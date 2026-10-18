/**
 * Server-side subclass of TaskDecision — enforces who may decide an approval task
 * (bc-aidp-next-golive#320 §3, rule 1: no self-approval).
 *
 * The rule itself is {@link TaskDecisionRefusal} (./TaskDecisionAuthority.ts). This class gathers its
 * facts on the server, where the signed-in user is known, and refuses the save through async
 * validation. It runs whenever a decision is created, or an existing one changes the fields the rule
 * reads, so every path that records a decision is covered: the in-app approval panel (which saves
 * from the browser), the Tasks inbox, and other apps' server code calling
 * `TaskOrchestrationService.RecordDecision`.
 *
 * Off by default: with the Tasks setting `PreventSelfApproval` unset or false, nothing is read and
 * every decision is accepted as before.
 *
 * CONNECTS TO:
 *   READS:  Tasks · Task Types · Task Assignments · MJ_BizApps_Common: People · MJ: Roles · MJ: User Roles
 *   SETTINGS: ./TasksSettings.ts (PreventSelfApproval, SelfApprovalExemptRole)
 */
import {
    BaseEntity,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
    type IMetadataProvider,
    type UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTaskDecisionEntity } from '@mj-biz-apps/tasks-entities';
import { TaskDecisionRefusal, type DecisionAssignmentFact, type TaskDecisionFacts } from './TaskDecisionAuthority.js';
import { TasksSettings } from './TasksSettings.js';

export const TASK_DECISION_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const TASK_ASSIGNMENT_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';
const USERS_ENTITY = 'MJ: Users';
const ROLES_ENTITY = 'MJ: Roles';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const SOURCE = 'TaskDecisionEntityServer.ValidateAsync';

/** The decision fields the rule reads; a change to any of them re-checks a saved decision. */
const CHECKED_FIELDS = ['TaskID', 'OutcomeID', 'DecidedByPersonID', 'TaskAssignmentID'] as const;

/** A UUID literal for a filter, or an error: every id here reaches SQL text. */
function guid(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id}'`;
}

/** True when the entity is People or an IS-A subtype of it. */
function isPeopleEntity(provider: IMetadataProvider, entityID: string): boolean {
    const entity = provider.EntityByID(entityID);
    if (!entity) return false;
    return entity.Name === PEOPLE_ENTITY || (entity.ParentChain ?? []).some((parent) => parent.Name === PEOPLE_ENTITY);
}

