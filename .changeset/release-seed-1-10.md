---
"@mj-biz-apps/tasks-entities": minor
---

Ship the 1.10 metadata: a `Metadata_Sync` migration that seeds the Priority Objective and Key Result task types, with its PostgreSQL counterpart, and the PostgreSQL counterpart of the Task priority / OKR and Task Check In migration (native PostgreSQL CodeGen from MJ 6.1.6), so a PostgreSQL install reaches the same schema and metadata as SQL Server. The credential type, action category and action the 1.8 seed created now carry their primary keys in `metadata/`, so a push against a database that ran that seed matches them instead of trying to create them again.
