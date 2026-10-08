---
"@mj-biz-apps/tasks-ng": patch
---

The Approvals, My Tasks and dashboard pages now find the signed-in user's active People record (`LinkedUserID` = the user's ID) and pass its ID. They passed the user's email address, which never matches an assignment's `AssigneeRecordID`, so both lists were empty for every user and comments added from the dashboard's detail panel stored the email as their `PersonID`. A user with no active linked People record sees a message saying so instead of an empty list. If the lookup itself fails, Approvals and My Tasks say the lookup failed rather than that the user is not linked, and the dashboard loads without a Person ID.
