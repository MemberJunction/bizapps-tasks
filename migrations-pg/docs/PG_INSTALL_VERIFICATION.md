# Verifying BizApps Tasks on PostgreSQL (one-shot install, no CodeGen)

This runbook simulates what `mj app install` does to a PostgreSQL database and
verifies that the app is **fully functional without ever running `mj codegen`**.
It is the tasks adaptation of bizapps-common's
`migrations-pg/docs/PG_INSTALL_VERIFICATION.md` (commit 1bfe93c) — read that one
for the full background.

Why simulate instead of running the real command? `mj app install` downloads
the app's migrations from the **latest GitHub release**. To test unreleased
changes to `migrations-pg/`, you run the same database steps the installer
performs — mapped 1:1 from `@memberjunction/open-app-engine`'s
`install-orchestrator` — but point the migration step at your local branch.
Once a release ships, the app steps collapse back to the real `mj app install`.

Background: on SQL Server, CodeGen's DDL (CRUD sprocs, views, triggers) is
appended into the migrations at authoring time, so an install is complete on
its own. The PG conversion pipeline cannot translate T-SQL procedures
(`-- SKIPPED: procedure (auto-conversion not supported)`), so historically a PG
install was incomplete until a consumer ran `mj codegen`. The `migrations-pg/`
files in this repo now carry CodeGen's native plpgsql directly (extracted
verbatim from a post-codegen v5.44 database — CodeGen's fixed point), which is
what makes the one-shot install work and makes a subsequent codegen run a no-op.

> **Not yet re-verified on MJ 6.x.** The committed plpgsql is still the v5.44
> emission. The MJ 6.1.0-edge upgrade was a dependency-only change made without
> database access, so the step-5 no-op check below has not been re-run against
> 6.x CodeGen. Run this whole runbook before trusting a PG install on MJ 6.

Tasks depends on bizapps-common, so the install is **four** layers:
MJ core → bizapps-common (≥ v5.33.1, the first release that peers on MJ 6.x and
whose PG migrations are themselves one-shot) → bizapps-tasks.

## 0. Fresh PostgreSQL (throwaway container)

```bash
docker run -d --name tasks-pg-test \
  -e POSTGRES_USER=mj_admin -e POSTGRES_PASSWORD=<pw> \
  -e POSTGRES_DB=Tasks_Test -p 5438:5432 postgres:17
```

## 1. Point the MJ CLI at it

Shell exports take precedence over `.env`, so nothing in the repo needs editing:

```bash
export DB_PLATFORM=postgresql DB_HOST=localhost DB_PORT=5438 \
  DB_DATABASE=Tasks_Test DB_USERNAME=mj_admin DB_PASSWORD=<pw> \
  CODEGEN_DB_USERNAME=mj_admin CODEGEN_DB_PASSWORD=<pw>
```

`CODEGEN_DB_*` is required even for migrate — the CLI opens its admin
connection with those credentials.

## 2. Platform install (the consumer's `mj migrate`)

```bash
npx mj migrate --tag v6.1.0-edge.1   # MJ core's own migrations on a virgin DB
```

The tag must satisfy `mj-app.json`'s `mjVersionRange` (`>=6.1.0-edge.1 <7.0.0`).
The applied count was 61 at MJ core v5.44.0 and has not been re-measured on the
6.x line — treat whatever 6.x reports as the new baseline.

Do **not** run plain `npx mj migrate` — without `--tag` it uses this repo's
local migrations directory (the app's own), not MJ core's.

## 3. Install bizapps-common (dependency), then bizapps-tasks

Each app follows the installer's exact order: create schema → the (no-op on
fresh installs) canonical-name persist → migrations → record the app.

```bash
PSQL="psql -h localhost -p 5438 -U mj_admin -d Tasks_Test"

# --- bizapps-common (from its repo checkout at >= v5.33.1) ---
$PSQL -c 'CREATE SCHEMA IF NOT EXISTS __mj_bizappscommon;'
npx mj migrate --schema __mj_bizappscommon --dir <bizapps-common>/migrations-pg   # expect: 7 applied

# --- bizapps-tasks (this repo) ---
$PSQL -c 'CREATE SCHEMA IF NOT EXISTS __mj_bizappstasks;'
# [Schema] PersistCanonicalSchemaName — expect "UPDATE 0". The installer fires
# this BEFORE migrations create the SchemaInfo row, so it always misses on a
# fresh install. That is why the CodeGen_Metadata_Backfill migration sets
# CanonicalSchemaName itself.
$PSQL -c "UPDATE __mj.\"SchemaInfo\" SET \"CanonicalSchemaName\"='__mj_BizAppsTasks'
   WHERE LOWER(\"SchemaName\")=LOWER('__mj_bizappstasks');"
npx mj migrate --schema __mj_bizappstasks --dir ./migrations-pg   # expect: 5 applied
# (the .pgonly.sql metadata backfill runs last)
```

Post-release, each app's step is one command:
`npx mj app install <repo-url> --dangerously-ignore-dbl-underscore-schema-rule`.

