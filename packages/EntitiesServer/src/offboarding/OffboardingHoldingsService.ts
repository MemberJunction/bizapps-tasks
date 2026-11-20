/**
 * Offboarding holdings for Tasks (bc-aidp-next-golive#297): lists the open task assignments a departed
 * user holds and moves them to a successor.
 *
 * A holding is a Task Assignment in status Pending or InProgress, on a task that is neither Completed
 * nor Cancelled, whose assignee is the leaver: as their `MJ: Users` row, as any Person bound to that
 * user (UserPeople), or as their `MJ: Employees` row. Role assignments are shared queues and stay put.
 *
 * A move changes only the assignee, through the Task Assignment's own Save run as the calling user, so
 * TaskAssignmentEntityServer's approval guard (ApprovalReassignRoles, no self-reassignment) decides;
 * a refused save is reported as skipped. AssignedByPersonID, the task's creator and every completed or
 * cancelled item stay as they are.
 *
 * CONNECTS TO:
 *   READS:  MJ: Users · MJ: Employees · MJ: User Roles · MJ_BizApps_Common: People · Tasks · Task Types
 *           · Task Assignments · MJ_BizApps_Accounting: Accounting Company Profiles (when installed)
 *   WRITES: Task Assignments (AssigneeEntityID, AssigneeRecordID)
 *   RULES:  ./OffboardingRules.ts
 */
