import {
    LogError,
    Metadata,
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type RunViewParams,
    type RunViewResult,
    type UserInfo,
} from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import {
    ChiefOfStaffWakeRegistry,
    COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
    COS_TASKS_INBOX_WORKSTREAM_KEY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { IsPeopleEntity, PEOPLE_ENTITY } from './UserPeople.js';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const TASK_DEPENDENCIES_ENTITY = 'MJ_BizApps_Tasks: Task Dependencies';
const USERS_ENTITY = 'MJ: Users';
const ROLES_ENTITY = 'MJ: Roles';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const AI_AGENTS_ENTITY = 'MJ: AI Agents';

function runViewCompat<T>(
    params: RunViewParams,
    user: UserInfo,
    provider?: IMetadataProvider,
    runViewProvider?: IRunViewProvider,
): Promise<RunViewResult<T>> {
    if (runViewProvider) {
        return new RunView(runViewProvider).RunView<T>(params, user);
    }
    if (provider && typeof RunView.FromMetadataProvider === 'function') {
        return RunView.FromMetadataProvider(provider).RunView<T>(params, user);
    }
    return new RunView().RunView<T>(params, user);
}

function getMetadataProvider(provider?: IMetadataProvider): IMetadataProvider {
    if (provider && typeof provider.EntityByName === 'function') {
        return provider;
    }
    return Metadata.Provider;
}

function dedupeUUIDs(ids: readonly string[]): string[] {
    const seen = new Map<string, string>();
    for (const id of ids) {
        if (!IsValidUUID(id)) continue;
        const key = NormalizeUUID(id);
        if (!seen.has(key)) {
            seen.set(key, id);
        }
    }
    return [...seen.values()];
}

/**
 * Resolves MJ UserIDs linked to one or more `MJ_BizApps_Common: People` IDs,
 * checking both `MJ: Users.LinkedEntityRecordID` and `People.LinkedUserID`.
 */
async function resolveUserIDsForPersonIDs(
    personIDs: readonly string[],
    user: UserInfo,
    provider?: IMetadataProvider,
    runViewProvider?: IRunViewProvider,
): Promise<string[]> {
    const valid = dedupeUUIDs(personIDs);
    if (valid.length === 0) return [];

    const inList = valid.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const md = getMetadataProvider(provider);
    const peopleEntityID = md?.EntityByName?.(PEOPLE_ENTITY)?.ID ?? null;

    const userFilter = peopleEntityID
        ? `LinkedEntityID = '${EscapeSQLString(peopleEntityID)}' AND LinkedEntityRecordID IN (${inList}) AND IsActive = 1`
        : `LinkedEntityRecordID IN (${inList}) AND IsActive = 1`;

    const [usersRes, peopleRes] = await Promise.all([
        runViewCompat<{ ID: string }>(
            {
                EntityName: USERS_ENTITY,
                ExtraFilter: userFilter,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 500,
            },
            user,
            provider,
            runViewProvider,
        ).catch(() => ({ Success: false, Results: [] as Array<{ ID: string }> })),
        runViewCompat<{ ID: string; LinkedUserID: string | null }>(
            {
                EntityName: PEOPLE_ENTITY,
                ExtraFilter: `ID IN (${inList}) AND LinkedUserID IS NOT NULL`,
                Fields: ['ID', 'LinkedUserID'],
                ResultType: 'simple',
                MaxRows: 500,
            },
            user,
            provider,
            runViewProvider,
        ).catch(() => ({ Success: false, Results: [] as Array<{ ID: string; LinkedUserID: string | null }> })),
    ]);

    const userIDs: string[] = [];
    if (usersRes.Success) {
        for (const row of usersRes.Results ?? []) {
            if (IsValidUUID(row.ID)) userIDs.push(row.ID);
        }
    }
    if (peopleRes.Success) {
        for (const row of peopleRes.Results ?? []) {
            if (row.LinkedUserID && IsValidUUID(row.LinkedUserID)) {
                userIDs.push(row.LinkedUserID);
            }
        }
    }
    return dedupeUUIDs(userIDs);
}

/**
 * Resolves MJ UserIDs holding one or more `MJ: Roles` IDs.
 */
async function resolveUserIDsForRoleIDs(
    roleIDs: readonly string[],
    user: UserInfo,
    provider?: IMetadataProvider,
    runViewProvider?: IRunViewProvider,
): Promise<string[]> {
    const valid = dedupeUUIDs(roleIDs);
    if (valid.length === 0) return [];

    const inList = valid.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const res = await runViewCompat<{ UserID: string }>(
        {
            EntityName: USER_ROLES_ENTITY,
            ExtraFilter: `RoleID IN (${inList})`,
            Fields: ['UserID'],
            ResultType: 'simple',
            MaxRows: 500,
        },
        user,
        provider,
        runViewProvider,
    ).catch(() => ({ Success: false, Results: [] as Array<{ UserID: string }> }));

    if (!res.Success) return [];
    return dedupeUUIDs((res.Results ?? []).map((r) => r.UserID));
}

/**
 * Resolves target human MJ UserIDs for a single `TaskAssignment` target
 * (`MJ_BizApps_Common: People`, `MJ: Roles`, or `MJ: Users`). Returns `[]` for AI Agents.
 */
export async function resolveAssigneeUserIDsForTarget(input: {
    assigneeEntityID: string | null | undefined;
    assigneeRecordID: string | null | undefined;
    actingUser: UserInfo;
    provider?: IMetadataProvider;
    runViewProvider?: IRunViewProvider;
}): Promise<string[]> {
    const recordID = (input.assigneeRecordID ?? '').trim();
    if (!IsValidUUID(recordID)) return [];

    const md = getMetadataProvider(input.provider);
    const entityID = (input.assigneeEntityID ?? '').trim();

    if (entityID) {
        const agentsEntityID = md?.EntityByName?.(AI_AGENTS_ENTITY)?.ID ?? null;
        if (agentsEntityID && UUIDsEqual(entityID, agentsEntityID)) {
            return [];
        }

        const usersEntityID = md?.EntityByName?.(USERS_ENTITY)?.ID ?? null;
        if (usersEntityID && UUIDsEqual(entityID, usersEntityID)) {
            return [recordID];
        }

        const rolesEntityID = md?.EntityByName?.(ROLES_ENTITY)?.ID ?? null;
        if (rolesEntityID && UUIDsEqual(entityID, rolesEntityID)) {
            return resolveUserIDsForRoleIDs([recordID], input.actingUser, input.provider, input.runViewProvider);
        }

        if (md && typeof md.EntityByID === 'function' && !IsPeopleEntity(md, entityID)) {
            return [];
        }
    }

    return resolveUserIDsForPersonIDs([recordID], input.actingUser, input.provider, input.runViewProvider);
}

/**
 * Resolves deduplicated human MJ UserIDs assigned to one or more tasks.
 */
export async function resolveTaskAssigneeUserIDsByTask(input: {
    taskIDs: readonly string[];
    actingUser: UserInfo;
    provider?: IMetadataProvider;
    runViewProvider?: IRunViewProvider;
}): Promise<Map<string, string[]>> {
    const result = new Map<string, string[]>();
    const validTaskIDs = dedupeUUIDs(input.taskIDs);
    if (validTaskIDs.length === 0) return result;

    const inList = validTaskIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const assignRes = await runViewCompat<{
        TaskID: string;
        AssigneeEntityID: string | null;
        AssigneeRecordID: string;
    }>(
        {
            EntityName: TASK_ASSIGNMENTS_ENTITY,
            ExtraFilter: `TaskID IN (${inList})`,
            Fields: ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID'],
            ResultType: 'simple',
            MaxRows: 1000,
        },
        input.actingUser,
        input.provider,
        input.runViewProvider,
    );
    if (!assignRes.Success || !assignRes.Results?.length) {
        return result;
    }

    const md = getMetadataProvider(input.provider);
    const rolesEntityID = md?.EntityByName?.(ROLES_ENTITY)?.ID ?? null;
    const usersEntityID = md?.EntityByName?.(USERS_ENTITY)?.ID ?? null;
    const agentsEntityID = md?.EntityByName?.(AI_AGENTS_ENTITY)?.ID ?? null;

    const personIDs = new Set<string>();
    const roleIDs = new Set<string>();

    for (const row of assignRes.Results) {
        if (!IsValidUUID(row.AssigneeRecordID)) continue;
        if (agentsEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, agentsEntityID)) {
            continue;
        }
        if (rolesEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, rolesEntityID)) {
            roleIDs.add(row.AssigneeRecordID);
        } else if (usersEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, usersEntityID)) {
            // Direct user ID handled inline below
        } else if (
            !row.AssigneeEntityID ||
            typeof md?.EntityByID !== 'function' ||
            IsPeopleEntity(md, row.AssigneeEntityID)
        ) {
            personIDs.add(row.AssigneeRecordID);
        }
    }

    // Build lookup maps per person and per role
    const personToUserIDs = new Map<string, string[]>();
    for (const pid of personIDs) {
        const uIds = await resolveUserIDsForPersonIDs([pid], input.actingUser, input.provider, input.runViewProvider);
        personToUserIDs.set(NormalizeUUID(pid), uIds);
    }

    const roleToUserIDs = new Map<string, string[]>();
    for (const rid of roleIDs) {
        const uIds = await resolveUserIDsForRoleIDs([rid], input.actingUser, input.provider, input.runViewProvider);
        roleToUserIDs.set(NormalizeUUID(rid), uIds);
    }

    for (const row of assignRes.Results) {
        if (!IsValidUUID(row.TaskID) || !IsValidUUID(row.AssigneeRecordID)) continue;
        const taskKey = NormalizeUUID(row.TaskID);
        const existing = result.get(taskKey) ?? [];

        if (agentsEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, agentsEntityID)) {
            continue;
        }
        if (usersEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, usersEntityID)) {
            existing.push(row.AssigneeRecordID);
        } else if (rolesEntityID && row.AssigneeEntityID && UUIDsEqual(row.AssigneeEntityID, rolesEntityID)) {
            existing.push(...(roleToUserIDs.get(NormalizeUUID(row.AssigneeRecordID)) ?? []));
        } else {
            existing.push(...(personToUserIDs.get(NormalizeUUID(row.AssigneeRecordID)) ?? []));
        }

        result.set(taskKey, dedupeUUIDs(existing));
    }

    return result;
}

