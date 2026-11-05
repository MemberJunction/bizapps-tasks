---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-ng-widgets": minor
---

Meetings T2, T3, and Video Conferencing: adds `MeetingNotesService` (`draftFromTranscript`, `acceptProposedTask`, `dismissProposedTask`) and `MeetingAgendaService.draftAgenda` backed by seeded `Meetings: Notes from Transcript` and `Meetings: Draft Agenda` AI prompts, `ZoomVideoProvider` (`VideoProviderBase` Server-to-Server OAuth via `CredentialEngine`), and `MeetingCalendarSyncService` / `MeetingCalendarEventLinkHandler` for `MJ: Calendar Event Links` synchronization.
