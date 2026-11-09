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

## Running Tests

```bash
# Build integration tests bundle
pnpm --filter @mj-biz-apps/tasks-integration-tests build

# Run unit / registration tests
pnpm --filter @mj-biz-apps/tasks-integration-tests test

# Run live integration suite against SQL Server
node test-harnesses/integration.mjs
```
