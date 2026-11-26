# @mj-biz-apps/tasks-integration-tests

Comprehensive integration check bundles for BizApps Tasks dispatched by `mj test` or `test-harnesses/integration.mjs`.

## Test Bundles & Scenarios (13 Bundles, 38 Checks)

| Bundle | Test IDs | Description |
| :--- | :--- | :--- |
| `task-world` | `TW1` | Establishes deterministic baseline data: 15+ multi-domain categories, 8 people, 6 task types with codes, dynamic task type statuses, candidate actions (`Calculate Expression`, `Color Converter`), and 3 divergent project hierarchies. |
| `task-hierarchy` | `TH1`, `TH2` | Evaluates parent/child task creation, depth querying, and multi-domain hierarchy integrity. |
| `task-dependencies` | `TD1`, `TD2` | Tests `FinishToStart` dependency graph links and critical path chains. |
| `task-assignments` | `TA1` | Evaluates polymorphic task assignments (People and AI Agents) across distinct operational roles. |
| `task-decisions` | `TDN1`, `TDN2` | Tests formal task decisions, sign-off outcomes, and approver audit tracking. |
| `task-templates` | `TT1` | Evaluates shipped task types and template structures. |
| `task-statuses` | `TS1`–`TS4` | Tests dynamic `TaskTypeStatus` defaulting on task creation, stage transitions across `MacroStatus` values, and terminal auto-completion. |
| `task-action-hooks` | `AH1`–`AH3` | Validates non-blocking event-driven Action hook dispatch (`OnCreate`, `OnStatusChange`, `OnEnterStatus`, `OnExitStatus`) with universal task payload. |
| `time-entries` | `TE1`–`TE6` | Tests `TaskTimeEntryEntityServer` validation rules `R1`–`R5`, ownership vs. `Manage Time Entries` authorization, task deletion protection with entry count (`§6.1`), and `TaskTimeEntryLink` locking (`R8`). |
| `timers` | `TMR1`–`TMR5` | Tests `Tasks.StartTimer` and `Tasks.StopTimer`, atomic timer switching across tasks, cross-midnight business-day splitting (`D5`), short-timer discard (`DiscardIfUnderSeconds`), and `TimeTrackingEnabled` gating. |
| `agent-effort` | `AE1`–`AE3` | Tests `TaskAgentRunEntityServer` ancestor/descendant deduplication (`A2`, `D7`), `vwTasks` and `Tasks.GetTaskEffort` subtree rollups, and the `Link Agent Run to Task` action. |
| `time-reporting` | `TR1`–`TR3` | Executes all 5 shipped MJ reporting queries (`Time Logged by Person and Period`, `Task Effort vs Estimate Rollup`, `Agent Effort and Cost by Task`, `Timesheet Approval Status Summary`, `Logged Time by Linked Record`) against seeded data. |
| `timesheets` | `TSH1`–`TSH5` | End-to-end multi-project timesheet submission, `R6`/`R7` period locks, `D13` self-approval refusal, part rejection and resubmit carry-forward vs. `TimesheetResubmitReapprovesAll`, `Withdraw`, `Reopen` with `TaskActivity` audit, `TaskLinkScopeApproverResolver`, and `ReconcileStaleTimesheetApprovals`. |
| `meetings` | `M1`–`M8` | Meetings over the wire: a meeting from the Team type with its agenda, the organizer's row and its `.ics` (M1); a weekly series' occurrences, with the series' attendees, a change reaching the untouched ones (M2); the status moves, the organizer starting the meeting as a UI-only user and someone else refused (M3); a Private meeting, its attendees, agenda and notes read by its attendees only (M4); who writes an attendee over the wire, a UI user unable to invite himself, answer for another or remove anyone, answering his own row, the organizer inviting and removing (M6); a Private series and who it invites read by its organizer and invitees only, a Standard one by all (M7); who writes a note and the agenda, an invited UI user writing a note and changing only his own, a stranger writing nothing, the agenda the organizer's (M8); a cancellation telling the fake video driver after the commit (M5). M3 and M4 sign in as two UI-only people (`ivy.meets@`, `jun.meets@task-world.test`) with keys minted for the run (`persona-provider.ts`); M5 needs MJAPI started with `--import <this package>/dist/video-stub.js`. |
| `task-org-bulk-ops` | `TOB1`–`TOB6` | Aggregate-root `OrganizationID` scoping on `Task`, `TaskCategory`, and `TaskTemplate` (`TOB1`); server-side parent-to-child `OrganizationID` inheritance via `TaskEntityServer` (`TOB2`); live `BizAppsTasks.BulkUpdateTasks` Reassign (Person + MJ Role replace/add/clear, `TOB3`), Redate (set/shift ±N days on both `DueAt` & `StartedAt`/clear) + Status/Priority/Org/idempotent Tag (`TOB4`), input validation guards (`TOB5`); and live `BizAppsTasks.InstantiateTemplate` with WBS hierarchy, dependencies, role mappings, and `OrganizationID` stamping (`TOB6`). |
| `artifact-convergence` | `ACV1`–`ACV6` | Multi-entity domain seed fixtures (`ArtifactConvergenceWorld`, 37 records across Organizations, People, UI-role Users, Tasks/TaskLinks, Category A WorkReports, Category B MeetingNotes, and Category C notes) (`ACV1`); batched `ArtifactDualReadResolver` latest-version resolution, header-only mode, and graceful `no_artifact_id` / `version_not_accessible` / `invalid_artifact_id` fallbacks (`ACV2`); idempotent `PublishMeetingNoteAsMJDoc` v1→v2 promotion preserving `Body` and `ProposedTasks` (`ACV3`); RLS & `ContextUser` adversarial boundaries (`ACV4`); Category C relational non-regression (`ACV5`); and rolled-back `ArtifactConvergenceLiveCrudVerifier` CRUD probes with 0 residual rows (`ACV6`). |

## Running Tests

```bash
# Build integration tests bundle
pnpm --filter @mj-biz-apps/tasks-integration-tests build

# Run unit / registration tests
pnpm --filter @mj-biz-apps/tasks-integration-tests test

# Run live integration suite against SQL Server
node test-harnesses/integration.mjs

# Run live integration suite against PostgreSQL
DB_PLATFORM=postgresql node test-harnesses/integration.mjs artifact-convergence
```