/**
 * Post-commit Chief of Staff wake when a task assignment is created or reassigned.
 * Triggers one coalesced `tasks-inbox` wake per target human user (excluding self-assignment).
 */
export async function wakeAssigneesForTaskAssignment(input: {
    taskID: string;
    taskAssignmentID: string;
    assigneeEntityID: string | null;
    assigneeRecordID: string;
    actingUser: UserInfo;
    provider?: IMetadataProvider;
    runViewProvider?: IRunViewProvider;
}): Promise<number> {
    if (!ChiefOfStaffWakeRegistry.Instance.HasHandler) {
        return 0;
    }

    const targetUserIDs = await resolveAssigneeUserIDsForTarget({
        assigneeEntityID: input.assigneeEntityID,
        assigneeRecordID: input.assigneeRecordID,
        actingUser: input.actingUser,
        provider: input.provider,
        runViewProvider: input.runViewProvider,
    });
    const recipients = targetUserIDs.filter((id) => !UUIDsEqual(id, input.actingUser.ID));
    if (recipients.length === 0) {
        return 0;
    }

    let taskName = input.taskID;
    const taskRes = await runViewCompat<{ Name: string }>(
        {
            EntityName: TASKS_ENTITY,
            ExtraFilter: `ID = '${EscapeSQLString(input.taskID)}'`,
            Fields: ['Name'],
            MaxRows: 1,
            ResultType: 'simple',
        },
        input.actingUser,
        input.provider,
        input.runViewProvider,
    ).catch(() => ({ Success: false, Results: [] as Array<{ Name: string }> }));
    if (taskRes.Success && taskRes.Results?.[0]?.Name) {
        taskName = taskRes.Results[0].Name;
    }

    const actorLabel = input.actingUser.Name || input.actingUser.Email || 'a teammate';
    let woken = 0;
    for (const targetUserID of recipients) {
        const ok = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
            targetUserID,
            workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
            wakeReason: `Task "${taskName}" was assigned to you by ${actorLabel}.`,
            resumeState: {
                eventType: 'TaskAssigned',
                taskID: input.taskID,
                taskName,
                taskAssignmentID: input.taskAssignmentID,
                assigneeRecordID: input.assigneeRecordID,
            },
            actingUser: input.actingUser,
            metadataProvider: input.provider,
        });
        if (ok) woken++;
    }
    return woken;
}

