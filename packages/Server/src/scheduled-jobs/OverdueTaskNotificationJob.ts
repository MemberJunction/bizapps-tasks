/**
 * Overdue Task Notification Scheduled Job
 *
 * Runs on a cron schedule (default: daily at 8 AM) to find tasks that are
 * past their DueAt and send in-app notifications to assignees and/or the
 * task creator. Optionally invokes a configured MJ Action for external
 * notification delivery (email, SMS, Teams, etc.).
 *
 * Configuration is read from the `TaskNotificationConfig` table:
 * - One row with TaskTypeID = NULL serves as the global default
 * - Per-TaskType rows override the global defaults
 *
 * Resolution order for the overdue action:
 * 1. TaskNotificationConfig with matching TaskTypeID → OverdueActionID
 * 2. TaskType.OnOverdueActionID
 * 3. TaskNotificationConfig global default → OverdueActionID
 * 4. Built-in: create MJ: User Notifications (in-app only)
 */
import { Metadata, RunView, UserInfo, ValidationResult } from '@memberjunction/core';
import { MJScheduledJobEntity } from '@memberjunction/core-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseScheduledJob, ScheduledJobExecutionContext } from '@memberjunction/scheduling-engine';
import { ScheduledJobResult, NotificationContent } from '@memberjunction/scheduling-base-types';

/** Shape of the TaskNotificationConfig rows loaded from the DB. */
interface NotificationConfig {
    ID: string;
    TaskTypeID: string | null;
    OverdueNotificationsEnabled: boolean;
    OverdueGracePeriodHours: number;
    OverdueRepeatIntervalHours: number | null;
    NotifyAssignees: boolean;
    NotifyCreator: boolean;
    OverdueActionID: string | null;
}

/** Shape of an overdue task candidate from the query. */
interface OverdueTask {
    ID: string;
    Name: string;
    TypeID: string;
    Status: string;
    Priority: string;
    DueAt: string;
    OverdueNotifiedAt: string | null;
    CreatedByPersonID: string | null;
}

/**
 * Scheduled job driver for overdue task notifications.
 *
 * Registered with the MJ scheduling engine via `@RegisterClass`.
 * The engine instantiates this class when a ScheduledJob record references
 * the `ScheduledJobOverdueTaskNotification` driver class.
 */
@RegisterClass(BaseScheduledJob, 'ScheduledJobOverdueTaskNotification')
export class OverdueTaskNotificationJob extends BaseScheduledJob {

    async Execute(context: ScheduledJobExecutionContext): Promise<ScheduledJobResult> {
        const { ContextUser } = context;

        try {
            // 1. Load all notification configs
            const { globalConfig, typeConfigs } = await this.loadConfigs(ContextUser);
            if (!globalConfig) {
                return { Success: true, Details: { message: 'No global config found, skipping', tasksNotified: 0 } };
            }

            // 2. Find overdue tasks
            const overdueTasks = await this.findOverdueTasks(globalConfig, typeConfigs, ContextUser);
            if (overdueTasks.length === 0) {
                return { Success: true, Details: { tasksNotified: 0 } };
            }

            // 3. Process each overdue task
            let notifiedCount = 0;
            for (const task of overdueTasks) {
                const config = this.resolveConfig(task.TypeID, typeConfigs, globalConfig);
                if (!config.OverdueNotificationsEnabled) continue;

                const recipients = await this.resolveRecipients(task, config, ContextUser);
                if (recipients.length === 0) continue;

                // Create in-app notifications
                await this.sendNotifications(task, recipients, ContextUser);

                // Invoke action if configured
                const actionID = await this.resolveActionID(task, config, ContextUser);
                if (actionID) {
                    await this.invokeAction(actionID, task, ContextUser);
                }

                // Log and stamp
                await this.logNotifications(task, recipients, ContextUser);
                await this.stampOverdueNotifiedAt(task.ID, ContextUser);
                notifiedCount++;
            }

            this.log(`Notified ${notifiedCount} overdue task(s)`);
            return { Success: true, Details: { tasksNotified: notifiedCount } };

        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            this.logError('Overdue task notification failed', err);
            return { Success: false, ErrorMessage: msg };
        }
    }

    ValidateConfiguration(_schedule: MJScheduledJobEntity): ValidationResult {
        // Configuration is minimal (just batchSize). Always valid.
        const result = new ValidationResult();
        result.Success = true;
        return result;
    }

