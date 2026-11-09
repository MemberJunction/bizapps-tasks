/**
 * Timesheet Approval Outcome Reconciliation Scheduled Job (§6.5, §16).
 *
 * Sweeps `Pending` `TimesheetApproval` parts (capped at `MaxRows: 200`) whose backing
 * `ApprovalTaskID` is already in a terminal status (`Completed`, `Cancelled`, or `Blocked`)
 * and applies the outcome idempotently via {@link ApplyTimesheetApprovalOutcomeForTask}.
 */
import {
    IMetadataProvider,
    IRunViewProvider,
    Metadata,
    RunView,
    UserInfo,
    ValidationResult,
} from '@memberjunction/core';
import { MJScheduledJobEntity } from '@memberjunction/core-entities';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { BaseScheduledJob, ScheduledJobExecutionContext } from '@memberjunction/scheduling-engine';
import { NotificationContent, ScheduledJobResult } from '@memberjunction/scheduling-base-types';
import {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
} from '@mj-biz-apps/tasks-entities';
import { ApplyTimesheetApprovalOutcomeForTask } from '@mj-biz-apps/tasks-entities-server';

/** Summary returned by {@link ReconcileStaleTimesheetApprovals}. */
export interface TimesheetApprovalReconcileSummary {
    ScannedPendingCount: number;
    RepairedCount: number;
    RepairedPartIDs: string[];
    RepairedTimesheetIDs: string[];
}

/**
 * Scans up to `maxRows` `Pending` `TimesheetApproval` rows, checks whether their backing
 * `ApprovalTaskID` is already in a terminal state (`Completed`, `Cancelled`, `Blocked`),
 * and applies the outcome idempotently.
 */
export async function ReconcileStaleTimesheetApprovals(
    contextUser: UserInfo,
    maxRows: number = 200,
    mdProvider?: IMetadataProvider | null,
    rvProvider?: IRunViewProvider | null,
): Promise<TimesheetApprovalReconcileSummary> {
    const md = mdProvider ?? Metadata.Provider;
    const rv = new RunView(rvProvider ?? null);
    const cap = Math.max(1, Math.min(1000, maxRows));

    const pendingRes = await rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>(
        {
            EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
            ExtraFilter: `Status='Pending'`,
            Fields: ['ID', 'TimesheetID', 'ApprovalTaskID', 'Status'],
            MaxRows: cap,
            ResultType: 'simple',
            BypassCache: true,
        },
        contextUser,
    );

    const pendingParts = pendingRes?.Results ?? [];
    if (pendingParts.length === 0) {
        return {
            ScannedPendingCount: 0,
            RepairedCount: 0,
            RepairedPartIDs: [],
            RepairedTimesheetIDs: [],
        };
    }

    const taskIDs = [
        ...new Set(
            pendingParts
                .map((p) => p.ApprovalTaskID)
                .filter((id): id is string => !!id && IsValidUUID(id)),
        ),
    ];
    if (taskIDs.length === 0) {
        return {
            ScannedPendingCount: pendingParts.length,
            RepairedCount: 0,
            RepairedPartIDs: [],
            RepairedTimesheetIDs: [],
        };
    }

    const inList = taskIDs.map((id) => `'${id}'`).join(',');
    const tasksRes = await rv.RunView<mjBizAppsTasksTaskEntity>(
        {
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ID IN (${inList}) AND Status IN ('Completed', 'Cancelled', 'Blocked')`,
            Fields: ['ID', 'Status'],
            MaxRows: cap,
            ResultType: 'simple',
            BypassCache: true,
        },
        contextUser,
    );

    const terminalTasks = tasksRes?.Results ?? [];
    const repairedPartIDs: string[] = [];
    const repairedTimesheetIDs = new Set<string>();

    for (const task of terminalTasks) {
        const outcome = await ApplyTimesheetApprovalOutcomeForTask(
            task.ID,
            task.Status,
            contextUser,
            md,
            rvProvider ?? null,
        );
        if (outcome.Applied && outcome.PartID) {
            repairedPartIDs.push(outcome.PartID);
            if (outcome.TimesheetID) {
                repairedTimesheetIDs.add(outcome.TimesheetID);
            }
        }
    }

    return {
        ScannedPendingCount: pendingParts.length,
        RepairedCount: repairedPartIDs.length,
        RepairedPartIDs: repairedPartIDs,
        RepairedTimesheetIDs: [...repairedTimesheetIDs],
    };
}

/**
 * Scheduled job driver that sweeps stale `Pending` `TimesheetApproval` rows whose approval
 * tasks are already terminal and applies their outcome (§6.5).
 */
@RegisterClass(BaseScheduledJob, 'TimesheetApprovalReconcileJob')
export class TimesheetApprovalReconcileJob extends BaseScheduledJob {
    public override async Execute(context: ScheduledJobExecutionContext): Promise<ScheduledJobResult> {
        try {
            const summary = await ReconcileStaleTimesheetApprovals(context.ContextUser, 200);
            if (summary.RepairedCount > 0) {
                this.log(
                    `Reconciled ${summary.RepairedCount} stale timesheet approval part(s): ${summary.RepairedPartIDs.join(', ')}`,
                );
            }
            return {
                Success: true,
                Details: {
                    scannedPendingCount: summary.ScannedPendingCount,
                    repairedCount: summary.RepairedCount,
                    repairedPartIDs: summary.RepairedPartIDs,
                    repairedTimesheetIDs: summary.RepairedTimesheetIDs,
                },
            };
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            this.logError('Timesheet approval reconciliation failed', err);
            return {
                Success: false,
                ErrorMessage: msg,
            };
        }
    }

    public override ValidateConfiguration(_schedule: MJScheduledJobEntity): ValidationResult {
        const result = new ValidationResult();
        result.Success = true;
        return result;
    }

    public override FormatNotification(
        _context: ScheduledJobExecutionContext,
        result: ScheduledJobResult,
    ): NotificationContent {
        const repairedCount =
            typeof result.Details?.repairedCount === 'number' ? result.Details.repairedCount : 0;
        return {
            Subject: `Timesheet Approval Reconciliation: ${repairedCount} part(s) repaired`,
            Body:
                repairedCount > 0
                    ? `Reconciled ${repairedCount} stale pending timesheet approval part(s).`
                    : 'No stale pending timesheet approval parts found.',
            Priority: repairedCount > 0 ? 'Normal' : 'Low',
        };
    }
}
