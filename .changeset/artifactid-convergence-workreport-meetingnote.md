---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-server": minor
---

Add additive nullable `ArtifactID` foreign keys (`[__mj].[Artifact]([ID])`) and filtered non-clustered indexes (`WHERE [ArtifactID] IS NOT NULL`) to `[__mj_BizAppsTasks].[WorkReport]` (Category A MJ Doc backing) and `[__mj_BizAppsTasks].[MeetingNote]` (Category B hybrid scratchpad + publishable MJ Doc) with deterministic split-bake PostgreSQL parity, isolated scratch-DB CodeGen entity/schema/GraphQL updates, and non-breaking preservation of `Body`, `ProposedTasks`, and Category C tables.
