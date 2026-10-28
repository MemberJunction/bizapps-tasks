/**
 * Server-side subclass of TaskAssignment — guards who an approval task is assigned to
 * (bc-aidp-next-golive#389).
 *
 * Every approval workflow (concessions, order review, access overrides, accounting batches and manual
 * entries, close-won) CREATES its assignments as the signed-in requester; none updates or deletes one.
 * So the edit paths can be narrowed without touching routing. Create is never checked: some workflows
 * (order review, among others) legitimately assign the acting user. On a task whose type is an approval
 * type (`TaskType.IsApproval`):
 *   1. nobody may reassign the task to themselves, whatever their role;
 *   2. changing an assignment's task or assignee, or deleting it, is refused unless the user holds a
 *      role the Tasks setting `ApprovalReassignRoles` names. Empty (the default) lets nobody.
 * Any other change is accepted as before, and a non-approval task is never checked.
 *
 * CONNECTS TO:
 *   READS:  Tasks · Task Types · MJ_BizApps_Common: People · MJ: User Roles
 *   SETTINGS: ./TasksSettings.ts (ApprovalReassignRoles)
 */
import {
    BaseEntity,
    BaseEntityResult,
    EntityDeleteOptions,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
    type UserInfo,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { TasksSettings } from './TasksSettings.js';
import { GuidLiteral as guid, IsPeopleEntity as isPeopleEntity, PEOPLE_ENTITY, PeopleFilterForUser } from './UserPeople.js';

export const TASK_ASSIGNMENT_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const USERS_ENTITY = 'MJ: Users';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const SOURCE = 'TaskAssignmentEntityServer';

/** The fields that say who an assignment is for; changing one is a reassignment. */
const ASSIGNEE_FIELDS = ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID'] as const;

export const SELF_ASSIGN_REFUSAL = 'You cannot assign an approval to yourself. Someone else must approve it.';
export const REASSIGN_REFUSAL = 'This is an approval task, and your role does not allow changing who it is assigned to.';
export const REMOVE_REFUSAL = 'This is an approval task, and your role does not allow removing its assignee.';
const NO_USER_REFUSAL = 'An approval assignment cannot be changed or removed without a signed-in user.';

@RegisterClass(BaseEntity, TASK_ASSIGNMENT_ENTITY)
export class TaskAssignmentEntityServer extends mjBizAppsTasksTaskAssignmentEntity {
    /** Async validation carries the rule, so it must run on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const reassigning = this.IsSaved && ASSIGNEE_FIELDS.some((name) => this.GetFieldByName(name)?.Dirty);
        if (!reassigning) return result;
        const refusal = await this.failClosed(() => this.reassignRefusal());
        if (refusal) {
            result.Success = false;
            result.Errors.push(new ValidationErrorInfo(SOURCE, refusal, null));
        }
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const refusal = this.IsSaved ? await this.failClosed(() => this.deleteRefusal()) : null;
        if (refusal) return this.refuseDelete(refusal);
        return super.Delete(options);
    }

    /** Why this reassignment must not be saved, or null. */
    private async reassignRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!(await this.touchesApprovalTask(user))) return null;
        if (!user) return NO_USER_REFUSAL;
        if (await this.assigneeIsUser(user)) return SELF_ASSIGN_REFUSAL;
        return (await this.holdsReassignRole(user)) ? null : REASSIGN_REFUSAL;
    }

    /** Why this assignment must not be deleted, or null. */
    private async deleteRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!(await this.touchesApprovalTask(user))) return null;
        if (!user) return NO_USER_REFUSAL;
        return (await this.holdsReassignRole(user)) ? null : REMOVE_REFUSAL;
    }

    /** Runs a check; a check that cannot be completed refuses rather than lets the write through. */
    private async failClosed(check: () => Promise<string | null>): Promise<string | null> {
        try {
            return await check();
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskAssignmentEntityServer: checking assignment ${this.ID ?? '(new)'} on task ${this.TaskID} failed: ${msg}`);
            return `The assignment was not changed: whether it is an approval could not be checked (${msg}).`;
        }
    }

    /** Whether the task this assignment is on, or was on before this change, is an approval task. */
    private async touchesApprovalTask(user: UserInfo | null): Promise<boolean> {
        const oldTaskID = this.GetFieldByName('TaskID')?.OldValue as string | null | undefined;
        const taskIDs = [...new Set([this.TaskID, oldTaskID].filter((id): id is string => !!id).map((id) => id.toUpperCase()))];
        if (taskIDs.length === 0) return false;
        const rv = new RunView(this.RunViewProviderToUse);
        const tasks = await rv.RunView<{ TypeID: string }>(
            { EntityName: TASK_ENTITY, ExtraFilter: `ID IN (${taskIDs.map((id) => guid(id, 'TaskID')).join(', ')})`, Fields: ['TypeID'], ResultType: 'simple', BypassCache: true },
            user ?? undefined,
        );
        if (!tasks?.Success) throw new Error(tasks?.ErrorMessage ?? 'the task lookup returned no result');
        const typeIDs = [...new Set((tasks.Results ?? []).map((t) => t.TypeID).filter((id) => !!id))];
        if (typeIDs.length === 0) return false;
        const types = await rv.RunView<{ IsApproval: boolean }>(
            { EntityName: TASK_TYPE_ENTITY, ExtraFilter: `ID IN (${typeIDs.map((id) => guid(id, 'TypeID')).join(', ')})`, Fields: ['IsApproval'], ResultType: 'simple', BypassCache: true },
            user ?? undefined,
        );
        if (!types?.Success) throw new Error(types?.ErrorMessage ?? 'the task type lookup returned no result');
        return (types.Results ?? []).some((t) => t.IsApproval === true);
    }

    /** Whether the assignee is the signed-in user, as one of their People or as the user directly. */
    private async assigneeIsUser(user: UserInfo): Promise<boolean> {
        const provider = Metadata.Provider;
        const recordID = (this.AssigneeRecordID ?? '').trim().toLowerCase();
        if (!recordID || !this.AssigneeEntityID) return false;
        const usersEntityID = provider.EntityByName(USERS_ENTITY)?.ID;
        if (usersEntityID && usersEntityID.toLowerCase() === this.AssigneeEntityID.toLowerCase()) return recordID === user.ID.toLowerCase();
        if (!isPeopleEntity(provider, this.AssigneeEntityID)) return false;
        const people = await new RunView(this.RunViewProviderToUse).RunView<{ ID: string }>(
            { EntityName: PEOPLE_ENTITY, ExtraFilter: PeopleFilterForUser(provider, user), Fields: ['ID'], ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!people?.Success) throw new Error(people?.ErrorMessage ?? 'the People lookup returned no result');
        return (people.Results ?? []).some((p) => p.ID.toLowerCase() === recordID);
    }

    /** Whether the user holds a role `ApprovalReassignRoles` names. No roles configured lets nobody. */
    private async holdsReassignRole(user: UserInfo): Promise<boolean> {
        await TasksSettings.Load(Metadata.Provider, user);
        const roles = TasksSettings.ApprovalReassignRoles(Metadata.Provider);
        if (roles.length === 0) return false;
        const names = roles.map((r) => `'${r.replace(/'/g, "''")}'`).join(', ');
        const held = await new RunView(this.RunViewProviderToUse).RunView<{ ID: string }>(
            { EntityName: USER_ROLES_ENTITY, ExtraFilter: `UserID = ${guid(user.ID, 'UserID')} AND Role IN (${names})`, Fields: ['ID'], MaxRows: 1, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!held?.Success) throw new Error(held?.ErrorMessage ?? 'the user role lookup returned no result');
        return (held.Results?.length ?? 0) > 0;
    }

    /** Records a refused delete where `LatestResult.CompleteMessage` (and so the caller) reads it. */
    private refuseDelete(message: string): false {
        const result = new BaseEntityResult();
        result.Success = false;
        result.Type = 'delete';
        result.Message = message;
        result.EndedAt = new Date();
        this.RegisterResultHistoryEntry(result);
        return false;
    }
}
