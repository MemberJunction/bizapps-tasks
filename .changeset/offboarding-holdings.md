---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-entities-server": minor
---

Adds the actions "Tasks: List Offboarding Holdings" and "Tasks: Reassign Offboarding Holdings" in the "Offboarding Holdings" action category, so the Offboarding screen can list a departed user's open task assignments and move them to a successor. A move saves each assignment as the calling user, so the approval reassignment guard still applies, and keeps who requested the task (bc-aidp-next-golive#297). Needs bizapps-common with the "Offboarding Holdings" category.
