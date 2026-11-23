/**
 * Server-side subclass of TaskAssignment — guards who an approval task is assigned to
 * (bc-aidp-next-golive#389, bizapps-tasks#209).
 *
 * Every approval workflow (concessions, order review, access overrides, accounting batches and manual
 * entries, close-won) creates its assignments as the signed-in requester, so the requester names who
 * they are asking. On a task whose type is an approval type (`TaskType.IsApproval`):
 *   1. nobody may reassign the task to themselves, whatever their role: not as one of their People,
 *      not as their own user, not as an MJ role they hold;
 *   2. while the Tasks setting `ApprovalReassignRoles` names roles, changing an assignment's task or
 *      assignee, or deleting it, is refused unless the user holds one of them. Empty (the default)
 *      switches this rule off; rule 1 still applies;
 *   3. a NEW assignment follows {@link ApprovalAssignmentAddRefusal}: the task's creator names who
 *      they are asking while the request is open; anyone else needs the same right as rule 2 and may
 *      never add themselves. Before this rule create was unchecked, and whoever could create an
 *      assignment could make themselves an assignee of any approval and then decide it.
 * Server code that chose the assignee itself (timesheet routing, the BizAppsTasks human-task provider,
 * another app's workflow) vouches for one save with {@link TaskAssignmentEntityServer.AuthorizeApprovalAssignment};
 * the system user needs no vouching. Any other change is accepted as before, and a non-approval task
 * is never refused.
 *
 * CONNECTS TO:
 *   READS:  Tasks · Task Types · MJ_BizApps_Common: People · MJ: User Roles · MJ: Roles
 *   SETTINGS: TasksSettings (@mj-biz-apps/tasks-core: ApprovalReassignRoles)
 */
