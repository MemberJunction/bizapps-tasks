# @mj-biz-apps/tasks-entities-server

Authoritative server-side entity subclasses for BizApps Tasks.

## Classes

- `TaskEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')`)
  - **Dynamic Status Synchronization**: Auto-syncs `TaskTypeStatusID` $\leftrightarrow$ `Status` (`MacroStatus`) and auto-assigns default stage on task creation.
  - **Terminal Completion**: Automatically populates `CompletedAt` and sets `PercentComplete = 100` upon entering terminal statuses.
  - **Audit Logging**: Writes server-authoritative `Task Activities` on creation, status change, progress update, priority change, and due date changes.
  - **Subtask Progress Rollup**: Reconciles parent progress upon child save.
  - **Lifecycle Action Hooks**: Dispatches asynchronous, non-blocking Action execution for `OnCreateActionID`, `OnStatusChangeActionID`, `OnEnterActionID`, `OnExitActionID`, `OnCompleteActionID`, `OnCancelActionID`, `OnRejectActionID`, and `OnPercentChangeActionID` with universal task event payloads.
- `MeetingEntityServer` (`MJ_BizApps_Tasks: Meetings`): the end is after the start and the zone is real; an occurrence names its series and its slot together; the status moves forward, and starting, ending or cancelling is the organizer's (their Person) or an administrator's (a role above UI that updates Meetings); the moves stamp `ActualStartedAt`, `ActualEndedAt`, `CancelledAt`; a new meeting takes the business time zone; the organizer's attendee row is made and kept in step with `OrganizerPersonID`; after the commit, a cancellation tells the video provider's driver to delete the provider's meeting.
- `MeetingSeriesEntityServer`: the rule parses and names a frequency, the zone is real, the length is more than 0; after the commit, the series' occurrences are made or brought up to date.
- `MeetingAttendeeEntityServer`, `MeetingSeriesAttendeeEntityServer`: a person or an email address; the address tidied; `UserID` filled from the person's MJ account; an Organizer row names the meeting's organizer.
- `MeetingAgendaItemEntityServer`: the parent is on the same meeting and the tree has no cycle; a duration is 0 or more; an item is deferred to another meeting.
- `MeetingLinkEntityServer`: a link belongs to a meeting or a series, one of the two.
- `VideoProviderBase` (`src/video`): the contract a video provider's driver implements and registers under `VideoProvider.DriverClass`; `resolveVideoProviderDriver` finds it. The drivers land with the Video step.
- `runAfterCommit`: work that runs once the save's transaction committed, through the database provider's `RunAfterCommit`. A provider without one is a client that loaded these subclasses beside its GraphQL provider (the integration harness does): the work is skipped there, since the server does it when it saves the same row.
