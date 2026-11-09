---
"@mj-biz-apps/tasks-entities": minor
---

Add the v1.11.x Metadata_Sync migration (with its PostgreSQL counterpart). It sets `EntityIDFieldName` on Task Assignments `AssigneeRecordID` and Task Links `RecordID`, so installs get the polymorphic record links that `metadata/entities/.polymorphic-fk-entity-fields.json` declares. The installer runs migrations and never reads `metadata/`, so without this migration the metadata change reached no one.
