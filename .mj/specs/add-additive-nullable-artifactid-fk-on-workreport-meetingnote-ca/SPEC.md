# WorkReport & MeetingNote MJ Docs (`ArtifactID`) Convergence

- **Status**: Implemented (v1.16.x additive release, non-breaking under `PUBLISH_NO_BREAK_POLICY.md`)
- **Target Packages**: `@mj-biz-apps/tasks-entities`, `@mj-biz-apps/tasks-core`, `@mj-biz-apps/tasks-actions`, `@mj-biz-apps/tasks-ng-widgets`, `@mj-biz-apps/tasks-ng`, `@mj-biz-apps/tasks-server`, `@mj-biz-apps/tasks-integration-tests`
- **Migrations**:
  - `migrations/V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql`
  - `migrations-pg/V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.pg.sql` (`-- @mj-pg-provenance: split-bake v1`)

## 1. Architectural Goal & Category A / B / C Rubric

BizApps Tasks converges long-form and publishable documents onto MemberJunction's canonical **MJ Docs** (`MJ: Artifacts` + `MJ: Artifact Versions`) model using strictly additive, nullable foreign keys while keeping high-frequency relational notes fast and untouched:

| Category | Entities | Schema & Behavioral Contract |
| --- | --- | --- |
| **Category A — Direct MJ Doc Backing** | `WorkReport` | Nullable `[ArtifactID] UNIQUEIDENTIFIER NULL` FK to `[__mj].[Artifact]([ID])` with filtered non-clustered index (`WHERE [ArtifactID] IS NOT NULL`). Legacy `Body` is strictly preserved (zero column drops/renames). Dual-read resolution prefers linked `MJ: Artifact Versions` content and falls back cleanly to `Body`. |
| **Category B — Hybrid Scratchpad + Publishable MJ Doc** | `MeetingNote` | Nullable `[ArtifactID] UNIQUEIDENTIFIER NULL` FK to `[__mj].[Artifact]([ID])` with filtered non-clustered index (`WHERE [ArtifactID] IS NOT NULL`). Preserves low-latency live editing in `Body` and structured `ProposedTasks` JSON; promotes to a versioned `MJ: Artifact` on demand via `Tasks.PublishMeetingNoteAsMJDoc`. |
| **Category C — Lightweight Relational Notes** | `TaskComment`, `TaskCheckIn`, `Task.BlockedReason`, `Timesheet`, `TaskTimeEntry.Notes` | Strictly relational — **no `ArtifactID` FK** and zero artifact overhead. |

### `MJ: Comments` vs. `MJ: Artifacts`
- **`MJ: Comments` / `MJ: Field Suggestions`**: Record-anchored discussion threads and AI field-value suggestions (`LinkedEntityID` + `LinkedRecordID`).
- **`MJ: Artifacts` (MJ Docs)**: Standalone, versioned, formatted documents rendered with `<mj-artifact-viewer-panel>`.
- **Category C Relational Notes**: Short transactional annotations queried inline with tasks, boards, timelines, and timesheets.

## 2. Additive Dual-Dialect Schema & CodeGen

- **T-SQL Migration (`migrations/V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql`)**:
  - Adds nullable `ArtifactID UNIQUEIDENTIFIER NULL` with FK constraints (`FK_WorkReport_Artifact`, `FK_MeetingNote_Artifact` referencing `[__mj].[Artifact]([ID])`), `MS_Description` extended properties, and filtered non-clustered indexes (`IX_WorkReport_ArtifactID`, `IX_MeetingNote_ArtifactID` where `ArtifactID IS NOT NULL`).
  - Preserves `WorkReport.Body`, `MeetingNote.Body`, `MeetingNote.ProposedTasks`, and leaves all Category C tables untouched.
  - Followed by 50+ blank lines and CodeGen-generated `EntityField` metadata, `vwWorkReports` / `vwMeetingNotes`, `spCreate*` / `spUpdate*` / `spDelete*`, and triggers.
- **PostgreSQL Counterpart (`migrations-pg/V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.pg.sql`)**:
  - Generated deterministically via `mj migrate convert --split --bake-codegen` + `mj migrate rebake --capture-only`.
  - Stamped at line 1 with `-- @mj-pg-provenance: split-bake v1 source=V202611261400__v1.16.x__WorkReport_MeetingNote_ArtifactID.sql source-sha256=... mode=needs-hand-rebaked`.
  - Verified with 6-category SQL Server <-> PostgreSQL schema-delta equivalence and clean Skyway `mj migrate` + `mj sync push --dir metadata --ci` without deploy-time CodeGen.
