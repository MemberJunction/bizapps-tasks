# Epic 8b: Provider-Level Row-Level Security & Chain-of-Command Visibility Across BizApps Tasks

- **Epic**: `23BEB2E0-3EEE-4C07-81C2-0488B0F2FF15`
- **Approved FactoryPlan**: `CCC97728-27A5-4842-9D01-23D48667D795` (v2)
- **Repository**: `MemberJunction/bizapps-tasks`
- **Pull Request**: `#220` (`factory/23beb2e0-epic-8b-rls-tasks` -> `next`)

## 1. Architecture Overview

BizApps Tasks enforces row-level authorization across all core task, time-tracking, meeting, risk-assessment, and work-report entities at the MemberJunction database provider layer (`MJ: Row Level Security Filters` + `MJ: Entity Permissions`). Because MemberJunction `RunView` and GraphQL resolvers evaluate provider-level RLS filters centrally, no data-access path can bypass chain-of-command or visibility boundaries.

### 1.1 `Task.Visibility` Data Model

Additive dual-dialect migrations (`migrations/V202611222115__v1.16.x__Task_Visibility_Team_Organization.sql` and `migrations-pg/V202611222115__v1.16.x__Task_Visibility_Team_Organization.pg.sql`, each preserving >= 50 blank lines before the CodeGen block) backfill legacy `Visibility` values to `'Team'`, replace the `CK_Task_Visibility` constraint with `('Team', 'Private', 'Organization')`, set default `'Team'`, and align entity metadata, Zod schemas, TypeScript union types (`mjBizAppsTasksTaskEntity['Visibility']`), and typed action parameter defaults.

- **`Team`** (default): Visible to the task creator, direct assignees (`MJ_BizApps_Common: People`, `MJ: Users`, `MJ: Roles`), root-task (`RootParentID`) creator/assignees, and every supervisor/manager/director up their reporting chains at arbitrary depth via `[__mj_BizAppsCommon].[vwPersonReportingChain]`.
- **`Private`**: Visible strictly to the task creator and direct assignees. Reporting-chain managers, root-task owners, and organization members are explicitly excluded.
- **`Organization`**: Inherits all `Team` visibility and additionally grants read access to active members of `Task.OrganizationID` (via active `PersonToOrganization` `Relationship` rows or active `Employee.CompanyID -> Organization.LinkedCompanyID`), while remaining strictly isolated from users in other organizations.

### 1.2 Dual-Dialect Filter Design & Correlation Safety

All 12 RLS filter definitions (`metadata/row-level-security-filters/.row-level-security-filters.json` and `metadata/row-level-security-filters/.work-report-rls-filters.json`) provide balanced SQL Server (`FilterText`) and PostgreSQL (`PlatformVariants.FilterText.postgresql`) predicates:

- **Indexed `EXISTS` Semi-Joins**: Zero uncorrelated `IN (SELECT ...)` subqueries so SQL Server and PostgreSQL query optimizers short-circuit per-row checks using foreign-key indexes.
- **Dual Identity Resolution**: Resolves caller `{{UserID}}` cleanly via both `Person.LinkedUserID` and `User.LinkedEntityRecordID` (plus email fallback on Work Reports).
- **Arbitrary-Depth Reporting Chain**: Replaces legacy single-hop/fixed-hop `Employee.SupervisorID` / `ManagerID` predicates with `bizapps-common`'s recursive cycle-safe `vwPersonReportingChain` view.
- **Collision-Free Subquery Correlation**: Derived-table column projections (`__TaskID`, `__SubPersonID`, `__RootTaskID`, `__AttendeeMeetingID`, `__LinkMeetingID`) prevent inner tables (`TaskAssignment`, `Entity`, `Task`, `vwPersonReportingChain`, `MeetingAttendee`, `MeetingLink`, `MeetingSeriesAttendee`) from shadowing unqualified outer columns (`[ID]`, `[RootParentID]`, `[PersonID]`, `[SeriesID]`) when `GenericDatabaseProvider` executes queries against either `vw*` base views or `BaseTable` count rewrites.

### 1.3 Governed Entities Matrix

