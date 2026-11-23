/**
 * Server-side subclass of TaskDecision — enforces who may decide an approval task
 * (bc-aidp-next-golive#320 §3, rule 1: no self-approval, and D13: `TaskType.RequiresAssigneeDecision`).
 *
 * The rule itself is {@link TaskDecisionRefusal} (./TaskDecisionAuthority.ts). This class gathers its
 * facts on the server, where the signed-in user is known, and refuses the save through async
 * validation. It runs whenever a decision is created, or an existing one changes the fields the rule
 * reads, so every path that records a decision is covered: the in-app approval panel (which saves
 * from the browser), the Tasks inbox, and other apps' server code calling
 * `TaskOrchestrationService.RecordDecision`.
 *
 * On by default (secure by default): only the Tasks setting `PreventSelfApproval` explicitly set to
 * false turns the global guard off. Even when `PreventSelfApproval` is explicitly false, a task whose
 * `TaskType` has `RequiresAssigneeDecision = true` (D13) still enforces assignee-only / no-self-approval.
 *
 * CONNECTS TO:
 *   READS:  Tasks · Task Types · Task Assignments · MJ_BizApps_Common: People · MJ: Roles · MJ: User Roles
 *   SETTINGS: TasksSettings (@mj-biz-apps/tasks-core: PreventSelfApproval, SelfApprovalExemptRole)
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
import { RegisterClass } from '@memberjunction/global';
import { GuidLiteral as guid, TasksLimitsResolver, TasksSettings } from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksTaskDecisionEntity } from '@mj-biz-apps/tasks-entities';
import { TaskDecisionRefusal, type DecisionAssignmentFact, type TaskDecisionFacts } from './TaskDecisionAuthority.js';
import { ApprovalActor, IsSystemActor } from './ApprovalActor.js';
import { IsPeopleEntity as isPeopleEntity, PEOPLE_ENTITY, PeopleFilterForUser } from './UserPeople.js';

export const TASK_DECISION_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const TASK_ASSIGNMENT_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const USERS_ENTITY = 'MJ: Users';
const ROLES_ENTITY = 'MJ: Roles';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const SOURCE = 'TaskDecisionEntityServer.ValidateAsync';

/** The decision fields the rule reads; a change to any of them re-checks a saved decision. */
const CHECKED_FIELDS = ['TaskID', 'OutcomeID', 'DecidedByPersonID', 'TaskAssignmentID'] as const;

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
        } catch (err) {
            // Fail closed: a decision whose decider cannot be checked is not recorded.
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskDecisionEntityServer: checking the decider on task ${this.TaskID} failed: ${msg}`);
            result.Success = false;
            result.Errors.push(new ValidationErrorInfo(SOURCE, `The decision was not recorded: who may decide this task could not be checked (${msg}).`, null));
        }
        return result;
    }

    /** Why this decision must not be saved, or null. */
    private async refusal(): Promise<string | null> {
        const provider = Metadata.Provider;
        const user = this.ContextCurrentUser;
        if (!user) {
            if (TasksSettings.PreventSelfApproval(provider)) {
                return 'The decision was not recorded: it was saved without a signed-in user, so who decided it cannot be checked.';
            }
            // Even when PreventSelfApproval is explicitly off, an approval task with RequiresAssigneeDecision
            // or an OrganizationID must still fail closed when no user context is supplied.
            const taskFilter = guid(this.TaskID, 'TaskID');
            const rv = new RunView(this.RunViewProviderToUse);
            const taskRes = await rv.RunView<{ TypeID: string; OrganizationID?: string | null }>(
                {
                    EntityName: TASK_ENTITY,
                    ExtraFilter: `ID = ${taskFilter}`,
                    Fields: ['ID', 'TypeID', 'OrganizationID'],
                    MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                    BypassCache: true,
                },
            );
            if (!taskRes?.Success) throw new Error(taskRes?.ErrorMessage ?? 'a lookup returned no result');
            const task = taskRes.Results?.[0];
            if (!task) throw new Error(`task ${this.TaskID} was not found`);
            const typeFlags = await this.loadApprovalTypeFlags(rv, task.TypeID, undefined);
            if (typeFlags.IsApproval && (typeFlags.RequiresAssigneeDecision || task.OrganizationID)) {
                return 'The decision was not recorded: it was saved without a signed-in user, so who decided it cannot be checked.';
            }
            return null;
        }
        await TasksSettings.Load(provider, user);
        const preventSelfApproval = TasksSettings.PreventSelfApproval(provider);
        const facts = await this.gatherFacts(provider, user, preventSelfApproval);
        return facts ? TaskDecisionRefusal(facts) : null;
    }

    /** The facts for {@link TaskDecisionRefusal}; null when the task is not an approval task or neither guard is active. */
    private async gatherFacts(
        provider: IMetadataProvider,
        user: UserInfo,
        preventSelfApproval: boolean,
    ): Promise<TaskDecisionFacts | null> {
        const rv = new RunView(this.RunViewProviderToUse);
        const taskFilter = guid(this.TaskID, 'TaskID');
        type DecidableTaskRow = {
            TypeID: string;
            CreatedByPersonID: string | null;
            OrganizationID?: string | null;
            Status?: string | null;
        };

        // When PreventSelfApproval is off, first check if the task's TaskType sets RequiresAssigneeDecision (D13)
        // or if the approval task is scoped to an organization.
        if (!preventSelfApproval) {
            const taskRes = await rv.RunView<DecidableTaskRow>(
                {
                    EntityName: TASK_ENTITY,
                    ExtraFilter: `ID = ${taskFilter}`,
                    Fields: ['ID', 'TypeID', 'CreatedByPersonID', 'OrganizationID', 'Status'],
                    MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            );
            if (!taskRes?.Success) throw new Error(taskRes?.ErrorMessage ?? 'a lookup returned no result');
            const task = taskRes.Results?.[0];
            if (!task) throw new Error(`task ${this.TaskID} was not found`);
            const typeFlags = await this.loadApprovalTypeFlags(rv, task.TypeID, user);
            if (!typeFlags.IsApproval || (!typeFlags.RequiresAssigneeDecision && !task.OrganizationID)) {
                return null;
            }
            return this.buildFactsForTask(rv, provider, user, task, false, typeFlags.RequiresAssigneeDecision);
        }

        const personFilter = PeopleFilterForUser(provider, user);
        const [taskRes, assignmentRes, peopleRes] = await rv.RunViews([
            { EntityName: TASK_ENTITY, ExtraFilter: `ID = ${taskFilter}`, Fields: ['ID', 'TypeID', 'CreatedByPersonID', 'OrganizationID', 'Status'], ResultType: 'simple', BypassCache: true },
            { EntityName: TASK_ASSIGNMENT_ENTITY, ExtraFilter: `TaskID = ${taskFilter}`, Fields: ['ID', 'AssigneeEntityID', 'AssigneeRecordID', 'Status'], ResultType: 'simple', BypassCache: true },
            { EntityName: PEOPLE_ENTITY, ExtraFilter: personFilter, Fields: ['ID'], ResultType: 'simple', BypassCache: true },
        ], user);
        for (const res of [taskRes, assignmentRes, peopleRes]) {
            if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'a lookup returned no result');
        }
        const task = (taskRes.Results as DecidableTaskRow[])[0];
        if (!task) throw new Error(`task ${this.TaskID} was not found`);
        const typeFlags = await this.loadApprovalTypeFlags(rv, task.TypeID, user);
        if (!typeFlags.IsApproval) return null;

        const actor = new ApprovalActor(user, provider, this.RunViewProviderToUse);
        const actorOrganizationIDs =
            task.OrganizationID && !IsSystemActor(user) ? await actor.OrganizationIDs() : undefined;

        const deciderPersonIDs = (peopleRes.Results as Array<{ ID: string }>).map((p) => p.ID);
        const creatorIsDecider = deciderPersonIDs.some((p) => p.toLowerCase() === (task.CreatedByPersonID ?? '').toLowerCase());
        return {
            PreventSelfApproval: true,
            RequiresAssigneeDecision: typeFlags.RequiresAssigneeDecision,
            IsApprovalTask: true,
            TaskStatus: task.Status ?? null,
            TaskOrganizationID: task.OrganizationID ?? null,
            ActorOrganizationIDs: actorOrganizationIDs,
            DeciderUserID: user.ID,
            DeciderPersonIDs: deciderPersonIDs,
            DecidedByPersonID: this.DecidedByPersonID ?? null,
            TaskAssignmentID: this.TaskAssignmentID ?? null,
            TaskCreatedByPersonID: task.CreatedByPersonID ?? null,
            Assignments: assignmentRes.Results as DecisionAssignmentFact[],
            IsPeopleEntityID: (entityID: string) => isPeopleEntity(provider, entityID),
            UsersEntityID: provider.EntityByName(USERS_ENTITY)?.ID ?? null,
            RolesEntityID: provider.EntityByName(ROLES_ENTITY)?.ID ?? null,
            DeciderRoleIDs: (user.UserRoles ?? []).map((r) => r.RoleID),
            // Only read when it matters: the decider created the task.
            DeciderIsExempt: creatorIsDecider ? await this.holdsExemptRole(rv, provider, user) : false,
        };
    }

    private async buildFactsForTask(
        rv: RunView,
        provider: IMetadataProvider,
        user: UserInfo,
        task: { TypeID: string; CreatedByPersonID: string | null; OrganizationID?: string | null; Status?: string | null },
        preventSelfApproval: boolean,
        requiresAssigneeDecision: boolean,
    ): Promise<TaskDecisionFacts> {
        const taskFilter = guid(this.TaskID, 'TaskID');
        const personFilter = PeopleFilterForUser(provider, user);
        const [assignmentRes, peopleRes] = await rv.RunViews([
            { EntityName: TASK_ASSIGNMENT_ENTITY, ExtraFilter: `TaskID = ${taskFilter}`, Fields: ['ID', 'AssigneeEntityID', 'AssigneeRecordID', 'Status'], ResultType: 'simple', BypassCache: true },
            { EntityName: PEOPLE_ENTITY, ExtraFilter: personFilter, Fields: ['ID'], ResultType: 'simple', BypassCache: true },
        ], user);
        for (const res of [assignmentRes, peopleRes]) {
            if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'a lookup returned no result');
        }
        const actor = new ApprovalActor(user, provider, this.RunViewProviderToUse);
        const actorOrganizationIDs =
            task.OrganizationID && !IsSystemActor(user) ? await actor.OrganizationIDs() : undefined;
        const deciderPersonIDs = (peopleRes.Results as Array<{ ID: string }>).map((p) => p.ID);
        const creatorIsDecider = deciderPersonIDs.some((p) => p.toLowerCase() === (task.CreatedByPersonID ?? '').toLowerCase());
        return {
            PreventSelfApproval: preventSelfApproval,
            RequiresAssigneeDecision: requiresAssigneeDecision,
            IsApprovalTask: true,
            TaskStatus: task.Status ?? null,
            TaskOrganizationID: task.OrganizationID ?? null,
            ActorOrganizationIDs: actorOrganizationIDs,
            DeciderUserID: user.ID,
            DeciderPersonIDs: deciderPersonIDs,
            DecidedByPersonID: this.DecidedByPersonID ?? null,
            TaskAssignmentID: this.TaskAssignmentID ?? null,
            TaskCreatedByPersonID: task.CreatedByPersonID ?? null,
            Assignments: assignmentRes.Results as DecisionAssignmentFact[],
            IsPeopleEntityID: (entityID: string) => isPeopleEntity(provider, entityID),
            UsersEntityID: provider.EntityByName(USERS_ENTITY)?.ID ?? null,
            RolesEntityID: provider.EntityByName(ROLES_ENTITY)?.ID ?? null,
            DeciderRoleIDs: (user.UserRoles ?? []).map((r) => r.RoleID),
            DeciderIsExempt: creatorIsDecider ? await this.holdsExemptRole(rv, provider, user) : false,
        };
    }

    private async loadApprovalTypeFlags(
        rv: RunView,
        typeID: string,
        user: UserInfo | undefined,
    ): Promise<{ IsApproval: boolean; RequiresAssigneeDecision: boolean }> {
        const res = await rv.RunView<{ IsApproval: boolean; RequiresAssigneeDecision?: boolean }>(
            {
                EntityName: TASK_TYPE_ENTITY,
                ExtraFilter: `ID = ${guid(typeID, 'TypeID')}`,
                Fields: ['IsApproval', 'RequiresAssigneeDecision'],
                MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'the task type lookup returned no result');
        const row = res.Results?.[0];
        return {
            IsApproval: row?.IsApproval === true,
            RequiresAssigneeDecision: row?.RequiresAssigneeDecision === true,
        };
    }

    /** Whether the user holds the role `SelfApprovalExemptRole` names. A named role that does not exist exempts nobody. */
    private async holdsExemptRole(rv: RunView, provider: IMetadataProvider, user: UserInfo): Promise<boolean> {
        const roleName = TasksSettings.SelfApprovalExemptRole(provider);
        if (!roleName) return false;
        const singleRowMax = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow;
        const roleRes = await rv.RunView<{ ID: string }>(
            { EntityName: ROLES_ENTITY, ExtraFilter: `Name = '${roleName.replace(/'/g, "''")}'`, Fields: ['ID'], MaxRows: singleRowMax, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!roleRes?.Success) throw new Error(roleRes?.ErrorMessage ?? 'the role lookup returned no result');
        const role = roleRes.Results?.[0];
        if (!role) {
            LogError(`TaskDecisionEntityServer: the SelfApprovalExemptRole setting names '${roleName}', which is not a role; nobody is exempt.`);
            return false;
        }
        const heldRes = await rv.RunView<{ ID: string }>(
            { EntityName: USER_ROLES_ENTITY, ExtraFilter: `UserID = ${guid(user.ID, 'UserID')} AND RoleID = ${guid(role.ID, 'RoleID')}`, Fields: ['ID'], MaxRows: singleRowMax, ResultType: 'simple', BypassCache: true },
            user,
        );
        if (!heldRes?.Success) throw new Error(heldRes?.ErrorMessage ?? 'the user role lookup returned no result');
        return (heldRes.Results?.length ?? 0) > 0;
    }
}
