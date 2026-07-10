-- ============================================================================
-- CodeGen metadata backfill (PostgreSQL only — no T-SQL counterpart)
-- ============================================================================
-- Brings __mj metadata for this app to MJ CodeGen's fixed-point state so a
-- fresh PG install is complete without running codegen, and a subsequent
-- codegen run makes no metadata changes. Mirrors the bizapps-common v5.32
-- backfill (commit 1bfe93c).
--
-- Four groups of statements, all data (no DDL):
--
-- 1. SchemaInfo (MemberJunction/MJ#2992). Tasks migrations never create a
--    SchemaInfo row, so on a fresh install CodeGen auto-creates one with
--    CanonicalSchemaName NULL — and the installer's own
--    PersistCanonicalSchemaName UPDATE fires BEFORE migrations, so it always
--    misses. Without the canonical name, generated class names and runtime
--    GraphQL type names come out lowercase (mjbizappstasks* instead of
--    mjBizAppsTasks*) and no longer match the published entity packages.
--    Pinned ID for determinism.
--
-- 2. Entity icons for the 19 app entities (CodeGen assigns these on first
--    run; shipping them keeps that run a no-op).
--
-- 3. EntityField normalization. The SS->PG migration converter translated
--    metadata literals into PG-flavored values (nvarchar->TEXT,
--    uniqueidentifier->UUID, sequences offset by 100000) that CodeGen
--    normalizes back on its first run, which in turn triggers the AI
--    form-layout categorization (Category/GeneratedFormSection). These
--    UPDATEs ship the normalized + categorized values directly. Values
--    extracted verbatim from a post-codegen v5.44 database (CodeGen's fixed
--    point on PostgreSQL).
--
-- 4. GeneratedCode registrations for the three CHECK-constraint validators
--    (Task self-dependency, template-item self-dependency, PercentComplete
--    range). Source is stored in PG constraint-text form AND with a
--    lowercase LinkedRecordPrimaryKey — that column is TEXT, and CodeGen's
--    change-detection lookup on PG is case-sensitive on it, so any other
--    casing makes CodeGen re-parse the constraint (AI call, nondeterministic
--    wording) on every fresh install. Code/Name pinned to the wording that
--    ships in @mj-biz-apps/tasks-entities.
--
-- This file is .pgonly.sql: on SQL Server none of this is needed (the schema
-- name is stored as authored and the converter never touched the metadata).
-- ============================================================================
SET standard_conforming_strings = on;

-- 1. SchemaInfo — create (fresh install) or repair (row already auto-created by CodeGen)
INSERT INTO __mj."SchemaInfo" ("ID", "SchemaName", "EntityIDMin", "EntityIDMax", "Comments", "EntityNamePrefix", "CanonicalSchemaName")
VALUES ('F0DC5870-1E8C-4235-8F7E-E21FF420D499', '__mj_bizappstasks', 1, 999999999, 'Auto-created by CodeGen. Please update EntityIDMin and EntityIDMax to appropriate values for this schema.', 'MJ_BizApps_Tasks: ', '__mj_BizAppsTasks')
ON CONFLICT ("ID") DO NOTHING;

UPDATE __mj."SchemaInfo"
SET "CanonicalSchemaName" = '__mj_BizAppsTasks',
    "EntityNamePrefix" = COALESCE("EntityNamePrefix", 'MJ_BizApps_Tasks: ')
WHERE "SchemaName" = '__mj_bizappstasks' AND "CanonicalSchemaName" IS NULL;

-- 2. Entity icons
UPDATE __mj."Entity" SET "Icon" = 'fa fa-bell' WHERE "ID" = 'a210af26-629a-4e0a-a90a-1cce33f5d095';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-bell' WHERE "ID" = 'dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-check-double' WHERE "ID" = '78ef0be0-1a0b-48d3-be06-8524e3cd7fdf';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-check-square' WHERE "ID" = 'd3868906-e957-4061-a79d-6ce7a96dc0ed';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-comments' WHERE "ID" = 'b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-link' WHERE "ID" = 'b92e802c-5c1b-486d-b021-03e47069502c';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-project-diagram' WHERE "ID" = '0662fc0f-3f2b-49c9-9be8-5b59e036044a';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tags' WHERE "ID" = '5db17493-cd0a-4633-80d4-d4a499662c76';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tags' WHERE "ID" = 'ea953d6b-524e-4a09-a842-9a0b0f1f850c';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '1e30141a-826f-4278-baa9-bbe14d29e606';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '559054c2-8f03-4a66-b4fd-70de5948ace2';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '6615ef77-83f1-49f1-b717-80ec31f77486';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '802aef11-bfe2-4b46-98b2-5febd4e35923';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = '8a30f14c-26ff-476e-8ca1-b10ead29a428';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = 'a28fdd91-d380-427e-b374-bcec56ed75b7';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = 'abfcfe68-f3aa-4401-a547-0fc01f27e3f3';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = 'b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466';
UPDATE __mj."Entity" SET "Icon" = 'fa fa-tasks' WHERE "ID" = 'df98e700-1992-442b-b93e-e47379f2ca52';

-- 3. EntityField normalization (CodeGen fixed point)
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 15, "DisplayName" = 'On Assign Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '4391ece2-8780-413a-8605-4569f84cff03';
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 16, "DisplayName" = 'On Complete Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '028bbcc5-6694-4b9f-81e8-f2b99ef72fbe';
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 17, "DisplayName" = 'On Overdue Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '39770061-f6e2-4e20-9d1a-8a9343e0f041';
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 18, "DisplayName" = 'On Percent Change Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f91576c2-90c5-407d-820f-7faeb246cfbd';
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 19, "DisplayName" = 'On Reject Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '4485192e-6dbc-4a4e-9a65-f4bc21a91daa';
UPDATE __mj."EntityField" SET "Category" = 'Action Scripts', "CodeType" = 'Other', "Sequence" = 20, "DisplayName" = 'On Cancel Action Script', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'da3ea9e6-160b-48c7-940e-567dcbf04d7a';
UPDATE __mj."EntityField" SET "Category" = 'Assignment Details', "Sequence" = 13, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '3edfbafc-eada-4557-bb45-81127ea36254';
UPDATE __mj."EntityField" SET "Category" = 'Assignment Tracking', "Sequence" = 15, "DisplayName" = 'Assigned By', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '1fd8bfab-20de-4ef1-8743-fca5eb95e28e';
UPDATE __mj."EntityField" SET "Category" = 'Author Information', "Sequence" = 10, "DisplayName" = 'Author Details', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '2f6fc89c-bb94-4778-83be-d232731db780';
UPDATE __mj."EntityField" SET "Category" = 'Automation Settings', "Sequence" = 12, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'c2e46071-908d-4452-9f75-d659d0ee9f21';
UPDATE __mj."EntityField" SET "Category" = 'Classification', "Sequence" = 10, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '4a27ab78-cb50-4895-a3c1-c04293754fe0';
UPDATE __mj."EntityField" SET "Category" = 'Classification', "Sequence" = 22, "DisplayName" = 'Type (Display)', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '5e003cc8-55fc-4401-a7d9-7687be6bd753';
UPDATE __mj."EntityField" SET "Category" = 'Classification', "Sequence" = 23, "DisplayName" = 'Category (Display)', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '411b26c4-2aec-41eb-96c1-897c92770598';
UPDATE __mj."EntityField" SET "Category" = 'Classification', "Sequence" = 9, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '39e1d13f-7f84-402d-a9e1-ec03dd2d2fd0';
UPDATE __mj."EntityField" SET "Category" = 'Decision Details', "Sequence" = 11, "DisplayName" = 'Outcome Name', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '2ede228d-162d-4a86-858e-6ab3606a4096';
UPDATE __mj."EntityField" SET "Category" = 'Decision Metadata', "Sequence" = 12, "DisplayName" = 'Decided By Name', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '51c078ed-a99e-4472-8f05-f38fd92262fe';
UPDATE __mj."EntityField" SET "Category" = 'Dependency Details', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '1c054f41-3fd6-44ae-abde-0ae1ffb7407f';
UPDATE __mj."EntityField" SET "Category" = 'Dependency Details', "Sequence" = 8, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f25c9bb2-2bc9-4893-aee3-665b2dce198c';
UPDATE __mj."EntityField" SET "Category" = 'Effort Tracking', "Sequence" = 12, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '0cf37cc9-7b64-4e9c-a79a-b7cf5be85244';
UPDATE __mj."EntityField" SET "Category" = 'Effort Tracking', "Sequence" = 13, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '7dc18266-ae9a-42f2-bf47-b406842712b8';
UPDATE __mj."EntityField" SET "Category" = 'Hierarchy', "Sequence" = 10, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a058e354-34aa-40ac-938f-80350d35bd96';
UPDATE __mj."EntityField" SET "Category" = 'Hierarchy', "Sequence" = 11, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '75a44757-69a9-4333-8e3e-5f4708bb0ce8';
UPDATE __mj."EntityField" SET "Category" = 'Notification Details', "Sequence" = 8, "DisplayName" = 'Task Details', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '95d43787-3e4a-4626-be10-1fc07ad2d772';
UPDATE __mj."EntityField" SET "Category" = 'Recipient Information', "Sequence" = 9, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '333468ec-8d96-490f-80dd-c90f9aa4025c';
UPDATE __mj."EntityField" SET "Category" = 'Related Information', "CodeType" = 'Other', "Sequence" = 10, "DisplayName" = 'Task Context', "ExtendedType" = 'Code', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '430ede8e-381e-41b8-a306-2fad2b44a526';
UPDATE __mj."EntityField" SET "Category" = 'Related Information', "CodeType" = 'Other', "Sequence" = 11, "DisplayName" = 'Person Context', "ExtendedType" = 'Code', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fca512c5-ab75-4fbb-bbc2-4499a4439826';
UPDATE __mj."EntityField" SET "Category" = 'Relationships', "Sequence" = 24, "DisplayName" = 'Parent Task (Display)', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '16bea5bd-358f-4e40-ab62-09be3478345f';
UPDATE __mj."EntityField" SET "Category" = 'Relationships', "Sequence" = 25, "DisplayName" = 'Created By (Display)', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '4ee84219-d7cb-408f-8ead-410973b487af';
UPDATE __mj."EntityField" SET "Category" = 'Relationships', "Sequence" = 26, "DisplayName" = 'Root Parent Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '3205c212-1737-4748-b232-3a64abd3c93c';
UPDATE __mj."EntityField" SET "Category" = 'Role and Responsibility', "Sequence" = 14, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '64c83f45-894f-43a0-aab1-5aa13f615813';
UPDATE __mj."EntityField" SET "Category" = 'Target Entity', "Sequence" = 9, "DisplayName" = 'Entity Details', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '0f4c45b2-8d5e-40ca-8ee1-7915db3f885e';
UPDATE __mj."EntityField" SET "Category" = 'Task Assignment', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '65dd9bd7-ac80-4b9a-8e08-b92bc37a8d37';
UPDATE __mj."EntityField" SET "Category" = 'Task Assignment', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '258256a5-3b70-4392-b4fc-f13e1892b4ca';
UPDATE __mj."EntityField" SET "Category" = 'Task Association', "Sequence" = 8, "DisplayName" = 'Task Details', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b705b24c-14e9-44df-ad99-5aded1b3d054';
UPDATE __mj."EntityField" SET "Category" = 'Task Configuration', "CodeType" = 'Other', "Sequence" = 12, "DisplayName" = 'Template Content', "ExtendedType" = 'Code', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '1b04cbb9-c18a-4bb2-956c-16f26aa85d48';
UPDATE __mj."EntityField" SET "Category" = 'Task Configuration', "Sequence" = 11, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '1e0b0b58-eeb0-483f-baa9-2c84b701562b';
UPDATE __mj."EntityField" SET "Category" = 'Task Configuration', "Sequence" = 13, "DisplayName" = 'Parent Item Metadata', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '158e5bd6-2fcf-4863-a09b-65f796dd26a5';
UPDATE __mj."EntityField" SET "Category" = 'Task Configuration', "Sequence" = 14, "DisplayName" = 'Root Parent Item', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '19fcbb42-f0c7-4b08-87f0-0a2127e0f665';
UPDATE __mj."EntityField" SET "Category" = 'Task Context', "Sequence" = 11, "DisplayName" = 'Root Comment', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e7a58455-30f8-4ac9-8d33-3abd1b91cbdc';
UPDATE __mj."EntityField" SET "Category" = 'Task Context', "Sequence" = 9, "DisplayName" = 'Task Details', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '9adda9ab-8118-4897-95f2-c42a767f5b60';
UPDATE __mj."EntityField" SET "Category" = 'Task Details', "Sequence" = 12, "DisplayName" = 'Task Description', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fd3035a9-13ab-40d2-941a-8e1178b4a797';
UPDATE __mj."EntityField" SET "Category" = 'Task Information', "Sequence" = 10, "DisplayName" = 'Task Name', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '29dac57c-41b1-4159-ad13-3dcc45a48d87';
UPDATE __mj."EntityField" SET "Category" = 'Task Information', "Sequence" = 7, "DisplayName" = 'Task Item Description', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'cf0321d6-9218-4f3e-8f19-359cde794bc9';
UPDATE __mj."EntityField" SET "Category" = 'Task Information', "Sequence" = 8, "DisplayName" = 'Depends On Task Description', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b3b55837-7701-424a-b681-535aac28dfdb';
UPDATE __mj."EntityField" SET "Category" = 'Task and Tag Details', "Sequence" = 6, "DisplayName" = 'Task Name', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '2ee80d0d-703c-44c0-843b-54a5cef8e9dd';
UPDATE __mj."EntityField" SET "Category" = 'Task and Tag Details', "Sequence" = 7, "DisplayName" = 'Tag Name', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'c2df8047-dca7-4404-a067-f679862af2d1';
UPDATE __mj."EntityField" SET "Category" = 'Timeline and Effort', "Sequence" = 8, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'c666f314-2fe0-4c7e-8cf0-33ff278cedf8';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Category Details', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f1e5f57f-ba65-427e-b888-eee83e1b030b';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Comment Content', "Sequence" = 6, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '92aee8dc-ed9d-4785-a6e1-c5d98884ed67';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Configuration', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '6ea8984b-1218-49d5-874d-2a39bec98316';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Configuration', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'bfa5d2b0-3d60-4acd-9478-e8fe5d02a820';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Notification Recipients', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a48474ec-3009-4c5b-aee6-e79b58089a2a';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Notification Recipients', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fc7e46c0-0d22-4c5d-b4c3-261829abd120';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Notification Settings', "Sequence" = 3, "DisplayName" = 'Enable Overdue Notifications', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '8e391113-9ab6-47c7-8942-29d0f50feb3b';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Task Type Definition', "Sequence" = 10, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '4383f518-7ae7-4c9e-b105-d9090fc545f1';
UPDATE __mj."EntityField" SET "Type" = 'bit', "Category" = 'Template Details', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'cb57cbf3-7b0e-4887-a963-a8137cde2ecc';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Assignment Tracking', "Sequence" = 9, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '5b7c8acc-6fd6-4f9b-84b6-f76fdc4d90fc';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Decision Metadata', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'd00f04d1-2af0-439a-806a-eae9e4321fb8';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 10, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '27f4d591-4acd-4bfe-9ab4-c372cb0533ea';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 10, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'bb8f8616-03dc-46f6-adb9-7d9e7be99b16';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 10, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fb020b7b-8d60-47e2-8324-240939f0c6bb';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 11, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '2f422608-152f-4983-83a5-3fd9fe5ce6fb';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 11, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '3b6a900c-646f-4a98-8f4b-bc7ae54a9c7a';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 11, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '5557c90b-7a7d-4fa6-910d-001917ed428c';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 12, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a4cc3d1e-96ac-4ec7-98cf-f83862215617';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 20, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'da16a787-212a-43bd-87e4-4d239f3eb12c';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 21, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '8711f2ad-0bdc-4398-819f-f87f1d11f34a';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 4, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '7f95d5bb-dd93-4ce0-aed7-efc073c716e0';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 4, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'accdd736-3097-4d1b-beab-9348e293caee';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '0a81c770-5ca1-43f2-8db0-285000a6ea96';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '0ab7cb59-83f6-4fd4-a8c8-38ecac388bce';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '0e9937e4-7665-409f-bdb1-9d048f24f518';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '997bf65f-dc1a-43a7-80c1-1dc1548e76dc';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f34358ef-69fa-43a8-b8df-dd57791fc52c';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 5, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f5cbafd5-b5a2-4bc5-9f6a-a932d86a75fb';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '07c7da46-0821-4bf1-a3af-007dc980c481';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '45ab032f-dbe5-4191-9635-f20bf7d9c7ef';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '5b121d65-da07-4ea6-a988-31b38d23b528';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '7ae19b3a-b0bd-4642-89bd-f1218ce0a962';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '9eea87de-003e-4834-ae9b-07f26f79d8a8';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 6, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e4a5d9df-1767-4c10-bd52-04b8a4c8bce2';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 7, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '202fc839-4893-468d-ae6b-faab8192c75c';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 7, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '98aeae08-c9ec-4136-819a-7919625f4bba';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 7, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'f8ec6d02-e1c2-433f-a96d-9095eaac35c3';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '2436ad22-ecce-48c0-87a7-f6f7f16fd12b';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '7c4cdb23-ab35-488d-84aa-3a54f8c4112f';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a1b66759-19aa-4c40-9d3a-1ada99277416';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a772e9ac-7673-49f4-99cd-38d4a5b14f30';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'da3abe83-4369-46e2-ac33-811e32a57ff2';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fdb6e33e-431f-4097-9119-657eaca7fe5b';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 8, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a9f7291b-c6b9-4832-8cad-154a7fc34071';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '87fa3f50-65d0-4b21-968d-31120657030c';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '9cdef81f-e064-48fb-ac86-0ea86123a499';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'dd3728e2-e5c6-42a8-92d6-e71fe878dbc0';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e16ec915-fde1-452e-bf76-77ffb6f2f6c9';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'System Metadata', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e8f50401-7746-40c1-a4f9-2d21e486d611';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Timeline', "Sequence" = 10, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e50c83fb-bb14-4dab-b1a5-9bc108988d7b';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Timeline', "Sequence" = 11, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '3b2893b6-9e68-4563-b25b-feb90feff201';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Timeline', "Sequence" = 19, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '65cb1110-12e0-4e48-bed3-6bf1b2926807';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Timeline', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = 'bc607c2b-d677-41b8-b2ce-4c515e49adc0';
UPDATE __mj."EntityField" SET "Type" = 'datetimeoffset', "Category" = 'Timeline', "Sequence" = 9, "DefaultColumnWidth" = 100, "GeneratedFormSection" = 'Category' WHERE "ID" = '3c7731ea-d59c-4db0-9a48-d2c40f7eff04';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Category Details', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '3c853dc6-fa48-4948-96c3-1dc2aad4f43b';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Configuration', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '61499937-ee87-4b0e-94f0-b3abe411dcd9';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Effort Tracking', "Sequence" = 14, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '5812f201-256c-47ac-aeeb-3402fd1e9846';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Notification Settings', "Sequence" = 4, "DisplayName" = 'Grace Period (Hours)', "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a2b0dc2d-3097-4e98-9aa8-6ebbedbe84c3';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Notification Settings', "Sequence" = 5, "DisplayName" = 'Repeat Interval (Hours)', "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = 'ac16d98b-855e-44a7-adb3-fbc3dc9e055e';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Role Definition', "Sequence" = 4, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '896f23e5-bd84-4cd9-86ae-cf527c34e772';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Task Configuration', "Sequence" = 9, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = 'ee42dc30-d767-46e2-9921-db1c2b423734';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Task Details', "Sequence" = 15, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '34c579d6-1fb8-4353-8f38-e75764139826';
UPDATE __mj."EntityField" SET "Type" = 'int', "Category" = 'Timeline and Effort', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 50, "GeneratedFormSection" = 'Category' WHERE "ID" = '7d855b57-90ec-47e2-85c7-0ef700036905';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Activity Details', "Sequence" = 4, "IsNameField" = TRUE, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '7b955fc4-a91e-4cc7-8768-e6945a895df9';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Activity Details', "Sequence" = 7, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '8d1c4682-5e91-4512-9f3c-e6e87ef6f303';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Assignment Details', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'a88cb22d-56cf-4506-9ac0-22dd89c7481c';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Category Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '5965f6a3-f788-40df-b248-b02a5834db01';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Category Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '7b6a7e70-677d-4e51-a845-d70bca699dc2';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Category Details', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '90a50ded-1f30-4429-87f0-0e2669260594';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Change Log', "Sequence" = 5, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '58a3f43c-3f2c-48ee-867a-8ef9f243bb63';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Change Log', "Sequence" = 6, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'ee81848c-d188-4c1d-95cc-3b618fabf1ec';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Comment Content', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE WHERE "ID" = '8e9c502b-d745-47f1-98aa-ad6ffe691d65';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Decision Details', "Sequence" = 6, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '97659d3f-72d7-4e58-9af4-e6deeea7fa50';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Dependency Details', "Sequence" = 4, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '2dd6db6e-82f2-439d-a15f-81bbe36286df';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Dependency Details', "Sequence" = 4, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '659f9a5c-bd9c-4ef7-88be-b731541d2345';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Notification Details', "Sequence" = 3, "IsNameField" = TRUE, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '9f629abd-ec18-4fa9-9bde-c8e47938903c';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Outcome Definition', "CodeType" = 'Other', "Sequence" = 3, "ExtendedType" = 'Code', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'Exact' WHERE "ID" = '1ccf7e45-4e05-4621-ade8-dec702a85f30';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Outcome Definition', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '13307cb7-4c4c-49b1-9ddd-bc6bf31d5aa2';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Outcome Definition', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '72a08d0c-73c9-4de6-b8bd-98b6dc25b95b';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Role Definition', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '23a93766-7d80-4b7c-bc0b-ef716e8e97aa';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Role Definition', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '604eaaa7-7911-48d9-8ac4-079affa9f901';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Role and Responsibility', "Sequence" = 6, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '79f7ae2e-7760-467f-9147-02edfcd730ca';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Status and Priority', "Sequence" = 16, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '72888bfb-a442-414a-96c5-6d8b3a3aa67f';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Status and Priority', "Sequence" = 7, "DefaultValue" = '(N''Open'')', "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'Exact' WHERE "ID" = '832e90ca-b150-4b19-aace-f5385db15e64';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Status and Priority', "Sequence" = 8, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'Exact' WHERE "ID" = 'bb921c78-2bad-4b36-b7cb-e4a471372340';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Tag Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = 'c7699d28-7075-435b-8a6f-1912b09a3469';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Tag Details', "Sequence" = 3, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '3ea0a461-dd7e-43b9-9349-702376f83663';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Tag Details', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '73221c4b-0f32-4bb2-a075-6637905a8fab';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Target Entity', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '820857f0-cb09-4ebe-ac47-145b55f61814';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Association', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE WHERE "ID" = '4a24d901-943f-44f6-9476-d86bc1d65c01';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 17, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '0a2f1be2-d205-47e7-a804-679c04348efc';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '4c041cc2-d419-485c-9896-790003f638b9';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '53f5b3e8-7220-48bd-a8e7-aea68a83cb82';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = 'e0060603-e9ff-4829-a4a8-a9b2abdb6bfa';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'fbcdc553-91ed-4844-b062-192358d1acd2';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 6, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '69c1abe5-3db5-4f9c-a55a-6381d46c1cd4';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Details', "Sequence" = 7, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "IncludeInUserSearchAPI" = TRUE, "UserSearchPredicateAPI" = 'Exact' WHERE "ID" = '4e823e84-05b4-43b4-a651-693798d589a8';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Type Definition', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '00619351-6557-42b0-b412-1fc4283cb682';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Type Definition', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '231b2378-3454-4a1e-a002-412fd7c8ad75';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Type Definition', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '756bd750-22b9-40af-b38a-c59a7b93fffe';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Task Type Definition', "Sequence" = 5, "DefaultInView" = TRUE, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '55d2a288-00c8-425f-8e69-06bced11d706';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Template Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "UserSearchPredicateAPI" = 'BeginsWith' WHERE "ID" = '1b80a51f-be02-411f-b960-63ea442c9172';
UPDATE __mj."EntityField" SET "Type" = 'nvarchar', "Category" = 'Template Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '83b87f55-e9e5-4ed9-a561-5cc2a77a22ed';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Activity Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '4e49c2fd-9527-484d-97ed-2afe4ee0e3e6';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Activity Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Person' WHERE "ID" = 'c885176b-bccd-4d0a-bdfc-b624394404b4';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Assignment Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'AssigneeEntity' WHERE "ID" = '01494276-140c-474d-a810-56c05f06b47e';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Assignment Tracking', "Sequence" = 8, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'AssignedByPerson' WHERE "ID" = 'd472964e-4aaf-44e6-a01a-e2a92aaa44da';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Author Information', "Sequence" = 4, "DisplayName" = 'Author', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Person' WHERE "ID" = 'bff49ce0-1e51-4f11-9d1d-cb1c1d014ad5';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Automation Settings', "Sequence" = 8, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OverdueAction' WHERE "ID" = '62e69520-b969-41da-88e0-58ec3afa0783';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Classification', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Category' WHERE "ID" = '9b39d77b-acec-40f7-b933-456760238d14';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Classification', "Sequence" = 4, "DisplayName" = 'Type', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Type' WHERE "ID" = '7ea597ed-da32-4cbc-a774-ad5e1986586a';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Classification', "Sequence" = 5, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Type' WHERE "ID" = 'f3908c0c-6c75-4a8d-8c7f-38c9535bffc2';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Classification', "Sequence" = 5, "DisplayName" = 'Category', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Category' WHERE "ID" = '4e328156-a0ff-4d3f-8c01-c75b89f235a6';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Decision Details', "Sequence" = 3, "DisplayName" = 'Outcome', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Outcome' WHERE "ID" = '1f74f328-548c-418d-ac2b-ade7cd40907c';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Decision Metadata', "Sequence" = 4, "DisplayName" = 'Decided By Person', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'DecidedByPerson' WHERE "ID" = 'de230ab6-50c3-47ee-9bd8-761caac10a01';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Dependency Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '9ccc0485-5b84-4120-9e9b-4d1a89999973';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Dependency Details', "Sequence" = 2, "DisplayName" = 'Task Item', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Item' WHERE "ID" = '910121c9-19bf-4a58-b76a-491cce751333';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Dependency Details', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'DependsOnTask' WHERE "ID" = '0704ad59-838f-49d6-9891-c5930c890258';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Dependency Details', "Sequence" = 3, "DisplayName" = 'Depends On Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'DependsOnItem' WHERE "ID" = 'f3ec22f4-d9cd-4c05-a31d-84efdc3d30de';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Hierarchy', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Parent' WHERE "ID" = '4da0eec6-3dc7-404c-9694-a65e1b58093c';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Notification Details', "Sequence" = 2, "DisplayName" = 'Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = 'e1e634a8-e437-4cf7-9c01-9272a0fd5c35';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Recipient Information', "Sequence" = 4, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'NotifiedUser' WHERE "ID" = '66bd853f-28ca-4592-8409-c114efb477a2';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Relationships', "Sequence" = 18, "DisplayName" = 'Created By', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'CreatedByPerson' WHERE "ID" = '0259c564-2dfe-480b-9075-3fd4c71fa46c';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Relationships', "Sequence" = 2, "DisplayName" = 'Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '34a075ff-ea19-4045-89bb-8fe767ecdbf6';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Relationships', "Sequence" = 3, "DisplayName" = 'Tag', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Tag' WHERE "ID" = 'e2740c12-01c0-4f86-ada4-f0cea1180dac';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Relationships', "Sequence" = 6, "DisplayName" = 'Parent Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Parent' WHERE "ID" = 'd419fc58-9802-454e-8d34-1dfaebee7df4';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Role and Responsibility', "Sequence" = 5, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Role' WHERE "ID" = '0b8e91bf-8429-46c3-acae-d930b6c032e8';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '062009d5-6662-48ce-8db6-ee9b68ef38c2';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '133050ee-20cf-45b3-a567-2aa95c0019f2';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '1d9ba99a-0cb9-4a1b-a1a9-3d4de2324cde';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '36aa7f8f-44bf-4d37-a1c7-e446d7e95094';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '39289af3-6bb0-4697-981b-8f39c47feed1';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '45ca153f-265a-4ac1-82f3-2ee0f76a0c91';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '6c4a40da-0866-4ca0-9f7d-12ec6064aef1';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '6fac4bfe-77ae-4f46-902b-467acffdc4f5';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '7ffa1073-b7a2-46df-a943-d10da3673c9b';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '94fceabf-a622-4502-820a-9e1f1533567d';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '99b41590-910a-448b-ad24-1e0f5585da26';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '9a5d15d2-bf9c-4566-9cb3-127c036a2297';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '9e1a5e43-07a2-4f96-bca6-0c47444ecff9';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b0210863-91b0-4b0b-a277-f5b2f85fac80';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b5d4a231-3f9f-45f8-b1e5-3b0fccabfe8b';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b8ad1f96-886c-4903-8d8d-fbebb27bb506';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'c2856d8e-31d8-4f13-a94a-2254c7427c69';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e59d0690-163e-433c-b408-df6ae4ec4747';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'System Metadata', "Sequence" = 1, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'e5f115d0-a541-463b-87d1-224fb396e4cf';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Target Entity', "Sequence" = 3, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Entity' WHERE "ID" = '2dee15ab-8820-448f-b3ce-ae79a8b82b6f';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Assignment', "Sequence" = 2, "DisplayName" = 'Task Item', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Item' WHERE "ID" = '64a2358a-484a-4c2a-989b-2687daa39fad';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Assignment', "Sequence" = 3, "DisplayName" = 'Role', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Role' WHERE "ID" = 'fc504621-f102-43fa-b6af-820e0fd0c366';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Association', "Sequence" = 2, "DisplayName" = 'Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = 'c6e39edf-d1b0-4571-9a35-22a4d7fd595e';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Configuration', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'TaskType' WHERE "ID" = '3a3dc1ee-3b5d-4ecb-9e63-fb061c37951f';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Configuration', "Sequence" = 2, "DisplayName" = 'Template', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Template' WHERE "ID" = '2e782cec-cbdf-4ff0-ad79-254e2e2a6c62';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Configuration', "Sequence" = 5, "DisplayName" = 'Parent Item', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'ParentItem' WHERE "ID" = '97d8e900-6af3-4a75-92da-1eaa66984aae';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Context', "Sequence" = 2, "DisplayName" = 'Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '1b0590eb-d333-46e2-ba4c-2328430fd472';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Context', "Sequence" = 3, "DisplayName" = 'Parent Comment', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = '926de279-27ff-43d5-9f02-cb5c8cb25ed5';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Details', "Sequence" = 2, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '8d982a22-f541-479b-ad71-e30667f21e32';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Information', "Sequence" = 2, "DisplayName" = 'Task', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'Task' WHERE "ID" = '16b9251a-bcb9-454b-99bc-29cb6c39d590';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Task Information', "Sequence" = 7, "DisplayName" = 'Task Assignment', "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category' WHERE "ID" = 'b075c87d-5e21-4b94-b77a-cc5d2e59d909';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 13, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnRejectAction' WHERE "ID" = '04b4f98d-f79d-4a84-9f63-fb5ffac014d5';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 14, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnCancelAction' WHERE "ID" = 'a86f3057-5e26-450f-a958-2c1f63dd2a88';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 6, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnAssignAction' WHERE "ID" = '2352e1f5-18ca-4495-85da-516fefc20463';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 7, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnCompleteAction' WHERE "ID" = '31f3f7cc-c0d0-4dd9-84f1-255bdb54dfae';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 8, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnOverdueAction' WHERE "ID" = '86e954fa-9304-49f6-ad53-7ea09875fd87';
UPDATE __mj."EntityField" SET "Type" = 'uniqueidentifier', "Category" = 'Workflow Actions', "Sequence" = 9, "DefaultColumnWidth" = 150, "GeneratedFormSection" = 'Category', "RelatedEntityNameFieldMap" = 'OnPercentChangeAction' WHERE "ID" = 'd6d015d3-c9d9-4eac-b17c-4ead902b6322';

-- 4. GeneratedCode validator registrations
INSERT INTO __mj."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
SELECT '62EB2902-A88E-4429-B524-9578F855E1E2', c."ID", 'C43229F6-4CC8-4838-9D04-03419A2DA191', NOW(), 'TypeScript', 'Approved', 'CHECK (("TaskID" <> "DependsOnTaskID"))', 'public ValidateTaskNotDependentOnSelf(result: ValidationResult) {
	if (this.TaskID != null && this.DependsOnTaskID != null && this.TaskID === this.DependsOnTaskID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnTaskID",
			"A task cannot depend on itself. The Task ID and Depends On Task ID must be different.",
			this.DependsOnTaskID,
			ValidationErrorType.Failure
		));
	}
}', 'A task cannot depend on itself. The task ID and the dependent task ID must be different to prevent self-referencing dependencies.', 'ValidateTaskNotDependentOnSelf', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '0662fc0f-3f2b-49c9-9be8-5b59e036044a'
FROM __mj."vwGeneratedCodeCategories" c WHERE c."Name" = 'CodeGen: Validators'
ON CONFLICT ("ID") DO NOTHING;

