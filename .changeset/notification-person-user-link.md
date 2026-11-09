---
"@mj-biz-apps/tasks-server": patch
"@mj-biz-apps/tasks-ng": patch
---

Assignment, comment and overdue notifications find the user to notify for a Person through the user's own People link first: a user whose `LinkedEntityID` is People or an IS-A subtype of it and whose `LinkedEntityRecordID` is the Person. `People.LinkedUserID`, which bizapps-common deprecated and a platform that binds users through a People subtype leaves empty, is the fallback. Before, those Persons got no in-app notification. An assignee with no linked user, and a failed lookup, are now logged. Both use bizapps-common's shared resolver (`@mj-biz-apps/common-entities` 5.55.0+), which the tasks pages now use too to find the signed-in user's Person.
