---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-ng-widgets": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-server": minor
---

Add additive nullable `ArtifactID` foreign keys (`[__mj].[Artifact]([ID])`) and filtered non-clustered indexes (`WHERE [ArtifactID] IS NOT NULL`) to `[__mj_BizAppsTasks].[WorkReport]` (Category A MJ Doc backing) and `[__mj_BizAppsTasks].[MeetingNote]` (Category B hybrid scratchpad + publishable MJ Doc) with deterministic split-bake PostgreSQL parity, batched `ArtifactDualReadResolver` dual-read resolution, idempotent `Tasks.PublishMeetingNoteAsMJDoc` server action, and Angular `<mj-artifact-viewer-panel>` integration with legacy `Body` fallback and `'Publish as MJ Doc'` / `'Live Scratchpad'` UX.
