/**
 * Sends task notifications through MJ's NotificationEngine, so each one carries a
 * notification type and the recipient's preferences for that type (in-app, email) apply.
 *
 * The engine creates the in-app row first and awaits it; email goes out afterwards and
 * its failure (no provider configured, no address on the user) is logged by the engine
 * without undoing the in-app row.
 *
 * Best-effort and never thrown: a task notification runs after the task change it reports
 * has been saved, so a failed send is logged and the caller carries on.
 */
import { LogError, UserInfo } from '@memberjunction/core';
import { NotificationEngine } from '@memberjunction/notifications';

/** `MJ: User Notification Types` record shipped in this app's `metadata/notification-types/`. */
export const TASK_COMPLETED_NOTIFICATION_TYPE = 'Task Completed';

/** `MJ: User Notification Types` record shipped in this app's `metadata/notification-types/`. */
export const TASK_OVERDUE_NOTIFICATION_TYPE = 'Task Overdue';

/** `MJ: User Notification Types` record that MJ core ships; reused rather than duplicated here. */
export const TASK_ASSIGNMENT_NOTIFICATION_TYPE = 'Task Assignment';

/** Values the type's email template renders. */
export type TaskNotificationTemplateData = Record<string, string | boolean | null>;

/** One notification, sent alike to every recipient. */
export interface TaskNotification {
    /** Name of the `MJ: User Notification Types` record. */
    TypeName: string;
    /** In-app title, and the email subject. */
    Title: string;
    /** In-app message. */
    Message: string;
    /** Data for the type's email template. */
    TemplateData: TaskNotificationTemplateData;
}

/**
 * Sends `notification` to each user. Returns how many sends the engine accepted.
 * Never throws; every failure is one log line naming the type and the user.
 */
export async function sendTaskNotifications(
    userIDs: string[],
    notification: TaskNotification,
    contextUser: UserInfo,
): Promise<number> {
    if (userIDs.length === 0) {
        return 0;
    }
    if (!(await configureEngine(notification.TypeName, contextUser))) {
        return 0;
    }
    const sent = await Promise.all(userIDs.map((userID) => sendToUser(userID, notification, contextUser)));
    return sent.filter(Boolean).length;
}

async function configureEngine(typeName: string, contextUser: UserInfo): Promise<boolean> {
    try {
        await NotificationEngine.Instance.Config(false, contextUser);
        return true;
    } catch (err) {
        LogError(`[BizAppsTasks] Could not load the notification engine; no "${typeName}" notifications sent: ${errorText(err)}`);
        return false;
    }
}

async function sendToUser(userID: string, notification: TaskNotification, contextUser: UserInfo): Promise<boolean> {
    try {
        const result = await NotificationEngine.Instance.SendNotification(
            {
                userId: userID,
                typeNameOrId: notification.TypeName,
                title: notification.Title,
                message: notification.Message,
                templateData: notification.TemplateData,
            },
            contextUser,
        );
        if (!result.success) {
            // The engine returns success: false rather than throwing, e.g. for a type the host
            // has not been seeded with yet or an in-app row that failed to save.
            const reason = (result.errors ?? []).join('; ') || 'no reason given';
            LogError(`[BizAppsTasks] "${notification.TypeName}" notification to user ${userID} was not sent: ${reason}`);
            return false;
        }
        return true;
    } catch (err) {
        LogError(`[BizAppsTasks] "${notification.TypeName}" notification to user ${userID} failed: ${errorText(err)}`);
        return false;
    }
}

function errorText(err: unknown): string {
    return err instanceof Error ? err.message : String(err);
}
