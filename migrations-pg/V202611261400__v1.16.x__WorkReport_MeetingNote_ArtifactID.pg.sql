-- @mj-pg-provenance: split-bake v1 source=V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql source-sha256=3a957234d3fb92e5f4630cef774980835e110628520b06dc5dbc0b5cc7e6ae16 mode=needs-hand-rebaked
-- ============================================================================
-- MemberJunction PostgreSQL Migration — V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql
-- Split-and-regenerate with INLINE NATIVE CodeGen baking: hand-written DDL transpiled
-- (AST dialect), metadata DML inline, and CodeGen objects (views/sprocs/triggers/grants)
-- baked natively from `mj codegen`. Applies standalone via `mj migrate` — no deploy codegen.
-- ============================================================================

-- None required: UUID defaults use the built-in gen_random_uuid() (PostgreSQL 13+).
CREATE SCHEMA IF NOT EXISTS __mj_bizappstasks;
SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

ALTER TABLE __mj_bizappstasks."WorkReport"
ADD COLUMN "ArtifactID" UUID NULL /* ============================================================================= */ /* Migration: V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql */ /* Description: */ /*   Add additive nullable [ArtifactID] UNIQUEIDENTIFIER NULL foreign keys */ /*   referencing [__mj].[Artifact]([ID]) and filtered non-clustered */ /*   indexes (WHERE [ArtifactID] IS NOT NULL) to: */ /*     1. [__mj_bizappstasks].[WorkReport] (Category A MJ Doc backing for */ /*        AI-authored executive work reports while preserving legacy Body). */ /*     2. [__mj_bizappstasks].[MeetingNote] (Category B hybrid live */ /*        scratchpad + ProposedTasks JSON with optional published MJ Doc). */ /*   Strictly additive: never drops, renames, or narrows Body, ProposedTasks, */ /*   or any existing column; leaves Category C tables (TaskComment, */ /*   TaskCheckIn, BlockedReason, Timesheet/TimeEntry) completely untouched. */ /* ============================================================================= */ /* ------------------------------------------------------------------------- */ /* 1. WorkReport: Add nullable ArtifactID FK -> __mj.Artifact(ID) */ /* ------------------------------------------------------------------------- */;

ALTER TABLE __mj_bizappstasks."WorkReport"
  ADD CONSTRAINT "FK_WorkReport_Artifact" FOREIGN KEY ("ArtifactID") REFERENCES "__mj"."Artifact" (
    "ID"
  );

CREATE INDEX "IDX_AUTO_MJ_FKEY_WorkReport_ArtifactID" ON __mj_bizappstasks."WorkReport"("ArtifactID")
WHERE
  NOT "ArtifactID" IS NULL;

COMMENT ON COLUMN __mj_bizappstasks."WorkReport"."ArtifactID" IS 'Optional foreign key to an MJ: Artifacts (MJ Doc) record backing this work report. Enables Category A MJ Doc authoring and versioning while preserving legacy Body for backward compatibility.';

ALTER TABLE __mj_bizappstasks."MeetingNote"
ADD COLUMN "ArtifactID" UUID NULL /* ------------------------------------------------------------------------- */ /* 2. MeetingNote: Add nullable ArtifactID FK -> __mj.Artifact(ID) */ /* ------------------------------------------------------------------------- */;

ALTER TABLE __mj_bizappstasks."MeetingNote"
  ADD CONSTRAINT "FK_MeetingNote_Artifact" FOREIGN KEY ("ArtifactID") REFERENCES "__mj"."Artifact" (
    "ID"
  );

CREATE INDEX "IDX_AUTO_MJ_FKEY_MeetingNote_ArtifactID" ON __mj_bizappstasks."MeetingNote"("ArtifactID")
WHERE
  NOT "ArtifactID" IS NULL;

