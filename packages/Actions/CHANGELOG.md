# @mj-biz-apps/tasks-actions

## 1.14.0

### Minor Changes

- 934d7bb: Meetings, a first-class app in Tasks (T1 of the meetings plan): ten tables for meetings, series, attendees, agendas and their item types, notes, links, meeting types and video providers, with CodeGen's output; the rules on the server (times and zone, the status moving forward with starting, ending and cancelling the organizer's, the organizer's attendee row, a series' rule parsed and its occurrences made after the commit, an agenda's tree, an attendee's MJ user filled from the person); the services (a meeting from a type with its agenda template, start/end/cancel, series materialization, agenda carry-forward, the `.ics` file); the daily series job; and the metadata: meeting and agenda item types, the three video providers (inactive) and their credential type, the Meetings application, the UI role's grants and Tasks' first row-level security filters (a Private meeting is read by its attendees only).

  Needs MemberJunction 6.2.1, the repository's floor: the after-commit work (a series' occurrences, the video provider's delete) runs through the database provider's `RunAfterCommit`. While the PostgreSQL migration counterpart (`migrations-pg/`) and `PlatformVariants` on the row-level security filters are shipped for schema parity, runtime RLS evaluation for UI-role users requires SQL Server until MemberJunction Core wires `GetPlatformFilterText` into `MarkupFilterText`.

## 1.13.0

## 1.12.0

## 1.11.1

## 1.11.0

## 1.10.0

## 1.9.0

## 1.8.0

## 1.7.2

## 1.7.1

## 1.7.0

### Minor Changes

- 8e01ce2: A task type can post each new assignment to a Microsoft Teams channel.

  - New action **Post Task Assignment to Teams** (`Tasks.PostAssignmentToTeams`). Set it as a Task Type's `OnAssignActionID`. It posts an Adaptive Card with the task, the assignee and, when the credential has an `explorerUrl`, a link to the task.
  - The webhook URL lives in a credential of the new **Teams Channel Webhook** type. The action uses the credential named in `CredentialName`, else the one named after the task type's `Code`, else the type's default. Office 365 connector and Power Automate Workflows webhook URLs are both accepted. A fallback to the default credential is logged. A `TaskTypeID` that is not a UUID fails with `INVALID_TASK_TYPE`. Task, type and assignee names are markdown-escaped on the card.
  - The OnAssign hook now also passes `TaskTypeID`, `AssigneePersonID` and `AssigneeName`. It runs whether or not the assignee has a linked MJ user, and when the in-app notification throws. Before, an assignee without one got neither the in-app notification nor the hook.
  - Metadata adds the `Tasks` action category, the action and the credential type. `mj sync push` orders them before the folders that reference them.

### Patch Changes

- 209989d: MemberJunction and other BizApps packages are peer dependencies with caret ranges (nothing in `dependencies`), so a host keeps one copy of each. `@memberjunction/ng-hierarchy-tree` moved from `tasks-ng`'s `dependencies` to `peerDependencies`; every MemberJunction peer has an exact `devDependencies` anchor for local builds. Adds `check-dependency-model` to CI.

## 1.6.2

## 1.6.1

## 1.6.0

### Minor Changes

- e9cf427: The UI role's task grants live in metadata/entities/.ui-role-permissions.json and are applied with mj sync push. Create and update cover tasks, comments, and assignments. Create covers tag links, tags, roles, decisions, and activities. Delete covers assignments and tag links. The list and board reload when their filter changes, and the list indents by depth. TaskClicked stays the task id. TaskRowClicked carries the id and name. The edit panel reads the People id from metadata before it saves, accepts a parent-list filter, and reports a refused save.

## 1.5.0

## 1.4.3

### Patch Changes

- 921648d: License declarations now agree on BUSL-1.1 everywhere.

  The README badge was the last thing in the repo still advertising ISC — `LICENSE`,
  `package.json`, `mj-app.json`, the README's own License section and every workspace package
  already declare BUSL-1.1. A green ISC badge at the top of the README is the first thing a
  reader sees, so it outranked all of them in practice. The badge now reads BUSL-1.1 and links
  to `LICENSE`.

## 1.4.2

## 1.4.1

## 1.4.0

## 1.3.0

### Patch Changes

- 3431e79: Declare BUSL-1.1 in mj-app.json. The LICENSE file and every package
  already state BUSL-1.1; the app manifest still said ISC, so anything
  reading the manifest saw the wrong license.

## 1.2.3

## 1.2.2

### Patch Changes

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

## 1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

## 1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.

## 1.1.0

## 1.0.1