/**
 * Post-commit Chief of Staff wake when a task directly unblocks (`Blocked` -> `Open`/`InProgress`)
 * OR completes and unblocks downstream dependent tasks. Always uses the single coalesced
 * per-user workstream key `tasks-inbox`.
 */
export async function wakeAssigneesForTaskUnblock(input: {
    taskID: string;
    taskName: string;
    oldStatus: mjBizAppsTasksTaskEntity['Status'] | null;
    newStatus: mjBizAppsTasksTaskEntity['Status'];
    actingUser: UserInfo;
    provider?: IMetadataProvider;
    runViewProvider?: IRunViewProvider;
}): Promise<number> {
    if (!ChiefOfStaffWakeRegistry.Instance.HasHandler) {
        return 0;
    }

    const isDirectUnblock =
        input.oldStatus === 'Blocked' && (input.newStatus === 'Open' || input.newStatus === 'InProgress');
    const isCompleted = input.newStatus === 'Completed' && input.oldStatus !== 'Completed';
    if (!isDirectUnblock && !isCompleted) {
        return 0;
    }

    let woken = 0;

    // 1. Direct unblock of this task
    if (isDirectUnblock) {
        const assigneesMap = await resolveTaskAssigneeUserIDsByTask({
            taskIDs: [input.taskID],
            actingUser: input.actingUser,
            provider: input.provider,
            runViewProvider: input.runViewProvider,
        });
        const userIDs = (assigneesMap.get(NormalizeUUID(input.taskID)) ?? []).filter(
            (id) => !UUIDsEqual(id, input.actingUser.ID),
        );
        for (const targetUserID of userIDs) {
            const ok = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
                targetUserID,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                wakeReason: `Task "${input.taskName}" is no longer blocked (status is now ${input.newStatus}).`,
                resumeState: {
                    eventType: 'TaskUnblocked',
                    taskID: input.taskID,
                    taskName: input.taskName,
                    previousStatus: input.oldStatus,
                    newStatus: input.newStatus,
                },
                actingUser: input.actingUser,
                metadataProvider: input.provider,
            });
            if (ok) woken++;
        }
    }

    // 2. Downstream dependency unblock when this task completes
    if (isCompleted) {
        const unblockedTasks = await findNewlyUnblockedDownstreamTasks(
            input.taskID,
            input.actingUser,
            input.provider,
            input.runViewProvider,
        );
        if (unblockedTasks.length === 0) {
            return woken;
        }

        const assigneesByTask = await resolveTaskAssigneeUserIDsByTask({
            taskIDs: unblockedTasks.map((t) => t.ID),
            actingUser: input.actingUser,
            provider: input.provider,
            runViewProvider: input.runViewProvider,
        });

        // Coalesce per target user so completing one prerequisite sends ONE tasks-inbox wake per user
        const tasksByUser = new Map<string, { targetUserID: string; tasks: Array<{ ID: string; Name: string }> }>();
        for (const dsTask of unblockedTasks) {
            const users = assigneesByTask.get(NormalizeUUID(dsTask.ID)) ?? [];
            for (const targetUserID of users) {
                const key = NormalizeUUID(targetUserID);
                const bucket = tasksByUser.get(key) ?? { targetUserID, tasks: [] };
                bucket.tasks.push(dsTask);
                tasksByUser.set(key, bucket);
            }
        }

        for (const { targetUserID, tasks } of tasksByUser.values()) {
            const first = tasks[0];
            const wakeReason =
                tasks.length === 1
                    ? `Prerequisite task "${input.taskName}" was completed, unblocking "${first.Name}".`
                    : `Prerequisite task "${input.taskName}" was completed, unblocking ${tasks.length} tasks (starting with "${first.Name}").`;
            const ok = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
                targetUserID,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                wakeReason,
                resumeState: {
                    eventType: 'TaskUnblocked',
                    taskID: first.ID,
                    taskName: first.Name,
                    unblockedCount: tasks.length,
                    completedDependencyTaskID: input.taskID,
                    completedDependencyTaskName: input.taskName,
                },
                actingUser: input.actingUser,
                metadataProvider: input.provider,
            });
            if (ok) woken++;
        }
    }

    return woken;
}