    FormatNotification(_context: ScheduledJobExecutionContext, result: ScheduledJobResult): NotificationContent {
        const count = result.Details?.tasksNotified ?? 0;
        return {
            Subject: `Overdue Task Check: ${count} task(s) notified`,
            Body: count > 0
                ? `Successfully sent overdue notifications for ${count} task(s).`
                : 'No overdue tasks found that need notification.',
            Priority: count > 0 ? 'Normal' : 'Low',
        };
    }

    // ---------------------------------------------------------------
    // Config Loading
    // ---------------------------------------------------------------

    private async loadConfigs(contextUser: UserInfo): Promise<{
        globalConfig: NotificationConfig | null;
        typeConfigs: Map<string, NotificationConfig>;
    }> {
        const rv = new RunView();
        const result = await rv.RunView<NotificationConfig>({
            EntityName: 'MJ.BizApps.Tasks: Task Notification Configs',
            ResultType: 'simple',
        }, contextUser);

        let globalConfig: NotificationConfig | null = null;
        const typeConfigs = new Map<string, NotificationConfig>();

        for (const row of result?.Results ?? []) {
            if (!row.TaskTypeID) {
                globalConfig = row;
            } else {
                typeConfigs.set(row.TaskTypeID, row);
            }
        }

        return { globalConfig, typeConfigs };
    }

    private resolveConfig(
        taskTypeID: string,
        typeConfigs: Map<string, NotificationConfig>,
        globalConfig: NotificationConfig,
    ): NotificationConfig {
        return typeConfigs.get(taskTypeID) ?? globalConfig;
    }

    // ---------------------------------------------------------------
    // Overdue Task Query
    // ---------------------------------------------------------------

