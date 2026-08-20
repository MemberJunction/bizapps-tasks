# @mj-biz-apps/tasks-server

Server runtime bootstrap, GraphQL resolvers, and scheduled background jobs for BizApps Tasks.

## Components

- `LoadBizAppsTasksServer()`: Bootstrap loader configuring entity subclasses, notification handlers, and services.
- `OverdueTaskNotificationJob`: Scheduled job detecting overdue tasks and raising notification events.
- `TaskNotificationHandler`: Event listener reacting to task assignment and state changes.
- Generated GraphQL resolvers.
