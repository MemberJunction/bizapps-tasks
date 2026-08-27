# @mj-biz-apps/tasks-entities

## 1.4.0

### Minor Changes

- 0064e26: Drop the form-chrome record naming `MJ_BizApps_Accounting: Journal Entry Batches` — Tasks metadata must not reference consumer apps, and the unresolvable `@lookup` rolled back the entire metadata push on any install without Accounting. Ship the v1.2.x metadata sync migration so a migrations-only install carries the full form chrome, display-name pins, and application settings with no `mj sync push` required.
- 0592ecc: Scope CodeGen heal EXECs with authored excludeSchemas plus `@IncludedSchemaNames` for the Tasks schema, instead of photographing sibling Open Apps.

## 1.3.0

### Minor Changes

- 90418c2: Task and Person form chrome uses L1 inclusion. Tasks stay Primary on Person; comments, assignments, decisions, and activities are None.
- 178cced: Task form uses left-nav. Both Task Dependencies grids (TaskID and DependsOnTaskID) are None — the sub-tasks gantt already plots those links. Tag links and notification logs are None. Created-by Tasks on Person are None.
- f2a41f2: Park Tasks created by a Person (CreatedByPersonID) in More on the Person form. Assignee is polymorphic, so there is no People→Task Assignments PersonID relationship to mark.
- 52e9d2d: feat(tasks): TaskType Code, dynamic TaskTypeStatus, and workflow action triggers

  - Adds unique `Code` and event-driven action triggers (`OnCreateActionID`, `OnStatusChangeActionID`) to `TaskType`.
  - Introduces `TaskTypeStatus` entity for customizable per-type task stages with `OnEnterActionID` and `OnExitActionID` lifecycle hooks.
  - Extends `TaskEntityServer` with automated `TaskTypeStatus` synchronization and universal payload action execution for downstream workflows and AI Flow Agents.

### Patch Changes

- 3431e79: Declare BUSL-1.1 in mj-app.json. The LICENSE file and every package
  already state BUSL-1.1; the app manifest still said ISC, so anything
  reading the manifest saw the wrong license.

## 1.2.3

### Patch Changes

- 256fea5: Unify every `@memberjunction/*` range at the estate-wide floor `^6.1.0-edge.2`,
  replacing the `^6.1.0-edge.1` ranges this repo published in 1.2.2.

  A `patch`: the convention reserves `minor` for migration and metadata changes, and this
  carries neither — only dependency ranges move, and no application source changed.

  **Why this matters beyond tidiness.** Two of the ranges are declared on
  `@mj-biz-apps/tasks-ng` as _peer_ dependencies — `@memberjunction/ng-gantt` and
  `@memberjunction/ng-kanban` — so they are part of this package's published contract, not a
  private implementation detail. While they say `^6.1.0-edge.1`, every downstream consumer
  that installs `tasks-ng` resolves an edge.1 tree even when the consumer itself has moved to
  edge.2. In `bizapps-issues` that materialised ~244 `@memberjunction` packages at
  `6.1.0-edge.1` sitting alongside the edge.2 set, which is the duplicate-copy condition the
  one-copy census exists to catch. Bumping the consumer cannot fix it; the range has to move
  here and be republished.

## 1.2.2

### Patch Changes

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

- 835d116: Migrate the workspace from npm to pnpm and remove the MJAPI/MJExplorer dev harness.

  No published package's code, types, metadata or migrations change — this is build tooling
  plus the deletion of two private, unpublished apps, which is why it is a patch.

  **pnpm migration.** `packageManager` moves to `pnpm@10.33.0`, `package-lock.json` is replaced
  by `pnpm-lock.yaml`, npm-only `.npmrc` keys are dropped, and CI installs with
  `pnpm install --frozen-lockfile`. Two workspace settings are load-bearing and mirror MJ core:
  `linkWorkspacePackages: true` (pnpm 10 defaults it false, which resolves this repo's
  exact-pinned internal packages from the registry instead of linking them locally) and an
  `onlyBuiltDependencies` allowlist (pnpm 10 runs no dependency build scripts without one).

  **The dev harness is gone.** `apps/MJAPI` and `apps/MJExplorer` were private and unpublished;
  the `@mj-biz-apps/tasks-*` packages are what this repo ships. They existed because there was
  no way to exercise the app against a real MJ instance, and MJ 6.x workspace linking now
  provides one. Removing them also retires a real failure: under pnpm's default layout an
  in-repo MJAPI cannot boot, because `@memberjunction/server` resolves to two physical copies
  (same version, different peer-resolution hashes) and type-graphql's process-global metadata
  storage then sees a duplicate `RunViewByIDInput`. With no app in the repo there is no process
  to fail, and pnpm's strict resolution is kept.

  **`mj:migrate` was broken and is fixed.** It was bare `mj migrate` with no `--schema` or
  `--dir`, so it reported "0 applied" and silently did nothing — the app's own migrations could
  not be applied through it at all. It is now
  `mj migrate --schema __mj_BizAppsTasks --dir ./migrations`, matching bizapps-common.

  **The publish step that derived `mj-app.json`'s bizapps-common range is deleted rather than
  repointed.** It read the range from `apps/MJAPI/package.json`, which no longer exists — and
  that was always the wrong source: it took an _npm_ dependency version and wrote it into a
  _schema-compatibility_ field. This repo has **zero** npm dependencies on bizapps-common; the
  coupling is four SQL foreign keys into `__mj_BizAppsCommon.Person`
  (`Task.CreatedByPersonID`, `TaskAssignment.AssignedByPersonID`, `TaskComment.PersonID`,
  `TaskDecision.DecidedByPersonID`). The manifest range stays `>=5.33.1 <6.0.0` and is now
  hand-maintained: it should change only when the referenced schema changes, not when a
  packaging release ships.

  Verified against a live database: 6/6 build, 65/65 tests, `pnpm install --frozen-lockfile`
  clean, app migrations apply (4 applied, 19 tables, `Person` foreign keys resolved), and
  CodeGen completes (412 entities, AFTER commands clean).

## 1.2.1

### Patch Changes

- 8487cf1: Upgrade to MemberJunction 6.1.0-edge.1.

  Every `@memberjunction/*` dependency and peer range moves from 5.44.0 to the
  exact `6.1.0-edge.1` prerelease, and the Open App manifest's `mjVersionRange`
  becomes `>=6.1.0-edge.1 <7.0.0`. **Hosts must be on a MemberJunction 6.x
  environment** — `latest` is still 5.51.0 and never resolves an edge build.

  `@mj-biz-apps/common-*` moves to 5.33.1, the first bizapps-common build that
  peers on the MJ 6.x line; anything older would pull a second MJ major into the
  tree.

  No source changes were required. Nothing between 5.44.0 and 5.51.0 was breaking,
  and 6.x's sole documented breaking change — removing the 36 vendor connectors
  from `@memberjunction/integration-connectors` — is in a package this app neither
  depends on nor imports.

  Bumped as a patch because this repo's release policy keys the version line to
  migrations: `publish.yml` reserves minor for releases that add migration files
  and major for explicit major changesets. This upgrade adds none.

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

## 1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.

## 1.1.0

### Minor Changes

- 160cf67: Approval/decision workflow primitives for tasks, plus MJ-token theming.

## 1.0.1
