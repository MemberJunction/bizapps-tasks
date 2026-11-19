# @mj-biz-apps/tasks-ng-widgets

## 1.14.0

### Minor Changes

- 6e78703: Meetings T2, T3, and Video Conferencing: adds `MeetingNotesService` (`draftFromTranscript`, `acceptProposedTask`, `dismissProposedTask`) and `MeetingAgendaService.draftAgenda` backed by seeded `Tasks: Meeting Notes from Transcript` and `Tasks: Draft Meeting Agenda` AI prompts, `ZoomVideoProvider` (`VideoProviderBase` Server-to-Server OAuth via `CredentialEngine`), and `MeetingCalendarSyncService` / `MeetingCalendarEventLinkHandler` for `MJ: Calendar Event Links` synchronization.
- b816574: The Meetings app's screens (T4 of the meetings plan). A new widgets package, `@mj-biz-apps/tasks-ng-widgets`, holds the presentational pieces any host can place: the meeting list grouped by day, the meeting card and header, status and response chips, the attendee response control, the people, agenda, notes, follow-ups and links sections, the live meeting view with the item clock, the series editor with its rule in words, and the new meeting form. `@mj-biz-apps/tasks-ng` adds the three resources the Meetings application's navigation names (My meetings, Meetings, Series), the meeting page's hero panel with the organizer's actions and the live meeting, the section panels that stand in for the generated related-entity grids on the Meetings and Meeting Series forms, and the data layer that reads and changes meetings over the MJ provider. `tasks-core` reads rrule in a way that works both in Node and in a browser bundle.

### Patch Changes

- Updated dependencies [2c415bc]
- Updated dependencies [934d7bb]
- Updated dependencies [6e78703]
- Updated dependencies [b816574]
  - @mj-biz-apps/tasks-entities@1.14.0
  - @mj-biz-apps/tasks-core@1.14.0
