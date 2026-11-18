# @mj-biz-apps/tasks-server

Server runtime bootstrap, GraphQL resolvers, and scheduled background jobs for BizApps Tasks.

## Components

- `LoadBizAppsTasksServer()`: Bootstrap loader configuring entity subclasses, notification handlers, and services.
- `OverdueTaskNotificationJob`: Scheduled job detecting overdue tasks and raising notification events.
- `MeetingSeriesMaterializationJob` (`ScheduledJobMeetingSeriesMaterialization`): extends each active meeting series' occurrences up to the horizon (90 days unless its Configuration says `HorizonDays`). Shipped as the daily job *Tasks — Meeting Series* in `metadata/scheduled-jobs`.
- `TaskNotificationHandler`: Event listener reacting to task assignment and state changes.
- Generated GraphQL resolvers.