| Entity | Read RLS Filter | Notes |
|---|---|---|
| `MJ_BizApps_Tasks: Tasks` | `Tasks: Visible Tasks` | `Private`, `Team`, `Organization`, `RootParentID`, `vwPersonReportingChain` |
| `MJ_BizApps_Tasks: Task Assignments` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Dependencies` | `Tasks: Visible Task Dependencies` | Enforces visibility on **both** `TaskID` and `DependsOnTaskID` |
| `MJ_BizApps_Tasks: Task Check Ins` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Comments` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Links` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Activities` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Risk Assessments` | `Tasks: Rows Of Visible Tasks` | Bound to parent `vwTasks` visibility |
| `MJ_BizApps_Tasks: Task Time Entries` | `Tasks: Visible Task Time Entries` | Own entries + standalone (`TaskID IS NULL`) chain + non-`Private` task chain |
| `MJ_BizApps_Tasks: Meetings` | `Tasks: Visible Meetings` | `Private` vs `Standard` + linked tasks (`MeetingAttendee`, `MeetingAgendaItem`, `MeetingNote` via `Rows Of Visible Meetings`; `MeetingLink`, `MeetingSeries`, `MeetingSeriesAttendee` via dedicated filters) |
| `MJ_BizApps_Tasks: Work Reports` | `UI: Work Reports - Author or Supervisor Chain` | Author + arbitrary-depth `vwPersonReportingChain` + admin roles (`Work Report Items` also bind `Draft Author Only` for Create/Update) |

## 2. Critical User Journeys (CUJs)

### CUJ-1: Department Manager & Skip-Level Director Chain-of-Command Isolation
- **Persona**: Direct Manager `M1` (depth 1) and Skip-Level Director `D1` (depth 2) in Organization 1 Chain A, alongside disjoint IC `User B` / Manager `M2` in Organization 1 Chain B.
- **Steps**:
  1. Query `Tasks`, all 6 task child entities, `Task Dependencies`, `Task Time Entries`, `Meetings`, and `Work Reports` as `M1` (resolved via `User.LinkedEntityRecordID`) and `D1` (resolved via `Person.LinkedUserID`).
  2. Query the same 11 entities as `User B` and `M2` in Chain B.
  3. Attempt to read `User A`'s `Private` task, child records attached to that `Private` task, `Team -> Private` dependency edge, `Private` task time entry, and `Private` meeting as `M1` and `D1`.
- **Expected Outcome**: `M1` and `D1` inherit read access across Chain A's `Team`, `Organization`, standalone `Time Entries` (`TaskID IS NULL`), `Standard` `Meetings`, and `Work Reports` at both depth 1 and depth 2, see zero `Private` records (unless explicitly assigned), and `User B` / `M2` see zero `Team` or `Private` records from Chain A across all 11 entities.

### CUJ-2: Root-Task Owner Inheritance, Cross-Organization Boundaries & Standalone Entities
- **Persona**: Root-Task Owner `R1` (and `R1`'s supervisor `RD1`) in Organization 1, IC `User A` creating a subtask under `R1`'s root task, and External `User C` in Organization 2.
- **Steps**:
  1. Create a `Team` subtask (`RootParentID = R1's root task`) owned/assigned inside Chain A and attach check-ins, comments, assignments, links, activities, and risk assessments.
  2. Query `Organization`-scoped tasks in Organization 1 as `User B` (same org, Chain B) and `External User C` (Organization 2).
  3. Query standalone `TaskTimeEntry` (`TaskID IS NULL`), standalone `Meeting` (no task link), and `WorkReport` / `WorkReportItem` records across chains and organizations.
- **Expected Outcome**: `R1` and `RD1` inherit visibility to the subtask and all its child entities via `RootParentID` + `vwPersonReportingChain`; `User B` sees Organization 1 `Organization` tasks while `External User C` sees zero Organization 1 records; standalone `Time Entries`, `Meetings`, and `Work Reports` enforce ownership and `vwPersonReportingChain` without cross-chain or cross-org leakage.

## 3. Verification Evidence

- **Migration & Metadata Tests (`packages/Entities`)**:
  - `src/__tests__/task-visibility-migration.test.ts` verifies dual-dialect SQL Server & PostgreSQL migrations, `>= 50` blank lines before CodeGen banner, backfill ordering, entity/action metadata, `release-lines.json`, and Zod/TypeScript types.
  - `src/__tests__/rls-filter-metadata.test.ts` verifies UI `EntityPermissions` bindings across all 11 governed entities, balanced parentheses, indexed `EXISTS` semi-joins, dual-dialect `PlatformVariants`, and `RowLevelSecurityFilterInfo` parameter binding.
- **Multi-Chain Relational RLS Integration Suite (`packages/Server`)**:
  - `src/__tests__/rls-chain-of-command.integration.test.ts` loads the real metadata files, resolves `EntityInfo.GetEffectiveRowFilterWhereClause` across both `sqlserver` and `postgresql` dialects, and executes the actual SQL predicates against an in-memory relational SQLite (`node:sqlite`) database populated with a recursive `vwPersonReportingChain` view and multi-chain/multi-org fixtures spanning all 11 governed entities plus `Work Report Items`.
- **Standards & Build Gates**:
  - `npm run check:standards` and `node scripts/sweep-limits.mjs --check-runaway` enforce zero `any`, zero lazy `unknown` casts, zero `BaseEntity.Get()/Set()`, and routed `TasksLimitsResolver` compliance.
  - `pnpm turbo build --filter="@mj-biz-apps/tasks-*" --force --log-order=stream` and `pnpm turbo test --force --log-order=stream` pass 100%.
