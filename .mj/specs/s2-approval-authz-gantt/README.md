# Sub-Epic S2: Approval Authorization Hardening, MIT Gantt v10, Recurring-Close DB Constraint & Manifests

- **Epic**: `B2D9081C-46B2-4CEB-AA89-88BAA72BA016`
- **Approved FactoryPlan**: `5940E02C-BB40-4F25-B0EE-04191626C14E` (v2)
- **Repository**: `MemberJunction/bizapps-tasks`
- **Pull Request**: `#221` (`factory/b2d9081c-46b2-4ceb-aa89-88baa72ba016-s2-authz-gantt` -> `next`)

## 1. Architecture Summary

### 1.1 Approval Authorization & Dual-Dialect LIKE-Wildcard Escaping (Slice 1)
- `ApprovalActor`, `ApprovalTaskAuthority`, `TaskDecisionAuthority`, `TaskDecisionEntityServer`, `TaskAssignmentEntityServer`, `TaskEntityServer`, and `TimesheetApprovalEntityServer` enforce fail-closed actor, role, self-approval, and cross-organization isolation (`ApprovalAuthorizationError`).
- `EscapeLikePattern` and `BuildLikeClause` in [`packages/Core/src/services/sql-guards.ts`](../../../packages/Core/src/services/sql-guards.ts) escape `%`, `_`, `[`, `]`, and `\` using explicit `ESCAPE '\'` across SQL Server and PostgreSQL.

### 1.2 Approval Latency Telemetry & Lifecycle Hooks (Slice 1)
- `RecordApprovalDecisionLatency` and `QueryApprovalLatencyMetrics` in [`packages/Core/src/services/ApprovalLatencyService.ts`](../../../packages/Core/src/services/ApprovalLatencyService.ts) record scalar, PII/UUID-scrubbed latency metrics via `TelemetryManager.Instance` (`DefaultApprovalRouteScrubber` / `RouteScrubberLike`) and query historical latency via `RunView` (`ResultType: 'simple'`, explicit `Fields`, zero `MaxRows` caps).
- `APPROVAL_REQUEST` lifecycle hooks (`OnComplete`, `OnReject`, `OnCancel` -> `Process Approval Request Outcome`) are seeded in [`metadata/task-types/.task-types.json`](../../../metadata/task-types/.task-types.json) and [`metadata/actions/.tasks-actions.json`](../../../metadata/actions/.tasks-actions.json), documented in [`docs/APPROVAL_AND_AGENT_HOOKS.md`](../../../docs/APPROVAL_AND_AGENT_HOOKS.md), and `AGENT_TASK` dispatch is verified by automated tests.

### 1.3 Dual-Dialect Recurring-Close Idempotency (Slice 1)
- [`migrations/V202611230210__v1.16.x__Recurring_Playbook_Unique_Index.sql`](../../../migrations/V202611230210__v1.16.x__Recurring_Playbook_Unique_Index.sql) and [`migrations-pg/V202611230210__v1.16.x__Recurring_Playbook_Unique_Index.pg.sql`](../../../migrations-pg/V202611230210__v1.16.x__Recurring_Playbook_Unique_Index.pg.sql) enforce atomic database-level idempotency via `UX_Task_RecurringPlaybook_Org_Period` on `(OrganizationID, RecurrenceTemplateID, RecurrencePeriodKey)` with `WHERE ... IS NOT NULL`.
- Registered as edge-only in [`release-lines.json`](../../../release-lines.json), with `TasksRunRecurringPlaybooksServerOperation` resolving dialect unique violations (`2601`/`2627`/`23505`) idempotently.

### 1.4 MIT `dhtmlx-gantt` v10 & Organization-Grouped Approval Inbox (Slice 2)
- [`packages/Angular/package.json`](../../../packages/Angular/package.json) upgrades `dhtmlx-gantt` to `^10.0.4` (MIT license), verified via headless Chromium Playwright rendering (`gantt.license === 'mit'`) and unit tests (`task-gantt-v10.test.ts`).
- [`ApprovalsPageComponent`](../../../packages/Angular/src/lib/pages/approvals.page.ts) and [`ApprovalInboxComponent`](../../../packages/Angular/src/lib/components/approval-inbox/approval-inbox.component.ts) share [`approval-inbox-grouping.ts`](../../../packages/Angular/src/lib/components/approval-inbox/approval-inbox-grouping.ts) to group pending approvals by `Task.OrganizationID`, surface wait-latency indicators, strip raw Markdown in excerpts, use `ChangeDetectionStrategy.OnPush` and `--mj-*` CSS design tokens exclusively, escape LIKE metacharacters in search filters, and persist collapse/sort/grouping state via `UserInfoEngine.Instance`.

### 1.5 Manifest Alignment & Zero Decision-Feeding Row Caps (Slice 2)
- [`mj-app.json`](../../../mj-app.json) aligns `mj-bizapps-common` dependency floor to `>=5.69.0 <6.0.0`.
- [`no-decision-row-caps.test.ts`](../../../packages/Core/src/services/__tests__/no-decision-row-caps.test.ts) guards approval inbox, authorization, latency, recurring-close, and workflow dispatch paths against arbitrary `MaxRows`/`TOP`/`LIMIT` truncation, paired with synchronized `scripts/limits-sweep-classified.csv` and `.mj/specs/limits-sweep-bizapps-tasks.csv`.

## 2. Critical User Journeys (CUJs)

1. **Organization Approver**: Opens Approvals inbox, filters with LIKE metacharacters (`Q4_[100%]`), inspects Organization-grouped queues with wait-latency pills and persisted collapse/sort state (`UserInfoEngine`), approves within authorized organization (triggering `Process Approval Request Outcome`), and is rejected on cross-organization/self-approval attempts.
2. **Project Manager (Timeline & Recurring Tasks)**: Views project timeline powered by MIT `dhtmlx-gantt` v10 in light and dark `--mj-*` themes with zero console/page errors; closes or triggers concurrent recurring playbooks with `UX_Task_RecurringPlaybook_Org_Period` guaranteeing single occurrence creation.
3. **Platform Operator / Release Engineer**: Validates `mj-app.json` (`>=5.69.0 <6.0.0`), `release-lines.json` edge-only entry, `.changeset/*.md` minor bumps, CI workflows (`.github/workflows/build.yml`, `repo-checks.yml`, `changes.yml`), and static standards/limits gates.
4. **Agent Task Automation Operator**: Assigns an `AGENT_TASK` to an `MJ: AI Agents` record, triggering `Execute Assigned Agent` asynchronously with run linking and Chief of Staff inbox wakeup.
