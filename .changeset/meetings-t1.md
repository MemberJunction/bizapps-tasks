---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-ng": minor
---

Meetings, a first-class app in Tasks (T1 of the meetings plan): ten tables for meetings, series, attendees, agendas and their item types, notes, links, meeting types and video providers, with CodeGen's output; the rules on the server (times and zone, the status moving forward with starting, ending and cancelling the organizer's, the organizer's attendee row, a series' rule parsed and its occurrences made after the commit, an agenda's tree, an attendee's MJ user filled from the person); the services (a meeting from a type with its agenda template, start/end/cancel, series materialization, agenda carry-forward, the `.ics` file); the daily series job; and the metadata: meeting and agenda item types, the three video providers (inactive) and their credential type, the Meetings application, the UI role's grants and Tasks' first row-level security filters (a Private meeting is read by its attendees only).

Needs MemberJunction 6.1.6, the repository's floor: the after-commit work (a series' occurrences, the video provider's delete) runs through the database provider's `RunAfterCommit`, which 6.1.6 carries, and the Meetings gate ran on it.
