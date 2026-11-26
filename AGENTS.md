# BizApps Tasks — Coding Agent Guide

This guide summarizes the architecture, strict engineering standards, and the **5-Rule BizApps Performance & Caching Standard** for `MemberJunction/bizapps-tasks`. See [CLAUDE.md](CLAUDE.md) for the complete repository handbook.

## Package Architecture

| Package | Path | Responsibility |
| --- | --- | --- |
| `@mj-biz-apps/tasks-entities` | `packages/Entities` | CodeGen entity subclasses, Zod schemas, and shared task-type classification helpers |
| `@mj-biz-apps/tasks-core` | `packages/Core` | Browser-safe services, `TasksEngineBase` (`BaseEngine` + `BaseSingleton`), `TasksLimitsResolver`, SQL guards, WBS tree helpers, and meeting logic |
| `@mj-biz-apps/tasks-ng-widgets` | `packages/AngularWidgets` | Explorer-free L2 task & meeting widgets |
| `@mj-biz-apps/tasks-ng` | `packages/Angular` | Explorer L3 components (`TaskList`, `TaskKanban`, `TaskGantt`, `TaskDetailPanel`, `TaskEditPanel`, `ConnectedTasksHost`), form panels, and pages (`TasksDashboard`, `MyTasks`, `Approvals`) |
| `@mj-biz-apps/tasks-actions` | `packages/Actions` | Typed server actions and meeting transcript actions |
| `@mj-biz-apps/tasks-entities-server` | `packages/EntitiesServer` | Server-only entity lifecycle hooks and calendar/video providers |
| `@mj-biz-apps/tasks-server` | `packages/Server` | GraphQL resolvers, remote operations, scheduled jobs, notification handlers, and workflow providers |
| `@mj-biz-apps/tasks-integration-tests` | `packages/IntegrationTests` | Live integration check bundles |

## Build, Test & Guard Commands

```bash
pnpm run build:packages                                # Build all packages via Turborepo
pnpm run test                                          # Run all package unit test suites
npm run check:standards                                # Enforce no-any, no-lazy-unknown, no-.Get()/.Set(), limits parity
node scripts/sweep-limits.mjs --check-runaway          # Verify zero unapproved RunawayGuard literals
npm run check:trademarks                               # Verify domain-neutral terminology and WCAG 2.1 AA citations
npm run check:doc-anchors                              # Verify documentation and sidebar anchors
npm run test:scripts                                   # Run repository guard script tests
```

## Non-Negotiable Coding Standards

- **Zero `any` and zero lazy `unknown`** (`as unknown`, `as unknown as Record<...>`). Derive entity value-list unions via `Entity['Field']`.
- **Zero `BaseEntity.Get()` / `.Set()`** — always use strongly-typed generated entity properties.
- **No cross-package re-exports** — import symbols directly from their defining package.
- **All singletons extend `BaseSingleton<T>`** (or `BaseEngine<T>`).
- **Modern Angular syntax** (`@if`/`@for`/`@switch`, `inject()`, `UserInfoEngine` instead of `localStorage`).
- **Route backend numeric limits via `TasksLimitsResolver.Instance.GetCurrentLimits()`** and keep `scripts/limits-sweep-classified.csv` and `.mj/specs/limits-sweep-bizapps-tasks.csv` in exact deterministic parity.
- **Preserve git history** — stage files explicitly (`git add <file>`), never push directly to `next`/`main`, and merge PRs with merge commits (`gh pr merge --merge`, never `--squash`).

## 5-Rule BizApps Performance & Caching Standard

### Rule 1: `BaseEngine` + `BaseSingleton` for Taxonomy & Config Tables
- All bounded reference/taxonomy tables (`MJ_BizApps_Tasks: Task Types`, `Task Type Status`, `Task Categories`, `Task Roles`, `Task Tags`) are cached in `TasksEngineBase` (`@mj-biz-apps/tasks-core`, `@RegisterForStartup()`, `BaseEngine<TasksEngineBase>`).
- Components and services read synchronously from `TasksEngineBase.Instance` (`TaskTypeById`, `TaskTypeByCode`, `StatusesForType`, `ActiveCategories`, `TaskRoleById`, `TaskTagByName`) after ensuring `Config()` has run rather than issuing redundant `RunView` calls.

### Rule 2: Impersonation / Multi-Provider Safety, `CacheLocal` Discipline & `CanRead` Gating
- `TasksEngineBase.ProviderToUse` follows the active provider passed to `Config()` or live `Metadata.Provider` — never latching permanently to a bootstrap provider during impersonation or provider switches.
- Switching the acting `userId` automatically evicts all user-scoped caches (`People`, `Organizations`, project subtrees).
- `CacheLocal: true` is permitted **only** on global, non-RLS reference/taxonomy tables. **Never** enable `CacheLocal: true` on RLS-filtered entities (`Tasks`, `Task Assignments`, `Task Dependencies`, `Task Comments`, `Task Activities`, `Meetings`, `Work Reports`).
- Gate optional entity loads on `EntityInfo.GetUserPermisions(user)?.CanRead` (`TasksEngineBase.Instance.CanReadEntity(...)`) so restricted roles never encounter GraphQL permission errors.

### Rule 3: `rv.RunViews([...])` GraphQL Batching & `ResultType: 'simple'`
- Collapse `Promise.all([rv.RunView(...), rv.RunView(...)])` bursts and independent sequential `await rv.RunView(...)` calls into **single `rv.RunViews([...])` GraphQL batch requests** (via `RunView.FromMetadataProvider(provider)` and `RunViewsBatch`).
- Use `ResultType: 'simple'` with explicit `Fields` projections for all read-only views, pickers, badges, and panels; reserve `ResultType: 'entity_object'` for write/save operations.
- Resolve `People` and `Organizations` through `TasksEngineBase.Instance.GetOrLoadPeopleByIds(...)`, `GetOrLoadAllPeople(...)`, and `GetOrLoadActiveOrganizations(...)` so previously seen records are served from memory.

### Rule 4: `ConversationEngine`-Style Bounded Container Window Caching
- Bounded container caches keyed strictly by parent/container ID are encouraged — `TasksEngineBase.Instance.LoadProjectSubtree(rootTaskId)` caches `[Tasks, Task Assignments, Task Dependencies]` per `(provider, userId)` with automatic `BaseEntity` event invalidation, explicit `InvalidateProjectSubtree(rootTaskId?)`, and user-switch reset so switching `WBS` <-> `Kanban` <-> `Gantt` within a project shares one cached bundle.
- **Never** cache arbitrary `ExtraFilter` SQL transactional task lists, search queries, or approval queues.

### Rule 5: Two-Step Entity `RunView`s Instead of Raw Base-View SQL Subqueries on RLS Entities
- Never write raw base-view SQL subqueries (e.g., `SELECT TaskID FROM __mj_BizAppsTasks.vwTaskAssignments WHERE ...`) inside `ExtraFilter` for RLS-protected entities — `MJServer` rejects them.
- Resolve parent or assignment IDs via a first-class `RunView` on the source entity, deduplicate and chunk the IDs (`SqlInClauseChunkSize`), and execute the follow-up `IN (...)` queries in a batched `rv.RunViews([...])` call.