INSERT INTO __mj."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
SELECT 'F38DC251-074D-4395-8730-FB820C72DEF3', c."ID", 'C43229F6-4CC8-4838-9D04-03419A2DA191', NOW(), 'TypeScript', 'Approved', 'CHECK (("ItemID" <> "DependsOnItemID"))', 'public ValidateItemIDNotEqualToDependsOnItemID(result: ValidationResult) {
	if (this.ItemID != null && this.DependsOnItemID != null && this.ItemID === this.DependsOnItemID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnItemID",
			"An item cannot depend on itself. The Item ID and Depends On Item ID must be different.",
			this.DependsOnItemID,
			ValidationErrorType.Failure
		));
	}
}', 'An item cannot depend on itself. The item and the item it depends on must be different to prevent circular or self-referencing dependencies.', 'ValidateItemIDNotEqualToDependsOnItemID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '8a30f14c-26ff-476e-8ca1-b10ead29a428'
FROM __mj."vwGeneratedCodeCategories" c WHERE c."Name" = 'CodeGen: Validators'
ON CONFLICT ("ID") DO NOTHING;

INSERT INTO __mj."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
SELECT '9D64CD2B-7E1F-42A5-A676-38A941866BAB', c."ID", 'C43229F6-4CC8-4838-9D04-03419A2DA191', NOW(), 'TypeScript', 'Approved', 'CHECK ((("PercentComplete" >= 0) AND ("PercentComplete" <= 100)))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
	if (this.PercentComplete != null && (this.PercentComplete < 0 || this.PercentComplete > 100)) {
		result.Errors.push(new ValidationErrorInfo(
			"PercentComplete",
			"Percent complete must be between 0 and 100.",
			this.PercentComplete,
			ValidationErrorType.Failure
		));
	}
}', 'Percent complete must be a value between 0 and 100 to ensure accurate progress tracking.', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '5812f201-256c-47ac-aeeb-3402fd1e9846'
FROM __mj."vwGeneratedCodeCategories" c WHERE c."Name" = 'CodeGen: Validators'
ON CONFLICT ("ID") DO NOTHING;