async function findNewlyUnblockedDownstreamTasks(
    completedTaskID: string,
    actingUser: UserInfo,
    provider?: IMetadataProvider,
    runViewProvider?: IRunViewProvider,
): Promise<Array<{ ID: string; Name: string }>> {
    const depsRes = await runViewCompat<{ TaskID: string }>(
        {
            EntityName: TASK_DEPENDENCIES_ENTITY,
            ExtraFilter: `DependsOnTaskID = '${EscapeSQLString(completedTaskID)}'`,
            Fields: ['TaskID'],
            MaxRows: 100,
            ResultType: 'simple',
        },
        actingUser,
        provider,
        runViewProvider,
    );
    const downstreamIDs = dedupeUUIDs((depsRes.Success ? (depsRes.Results ?? []) : []).map((d) => d.TaskID));
    if (downstreamIDs.length === 0) return [];

    const inDownstream = downstreamIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const [downstreamTasksRes, allPrereqsRes] = await Promise.all([
        runViewCompat<{ ID: string; Name: string; Status: mjBizAppsTasksTaskEntity['Status'] }>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID IN (${inDownstream}) AND Status NOT IN ('Completed', 'Cancelled')`,
                Fields: ['ID', 'Name', 'Status'],
                ResultType: 'simple',
            },
            actingUser,
            provider,
            runViewProvider,
        ),
        runViewCompat<{ TaskID: string; DependsOnTaskID: string }>(
            {
                EntityName: TASK_DEPENDENCIES_ENTITY,
                ExtraFilter: `TaskID IN (${inDownstream})`,
                Fields: ['TaskID', 'DependsOnTaskID'],
                ResultType: 'simple',
            },
            actingUser,
            provider,
            runViewProvider,
        ),
    ]);

    const openDownstream = downstreamTasksRes.Success ? (downstreamTasksRes.Results ?? []) : [];
    if (openDownstream.length === 0) return [];

    const allPrereqs = allPrereqsRes.Success ? (allPrereqsRes.Results ?? []) : [];
    const otherPrereqIDs = dedupeUUIDs(
        allPrereqs
            .map((p) => p.DependsOnTaskID)
            .filter((id) => !UUIDsEqual(id, completedTaskID)),
    );

    const incompletePrereqIDs = new Set<string>();
    if (otherPrereqIDs.length > 0) {
        const inOther = otherPrereqIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        const prereqRes = await runViewCompat<{ ID: string }>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID IN (${inOther}) AND Status <> 'Completed'`,
                Fields: ['ID'],
                ResultType: 'simple',
            },
            actingUser,
            provider,
            runViewProvider,
        );
        for (const row of prereqRes.Success ? (prereqRes.Results ?? []) : []) {
            if (IsValidUUID(row.ID)) {
                incompletePrereqIDs.add(NormalizeUUID(row.ID));
            }
        }
    }

    const unblocked: Array<{ ID: string; Name: string }> = [];
    for (const dsTask of openDownstream) {
        const taskPrereqs = allPrereqs.filter((p) => UUIDsEqual(p.TaskID, dsTask.ID));
        const stillBlocked = taskPrereqs.some(
            (p) =>
                !UUIDsEqual(p.DependsOnTaskID, completedTaskID) &&
                incompletePrereqIDs.has(NormalizeUUID(p.DependsOnTaskID)),
        );
        if (!stillBlocked) {
            unblocked.push({ ID: dsTask.ID, Name: dsTask.Name });
        }
    }
    return unblocked;
}

