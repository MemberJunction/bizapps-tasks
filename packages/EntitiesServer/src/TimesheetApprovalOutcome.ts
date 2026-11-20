import {
    IMetadataProvider,
    IRunViewProvider,
    LogError,
    Metadata,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import {
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
} from '@mj-biz-apps/tasks-entities';
import { TimesheetStatusFromParts } from '@mj-biz-apps/tasks-core';
import { PrimaryPersonIDForUser } from './UserPeople.js';

export const TIMESHEET_APPROVAL_TASK_TYPE_CODE = 'TIMESHEET_APPROVAL';

/**
 * Result of applying a terminal approval task outcome to its `TimesheetApproval`
 * part and parent `Timesheet`.
 */
export interface TimesheetApprovalOutcomeResult {
    Applied: boolean;
    TimesheetID: string | null;
    PartID: string | null;
    PartStatus: mjBizAppsTasksTimesheetApprovalEntity['Status'] | null;
    TimesheetStatus: mjBizAppsTasksTimesheetEntity['Status'] | null;
}

/**
 * Applies the outcome of a terminal `TIMESHEET_APPROVAL` task (`Completed`,
 * `Cancelled`, or `Blocked`) to its `TimesheetApproval` part and parent `Timesheet`.
 *
 * Idempotent: if the part is already in a non-`Pending` state, returns
 * `{ Applied: false }` without writing.
 *
 * Steps (§6.5):
 * 1. Finds the `Pending` `TimesheetApproval` part with `ApprovalTaskID = taskID`.
 * 2. Sets the part to `Approved` (when `taskStatus === 'Completed'`) or `Rejected`
 *    (when `Cancelled` or `Blocked`), stamping `DecidedAt`, `DecidedByPersonID`,
 *    and `DecisionNotes` from the latest `TaskDecision` on the task.
 * 3. If the part was `Rejected`, cancels every other `Pending` part in the same
 *    submission round, moves its approval task to `Cancelled`, and adds a comment:
 *    `"No decision needed: this timesheet was returned by {part label}."`
 * 4. Recomputes the parent `Timesheet.Status` via `TimesheetStatusFromParts` and
 *    saves the `Timesheet` when its status changed.
 */
export async function ApplyTimesheetApprovalOutcomeForTask(
    taskID: string,
    taskStatus: mjBizAppsTasksTaskEntity['Status'],
    contextUser: UserInfo,
    mdProvider?: IMetadataProvider | null,
    rvProvider?: IRunViewProvider | null,
): Promise<TimesheetApprovalOutcomeResult> {
    if (taskStatus !== 'Completed' && taskStatus !== 'Cancelled' && taskStatus !== 'Blocked') {
        return {
            Applied: false,
            TimesheetID: null,
            PartID: null,
            PartStatus: null,
            TimesheetStatus: null,
        };
    }

    const md = mdProvider ?? Metadata.Provider;
    const rv = new RunView(rvProvider ?? null);
    const safeTaskID = taskID.replace(/'/g, "''");

    const partRes = await rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>({
        EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
        ExtraFilter: `ApprovalTaskID='${safeTaskID}' AND Status='Pending'`,
        MaxRows: 1,
        ResultType: 'entity_object',
    }, contextUser);

    const part = partRes.Results?.[0];
    if (!part) {
        return {
            Applied: false,
            TimesheetID: null,
            PartID: null,
            PartStatus: null,
            TimesheetStatus: null,
        };
    }

    const nextPartStatus: mjBizAppsTasksTimesheetApprovalEntity['Status'] =
        taskStatus === 'Completed' ? 'Approved' : 'Rejected';

    // Load the most recent TaskDecision on this approval task (if any)
    const decRes = await rv.RunView<mjBizAppsTasksTaskDecisionEntity>({
        EntityName: 'MJ_BizApps_Tasks: Task Decisions',
        ExtraFilter: `TaskID='${safeTaskID}'`,
        OrderBy: 'DecidedAt DESC',
        MaxRows: 1,
        ResultType: 'simple',
    }, contextUser);
    const latestDecision = decRes.Results?.[0];

    let deciderPersonID = latestDecision?.DecidedByPersonID ?? null;
    if (!deciderPersonID) {
        deciderPersonID = await PrimaryPersonIDForUser(md, rvProvider ?? null, contextUser);
    }

    part.Status = nextPartStatus;
    part.DecidedAt = latestDecision?.DecidedAt ? new Date(latestDecision.DecidedAt) : new Date();
    if (deciderPersonID) {
        part.DecidedByPersonID = deciderPersonID;
    }
    if (latestDecision?.DecisionNotes != null) {
        part.DecisionNotes = latestDecision.DecisionNotes;
    }

    const partSaved = await part.Save();
    if (!partSaved) {
        throw new Error(
            part.LatestResult?.CompleteMessage ||
            `Failed to save TimesheetApproval outcome for part ${part.ID}.`,
        );
    }

    const partLabel = part.ScopeTask || 'Timesheet review';
    const safeTimesheetID = part.TimesheetID.replace(/'/g, "''");

    // Load all parts of this timesheet in the same submission round
    const allPartsRes = await rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>({
        EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
        ExtraFilter: `TimesheetID='${safeTimesheetID}' AND SubmissionRound=${part.SubmissionRound}`,
        ResultType: 'entity_object',
    }, contextUser);
    const roundParts = allPartsRes.Results ?? [part];

    // Ensure our updated part status is reflected in the in-memory list
    for (const p of roundParts) {
        if (p.ID.toLowerCase() === part.ID.toLowerCase()) {
            p.Status = nextPartStatus;
        }
    }

    // Step 2: If rejected, cancel sibling Pending parts and their approval tasks
    if (nextPartStatus === 'Rejected') {
        for (const sibling of roundParts) {
            if (sibling.ID.toLowerCase() === part.ID.toLowerCase()) continue;
            if (sibling.Status !== 'Pending') continue;

            sibling.Status = 'Canceled';
            sibling.DecidedAt = new Date();
            await sibling.Save();

            if (sibling.ApprovalTaskID && sibling.ApprovalTaskID.toLowerCase() !== taskID.toLowerCase()) {
                await cancelSiblingApprovalTask(
                    sibling.ApprovalTaskID,
                    partLabel,
                    deciderPersonID,
                    contextUser,
                    md,
                );
            }
        }
    }

    // Step 3: Recompute parent Timesheet status from the round's parts
    const nextTimesheetStatus = TimesheetStatusFromParts(roundParts.map(p => p.Status));
    const tsEntity = await md.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
        'MJ_BizApps_Tasks: Timesheets',
        contextUser,
    );
    const tsLoaded = await tsEntity.Load(part.TimesheetID);
    if (tsLoaded && tsEntity.Status !== nextTimesheetStatus) {
        tsEntity.Status = nextTimesheetStatus;
        const tsSaved = await tsEntity.Save();
        if (!tsSaved) {
            LogError(
                `TimesheetApprovalOutcome: failed to update Timesheet ${part.TimesheetID} to ${nextTimesheetStatus}: ${tsEntity.LatestResult?.CompleteMessage ?? ''}`,
            );
        }
    }

    return {
        Applied: true,
        TimesheetID: part.TimesheetID,
        PartID: part.ID,
        PartStatus: nextPartStatus,
        TimesheetStatus: nextTimesheetStatus,
    };
}

async function cancelSiblingApprovalTask(
    siblingTaskID: string,
    rejectingPartLabel: string,
    commentPersonID: string | null,
    contextUser: UserInfo,
    md: IMetadataProvider,
): Promise<void> {
    try {
        const siblingTask = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
            'MJ_BizApps_Tasks: Tasks',
            contextUser,
        );
        const loaded = await siblingTask.Load(siblingTaskID);
        if (loaded && siblingTask.Status !== 'Completed' && siblingTask.Status !== 'Cancelled') {
            siblingTask.Status = 'Cancelled';
            await siblingTask.Save();
        }

        if (commentPersonID) {
            const comment = await md.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
                'MJ_BizApps_Tasks: Task Comments',
                contextUser,
            );
            comment.NewRecord();
            comment.TaskID = siblingTaskID;
            comment.PersonID = commentPersonID;
            comment.Content = `No decision needed: this timesheet was returned by ${rejectingPartLabel}.`;
            await comment.Save();
        }
    } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        LogError(`TimesheetApprovalOutcome: could not cancel sibling approval task ${siblingTaskID}: ${msg}`);
    }
}
