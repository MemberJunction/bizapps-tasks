# Chief of Staff Meetings & Transcripts

Use this skill whenever the user asks about upcoming meetings, meeting preparation briefs, past meeting notes and decisions, or turning meeting transcripts into deduplicated action items and commitments.

## 1. Typed Tools Only (Never Generic CRUD or Raw SQL)

- **`Get My Upcoming Meetings`**: List the caller's non-cancelled upcoming meetings (`DaysAhead`, `IncludePastHours`, `Limit`) with attendee count, agenda readiness, notes status, and transcript status.
- **`Prepare Meeting Brief`**: Gather a concise one-page brief for a meeting: attendees, agenda, prior notes from the same recurring series, open tasks involving attendees or linked to the meeting, and live-calendar re-check metadata.
- **`Process Meeting Transcript`**: Locate and ingest a meeting transcript (checking an attached `TranscriptFileID` first, then configured transcript plugins such as Zoom Cloud Recordings, or accepting supplied `TranscriptText`), draft structured AI notes, extract decisions, and deduplicate proposed commitments against existing tasks over a 30-day window.
- **`Accept Meeting Commitments`**: Idempotently turn user-confirmed proposals from a meeting note into `ACTION_ITEM` tasks (or link duplicate-matched proposals to existing tasks via `LinkExistingMatches` so nothing is duplicated).
- **`Get Meeting Notes`**: Read a meeting's saved notes, extracted decisions, agenda outcomes, and linked tasks (strictly respecting 1:1 private meeting visibility).

## 2. Meeting Preparation & Live Calendar Re-check

1. When preparing a brief ahead of a meeting (especially from a scheduled `meeting-prep-<id>` wake), call **`Prepare Meeting Brief`**.
2. **Always re-check live calendar state** (when calendar tools are available) before delivering a scheduled prep brief:
   - If the event was cancelled, exit silently without bothering the user.
   - If the event was moved to a new time, reschedule the prep wake rather than sending an early brief.
3. Keep the brief scannable: meeting goal, key attendees, open commitments/overdue tasks between you and attendees, carryover items from prior notes, and 2–3 suggested questions or decisions to close.

## 3. Post-Meeting Transcripts & Commitment Deduplication

1. Call **`Process Meeting Transcript`** (leaving `AutoCreateCommitments` as `false` unless the user has explicitly authorized automatic creation).
2. Branch on the returned `Status`:
   - **`TRANSCRIPT_NOT_READY`**: The recording/transcript is not available yet — do not bother the user; let the post-meeting wake retry (up to 24 hours).
   - **`NO_SOURCE`**: No transcript file is attached and no transcript source is configured for this meeting — ask the user if they want to paste or upload a transcript.
   - **`PROCESSED`**: Review `Summary`, `Decisions`, `MatchedExistingTasks` (30-day deduplication hits), and `ProposedNewCommitments`.
3. **Confirm before creating tasks**: Present the summary, decisions, existing-task links, and proposed new commitments cleanly to the user.
   - Only after user confirmation, call **`Accept Meeting Commitments`** with `MeetingNoteID`, selected `ProposalIDs`, and `LinkExistingMatches` for commitments that already have a tracked task.
   - Never silently dump commitments onto other teammates' active task lists; propose them for review or route via peer Chief of Staff coordination.

## 4. Handling Canonical Result Codes

- **`NOT_FOUND` / `PERMISSION_DENIED`**: Private 1:1 meetings are strictly restricted to attendees and organizers; report cleanly without speculating about inaccessible meetings.
- **`NO_PERSON_RECORD`**: Explain that the user's account must be linked to an active `People` record.
- **`POLICY_DENIED` / `POLICY_DEFERRED` / `APPROVAL_REQUIRED`**: Honor the user's Agent User Policy strictly.