import { Metadata, RunView, type IMetadataProvider, type IRunViewProvider, type RunViewParams, type UserInfo } from '@memberjunction/core';
import { IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { TasksSettings } from '../TasksSettings.js';
import { GuidLiteral as guid, IsPeopleEntity, PEOPLE_ENTITY, PersonIDsForUser } from '../UserPeople.js';
import {
    ALREADY_ASSIGNED_REASON,
    type AssigneeKind,
    type AssignmentHoldingFact,
    type CallerAuthority,
    NOT_HELD_REASON,
    type OffboardingHolding,
    type OffboardingSkip,
    SALES_ADMIN_ROLE,
    SelectRequested,
    SuccessorRecordFor,
    type SuccessorTargets,
    TASK_ASSIGNMENT_ENTITY_NAME,
    ToHolding,
} from './OffboardingRules.js';

const USERS_ENTITY = 'MJ: Users';
const EMPLOYEES_ENTITY = 'MJ: Employees';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
/** Owned by the accounting app, which may not be installed; looked up by name only. */
export const ACCOUNTING_COMPANY_PROFILES_ENTITY = 'MJ_BizApps_Accounting: Accounting Company Profiles';

const OPEN_ASSIGNMENT_FILTER = "Status IN ('Pending', 'InProgress')";
const CLOSED_TASK_STATUSES = "('Completed', 'Cancelled')";
/** IDs per `IN (...)` list, well under SQL Server's parameter and text limits. */
const ID_CHUNK = 200;

type UserRow = { ID: string; IsActive: boolean; EmployeeID: string | null; LinkedEntityID: string | null; LinkedEntityRecordID: string | null };
type EmployeeRow = { ID: string; SupervisorID: string | null };
type AssignmentRow = { ID: string; TaskID: string; AssigneeEntityID: string; AssigneeRecordID: string };
type TaskRow = { ID: string; Name: string; TypeID: string };

/** Who the leaver is, in every identity a Task Assignment can name. */
export interface LeaverIdentity {
    UserID: string | null;
    EmployeeID: string | null;
    SupervisorEmployeeID: string | null;
    PersonIDs: string[];
}

/** The leaver's holdings as listed for one caller, with the facts behind them. */
export interface HoldingsListing {
    Holdings: OffboardingHolding[];
    Facts: AssignmentHoldingFact[];
}

export type ReassignResultCode = 'SUCCESS' | 'NOT_AUTHORIZED' | 'INVALID_INPUT';

export interface ReassignOutcome {
    ResultCode: ReassignResultCode;
    Message: string;
    Moved: number;
    Skipped: OffboardingSkip[];
}

/** Entity IDs that identify each kind of assignee. */
interface AssigneeEntityIDs {
    Users: string | null;
    Employees: string | null;
    PeopleFamily: string[];
}

/** Lists and moves a leaver's Tasks holdings, reading and saving as the calling user. */
export class OffboardingHoldingsService {
    private readonly provider: IMetadataProvider;

    constructor(
        private readonly contextUser: UserInfo,
        provider?: IMetadataProvider,
        private readonly runViewProvider?: IRunViewProvider,
    ) {
        this.provider = provider ?? Metadata.Provider;
    }

    // ───────────────────────── leaver and caller ─────────────────────────

    /**
     * Resolves the leaver from a user ID, an employee ID or both, filling in the other through
     * `MJ: Users`.EmployeeID. Null when neither resolves to a record.
     */
    public async ResolveLeaver(userID: string | null, employeeID: string | null): Promise<LeaverIdentity | null> {
        const user = userID ? await this.loadUserByID(userID) : employeeID ? await this.loadUserByEmployee(employeeID) : null;
        const resolvedEmployeeID = employeeID ?? user?.EmployeeID ?? null;
        const employee = resolvedEmployeeID ? await this.loadEmployee(resolvedEmployeeID) : null;
        if (!user && !employee) return null;
        return {
            UserID: user?.ID ?? null,
            EmployeeID: employee?.ID ?? null,
            SupervisorEmployeeID: employee?.SupervisorID ?? null,
            PersonIDs: user ? await PersonIDsForUser(this.provider, this.runViewProvider, user, this.contextUser) : [],
        };
    }

    /** What the calling user may do with this leaver's holdings. */
    public async ResolveCallerAuthority(leaver: LeaverIdentity): Promise<CallerAuthority> {
        const roles = await this.callerRoleNames();
        const callerEmployeeID = this.contextUser.EmployeeID != null ? String(this.contextUser.EmployeeID) : null;
        return {
            IsLeaversSupervisor: UUIDsEqual(leaver.SupervisorEmployeeID, callerEmployeeID) && !!callerEmployeeID,
            HoldsSalesAdmin: roles.has(SALES_ADMIN_ROLE.toLowerCase()),
            IsCFOApprover: await this.callerIsCFOApprover(),
            MayReassignApprovals: await this.callerMayReassignApprovals(roles),
        };
    }

    private async loadUserByID(userID: string): Promise<UserRow | null> {
        return this.first<UserRow>(USERS_ENTITY, `ID = ${guid(userID, 'LeaverUserID')}`, ['ID', 'IsActive', 'EmployeeID', 'LinkedEntityID', 'LinkedEntityRecordID']);
    }

    /** The user bound to an employee, preferring an active one when several are. */
    private async loadUserByEmployee(employeeID: string): Promise<UserRow | null> {
        const rows = await this.view<UserRow>({
            EntityName: USERS_ENTITY,
            ExtraFilter: `EmployeeID = ${guid(employeeID, 'LeaverEmployeeID')}`,
            Fields: ['ID', 'IsActive', 'EmployeeID', 'LinkedEntityID', 'LinkedEntityRecordID'],
        });
        return rows.find((u) => u.IsActive) ?? rows[0] ?? null;
    }

    private async loadEmployee(employeeID: string): Promise<EmployeeRow | null> {
        return this.first<EmployeeRow>(EMPLOYEES_ENTITY, `ID = ${guid(employeeID, 'EmployeeID')}`, ['ID', 'SupervisorID']);
    }

    /** The caller's role names, trimmed and lower-cased, read fresh so a role just granted counts. */
    private async callerRoleNames(): Promise<Set<string>> {
        const rows = await this.view<{ Role: string | null }>({
            EntityName: USER_ROLES_ENTITY,
            ExtraFilter: `UserID = ${guid(this.contextUser.ID, 'UserID')}`,
            Fields: ['Role'],
        });
        return new Set(rows.map((r) => String(r.Role ?? '').trim().toLowerCase()));
    }

    /** Whether the caller is the CFO approver of any accounting company profile; false when accounting is not installed. */
    private async callerIsCFOApprover(): Promise<boolean> {
        if (!this.provider.EntityByName(ACCOUNTING_COMPANY_PROFILES_ENTITY)) return false;
        const row = await this.first<{ ID: string }>(ACCOUNTING_COMPANY_PROFILES_ENTITY, `ApprovalCFOUserID = ${guid(this.contextUser.ID, 'UserID')}`, ['ID']);
        return !!row;
    }

    /**
     * The same answer TaskAssignmentEntityServer gives on save: anyone while `ApprovalReassignRoles`
     * is empty, otherwise a holder of a role it names. Used to predict CanReassign; the guard decides.
     */
    private async callerMayReassignApprovals(roles: Set<string>): Promise<boolean> {
        await TasksSettings.Load(this.provider, this.contextUser);
        const allowed = TasksSettings.ApprovalReassignRoles(this.provider);
        return allowed.length === 0 || allowed.some((role) => roles.has(role.toLowerCase()));
    }

    // ───────────────────────── listing ─────────────────────────

    /** The leaver's open task assignments, each with whether this caller may move it. */
    public async ListHoldings(leaver: LeaverIdentity, authority: CallerAuthority): Promise<HoldingsListing> {
        const facts = await this.loadHoldingFacts(leaver);
        return { Facts: facts, Holdings: facts.map((f) => ToHolding(f, authority)) };
    }

    private assigneeEntityIDs(): AssigneeEntityIDs {
        return {
            Users: this.provider.EntityByName(USERS_ENTITY)?.ID ?? null,
            Employees: this.provider.EntityByName(EMPLOYEES_ENTITY)?.ID ?? null,
            PeopleFamily: this.provider.Entities.filter((e) => IsPeopleEntity(this.provider, e.ID)).map((e) => e.ID),
        };
    }

    /** A filter matching assignments to any of the given identities, or null when there are none. */
    private assigneeFilter(ids: AssigneeEntityIDs, who: { UserID: string | null; EmployeeID: string | null; PersonIDs: readonly string[] }): string | null {
        const clauses: string[] = [];
        if (ids.Users && who.UserID) clauses.push(`(AssigneeEntityID = '${ids.Users}' AND AssigneeRecordID = ${guid(who.UserID, 'UserID')})`);
        if (ids.Employees && who.EmployeeID) clauses.push(`(AssigneeEntityID = '${ids.Employees}' AND AssigneeRecordID = ${guid(who.EmployeeID, 'EmployeeID')})`);
        if (ids.PeopleFamily.length > 0 && who.PersonIDs.length > 0) {
            const entities = ids.PeopleFamily.map((id) => `'${id}'`).join(', ');
            const people = who.PersonIDs.map((id) => guid(id, 'PersonID')).join(', ');
            clauses.push(`(AssigneeEntityID IN (${entities}) AND AssigneeRecordID IN (${people}))`);
        }
        return clauses.length > 0 ? `(${clauses.join(' OR ')})` : null;
    }

    private async loadHoldingFacts(leaver: LeaverIdentity): Promise<AssignmentHoldingFact[]> {
        const ids = this.assigneeEntityIDs();
        const filter = this.assigneeFilter(ids, leaver);
        if (!filter) return [];
        const assignments = await this.view<AssignmentRow>({
            EntityName: TASK_ASSIGNMENT_ENTITY_NAME,
            ExtraFilter: `${OPEN_ASSIGNMENT_FILTER} AND ${filter}`,
            Fields: ['ID', 'TaskID', 'AssigneeEntityID', 'AssigneeRecordID'],
        });
        const tasks = await this.loadOpenTasks(assignments.map((a) => a.TaskID));
        const approvalTypes = await this.loadApprovalTypeIDs([...tasks.values()].map((t) => t.TypeID));
        return assignments.flatMap((a) => {
            const task = tasks.get(NormalizeUUID(a.TaskID));
            const kind = this.assigneeKind(ids, a.AssigneeEntityID);
            if (!task || !kind) return [];
            return [{
                AssignmentID: a.ID,
                TaskID: a.TaskID,
                TaskName: task.Name,
                IsApproval: approvalTypes.has(NormalizeUUID(task.TypeID)),
                AssigneeEntityID: a.AssigneeEntityID,
                AssigneeRecordID: a.AssigneeRecordID,
                AssigneeKind: kind,
            }];
        });
    }

    private assigneeKind(ids: AssigneeEntityIDs, entityID: string): AssigneeKind | null {
        if (UUIDsEqual(entityID, ids.Users)) return 'User';
        if (UUIDsEqual(entityID, ids.Employees)) return 'Employee';
        return ids.PeopleFamily.some((id) => UUIDsEqual(id, entityID)) ? 'Person' : null;
    }

    /** The tasks among `taskIDs` that are neither Completed nor Cancelled, keyed by normalized ID. */
    private async loadOpenTasks(taskIDs: string[]): Promise<Map<string, TaskRow>> {
        const rows = await this.viewByIDs<TaskRow>(TASK_ENTITY, 'ID', taskIDs, `Status NOT IN ${CLOSED_TASK_STATUSES}`, ['ID', 'Name', 'TypeID']);
        return new Map(rows.map((t) => [NormalizeUUID(t.ID), t]));
    }

    private async loadApprovalTypeIDs(typeIDs: string[]): Promise<Set<string>> {
        const rows = await this.viewByIDs<{ ID: string; IsApproval: boolean }>(TASK_TYPE_ENTITY, 'ID', typeIDs, 'IsApproval = 1', ['ID', 'IsApproval']);
        return new Set(rows.filter((t) => t.IsApproval === true).map((t) => NormalizeUUID(t.ID)));
    }

    // ───────────────────────── reassignment ─────────────────────────

    /**
     * Moves the requested holdings of the leaver to the successor, one Save at a time as the caller.
     * `kinds` and `recordIDs`, when given, narrow the request.
     */
    public async Reassign(leaver: LeaverIdentity, successorUserID: string, kinds: string[] | null, recordIDs: string[] | null): Promise<ReassignOutcome> {
        const successor = await this.resolveSuccessor(leaver, successorUserID);
        if ('Reason' in successor) return { ResultCode: 'INVALID_INPUT', Message: successor.Reason, Moved: 0, Skipped: [] };

        const authority = await this.ResolveCallerAuthority(leaver);
        const listing = await this.ListHoldings(leaver, authority);
        const { Selected, Unknown } = SelectRequested(listing.Holdings, kinds, recordIDs);
        const skipped: OffboardingSkip[] = Unknown.map((id) => ({ Kind: '', EntityName: TASK_ASSIGNMENT_ENTITY_NAME, RecordID: id, Reason: NOT_HELD_REASON }));
        const permitted = Selected.filter((h) => h.CanReassign);
        skipped.push(...Selected.filter((h) => !h.CanReassign).map((h) => skipOf(h, h.Note ?? 'You may not move this item.')));

        if (Selected.length > 0 && permitted.length === 0) {
            return { ResultCode: 'NOT_AUTHORIZED', Message: 'You may not move any of the requested items.', Moved: 0, Skipped: skipped };
        }
        const moved = await this.moveAll(permitted, listing.Facts, successor, skipped);
        return { ResultCode: 'SUCCESS', Message: `Moved ${moved} task assignment(s); skipped ${skipped.length}.`, Moved: moved, Skipped: skipped };
    }

    /** The successor's records, or why the successor cannot take the leaver's items. */
    private async resolveSuccessor(leaver: LeaverIdentity, successorUserID: string): Promise<SuccessorTargets | { Reason: string }> {
        if (!IsValidUUID(successorUserID)) return { Reason: 'SuccessorUserID is not a valid ID.' };
        const user = await this.loadUserByID(successorUserID);
        if (!user) return { Reason: 'The successor user was not found.' };
        if (!user.IsActive) return { Reason: 'The successor user is inactive.' };
        if (UUIDsEqual(user.ID, leaver.UserID) || (!!user.EmployeeID && UUIDsEqual(user.EmployeeID, leaver.EmployeeID))) {
            return { Reason: 'The successor is the leaver.' };
        }
        const personIDs = await PersonIDsForUser(this.provider, this.runViewProvider, user, this.contextUser);
        return { UserID: user.ID, EmployeeID: user.EmployeeID, PersonIDs: personIDs };
    }

    private async moveAll(permitted: OffboardingHolding[], facts: AssignmentHoldingFact[], successor: SuccessorTargets, skipped: OffboardingSkip[]): Promise<number> {
        const factByID = new Map(facts.map((f) => [NormalizeUUID(f.AssignmentID), f]));
        const chosen = permitted.flatMap((h) => {
            const fact = factByID.get(NormalizeUUID(h.RecordID));
            return fact ? [{ Holding: h, Fact: fact }] : [];
        });
        const existing = await this.successorAssignmentKeys(chosen.map((c) => c.Fact.TaskID), successor);
        let moved = 0;
        for (const { Holding, Fact } of chosen) {
            const reason = await this.moveOne(Fact, successor, existing);
            if (reason) skipped.push(skipOf(Holding, reason));
            else moved++;
        }
        return moved;
    }

    /** Moves one assignment; returns why it was not moved, or null. */
    private async moveOne(fact: AssignmentHoldingFact, successor: SuccessorTargets, existing: Set<string>): Promise<string | null> {
        const target = await this.successorRecordFor(fact, successor);
        if ('Reason' in target) return target.Reason;
        const key = assignmentKey(fact.TaskID, fact.AssigneeEntityID, target.RecordID);
        if (existing.has(key)) return ALREADY_ASSIGNED_REASON;

        const assignment = await new Metadata().GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY_NAME, this.contextUser);
        if (!(await assignment.Load(fact.AssignmentID))) return 'The assignment could not be loaded.';
        if (!isStillLeavers(assignment, fact)) return NOT_HELD_REASON;
        // Only the assignee changes: AssignedByPersonID (the requester), the role and the status stay.
        assignment.AssigneeRecordID = target.RecordID;
        if (await assignment.Save()) {
            existing.add(key);
            return null;
        }
        return assignment.LatestResult?.CompleteMessage || 'The save was refused.';
    }

    /**
     * The successor's record in the entity the leaver was assigned through. A People subtype needs the
     * successor's Person to exist in that subtype too.
     */
    private async successorRecordFor(fact: AssignmentHoldingFact, successor: SuccessorTargets): Promise<{ RecordID: string } | { Reason: string }> {
        const target = SuccessorRecordFor(fact.AssigneeKind, successor);
        if (fact.AssigneeKind !== 'Person' || 'Reason' in target) return target;
        const entity = this.provider.EntityByID(fact.AssigneeEntityID);
        if (!entity || entity.Name === PEOPLE_ENTITY) return target;
        const rows = await this.viewByIDs<{ ID: string }>(entity.Name, 'ID', [...successor.PersonIDs], '', ['ID']);
        const match = successor.PersonIDs.find((p) => rows.some((r) => UUIDsEqual(r.ID, p)));
        return match ? { RecordID: match } : { Reason: `The successor has no ${entity.Name} record, and this assignment is to one.` };
    }

    /** Keys of the successor's existing assignments on these tasks, so a move never duplicates one. */
    private async successorAssignmentKeys(taskIDs: string[], successor: SuccessorTargets): Promise<Set<string>> {
        const filter = this.assigneeFilter(this.assigneeEntityIDs(), successor);
        if (!filter || taskIDs.length === 0) return new Set();
        const rows = await this.viewByIDs<AssignmentRow>(TASK_ASSIGNMENT_ENTITY_NAME, 'TaskID', taskIDs, filter, ['ID', 'TaskID', 'AssigneeEntityID', 'AssigneeRecordID']);
        return new Set(rows.map((r) => assignmentKey(r.TaskID, r.AssigneeEntityID, r.AssigneeRecordID)));
    }

    // ───────────────────────── data access ─────────────────────────

    /** A simple, uncached view as the caller. @throws when the view fails, so nothing is reported from a partial read. */
    private async view<T>(params: Pick<RunViewParams, 'EntityName' | 'ExtraFilter' | 'Fields' | 'MaxRows'>): Promise<T[]> {
        const res = await new RunView(this.runViewProvider).RunView<T>({ ...params, ResultType: 'simple', BypassCache: true }, this.contextUser);
        if (!res?.Success) throw new Error(res?.ErrorMessage ?? `the ${params.EntityName} lookup returned no result`);
        return res.Results ?? [];
    }

    private async first<T>(entityName: string, filter: string, fields: string[]): Promise<T | null> {
        return (await this.view<T>({ EntityName: entityName, ExtraFilter: filter, Fields: fields, MaxRows: 1 }))[0] ?? null;
    }

    /** Rows whose `column` is one of `ids`, in chunks, with an optional extra filter. */
    private async viewByIDs<T>(entityName: string, column: string, ids: string[], extra: string, fields: string[]): Promise<T[]> {
        const unique = [...new Set(ids.filter((id) => !!id).map((id) => NormalizeUUID(id)))];
        const out: T[] = [];
        for (let i = 0; i < unique.length; i += ID_CHUNK) {
            const list = unique.slice(i, i + ID_CHUNK).map((id) => guid(id, column)).join(', ');
            const filter = `${column} IN (${list})${extra ? ` AND ${extra}` : ''}`;
            out.push(...(await this.view<T>({ EntityName: entityName, ExtraFilter: filter, Fields: fields })));
        }
        return out;
    }
}

function skipOf(holding: OffboardingHolding, reason: string): OffboardingSkip {
    return { Kind: holding.Kind, EntityName: holding.EntityName, RecordID: holding.RecordID, Reason: reason };
}

function assignmentKey(taskID: string, entityID: string, recordID: string): string {
    return `${NormalizeUUID(taskID)}|${NormalizeUUID(entityID)}|${NormalizeUUID(recordID)}`;
}

/** The loaded assignment is still the open one the listing found for the leaver. */
function isStillLeavers(assignment: mjBizAppsTasksTaskAssignmentEntity, fact: AssignmentHoldingFact): boolean {
    return (assignment.Status === 'Pending' || assignment.Status === 'InProgress')
        && UUIDsEqual(assignment.AssigneeEntityID, fact.AssigneeEntityID)
        && UUIDsEqual(assignment.AssigneeRecordID, fact.AssigneeRecordID);
}
