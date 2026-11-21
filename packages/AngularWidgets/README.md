# @mj-biz-apps/tasks-ng-widgets

The meeting widgets of BizApps Tasks (the meetings plan, § 5), with no Explorer dependency, so the Meetings app in
`@mj-biz-apps/tasks-ng` and other apps (Collaboration's Meetings tab) compose the same parts. A widget takes the models in
`types.ts`, which the host builds from the records, and asks for every change through an output; the host saves it.

| Widget | Shows |
|---|---|
| `bizapps-meeting-list` | Meetings grouped by day in the viewer's zone, with the meeting's own time when it differs, type, status, place or Join, and the viewer's answer |
| `bizapps-meeting-card` | A meeting as a small card, for a *Coming up* strip |
| `bizapps-meeting-header` | The meeting page's header: time in both zones, status, place, the organizer's actions (start, run, end, cancel), *Add to calendar*, the viewer's answer |
| `bizapps-attendee-response`, `bizapps-response-chip`, `bizapps-meeting-status-chip` | The answer control and the chips |
| `bizapps-meeting-people` | Who is invited, their answers and attendance; invite a person or a guest; remove |
| `bizapps-meeting-agenda` | The agenda builder: nesting, order, type, presenter, durations added up against the meeting's length, the type's template |
| `bizapps-meeting-notes` | Notes by hand, on the meeting or on an item, Draft or Final (AI drafting comes with T3) |
| `bizapps-meeting-followups` | The tasks linked to the meeting, and a form that files a new one |
| `bizapps-meeting-links` | What the meeting belongs to |
| `bizapps-meeting-live` | The live meeting: the current item and its timer, next and previous, attendance, a quick note, a follow-up, End |
| `bizapps-meeting-series-editor` | A series: when, how long, the rule (daily, weekly on days, monthly; an interval; an end) and a preview of the next occurrences |
| `bizapps-new-meeting-form` | A new meeting from a type, with its people and the type's template |

`format.ts` says when a meeting is in two zones through Intl; `series-rule.ts` writes and reads the editor's RRULE subset.
Colours come from MemberJunction's semantic tokens (`tokens.ts`), so light and dark follow the host.

## Tasks Widgets (`src/lib/tasks`)

Standalone, Router-free, `@memberjunction/ng-shared`-free task UI primitives styled exclusively with `--mj-*` design tokens and CSS `@container` queries:

| Widget | Selector | Purpose |
|---|---|---|
| `TaskBulkActionDockComponent` | `<mjt-bulk-action-dock>` | Single-row floating Asana-grade bulk action bar with upward popovers for **Reassign** (Person / MJ Role replace/add/clear), **Redate** (set date, shift ±N days, clear), **Status**, **Org**, and **More Fields** |
| `TaskQuickCaptureComponent` | `<mjt-quick-capture>` | Natural-language quick capture input with live parsed preview chips |
| `TaskCompletionRingComponent` | `<mjt-completion-ring>` | Tactile 1-click completion ring separate from bulk-select checkboxes |
| `TaskWorkflowStepperComponent` | `<mjt-workflow-stepper>` | Interactive `TaskTypeStatus` stage pipeline stepper |
| `TaskUrgencyStripComponent` | `<mjt-urgency-strip>` | Conditional KPI pill strip (Overdue, Blocked, Pending Approvals, SLA Risk) |
| `TaskApprovalCardComponent` | `<mjt-approval-card>` | Inline decision card (`Approve` / `Approve with Conditions` / `Reject`) |
| `TaskAdaptiveSpotlightComponent` | `<mjt-adaptive-spotlight>` | Archetype-aware form spotlight (Effort Burn, SLA Risk, Blockers; 0px collapse on plain General tasks) |
| `TaskOkrCheckInComponent` | `<mjt-okr-checkin>` | Metric progress display + inline `TaskCheckIn` composer for OKR Key Results |
| `TaskCommandPaletteComponent` | `<mjt-command-palette>` | `⌘J` keyboard quick-jump palette built on `<mj-dialog>` |
| `TaskMobileMilestoneStackComponent` | `<mjt-mobile-milestone-stack>` | Chronological mobile milestone cards replacing wide Gantt charts on phones |
| `ConnectedTasksWidgetComponent` | `<mjt-connected-tasks>` | Embeddable task list widget for attaching tasks to any MJ entity form |