COMMENT ON COLUMN __mj_bizappstasks."MeetingNote"."ArtifactID" IS 'Optional foreign key to an MJ: Artifacts (MJ Doc) record storing published canonical meeting minutes. Enables Category B hybrid authoring while preserving live MeetingNote.Body scratchpad and ProposedTasks JSON.';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityField" WHERE "ID" = '8bdd9f20-70ed-45e6-a38f-f83799ae8f3f' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ArtifactID')) THEN
    INSERT INTO "__mj"."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('8bdd9f20-70ed-45e6-a38f-f83799ae8f3f', 'A9038030-2DBD-48E1-9075-03ED5373B85A' /* Entity: MJ_BizApps_Tasks: Work Reports */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM "__mj"."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'), 'ArtifactID', 'Artifact ID', 'Optional foreign key to an MJ: Artifacts (MJ Doc) record backing this work report. Enables Category A MJ Doc authoring and versioning while preserving legacy Body for backward compatibility.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, 'F48D2341-8667-40BB-BCA8-87D7F80E16CD', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityField" WHERE "ID" = '13c9a065-8889-43c8-83be-209259a0bbdc' OR ("EntityID" = '02892041-B070-475D-9486-5570486DDBEC' AND "Name" = 'ArtifactID')) THEN
    INSERT INTO "__mj"."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('13c9a065-8889-43c8-83be-209259a0bbdc', '02892041-B070-475D-9486-5570486DDBEC' /* Entity: MJ_BizApps_Tasks: Meeting Notes */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM "__mj"."EntityField" WHERE "EntityID" = '02892041-B070-475D-9486-5570486DDBEC'), 'ArtifactID', 'Artifact ID', 'Optional foreign key to an MJ: Artifacts (MJ Doc) record storing published canonical meeting minutes. Enables Category B hybrid authoring while preserving live MeetingNote.Body scratchpad and ProposedTasks JSON.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, 'F48D2341-8667-40BB-BCA8-87D7F80E16CD', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityRelationship" WHERE "ID" = '442c806d-c9bf-4e23-b1c8-013f95b1a569' OR ("EntityID" = 'F48D2341-8667-40BB-BCA8-87D7F80E16CD' AND "RelatedEntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "RelatedEntityJoinField" = 'ArtifactID')) THEN
    INSERT INTO "__mj"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('442c806d-c9bf-4e23-b1c8-013f95b1a569', 'F48D2341-8667-40BB-BCA8-87D7F80E16CD', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'ArtifactID', 'One To Many', TRUE, TRUE, 8, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityRelationship" WHERE "ID" = '99541c6a-7181-4e52-9250-2fd1c9f1645b' OR ("EntityID" = 'F48D2341-8667-40BB-BCA8-87D7F80E16CD' AND "RelatedEntityID" = '02892041-B070-475D-9486-5570486DDBEC' AND "RelatedEntityJoinField" = 'ArtifactID')) THEN
    INSERT INTO "__mj"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('99541c6a-7181-4e52-9250-2fd1c9f1645b', 'F48D2341-8667-40BB-BCA8-87D7F80E16CD', '02892041-B070-475D-9486-5570486DDBEC', 'ArtifactID', 'One To Many', TRUE, TRUE, 9, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityField" WHERE "ID" = '386cd0f4-9f79-47be-95a3-9b8316a06d1c' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'Artifact')) THEN
    INSERT INTO "__mj"."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('386cd0f4-9f79-47be-95a3-9b8316a06d1c', 'A9038030-2DBD-48E1-9075-03ED5373B85A' /* Entity: MJ_BizApps_Tasks: Work Reports */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM "__mj"."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'), 'Artifact', 'Artifact', NULL, 'nvarchar', 510, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM "__mj"."EntityField" WHERE "ID" = '87be716d-1a4d-4da2-876b-3201b1ade749' OR ("EntityID" = '02892041-B070-475D-9486-5570486DDBEC' AND "Name" = 'Artifact')) THEN
    INSERT INTO "__mj"."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('87be716d-1a4d-4da2-876b-3201b1ade749', '02892041-B070-475D-9486-5570486DDBEC' /* Entity: MJ_BizApps_Tasks: Meeting Notes */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM "__mj"."EntityField" WHERE "EntityID" = '02892041-B070-475D-9486-5570486DDBEC'), 'Artifact', 'Artifact', NULL, 'nvarchar', 510, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

-- Resolve unhandled T-SQL EXEC spUpdateEntityFieldRelatedEntityNameFieldMap (native PG function)
DO $$
BEGIN
  PERFORM __mj."spUpdateEntityFieldRelatedEntityNameFieldMap"(
    p_entityfieldid             := '8bdd9f20-70ed-45e6-a38f-f83799ae8f3f'::uuid,
    p_relatedentitynamefieldmap := 'Artifact'
  );
  PERFORM __mj."spUpdateEntityFieldRelatedEntityNameFieldMap"(
    p_entityfieldid             := '13c9a065-8889-43c8-83be-209259a0bbdc'::uuid,
    p_relatedentitynamefieldmap := 'Artifact'
  );
END $$;

-- ===================== CodeGen (native PG, baked) =====================

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: Index for Foreign Keys
-- ============================================================
-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'MeetingNote'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'MeetingID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_meeting_note_meeting_id"
            ON "__mj_bizappstasks"."MeetingNote" ("MeetingID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'MeetingNote'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'AgendaItemID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_meeting_note_agenda_item_id"
            ON "__mj_bizappstasks"."MeetingNote" ("AgendaItemID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'MeetingNote'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'AuthorPersonID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_meeting_note_author_person_id"
            ON "__mj_bizappstasks"."MeetingNote" ("AuthorPersonID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'MeetingNote'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'AIPromptRunID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_meeting_note_ai_prompt_run_id"
            ON "__mj_bizappstasks"."MeetingNote" ("AIPromptRunID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'MeetingNote'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'ArtifactID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_meeting_note_artifact_id"
            ON "__mj_bizappstasks"."MeetingNote" ("ArtifactID");
    END IF;
END
$$;

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: vwMeetingNotes
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Notes
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  MeetingNote
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwMeetingNotes"
AS
SELECT
    m.*,
    mjBizAppsTasksMeeting_MeetingID."Name" AS "Meeting",
    mjBizAppsTasksMeetingAgendaItem_AgendaItemID."Name" AS "AgendaItem",
    mjBizAppsCommonPerson_AuthorPersonID."DisplayName" AS "AuthorPerson",
    MJAIPromptRun_AIPromptRunID."RunName" AS "AIPromptRun",
    MJArtifact_ArtifactID."Name" AS "Artifact"
FROM
    "__mj_bizappstasks"."MeetingNote" AS m
LEFT OUTER JOIN
    "__mj_bizappstasks"."Meeting" AS mjBizAppsTasksMeeting_MeetingID
  ON
    "m"."MeetingID" = mjBizAppsTasksMeeting_MeetingID."ID"
LEFT OUTER JOIN
    "__mj_bizappstasks"."MeetingAgendaItem" AS mjBizAppsTasksMeetingAgendaItem_AgendaItemID
  ON
    "m"."AgendaItemID" = mjBizAppsTasksMeetingAgendaItem_AgendaItemID."ID"
LEFT OUTER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_AuthorPersonID
  ON
    "m"."AuthorPersonID" = mjBizAppsCommonPerson_AuthorPersonID."ID"
LEFT OUTER JOIN
    "__mj"."AIPromptRun" AS MJAIPromptRun_AIPromptRunID
  ON
    "m"."AIPromptRunID" = MJAIPromptRun_AIPromptRunID."ID"
LEFT OUTER JOIN
    "__mj"."Artifact" AS MJArtifact_ArtifactID
  ON
    "m"."ArtifactID" = MJArtifact_ArtifactID."ID"
$vsql$;
  rec RECORD;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- 42P16: column rename/reorder/type change. CREATE OR REPLACE can't handle
  -- non-additive shape changes — must DROP CASCADE + recreate. CASCADE drops
  -- every dependent view (anything that JOINs this view in its body), so we
  -- capture each dependent's definition + grants BEFORE the drop and replay
  -- them afterward (best-effort). Without this, on a fresh-DB replay where
  -- one entity's wrapper triggers (e.g. vwAIModelTypes shape changed since
  -- baseline V202605021056), CASCADE wipes downstream views (vwAIModels)
  -- that the wrapper for this entity doesn't know how to recreate, and
  -- those views stay permanently missing.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_deps (
    schema_name TEXT,
    view_name   TEXT,
    relkind     CHAR(1),
    definition  TEXT,
    grants_sql  TEXT,
    depth       INT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_deps;

  -- Every view that DROP ... CASCADE removes: direct dependents AND theirs, transitively.
  -- Capturing only direct dependents restored vwTestRuns after a vwTestSuiteRuns regen but
  -- not vwConversations / vwConversationDetails, which select from vwTestRuns — they and their
  -- CRUD functions stayed permanently missing. depth is the LONGEST path from the target, so
  -- replaying in depth order always recreates a view after every view it reads.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_dep_oids (
    view_oid OID,
    depth    INT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_dep_oids;
  INSERT INTO _vw_regen_dep_oids (view_oid, depth)
  WITH RECURSIVE deps(view_oid, depth) AS (
      SELECT DISTINCT dc.oid, 1
      FROM pg_depend d
      JOIN pg_rewrite r ON r.oid = d.objid AND d.classid = 'pg_rewrite'::regclass
      JOIN pg_class dc ON dc.oid = r.ev_class AND dc.relkind IN ('v', 'm')
      JOIN pg_class tc ON tc.oid = d.refobjid
      JOIN pg_namespace tn ON tn.oid = tc.relnamespace
      WHERE tn.nspname = '__mj_bizappstasks'
        AND tc.relname = 'vwMeetingNotes'
        AND tc.relkind IN ('v', 'm')
        AND dc.oid <> tc.oid
    UNION
      SELECT dc.oid, deps.depth + 1
      FROM deps
      JOIN pg_depend d ON d.refobjid = deps.view_oid
      JOIN pg_rewrite r ON r.oid = d.objid AND d.classid = 'pg_rewrite'::regclass
      JOIN pg_class dc ON dc.oid = r.ev_class AND dc.relkind IN ('v', 'm')
      WHERE dc.oid <> deps.view_oid
        AND deps.depth < 50
  )
  SELECT view_oid, MAX(depth) FROM deps GROUP BY view_oid;

  -- Capture dependent FUNCTIONS too. CASCADE drops every function with
  -- RETURNS SETOF <view> (the codegen-emitted spCreate/spUpdate/spDelete
  -- pattern) when the target view is dropped. Without restoring them,
  -- post-codegen CRUD validation reports those routines as missing —
  -- e.g. "MJ: Recommendation Items → missing create routine
  -- spCreateRecommendationItem" — even though the next codegen pass
  -- emits them. The restored definitions are pg_get_functiondef() output
  -- which is a complete CREATE OR REPLACE FUNCTION statement plus a
  -- trailing semicolon; replaying them verbatim recreates the function
  -- with its original body, parameter list, and return type.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_fn_deps (
    schema_name TEXT,
    fn_name     TEXT,
    fn_oid      OID,
    definition  TEXT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_fn_deps;

  -- Capture dependents. NOTES on the grants_sql build:
  --   - Resolve role name via pg_get_userbyid(oid) — returns the bare,
  --     unquoted role name (or 'unknown (OID=N)' if the oid no longer
  --     exists). pg_get_userbyid is a public catalog function available to
  --     every database user, including unprivileged accounts on managed
  --     PostgreSQL services (Amazon RDS, Azure Database for PostgreSQL,
  --     Cloud SQL) where pg_authid is restricted to the rds_superuser /
  --     azure_pg_admin / cloudsqlsuperuser group. Earlier revisions joined
  --     to pg_authid which works on self-hosted PG but fails with
  --     "permission denied for table pg_authid" on managed services.
  --   - The earlier (broken) approach cast (aclexplode).grantee::regrole::text
  --     which RETURNS the role name pre-quoted when it contains uppercase
  --     (e.g. cdp_Developer comes back already wrapped); calling quote_ident
  --     on the already-quoted string double-wrapped and the GRANT failed at
  --     replay with "role does not exist". Using
  --     pg_get_userbyid returns a bare name and lets quote_ident wrap it
  --     correctly exactly once.
  --   - PUBLIC is grantee oid 0; pg_get_userbyid(0) returns 'unknown
  --     (OID=0)' so handle the PUBLIC case explicitly and use it as the
  --     literal 'PUBLIC' rather than quote_ident on the synthetic name.
  INSERT INTO _vw_regen_deps (schema_name, view_name, relkind, definition, grants_sql, depth)
  SELECT
      dn.nspname,
      dc.relname,
      dc.relkind,
      pg_get_viewdef(dc.oid),
      (SELECT string_agg(
          'GRANT ' || g.privilege || ' ON ' || quote_ident(dn.nspname) || '.' || quote_ident(dc.relname) ||
          ' TO ' || (CASE WHEN g.grantee_oid = 0 THEN 'PUBLIC' ELSE quote_ident(pg_get_userbyid(g.grantee_oid)) END) || ';',
          E'
')
       FROM (
           SELECT (aclexplode(dc.relacl)).grantee AS grantee_oid,
                  (aclexplode(dc.relacl)).privilege_type AS privilege
       ) g
       WHERE g.privilege IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER')),
      o.depth
  FROM _vw_regen_dep_oids o
  JOIN pg_class dc ON dc.oid = o.view_oid
  JOIN pg_namespace dn ON dn.oid = dc.relnamespace;

  -- Capture dependent functions. Two paths matter on PG:
  --   1. Functions whose RETURN type references the view (RETURNS SETOF
  --      <view>) — pg_depend records this as type=pg_type → pg_class.
  --   2. Functions whose body references the view (used by sql functions
  --      and by some plpgsql edge cases) — pg_depend records this as
  --      pg_proc → pg_class.
  -- pg_get_functiondef returns a complete CREATE OR REPLACE FUNCTION
  -- statement that we replay verbatim. We DO include RETURNS-only
  -- references because that's the dominant codegen pattern (sp* CRUD
  -- functions all RETURNS SETOF the matching vwX).
  -- The set is the target view plus every view captured above, because CASCADE drops the
  -- functions of each of them, not only the target's.
  INSERT INTO _vw_regen_fn_deps (schema_name, fn_name, fn_oid, definition)
  SELECT DISTINCT
      pn.nspname,
      pp.proname,
      pp.oid,
      pg_get_functiondef(pp.oid)
  FROM pg_proc pp
  JOIN pg_namespace pn ON pn.oid = pp.pronamespace
  WHERE pp.prokind IN ('f', 'p')
    AND EXISTS (
      SELECT 1
      FROM pg_class c
      WHERE (c.oid IN (SELECT view_oid FROM _vw_regen_dep_oids)
             OR c.oid = (SELECT tc.oid FROM pg_class tc
                         JOIN pg_namespace tn ON tn.oid = tc.relnamespace
                         WHERE tn.nspname = '__mj_bizappstasks'
                           AND tc.relname = 'vwMeetingNotes'
                           AND tc.relkind IN ('v', 'm')))
        AND (pp.prorettype = c.reltype
             OR EXISTS (SELECT 1 FROM pg_depend d
                        WHERE d.classid = 'pg_proc'::regclass
                          AND d.objid = pp.oid
                          AND d.refobjid = c.oid))
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwMeetingNotes" CASCADE;
  EXECUTE vsql;

  -- Replay captured dependents. Best-effort: log + continue on failure.
  -- IMPORTANT: the CREATE VIEW and the GRANTs run in SEPARATE inner BEGIN
  -- blocks. PL/pgSQL's BEGIN ... EXCEPTION creates an implicit savepoint
  -- and rolls back EVERY statement in the block on any exception. If we
  -- combined CREATE+GRANT in one block and a GRANT failed (e.g. role not
  -- present in target environment), the just-recreated VIEW would also
  -- get rolled back and stay missing — the exact failure mode this
  -- wrapper exists to prevent.
  FOR rec IN SELECT schema_name, view_name, relkind, definition, grants_sql FROM _vw_regen_deps ORDER BY depth, view_name LOOP
    BEGIN
      IF rec.relkind = 'm' THEN
        EXECUTE 'CREATE MATERIALIZED VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      ELSE
        EXECUTE 'CREATE VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent %.%: %', rec.schema_name, rec.view_name, SQLERRM;
    END;

    IF rec.grants_sql IS NOT NULL THEN
      BEGIN
        EXECUTE rec.grants_sql;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Best-effort grant restore skipped %.%: %', rec.schema_name, rec.view_name, SQLERRM;
      END;
    END IF;
  END LOOP;

  -- Replay captured dependent functions AFTER all dependent views are
  -- restored — most codegen-emitted sp* functions reference both the
  -- target view AND the dependent views in their bodies/return types.
  -- Wrapped per-function in its own savepoint so a single failure
  -- doesn't poison subsequent restores or the just-recreated target.
  FOR rec IN SELECT schema_name, fn_name, definition FROM _vw_regen_fn_deps LOOP
    BEGIN
      EXECUTE rec.definition;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent function %.%: %', rec.schema_name, rec.fn_name, SQLERRM;
    END;
  END LOOP;

  DROP TABLE _vw_regen_deps;
  DROP TABLE _vw_regen_dep_oids;
  DROP TABLE _vw_regen_fn_deps;
END $vw_regen$;
GRANT SELECT ON "__mj_bizappstasks"."vwMeetingNotes" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwMeetingNotes" TO "cdp_Integration";
GRANT SELECT ON "__mj_bizappstasks"."vwMeetingNotes" TO "cdp_UI";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spCreateMeetingNote
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR MeetingNote
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateMeetingNote'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateMeetingNote"(
    p_id uuid DEFAULT NULL,
    p_meetingid uuid DEFAULT NULL,
    p_agendaitemid_clear boolean DEFAULT false,
    p_agendaitemid uuid DEFAULT NULL,
    p_kind text DEFAULT NULL,
    p_title_clear boolean DEFAULT false,
    p_title text DEFAULT NULL,
    p_body text DEFAULT NULL,
    p_source text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_authorpersonid_clear boolean DEFAULT false,
    p_authorpersonid uuid DEFAULT NULL,
    p_aipromptrunid_clear boolean DEFAULT false,
    p_aipromptrunid uuid DEFAULT NULL,
    p_proposedtasks_clear boolean DEFAULT false,
    p_proposedtasks text DEFAULT NULL,
    p_artifactid_clear boolean DEFAULT false,
    p_artifactid UUID DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwMeetingNotes" AS $$
DECLARE
    v_new_id uuid;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."MeetingNote"
        (
            "ID",
            "MeetingID",
                "AgendaItemID",
                "Kind",
                "Title",
                "Body",
                "Source",
                "Status",
                "AuthorPersonID",
                "AIPromptRunID",
                "ProposedTasks",
                "ArtifactID"
        )
    VALUES
        (
            v_new_id,
            p_meetingid,
                CASE WHEN p_agendaitemid_clear = true THEN NULL ELSE COALESCE(p_agendaitemid, NULL) END,
                COALESCE(p_kind, 'Notes'),
                CASE WHEN p_title_clear = true THEN NULL ELSE COALESCE(p_title, NULL) END,
                p_body,
                COALESCE(p_source, 'Manual'),
                COALESCE(p_status, 'Draft'),
                CASE WHEN p_authorpersonid_clear = true THEN NULL ELSE COALESCE(p_authorpersonid, NULL) END,
                CASE WHEN p_aipromptrunid_clear = true THEN NULL ELSE COALESCE(p_aipromptrunid, NULL) END,
                CASE WHEN p_proposedtasks_clear = true THEN NULL ELSE COALESCE(p_proposedtasks, NULL) END,
                CASE WHEN p_artifactid_clear = true THEN NULL ELSE COALESCE(p_artifactid, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwMeetingNotes"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateMeetingNote" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateMeetingNote" TO "cdp_Integration";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateMeetingNote" TO "cdp_UI";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spUpdateMeetingNote
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR MeetingNote
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateMeetingNote'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateMeetingNote"(
    p_id uuid,
    p_meetingid uuid DEFAULT NULL,
    p_agendaitemid_clear boolean DEFAULT false,
    p_agendaitemid uuid DEFAULT NULL,
    p_kind text DEFAULT NULL,
    p_title_clear boolean DEFAULT false,
    p_title text DEFAULT NULL,
    p_body text DEFAULT NULL,
    p_source text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_authorpersonid_clear boolean DEFAULT false,
    p_authorpersonid uuid DEFAULT NULL,
    p_aipromptrunid_clear boolean DEFAULT false,
    p_aipromptrunid uuid DEFAULT NULL,
    p_proposedtasks_clear boolean DEFAULT false,
    p_proposedtasks text DEFAULT NULL,
    p_artifactid_clear boolean DEFAULT false,
    p_artifactid UUID DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwMeetingNotes" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."MeetingNote"
    SET
        "MeetingID" = COALESCE(p_meetingid, "MeetingID"),
        "AgendaItemID" = CASE WHEN p_agendaitemid_clear = true THEN NULL ELSE COALESCE(p_agendaitemid, "AgendaItemID") END,
        "Kind" = COALESCE(p_kind, "Kind"),
        "Title" = CASE WHEN p_title_clear = true THEN NULL ELSE COALESCE(p_title, "Title") END,
        "Body" = COALESCE(p_body, "Body"),
        "Source" = COALESCE(p_source, "Source"),
        "Status" = COALESCE(p_status, "Status"),
        "AuthorPersonID" = CASE WHEN p_authorpersonid_clear = true THEN NULL ELSE COALESCE(p_authorpersonid, "AuthorPersonID") END,
        "AIPromptRunID" = CASE WHEN p_aipromptrunid_clear = true THEN NULL ELSE COALESCE(p_aipromptrunid, "AIPromptRunID") END,
        "ProposedTasks" = CASE WHEN p_proposedtasks_clear = true THEN NULL ELSE COALESCE(p_proposedtasks, "ProposedTasks") END,
        "ArtifactID" = CASE WHEN p_artifactid_clear = true THEN NULL ELSE COALESCE(p_artifactid, "ArtifactID") END,
        "__mj_UpdatedAt" = (NOW() AT TIME ZONE 'UTC')
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwMeetingNotes"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateMeetingNote" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateMeetingNote" TO "cdp_Integration";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateMeetingNote" TO "cdp_UI";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingNote table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_meeting_note"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_meeting_note" ON "__mj_bizappstasks"."MeetingNote";

CREATE TRIGGER "trg_update_meeting_note"
BEFORE UPDATE ON "__mj_bizappstasks"."MeetingNote"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_meeting_note"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spDeleteMeetingNote
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR MeetingNote
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteMeetingNote'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteMeetingNote"(
    p_id uuid
) RETURNS TABLE("ID" uuid) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."MeetingNote"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::uuid AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteMeetingNote" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteMeetingNote" TO "cdp_Integration";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteMeetingNote" TO "cdp_UI";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Work Reports
-- Item: Index for Foreign Keys
-- ============================================================
-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'WorkReport'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'PersonID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_work_report_person_id"
            ON "__mj_bizappstasks"."WorkReport" ("PersonID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'WorkReport'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'AuthoredByAgentRunID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_work_report_authored_by_agent_run_id"
            ON "__mj_bizappstasks"."WorkReport" ("AuthoredByAgentRunID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'WorkReport'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'ReviewedByPersonID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_work_report_reviewed_by_person_id"
            ON "__mj_bizappstasks"."WorkReport" ("ReviewedByPersonID");
    END IF;
END
$$;

-- Skipped when another non-partial index already leads with the column.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index ix
        INNER JOIN pg_class t ON t.oid = ix.indrelid
        INNER JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'WorkReport'
          AND ix.indpred IS NULL
          AND ix.indnkeyatts >= 1
              AND ix.indkey[0] = (SELECT a.attnum FROM pg_attribute a WHERE a.attrelid = t.oid AND a.attname = 'ArtifactID')
    ) THEN
        CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_work_report_artifact_id"
            ON "__mj_bizappstasks"."WorkReport" ("ArtifactID");
    END IF;
END
$$;

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Work Reports
-- Item: vwWorkReports
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Work Reports
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  WorkReport
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwWorkReports"
AS
SELECT
    w.*,
    mjBizAppsCommonPerson_PersonID."DisplayName" AS "Person",
    MJAIAgentRun_AuthoredByAgentRunID."RunName" AS "AuthoredByAgentRun",
    mjBizAppsCommonPerson_ReviewedByPersonID."DisplayName" AS "ReviewedByPerson",
    MJArtifact_ArtifactID."Name" AS "Artifact"
FROM
    "__mj_bizappstasks"."WorkReport" AS w
LEFT OUTER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_PersonID
  ON
    "w"."PersonID" = mjBizAppsCommonPerson_PersonID."ID"
LEFT OUTER JOIN
    "__mj"."AIAgentRun" AS MJAIAgentRun_AuthoredByAgentRunID
  ON
    "w"."AuthoredByAgentRunID" = MJAIAgentRun_AuthoredByAgentRunID."ID"
LEFT OUTER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_ReviewedByPersonID
  ON
    "w"."ReviewedByPersonID" = mjBizAppsCommonPerson_ReviewedByPersonID."ID"
LEFT OUTER JOIN
    "__mj"."Artifact" AS MJArtifact_ArtifactID
  ON
    "w"."ArtifactID" = MJArtifact_ArtifactID."ID"
$vsql$;
  rec RECORD;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- 42P16: column rename/reorder/type change. CREATE OR REPLACE can't handle
  -- non-additive shape changes — must DROP CASCADE + recreate. CASCADE drops
  -- every dependent view (anything that JOINs this view in its body), so we
  -- capture each dependent's definition + grants BEFORE the drop and replay
  -- them afterward (best-effort). Without this, on a fresh-DB replay where
  -- one entity's wrapper triggers (e.g. vwAIModelTypes shape changed since
  -- baseline V202605021056), CASCADE wipes downstream views (vwAIModels)
  -- that the wrapper for this entity doesn't know how to recreate, and
  -- those views stay permanently missing.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_deps (
    schema_name TEXT,
    view_name   TEXT,
    relkind     CHAR(1),
    definition  TEXT,
    grants_sql  TEXT,
    depth       INT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_deps;

  -- Every view that DROP ... CASCADE removes: direct dependents AND theirs, transitively.
  -- Capturing only direct dependents restored vwTestRuns after a vwTestSuiteRuns regen but
  -- not vwConversations / vwConversationDetails, which select from vwTestRuns — they and their
  -- CRUD functions stayed permanently missing. depth is the LONGEST path from the target, so
  -- replaying in depth order always recreates a view after every view it reads.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_dep_oids (
    view_oid OID,
    depth    INT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_dep_oids;
  INSERT INTO _vw_regen_dep_oids (view_oid, depth)
  WITH RECURSIVE deps(view_oid, depth) AS (
      SELECT DISTINCT dc.oid, 1
      FROM pg_depend d
      JOIN pg_rewrite r ON r.oid = d.objid AND d.classid = 'pg_rewrite'::regclass
      JOIN pg_class dc ON dc.oid = r.ev_class AND dc.relkind IN ('v', 'm')
      JOIN pg_class tc ON tc.oid = d.refobjid
      JOIN pg_namespace tn ON tn.oid = tc.relnamespace
      WHERE tn.nspname = '__mj_bizappstasks'
        AND tc.relname = 'vwWorkReports'
        AND tc.relkind IN ('v', 'm')
        AND dc.oid <> tc.oid
    UNION
      SELECT dc.oid, deps.depth + 1
      FROM deps
      JOIN pg_depend d ON d.refobjid = deps.view_oid
      JOIN pg_rewrite r ON r.oid = d.objid AND d.classid = 'pg_rewrite'::regclass
      JOIN pg_class dc ON dc.oid = r.ev_class AND dc.relkind IN ('v', 'm')
      WHERE dc.oid <> deps.view_oid
        AND deps.depth < 50
  )
  SELECT view_oid, MAX(depth) FROM deps GROUP BY view_oid;

  -- Capture dependent FUNCTIONS too. CASCADE drops every function with
  -- RETURNS SETOF <view> (the codegen-emitted spCreate/spUpdate/spDelete
  -- pattern) when the target view is dropped. Without restoring them,
  -- post-codegen CRUD validation reports those routines as missing —
  -- e.g. "MJ: Recommendation Items → missing create routine
  -- spCreateRecommendationItem" — even though the next codegen pass
  -- emits them. The restored definitions are pg_get_functiondef() output
  -- which is a complete CREATE OR REPLACE FUNCTION statement plus a
  -- trailing semicolon; replaying them verbatim recreates the function
  -- with its original body, parameter list, and return type.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_fn_deps (
    schema_name TEXT,
    fn_name     TEXT,
    fn_oid      OID,
    definition  TEXT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_fn_deps;

  -- Capture dependents. NOTES on the grants_sql build:
  --   - Resolve role name via pg_get_userbyid(oid) — returns the bare,
  --     unquoted role name (or 'unknown (OID=N)' if the oid no longer
  --     exists). pg_get_userbyid is a public catalog function available to
  --     every database user, including unprivileged accounts on managed
  --     PostgreSQL services (Amazon RDS, Azure Database for PostgreSQL,
  --     Cloud SQL) where pg_authid is restricted to the rds_superuser /
  --     azure_pg_admin / cloudsqlsuperuser group. Earlier revisions joined
  --     to pg_authid which works on self-hosted PG but fails with
  --     "permission denied for table pg_authid" on managed services.
  --   - The earlier (broken) approach cast (aclexplode).grantee::regrole::text
  --     which RETURNS the role name pre-quoted when it contains uppercase
  --     (e.g. cdp_Developer comes back already wrapped); calling quote_ident
  --     on the already-quoted string double-wrapped and the GRANT failed at
  --     replay with "role does not exist". Using
  --     pg_get_userbyid returns a bare name and lets quote_ident wrap it
  --     correctly exactly once.
  --   - PUBLIC is grantee oid 0; pg_get_userbyid(0) returns 'unknown
  --     (OID=0)' so handle the PUBLIC case explicitly and use it as the
  --     literal 'PUBLIC' rather than quote_ident on the synthetic name.
  INSERT INTO _vw_regen_deps (schema_name, view_name, relkind, definition, grants_sql, depth)
  SELECT
      dn.nspname,
      dc.relname,
      dc.relkind,
      pg_get_viewdef(dc.oid),
      (SELECT string_agg(
          'GRANT ' || g.privilege || ' ON ' || quote_ident(dn.nspname) || '.' || quote_ident(dc.relname) ||
          ' TO ' || (CASE WHEN g.grantee_oid = 0 THEN 'PUBLIC' ELSE quote_ident(pg_get_userbyid(g.grantee_oid)) END) || ';',
          E'
')
       FROM (
           SELECT (aclexplode(dc.relacl)).grantee AS grantee_oid,
                  (aclexplode(dc.relacl)).privilege_type AS privilege
       ) g
       WHERE g.privilege IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER')),
      o.depth
  FROM _vw_regen_dep_oids o
  JOIN pg_class dc ON dc.oid = o.view_oid
  JOIN pg_namespace dn ON dn.oid = dc.relnamespace;

  -- Capture dependent functions. Two paths matter on PG:
  --   1. Functions whose RETURN type references the view (RETURNS SETOF
  --      <view>) — pg_depend records this as type=pg_type → pg_class.
  --   2. Functions whose body references the view (used by sql functions
  --      and by some plpgsql edge cases) — pg_depend records this as
  --      pg_proc → pg_class.
  -- pg_get_functiondef returns a complete CREATE OR REPLACE FUNCTION
  -- statement that we replay verbatim. We DO include RETURNS-only
  -- references because that's the dominant codegen pattern (sp* CRUD
  -- functions all RETURNS SETOF the matching vwX).
  -- The set is the target view plus every view captured above, because CASCADE drops the
  -- functions of each of them, not only the target's.
  INSERT INTO _vw_regen_fn_deps (schema_name, fn_name, fn_oid, definition)
  SELECT DISTINCT
      pn.nspname,
      pp.proname,
      pp.oid,
      pg_get_functiondef(pp.oid)
  FROM pg_proc pp
  JOIN pg_namespace pn ON pn.oid = pp.pronamespace
  WHERE pp.prokind IN ('f', 'p')
    AND EXISTS (
      SELECT 1
      FROM pg_class c
      WHERE (c.oid IN (SELECT view_oid FROM _vw_regen_dep_oids)
             OR c.oid = (SELECT tc.oid FROM pg_class tc
                         JOIN pg_namespace tn ON tn.oid = tc.relnamespace
                         WHERE tn.nspname = '__mj_bizappstasks'
                           AND tc.relname = 'vwWorkReports'
                           AND tc.relkind IN ('v', 'm')))
        AND (pp.prorettype = c.reltype
             OR EXISTS (SELECT 1 FROM pg_depend d
                        WHERE d.classid = 'pg_proc'::regclass
                          AND d.objid = pp.oid
                          AND d.refobjid = c.oid))
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwWorkReports" CASCADE;
  EXECUTE vsql;

  -- Replay captured dependents. Best-effort: log + continue on failure.
  -- IMPORTANT: the CREATE VIEW and the GRANTs run in SEPARATE inner BEGIN
  -- blocks. PL/pgSQL's BEGIN ... EXCEPTION creates an implicit savepoint
  -- and rolls back EVERY statement in the block on any exception. If we
  -- combined CREATE+GRANT in one block and a GRANT failed (e.g. role not
  -- present in target environment), the just-recreated VIEW would also
  -- get rolled back and stay missing — the exact failure mode this
  -- wrapper exists to prevent.
  FOR rec IN SELECT schema_name, view_name, relkind, definition, grants_sql FROM _vw_regen_deps ORDER BY depth, view_name LOOP
    BEGIN
      IF rec.relkind = 'm' THEN
        EXECUTE 'CREATE MATERIALIZED VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      ELSE
        EXECUTE 'CREATE VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent %.%: %', rec.schema_name, rec.view_name, SQLERRM;
    END;

    IF rec.grants_sql IS NOT NULL THEN
      BEGIN
        EXECUTE rec.grants_sql;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Best-effort grant restore skipped %.%: %', rec.schema_name, rec.view_name, SQLERRM;
      END;
    END IF;
  END LOOP;

  -- Replay captured dependent functions AFTER all dependent views are
  -- restored — most codegen-emitted sp* functions reference both the
  -- target view AND the dependent views in their bodies/return types.
  -- Wrapped per-function in its own savepoint so a single failure
  -- doesn't poison subsequent restores or the just-recreated target.
  FOR rec IN SELECT schema_name, fn_name, definition FROM _vw_regen_fn_deps LOOP
    BEGIN
      EXECUTE rec.definition;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent function %.%: %', rec.schema_name, rec.fn_name, SQLERRM;
    END;
  END LOOP;

  DROP TABLE _vw_regen_deps;
  DROP TABLE _vw_regen_dep_oids;
  DROP TABLE _vw_regen_fn_deps;
END $vw_regen$;
GRANT SELECT ON "__mj_bizappstasks"."vwWorkReports" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwWorkReports" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwWorkReports" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spCreateWorkReport
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR WorkReport
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateWorkReport'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateWorkReport"(
    p_id uuid DEFAULT NULL,
    p_personid uuid DEFAULT NULL,
    p_periodstart date DEFAULT NULL,
    p_periodend date DEFAULT NULL,
    p_title_clear boolean DEFAULT false,
    p_title text DEFAULT NULL,
    p_body text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_authoredbyagentrunid_clear boolean DEFAULT false,
    p_authoredbyagentrunid uuid DEFAULT NULL,
    p_supervisorfeedback_clear boolean DEFAULT false,
    p_supervisorfeedback text DEFAULT NULL,
    p_reviewedbypersonid_clear boolean DEFAULT false,
    p_reviewedbypersonid uuid DEFAULT NULL,
    p_reviewedat_clear boolean DEFAULT false,
    p_reviewedat timestamptz DEFAULT NULL,
    p_artifactid_clear boolean DEFAULT false,
    p_artifactid UUID DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwWorkReports" AS $$
DECLARE
    v_new_id uuid;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."WorkReport"
        (
            "ID",
            "PersonID",
                "PeriodStart",
                "PeriodEnd",
                "Title",
                "Body",
                "Status",
                "AuthoredByAgentRunID",
                "SupervisorFeedback",
                "ReviewedByPersonID",
                "ReviewedAt",
                "ArtifactID"
        )
    VALUES
        (
            v_new_id,
            p_personid,
                p_periodstart,
                p_periodend,
                CASE WHEN p_title_clear = true THEN NULL ELSE COALESCE(p_title, NULL) END,
                p_body,
                COALESCE(p_status, 'Draft'),
                CASE WHEN p_authoredbyagentrunid_clear = true THEN NULL ELSE COALESCE(p_authoredbyagentrunid, NULL) END,
                CASE WHEN p_supervisorfeedback_clear = true THEN NULL ELSE COALESCE(p_supervisorfeedback, NULL) END,
                CASE WHEN p_reviewedbypersonid_clear = true THEN NULL ELSE COALESCE(p_reviewedbypersonid, NULL) END,
                CASE WHEN p_reviewedat_clear = true THEN NULL ELSE COALESCE(p_reviewedat, NULL) END,
                CASE WHEN p_artifactid_clear = true THEN NULL ELSE COALESCE(p_artifactid, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwWorkReports"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateWorkReport" TO "cdp_UI";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateWorkReport" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateWorkReport" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spUpdateWorkReport
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR WorkReport
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateWorkReport'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateWorkReport"(
    p_id uuid,
    p_personid uuid DEFAULT NULL,
    p_periodstart date DEFAULT NULL,
    p_periodend date DEFAULT NULL,
    p_title_clear boolean DEFAULT false,
    p_title text DEFAULT NULL,
    p_body text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_authoredbyagentrunid_clear boolean DEFAULT false,
    p_authoredbyagentrunid uuid DEFAULT NULL,
    p_supervisorfeedback_clear boolean DEFAULT false,
    p_supervisorfeedback text DEFAULT NULL,
    p_reviewedbypersonid_clear boolean DEFAULT false,
    p_reviewedbypersonid uuid DEFAULT NULL,
    p_reviewedat_clear boolean DEFAULT false,
    p_reviewedat timestamptz DEFAULT NULL,
    p_artifactid_clear boolean DEFAULT false,
    p_artifactid UUID DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwWorkReports" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."WorkReport"
    SET
        "PersonID" = COALESCE(p_personid, "PersonID"),
        "PeriodStart" = COALESCE(p_periodstart, "PeriodStart"),
        "PeriodEnd" = COALESCE(p_periodend, "PeriodEnd"),
        "Title" = CASE WHEN p_title_clear = true THEN NULL ELSE COALESCE(p_title, "Title") END,
        "Body" = COALESCE(p_body, "Body"),
        "Status" = COALESCE(p_status, "Status"),
        "AuthoredByAgentRunID" = CASE WHEN p_authoredbyagentrunid_clear = true THEN NULL ELSE COALESCE(p_authoredbyagentrunid, "AuthoredByAgentRunID") END,
        "SupervisorFeedback" = CASE WHEN p_supervisorfeedback_clear = true THEN NULL ELSE COALESCE(p_supervisorfeedback, "SupervisorFeedback") END,
        "ReviewedByPersonID" = CASE WHEN p_reviewedbypersonid_clear = true THEN NULL ELSE COALESCE(p_reviewedbypersonid, "ReviewedByPersonID") END,
        "ReviewedAt" = CASE WHEN p_reviewedat_clear = true THEN NULL ELSE COALESCE(p_reviewedat, "ReviewedAt") END,
        "ArtifactID" = CASE WHEN p_artifactid_clear = true THEN NULL ELSE COALESCE(p_artifactid, "ArtifactID") END,
        "__mj_UpdatedAt" = (NOW() AT TIME ZONE 'UTC')
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwWorkReports"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateWorkReport" TO "cdp_UI";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateWorkReport" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateWorkReport" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the WorkReport table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_work_report"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_work_report" ON "__mj_bizappstasks"."WorkReport";

CREATE TRIGGER "trg_update_work_report"
BEFORE UPDATE ON "__mj_bizappstasks"."WorkReport"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_work_report"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spDeleteWorkReport
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR WorkReport
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteWorkReport'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteWorkReport"(
    p_id uuid
) RETURNS TABLE("ID" uuid) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."WorkReport"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::uuid AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteWorkReport" TO "cdp_UI";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteWorkReport" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteWorkReport" TO "cdp_Integration";