- **CodeGen Artifacts**:
  - `packages/Entities/src/generated/entities/__mj_BizAppsTasks.ts` & `schemas/__mj_BizAppsTasks.ts`: strongly-typed `ArtifactID: string | null` and virtual `Artifact: string | null` properties on `mjBizAppsTasksWorkReportEntity` and `mjBizAppsTasksMeetingNoteEntity`.
  - `packages/Server/src/generated/graphql-schemas/__mj_BizAppsTasks.ts`: GraphQL input/output fields for `ArtifactID` and `Artifact`.
  - `metadata/entities/.entities.json` & `metadata/actions/.tasks-actions.json`.

## 3. Core Services & Server Action

- **`ArtifactDualReadResolver` (`@mj-biz-apps/tasks-core`)**:
  - `BaseSingleton<ArtifactDualReadResolver>` exposing `ResolveBatch` and `ResolveSingle`.
  - Validates and deduplicates UUIDs (`ValidateAndDeduplicateArtifactIDs`), chunks SQL `IN (...)` predicates via `TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize`, executes batched `RunView(..., { ResultType: 'simple' })` queries propagating `ContextUser`, supports `IncludeContent: false` header-only list resolution, and falls back deterministically to `Body` (`no_artifact_id`, `invalid_artifact_id`, `artifact_not_accessible`, `version_not_accessible`, `empty_artifact_content`).
- **`PublishMeetingNoteAsMJDocAction` (`@mj-biz-apps/tasks-actions`, DriverClass `Tasks.PublishMeetingNoteAsMJDoc`)**:
  - `@RegisterClass(BaseAction, 'Tasks.PublishMeetingNoteAsMJDoc')` with `AuthorizesCaller = true` and `checkTypedPolicyGuard` checks on `MJ_BizApps_Tasks: Meeting Notes`, `MJ: Artifacts`, and `MJ: Artifact Versions`.
  - First publish creates `MJ: Artifacts` + `MJ: Artifact Versions` (`VersionNumber = 1`) and links `MeetingNote.ArtifactID` with compensating cleanup on downstream save failure.
  - Subsequent publishes append `VersionNumber = max + 1` on the existing `ArtifactID` without creating duplicate artifacts, strictly preserving `MeetingNote.Body` and `MeetingNote.ProposedTasks`.

## 4. Angular UI & OpenApp v3 Readiness

- **`WorkReportArtifactPanel`** (`form-panel:WorkReports:artifact`) & **`ChiefOfStaffWorkReportsResource`**: Render linked `WorkReport` MJ Docs via `@memberjunction/ng-artifacts` `<mj-artifact-viewer-panel>` with formatted `<mj-markdown>` legacy `Body` fallback (zero raw Markdown leaks), `ChangeDetectionStrategy.OnPush`, `UserInfoEngine.Instance` preference persistence (zero `localStorage`), and `--mj-*` CSS design tokens exclusively.
- **`MeetingNoteArtifactPanel`** (`form-panel:MeetingNotes:artifact`) & **`MeetingNotesPanel`** / **`bizapps-meeting-notes`**: Switch cleanly between **Published MJ Doc** (`<mj-artifact-viewer-panel>`) and **Live Scratchpad** (preserving `Body` + `ProposedTasks`), guard against blank bodies and concurrent double-clicks on **Publish as MJ Doc** / **Publish New Version**, and surface unpublished scratchpad edit indicators.
- **Dual Form Registration & Nav Parity**: Retains `@RegisterClass(BaseFormComponent, '<EntityName>')` for all entities (including `WorkReport` and `MeetingNote`) alongside `BaseFormPanel` slots and `BaseResourceComponent` nav items.

## 5. Verification Matrix

- **Unit Tests**: Vitest suites across `Entities`, `Core`, `Actions`, `AngularWidgets`, `Angular`, `Server`, and `IntegrationTests`.
- **Dual-DBMS Integration Suite (`artifact-convergence`, `ACV1`–`ACV6`)**: Multi-entity `ArtifactConvergenceWorld` (37 domain records across Organizations, People, UI-role Users, Tasks/TaskLinks, Category A WorkReports, Category B MeetingNotes, and Category C notes) executed against both SQL Server and PostgreSQL via `test-harnesses/integration.mjs`.
- **CI Static Guards**: `.github/scripts/check-pg-provenance.mjs` (enforced via `.github/workflows/repo-checks.yml` on PRs targeting `next`), `npm run check:standards`, `node scripts/sweep-limits.mjs --check-runaway`, `npm run check:trademarks`, `npm run check:doc-anchors`, `npm run test:scripts`, and `.github/scripts/__tests__/*.spec.mjs`.
