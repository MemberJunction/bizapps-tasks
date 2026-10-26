# @mj-biz-apps/tasks-integration-tests

Comprehensive integration check bundles for BizApps Tasks dispatched by `mj test` or standalone test runners.

## Test Bundles & Scenarios

| Bundle | Test ID | Description |
| :--- | :--- | :--- |
| `task-world` | `TSK-00` | Establishes deterministic baseline data: 15+ multi-domain categories, 8 people, 6 task types with codes, dynamic task type statuses, candidate actions (`Calculate Expression`, `Color Converter`), and 3 divergent project hierarchies (Software Dev, Corporate HQ Construction, Heritage Documentary Film). |
| `task-hierarchy` | `TSK-01` | Evaluates parent/child task creation, depth querying, and multi-domain hierarchy integrity. |
| `task-dependencies` | `TSK-02` | Tests `FinishToStart` dependency graph links and critical path chains. |
| `task-assignments` | `TSK-03` | Evaluates polymorphic task assignments (People and AI Agents) across distinct operational roles. |
| `task-decisions` | `TSK-04` | Tests formal task decisions, sign-off outcomes, and approver audit tracking. |
| `task-templates` | `TSK-05` | Evaluates task template instantiation with category and schedule offsets. |
| `task-statuses` | `TSK-06` | Tests dynamic `TaskTypeStatus` defaulting on task creation, stage transitions across `MacroStatus` values, and terminal auto-completion. |
| `task-action-hooks` | `TSK-07` | Validates non-blocking event-driven Action hook dispatch (`OnCreate`, `OnStatusChange`, `OnEnterStatus`, `OnExitStatus`) with universal task payload. |
| `meetings` | `M1`–`M8` | Meetings over the wire: a meeting from the Team type with its agenda, the organizer's row and its `.ics` (M1); a weekly series' occurrences, with the series' attendees, a change reaching the untouched ones (M2); the status moves, the organizer starting the meeting as a UI-only user and someone else refused (M3); a Private meeting, its attendees, agenda and notes read by its attendees only (M4); who writes an attendee over the wire, a UI user unable to invite himself, answer for another or remove anyone, answering his own row, the organizer inviting and removing (M6); a Private series and who it invites read by its organizer and invitees only, a Standard one by all (M7); who writes a note and the agenda, an invited UI user writing a note and changing only his own, a stranger writing nothing, the agenda the organizer's (M8); a cancellation telling the fake video driver after the commit (M5). M3 and M4 sign in as two UI-only people (`ivy.meets@`, `jun.meets@task-world.test`) with keys minted for the run (`persona-provider.ts`); M5 needs MJAPI started with `--import <this package>/dist/video-stub.js`. |

## Running Tests

```bash
# Build integration tests bundle
pnpm --filter @mj-biz-apps/tasks-integration-tests build

# Run unit / registration tests
pnpm --filter @mj-biz-apps/tasks-integration-tests test
```