    private async findOverdueTasks(
        globalConfig: NotificationConfig,
        typeConfigs: Map<string, NotificationConfig>,
        contextUser: UserInfo,
    ): Promise<OverdueTask[]> {
        const rv = new RunView();
        const now = new Date();

        // Base query: overdue + not completed/cancelled
        const result = await rv.RunView<OverdueTask>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `DueAt < GETUTCDATE() AND Status NOT IN ('Completed', 'Cancelled')`,
            ResultType: 'simple',
        }, contextUser);

        // Filter by grace period and repeat interval
        return (result?.Results ?? []).filter(task => {
            const config = this.resolveConfig(task.TypeID, typeConfigs, globalConfig);
            if (!config.OverdueNotificationsEnabled) return false;

            const dueAt = new Date(task.DueAt);
            const graceCutoff = new Date(dueAt.getTime() + config.OverdueGracePeriodHours * 3600000);
            if (now < graceCutoff) return false;

            // Check repeat interval
            if (task.OverdueNotifiedAt) {
                if (!config.OverdueRepeatIntervalHours) return false; // notify once only
                const lastNotified = new Date(task.OverdueNotifiedAt);
                const nextNotifyAt = new Date(lastNotified.getTime() + config.OverdueRepeatIntervalHours * 3600000);
                if (now < nextNotifyAt) return false;
            }

            return true;
        });
    }

    // ---------------------------------------------------------------
    // Recipient Resolution
    // ---------------------------------------------------------------

    private async resolveRecipients(
        task: OverdueTask,
        config: NotificationConfig,
        contextUser: UserInfo,
    ): Promise<string[]> {
        const userIDs = new Set<string>();
        const rv = new RunView();

        // Assignees
        if (config.NotifyAssignees) {
            const assignments = await rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Assignments',
                ExtraFilter: `TaskID='${task.ID}'`,
                ResultType: 'simple',
            }, contextUser);

            const personIDs = (assignments?.Results ?? []).map((a: any) => a.AssigneeRecordID as string);
            for (const personID of personIDs) {
                const uid = await this.getLinkedUserID(personID, contextUser);
                if (uid) userIDs.add(uid);
            }
        }

        // Creator
        if (config.NotifyCreator && task.CreatedByPersonID) {
            const uid = await this.getLinkedUserID(task.CreatedByPersonID, contextUser);
            if (uid) userIDs.add(uid);
        }

        return [...userIDs];
    }

    private async getLinkedUserID(personID: string, contextUser: UserInfo): Promise<string | null> {
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Common: People',
            ExtraFilter: `ID='${personID}'`,
            Fields: ['ID', 'LinkedUserID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        return result?.Results?.[0]?.LinkedUserID ?? null;
    }

    // ---------------------------------------------------------------
    // Notification Delivery
    // ---------------------------------------------------------------

    private async sendNotifications(
        task: OverdueTask,
        userIDs: string[],
        contextUser: UserInfo,
    ): Promise<void> {
        const dueDate = new Date(task.DueAt).toLocaleDateString('en-US', {
            month: 'short', day: 'numeric', year: 'numeric',
        });
        const isReminder = !!task.OverdueNotifiedAt;
        const title = isReminder
            ? `Overdue Reminder: ${task.Name}`
            : `Task Overdue: ${task.Name}`;
        const message = `"${task.Name}" was due ${dueDate} and is still ${task.Status}. Priority: ${task.Priority}.`;

        const md = new Metadata();
        for (const userID of userIDs) {
            try {
                const notification = await md.GetEntityObject<any>('MJ: User Notifications', contextUser);
                notification.NewRecord();
                notification.Set('UserID', userID);
                notification.Set('Title', title);
                notification.Set('Message', message);
                notification.Set('Unread', true);
                await notification.Save();
            } catch {
                this.logError(`Failed to create notification for user ${userID}`);
            }
        }
    }

    // ---------------------------------------------------------------
    // Action Invocation
    // ---------------------------------------------------------------

    private async resolveActionID(
        task: OverdueTask,
        config: NotificationConfig,
        contextUser: UserInfo,
    ): Promise<string | null> {
        // 1. Config-level override
        if (config.OverdueActionID) return config.OverdueActionID;

        // 2. TaskType.OnOverdueActionID
        const rv = new RunView();
        const typeResult = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Types',
            ExtraFilter: `ID='${task.TypeID}'`,
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const onOverdueActionID = typeResult?.Results?.[0]?.OnOverdueActionID;
        if (onOverdueActionID) return onOverdueActionID;

        return null;
    }

    private async invokeAction(
        actionID: string,
        task: OverdueTask,
        contextUser: UserInfo,
    ): Promise<void> {
        try {
            const { ActionEngineServer } = await import('@memberjunction/actions');
            await ActionEngineServer.Instance.Config(false, contextUser);
            const action = ActionEngineServer.Instance.Actions.find((a: any) => a.ID === actionID);
            if (!action) {
                this.logError(`Action ${actionID} not found`);
                return;
            }

            await ActionEngineServer.Instance.RunAction({
                Action: action,
                ContextUser: contextUser,
                Params: [
                    { Name: 'TaskID', Value: task.ID, Type: 'Input' },
                    { Name: 'TaskName', Value: task.Name, Type: 'Input' },
                    { Name: 'Status', Value: task.Status, Type: 'Input' },
                    { Name: 'Priority', Value: task.Priority, Type: 'Input' },
                    { Name: 'DueAt', Value: task.DueAt, Type: 'Input' },
                ],
                Filters: [],
            });
            this.log(`Invoked overdue action for "${task.Name}"`);
        } catch (err) {
            this.logError(`Failed to invoke action ${actionID}`, err);
        }
    }

    // ---------------------------------------------------------------
    // Logging + Tracking
    // ---------------------------------------------------------------

    private async logNotifications(
        task: OverdueTask,
        userIDs: string[],
        contextUser: UserInfo,
    ): Promise<void> {
        const notificationType = task.OverdueNotifiedAt ? 'OverdueReminder' : 'Overdue';
        const md = new Metadata();

        for (const userID of userIDs) {
            try {
                const log = await md.GetEntityObject<any>('MJ.BizApps.Tasks: Task Notification Logs', contextUser);
                log.NewRecord();
                log.Set('TaskID', task.ID);
                log.Set('NotificationType', notificationType);
                log.Set('NotifiedUserID', userID);
                await log.Save();
            } catch {
                this.logError(`Failed to log notification for task ${task.ID}, user ${userID}`);
            }
        }
    }

    private async stampOverdueNotifiedAt(taskID: string, contextUser: UserInfo): Promise<void> {
        try {
            const md = new Metadata();
            const task = await md.GetEntityObject<any>('MJ.BizApps.Tasks: Tasks', contextUser);
            const { CompositeKey } = await import('@memberjunction/core');
            const pk = new CompositeKey([{ FieldName: 'ID', Value: taskID }]);
            await task.InnerLoad(pk);
            task.Set('OverdueNotifiedAt', new Date());
            await task.Save();
        } catch {
            this.logError(`Failed to stamp OverdueNotifiedAt for task ${taskID}`);
        }
    }
}