@RegisterClass(BaseEntity, TASK_DECISION_ENTITY)
export class TaskDecisionEntityServer extends mjBizAppsTasksTaskDecisionEntity {
    /** Async validation carries the rule, so it must run on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        if (this.IsSaved && !CHECKED_FIELDS.some((name) => this.GetFieldByName(name)?.Dirty)) return result;
        try {
            const refusal = await this.refusal();
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(SOURCE, refusal, null));
            }
        } catch (err: unknown) {
            // Fail closed: a decision whose decider cannot be checked is not recorded.
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskDecisionEntityServer: checking the decider on task ${this.TaskID} failed: ${msg}`);
            result.Success = false;
            result.Errors.push(new ValidationErrorInfo(SOURCE, `The decision was not recorded: who may decide this task could not be checked (${msg}).`, null));
        }
        return result;
    }

    /** Why this decision must not be saved, or null. Reads nothing while the setting is off. */
    private async refusal(): Promise<string | null> {
        const provider = Metadata.Provider;
        const user = this.ContextCurrentUser;
        if (!user) {
            // No signed-in user means no decider to check. Only the already-loaded settings cache can be
            // read without one; when the guard is on, the save is refused rather than let through unchecked.
            return TasksSettings.PreventSelfApproval(provider)
                ? 'The decision was not recorded: it was saved without a signed-in user, so who decided it cannot be checked.'
                : null;
        }
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.PreventSelfApproval(provider)) return null;
        const facts = await this.gatherFacts(provider, user);
        return facts ? TaskDecisionRefusal(facts) : null;
    }

    /** The facts for {@link TaskDecisionRefusal}; null when the task is not an approval task. */
    private async gatherFacts(provider: IMetadataProvider, user: UserInfo): Promise<TaskDecisionFacts | null> {
        const rv = new RunView(this.RunViewProviderToUse);
        const taskFilter = guid(this.TaskID, 'TaskID');
        const personFilter = this.personFilter(provider, user);
        const [taskRes, assignmentRes, peopleRes] = await rv.RunViews([
            { EntityName: TASK_ENTITY, ExtraFilter: `ID = ${taskFilter}`, Fields: ['ID', 'TypeID', 'CreatedByPersonID'], ResultType: 'simple', BypassCache: true },
            { EntityName: TASK_ASSIGNMENT_ENTITY, ExtraFilter: `TaskID = ${taskFilter}`, Fields: ['ID', 'AssigneeEntityID', 'AssigneeRecordID'], ResultType: 'simple', BypassCache: true },
            { EntityName: PEOPLE_ENTITY, ExtraFilter: personFilter, Fields: ['ID'], ResultType: 'simple', BypassCache: true },
        ], user);
        for (const res of [taskRes, assignmentRes, peopleRes]) {
            if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'a lookup returned no result');
        }
        const task = (taskRes.Results as Array<{ TypeID: string; CreatedByPersonID: string | null }>)[0];
        if (!task) throw new Error(`task ${this.TaskID} was not found`);
        if (!(await this.isApprovalType(rv, task.TypeID, user))) return null;

        const deciderPersonIDs = (peopleRes.Results as Array<{ ID: string }>).map((p) => p.ID);
        const creatorIsDecider = deciderPersonIDs.some((p) => p.toLowerCase() === (task.CreatedByPersonID ?? '').toLowerCase());
        return {
            PreventSelfApproval: true,
            IsApprovalTask: true,
            DeciderUserID: user.ID,
            DeciderPersonIDs: deciderPersonIDs,
            DecidedByPersonID: this.DecidedByPersonID ?? null,
            TaskAssignmentID: this.TaskAssignmentID ?? null,
            TaskCreatedByPersonID: task.CreatedByPersonID ?? null,
            Assignments: assignmentRes.Results as DecisionAssignmentFact[],
            IsPeopleEntityID: (entityID: string) => isPeopleEntity(provider, entityID),
            UsersEntityID: provider.EntityByName(USERS_ENTITY)?.ID ?? null,
            // Only read when it matters: the decider created the task.
            DeciderIsExempt: creatorIsDecider ? await this.holdsExemptRole(rv, provider, user) : false,
        };
    }

    /** People bound to the user: the user's own People link, and any Person whose LinkedUserID names them. */
    private personFilter(provider: IMetadataProvider, user: UserInfo): string {
        const clauses = [`LinkedUserID = ${guid(user.ID, 'UserID')}`];
        const linkedEntityID = user.LinkedEntityID != null ? String(user.LinkedEntityID) : '';
        const linkedRecordID = user.LinkedEntityRecordID != null ? String(user.LinkedEntityRecordID) : '';
        if (IsValidUUID(linkedEntityID) && IsValidUUID(linkedRecordID) && isPeopleEntity(provider, linkedEntityID)) {
            clauses.push(`ID = '${linkedRecordID}'`);
        }
        return clauses.join(' OR ');
    }

    private async isApprovalType(rv: RunView, typeID: string, user: UserInfo): Promise<boolean> {
        const res = await rv.RunView<{ IsApproval: boolean }>(
            { EntityName: TASK_TYPE_ENTITY, ExtraFilter: `ID = ${guid(typeID, 'TypeID')}`, Fields: ['IsApproval'], MaxRows: 1, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'the task type lookup returned no result');
        return res.Results?.[0]?.IsApproval === true;
    }

    /** Whether the user holds the role `SelfApprovalExemptRole` names. A named role that does not exist exempts nobody. */
    private async holdsExemptRole(rv: RunView, provider: IMetadataProvider, user: UserInfo): Promise<boolean> {
        const roleName = TasksSettings.SelfApprovalExemptRole(provider);
        if (!roleName) return false;
        const roleRes = await rv.RunView<{ ID: string }>(
            { EntityName: ROLES_ENTITY, ExtraFilter: `Name = '${roleName.replace(/'/g, "''")}'`, Fields: ['ID'], MaxRows: 1, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!roleRes?.Success) throw new Error(roleRes?.ErrorMessage ?? 'the role lookup returned no result');
        const role = roleRes.Results?.[0];
        if (!role) {
            LogError(`TaskDecisionEntityServer: the SelfApprovalExemptRole setting names '${roleName}', which is not a role; nobody is exempt.`);
            return false;
        }
        const heldRes = await rv.RunView<{ ID: string }>(
            { EntityName: USER_ROLES_ENTITY, ExtraFilter: `UserID = ${guid(user.ID, 'UserID')} AND RoleID = ${guid(role.ID, 'RoleID')}`, Fields: ['ID'], MaxRows: 1, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!heldRes?.Success) throw new Error(heldRes?.ErrorMessage ?? 'the user role lookup returned no result');
        return (heldRes.Results?.length ?? 0) > 0;
    }
}
