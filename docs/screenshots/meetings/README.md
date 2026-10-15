# Meetings app screenshots

The Meetings app's screens in MJ Explorer, taken with Playwright as a signed-in staff user, light and dark. Each screen is asserted before its capture (the text it must show, from the sample rows the runner seeds), so a `-FAILED.png` is a real finding, not a timing miss.

| File | Screen | Where |
| --- | --- | --- |
| `01-my-meetings-*.png` | My meetings: the viewer's upcoming meetings by day, with the Organizer badge and the response chip | `/app/meetings/My meetings` |
| `02-meetings-*.png` | Meetings: every meeting the viewer may see, with the type and status filters | `/app/meetings/Meetings` |
| `03-series-*.png` | Series: the recurring meetings, their rule in words, and how many occurrences exist | `/app/meetings/Series` |
| `04-new-meeting-*.png` | The New meeting form: type, time and zone, where, who sees it, invitations | New meeting on My meetings |
| `05-meeting-page-*.png` | A meeting's page: the hero with the organizer's actions, then agenda, people, notes, follow-ups, links | the Meetings record form |
| `06-live-meeting-*.png` | Running a meeting: the agenda item clock, who is here, quick notes and follow-ups | Start meeting on the page |
| `07-series-page-*.png` | A series' page: its rule and the meetings made from it | the Meeting Series record form |
| `08-scheduled-from-form-*.png` | The page of a meeting scheduled through the New meeting form | Schedule meeting on My meetings |

Three of the screens act as well as look, so the pass is an end-to-end test of the browser path: 01 answers Ivy's invitation with Going and checks the answer is still pressed after a reload; 06 starts the meeting (first pass), starts its first agenda item, saves a quick note from the live view and checks the note is in the page's Notes section after a reload; 08 schedules "Pricing review (sample)" from the form (first pass) and checks the new meeting's page opens with the viewer as organizer. Each acts once; later passes find what the first made.

## Taking them

```sh
# once: a browser opens; sign in as the staff account; the session is saved beside this file (git-ignored)
node docs/screenshots/meetings/take-screenshots.mjs --save-staff-session

# then, from the bizapps-tasks root, with MJAPI and Explorer up
SCREENSHOT_STAFF_EMAIL=<staff email> node --env-file=<env with MJAPI_URL and MJ_API_KEY> docs/screenshots/meetings/take-screenshots.mjs [--theme light|dark|both] [--only 01-my-meetings,05-meeting-page]
```

`EXPLORER_URL` defaults to `http://localhost:4218`. `SHOT_DEBUG=1` prints the page's console errors for each screen.

## The sample rows

The runner seeds, once and by name, as the harness user over GraphQL: a Person for the staff account and the user's link to it, then three meetings ("Board prep (sample)" with the TEAM agenda, a note and a follow-up task; "Client kickoff (sample)" organized by the Ivy persona with the staff user invited; a completed "Sprint retro (sample)") and one series ("Weekly staff sync (sample)", every Tuesday). The personas come from the integration tests' meeting world. The rows stay in place between runs; screen 06 starts "Board prep", so after the first pass it is In progress and the live view opens through Run meeting. The console errors the runner prints on a host whose database is behind its MJ build (`Entity MJ: Entity Form Contributions not found in metadata`) are the host's, not the app's.
