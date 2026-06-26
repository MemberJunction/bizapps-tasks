/**
 * BizAppsTasks Notification Handler
 *
 * Subscribes to MJGlobal entity events and creates in-app notifications
 * (MJ: User Notifications) for key task events:
 *
 * - Task assigned → notify the assignee
 * - Task completed → notify all assignees
 * - Task status changed to Blocked → notify all assignees
 * - Task comment created → notify all assignees except the commenter
 * - TaskType action hooks → invoke linked MJ Actions (OnAssign, OnComplete, OnOverdue, OnPercentChange)
 */
import {
    BaseEntity,
    BaseEntityEvent,
    LogError,
    LogStatus,
    Metadata,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { MJEventType, MJGlobal, MJEvent } from '@memberjunction/global';
import { Subscription } from 'rxjs';

/** Entity names we listen for */
const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const TASK_COMMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Comments';

/** The TaskType FK columns that can carry an action hook. */
type TaskTypeActionColumn =
    | 'OnAssignActionID'
    | 'OnCompleteActionID'
    | 'OnOverdueActionID'
    | 'OnPercentChangeActionID'
    | 'OnRejectActionID'
    | 'OnCancelActionID';

/** Row shape for a Person resolved to its linked MJ UserID. */
interface PersonLinkRow {
    ID: string;
    LinkedUserID: string | null;
}

/** Outcome of invoking a TaskType action hook (post-commit, non-blocking). */
type ActionHookResult = {
    /** True when an action was configured and actually invoked. */
    Invoked: boolean;
    /** Whether the invoked action reported success. Undefined when nothing was invoked. */
    Success?: boolean;
    Message?: string;
};

/**
 * Initializes the global event subscription for task notifications.
 * Call once at server startup from {@link LoadBizAppsTasksServer}.
 */
export function InitTaskNotificationHandler(): void {
    const storeKey = '___BizAppsTasks___NotificationHandler___Subscription';
    const store = MJGlobal.Instance.GetGlobalObjectStore();

    // Guard against double-subscription (bundler duplication / hot-reload)
    if (store[storeKey]) {
        return;
    }

    const subscription: Subscription = MJGlobal.Instance.GetEventListener(true).subscribe(
        (event: MJEvent) => {
            if (
                event.event === MJEventType.ComponentEvent &&
                event.eventCode === BaseEntity.BaseEventCode
            ) {
                const entityEvent = event.args as BaseEntityEvent;
                handleEntityEvent(entityEvent);
            }
        }
    );

    store[storeKey] = subscription;
    LogStatus('[BizAppsTasks] Notification handler initialized');
}

// ---------------------------------------------------------------------------
// Event Router
// ---------------------------------------------------------------------------

function handleEntityEvent(event: BaseEntityEvent): void {
    if (event.type !== 'save' || !event.baseEntity) {
        return;
    }

    const entityName = event.baseEntity.EntityInfo.Name;

    switch (entityName) {
        case TASKS_ENTITY:
            handleTaskSave(event).catch(logHandlerError('TaskSave'));
            break;
        case TASK_ASSIGNMENTS_ENTITY:
            handleAssignmentSave(event).catch(logHandlerError('AssignmentSave'));
            break;
        case TASK_COMMENTS_ENTITY:
            handleCommentSave(event).catch(logHandlerError('CommentSave'));
            break;
    }
}

function logHandlerError(handler: string): (err: unknown) => void {
    return (err: unknown) => {
        const msg = err instanceof Error ? err.message : String(err);
        LogError(`[BizAppsTasks] ${handler} notification error: ${msg}`);
    };
}

// ---------------------------------------------------------------------------
// Task Notifications (status changes)
// ---------------------------------------------------------------------------

/**
 * When a task is saved:
 * - If completed → notify all assignees: "Task completed: {name}"
 * - If blocked → notify all assignees: "Task blocked: {name}"
 * - If newly created → no notification (assignment creation handles that)
 *
 * Also invokes TaskType action hooks if configured (OnComplete, OnOverdue, OnPercentChange).
 */
async function handleTaskSave(event: BaseEntityEvent): Promise<void> {
    const task = event.baseEntity!;
    const contextUser = task.ContextCurrentUser;
    if (!contextUser) return;

    const taskID = task.Get('ID') as string;
    const taskName = task.Get('Name') as string;
    const status = task.Get('Status') as string;

    // Only notify on specific status values, and only on update (not create)
    if (event.saveSubType === 'create') {
        return;
    }

    if (status === 'Completed') {
        const userIDs = await getTaskAssigneeUserIDs(taskID, contextUser);
        if (userIDs.length > 0) {
            await createNotificationsForUsers(
                userIDs,
                `Task Completed: ${taskName}`,
                `"${taskName}" has been marked as completed.`,
                contextUser
            );
            LogStatus(`[BizAppsTasks] Sent completion notification for "${taskName}" to ${userIDs.length} assignee(s)`);
        }

        // Invoke OnComplete action if configured on TaskType
        await invokeTaskTypeAction(task, 'OnCompleteActionID', contextUser);
    }

    if (status === 'Blocked') {
        const blockedReason = task.Get('BlockedReason') as string | null;
        const userIDs = await getTaskAssigneeUserIDs(taskID, contextUser);
        if (userIDs.length > 0) {
            const reasonStr = blockedReason ? ` Reason: ${blockedReason}` : '';
            await createNotificationsForUsers(
                userIDs,
                `Task Blocked: ${taskName}`,
                `"${taskName}" has been blocked.${reasonStr}`,
                contextUser
            );
            LogStatus(`[BizAppsTasks] Sent blocked notification for "${taskName}" to ${userIDs.length} assignee(s)`);
        }
    }

    if (status === 'Cancelled') {
        // A cancellation that follows a Rejected decision is treated as a rejection,
        // firing OnReject (e.g. "return the source record to Draft"); a plain cancel
        // fires OnCancel. Both are post-commit and non-blocking.
        const rejected = await taskHasRejectedDecision(taskID, contextUser);
        await invokeTaskTypeAction(task, rejected ? 'OnRejectActionID' : 'OnCancelActionID', contextUser);
    }
}

/**
 * Returns true when the task has a TaskDecision with the 'Rejected' outcome.
 * Used to distinguish a rejection from a plain cancellation when routing hooks.
 *
 * Resolves the rejected outcome by its stable Code, then matches decisions by
 * OutcomeID — so renaming the outcome's display Name doesn't break routing.
 */
async function taskHasRejectedDecision(taskID: string, contextUser: UserInfo): Promise<boolean> {
    const rv = new RunView();
    const outcomeResult = await rv.RunView<{ ID: string }>({
        EntityName: 'MJ_BizApps_Tasks: Task Decision Outcomes',
        ExtraFilter: `Code = 'Rejected'`,
        Fields: ['ID'],
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);
    const rejectedOutcomeID = outcomeResult?.Results?.[0]?.ID;
    if (!rejectedOutcomeID) return false;

    const result = await rv.RunView<{ ID: string }>({
        EntityName: 'MJ_BizApps_Tasks: Task Decisions',
        ExtraFilter: `TaskID = '${taskID}' AND OutcomeID = '${rejectedOutcomeID}'`,
        Fields: ['ID'],
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);
    return (result?.Results?.length ?? 0) > 0;
}

// ---------------------------------------------------------------------------
// Assignment Notifications
// ---------------------------------------------------------------------------

/**
 * When a NEW task assignment is created, notify the assignee:
 * "You've been assigned: {task name}"
 *
 * Also invokes OnAssign action if configured on the task's TaskType.
 */
async function handleAssignmentSave(event: BaseEntityEvent): Promise<void> {
    if (event.saveSubType !== 'create') {
        return;
    }

    const assignment = event.baseEntity!;
    const contextUser = assignment.ContextCurrentUser;
    if (!contextUser) return;

    const assigneeRecordID = assignment.Get('AssigneeRecordID') as string;
    const taskID = assignment.Get('TaskID') as string;

    // Resolve the assignee's linked MJ UserID
    const userID = await getPersonLinkedUserID(assigneeRecordID, contextUser);
    if (!userID) return;

    // Load the task to get its name and details
    const rv = new RunView();
    const taskResult = await rv.RunView<{ Name: string; Priority: string; DueAt: string | null }>({
        EntityName: TASKS_ENTITY,
        ExtraFilter: `ID='${taskID}'`,
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);

    const task = taskResult?.Results?.[0];
    if (!task) return;

    const taskName = task.Name;
    const priority = task.Priority;
    const dueAt = task.DueAt ? formatDate(new Date(task.DueAt)) : null;
    const dueStr = dueAt ? ` Due: ${dueAt}.` : '';

    // Resolve role name if present
    const roleID = assignment.Get('RoleID') as string | null;
    let roleStr = '';
    if (roleID) {
        const roleResult = await new RunView().RunView<{ Name: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Roles',
            ExtraFilter: `ID='${roleID}'`,
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const roleName = roleResult?.Results?.[0]?.Name;
        if (roleName) roleStr = ` Role: ${roleName}.`;
    }

    await createNotificationsForUsers(
        [userID],
        `Task Assigned: ${taskName}`,
        `You've been assigned to "${taskName}". Priority: ${priority}.${roleStr}${dueStr}`,
        contextUser
    );
    LogStatus(`[BizAppsTasks] Sent assignment notification for "${taskName}"`);

    // Invoke OnAssign action if configured on the task's TaskType
    await invokeTaskTypeActionByTaskID(taskID, 'OnAssignActionID', contextUser);
}

// ---------------------------------------------------------------------------
// Comment Notifications
// ---------------------------------------------------------------------------

/**
 * When a NEW comment is created on a task, notify all assignees
 * except the comment author.
 */
async function handleCommentSave(event: BaseEntityEvent): Promise<void> {
    if (event.saveSubType !== 'create') {
        return;
    }

    const comment = event.baseEntity!;
    const contextUser = comment.ContextCurrentUser;
    if (!contextUser) return;

    const taskID = comment.Get('TaskID') as string;
    const authorPersonID = comment.Get('PersonID') as string;
    const content = comment.Get('Content') as string;
    const preview = content.length > 100 ? content.substring(0, 100) + '...' : content;

    // Get task name
    const rv = new RunView();
    const taskResult = await rv.RunView<{ Name: string }>({
        EntityName: TASKS_ENTITY,
        ExtraFilter: `ID='${taskID}'`,
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);
    const taskName = taskResult?.Results?.[0]?.Name ?? 'a task';

    // Get author name
    const authorName = await getPersonName(authorPersonID, contextUser) ?? 'Someone';

    // Get all assignee UserIDs except the author
    const allUserIDs = await getTaskAssigneeUserIDs(taskID, contextUser);
    const authorUserID = await getPersonLinkedUserID(authorPersonID, contextUser);
    const notifyUserIDs = allUserIDs.filter(id => id !== authorUserID);

    if (notifyUserIDs.length === 0) return;

    await createNotificationsForUsers(
        notifyUserIDs,
        `Comment on: ${taskName}`,
        `${authorName} commented: "${preview}"`,
        contextUser
    );
    LogStatus(`[BizAppsTasks] Sent comment notification for "${taskName}" to ${notifyUserIDs.length} assignee(s)`);
}

// ---------------------------------------------------------------------------
// TaskType Action Invocation
// ---------------------------------------------------------------------------

/**
 * Looks up the TaskType for a task entity and invokes the specified action
 * FK column if it has a value.
 *
 * Post-commit and non-blocking: the action's result is consumed (captured and
 * recorded as a TaskActivity, logged on failure) but a failed action does NOT
 * roll back the task save that triggered it.
 */
async function invokeTaskTypeAction(
    task: BaseEntity,
    actionColumn: TaskTypeActionColumn,
    contextUser: UserInfo,
): Promise<ActionHookResult> {
    const typeID = task.Get('TypeID') as string | null;
    if (!typeID) return { Invoked: false };

    const rv = new RunView();
    const typeResult = await rv.RunView<Record<TaskTypeActionColumn, string | null>>({
        EntityName: 'MJ_BizApps_Tasks: Task Types',
        ExtraFilter: `ID='${typeID}'`,
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);

    const taskType = typeResult?.Results?.[0];
    if (!taskType) return { Invoked: false };

    const actionID = taskType[actionColumn];
    if (!actionID) return { Invoked: false };

    const taskName = task.Get('Name') as string;
    try {
        // Dynamic import to avoid hard dependency on @memberjunction/actions
        const { ActionEngineServer } = await import('@memberjunction/actions');
        await ActionEngineServer.Instance.Config(false, contextUser);
        const action = ActionEngineServer.Instance.Actions.find((a: any) => a.ID === actionID);
        if (!action) {
            const msg = `Action ${actionID} not found for TaskType ${actionColumn}`;
            LogError(`[BizAppsTasks] ${msg}`);
            return { Invoked: false, Message: msg };
        }

        const result = await ActionEngineServer.Instance.RunAction({
            Action: action,
            ContextUser: contextUser,
            Params: [
                { Name: 'TaskID', Value: task.Get('ID'), Type: 'Input' },
                { Name: 'TaskName', Value: taskName, Type: 'Input' },
                { Name: 'Status', Value: task.Get('Status'), Type: 'Input' },
            ],
            Filters: [],
        });

        return interpretActionHookResult(result, actionColumn, taskName);
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        LogError(`[BizAppsTasks] Failed to invoke ${actionColumn}: ${msg}`);
        return { Invoked: true, Success: false, Message: msg };
    }
}

/**
 * Consumes an action's RunAction result: captures Success/Message and logs the
 * outcome (success via LogStatus, failure loudly via LogError). Post-commit and
 * non-blocking — a failed action does NOT roll back the task transition.
 *
 * Exported for unit testing the result-capture branch (issue #8, item 2).
 */
export function interpretActionHookResult(
    result: { Success?: boolean; Message?: string } | null | undefined,
    actionColumn: TaskTypeActionColumn,
    taskName: string,
): ActionHookResult {
    const success = result?.Success === true;
    const message = result?.Message ?? undefined;

    if (success) {
        LogStatus(`[BizAppsTasks] Invoked ${actionColumn} action for task "${taskName}"`);
    } else {
        // Loud, non-blocking: downstream failure (e.g. "return Order to Draft" failed)
        // is surfaced for operators but does not roll back the task transition.
        LogError(`[BizAppsTasks] ${actionColumn} action for task "${taskName}" reported failure: ${message ?? 'no message'}`);
    }
    return { Invoked: true, Success: success, Message: message };
}

/**
 * Convenience wrapper: loads a task by ID, then invokes a TaskType action.
 */
async function invokeTaskTypeActionByTaskID(
    taskID: string,
    actionColumn: TaskTypeActionColumn,
    contextUser: UserInfo,
): Promise<void> {
    const rv = new RunView();
    const result = await rv.RunView<BaseEntity>({
        EntityName: TASKS_ENTITY,
        ExtraFilter: `ID='${taskID}'`,
        ResultType: 'entity_object',
        MaxRows: 1,
    }, contextUser);
    const task = result?.Results?.[0];
    if (task) {
        await invokeTaskTypeAction(task, actionColumn, contextUser);
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Returns MJ UserIDs for all people assigned to a task.
 * Two-step: TaskAssignment → Person → LinkedUserID.
 */
async function getTaskAssigneeUserIDs(taskID: string, contextUser: UserInfo): Promise<string[]> {
    const rv = new RunView();

    const assignments = await rv.RunView<{ AssigneeRecordID: string }>({
        EntityName: TASK_ASSIGNMENTS_ENTITY,
        ExtraFilter: `TaskID='${taskID}'`,
        ResultType: 'simple',
    }, contextUser);

    if (!assignments?.Success || assignments.Results.length === 0) {
        return [];
    }

    const personIDs = assignments.Results.map(a => a.AssigneeRecordID);
    const inClause = personIDs.map((id: string) => `'${id}'`).join(',');

    const people = await rv.RunView<PersonLinkRow>({
        EntityName: 'MJ_BizApps_Common: People',
        ExtraFilter: `ID IN (${inClause}) AND LinkedUserID IS NOT NULL`,
        Fields: ['ID', 'LinkedUserID'],
        ResultType: 'simple',
    }, contextUser);

    if (!people?.Success) {
        return [];
    }

    return people.Results
        .map(p => p.LinkedUserID)
        .filter((id: string | null): id is string => id != null);
}

/**
 * Resolves a PersonID to their linked MJ UserID (if any).
 */
async function getPersonLinkedUserID(personID: string, contextUser: UserInfo): Promise<string | null> {
    const rv = new RunView();
    const result = await rv.RunView<PersonLinkRow>({
        EntityName: 'MJ_BizApps_Common: People',
        ExtraFilter: `ID='${personID}'`,
        Fields: ['ID', 'LinkedUserID'],
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);

    return result?.Results?.[0]?.LinkedUserID ?? null;
}

/**
 * Resolves a PersonID to their display name.
 */
async function getPersonName(personID: string, contextUser: UserInfo): Promise<string | null> {
    const rv = new RunView();
    const result = await rv.RunView<{ FirstName: string; LastName: string }>({
        EntityName: 'MJ_BizApps_Common: People',
        ExtraFilter: `ID='${personID}'`,
        Fields: ['ID', 'FirstName', 'LastName'],
        ResultType: 'simple',
        MaxRows: 1,
    }, contextUser);

    const p = result?.Results?.[0];
    return p ? `${p.FirstName} ${p.LastName}` : null;
}

/**
 * Creates an in-app notification for each UserID in the list.
 */
async function createNotificationsForUsers(
    userIDs: string[],
    title: string,
    message: string,
    contextUser: UserInfo
): Promise<void> {
    const md = new Metadata();

    const saves = userIDs.map(async (userID) => {
        const notification = await md.GetEntityObject<any>(
            'MJ: User Notifications',
            contextUser
        );
        notification.NewRecord();
        notification.Set('UserID', userID);
        notification.Set('Title', title);
        notification.Set('Message', message);
        notification.Set('Unread', true);

        const saved = await notification.Save();
        if (!saved) {
            LogError(`[BizAppsTasks] Failed to save notification for user ${userID}`);
        }
    });

    await Promise.all(saves);
}

/**
 * Formats a Date to a readable string like "Mar 12, 2026"
 */
function formatDate(date: Date): string {
    if (!(date instanceof Date) || isNaN(date.getTime())) {
        return 'TBD';
    }
    return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
    });
}
