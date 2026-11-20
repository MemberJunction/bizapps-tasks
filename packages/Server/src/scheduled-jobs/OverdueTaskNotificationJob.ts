/**
 * Overdue Task Notification Scheduled Job
 *
 * Runs on a cron schedule (default: daily at 8 AM) to find tasks that are
 * past their DueAt and send typed notifications through MJ's NotificationEngine
 * to assignees and/or the task creator. Optionally invokes a configured MJ Action
 * for external notification delivery (email, SMS, Teams, etc.).
 *
 * Configuration is read from the `TaskNotificationConfig` table:
 * - One row with TaskTypeID = NULL serves as the global default
 * - Per-TaskType rows override the global defaults
 *
 * Resolution order for the overdue action:
 * 1. TaskNotificationConfig with matching TaskTypeID → OverdueActionID
 * 2. TaskType.OnOverdueActionID
 * 3. TaskNotificationConfig global default → OverdueActionID
 * 4. Built-in: typed Task Overdue notification via NotificationEngine
 */
import { CompositeKey, Metadata, RunView, UserInfo, ValidationResult } from '@memberjunction/core';
import { MJScheduledJobEntity } from '@memberjunction/core-entities';
import { ActionEngineServer } from '@memberjunction/actions';
import { EscapeSQLString, IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { BaseScheduledJob, ScheduledJobExecutionContext } from '@memberjunction/scheduling-engine';
import { ScheduledJobResult, NotificationContent } from '@memberjunction/scheduling-base-types';
import { ResolveUserIDsForPeople } from '@mj-biz-apps/common-entities';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskNotificationLogEntity,
} from '@mj-biz-apps/tasks-entities';
import { IsRoleEntityID, ResolveUserIDsForRoles } from '../role-assignees.js';
import {
    sendTaskNotifications,
    TASK_OVERDUE_NOTIFICATION_TYPE,
} from '../notifications/sendTaskNotifications.js';

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
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
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

                // Send typed overdue notifications
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
            EntityName: 'MJ_BizApps_Tasks: Task Notification Configs',
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
        // Use portable ISO-8601 UTC timestamp literal (works on both SQL Server and PostgreSQL)
        const nowIso = now.toISOString();

        const result = await rv.RunView<OverdueTask>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `DueAt < '${nowIso}' AND Status NOT IN ('Completed', 'Cancelled')`,
            ResultType: 'simple',
        }, contextUser);

        // Filter by grace period and repeat interval
        return (result?.Results ?? []).filter(task => {
            const config = this.resolveConfig(task.TypeID, typeConfigs, globalConfig);
            if (!config.OverdueNotificationsEnabled) return false;

            const dueAt = new Date(task.DueAt);
            const graceCutoff = new Date(dueAt.getTime() + config.OverdueGracePeriodHours * 3600000);
            if (now < graceCutoff) return false;

            if (task.OverdueNotifiedAt) {
                if (!config.OverdueRepeatIntervalHours) return false;
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
        if (!IsValidUUID(task.ID)) return [];
        const personIDs: string[] = [];
        const roleUserIDs: string[] = [];
        const rv = new RunView();

        // Assignees
        if (config.NotifyAssignees) {
            const assignments = await rv.RunView<{ AssigneeEntityID: string | null; AssigneeRecordID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                ExtraFilter: `TaskID='${EscapeSQLString(task.ID)}'`,
                ResultType: 'simple',
            }, contextUser);
            const results = assignments?.Results ?? [];
            const roleIDs = results.filter(a => IsRoleEntityID(a.AssigneeEntityID)).map(a => a.AssigneeRecordID);
            try {
                roleUserIDs.push(...await ResolveUserIDsForRoles(roleIDs, contextUser));
            } catch (err) {
                this.logError(`Could not resolve the members of task ${task.ID}'s assigned roles`, err);
            }

            personIDs.push(...results.filter(a => !IsRoleEntityID(a.AssigneeEntityID)).map(a => a.AssigneeRecordID));
        }

        // Creator
        if (config.NotifyCreator && task.CreatedByPersonID) {
            personIDs.push(task.CreatedByPersonID);
        }

        const personUserIDs = await this.getLinkedUserIDs(personIDs, task.ID, contextUser);
        return [...new Set([...roleUserIDs, ...personUserIDs])];
    }

    /** The users bound to these Persons in a single batched lookup via ResolveUserIDsForPeople. */
    private async getLinkedUserIDs(personIDs: string[], taskID: string, contextUser: UserInfo): Promise<string[]> {
        const validPersonIDs = personIDs.filter(id => IsValidUUID(id));
        if (validPersonIDs.length === 0) return [];
        try {
            return [...new Set((await ResolveUserIDsForPeople(validPersonIDs, Metadata.Provider, contextUser)).values())];
        } catch (error) {
            this.logError(`Could not resolve the recipients of task ${taskID}`, error);
            return [];
        }
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

        const sent = await sendTaskNotifications(userIDs, {
            TypeName: TASK_OVERDUE_NOTIFICATION_TYPE,
            Title: title,
            Message: message,
            TemplateData: {
                taskName: task.Name,
                message,
                dueDate,
                status: task.Status,
                priority: task.Priority,
                isReminder,
            },
        }, contextUser);
        if (sent < userIDs.length) {
            this.logError(`Sent the overdue notification for task ${task.ID} to ${sent} of ${userIDs.length} recipient(s)`);
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
        if (config.OverdueActionID) return config.OverdueActionID;
        if (!task.TypeID || !IsValidUUID(task.TypeID)) return null;

        const rv = new RunView();
        const typeResult = await rv.RunView<{ OnOverdueActionID: string | null }>({
            EntityName: 'MJ_BizApps_Tasks: Task Types',
            ExtraFilter: `ID='${EscapeSQLString(task.TypeID)}'`,
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
            await ActionEngineServer.Instance.Config(false, contextUser);
            const action = ActionEngineServer.Instance.Actions.find(a => UUIDsEqual(a.ID, actionID));
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
        const notificationType: mjBizAppsTasksTaskNotificationLogEntity['NotificationType'] =
            task.OverdueNotifiedAt ? 'OverdueReminder' : 'Overdue';
        const md = new Metadata();

        for (const userID of userIDs) {
            try {
                const log = await md.GetEntityObject<mjBizAppsTasksTaskNotificationLogEntity>(
                    'MJ_BizApps_Tasks: Task Notification Logs',
                    contextUser,
                );
                log.NewRecord();
                log.TaskID = task.ID;
                log.NotificationType = notificationType;
                log.NotifiedUserID = userID;
                const saved = await log.Save();
                if (!saved) {
                    this.logError(`Failed to log notification for task ${task.ID}, user ${userID}: ${log.LatestResult?.CompleteMessage ?? 'unknown error'}`);
                }
            } catch {
                this.logError(`Failed to log notification for task ${task.ID}, user ${userID}`);
            }
        }
    }

    private async stampOverdueNotifiedAt(taskID: string, contextUser: UserInfo): Promise<void> {
        try {
            const md = new Metadata();
            const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks', contextUser);
            const pk = new CompositeKey([{ FieldName: 'ID', Value: taskID }]);
            await task.InnerLoad(pk);
            task.OverdueNotifiedAt = new Date();
            const saved = await task.Save();
            if (!saved) {
                this.logError(`Failed to stamp OverdueNotifiedAt for task ${taskID}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            }
        } catch {
            this.logError(`Failed to stamp OverdueNotifiedAt for task ${taskID}`);
        }
    }
}
