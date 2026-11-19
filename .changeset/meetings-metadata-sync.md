---
"@mj-biz-apps/tasks-entities": minor
---

Ships the Meetings metadata to installs and upgrades in the v1.14.x Metadata_Sync migration (SQL Server and PostgreSQL): the Meetings application, row-level security filters and the UI role's grants on the meeting entities, meeting types, agenda item types, video providers (inactive), the Video Provider OAuth credential type, the meeting notes and agenda prompts, the calendar settings (empty), and the daily meeting series job. Every record is create-only, so a host's own edits are kept.
