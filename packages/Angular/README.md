# @mj-biz-apps/tasks-ng

Reusable Angular components, generated forms, custom form panels, and dashboard sections for BizApps Tasks.

## Task Management Components

- `<bizapps-tasks-dashboard-page>`: Projects & All Work shell built on `<mj-page-layout>` / `<mj-page-header>` / `<mj-page-body>`, collapsible `<mj-left-nav>` category rail, unified `<mj-filter-panel>` (**Assignee**, **Due Date**, **Organization / Company**, Status, Priority, Task Type), `⌘J` command palette, and `UserInfoEngine`-persisted view preferences.
- `<bizapps-task-list>`: Calm hierarchical WBS tree list with Organization badges, rich Assignee chips (avatar + short name + `+N` + MJ Role pills), completion rings, `TaskTypeStatus` stage pills, Shift+click range selection, and floating `<mjt-bulk-action-dock>` backed by `BizAppsTasks.BulkUpdateTasks`.
- `<bizapps-my-tasks>`: Action Horizons personal workspace (`Needs Your Decision`, `Focus Today`, `Blocked & Waiting`, `Coming Up`) with `<mjt-quick-capture>` and `<mjt-urgency-strip>`.
- `<bizapps-task-detail-panel>`: Zero-bounce slide-in inspector (`<mj-slide-panel>` on desktop, `<mj-bottom-sheet>` on phone) with inline Status, Priority, Due Date, and **Organization / Company** editing, `<mjt-workflow-stepper>`, Effort Burn, `<bizapps-task-time-effort>`, assignees, sub-tasks, and linked records.
- `<bizapps-task-edit-panel>`: Express Create drawer with TaskType progressive archetype disclosure, Organization / Company selector, and atomic `RelatedRecordCollection` saves.
- `<bizapps-task-kanban>`: 5-mode Kanban board (`<mj-kanban-board>`) grouped by **Organization / Company**, Macro Status, Workflow Stages (`TaskTypeStatus`), Priority, or Assignee.
- `<bizapps-task-gantt>`: Critical-path DHTMLX Gantt timeline (`<mj-gantt-chart>`) with dedicated **`Assignee`** and **`Organization`** columns, Finish-to-Start dependency arrows, unified filters, and automatic `<mjt-mobile-milestone-stack>` phone swap.
- `<bizapps-task-template-wizard>`: 1-screen Playbook Launcher with Organization / Company scoping, People/MJ Role pickers, and live offset schedule preview backed by `BizAppsTasks.InstantiateTemplate`.
- `<bizapps-task-dashboard>`: Comprehensive embeddable tasks application shell.

## Time Tracking, AI Agent Effort & Timesheet Components

- `<mj-tasks-running-timer-chip>` (`RunningTimerChipComponent`): Live `HH:MM:SS` running timer badge mounted in Tasks section headers with quick **Stop**, **Open Task**, and **Discard** actions.
- `<mj-tasks-time-and-effort-panel>` (`TaskTimeAndEffortPanelComponent`): Custom `BaseFormPanel` (`@RegisterClass(BaseFormPanel, 'MJ_BizApps_Tasks: Tasks.timeAndEffort')`) displaying human hours vs. estimate, start/stop timer button, manual time entry editor, logged entries table, and AI agent effort summary with run-linking picker.
- `<mj-tasks-my-time-section>` (`TasksMyTimeSectionComponent`): Full **My Time** dashboard section (`@RegisterClass(BaseResourceComponent, 'TasksMyTimeSection')`) featuring:
  - **Weekly Grid**: 7-day task-by-day editable time matrix with daily/weekly totals, add-task row, and timer controls.
  - **Timesheet Period View**: Period selector (`Weekly`, `BiWeekly`, `SemiMonthly`, `Monthly`), status badge, project approval parts breakdown, **Submit**, **Withdraw**, and **Reopen** (for `Manage Timesheets` holders) actions.
- `BaseApprovalSubjectPanel`: Abstract `ClassFactory` extension point rendered inside `<mj-tasks-approval-decision-panel>` when an approval task's `TaskType.Code` matches a registered panel key.
- `<mj-tasks-timesheet-part-approval-panel>` (`TimesheetPartApprovalPanelComponent`): `@RegisterClass(BaseApprovalSubjectPanel, 'TIMESHEET_APPROVAL')` displaying a timesheet part's worker, period, scope, entries table, and row-level-security hidden-entry notice inside Approvals.
- `TasksTimeTrackingService`: Shared Angular service wrapping `ExecuteRemoteOperation` (`Tasks.StartTimer`, `Tasks.StopTimer`, `Tasks.SubmitTimesheet`, `Tasks.WithdrawTimesheet`, `Tasks.ReopenTimesheet`, `Tasks.GetTaskEffort`) and reactive running-timer state.

## MJ Docs (`<mj-artifact-viewer-panel>`) Work Report & Meeting Note Panels

- `WorkReportArtifactPanel` (`@RegisterClassEx(BaseFormPanel, 'form-panel:WorkReports:artifact')`): Renders linked Category A `WorkReport` MJ Docs inside `@memberjunction/ng-artifacts` `<mj-artifact-viewer-panel>`, falls back cleanly to formatted `<mj-markdown>` legacy `Body` when `ArtifactID` is null or inaccessible, persists view-mode preferences via `UserInfoEngine.Instance`, and retains full `BaseFormComponent` parity (`mjBizAppsTasksWorkReportFormComponent`).
- `MeetingNoteArtifactPanel` (`@RegisterClassEx(BaseFormPanel, 'form-panel:MeetingNotes:artifact')`): Hybrid Category B view switching between **Published MJ Doc** (`<mj-artifact-viewer-panel>`) and **Live Scratchpad** (preserving `Body` + `ProposedTasks` JSON), exposing an in-flight-guarded **Publish as MJ Doc** / **Publish New Version** CTA wired to `Tasks.PublishMeetingNoteAsMJDoc` and an unpublished-edits indicator.
- `ChiefOfStaffWorkReportsResource` & `MeetingNotesPanel`: Batched dual-read integration via `ArtifactDualReadResolver` with `<mj-artifact-viewer-panel>` rendering, formatted `<mj-markdown>` fallback (zero raw Markdown leaks), `ChangeDetectionStrategy.OnPush`, and `--mj-*` semantic CSS tokens exclusively.
