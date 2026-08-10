---
"@mj-biz-apps/tasks-entities": patch
---

Migrate the workspace from npm to pnpm and remove the MJAPI/MJExplorer dev harness.

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
that was always the wrong source: it took an *npm* dependency version and wrote it into a
*schema-compatibility* field. This repo has **zero** npm dependencies on bizapps-common; the
coupling is four SQL foreign keys into `__mj_BizAppsCommon.Person`
(`Task.CreatedByPersonID`, `TaskAssignment.AssignedByPersonID`, `TaskComment.PersonID`,
`TaskDecision.DecidedByPersonID`). The manifest range stays `>=5.33.1 <6.0.0` and is now
hand-maintained: it should change only when the referenced schema changes, not when a
packaging release ships.

Verified against a live database: 6/6 build, 65/65 tests, `pnpm install --frozen-lockfile`
clean, app migrations apply (4 applied, 19 tables, `Person` foreign keys resolved), and
CodeGen completes (412 entities, AFTER commands clean).
