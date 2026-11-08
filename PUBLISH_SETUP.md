# Publishing Setup — bizapps-tasks

This repo publishes the five `@mj-biz-apps/tasks-*` packages to npm with the open-app release
pipeline shared across the BizApps repos. The release workflows and their scripts are copied
byte-for-byte from **bizapps-issues** and must stay identical; checks specific to this repo live
in `.github/workflows/repo-checks.yml`.

## Branch model

```
feature branch ──PR──▶ next ──(App opens Version Packages PR)──▶ main ──(publish.yml)──▶ npm
```

- PRs land on **`next`** with a changeset (`pnpm run change`). A migration or `metadata/`
  change needs at least a **`minor`** changeset (`migration changeset` check).
- Every push to `next` refreshes **one Version Packages PR** (`changeset-release/main` → `main`),
  opened by the `blue-cypress-ci-bot` GitHub App (`version.yml`). It runs
  `pnpm run version:prepare`: `changeset version`, the `mj-app.json` version and MJ range sync
  (`ci/sync-mj-app-version.mjs`), and a lockfile refresh.
- **Merging that PR is the release.** `release-readiness.yml` gates it (`rr:` checks: no pending
  changesets, bump level, metadata shipped, Postgres counterparts, release base current,
  migration immutability, packages on npm). The push to `main` runs `publish.yml`, which
  publishes over npm OIDC, tags `vX.Y.Z`, then the App opens and merges a
  `release-back-merge/vX.Y.Z` PR into `next`.
- There is no hand-opened `next` → `main` PR, and nothing commits to `main` directly.

## npm authentication — OIDC (no NPM_TOKEN secret)

`publish.yml` declares `id-token: write`; npm verifies the GitHub Actions OIDC identity at publish
time. Each package's **Settings → Trusted Publisher** on npmjs.com must name
`MemberJunction/bizapps-tasks` and the `publish.yml` workflow.

## Org setup

- The `blue-cypress-ci-bot` App is installed on this repo, and the org `APP_CLIENT_ID` variable
  and `APP_PRIVATE_KEY` secret reach it.
- Rulesets: `protect-next` (PR required, the four door checks, strict; App bypass for pull
  requests only) and `protect-main` (the seven `rr:` checks plus `build`, one approval).

## Notes

- `migrations/` holds a `B`-prefixed Flyway baseline; the filename and changeset checks match the
  `V…` files added after it.
- Every new `migrations/*.sql` needs a `migrations-pg/` counterpart
  (`pnpm run mj:migrate:convert`). A PR without one gets a warning; `rr: pg counterparts` fails
  the release until it exists.
