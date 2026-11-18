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