import {
    BaseEntity,
    BaseEntityResult,
    EntityDeleteOptions,
    EntitySaveOptions,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
    type IMetadataProvider,
    type UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { GuidLiteral as guid } from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { capturePostCommitToken, runAfterCommit } from './after-commit.js';
import { ApprovalActor, IsSystemActor } from './ApprovalActor.js';
import {
    ApprovalAssignmentAddRefusal,
    ApprovalAssignmentManageRefusal,
    SELF_ASSIGN_REFUSAL,
} from './ApprovalTaskAuthority.js';
import { wakeAssigneesForTaskAssignment } from './cos-wake-helpers.js';

export const TASK_ASSIGNMENT_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const SOURCE = 'TaskAssignmentEntityServer';

/** The fields that say who an assignment is for; changing one is a reassignment. */
const ASSIGNEE_FIELDS = ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID'] as const;

/** The statuses in which an approval task no longer takes assignees from its creator. */
const CLOSED_TASK_STATUSES: readonly string[] = ['Completed', 'Cancelled'];

/** What the rules read from a task an assignment is on. */
type AssignedTask = {
    ID: string;
    TypeID: string | null;
    CreatedByPersonID: string | null;
    Status: string;
    OrganizationID?: string | null;
};

export { SELF_ASSIGN_REFUSAL };
export const REASSIGN_REFUSAL = 'This is an approval task, and your role does not allow changing who it is assigned to.';
export const REMOVE_REFUSAL = 'This is an approval task, and your role does not allow removing its assignee.';
const NO_USER_REFUSAL = 'An approval assignment cannot be changed or removed without a signed-in user.';

@RegisterClass(BaseEntity, TASK_ASSIGNMENT_ENTITY)
export class TaskAssignmentEntityServer extends mjBizAppsTasksTaskAssignmentEntity {
    private approvalAssignmentAuthorized = false;

    /**
     * Lets the next save create this assignment on an approval task whoever is saving and whoever
     * the assignee is. Called only by server code that chose the assignee itself, never to pass
     * along an assignee a caller supplied. See `SanctionApprovalAssignment` (./ApprovalSanctions.ts).
     */
    public AuthorizeApprovalAssignment(): void {
        this.approvalAssignmentAuthorized = true;
    }

    /** Async validation carries the rule, so it must run on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const reassigning = this.IsSaved && ASSIGNEE_FIELDS.some((name) => this.GetFieldByName(name)?.Dirty);
        if (this.IsSaved && !reassigning) return result;
        const refusal = await this.failClosed(() => (this.IsSaved ? this.reassignRefusal() : this.addRefusal()));
        if (refusal) {
            result.Success = false;
            result.Errors.push(new ValidationErrorInfo(SOURCE, refusal, null));
        }
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        try {
            return await this.saveThenWake(options);
        } finally {
            // Authorizes one save, never a later one made through the same object.
            this.approvalAssignmentAuthorized = false;
        }
    }

    private async saveThenWake(options?: EntitySaveOptions): Promise<boolean> {
        const postCommitToken = capturePostCommitToken(this.ProviderToUse);
        const isNew = !this.IsSaved;
        const assigneeChanged = this.IsSaved && ASSIGNEE_FIELDS.some((name) => this.GetFieldByName(name)?.Dirty);

        const saved = await super.Save(options);
        if (!saved) return false;

        const actingUser = this.ContextCurrentUser;
        if ((isNew || assigneeChanged) && actingUser && IsValidUUID(this.TaskID) && this.AssigneeRecordID) {
            const taskID = this.TaskID;
            const taskAssignmentID = this.ID;
            const assigneeEntityID = this.AssigneeEntityID ?? null;
            const assigneeRecordID = this.AssigneeRecordID;
            const metadataProvider = this.metadataProvider;
            const runViewProvider = this.RunViewProviderToUse;

            runAfterCommit(
                this.ProviderToUse,
                `CoS tasks-inbox wake for task assignment ${taskAssignmentID}`,
                async () => {
                    await wakeAssigneesForTaskAssignment({
                        taskID,
                        taskAssignmentID,
                        assigneeEntityID,
                        assigneeRecordID,
                        actingUser,
                        provider: metadataProvider,
                        runViewProvider,
                    });
                },
                postCommitToken,
            );
        }

        return true;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const refusal = this.IsSaved ? await this.failClosed(() => this.deleteRefusal()) : null;
        if (refusal) return this.refuseDelete(refusal);
        return super.Delete(options);
    }

    /**
     * Why this NEW assignment must not be saved, or null. The task must be readable by the user
     * saving: an approval they cannot read is not one they may put someone on, so a task that does
     * not come back refuses the save rather than passing as "not an approval".
     */
    private async addRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        // Both are accepted on any task, so neither needs the task read.
        if (this.approvalAssignmentAuthorized || IsSystemActor(user)) return null;
        const task = (await this.loadTasks([this.TaskID], user))[0];
        if (!task) throw new Error('its task was not found, or you may not read it');
        if (!(await this.anyIsApproval([task], user))) return null;
        const actor = user ? this.actorFor(user) : null;
        const actorOrgs = actor && task.OrganizationID ? await actor.OrganizationIDs() : undefined;
        const taskIsOpen = !CLOSED_TASK_STATUSES.includes(task.Status);
        const isCreator = actor ? await actor.IsPerson(task.CreatedByPersonID) : false;
        const assigneeIsActor = actor ? await actor.IsAssignee(this.AssigneeEntityID, this.AssigneeRecordID) : false;
        const ownOpenRequest = isCreator && taskIsOpen;
        return ApprovalAssignmentAddRefusal({
            Sanctioned: false,
            ActorIsSystem: false,
            HasActor: !!user,
            TaskOrganizationID: task.OrganizationID ?? null,
            ActorOrganizationIDs: actorOrgs,
            AssigneeIsActor: assigneeIsActor,
            ActorIsTaskCreator: isCreator,
            TaskIsOpen: taskIsOpen,
            // Only read when it decides: the requester of an open request, and anyone adding themselves, do not turn on it.
            ActorMayReassign: actor && !ownOpenRequest && !assigneeIsActor ? await actor.MayReassignApprovals() : false,
        });
    }

    /** Why this reassignment must not be saved, or null. */
    private async reassignRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        const oldTaskID = this.GetFieldByName('TaskID')?.OldValue as string | null | undefined;
        const tasks = await this.loadTasks([this.TaskID, oldTaskID], user);
        if (!(await this.anyIsApproval(tasks, user))) return null;
        if (!user) return NO_USER_REFUSAL;
        const actor = this.actorFor(user);
        const orgID = tasks.map((t) => t.OrganizationID).find((id) => !!id) ?? null;
        const actorOrgs = orgID && !IsSystemActor(user) ? await actor.OrganizationIDs() : undefined;
        const assigneeIsActor = await actor.IsAssignee(this.AssigneeEntityID, this.AssigneeRecordID);
        if (assigneeIsActor) return SELF_ASSIGN_REFUSAL;
        return ApprovalAssignmentManageRefusal({
            ActorIsSystem: IsSystemActor(user),
            HasActor: true,
            TaskOrganizationID: orgID,
            ActorOrganizationIDs: actorOrgs,
            AssigneeIsActor: false,
            ActorMayReassign: await actor.MayReassignApprovals(),
            NoUserMessage: NO_USER_REFUSAL,
            RoleRefusalMessage: REASSIGN_REFUSAL,
        });
    }

    /** Why this assignment must not be deleted, or null. */
    private async deleteRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        const oldTaskID = this.GetFieldByName('TaskID')?.OldValue as string | null | undefined;
        const tasks = await this.loadTasks([this.TaskID, oldTaskID], user);
        if (!(await this.anyIsApproval(tasks, user))) return null;
        if (!user) return NO_USER_REFUSAL;
        const actor = this.actorFor(user);
        const orgID = tasks.map((t) => t.OrganizationID).find((id) => !!id) ?? null;
        const actorOrgs = orgID && !IsSystemActor(user) ? await actor.OrganizationIDs() : undefined;
        return ApprovalAssignmentManageRefusal({
            ActorIsSystem: IsSystemActor(user),
            HasActor: true,
            TaskOrganizationID: orgID,
            ActorOrganizationIDs: actorOrgs,
            ActorMayReassign: await actor.MayReassignApprovals(),
            NoUserMessage: NO_USER_REFUSAL,
            RoleRefusalMessage: REMOVE_REFUSAL,
        });
    }

    /** Runs a check; a check that cannot be completed refuses rather than lets the write through. */
    private async failClosed(check: () => Promise<string | null>): Promise<string | null> {
        try {
            return await check();
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskAssignmentEntityServer: checking assignment ${this.ID ?? '(new)'} on task ${this.TaskID} failed: ${msg}`);
            return `The assignment was not ${this.IsSaved ? 'changed' : 'saved'}: whether it is an approval could not be checked (${msg}).`;
        }
    }

    /** The tasks with these IDs that the user may read, with what the rules read from each. */
    private async loadTasks(ids: Array<string | null | undefined>, user: UserInfo | null): Promise<AssignedTask[]> {
        const taskIDs = [...new Set(ids.filter((id): id is string => !!id).map((id) => id.toUpperCase()))];
        if (taskIDs.length === 0) return [];
        const tasks = await new RunView(this.RunViewProviderToUse).RunView<AssignedTask>(
            { EntityName: TASK_ENTITY, ExtraFilter: `ID IN (${taskIDs.map((id) => guid(id, 'TaskID')).join(', ')})`, Fields: ['ID', 'TypeID', 'CreatedByPersonID', 'Status', 'OrganizationID'], ResultType: 'simple', BypassCache: true },
            user ?? undefined,
        );
        if (!tasks?.Success) throw new Error(tasks?.ErrorMessage ?? 'the task lookup returned no result');
        return tasks.Results ?? [];
    }

    /** Whether any of the tasks has an approval type. */
    private async anyIsApproval(tasks: AssignedTask[], user: UserInfo | null): Promise<boolean> {
        const typeIDs = [...new Set(tasks.map((t) => t.TypeID).filter((id): id is string => !!id))];
        if (typeIDs.length === 0) return false;
        const types = await new RunView(this.RunViewProviderToUse).RunView<{ IsApproval: boolean }>(
            { EntityName: TASK_TYPE_ENTITY, ExtraFilter: `ID IN (${typeIDs.map((id) => guid(id, 'TypeID')).join(', ')})`, Fields: ['IsApproval'], ResultType: 'simple', BypassCache: true },
            user ?? undefined,
        );
        if (!types?.Success) throw new Error(types?.ErrorMessage ?? 'the task type lookup returned no result');
        return (types.Results ?? []).some((t) => t.IsApproval === true);
    }

    private actorFor(user: UserInfo): ApprovalActor {
        return new ApprovalActor(user, this.metadataProvider, this.RunViewProviderToUse);
    }

    /** The provider this assignment was created on when it carries metadata, else the process default. */
    private get metadataProvider(): IMetadataProvider {
        const candidate = this.ProviderToUse as Partial<IMetadataProvider> | undefined;
        return typeof candidate?.EntityByName === 'function' ? (candidate as IMetadataProvider) : Metadata.Provider;
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
