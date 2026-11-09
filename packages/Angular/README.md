# @mj-biz-apps/tasks-ng

Reusable Angular components, generated forms, custom form panels, and dashboard sections for BizApps Tasks.

## Task Management Components

- `<bizapps-task-list>`: Embeddable, filterable task grid with multi-select and before/after events.
- `<bizapps-my-tasks>`: Personalized view of the current user's assigned tasks.
- `<bizapps-task-detail-panel>`: Read-only slide-in detail panel with activity and comment streams.
- `<bizapps-task-edit-panel>`: Create/edit slide-in form panel.
- `<bizapps-task-kanban>`: Drag-and-drop Kanban board by status.
- `<bizapps-task-gantt>`: DHTMLX-powered interactive Gantt chart.
- `<bizapps-task-template-wizard>`: Multi-step wizard for template instantiation.
- `<bizapps-task-dashboard>`: Comprehensive tasks application shell.

## Time Tracking, AI Agent Effort & Timesheet Components

- `<mj-tasks-running-timer-chip>` (`RunningTimerChipComponent`): Live `HH:MM:SS` running timer badge mounted in Tasks section headers with quick **Stop**, **Open Task**, and **Discard** actions.
- `<mj-tasks-time-and-effort-panel>` (`TaskTimeAndEffortPanelComponent`): Custom `BaseFormPanel` (`@RegisterClass(BaseFormPanel, 'MJ_BizApps_Tasks: Tasks.timeAndEffort')`) displaying human hours vs. estimate, start/stop timer button, manual time entry editor, logged entries table, and AI agent effort summary with run-linking picker.
- `<mj-tasks-my-time-section>` (`TasksMyTimeSectionComponent`): Full **My Time** dashboard section (`@RegisterClass(BaseResourceComponent, 'TasksMyTimeSection')`) featuring:
  - **Weekly Grid**: 7-day task-by-day editable time matrix with daily/weekly totals, add-task row, and timer controls.
  - **Timesheet Period View**: Period selector (`Weekly`, `BiWeekly`, `SemiMonthly`, `Monthly`), status badge, project approval parts breakdown, **Submit**, **Withdraw**, and **Reopen** (for `Manage Timesheets` holders) actions.
- `BaseApprovalSubjectPanel`: Abstract `ClassFactory` extension point rendered inside `<mj-tasks-approval-decision-panel>` when an approval task's `TaskType.Code` matches a registered panel key.
- `<mj-tasks-timesheet-part-approval-panel>` (`TimesheetPartApprovalPanelComponent`): `@RegisterClass(BaseApprovalSubjectPanel, 'TIMESHEET_APPROVAL')` displaying a timesheet part's worker, period, scope, entries table, and row-level-security hidden-entry notice inside Approvals.
- `TasksTimeTrackingService`: Shared Angular service wrapping `ExecuteRemoteOperation` (`Tasks.StartTimer`, `Tasks.StopTimer`, `Tasks.SubmitTimesheet`, `Tasks.WithdrawTimesheet`, `Tasks.ReopenTimesheet`, `Tasks.GetTaskEffort`) and reactive running-timer state.
