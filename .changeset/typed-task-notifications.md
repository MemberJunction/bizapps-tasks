---
"@mj-biz-apps/tasks-server": minor
---

Task completed and task overdue notifications now carry a notification type and go through MJ's NotificationEngine, so users can filter them, mute them, and get them by email in Notification Preferences. `metadata/notification-types/` adds the "Task Completed" and "Task Overdue" types (in-app and email on by default, user preference allowed), each with an HTML email template in `metadata/templates/`. Task assignment notifications use MJ's existing "Task Assignment" type. Titles and messages are unchanged. A failed send is logged and does not stop the task's OnComplete action or the overdue job.
