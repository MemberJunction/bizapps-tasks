# Publishing Setup — bizapps-tasks

This repo publishes the five `@mj-biz-apps/tasks-*` packages to npm using a
Changesets-based pipeline, modeled on **bizapps-common** (`MemberJunction/bizapps-common`).
The workflow files, validator scripts, `ci/` helpers, and Changesets config are
already in place.

## Branch model

```
feature branch ──PR──▶ next ──(merge)──▶ main ──(push triggers publish.yml)──▶ npm
```

- PRs land on **`next`**. `build.yml` + `changes.yml` run as checks.
- Changesets (`.changeset/*.md`) accumulate on `next`. A migration-bearing PR to
  `next` is *required* to include a changeset (`changes.yml` enforces this).
- Releasing = merging **`next` → `main`**. The push to `main` fires `publish.yml`,
  which (if pending changesets exist) bumps the fixed version across all five
  packages, builds, `changeset publish` to npm, tags `vX.Y.Z`, commits the bump
  back to `main`, then merges `main` → `next` and refreshes the lockfile.
- If there are **no** pending changesets, a push to `main` is a no-op.

> **Branch protection:** like bizapps-common, `main` is **not** protected. The
> "publish only flows next→main" rule is a *convention*, enforced by discipline,
> not by a ruleset. `publish.yml` pushes the version-bump commit back to `main`
> using the default `GITHUB_TOKEN`, which works because `main` is open.

## npm authentication — OIDC (no NPM_TOKEN secret)

This repo publishes via **npm OIDC trusted publishing**, the same as
bizapps-common. The workflow declares `id-token: write` and npm verifies the
GitHub Actions OIDC identity at publish time — there is **no `NPM_TOKEN` secret**
to manage.

One-time setup on npmjs.com (per package, by an `@mj-biz-apps` org owner): under
each package's **Settings → Trusted Publisher**, add this repo
(`MemberJunction/bizapps-tasks`) and the `publish.yml` workflow. Trusted
publishing can only be configured *after* the package exists, so it happens
together with the placeholder publish below.

## First publish — npm placeholders

The five packages do **not** yet exist on npm (all return 404), and
`validate-npm-packages.sh` fails the publish job until every package has at least
a placeholder version published. Publish a `0.0.0` placeholder for each **once,
manually**, then the automated flow takes over:

- `@mj-biz-apps/tasks-entities`
- `@mj-biz-apps/tasks-core`
- `@mj-biz-apps/tasks-actions`
- `@mj-biz-apps/tasks-server`
- `@mj-biz-apps/tasks-ng`

After publishing each placeholder, configure its **Trusted Publisher** on npm
(see above) so the automated OIDC publish works.

## Checklist

- [ ] Publish `0.0.0` placeholders for all five packages (manually, with a token)
- [ ] Configure npm Trusted Publisher for each package → `MemberJunction/bizapps-tasks` / `publish.yml`
- [ ] Land a changeset on `next`, merge `next` → `main`, confirm `publish.yml` publishes + tags

## Notes / divergences from bizapps-common

- **Migration validators are currently inert**: tasks's schema migration is
  `B`-prefixed (Flyway baseline), but `validate-migration-filenames.sh` and the
  timestamp/changeset gates in `changes.yml` only match `V[0-9]{12}` files. They
  pass vacuously today. If future migrations use the `V` prefix, the gates
  activate automatically.
