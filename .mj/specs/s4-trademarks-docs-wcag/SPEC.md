# Sub-Epic S4: Domain-Neutral Terminology Sweep, Documentation Anchor Repair & WCAG 2.1 AA Citation Fix

- **Epic**: `3208ED67-B2DF-4D99-BE45-04627C67D68E`
- **Approved FactoryPlan**: `CC3FD61F-7677-4D84-8F3F-925A18A4EEFC` (v2)
- **Repository**: `MemberJunction/bizapps-tasks`
- **Pull Request**: `#222` (`factory/3208ed67-b2df-4d99-be45-04627c67d68e-s4-trademarks-docs-wcag` -> `next`)

## 1. Architecture & Scope Summary

### 1.1 Domain-Neutral Terminology Sweep (Slices 1 & 2)
- Standardized Angular components, widgets, Core services, Actions, Entities/Server descriptions, package READMEs, metadata descriptions/prompts, root `README.md`, `guides/**`, `docs/**`, and `.mj/specs/**` on domain-neutral MemberJunction terminology (`Board View`, `Kanban Board`, `Work Reports`, `Daily Work Report`, `daily-work-report`, `2x HiDPI`).
- Preserved all public TypeScript class/interface exports, entity/field names, `@lookup:` metadata sync keys, `MJ: AI Agent Rhythm Templates` core entity references, zero-`any`/zero-`unknown` typing, zero `BaseEntity.Get()/Set()`, and `--mj-*` semantic CSS design tokens.

### 1.2 Documentation Anchor Repair & WCAG 2.1 AA Citation Alignment (Slice 2)
- Renamed `guides/WORK_BUS_AND_WORK_REPORTS_GUIDE.md` and updated all cross-links in `README.md`, `guides/TASK_WORKFLOW_AND_LIFECYCLE_GUIDE.md`, and `packages/Angular/src/lib/__tests__/goals-view-and-okr-steering.test.ts`.
- Repaired the `README.md` Components header anchor (`#10-reusable-angular-components--full-dashboard-app`) and verified all `guides/**`, `docs/**`, and `README.md` internal links resolve cleanly.
- Replaced the misattributed WCAG 2.2 criterion under WCAG 2.1 AA claims in `guides/TASKS_UX_ORGANIZATION_AND_BULK_OPS_GUIDE.html` with `WCAG 2.4.7 Focus Visible`.

### 1.3 Automated CI Guards & Release Hygiene (Slice 3)
- Added [`scripts/verify-trademarks.mjs`](../../../scripts/verify-trademarks.mjs) (`pnpm run check:trademarks`): zero-dependency ESM scanner over `packages/**`, `metadata/**`, `guides/**`, `docs/**`, `.mj/specs/**`, and `README.md` enforcing word-boundary/case-aware trademark rules (without false-positiving on `taskIds`/`IDs` or `MJ: AI Agent Rhythm Templates`) and blocking WCAG 2.2 criterion misattribution under WCAG 2.1 AA claims.
- Added [`scripts/verify-doc-anchors.mjs`](../../../scripts/verify-doc-anchors.mjs) (`pnpm run check:doc-anchors`): zero-dependency ESM Markdown/HTML anchor resolver verifying internal `#...` and cross-document links across `guides/**`, `docs/**`, and `README.md`.
- Added [`scripts/__tests__/verify-guards.test.mjs`](../../../scripts/__tests__/verify-guards.test.mjs) (`pnpm run test:scripts`): deterministic `node:test` positive and negative fixture suite using temporary directories cleaned up in `finally`.
- Wired `check:trademarks`, `check:doc-anchors`, and `test:scripts` into [`.github/workflows/repo-checks.yml`](../../../.github/workflows/repo-checks.yml) alongside `check:standards` on `pull_request` (`next`, `main`, `lts/**`) and `push`, with concurrency cancellation and explicit job timeouts.
- Added [`.changeset/s4-trademarks-docs-wcag.md`](../../../.changeset/s4-trademarks-docs-wcag.md) covering all 7 modified publishable `@mj-biz-apps/*` packages.
