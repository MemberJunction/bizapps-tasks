import {
    BaseEntity,
    BaseEntityEvent,
    BaseEntityResult,
    EntityDeleteOptions,
    EntitySaveOptions,
    IEntityDataProvider,
    IMetadataProvider,
    IRunViewProvider,
    LogError,
    LogStatus,
    Metadata,
    RunView,
    UserInfo,
    ValidationErrorInfo,
    ValidationErrorType,
    ValidationResult,
} from '@memberjunction/core';
import { RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { ActionEngineServer } from '@memberjunction/actions';
import {
    TaskEntity,
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import { GuidLiteral, IsTaskDecisionOutcomeCode, TaskDecisionOutcomes, TaskService } from '@mj-biz-apps/tasks-core';
import { ApprovalActor, IsSystemActor } from './ApprovalActor.js';
import {
    ApprovalStatusChangeRefusal,
    ApprovalTypeChangeRefusal,
    TaskCreatorRefusal,
    type ApprovalClosingStatus,
} from './ApprovalTaskAuthority.js';
import { ACTIVE_ASSIGNMENT_STATUSES, TaskDecisionRefusal, type DecisionAssignmentFact } from './TaskDecisionAuthority.js';
import { IsPeopleEntity, PrimaryPersonIDForUser } from './UserPeople.js';
import {
    ApplyTimesheetApprovalOutcomeForTask,
    TIMESHEET_APPROVAL_TASK_TYPE_CODE,
} from './TimesheetApprovalOutcome.js';
import { EnterTaskCheckInGraphScope } from './composite-graph-scope.js';
import { wakeAssigneesForTaskUnblock } from './cos-wake-helpers.js';

/**
 * Action hook trigger types supported on TaskType and TaskTypeStatus.
 */
export type TaskActionHookType =
    | 'OnCreate'
    | 'OnStatusChange'
    | 'OnEnterStatus'
    | 'OnExitStatus'
    | 'OnComplete'
    | 'OnCancel'
    | 'OnReject'
    | 'OnPercentChange';

/**
 * Conventional TaskTypeStatus.Code for a task type's "rejected" stage (a convention deployments
 * opt into when defining TaskTypeStatus rows with MacroStatus = 'Cancelled'; stock installs seed
 * no TaskTypeStatus rows). Landing on a stage with this Code is treated as a rejection for
 * OnReject/OnCancel routing even when no TaskDecision row was recorded.
 */
export const REJECTED_STAGE_CODE = 'REJECTED';

/**
 * Lifecycle snapshot captured pre-save to drive post-save audit logging and action triggers.
 */
export interface TaskLifecycleContext {
    isNew: boolean;
    statusChanged: boolean;
    typeStatusChanged: boolean;
    pctChanged: boolean;
    priorityChanged: boolean;
    dueChanged: boolean;
    oldStatus: mjBizAppsTasksTaskEntity['Status'] | null;
    newStatus: mjBizAppsTasksTaskEntity['Status'];
    oldTypeStatusID: string | null;
    newTypeStatusID: string | null;
    oldPct: number | null;
    newPct: number | null;
    oldPriority: mjBizAppsTasksTaskEntity['Priority'] | null;
    newPriority: mjBizAppsTasksTaskEntity['Priority'];
    oldDue: Date | null;
    newDue: Date | null;
    typeID: string | null;
}

/**
 * Result of an action hook invocation.
 */
export interface TaskActionHookResult {
    Invoked: boolean;
    Success?: boolean;
    Message?: string;
}

/**
 * A provider that can create entities and run views: what every server-side MJ data provider is.
 */
type TaskSaveProvider = IEntityDataProvider & IMetadataProvider & IRunViewProvider;

/**
 * The post-commit scheduling surface of MJ's `DatabaseProviderBase` (MJ 6.1.3 and later). Declared
 * here so this package keeps building against older MJ versions, where the provider has no
 * scheduler and post-save work starts right away as before.
 */
interface PostCommitScheduler {
    RunAfterCommit(task: () => Promise<void>, description?: string, token?: object): void;
    CapturePostCommitToken(): object | undefined;
}

function isTaskSaveProvider(provider: IEntityDataProvider | null | undefined): provider is TaskSaveProvider {
    const candidate = provider as Partial<TaskSaveProvider> | null | undefined;
    return typeof candidate?.GetEntityObject === 'function' && typeof candidate?.RunView === 'function';
}

function isPostCommitScheduler(provider: IEntityDataProvider | null | undefined): provider is IEntityDataProvider & PostCommitScheduler {
    const candidate = provider as Partial<PostCommitScheduler> | null | undefined;
    return typeof candidate?.RunAfterCommit === 'function' && typeof candidate?.CapturePostCommitToken === 'function';
}

/** What lets a user close an approval task with no decision behind them: the actor facts of {@link ApprovalStatusChangeRefusal}. */
type ClosingStanding = { ActorMayDecide: boolean; ActorIsTaskCreator: boolean; ActorHoldsActiveAssignment: boolean; ActorMayReassign: boolean };

const NO_CLOSING_STANDING: ClosingStanding = { ActorMayDecide: false, ActorIsTaskCreator: false, ActorHoldsActiveAssignment: false, ActorMayReassign: false };

/**
 * Server-side subclass of {@link TaskEntity}.
 *
 * Holds the SERVER-ONLY task side-effects that must run exactly once and
 * authoritatively on the backend:
 *   - Dynamic TaskTypeStatus & MacroStatus synchronization
 *   - Server-authoritative activity audit logging (MJ_BizApps_Tasks: Task Activities)
 *   - Parent sub-task progress rollup
 *   - Event-driven Action & Workflow hook execution (OnCreate, OnStatusChange, OnEnterStatus, OnExitStatus, OnComplete, OnCancel, OnReject, OnPercentChange)
 *   - Creator integrity: a new task with no `CreatedByPersonID` records the signed-in user's Person,
 *     a creator the caller names must be the caller, and a recorded creator cannot be changed. The
 *     no-self-approval rule (TaskDecisionEntityServer) compares deciders against this column, so it
 *     must not depend on every caller remembering to pass it, be nameable as someone else, nor be
 *     editable away afterwards. Server code raising a task for someone else vouches for one save
 *     with {@link TaskEntityServer.AuthorizeCreatorOnBehalf}.
 *   - Approval outcomes (bizapps-tasks#209): an approval task (`TaskType.IsApproval`) reaches
 *     `Completed` only with an approving decision standing on it or from someone who could have
 *     recorded one, is cancelled only by someone who may withdraw it, and cannot be turned into an
 *     ordinary task. Timesheets, OnComplete actions and workflow steps read the status as the
 *     outcome, so the status must not be settable around the decision rule. The rules are in
 *     ./ApprovalTaskAuthority.ts; this class gathers their facts.
 *
 * Lifecycle hook dispatch lives HERE and only here — it fires on the status
 * TRANSITION captured pre-save. TaskNotificationHandler (tasks-server) must not
 * invoke these hooks again, or one transition would fire them twice and later
 * edits of a terminal task would replay them.
 *
 * Compiler/import order ensures this server subclass takes effect.
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')
export class TaskEntityServer extends TaskEntity {
    private _rollupHandlerRegistered = false;
    private creatorOnBehalfAuthorized = false;
    private approvalWithdrawalAuthorized = false;
    /** The creator this class recorded itself on this object, which needs no second look. */
    private stampedCreatorPersonID: string | null = null;

    /**
     * Lets the next save record the creator exactly as the caller left it: someone other than the
     * user saving, or nobody at all (the user saving is then not recorded either). Called only by
     * server code raising a task on someone's behalf (a workflow for its owner, a manager submitting
     * a report's timesheet) or for no Person (an agent asking its own user), never to pass along a
     * creator a caller supplied. See `SanctionOnBehalfCreator` (./ApprovalSanctions.ts).
     */
    public AuthorizeCreatorOnBehalf(): void {
        this.creatorOnBehalfAuthorized = true;
    }

    /**
     * Lets the next save move an approval task to `Cancelled` with no rejecting decision, whoever is
     * saving. Called only by server code withdrawing a request it raised (a workflow withdrawing its
     * ask, a resubmitted timesheet). It never lets an approval be `Completed`: that takes an
     * approving decision, or someone who could record one. See `SanctionApprovalWithdrawal`
     * (./ApprovalSanctions.ts).
     */
    public AuthorizeApprovalWithdrawal(): void {
        this.approvalWithdrawalAuthorized = true;
    }

    /** Async validation carries the creator and approval rules, so it must run on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        try {
            return await this.saveWithLifecycle(options);
        } finally {
            // Each authorization covers one save, never a later one made through the same object.
            this.creatorOnBehalfAuthorized = false;
            this.approvalWithdrawalAuthorized = false;
        }
    }

    private async saveWithLifecycle(options?: EntitySaveOptions): Promise<boolean> {
        // Captured before the first await so the post-commit hooks follow the caller's
        // transaction, if one is open on this Task's provider.
        const postCommitToken = this.capturePostCommitToken();
        this.ensureRollupHandler();

        // 0. Record the creator when the caller did not (fails closed: throws if it cannot be looked up)
        await this.stampCreatorPreSave();

        // 0b. Inherit parent task's OrganizationID for new child sub-tasks when left unset
        await this.inheritParentOrganizationPreSave();

        // 1. Pre-Save Sync: Synchronize TaskTypeStatusID <-> Status and defaults
        await this.syncTaskTypeStatusPreSave();

        // 1b. Pre-Save CheckIn Sync: if CheckIns are attached on the composite Task graph,
        // apply their derived values and propagate the latest check-in onto this Task before saving
        // so TaskCheckInEntityServer does not trigger a redundant recursive Task.Save().
        const pendingCheckIns = this.prepareCompositeCheckInsPreSave();

        // 2. Snapshot dirty flags and old values BEFORE super.Save resets them
        const lifecycleContext = this.captureLifecycleContext();

        // 3. Persist record (with composite check-in scope active so child CheckIn saves skip recursive Task.Save)
        const exitCheckInScope = EnterTaskCheckInGraphScope(this.ID, pendingCheckIns);
        let result: boolean;
        try {
            result = await super.Save(options);
        } finally {
            exitCheckInScope();
        }
        if (!result) return false;

        // 4. Activity logging — server-only audit trail
        try {
            await this.logActivities(lifecycleContext);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: activity logging failed for task ${this.ID}: ${msg}`);
        }

        // 5. Timesheet approval outcome reconciliation (§6.5, awaited)
        try {
            await this.applyTimesheetApprovalOutcomeIfApplicable(lifecycleContext);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: timesheet approval outcome failed for task ${this.ID}: ${msg}`);
        }

        // 6. Post-Save Lifecycle Action & Workflow Dispatcher (asynchronous, non-blocking). Runs
        // once the caller's transaction commits and is dropped if it rolls back: a detached query
        // issued into an open transaction races its other requests on the same connection.
        this.runAfterCommit('Task lifecycle action hooks', postCommitToken, () =>
            this.dispatchLifecycleActionHooks(lifecycleContext).catch((err) => {
                const msg = err instanceof Error ? err.message : String(err);
                LogError(`TaskEntityServer: action hook dispatch error for task ${this.ID}: ${msg}`);
            })
        );

        // 7. Coalesced Chief of Staff `tasks-inbox` wake on direct unblock (Blocked -> Open/InProgress)
        // or prerequisite completion unblocking downstream tasks (covers UI, BulkUpdateTasks, and CoS actions).
        const actingUser = this.ContextCurrentUser;
        if (actingUser && lifecycleContext.statusChanged && !lifecycleContext.isNew) {
            const taskID = this.ID;
            const taskName = this.Name;
            const oldStatus = lifecycleContext.oldStatus;
            const newStatus = lifecycleContext.newStatus;
            const candidateProvider = this.ProviderToUse as Partial<IMetadataProvider> | undefined;
            const metadataProvider =
                typeof candidateProvider?.EntityByName === 'function'
                    ? (candidateProvider as IMetadataProvider)
                    : Metadata.Provider;
            const runViewProvider = this.RunViewProviderToUse;

            this.runAfterCommit('Task unblock CoS tasks-inbox wake', postCommitToken, () =>
                wakeAssigneesForTaskUnblock({
                    taskID,
                    taskName,
                    oldStatus,
                    newStatus,
                    actingUser,
                    provider: metadataProvider,
                    runViewProvider,
                }).then(() => undefined).catch((err) => {
                    const msg = err instanceof Error ? err.message : String(err);
                    LogError(`TaskEntityServer: CoS unblock wake error for task ${taskID}: ${msg}`);
                })
            );
        }

        return true;
    }

    /**
     * Refuses deleting a task when `TaskTimeEntry` rows exist for the task, reporting
     * the exact entry count (§6.1). Time entries are permanent records of work and never cascade.
     */
    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        if (this.ID) {
            const entryCount = await this.countLoggedTimeEntries();
            if (entryCount > 0) {
                const noun = entryCount === 1 ? 'time entry' : 'time entries';
                const msg = `Cannot delete task "${this.Name || this.ID}": it has ${entryCount} logged ${noun}.`;
                let latest = this.LatestResult;
                if (!latest) {
                    latest = new BaseEntityResult();
                    latest.Type = 'delete';
                    this.ResultHistory.push(latest);
                }
                latest.Success = false;
                latest.Message = msg;
                latest.Errors.push(new ValidationErrorInfo(
                    'ID',
                    msg,
                    this.ID,
                    ValidationErrorType.Failure,
                ));
                return false;
            }
        }
        return super.Delete(options);
    }

    /**
     * Counts `TaskTimeEntry` rows logged against this task.
     */
    protected async countLoggedTimeEntries(): Promise<number> {
        const rv = new RunView(this.RunViewProviderToUse);
        const safeID = this.ID.replace(/'/g, "''");
        const res = await rv.RunView<mjBizAppsTasksTaskTimeEntryEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
            ExtraFilter: `TaskID='${safeID}'`,
            Fields: ['ID'],
            ResultType: 'simple',
        }, this.ContextCurrentUser);
        if (!res.Success) {
            return 0;
        }
        return res.Results?.length ?? res.TotalRowCount ?? 0;
    }

    /**
     * When a task of type `TIMESHEET_APPROVAL` reaches a terminal status (`Completed`,
     * `Cancelled`, or `Blocked`), applies the outcome to its `TimesheetApproval` part
     * and parent `Timesheet` (§6.5).
     */
    protected async applyTimesheetApprovalOutcomeIfApplicable(ctx: TaskLifecycleContext): Promise<void> {
        if (!this.ContextCurrentUser || !ctx.typeID) {
            return;
        }
        if (!ctx.statusChanged && !ctx.isNew) {
            return;
        }
        if (this.Status !== 'Completed' && this.Status !== 'Cancelled' && this.Status !== 'Blocked') {
            return;
        }

        const taskType = await this.loadTaskType(ctx.typeID);
        if (!taskType || taskType.Code !== TIMESHEET_APPROVAL_TASK_TYPE_CODE) {
            return;
        }

        await ApplyTimesheetApprovalOutcomeForTask(
            this.ID,
            this.Status,
            this.ContextCurrentUser,
            this.saveProvider,
            this.RunViewProviderToUse,
        );
    }

    /** Refuses changing a recorded creator, on top of the client-safe field rules. */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        const creator = this.Fields.find(f => f.CodeName === 'CreatedByPersonID');
        if (this.IsSaved && creator?.Dirty && creator.OldValue != null && String(creator.OldValue).toLowerCase() !== String(creator.Value ?? '').toLowerCase()) {
            result.Errors.push(new ValidationErrorInfo(
                'CreatedByPersonID',
                "A task's creator cannot be changed once it is recorded.",
                creator.Value,
                ValidationErrorType.Failure,
            ));
            result.Success = false;
        }
        return result;
    }

    /**
     * The rules that need a read: who a task's creator may be, and how an approval task may close
     * (./ApprovalTaskAuthority.ts). Runs after the status sync in {@link Save}, so it sees the status
     * the task will be saved with. A check that cannot be completed refuses the save.
     */
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusals = [await this.creatorRefusal(), ...(await this.approvalRefusals())];
            for (const refusal of refusals) {
                if (refusal) this.addRefusal(result, refusal);
            }
        } catch (e: unknown) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: checking who may save task ${this.ID ?? '(new)'} failed: ${msg}`);
            this.addRefusal(result, `The task was not saved: whether this change is allowed could not be checked (${msg}).`);
        }
        return result;
    }

    private addRefusal(result: ValidationResult, message: string): void {
        result.Errors.push(new ValidationErrorInfo('TaskEntityServer.ValidateAsync', message, null, ValidationErrorType.Failure));
        result.Success = false;
    }

    /** Why the creator must not be recorded as it stands, or null. Reads nothing unless a caller named one. */
    private async creatorRefusal(): Promise<string | null> {
        const creator = this.CreatedByPersonID;
        const field = this.Fields.find(f => f.CodeName === 'CreatedByPersonID');
        const recordingNow = !this.IsSaved || (!!field?.Dirty && field.OldValue == null);
        if (!creator || !recordingNow) return null;
        if (!this.IsSaved && this.stampedCreatorPersonID && UUIDsEqual(creator, this.stampedCreatorPersonID)) return null;
        const user = this.ContextCurrentUser;
        const isSystem = IsSystemActor(user);
        const checksActor = !this.creatorOnBehalfAuthorized && !isSystem && !!user && !this.IsSaved;
        return TaskCreatorRefusal({
            CreatorPersonID: creator,
            TaskIsSaved: this.IsSaved,
            ActorPersonIDs: checksActor && user ? await this.approvalActor(user).PersonIDs() : [],
            OnBehalfSanctioned: this.creatorOnBehalfAuthorized,
            ActorIsSystem: isSystem,
            HasActor: !!user,
        });
    }

    /**
     * Why this save must not go through under the approval rules; empty when it may. Reads nothing
     * unless the task is closing or changing type, so an ordinary save costs nothing.
     */
    private async approvalRefusals(): Promise<Array<string | null>> {
        const closing = this.closingStatusBeingSet();
        const previousTypeID = this.previousTypeID();
        if (!closing && !previousTypeID) return [];
        const user = this.ContextCurrentUser;
        const isSystem = IsSystemActor(user);
        const approvalTypeIDs = await this.approvalTypeIDs([this.TypeID, previousTypeID]);
        const isApproval = approvalTypeIDs.some((id) => UUIDsEqual(id, this.TypeID));
        const wasApproval = previousTypeID ? approvalTypeIDs.some((id) => UUIDsEqual(id, previousTypeID)) : isApproval;
        return [
            previousTypeID ? ApprovalTypeChangeRefusal({ WasApprovalType: wasApproval, IsApprovalType: isApproval, ActorIsSystem: isSystem }) : null,
            closing && (isApproval || wasApproval) ? await this.closingRefusal(closing, user, isSystem) : null,
        ];
    }

    /** The closing status this save moves the task to, or null when it does not close it. */
    private closingStatusBeingSet(): ApprovalClosingStatus | null {
        const status = this.Status;
        if (status !== 'Completed' && status !== 'Cancelled') return null;
        if (!this.IsSaved) return status;
        const field = this.Fields.find(f => f.CodeName === 'Status');
        return field?.Dirty && field.OldValue !== status ? status : null;
    }

    /** The type a saved task is being moved off, or null when its type is not changing. */
    private previousTypeID(): string | null {
        const field = this.Fields.find(f => f.CodeName === 'TypeID');
        if (!this.IsSaved || !field?.Dirty || field.OldValue == null) return null;
        const previous = String(field.OldValue);
        return UUIDsEqual(previous, this.TypeID) ? null : previous;
    }

    /** Which of these task types are approval types. */
    private async approvalTypeIDs(typeIDs: Array<string | null | undefined>): Promise<string[]> {
        const ids = typeIDs.filter((id): id is string => !!id);
        if (ids.length === 0) return [];
        const rows = await this.readRuleRows<{ ID: string; IsApproval: boolean }>(
            'MJ_BizApps_Tasks: Task Types',
            `ID IN (${ids.map((id) => GuidLiteral(id, 'TypeID')).join(', ')})`,
            ['ID', 'IsApproval'],
        );
        return rows.filter((t) => t.IsApproval === true).map((t) => t.ID);
    }

    /** Why this approval task must not move to `newStatus`, or null. */
    private async closingRefusal(newStatus: ApprovalClosingStatus, user: UserInfo | null, isSystem: boolean): Promise<string | null> {
        const decided = await this.standingDecisionStatus();
        // Who is saving only matters when the status does not follow a decision.
        const standing = decided !== newStatus && user ? await this.closingStanding(newStatus, user, isSystem) : NO_CLOSING_STANDING;
        return ApprovalStatusChangeRefusal({
            NewStatus: newStatus,
            DecidedStatus: decided,
            WithdrawalSanctioned: this.approvalWithdrawalAuthorized,
            ActorIsSystem: isSystem,
            HasActor: !!user,
            ...standing,
        });
    }

    /** What the user holds that lets them close this approval, reading only what `newStatus` turns on. */
    private async closingStanding(newStatus: ApprovalClosingStatus, user: UserInfo, isSystem: boolean): Promise<ClosingStanding> {
        if (newStatus === 'Completed') return { ...NO_CLOSING_STANDING, ActorMayDecide: await this.actorMayDecide(user) };
        // A withdrawal somebody vouched for is accepted whoever saves it.
        if (this.approvalWithdrawalAuthorized || isSystem) return NO_CLOSING_STANDING;
        return this.withdrawalStanding(user);
    }

    /**
     * The status the decision standing on this task leads to: the one being saved with the task
     * (`RecordDecision` saves both as one unit, and the decision's own save checks who decided), else
     * the latest one recorded. Null when there is none, or its outcome is not one that closes a task.
     */
    private async standingDecisionStatus(): Promise<ApprovalClosingStatus | null> {
        const pending = (this.Decisions?.Items ?? []).filter((d) => !d.IsSaved);
        const pendingOutcomeID = pending.length > 0 ? pending[pending.length - 1].OutcomeID : null;
        const outcomeID = pendingOutcomeID ?? (this.IsSaved ? await this.latestRecordedOutcomeID() : null);
        if (!outcomeID) return null;
        const outcomes = await this.readRuleRows<{ Code: string | null }>(
            'MJ_BizApps_Tasks: Task Decision Outcomes',
            `ID = ${GuidLiteral(outcomeID, 'OutcomeID')}`,
            ['ID', 'Code'],
        );
        const code = outcomes[0]?.Code ?? null;
        return IsTaskDecisionOutcomeCode(code) ? TaskDecisionOutcomes[code].Status : null;
    }

    /** The outcome of the latest decision recorded on this task, or null when it has none. */
    private async latestRecordedOutcomeID(): Promise<string | null> {
        const rows = await this.readRuleRows<{ OutcomeID: string | null }>(
            'MJ_BizApps_Tasks: Task Decisions',
            `TaskID = ${GuidLiteral(this.ID, 'TaskID')}`,
            ['ID', 'OutcomeID'],
            { OrderBy: 'DecidedAt DESC, __mj_CreatedAt DESC', MaxRows: 1 },
        );
        return rows[0]?.OutcomeID ?? null;
    }

    /**
     * Whether the user could record a decision on this task themselves: the decision rule, asked
     * with the self-approval guard on whatever the `PreventSelfApproval` setting says, so a
     * completion always comes from an active assignee who did not ask for the approval. A task
     * that is being created has no assignee yet.
     */
    private async actorMayDecide(user: UserInfo): Promise<boolean> {
        if (!this.IsSaved) return false;
        const provider = this.ruleMetadataProvider;
        const actor = this.approvalActor(user);
        const creatorIsActor = await actor.IsPerson(this.CreatedByPersonID);
        const refusal = TaskDecisionRefusal({
            PreventSelfApproval: true,
            IsApprovalTask: true,
            DeciderUserID: user.ID,
            DeciderPersonIDs: await actor.PersonIDs(),
            DecidedByPersonID: null,
            TaskAssignmentID: null,
            TaskCreatedByPersonID: this.CreatedByPersonID ?? null,
            Assignments: await this.assignmentRows(),
            IsPeopleEntityID: (entityID: string) => IsPeopleEntity(provider, entityID),
            UsersEntityID: provider.EntityByName('MJ: Users')?.ID ?? null,
            RolesEntityID: provider.EntityByName('MJ: Roles')?.ID ?? null,
            DeciderRoleIDs: await actor.RoleIDs(),
            // Only read when it matters: the user asked for this approval themselves.
            DeciderIsExempt: creatorIsActor ? await actor.HoldsSelfApprovalExemptRole() : false,
        });
        return refusal === null;
    }

    /** What lets the user withdraw this approval, each read only until one of them does. */
    private async withdrawalStanding(user: UserInfo): Promise<ClosingStanding> {
        const actor = this.approvalActor(user);
        // A task created already cancelled is its creator's own.
        const isCreator = !this.IsSaved || (await actor.IsPerson(this.CreatedByPersonID));
        const holdsAssignment = !isCreator && (await this.holdsActiveAssignment(actor));
        const mayReassign = !isCreator && !holdsAssignment && (await actor.MayReassignApprovals());
        return { ...NO_CLOSING_STANDING, ActorIsTaskCreator: isCreator, ActorHoldsActiveAssignment: holdsAssignment, ActorMayReassign: mayReassign };
    }

    /** Whether one of this task's Pending or InProgress assignments is the user's. */
    private async holdsActiveAssignment(actor: ApprovalActor): Promise<boolean> {
        const active = (await this.assignmentRows()).filter((a) => ACTIVE_ASSIGNMENT_STATUSES.includes(a.Status));
        for (const assignment of active) {
            if (await actor.IsAssignee(assignment.AssigneeEntityID, assignment.AssigneeRecordID)) return true;
        }
        return false;
    }

    /** This task's assignments, in every status. */
    private assignmentRows(): Promise<DecisionAssignmentFact[]> {
        return this.readRuleRows<DecisionAssignmentFact>(
            'MJ_BizApps_Tasks: Task Assignments',
            `TaskID = ${GuidLiteral(this.ID, 'TaskID')}`,
            ['ID', 'AssigneeEntityID', 'AssigneeRecordID', 'Status'],
        );
    }

    private approvalActor(user: UserInfo): ApprovalActor {
        return new ApprovalActor(user, this.ruleMetadataProvider, this.RunViewProviderToUse);
    }

    /** The provider this task was created on when it carries metadata, else the process default. */
    private get ruleMetadataProvider(): IMetadataProvider {
        const candidate = this.ProviderToUse as Partial<IMetadataProvider> | undefined;
        return typeof candidate?.EntityByName === 'function' ? (candidate as IMetadataProvider) : Metadata.Provider;
    }

    /** A fresh read for a rule, as the user saving. Throws when it fails, so the rule fails closed. */
    private async readRuleRows<T>(
        entityName: string,
        filter: string,
        fields: string[],
        options: { OrderBy?: string; MaxRows?: number } = {},
    ): Promise<T[]> {
        const res = await new RunView(this.RunViewProviderToUse).RunView<T>(
            { EntityName: entityName, ExtraFilter: filter, Fields: fields, ResultType: 'simple', BypassCache: true, ...options },
            this.ContextCurrentUser,
        );
        if (!res?.Success) throw new Error(res?.ErrorMessage ?? `the ${entityName} lookup returned no result`);
        return res.Results ?? [];
    }

    /**
     * On create, records the signed-in user's Person as the creator when the caller left it unset.
     * A caller-supplied creator is kept here and checked in {@link ValidateAsync}: it must be the
     * caller, unless server code vouched for it or the system user is saving. A user with no Person
     * (a service account) leaves it unset.
     */
    private async stampCreatorPreSave(): Promise<void> {
        const user = this.ContextCurrentUser;
        // Server code that vouched for the creator decided it, an empty one included.
        if (this.IsSaved || this.CreatedByPersonID || !user || this.creatorOnBehalfAuthorized) return;
        try {
            const candidate = this.ProviderToUse as Partial<IMetadataProvider> | undefined;
            const metadataProvider = typeof candidate?.EntityByID === 'function'
                ? (candidate as IMetadataProvider)
                : Metadata.Provider;
            const personID = await PrimaryPersonIDForUser(metadataProvider, this.RunViewProviderToUse, user);
            if (personID) {
                this.CreatedByPersonID = personID;
                this.stampedCreatorPersonID = personID;
            }
        } catch (e: unknown) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: could not record the creator of task "${this.Name}": ${msg}`);
            throw new Error(`The task was not created: its creator could not be recorded (${msg}).`);
        }
    }

    /**
     * On create, defaults a child sub-task's OrganizationID from its parent task
     * when the caller did not specify one explicitly.
     */
    private async inheritParentOrganizationPreSave(): Promise<void> {
        if (this.IsSaved || this.OrganizationID || !this.ParentID) {
            return;
        }
        const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        if (!uuidPattern.test(this.ParentID)) {
            return;
        }
        try {
            const rv = new RunView(this.RunViewProviderToUse);
            const res = await rv.RunView<{ OrganizationID: string | null }>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID = '${this.ParentID}'`,
                    Fields: ['OrganizationID'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                this.ContextCurrentUser,
            );
            const parentOrgID = res.Success ? res.Results?.[0]?.OrganizationID ?? null : null;
            if (parentOrgID) {
                this.OrganizationID = parentOrgID;
            }
        } catch (e: unknown) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: could not inherit OrganizationID from parent ${this.ParentID}: ${msg}`);
        }
    }

    /**
     * Synchronizes TaskTypeStatusID and MacroStatus before saving.
     */
    private async syncTaskTypeStatusPreSave(): Promise<void> {
        const isNew = !this.IsSaved;
        const typeStatusField = this.Fields.find(f => f.CodeName === 'TaskTypeStatusID');
        const typeStatusDirty = typeStatusField?.Dirty ?? false;

        if (this.TaskTypeStatusID && (typeStatusDirty || isNew)) {
            const statusRecord = await this.loadTaskTypeStatus(this.TaskTypeStatusID);
            if (statusRecord) {
                this.Status = statusRecord.MacroStatus;
                if (statusRecord.IsTerminal) {
                    if (!this.CompletedAt) {
                        this.CompletedAt = new Date();
                    }
                    if (this.PercentComplete !== 100) {
                        this.PercentComplete = 100;
                    }
                }
            }
        } else if (isNew && !this.TaskTypeStatusID && this.TypeID) {
            const defaultStatus = await this.loadDefaultTaskTypeStatus(this.TypeID);
            if (defaultStatus) {
                this.TaskTypeStatusID = defaultStatus.ID;
                this.Status = defaultStatus.MacroStatus;
                if (defaultStatus.IsTerminal) {
                    if (!this.CompletedAt) {
                        this.CompletedAt = new Date();
                    }
                    if (this.PercentComplete !== 100) {
                        this.PercentComplete = 100;
                    }
                }
            }
        }
    }

    /**
     * Captures a snapshot of entity changes prior to saving.
     */
    private captureLifecycleContext(): TaskLifecycleContext {
        const statusField = this.Fields.find(f => f.CodeName === 'Status');
        const typeStatusField = this.Fields.find(f => f.CodeName === 'TaskTypeStatusID');
        const pctField = this.Fields.find(f => f.CodeName === 'PercentComplete');
        const priorityField = this.Fields.find(f => f.CodeName === 'Priority');
        const dueField = this.Fields.find(f => f.CodeName === 'DueAt');

        return {
            isNew: !this.IsSaved,
            statusChanged: statusField?.Dirty ?? false,
            typeStatusChanged: typeStatusField?.Dirty ?? false,
            pctChanged: pctField?.Dirty ?? false,
            priorityChanged: priorityField?.Dirty ?? false,
            dueChanged: dueField?.Dirty ?? false,
            oldStatus: (statusField?.OldValue as mjBizAppsTasksTaskEntity['Status']) ?? null,
            newStatus: this.Status,
            oldTypeStatusID: (typeStatusField?.OldValue as string) ?? null,
            newTypeStatusID: this.TaskTypeStatusID,
            oldPct: (pctField?.OldValue as number) ?? null,
            newPct: this.PercentComplete,
            oldPriority: (priorityField?.OldValue as mjBizAppsTasksTaskEntity['Priority']) ?? null,
            newPriority: this.Priority,
            oldDue: (dueField?.OldValue as Date) ?? null,
            newDue: this.DueAt,
            typeID: this.TypeID,
        };
    }

    /**
     * Writes server-side audit log entries for task mutations.
     */
    private async logActivities(ctx: TaskLifecycleContext): Promise<void> {
        const taskID = this.ID;

        if (ctx.isNew) {
            await this.logActivity(taskID, 'Created', `Task created: ${this.Name}`);
        }
        if (ctx.statusChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'StatusChange',
                `Status changed from ${ctx.oldStatus} to ${this.Status}`,
                ctx.oldStatus ?? undefined,
                this.Status
            );
        }
        if (ctx.typeStatusChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'StatusChange',
                `Task stage updated`,
                ctx.oldTypeStatusID ?? undefined,
                this.TaskTypeStatusID ?? undefined
            );
        }
        if (ctx.pctChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'PercentCompleteChanged',
                `Progress updated to ${this.PercentComplete}%`,
                String(ctx.oldPct ?? 0),
                String(this.PercentComplete ?? 0)
            );
        }
        if (ctx.priorityChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'PriorityChanged',
                `Priority changed from ${ctx.oldPriority} to ${this.Priority}`,
                ctx.oldPriority ?? undefined,
                this.Priority
            );
        }
        if (ctx.dueChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'DueDateChanged',
                `Due date changed`,
                String(ctx.oldDue ?? ''),
                String(this.DueAt ?? '')
            );
        }
        if (ctx.statusChanged && this.Status === 'Completed') {
            await this.logActivity(taskID, 'Completed', `Task completed: ${this.Name}`);
        }
    }

    private async logActivity(
        taskID: string,
        activityType: mjBizAppsTasksTaskActivityEntity['ActivityType'],
        description: string,
        previousValue?: string,
        newValue?: string,
    ): Promise<void> {
        const activity = await this.saveProvider.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(
            'MJ_BizApps_Tasks: Task Activities',
            this.ContextCurrentUser
        );
        activity.NewRecord();
        activity.TaskID = taskID;
        activity.ActivityType = activityType;
        activity.Description = description;
        if (previousValue != null) activity.PreviousValue = previousValue;
        if (newValue != null) activity.NewValue = newValue;
        // When this Task is queued inside a caller's TransactionGroup, attach the activity
        // to the SAME TransactionGroup so both INSERTs commit atomically in order (preventing
        // FK_TaskActivity_Task violations against a not-yet-submitted Task row).
        if (this.TransactionGroup) {
            activity.TransactionGroup = this.TransactionGroup;
        }
        const saved = await activity.Save();
        if (!saved) {
            LogError(`TaskEntityServer: failed to save TaskActivity (${activityType}) for task ${taskID}: ${activity.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }

    /**
     * Dispatches configured lifecycle action hooks asynchronously after commit.
     */
    public async dispatchLifecycleActionHooks(ctx: TaskLifecycleContext): Promise<void> {
        if (!this.ContextCurrentUser || !ctx.typeID) {
            return;
        }

        const taskType = await this.loadTaskType(ctx.typeID);
        if (!taskType) return;

        let currentTypeStatusCode: string | null = null;
        if (this.TaskTypeStatusID) {
            const currentStatusEntity = await this.loadTaskTypeStatus(this.TaskTypeStatusID);
            currentTypeStatusCode = currentStatusEntity?.Code ?? null;
        }

        // 1. OnCreate hook
        if (ctx.isNew && taskType.OnCreateActionID) {
            await this.invokeAction(
                taskType.OnCreateActionID,
                'OnCreate',
                taskType.Code,
                currentTypeStatusCode,
                null
            );
        }

        // 2. OnStatusChange hook (macro or type status changed)
        if ((ctx.statusChanged || ctx.typeStatusChanged) && !ctx.isNew && taskType.OnStatusChangeActionID) {
            await this.invokeAction(
                taskType.OnStatusChangeActionID,
                'OnStatusChange',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }

        // 3. OnExitStatus hook (when exiting an old TaskTypeStatus)
        if (ctx.typeStatusChanged && ctx.oldTypeStatusID) {
            const oldStatusRecord = await this.loadTaskTypeStatus(ctx.oldTypeStatusID);
            if (oldStatusRecord?.OnExitActionID) {
                await this.invokeAction(
                    oldStatusRecord.OnExitActionID,
                    'OnExitStatus',
                    taskType.Code,
                    oldStatusRecord.Code,
                    ctx.oldStatus
                );
            }
        }

        // 4. OnEnterStatus hook (when entering a new TaskTypeStatus)
        if (ctx.typeStatusChanged && ctx.newTypeStatusID) {
            const newStatusRecord = await this.loadTaskTypeStatus(ctx.newTypeStatusID);
            if (newStatusRecord?.OnEnterActionID) {
                await this.invokeAction(
                    newStatusRecord.OnEnterActionID,
                    'OnEnterStatus',
                    taskType.Code,
                    newStatusRecord.Code,
                    ctx.oldStatus
                );
            }
        }

        // 5. Specific status milestone hooks
        if (ctx.statusChanged && this.Status === 'Completed' && taskType.OnCompleteActionID) {
            await this.invokeAction(
                taskType.OnCompleteActionID,
                'OnComplete',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }

        if (ctx.statusChanged && this.Status === 'Cancelled') {
            await this.dispatchCancelOrRejectHook(taskType, currentTypeStatusCode, ctx);
        }

        // 6. OnPercentChange hook
        if (ctx.pctChanged && !ctx.isNew && taskType.OnPercentChangeActionID) {
            await this.invokeAction(
                taskType.OnPercentChangeActionID,
                'OnPercentChange',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }
    }

    /**
     * Executes a configured Action using ActionEngineServer with the universal task payload.
     */
    public async invokeAction(
        actionID: string,
        hookType: TaskActionHookType,
        taskTypeCode: string,
        taskTypeStatusCode: string | null,
        previousStatus: string | null
    ): Promise<TaskActionHookResult> {
        const contextUser = this.ContextCurrentUser;
        if (!contextUser) return { Invoked: false };

        const taskName = this.Name;
        try {
            await ActionEngineServer.Instance.Config(false, contextUser);
            const action = ActionEngineServer.Instance.Actions.find(a => a.ID === actionID);
            if (!action) {
                const msg = `Action ${actionID} not found for hook ${hookType}`;
                LogError(`[BizAppsTasks] ${msg}`);
                return { Invoked: false, Message: msg };
            }

            const recordBag = this.GetAll();
            const payloadObject = {
                taskID: this.ID,
                taskName: this.Name,
                taskTypeCode,
                taskTypeStatusID: this.TaskTypeStatusID,
                taskTypeStatusCode,
                status: this.Status,
                previousStatus,
                percentComplete: this.PercentComplete,
                priority: this.Priority,
                dueAt: this.DueAt,
                record: recordBag,
            };

            const result = await ActionEngineServer.Instance.RunAction({
                Action: action,
                ContextUser: contextUser,
                Provider: this.saveProvider,
                Params: [
                    { Name: 'TaskID', Value: this.ID, Type: 'Input' },
                    { Name: 'RecordID', Value: this.ID, Type: 'Input' },
                    { Name: 'TaskName', Value: this.Name, Type: 'Input' },
                    { Name: 'TaskTypeCode', Value: taskTypeCode, Type: 'Input' },
                    { Name: 'TaskTypeStatusID', Value: this.TaskTypeStatusID, Type: 'Input' },
                    { Name: 'TaskTypeStatusCode', Value: taskTypeStatusCode ?? '', Type: 'Input' },
                    { Name: 'Status', Value: this.Status, Type: 'Input' },
                    { Name: 'PreviousStatus', Value: previousStatus ?? '', Type: 'Input' },
                    { Name: 'PercentComplete', Value: this.PercentComplete, Type: 'Input' },
                    { Name: 'Priority', Value: this.Priority, Type: 'Input' },
                    { Name: 'DueAt', Value: this.DueAt, Type: 'Input' },
                    { Name: 'TaskRecord', Value: recordBag, Type: 'Input' },
                    { Name: 'Payload', Value: JSON.stringify(payloadObject), Type: 'Input' },
                    // Generic utility action compatibility bindings
                    { Name: 'Expression', Value: `${this.PercentComplete || 100} * 1`, Type: 'Input' },
                    { Name: 'Color', Value: '#2563eb', Type: 'Input' },
                    { Name: 'Text', Value: this.Name, Type: 'Input' },
                    { Name: 'Input', Value: this.Name, Type: 'Input' },
                ],
                Filters: [],
            });

            const success = Array.isArray(result) ? result.every(r => r.Success) : result?.Success === true;
            const message = Array.isArray(result) ? result.map(r => r.Message).filter(Boolean).join('; ') : result?.Message ?? undefined;

            if (success) {
                LogStatus(`[BizAppsTasks] Invoked ${hookType} action "${action.Name}" for task "${taskName}"`);
            } else {
                LogError(`[BizAppsTasks] ${hookType} action "${action.Name}" for task "${taskName}" failed: ${message ?? 'no message'}`);
            }
            return { Invoked: true, Success: success, Message: message };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`[BizAppsTasks] Error invoking ${hookType} action ${actionID}: ${msg}`);
            return { Invoked: true, Success: false, Message: msg };
        }
    }

    /**
     * Routes a Cancelled transition to exactly one of OnReject / OnCancel.
     *
     * A cancellation is a REJECTION when either signal is present:
     *   (a) the task landed on a stage whose TaskTypeStatus.Code === REJECTED_STAGE_CODE
     *       (a convention a deployment opts into when defining custom TaskTypeStatus stages,
     *       reachable via status dropdown / bulk change with no TaskDecision row), or
     *   (b) a TaskDecision with the Rejected outcome exists (the RecordDecision path, which saves the
     *       decision before transitioning the task).
     * Otherwise it is a plain cancel. Never both, and Blocked never fires OnReject.
     * When a rejection occurs on a type that wires OnCancelActionID but not OnRejectActionID,
     * nothing fires (by design — cancel-shaped cleanup must not run for a rejection).
     *
     * The decision query is skipped entirely when the type wires neither hook.
     */
    protected async dispatchCancelOrRejectHook(
        taskType: mjBizAppsTasksTaskTypeEntity,
        currentTypeStatusCode: string | null,
        ctx: TaskLifecycleContext,
    ): Promise<void> {
        if (!taskType.OnRejectActionID && !taskType.OnCancelActionID) return;

        const rejected = this.isRejectedStage(currentTypeStatusCode) || await this.taskHasRejectedDecision();
        const [actionID, hook] = rejected
            ? [taskType.OnRejectActionID, 'OnReject' as const]
            : [taskType.OnCancelActionID, 'OnCancel' as const];
        if (!actionID) return;

        await this.invokeAction(actionID, hook, taskType.Code, currentTypeStatusCode, ctx.oldStatus);
    }

    /** True when the task's current TaskTypeStatus is the conventional rejected stage. */
    protected isRejectedStage(currentTypeStatusCode: string | null): boolean {
        return (currentTypeStatusCode ?? '').trim().toUpperCase() === REJECTED_STAGE_CODE;
    }

    /**
     * Returns true when this task has a TaskDecision with the 'Rejected' outcome.
     * Used to distinguish a rejection from a plain cancellation when routing the
     * OnReject vs. OnCancel hooks.
     *
     * Resolves the rejected outcome by its stable Code, then matches decisions by
     * OutcomeID — so renaming the outcome's display Name doesn't break routing.
     * A failed query is logged and treated as "no rejected decision" — the stage
     * check above still routes deployments using a REJECTED stage correctly.
     */
    protected async taskHasRejectedDecision(): Promise<boolean> {
        const rv = new RunView(this.RunViewProviderToUse);
        const outcomeResult = await rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Decision Outcomes',
            ExtraFilter: `Code = 'Rejected'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        if (!outcomeResult?.Success) {
            LogError(`TaskEntityServer: could not resolve the Rejected outcome for task ${this.ID}: ${outcomeResult?.ErrorMessage ?? 'unknown error'}`);
            return false;
        }
        const rejectedOutcomeID = outcomeResult.Results?.[0]?.ID;
        if (!rejectedOutcomeID) return false;

        const result = await rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Decisions',
            ExtraFilter: `TaskID = ${GuidLiteral(this.ID, 'TaskID')} AND OutcomeID = ${GuidLiteral(rejectedOutcomeID, 'OutcomeID')}`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        if (!result?.Success) {
            LogError(`TaskEntityServer: could not load decisions for task ${this.ID}: ${result?.ErrorMessage ?? 'unknown error'}`);
            return false;
        }
        return (result.Results?.length ?? 0) > 0;
    }

    /**
     * Loads a TaskTypeStatus entity by ID.
     */
    protected async loadTaskTypeStatus(statusID: string): Promise<mjBizAppsTasksTaskTypeStatusEntity | null> {
        const statusEntity = await this.saveProvider.GetEntityObject<mjBizAppsTasksTaskTypeStatusEntity>(
            'MJ_BizApps_Tasks: Task Type Status',
            this.ContextCurrentUser
        );
        const loaded = await statusEntity.Load(statusID);
        return loaded ? statusEntity : null;
    }

    /**
     * Prepares any new or dirty check-ins attached via `this.CheckIns` before the parent Task saves:
     * backfills PreviousValue / quantitative PercentComplete on each check-in and applies the newest
     * check-in's progress/health/timestamps directly onto this Task so everything persists in one pass.
     */
    private prepareCompositeCheckInsPreSave(): mjBizAppsTasksTaskCheckInEntity[] {
        const items = this.CheckIns?.Items;
        if (!Array.isArray(items) || items.length === 0) {
            return [];
        }
        const pending = items.filter(ci => !ci.IsSaved || ci.Dirty);
        if (pending.length === 0) {
            return [];
        }

        // Apply derived defaults in chronological order, tracking CurrentValue progression
        const ordered = [...pending].sort((a, b) => {
            const ta = a.CheckInAt ? new Date(a.CheckInAt).getTime() : 0;
            const tb = b.CheckInAt ? new Date(b.CheckInAt).getTime() : 0;
            return ta - tb;
        });

        let runningValue = this.CurrentValue;
        for (const ci of ordered) {
            if (ci.PreviousValue == null && runningValue != null) {
                ci.PreviousValue = runningValue;
            }
            if (ci.PercentComplete == null && ci.NewValue != null && this.TargetValue != null) {
                const computedPct = TaskService.computeQuantitativePercentComplete(
                    this.BaselineValue,
                    this.TargetValue,
                    ci.NewValue,
                    this.MetricDirection,
                );
                if (computedPct != null) {
                    ci.PercentComplete = computedPct;
                }
            }
            if (ci.NewValue != null) {
                runningValue = ci.NewValue;
            }
        }

        const latest = ordered[ordered.length - 1];
        const checkInTime = latest.CheckInAt ?? new Date();
        this.HealthStatus = latest.HealthStatus;
        if (latest.ConfidenceScore != null) {
            this.ConfidenceScore = latest.ConfidenceScore;
        }
        if (latest.NewValue != null) {
            this.CurrentValue = latest.NewValue;
        }
        if (latest.PercentComplete != null) {
            this.PercentComplete = latest.PercentComplete;
        }
        this.LastCheckInAt = checkInTime;
        if (this.CheckInCadence) {
            const nextDue = TaskService.computeNextCheckInDueAt(checkInTime, this.CheckInCadence);
            if (nextDue) {
                this.NextCheckInDueAt = nextDue;
            }
        }
        return pending;
    }

    /**
     * Loads the default TaskTypeStatus for a given TaskType.
     *
     * @throws when `typeID` is not a UUID — on a new, unsaved task it is caller-supplied and reaches
     * SQL text before `super.Save()` FK validation, so an invalid value fails the save loudly.
     */
    protected async loadDefaultTaskTypeStatus(typeID: string): Promise<mjBizAppsTasksTaskTypeStatusEntity | null> {
        const typeLiteral = GuidLiteral(typeID, 'TypeID');
        const rv = new RunView(this.RunViewProviderToUse);
        const result = await rv.RunView<mjBizAppsTasksTaskTypeStatusEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Type Status',
            ExtraFilter: `TaskTypeID=${typeLiteral} AND IsDefault=1 AND IsActive=1`,
            ResultType: 'entity_object',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        return result?.Results?.[0] ?? null;
    }

    /**
     * Loads a TaskType entity by ID.
     */
    protected async loadTaskType(typeID: string): Promise<mjBizAppsTasksTaskTypeEntity | null> {
        const typeEntity = await this.saveProvider.GetEntityObject<mjBizAppsTasksTaskTypeEntity>(
            'MJ_BizApps_Tasks: Task Types',
            this.ContextCurrentUser
        );
        const loaded = await typeEntity.Load(typeID);
        return loaded ? typeEntity : null;
    }

    /**
     * Registers a per-instance save handler that rolls up this task's parent
     * progress (server-only, idempotent, fire-and-forget). Fires after the save
     * is finalized so the ID/dirty state is settled.
     */
    private ensureRollupHandler(): void {
        if (this._rollupHandlerRegistered) {
            return;
        }
        this._rollupHandlerRegistered = true;

        this.RegisterEventHandler((event: BaseEntityEvent) => {
            if (event.type !== 'save') {
                return;
            }

            const parentID = this.ParentID;
            if (!parentID) {
                return;
            }

            // Idempotent reconcile: recomputes parent's weighted progress (and
            // auto-completes it when all children are done); no-ops when nothing
            // changed, which prevents the save it raises from looping back here.
            // Runs after commit on this Task's provider, like the action hooks.
            const provider = this.saveProvider;
            this.runAfterCommit('Task parent-progress rollup', this.capturePostCommitToken(), () =>
                new TaskService()
                    .rollupParentProgress(parentID, this.ContextCurrentUser, provider)
                    .catch((err: unknown) => {
                        const msg = err instanceof Error ? err.message : String(err);
                        LogError(`TaskEntityServer: parent-progress rollup failed for parent ${parentID}: ${msg}`);
                    })
            );
        });
    }

    /**
     * The provider this Task was created on. Every Save-time read and write goes through it, so a
     * Task saved on an isolated or transactional provider never touches the process-global one,
     * where another caller's open transaction would capture these queries.
     */
    protected get saveProvider(): TaskSaveProvider {
        const provider = this.ProviderToUse;
        if (!isTaskSaveProvider(provider)) {
            throw new Error('TaskEntityServer: the Task\'s provider cannot load entities or run views; this class is server-only.');
        }
        return provider;
    }

    private capturePostCommitToken(): object | undefined {
        const provider = this.ProviderToUse;
        return isPostCommitScheduler(provider) ? provider.CapturePostCommitToken() : undefined;
    }

    /**
     * Runs `task` once the transaction `token` names commits (now, when none was open), and drops
     * it on rollback. Starts it right away on a provider without a post-commit scheduler.
     * `task` must handle its own errors.
     */
    private runAfterCommit(description: string, token: object | undefined, task: () => Promise<void>): void {
        const provider = this.ProviderToUse;
        if (isPostCommitScheduler(provider)) {
            provider.RunAfterCommit(task, description, token);
        } else {
            void task();
        }
    }
}
