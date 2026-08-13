# @mj-biz-apps/tasks-entities

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
