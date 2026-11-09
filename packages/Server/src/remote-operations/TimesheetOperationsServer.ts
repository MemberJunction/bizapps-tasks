import {
    BaseRemotableOperation,
    IMetadataProvider,
    IRunViewProvider,
    RemoteOpServerContext,
    RunInEntityTransaction,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import {
    CalendarDay,
    CompareDays,
    FromCalendarDay,
    IsCalendarDay,
    ToCalendarDay,
} from '@mj-biz-apps/common-entities';
import {
    ReopenTimesheetInput,
    ReopenTimesheetOutput,
    SubmitTimesheetInput,
    SubmitTimesheetOutput,
    TasksReopenTimesheetOperation,
    TasksSubmitTimesheetOperation,
    TasksWithdrawTimesheetOperation,
    TimesheetPartSummary,
    WithdrawTimesheetInput,
    WithdrawTimesheetOutput,
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTimerEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTimeApproverEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
    mjBizAppsTasksTimesheetScheduleEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ApproverResolutionContext,
    EffectiveScheduleCandidate,
    FormatDurationMinutes,
    GroupIntoParts,
    GroupedTimesheetPart,
    PeriodFor,
    ResolveScheduleForDate,
    TaskHierarchyNode,
    TasksSettings,
    TimeApproverRuleFact,
    TimesheetEntryFact,
    TimesheetStatusFromParts,
    UserCanManageTimeEntries,
    UserCanManageTimesheets,
} from '@mj-biz-apps/tasks-core';
import {
    BaseTimeApproverResolver,
    PEOPLE_ENTITY,
    PeopleForUser,
    TIMESHEET_APPROVAL_TASK_TYPE_CODE,
} from '@mj-biz-apps/tasks-entities-server';
import {
    AsTransactionHost,
    ConvertTimerToEntriesInTransaction,
    ResolveBusinessTimeZone,
} from './TimerOperationsServer.js';

interface PersonNameRow {
    ID: string;
    DisplayName?: string | null;
    FirstName?: string | null;
    LastName?: string | null;
    LinkedUserID?: string | null;
}

interface RelationshipRow {
    ToPersonID: string | null;
    StartDate: Date | string | null;
    EndDate: Date | string | null;
    Status: string;
}

interface UserRoleRow {
    UserID: string;
}

/**
 * Formats a `PersonNameRow` into a clean display label.
 */
function formatPersonName(row: PersonNameRow | undefined, fallbackId: string): string {
    if (!row) return fallbackId;
    if (row.DisplayName?.trim()) return row.DisplayName.trim();
    const parts = [row.FirstName?.trim(), row.LastName?.trim()].filter(Boolean);
    return parts.length > 0 ? parts.join(' ') : fallbackId;
}

/**
 * Resolves the `TIMESHEET_APPROVAL` task type ID, falling back to any active approval task type
 * or any active task type when the seed row is absent in minimal test fixtures.
 */
async function resolveTimesheetApprovalTaskTypeID(
    rv: RunView,
    user: UserInfo,
): Promise<string | null> {
    const codeRes = await rv.RunView<mjBizAppsTasksTaskTypeEntity>(
        {
            EntityName: 'MJ_BizApps_Tasks: Task Types',
            ExtraFilter: `Code='${TIMESHEET_APPROVAL_TASK_TYPE_CODE}' AND IsActive=1`,
            Fields: ['ID'],
            MaxRows: 1,
            ResultType: 'simple',
        },
        user,
    );
    if (codeRes?.Results?.[0]?.ID) {
        return codeRes.Results[0].ID;
    }

    const fallbackRes = await rv.RunView<mjBizAppsTasksTaskTypeEntity>(
        {
            EntityName: 'MJ_BizApps_Tasks: Task Types',
            ExtraFilter: `IsApproval=1 AND IsActive=1`,
            Fields: ['ID'],
            MaxRows: 1,
            ResultType: 'simple',
        },
        user,
    );
    if (fallbackRes?.Results?.[0]?.ID) {
        return fallbackRes.Results[0].ID;
    }

    const anyRes = await rv.RunView<mjBizAppsTasksTaskTypeEntity>(
        {
            EntityName: 'MJ_BizApps_Tasks: Task Types',
            ExtraFilter: `IsActive=1`,
            Fields: ['ID'],
            MaxRows: 1,
            ResultType: 'simple',
        },
        user,
    );
    return anyRes?.Results?.[0]?.ID ?? null;
}

/**
 * Builds a concise Markdown description of a timesheet approval part's entries by task and day (§6.5).
 */
function buildPartApprovalDescription(
    personName: string,
    periodStart: CalendarDay,
    periodEnd: CalendarDay,
    part: GroupedTimesheetPart,
): string {
    const header = `Timesheet approval for **${personName}** (${periodStart} to ${periodEnd}) — **${part.ScopeLabel}**.`;
    const summary = `Total: **${FormatDurationMinutes(part.Minutes)}** (${part.Minutes} min) · Billable: **${FormatDurationMinutes(part.BillableMinutes)}** (${part.BillableMinutes} min) · Entries: **${part.EntryCount}**.`;
    if (part.Entries.length === 0) {
        return `${header}\n\n${summary}\n\n_No time entries logged in this period._`;
    }

    const lines = part.Entries.map((e) => {
        const day = ToCalendarDay(e.WorkDate) ?? String(e.WorkDate);
        const taskLabel = e.TaskName?.trim() || e.TaskID;
        const billableTag = e.IsBillable ? 'Billable' : 'Non-billable';
        const noteSuffix = e.Notes?.trim() ? ` — ${e.Notes.trim()}` : '';
        return `- ${day} · **${taskLabel}**: ${FormatDurationMinutes(e.Minutes)} (${billableTag})${noteSuffix}`;
    });

    return `${header}\n\n${summary}\n\n${lines.join('\n')}`;
}

/**
 * Loads the task hierarchy nodes (entry tasks and all ancestors up to each root task) for a set of task IDs.
 */
async function loadTaskHierarchyForEntries(
    taskIDs: readonly string[],
    rv: RunView,
    user: UserInfo,
): Promise<{ taskMap: Map<string, TaskHierarchyNode>; rootTaskIDs: string[] }> {
    const taskMap = new Map<string, TaskHierarchyNode>();
    const validIds = [...new Set(taskIDs.filter((id) => IsValidUUID(id)))];
    if (validIds.length === 0) {
        return { taskMap, rootTaskIDs: [] };
    }

    const inList = validIds.map((id) => `'${id}'`).join(',');
    const directRes = await rv.RunView<{
        ID: string;
        Name: string;
        ParentID: string | null;
        RootParentID: string | null;
    }>(
        {
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ID IN (${inList})`,
            Fields: ['ID', 'Name', 'ParentID', 'RootParentID'],
            ResultType: 'simple',
            BypassCache: true,
        },
        user,
    );

    const rootIds = new Set<string>();
    for (const row of directRes?.Results ?? []) {
        taskMap.set(row.ID.toLowerCase(), {
            ID: row.ID,
            Name: row.Name,
            ParentID: row.ParentID ?? null,
            RootParentID: row.RootParentID ?? row.ID,
        });
        const rootId = row.RootParentID || row.ID;
        if (IsValidUUID(rootId)) {
            rootIds.add(rootId);
        }
    }

    if (rootIds.size > 0) {
        const rootInList = [...rootIds].map((id) => `'${id}'`).join(',');
        const treeRes = await rv.RunView<{
            ID: string;
            Name: string;
            ParentID: string | null;
            RootParentID: string | null;
        }>(
            {
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `RootParentID IN (${rootInList}) OR ID IN (${rootInList})`,
                Fields: ['ID', 'Name', 'ParentID', 'RootParentID'],
                MaxRows: 5000,
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        for (const row of treeRes?.Results ?? []) {
            taskMap.set(row.ID.toLowerCase(), {
                ID: row.ID,
                Name: row.Name,
                ParentID: row.ParentID ?? null,
                RootParentID: row.RootParentID ?? row.ID,
            });
        }
    }

    return { taskMap, rootTaskIDs: [...rootIds] };
}

/**
 * Loads fallback approver Person IDs from `TimesheetApproverRelationshipType` and `TimesheetApproverRole`.
 */
async function loadFallbackApprovers(
    submitterPersonID: string,
    periodStart: CalendarDay,
    periodEnd: CalendarDay,
    provider: IMetadataProvider,
    rv: RunView,
    user: UserInfo,
): Promise<{ relationshipApproverIDs: string[]; roleApproverIDs: string[] }> {
    const relationshipApproverIDs: string[] = [];
    const roleApproverIDs: string[] = [];

    const relType = TasksSettings.TimesheetApproverRelationshipType(provider);
    if (relType && IsValidUUID(submitterPersonID)) {
        const safeRel = relType.replace(/'/g, "''");
        const relRes = await rv.RunView<RelationshipRow>(
            {
                EntityName: 'MJ_BizApps_Common: Relationships',
                ExtraFilter: `FromPersonID='${submitterPersonID}' AND Status='Active' AND RelationshipType='${safeRel}' AND ToPersonID IS NOT NULL`,
                Fields: ['ToPersonID', 'StartDate', 'EndDate', 'Status'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        for (const r of relRes?.Results ?? []) {
            if (!r.ToPersonID) continue;
            if (r.StartDate) {
                const startDay = ToCalendarDay(r.StartDate);
                if (startDay && CompareDays(startDay, periodEnd) > 0) continue;
            }
            if (r.EndDate) {
                const endDay = ToCalendarDay(r.EndDate);
                if (endDay && CompareDays(endDay, periodStart) < 0) continue;
            }
            relationshipApproverIDs.push(r.ToPersonID);
        }
    }

    const roleName = TasksSettings.TimesheetApproverRole(provider);
    if (roleName) {
        const safeRole = roleName.replace(/'/g, "''");
        const userRoleRes = await rv.RunView<UserRoleRow>(
            {
                EntityName: 'MJ: User Roles',
                ExtraFilter: `Role='${safeRole}'`,
                Fields: ['UserID'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        const roleUserIDs = [...new Set((userRoleRes?.Results ?? []).map((u) => u.UserID).filter((id) => IsValidUUID(id)))];
        if (roleUserIDs.length > 0) {
            const userInList = roleUserIDs.map((id) => `'${id}'`).join(',');
            const peopleRes = await rv.RunView<{ ID: string }>(
                {
                    EntityName: PEOPLE_ENTITY,
                    ExtraFilter: `LinkedUserID IN (${userInList})`,
                    Fields: ['ID'],
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            );
            for (const p of peopleRes?.Results ?? []) {
                roleApproverIDs.push(p.ID);
            }
        }
    }

    return { relationshipApproverIDs, roleApproverIDs };
}

/**
 * Server implementation of `Tasks.SubmitTimesheet` (§6.5, §7).
 *
 * Groups the period's time entries into approval parts, resolves each part's approvers via
 * `GroupIntoParts`, carries forward unchanged `Approved` parts on resubmission, and spawns
 * `TIMESHEET_APPROVAL` tasks in the Tasks inbox inside one database transaction.
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.SubmitTimesheet')
export class SubmitTimesheetOperationServer extends TasksSubmitTimesheetOperation {
    protected override async InternalExecute(
        input: SubmitTimesheetInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<SubmitTimesheetOutput> {
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.TimesheetApprovalEnabled(provider)) {
            return {
                Success: false,
                Message: 'Timesheet approval is disabled for the Tasks application.',
            };
        }

        if (input?.TimesheetID && !IsValidUUID(input.TimesheetID)) {
            return {
                Success: false,
                Message: 'TimesheetID is not a valid UUID.',
            };
        }
        if (input?.PersonID && !IsValidUUID(input.PersonID)) {
            return {
                Success: false,
                Message: 'PersonID is not a valid UUID.',
            };
        }

        const rvProvider = provider as unknown as IRunViewProvider;
        const rv = new RunView(rvProvider);
        const callerPersonIDs = await PeopleForUser(provider, rvProvider, user);
        const canManage =
            UserCanManageTimesheets(user, provider) || UserCanManageTimeEntries(user, provider);

        let existingTimesheet: mjBizAppsTasksTimesheetEntity | null = null;
        let targetPersonID: string | null = null;
        let periodStartDay: CalendarDay;
        let periodEndDay: CalendarDay;

        if (input?.TimesheetID) {
            const loaded = await provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                'MJ_BizApps_Tasks: Timesheets',
                user,
            );
            const ok = await loaded.Load(input.TimesheetID);
            if (!ok) {
                return {
                    Success: false,
                    Message: 'Timesheet not found.',
                };
            }
            existingTimesheet = loaded;
            targetPersonID = loaded.PersonID;
            const start = ToCalendarDay(loaded.PeriodStart);
            const end = ToCalendarDay(loaded.PeriodEnd);
            if (!start || !end) {
                return {
                    Success: false,
                    Message: 'Timesheet has invalid PeriodStart or PeriodEnd dates.',
                };
            }
            periodStartDay = start;
            periodEndDay = end;
        } else {
            targetPersonID = input?.PersonID?.trim() || callerPersonIDs[0] || null;
            if (!targetPersonID || !IsValidUUID(targetPersonID)) {
                return {
                    Success: false,
                    Message: "You can't submit a timesheet: your user has no person record.",
                };
            }

            const explicitStart = input?.PeriodStart ? ToCalendarDay(input.PeriodStart) : null;
            const explicitEnd = input?.PeriodEnd ? ToCalendarDay(input.PeriodEnd) : null;

            if (input?.PeriodStart && (!explicitStart || !IsCalendarDay(explicitStart))) {
                return {
                    Success: false,
                    Message: 'PeriodStart must be a valid YYYY-MM-DD date.',
                };
            }
            if (input?.PeriodEnd && (!explicitEnd || !IsCalendarDay(explicitEnd))) {
                return {
                    Success: false,
                    Message: 'PeriodEnd must be a valid YYYY-MM-DD date.',
                };
            }

            if (explicitStart && explicitEnd) {
                if (CompareDays(explicitEnd, explicitStart) < 0) {
                    return {
                        Success: false,
                        Message: 'PeriodEnd must be on or after PeriodStart.',
                    };
                }
                periodStartDay = explicitStart;
                periodEndDay = explicitEnd;
            } else {
                // Compute period boundaries from the person's effective schedule or app defaults
                const schedRes = await rv.RunView<mjBizAppsTasksTimesheetScheduleEntity>(
                    {
                        EntityName: 'MJ_BizApps_Tasks: Timesheet Schedules',
                        ExtraFilter: `PersonID='${targetPersonID}' OR PersonID IS NULL`,
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    user,
                );
                const refDay = explicitStart ?? ToCalendarDay(new Date())!;
                const candidates: EffectiveScheduleCandidate[] = (schedRes?.Results ?? []).map((s) => ({
                    ID: s.ID,
                    PersonID: s.PersonID,
                    ScopeEntityID: s.ScopeEntityID,
                    ScopeRecordID: s.ScopeRecordID,
                    Cadence: s.Cadence,
                    WeekStartDay: s.WeekStartDay,
                    BiWeeklyAnchorDate: s.BiWeeklyAnchorDate,
                    EffectiveFrom: s.EffectiveFrom,
                    EffectiveTo: s.EffectiveTo,
                }));
                const matchedSched = ResolveScheduleForDate(refDay, candidates, targetPersonID);
                const bounds = PeriodFor(refDay, {
                    Cadence: matchedSched?.Cadence ?? TasksSettings.TimesheetCadence(provider),
                    WeekStartDay: matchedSched?.WeekStartDay ?? TasksSettings.TimesheetWeekStartDay(provider),
                    BiWeeklyAnchorDate:
                        matchedSched?.BiWeeklyAnchorDate ?? TasksSettings.TimesheetBiWeeklyAnchorDate(provider),
                    OpenEndedPeriodEnd: explicitEnd,
                });
                periodStartDay = explicitStart ?? bounds.PeriodStart;
                periodEndDay = explicitEnd ?? bounds.PeriodEnd;
            }
        }

        const isOwner = callerPersonIDs.some((id) => id.toLowerCase() === targetPersonID!.toLowerCase());
        if (!isOwner && !canManage) {
            return {
                Success: false,
                Message: 'Only the timesheet owner or a timesheet manager can submit this timesheet.',
            };
        }

        // Check existing timesheets for the person overlapping [periodStartDay, periodEndDay]
        const overlappingRes = await rv.RunView<mjBizAppsTasksTimesheetEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Timesheets',
                ExtraFilter: `PersonID='${targetPersonID}' AND PeriodStart <= '${periodEndDay}' AND PeriodEnd >= '${periodStartDay}'`,
                ResultType: 'entity_object',
                BypassCache: true,
            },
            user,
        );
        const overlapping = overlappingRes?.Results ?? [];

        if (!existingTimesheet) {
            const exactMatch = overlapping.find(
                (ts) =>
                    ToCalendarDay(ts.PeriodStart) === periodStartDay &&
                    ToCalendarDay(ts.PeriodEnd) === periodEndDay,
            );
            if (exactMatch) {
                existingTimesheet = exactMatch;
            }
        }

        if (existingTimesheet && (existingTimesheet.Status === 'Submitted' || existingTimesheet.Status === 'Approved')) {
            return {
                Success: false,
                Message: `The timesheet for ${periodStartDay} to ${periodEndDay} is already ${existingTimesheet.Status}.`,
            };
        }

        const conflicting = overlapping.find(
            (ts) => !existingTimesheet || ts.ID.toLowerCase() !== existingTimesheet.ID.toLowerCase(),
        );
        if (conflicting) {
            const cStart = ToCalendarDay(conflicting.PeriodStart) ?? String(conflicting.PeriodStart);
            const cEnd = ToCalendarDay(conflicting.PeriodEnd) ?? String(conflicting.PeriodEnd);
            return {
                Success: false,
                Message: `Period ${periodStartDay} to ${periodEndDay} overlaps with an existing timesheet (${cStart} to ${cEnd}).`,
            };
        }

        // Check for a running timer on targetPersonID
        const timerRes = await rv.RunView<mjBizAppsTasksTaskTimerEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Task Timers',
                ExtraFilter: `PersonID='${targetPersonID}'`,
                MaxRows: 1,
                ResultType: 'entity_object',
                BypassCache: true,
            },
            user,
        );
        const runningTimer = timerRes?.Results?.[0] ?? null;
        const zone = await ResolveBusinessTimeZone(provider, user);
        const rounding = TasksSettings.TimeEntryRoundingMinutes(provider);

        // If a running timer started inside or overlaps the period, stop it first so its entries are included
        if (runningTimer) {
            const timerStartDay = ToCalendarDay(new Date(runningTimer.StartedAt));
            if (timerStartDay && CompareDays(timerStartDay, periodEndDay) <= 0) {
                try {
                    await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                        await ConvertTimerToEntriesInTransaction(
                            runningTimer,
                            new Date(),
                            undefined,
                            undefined,
                            undefined,
                            zone,
                            rounding,
                            provider,
                            user,
                        );
                    });
                } catch (err: unknown) {
                    const msg = err instanceof Error ? err.message : String(err);
                    return {
                        Success: false,
                        Message: `Could not stop running timer before submitting timesheet: ${msg}`,
                    };
                }
            }
        }

        // Load all time entries for targetPersonID in [periodStartDay, periodEndDay], plus person info & approver rules
        const [entriesRes, personRes, rulesRes, existingPartsRes] = await Promise.all([
            rv.RunView<mjBizAppsTasksTaskTimeEntryEntity>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
                    ExtraFilter: `PersonID='${targetPersonID}' AND WorkDate >= '${periodStartDay}' AND WorkDate <= '${periodEndDay}'`,
                    OrderBy: 'WorkDate ASC, __mj_CreatedAt ASC',
                    ResultType: 'entity_object',
                    BypassCache: true,
                },
                user,
            ),
            rv.RunView<PersonNameRow>(
                {
                    EntityName: PEOPLE_ENTITY,
                    ExtraFilter: `ID='${targetPersonID}'`,
                    Fields: ['ID', 'DisplayName', 'FirstName', 'LastName'],
                    MaxRows: 1,
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            ),
            rv.RunView<mjBizAppsTasksTimeApproverEntity>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Time Approvers',
                    ExtraFilter: `IsActive=1`,
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            ),
            existingTimesheet
                ? rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>(
                      {
                          EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                          ExtraFilter: `TimesheetID='${existingTimesheet.ID}'`,
                          OrderBy: 'SubmissionRound DESC',
                          ResultType: 'entity_object',
                          BypassCache: true,
                      },
                      user,
                  )
                : Promise.resolve({ Success: true, Results: [] as mjBizAppsTasksTimesheetApprovalEntity[] }),
        ]);

        if (!entriesRes?.Success) {
            return {
                Success: false,
                Message: entriesRes?.ErrorMessage || 'Failed to load time entries for timesheet period.',
            };
        }

        const entryEntities = entriesRes.Results ?? [];
        const submitterName = formatPersonName(personRes?.Results?.[0], targetPersonID);

        const entryTaskIDs = entryEntities.map((e) => e.TaskID);
        const [{ taskMap, rootTaskIDs }, { relationshipApproverIDs, roleApproverIDs }] = await Promise.all([
            loadTaskHierarchyForEntries(entryTaskIDs, rv, user),
            loadFallbackApprovers(targetPersonID, periodStartDay, periodEndDay, provider, rv, user),
        ]);

        const resolverScopesByRoot = await BaseTimeApproverResolver.ResolveAllForRootTasks(
            rootTaskIDs,
            provider,
            rvProvider,
            user,
        );

        const tasksEntityID =
            provider.Entities?.find((e) => e.Name === 'MJ_BizApps_Tasks: Tasks')?.ID ?? null;
        const peopleEntityID =
            provider.Entities?.find((e) => e.Name === PEOPLE_ENTITY)?.ID ?? null;
        const tsApprovalEntityID =
            provider.Entities?.find((e) => e.Name === 'MJ_BizApps_Tasks: Timesheet Approvals')?.ID ?? null;

        const approverRules: TimeApproverRuleFact[] = (rulesRes?.Results ?? []).map((r) => ({
            ID: r.ID,
            ApproverPersonID: r.ApproverPersonID,
            WorkerPersonID: r.WorkerPersonID,
            ScopeTaskID: r.ScopeTaskID,
            IncludeDescendants: r.IncludeDescendants,
            ScopeEntityID: r.ScopeEntityID,
            ScopeRecordID: r.ScopeRecordID,
            EffectiveFrom: r.EffectiveFrom,
            EffectiveTo: r.EffectiveTo,
            IsActive: r.IsActive,
        }));

        const entryFacts: TimesheetEntryFact[] = entryEntities.map((e) => ({
            ID: e.ID,
            TaskID: e.TaskID,
            TaskName: e.Task || taskMap.get(e.TaskID.toLowerCase())?.Name || e.TaskID,
            WorkDate: ToCalendarDay(e.WorkDate) ?? periodStartDay,
            Minutes: e.Minutes,
            IsBillable: e.IsBillable,
            Notes: e.Notes,
        }));

        const resolutionContext: ApproverResolutionContext = {
            SubmitterPersonID: targetPersonID,
            SubmitterPersonName: submitterName,
            ReferenceDate: periodEndDay,
            TasksEntityID: tasksEntityID,
            PeopleEntityID: peopleEntityID,
            Tasks: taskMap,
            ResolverScopesByRootTaskID: resolverScopesByRoot,
            ApproverRules: approverRules,
            FallbackRelationshipApproverPersonIDs: relationshipApproverIDs,
            FallbackRoleApproverPersonIDs: roleApproverIDs,
        };

        const routingMode = TasksSettings.TimesheetApprovalRouting(provider);
        const grouped = GroupIntoParts(entryFacts, resolutionContext, routingMode);
        if (grouped.RefusalMessage) {
            return {
                Success: false,
                Message: grouped.RefusalMessage,
            };
        }

        const totalMinutes = entryFacts.reduce((sum, e) => sum + e.Minutes, 0);
        const billableMinutes = entryFacts.reduce((sum, e) => sum + (e.IsBillable ? e.Minutes : 0), 0);
        const existingParts = existingPartsRes?.Results ?? [];
        const maxPreviousRound = existingParts.reduce((max, p) => Math.max(max, p.SubmissionRound || 0), 0);
        const currentRound = maxPreviousRound + 1;
        const reapproveAll = TasksSettings.TimesheetResubmitReapprovesAll(provider);

        const approvalTaskTypeID = await resolveTimesheetApprovalTaskTypeID(rv, user);
        if (!approvalTaskTypeID && routingMode !== 'AutoApprove') {
            return {
                Success: false,
                Message: 'Timesheet Approval task type (TIMESHEET_APPROVAL) is not configured.',
            };
        }

        try {
            return await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                let timesheet = existingTimesheet;
                if (!timesheet) {
                    timesheet = await provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                        'MJ_BizApps_Tasks: Timesheets',
                        user,
                    );
                    timesheet.NewRecord();
                    timesheet.PersonID = targetPersonID!;
                    timesheet.PeriodStart = FromCalendarDay(periodStartDay);
                    timesheet.PeriodEnd = FromCalendarDay(periodEndDay);
                }

                // Save as Draft first while attaching entries so R6 lock does not reject entry updates
                timesheet.Status = 'Draft';
                timesheet.TotalMinutes = totalMinutes;
                timesheet.BillableMinutes = billableMinutes;
                timesheet.SubmittedAt = new Date();
                timesheet.SubmittedByUserID = user.ID;
                if (input?.Notes !== undefined) {
                    timesheet.Notes = input.Notes;
                }

                const tsDraftSaved = await timesheet.Save();
                if (!tsDraftSaved) {
                    const msg =
                        timesheet.LatestResult?.CompleteMessage ||
                        timesheet.ResultHistory?.[timesheet.ResultHistory.length - 1]?.Message ||
                        'Failed to save timesheet header.';
                    throw new Error(msg);
                }

                // Attach all time entries in the period to this timesheet
                for (const entry of entryEntities) {
                    if (!entry.TimesheetID || entry.TimesheetID.toLowerCase() !== timesheet.ID.toLowerCase()) {
                        entry.TimesheetID = timesheet.ID;
                        const entrySaved = await entry.Save();
                        if (!entrySaved) {
                            const msg =
                                entry.LatestResult?.CompleteMessage ||
                                entry.ResultHistory?.[entry.ResultHistory.length - 1]?.Message ||
                                `Failed to link time entry ${entry.ID} to timesheet.`;
                            throw new Error(msg);
                        }
                    }
                }

                // Cancel any lingering Pending parts from earlier rounds
                for (const oldPart of existingParts) {
                    if (oldPart.Status === 'Pending') {
                        oldPart.Status = 'Canceled';
                        oldPart.DecidedAt = new Date();
                        await oldPart.Save();
                        if (oldPart.ApprovalTaskID) {
                            const oldTask = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                                'MJ_BizApps_Tasks: Tasks',
                                user,
                            );
                            if (await oldTask.Load(oldPart.ApprovalTaskID)) {
                                if (oldTask.Status !== 'Completed' && oldTask.Status !== 'Cancelled') {
                                    oldTask.Status = 'Cancelled';
                                    await oldTask.Save();
                                }
                            }
                        }
                    }
                }

                const partSummaries: TimesheetPartSummary[] = [];

                if (routingMode === 'AutoApprove') {
                    timesheet.Status = 'Approved';
                    const finalSaved = await timesheet.Save();
                    if (!finalSaved) {
                        throw new Error(
                            timesheet.LatestResult?.CompleteMessage || 'Failed to finalize auto-approved timesheet.',
                        );
                    }
                    return {
                        Success: true,
                        Message: 'Timesheet auto-approved.',
                        TimesheetID: timesheet.ID,
                        Status: timesheet.Status,
                        SubmissionRound: currentRound,
                        TotalMinutes: totalMinutes,
                        BillableMinutes: billableMinutes,
                        Parts: [],
                    };
                }

                for (const part of grouped.Parts) {
                    // Check if an Approved part from the previous round has the same ScopeTaskID and SnapshotHash
                    const reusableApprovedPart = !reapproveAll
                        ? existingParts.find((prev) => {
                              if (prev.Status !== 'Approved') return false;
                              const prevScope = (prev.ScopeTaskID ?? '').toLowerCase();
                              const currScope = (part.ScopeTaskID ?? '').toLowerCase();
                              return prevScope === currScope && prev.SnapshotHash === part.SnapshotHash;
                          })
                        : undefined;

                    if (reusableApprovedPart) {
                        reusableApprovedPart.SubmissionRound = currentRound;
                        reusableApprovedPart.Minutes = part.Minutes;
                        reusableApprovedPart.BillableMinutes = part.BillableMinutes;
                        reusableApprovedPart.EntryCount = part.EntryCount;
                        const savedCarry = await reusableApprovedPart.Save();
                        if (!savedCarry) {
                            throw new Error(
                                reusableApprovedPart.LatestResult?.CompleteMessage ||
                                    'Failed to carry forward approved timesheet part.',
                            );
                        }
                        partSummaries.push({
                            TimesheetApprovalID: reusableApprovedPart.ID,
                            ScopeTaskID: reusableApprovedPart.ScopeTaskID,
                            ScopeTaskName: part.ScopeLabel,
                            ApprovalTaskID: reusableApprovedPart.ApprovalTaskID,
                            ApproverPersonIDs: part.ApproverPersonIDs,
                            Minutes: part.Minutes,
                            BillableMinutes: part.BillableMinutes,
                            EntryCount: part.EntryCount,
                            Status: 'Approved',
                            CarriedForward: true,
                        });
                        continue;
                    }

                    // Spawn a new approval Task in the Tasks inbox
                    const approvalTask = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                        'MJ_BizApps_Tasks: Tasks',
                        user,
                    );
                    approvalTask.NewRecord();
                    approvalTask.Name = `Timesheet: ${submitterName}, ${periodStartDay} to ${periodEndDay} · ${part.ScopeLabel}`;
                    approvalTask.Description = buildPartApprovalDescription(
                        submitterName,
                        periodStartDay,
                        periodEndDay,
                        part,
                    );
                    approvalTask.TypeID = approvalTaskTypeID!;
                    approvalTask.Status = 'Open';
                    approvalTask.Priority = 'Medium';
                    approvalTask.CreatedByPersonID = targetPersonID!;
                    if (part.ScopeTaskID) {
                        approvalTask.ParentID = part.ScopeTaskID;
                    }

                    const taskSaved = await approvalTask.Save();
                    if (!taskSaved) {
                        const msg =
                            approvalTask.LatestResult?.CompleteMessage ||
                            approvalTask.ResultHistory?.[approvalTask.ResultHistory.length - 1]?.Message ||
                            `Failed to create approval task for ${part.ScopeLabel}.`;
                        throw new Error(msg);
                    }

                    // Assign each resolved approver Person to the approval task
                    if (peopleEntityID) {
                        for (const approverPersonID of part.ApproverPersonIDs) {
                            const assignment = await provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                                'MJ_BizApps_Tasks: Task Assignments',
                                user,
                            );
                            assignment.NewRecord();
                            assignment.TaskID = approvalTask.ID;
                            assignment.AssigneeEntityID = peopleEntityID;
                            assignment.AssigneeRecordID = approverPersonID;
                            assignment.Status = 'Pending';
                            assignment.AssignedByPersonID = targetPersonID!;
                            const asgnSaved = await assignment.Save();
                            if (!asgnSaved) {
                                const msg =
                                    assignment.LatestResult?.CompleteMessage ||
                                    `Failed to assign approver ${approverPersonID} to approval task.`;
                                throw new Error(msg);
                            }
                        }
                    }

                    // Create the TimesheetApproval row for this round
                    const partEntity = await provider.GetEntityObject<mjBizAppsTasksTimesheetApprovalEntity>(
                        'MJ_BizApps_Tasks: Timesheet Approvals',
                        user,
                    );
                    partEntity.NewRecord();
                    partEntity.TimesheetID = timesheet.ID;
                    partEntity.SubmissionRound = currentRound;
                    partEntity.ScopeTaskID = part.ScopeTaskID;
                    partEntity.ApprovalTaskID = approvalTask.ID;
                    partEntity.Minutes = part.Minutes;
                    partEntity.BillableMinutes = part.BillableMinutes;
                    partEntity.EntryCount = part.EntryCount;
                    partEntity.SnapshotHash = part.SnapshotHash;
                    partEntity.Status = 'Pending';

                    const partSaved = await partEntity.Save();
                    if (!partSaved) {
                        const msg =
                            partEntity.LatestResult?.CompleteMessage ||
                            partEntity.ResultHistory?.[partEntity.ResultHistory.length - 1]?.Message ||
                            `Failed to save timesheet approval slice for ${part.ScopeLabel}.`;
                        throw new Error(msg);
                    }

                    // Link the approval task to the TimesheetApproval record via TaskLink (§6.5, §8.5)
                    if (tsApprovalEntityID) {
                        const link = await provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(
                            'MJ_BizApps_Tasks: Task Links',
                            user,
                        );
                        link.NewRecord();
                        link.TaskID = approvalTask.ID;
                        link.EntityID = tsApprovalEntityID;
                        link.RecordID = partEntity.ID;
                        link.Description = part.ScopeLabel;
                        await link.Save();
                    }

                    partSummaries.push({
                        TimesheetApprovalID: partEntity.ID,
                        ScopeTaskID: part.ScopeTaskID,
                        ScopeTaskName: part.ScopeLabel,
                        ApprovalTaskID: approvalTask.ID,
                        ApproverPersonIDs: part.ApproverPersonIDs,
                        Minutes: part.Minutes,
                        BillableMinutes: part.BillableMinutes,
                        EntryCount: part.EntryCount,
                        Status: 'Pending',
                        CarriedForward: false,
                    });
                }

                const nextStatus = TimesheetStatusFromParts(partSummaries.map((p) => p.Status));
                timesheet.Status = nextStatus;
                const finalTsSaved = await timesheet.Save();
                if (!finalTsSaved) {
                    const msg =
                        timesheet.LatestResult?.CompleteMessage ||
                        timesheet.ResultHistory?.[timesheet.ResultHistory.length - 1]?.Message ||
                        'Failed to update timesheet status.';
                    throw new Error(msg);
                }

                return {
                    Success: true,
                    Message:
                        nextStatus === 'Approved'
                            ? 'Timesheet submitted and approved (all parts carried forward).'
                            : `Timesheet submitted (${partSummaries.length} approval part(s)).`,
                    TimesheetID: timesheet.ID,
                    Status: timesheet.Status,
                    SubmissionRound: currentRound,
                    TotalMinutes: totalMinutes,
                    BillableMinutes: billableMinutes,
                    Parts: partSummaries,
                };
            });
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                Message: msg,
            };
        }
    }
}

/**
 * Server implementation of `Tasks.WithdrawTimesheet` (§6.5, §7).
 *
 * Withdraws a `Submitted` timesheet back to `Draft` so the worker can edit time entries,
 * canceling all `Pending` `TimesheetApproval` parts and their backing approval tasks inside
 * one database transaction while preserving already-`Approved` parts for the resubmit carry-forward rule.
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.WithdrawTimesheet')
export class WithdrawTimesheetOperationServer extends TasksWithdrawTimesheetOperation {
    protected override async InternalExecute(
        input: WithdrawTimesheetInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<WithdrawTimesheetOutput> {
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.TimesheetApprovalEnabled(provider)) {
            return {
                Success: false,
                Message: 'Timesheet approval is disabled for the Tasks application.',
            };
        }

        if (!input?.TimesheetID || !IsValidUUID(input.TimesheetID)) {
            return {
                Success: false,
                Message: 'A valid TimesheetID is required to withdraw a timesheet.',
            };
        }

        const rvProvider = provider as unknown as IRunViewProvider;
        const rv = new RunView(rvProvider);
        const callerPersonIDs = await PeopleForUser(provider, rvProvider, user);
        const canManage =
            UserCanManageTimesheets(user, provider) || UserCanManageTimeEntries(user, provider);

        const timesheet = await provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
            'MJ_BizApps_Tasks: Timesheets',
            user,
        );
        const loaded = await timesheet.Load(input.TimesheetID);
        if (!loaded) {
            return {
                Success: false,
                Message: 'Timesheet not found.',
            };
        }

        const isOwner = callerPersonIDs.some((id) => id.toLowerCase() === timesheet.PersonID.toLowerCase());
        if (!isOwner && !canManage) {
            return {
                Success: false,
                Message: 'Only the timesheet submitter or a timesheet manager can withdraw this timesheet.',
            };
        }

        if (timesheet.Status !== 'Submitted') {
            return {
                Success: false,
                Message: `Only a Submitted timesheet can be withdrawn (current status: ${timesheet.Status}).`,
            };
        }

        const pendingPartsRes = await rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                ExtraFilter: `TimesheetID='${timesheet.ID}' AND Status='Pending'`,
                ResultType: 'entity_object',
                BypassCache: true,
            },
            user,
        );
        const pendingParts = pendingPartsRes?.Results ?? [];

        try {
            return await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                for (const part of pendingParts) {
                    part.Status = 'Canceled';
                    part.DecidedAt = new Date();
                    if (input.Reason?.trim()) {
                        part.DecisionNotes = `Withdrawn: ${input.Reason.trim()}`;
                    }
                    const partSaved = await part.Save();
                    if (!partSaved) {
                        throw new Error(
                            part.LatestResult?.CompleteMessage ||
                                `Failed to cancel timesheet approval part ${part.ID}.`,
                        );
                    }

                    if (part.ApprovalTaskID) {
                        const approvalTask = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                            'MJ_BizApps_Tasks: Tasks',
                            user,
                        );
                        if (await approvalTask.Load(part.ApprovalTaskID)) {
                            if (approvalTask.Status !== 'Completed' && approvalTask.Status !== 'Cancelled') {
                                approvalTask.Status = 'Cancelled';
                                await approvalTask.Save();
                            }
                        }
                    }
                }

                timesheet.Status = 'Draft';
                if (input.Reason?.trim()) {
                    const withdrawNote = `[Withdrawn: ${input.Reason.trim()}]`;
                    timesheet.Notes = timesheet.Notes?.trim()
                        ? `${timesheet.Notes.trim()}\n${withdrawNote}`
                        : withdrawNote;
                }

                const tsSaved = await timesheet.Save();
                if (!tsSaved) {
                    throw new Error(
                        timesheet.LatestResult?.CompleteMessage || 'Failed to update timesheet status to Draft.',
                    );
                }

                return {
                    Success: true,
                    Message: 'Timesheet withdrawn to Draft.',
                    TimesheetID: timesheet.ID,
                    Status: timesheet.Status,
                };
            });
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                Message: msg,
            };
        }
    }
}

/**
 * Server implementation of `Tasks.ReopenTimesheet` (§6.5, §7).
 *
 * Reopens an `Approved` timesheet back to `Draft` for correction. Requires the
 * `Manage Timesheets` authorization and a non-empty `Reason`, and records a
 * `TaskActivity` audit entry on the timesheet's approval tasks.
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.ReopenTimesheet')
export class ReopenTimesheetOperationServer extends TasksReopenTimesheetOperation {
    protected override async InternalExecute(
        input: ReopenTimesheetInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<ReopenTimesheetOutput> {
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.TimesheetApprovalEnabled(provider)) {
            return {
                Success: false,
                Message: 'Timesheet approval is disabled for the Tasks application.',
            };
        }

        if (!UserCanManageTimesheets(user, provider)) {
            return {
                Success: false,
                Message: 'Reopening an approved timesheet requires the Manage Timesheets authorization.',
            };
        }

        if (!input?.TimesheetID || !IsValidUUID(input.TimesheetID)) {
            return {
                Success: false,
                Message: 'A valid TimesheetID is required to reopen a timesheet.',
            };
        }

        const reason = input.Reason?.trim() ?? '';
        if (!reason) {
            return {
                Success: false,
                Message: 'A non-empty Reason is required to reopen a timesheet.',
            };
        }

        const timesheet = await provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
            'MJ_BizApps_Tasks: Timesheets',
            user,
        );
        const loaded = await timesheet.Load(input.TimesheetID);
        if (!loaded) {
            return {
                Success: false,
                Message: 'Timesheet not found.',
            };
        }

        if (timesheet.Status !== 'Approved') {
            return {
                Success: false,
                Message: `Only an Approved timesheet can be reopened (current status: ${timesheet.Status}).`,
            };
        }

        const rvProvider = provider as unknown as IRunViewProvider;
        const rv = new RunView(rvProvider);
        const callerPersonIDs = await PeopleForUser(provider, rvProvider, user);
        const actorPersonID = callerPersonIDs[0] ?? null;

        const partsRes = await rv.RunView<mjBizAppsTasksTimesheetApprovalEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                ExtraFilter: `TimesheetID='${timesheet.ID}'`,
                OrderBy: 'SubmissionRound DESC',
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        const parts = partsRes?.Results ?? [];

        try {
            return await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                const previousStatus = timesheet.Status;
                timesheet.Status = 'Draft';
                const auditLine = `[Reopened by ${user.Name || user.Email || user.ID}: ${reason}]`;
                timesheet.Notes = timesheet.Notes?.trim()
                    ? `${timesheet.Notes.trim()}\n${auditLine}`
                    : auditLine;

                const tsSaved = await timesheet.Save();
                if (!tsSaved) {
                    throw new Error(
                        timesheet.LatestResult?.CompleteMessage || 'Failed to reopen timesheet.',
                    );
                }

                // Record a TaskActivity audit entry on the latest round's approval task(s)
                const latestRound = parts.reduce((max, p) => Math.max(max, p.SubmissionRound || 0), 0);
                const latestTaskIDs = [
                    ...new Set(
                        parts
                            .filter((p) => p.SubmissionRound === latestRound && p.ApprovalTaskID)
                            .map((p) => p.ApprovalTaskID),
                    ),
                ];

                for (const approvalTaskID of latestTaskIDs) {
                    const activity = await provider.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(
                        'MJ_BizApps_Tasks: Task Activities',
                        user,
                    );
                    activity.NewRecord();
                    activity.TaskID = approvalTaskID;
                    activity.ActivityType = 'StatusChange';
                    if (actorPersonID) {
                        activity.PersonID = actorPersonID;
                    }
                    activity.PreviousValue = previousStatus;
                    activity.NewValue = 'Draft';
                    activity.Description = `Timesheet reopened: ${reason}`;
                    await activity.Save();
                }

                return {
                    Success: true,
                    Message: 'Timesheet reopened to Draft.',
                    TimesheetID: timesheet.ID,
                    Status: timesheet.Status,
                };
            });
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                Message: msg,
            };
        }
    }
}