**Do not run codegen.** That is the point of the test.

## 4. Verify everything is there

```sql
-- expected values in comments
SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = '__mj_bizappstasks' AND p.proname LIKE 'sp%';        -- 57

SELECT count(*) FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid
 JOIN pg_namespace n ON n.oid = c.relnamespace
 WHERE NOT t.tgisinternal AND n.nspname = '__mj_bizappstasks';          -- 19

SELECT "CanonicalSchemaName" FROM __mj."SchemaInfo"
 WHERE "SchemaName" = '__mj_bizappstasks';                              -- __mj_BizAppsTasks

SELECT count(*) FROM __mj."vwEntities"
 WHERE "SchemaName" = '__mj_bizappstasks'
   AND "ClassName" LIKE 'mjBizAppsTasks%';                              -- 19 (and 0 lowercase)

SELECT (SELECT count(*) FROM __mj_bizappstasks."TaskType"),             -- 5
       (SELECT count(*) FROM __mj_bizappstasks."TaskRole"),             -- 3
       (SELECT count(*) FROM __mj_bizappstasks."TaskNotificationConfig"), -- 1
       (SELECT count(*) FROM __mj_bizappstasks."TaskDecisionOutcome");  -- 3

-- CRUD round-trip through CodeGen's own function
SELECT "ID", "Name" FROM __mj_bizappstasks."spCreateTaskRole"(
  p_name := 'RunbookProbe', p_sequence := 999);
DELETE FROM __mj_bizappstasks."TaskRole" WHERE "Name" = 'RunbookProbe';
```

Then the two live proofs:

```bash
# Functional suite — CRUD functions, FK-join views, root-parent TVFs, CHECK
# enforcement, cross-schema Person joins, polymorphic assignment, approval
# model, row-touch triggers. Self-cleaning. Connection via PGHOST/PGPORT/
# PGDATABASE/PGUSER/PGPASSWORD (defaults match this runbook's container).
node scripts/pg-objectmodel-test.mjs      # expect: RESULT: 19 passed, 0 failed

# MJAPI against it (same shell, exports still set)
cd apps/MJAPI && GRAPHQL_PORT=4111 npm start   # expect: Server ready at http://localhost:4111/
```

## 5. Optional: prove codegen is a no-op

Snapshot every `__mj_bizappstasks` function/view/trigger definition plus the
app's `__mj` metadata rows (Entity / EntityField / EntityRelationship /
GeneratedCode / SchemaInfo), run `npx mj codegen`, snapshot again: the diff
must be empty.

CodeGen will rewrite this repo's generated TypeScript with PG-flavored doc
comments (`gen_random_uuid()` vs `newsequentialid()`, etc.) — restore them
afterward; they are not part of the test:

```bash
git checkout -- 'packages/Entities/src/generated' 'packages/Server/src/generated' \
  'packages/Angular/src/lib/generated' apps/MJAPI/schema.graphql
rm -rf temp_sql_scripts migrations/codegen/CodeGen_Run_<today>*.sql
```

## Things that look wrong but aren't

- **First codegen on a virgin MJ core reconciles a handful of CORE metadata
  rows** (`__mj` schema) — MJ core's own migrations not shipping their codegen
  metadata; outside this repo's control. The acceptance criterion is that
  **no `__mj_bizappstasks` object and no app-entity metadata row changes**.
- **GeneratedCode `LinkedRecordPrimaryKey` casing matters**: the column is
  TEXT (composite-key serialization) and CodeGen's constraint change-detection
  lookup is case-sensitive on it. The backfill stores the lowercase form PG
  CodeGen writes; an uppercase value makes CodeGen miss the row and re-parse
  the constraint (an AI call with nondeterministic wording) on every install.
- **Validator set differs slightly from the committed SS output**: the
  `TaskTemplateItemDependency` self-reference validator exists on PG but was
  not emitted by the SS run that generated the committed
  `entity_subclasses.ts`, so a codegen run emits TypeScript containing it —
  restore per step 5.
- **Flyway history schema casing**: `mj migrate --schema __mj_BizAppsTasks`
  (mixed case) creates the history table in a quoted mixed-case schema, while
  the real installer uses the lowercase physical schema. Cosmetic; pass the
  lowercase form as shown above.

## Maintenance contract

The plpgsql in `migrations-pg/` is CodeGen's own emission, frozen at v5.44 —
still, after the move to MJ 6.1.0-edge.1, because that upgrade regenerated
nothing. The first person with a database should re-run step 5 on 6.x CodeGen
and re-freeze here if it is no longer a no-op.
When a future schema change regenerates any CRUD function, view, or trigger,
the new definition must be captured into the corresponding PG migration (the
manual PG analog of what `appendOutputCode` does automatically for T-SQL).
The no-op check in step 5 is the regression test for this: if codegen changes
anything after a fresh install, a migration is missing codegen output.

## Cleanup

```bash
docker rm -f tasks-pg-test
```