/**
 * Post-commit Chief of Staff wake for post-meeting transcript/note processing.
 * Triggers one coalesced `meetings-transcript` wake per onboarded meeting participant
 * (MJ's `TriggerWakeForWorkstream` automatically suppresses wakes for users without an Active policy).
 */
export async function wakeMeetingParticipantsForTranscript(input: {
    meetingID: string;
    meetingName?: string | null;
    organizerPersonID?: string | null;
    noteID?: string | null;
    eventType: 'MeetingCompleted' | 'MeetingTranscriptAttached' | 'MeetingNoteSaved';
    hasTranscriptFile: boolean;
    excludeActingUser: boolean;
    actingUser: UserInfo;
    provider?: IMetadataProvider;
    runViewProvider?: IRunViewProvider;
}): Promise<number> {
    if (!ChiefOfStaffWakeRegistry.Instance.HasHandler || !IsValidUUID(input.meetingID)) {
        return 0;
    }

    try {
        let meetingName = input.meetingName?.trim() || '';
        let organizerPersonID = input.organizerPersonID ?? null;
        let hasTranscriptFile = input.hasTranscriptFile;

        if (!meetingName || !organizerPersonID) {
            const meetingRes = await runViewCompat<{
                Name: string;
                OrganizerPersonID: string | null;
                TranscriptFileID: string | null;
            }>(
                {
                    EntityName: MEETING_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(input.meetingID)}'`,
                    Fields: ['Name', 'OrganizerPersonID', 'TranscriptFileID'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                input.actingUser,
                input.provider,
                input.runViewProvider,
            );
            const row = meetingRes.Success ? meetingRes.Results?.[0] : undefined;
            if (row) {
                if (!meetingName) meetingName = row.Name;
                if (!organizerPersonID) organizerPersonID = row.OrganizerPersonID;
                if (!hasTranscriptFile) hasTranscriptFile = Boolean(row.TranscriptFileID);
            }
        }
        if (!meetingName) meetingName = input.meetingID;

        const attendeesRes = await runViewCompat<{ PersonID: string | null; UserID: string | null }>(
            {
                EntityName: MEETING_ATTENDEE_ENTITY,
                ExtraFilter: `MeetingID = '${EscapeSQLString(input.meetingID)}'`,
                Fields: ['PersonID', 'UserID'],
                MaxRows: 200,
                ResultType: 'simple',
            },
            input.actingUser,
            input.provider,
            input.runViewProvider,
        );

        const directUserIDs: string[] = [];
        const unresolvedPersonIDs: string[] = [];

        for (const att of attendeesRes.Success ? (attendeesRes.Results ?? []) : []) {
            if (att.UserID && IsValidUUID(att.UserID)) {
                directUserIDs.push(att.UserID);
            } else if (att.PersonID && IsValidUUID(att.PersonID)) {
                unresolvedPersonIDs.push(att.PersonID);
            }
        }
        if (organizerPersonID && IsValidUUID(organizerPersonID)) {
            unresolvedPersonIDs.push(organizerPersonID);
        }

        const resolvedFromPeople =
            unresolvedPersonIDs.length > 0
                ? await resolveUserIDsForPersonIDs(
                      unresolvedPersonIDs,
                      input.actingUser,
                      input.provider,
                      input.runViewProvider,
                  )
                : [];

        const participantUserIDs = dedupeUUIDs([...directUserIDs, ...resolvedFromPeople]).filter(
            (id) => !input.excludeActingUser || !UUIDsEqual(id, input.actingUser.ID),
        );
        if (participantUserIDs.length === 0) {
            return 0;
        }

        const wakeReason =
            input.eventType === 'MeetingCompleted'
                ? `Meeting "${meetingName}" completed; check for transcript, notes, and follow-up commitments.`
                : input.eventType === 'MeetingTranscriptAttached'
                  ? `Transcript attached to meeting "${meetingName}"; ready to process notes and commitments.`
                  : `Meeting notes updated for "${meetingName}"; review extracted decisions and commitments.`;

        let woken = 0;
        for (const targetUserID of participantUserIDs) {
            const ok = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
                targetUserID,
                workstreamKey: COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
                wakeReason,
                resumeState: {
                    eventType: input.eventType,
                    meetingID: input.meetingID,
                    meetingName,
                    noteID: input.noteID ?? null,
                    hasTranscriptFile,
                },
                actingUser: input.actingUser,
                metadataProvider: input.provider,
            });
            if (ok) woken++;
        }
        return woken;
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        LogError(`[BizAppsTasks] Post-meeting transcript wake failed for meeting ${input.meetingID}: ${msg}`);
        return 0;
    }
}
