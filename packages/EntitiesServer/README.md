# @mj-biz-apps/tasks-entities-server

Authoritative server-side entity subclasses and approval engines for BizApps Tasks.

## Entity Server Subclasses

- `TaskEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')`)
  - **Parent Organization Inheritance (`inheritParentOrganizationPreSave`)**: On create, new child sub-tasks automatically inherit their parent task's `OrganizationID` when left unset, while preserving explicit overrides and intentional clears on existing tasks.
  - **Dynamic Status Synchronization**: Auto-syncs `TaskTypeStatusID` $\leftrightarrow$ `Status` (`MacroStatus`) and auto-assigns default stage on task creation.
  - **Terminal Completion**: Automatically populates `CompletedAt` and sets `PercentComplete = 100` upon entering terminal statuses.
  - **Audit Logging**: Writes server-authoritative `Task Activities` on creation, status change, progress update, priority change, and due date changes.
  - **Subtask Progress Rollup**: Reconciles parent progress upon child save.
  - **Time Entry Delete Guard**: Refuses deleting a task that has logged `TaskTimeEntry` rows, reporting the exact entry count.
  - **Timesheet Approval Outcome Reconciliation**: When a task of type `TIMESHEET_APPROVAL` reaches a terminal status (`Completed`, `Cancelled`, `Blocked`), updates its `TimesheetApproval` part and parent `Timesheet` inside the save pipeline.
  - **Lifecycle Action Hooks**: Dispatches asynchronous, non-blocking Action execution for `OnCreateActionID`, `OnStatusChangeActionID`, `OnEnterActionID`, `OnExitActionID`, `OnCompleteActionID`, `OnCancelActionID`, `OnRejectActionID`, and `OnPercentChangeActionID`.
- `TaskDecisionEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Decisions')`)
  - Enforces the no-self-approval rule (`D13`) against both `Task.CreatedByPersonID` and `Timesheet.PersonID` (for `TIMESHEET_APPROVAL` tasks), and requires deciders to be assigned approvers when the task has assignments.
- `TaskTimeEntryEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entries')`)
  - Enforces `TimeTrackingEnabled`, `R1`–`R8` validation rules, ownership vs. `Tasks: Manage Time Entries` authorization, timesheet period locks (`R6`/`R7`), and `TaskTimeEntryLink` locks (`R8`).
- `TaskTimerEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Timers')`)
  - Enforces timer ownership (`PersonID`) and `Tasks: Manage Time Entries` override on save and delete.
- `TaskAgentRunEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Agent Runs')`)
  - Validates that the caller started the `AIAgentRun` (or holds `Tasks: Manage Time Entries`) and prevents double-counting (`A2`/`D7`) by pruning descendant run links when an ancestor run is linked or no-oping when an ancestor is already linked.
- `TaskTimeEntryLinkEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entry Links')`)
- `TimesheetLinkEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Links')`)
- `TimesheetScheduleEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Schedules')`)
- `TimeApproverEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Time Approvers')`)
- `MeetingEntityServer` (`MJ_BizApps_Tasks: Meetings`): the end is after the start and the zone is real; an occurrence names its series and its slot together; the status moves forward, and starting, ending or cancelling is the organizer's (their Person) or an administrator's (a role above UI that updates Meetings); the meeting itself is theirs to make and change too, so a new meeting's organizer is the person who schedules it unless an administrator schedules it, and a meeting joins a series only at that series' organizer's hand; the moves leave their stamps (ActualStartedAt, ActualEndedAt, CancelledAt) only when the save is accepted; a new meeting's zone defaults from the business time zone; the organizer's attendee row is made and kept in step (a new organizer who is already an attendee is promoted and the old organizer stays as a Required attendee); after the commit, a cancellation tells the video provider's driver.
- `MeetingSeriesEntityServer`: the rule parses and names a frequency, the zone is real, the length is more than 0; a series is made and changed by its organizer or an administrator (a change reaches every occurrence not yet held); after the commit, the series' occurrences are made or brought up to date, or, when the series was cancelled, the ones not yet held are cancelled. The daily job runs as the scheduling engine's polling user, which must administer Meetings.
- `MeetingAttendeeEntityServer`, `MeetingSeriesAttendeeEntityServer`: a person or an email address; the address tidied; `UserID` filled from the person's MJ account, again when the person changes; an Organizer row names the meeting's organizer. Who writes them, over the API as in the app: the organizer or an administrator invites, removes and changes attendees; an attendee changes only their own answer and attendance (`ResponseStatus`, `RespondedAt`, `AttendanceStatus`, `JoinedAt`, `LeftAt`, `Notes`); a meeting the caller may not read is, to them, not there. The meeting server marks the rows it keeps in step as its own (`MaintainedByMeetingServer`, never a column).
- `MeetingAgendaItemEntityServer`, `MeetingLinkEntityServer`: `MeetingID`, `ParentID`, `DeferredToMeetingID` and `SeriesID` are GUIDs before any of them reaches a filter; the parent is on the same meeting and the tree has no cycle; a duration is 0 or more; an item is deferred to another meeting; a link belongs to one of a meeting and a series. The agenda and the links are the organizer's (or an administrator's) to write, over the API as in the app; a meeting the caller may not read is, to them, not there.
- `MeetingNoteEntityServer`: anyone on the meeting writes a note; it is the caller's own unless the organizer or an administrator writes it for someone; the author the database holds decides who may change it (its author, the organizer, an administrator), and only the organizer changes the author.
- A row of a meeting (an attendee, an agenda item, a note, a link) moves to another meeting or series only at the organizer's hand on both; and a cancelled series stays cancelled, so its meetings are not remade over the ones it cancelled.
- `MeetingLinkEntityServer`: a link belongs to a meeting or a series, one of the two.
- `VideoProviderBase` (`src/video`): the contract a video provider's driver implements and registers under `VideoProvider.DriverClass`; `resolveVideoProviderDriver` finds it. The drivers land with the Video step.
- `runAfterCommit`: work that runs once the save's transaction committed, through the database provider's `RunAfterCommit` (MemberJunction 6.2.0-edge.0 and later: the app's floor). A provider without one is a client that loaded these subclasses beside its GraphQL provider (the integration harness does): the work is skipped there, since the server does it when it saves the same row.

## Server Services & Extension Points

- `TaskTimerServer`: Transactional `StartTimer` (stopping any previous running timer in the same transaction) and `StopTimer` (splitting cross-midnight timers by business day in `BusinessTimeZoneEngine`).
- `TimesheetEngine` (`BaseSingleton`): Implements `SubmitTimesheet`, `WithdrawTimesheet`, `ReopenTimesheet`, `GetTaskEffort`, and `ReconcileStaleTimesheetApprovals`.
- `BaseTimeApproverResolver`: `ClassFactory` extension point allowing downstream BizApps to resolve external parent scopes for a task (`ResolveScopesForTask`). Ships with `TaskLinkScopeApproverResolver` (`@RegisterClass(BaseTimeApproverResolver, 'TaskLinkScopeApproverResolver', 50)`).
- `UserHasTasksAuthorization`: Evaluates hierarchical `Tasks: Manage Time Entries` and `Tasks: Manage Timesheets` authorizations.

## Server Remotable Operations (`TasksRemoteOperationsServer.ts`)

- `TasksBulkUpdateServerOperation` (`@RegisterClass(BaseRemotableOperation, 'BizAppsTasks.BulkUpdateTasks')`): Authoritative server handler for Asana-grade bulk operations across up to 500 tasks per call — deduplicates UUIDs, validates inputs, applies scalar + assignment + tag mutations through `TaskEntityServer` so audit trails and lifecycle hooks fire accurately, and reports partial failures cleanly.
- `TasksInstantiateTemplateServerOperation` (`@RegisterClass(BaseRemotableOperation, 'BizAppsTasks.InstantiateTemplate')`): Server handler that topologically sorts template items (parent-before-child), computes relative `DueAt` offsets, stamps `OrganizationID` / `CategoryID`, assigns mapped People or MJ Roles, and wires `TaskDependency` links.
