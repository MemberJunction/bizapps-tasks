---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-integration-tests": minor
---

Chief of Staff extension. MJ core's Chief of Staff no longer knows about BizApps (MemberJunction/MJ#6193); this app now extends it:

- **Priorities & To-dos page** (`@mj-biz-apps/tasks-ng`, driver class `BizAppsTasksChiefOfStaffPriorities`): the signed-in person's open to-dos and the priority objectives in their scope, with milestones, owners, assignees and progress, health filter and search. Added to the Chief of Staff application by the `NavItem.bizapps-tasks.chief-of-staff` application setting (metadata `chief-of-staff-nav-items`), which MJ core's `BaseApplication.GetNavItems()` reads.
- **Chief of Staff Tasks & Priorities skill** (metadata `chief-of-staff-skills`), granted to the Chief of Staff agent: how to resolve the user's People record, read and create objectives, milestones and assignments, and keep to-dos.
- **Helpers** (`@mj-biz-apps/tasks-core`): `ResolvePersonTaskScope`, `LoadTaskAssignees`, `BuildPrioritySummary`, to-do and filter helpers, moved from MJ core with their tests. Every query takes an optional `contextUser` for server-side callers.
- **Teardown** (`teardown/`, `teardown-pg/`, `migrations.teardownDirectory`): `mj app remove` deletes the skill, its grant and usage links, and the nav-item setting from the core schema.
- **Integration bundle `task-chief-of-staff`** (TSK-08): skill and grant installed, nav item well-formed, and a person's task scope checked against the real Tasks view.

Requires an MJ release with the Chief of Staff application and `NavItem.*` application settings.
