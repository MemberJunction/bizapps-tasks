# @mj-biz-apps/tasks-ng

## 1.4.0

### Minor Changes

- 0064e26: Drop the form-chrome record naming `MJ_BizApps_Accounting: Journal Entry Batches` — Tasks metadata must not reference consumer apps, and the unresolvable `@lookup` rolled back the entire metadata push on any install without Accounting. Ship the v1.2.x metadata sync migration so a migrations-only install carries the full form chrome, display-name pins, and application settings with no `mj sync push` required.
- 0592ecc: Scope CodeGen heal EXECs with authored excludeSchemas plus `@IncludedSchemaNames` for the Tasks schema, instead of photographing sibling Open Apps.

### Patch Changes

- Updated dependencies [0064e26]
- Updated dependencies [0592ecc]
  - @mj-biz-apps/tasks-entities@1.4.0
  - @mj-biz-apps/tasks-core@1.4.0

## 1.3.0

### Minor Changes

- f49dd48: Open a Task record through SharedService (no optional NavigationService no-op). Generated Task form gets an identity header plus a Gantt/Kanban sub-task contribution and left-nav FormRole chrome.
- 52e9d2d: feat(tasks): TaskType Code, dynamic TaskTypeStatus, and workflow action triggers

  - Adds unique `Code` and event-driven action triggers (`OnCreateActionID`, `OnStatusChangeActionID`) to `TaskType`.
  - Introduces `TaskTypeStatus` entity for customizable per-type task stages with `OnEnterActionID` and `OnExitActionID` lifecycle hooks.
  - Extends `TaskEntityServer` with automated `TaskTypeStatus` synchronization and universal payload action execution for downstream workflows and AI Flow Agents.

### Patch Changes

- efe3791: feat(tasks-ng): add TaskCategoryHierarchyPanel with @memberjunction/ng-hierarchy-tree

  - Adds `TaskCategoryHierarchyPanel` to `MJ_BizApps_Tasks: Task Categories` in the `after-related` slot for interactive portfolio category hierarchy visualization.
  - Polishes Gantt flex layout and height responsiveness.

- d0f50a4: Gantt on the Tasks dashboard opens the detail slide-in only on double-click, so single-click stays available for native DHTMLX selection, drag, and zoom.
- 1c87a4a: Tasks Gantt persists grid pane width and column widths with zoom in `mj.tasks.gantt.v1` (still reads the old zoom-only key). Other apps keep their own settings.
- ec7cb35: Task Gantt status legend dots use MJ status/brand tokens instead of hardcoded hex.
- f7b01ea: Task Gantt starts one step zoomed out (month), adds +/- controls, and persists the preferred zoom level via UserInfoEngine (`mj.tasks.ganttZoom.v1`).
- 3431e79: Declare BUSL-1.1 in mj-app.json. The LICENSE file and every package
  already state BUSL-1.1; the app manifest still said ISC, so anything
  reading the manifest saw the wrong license.
- Updated dependencies [90418c2]
- Updated dependencies [178cced]
- Updated dependencies [f2a41f2]
- Updated dependencies [3431e79]
- Updated dependencies [52e9d2d]
  - @mj-biz-apps/tasks-entities@1.3.0
  - @mj-biz-apps/tasks-core@1.3.0

## 1.2.3

### Patch Changes

- Updated dependencies [256fea5]
  - @mj-biz-apps/tasks-entities@1.2.3
  - @mj-biz-apps/tasks-core@1.2.3

## 1.2.2

### Patch Changes

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

- Updated dependencies [3f6aa3d]
- Updated dependencies [4a0fba5]
- Updated dependencies [835d116]
  - @mj-biz-apps/tasks-core@1.2.2
  - @mj-biz-apps/tasks-entities@1.2.2

## 1.2.1

### Patch Changes

- Updated dependencies [8487cf1]
  - @mj-biz-apps/tasks-entities@1.2.1
  - @mj-biz-apps/tasks-core@1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

### Patch Changes

- Updated dependencies [d540e69]
  - @mj-biz-apps/tasks-entities@1.2.0
  - @mj-biz-apps/tasks-core@1.2.0

## 1.1.2

### Patch Changes

- Updated dependencies [290772b]
  - @mj-biz-apps/tasks-core@1.1.2
  - @mj-biz-apps/tasks-entities@1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.
- Updated dependencies [fc7918b]
  - @mj-biz-apps/tasks-entities@1.1.1
  - @mj-biz-apps/tasks-core@1.1.1

## 1.1.0

### Minor Changes

- 160cf67: Approval/decision workflow primitives for tasks, plus MJ-token theming.

### Patch Changes

- Updated dependencies [160cf67]
  - @mj-biz-apps/tasks-entities@1.1.0
  - @mj-biz-apps/tasks-core@1.1.0

## 1.0.1

### Patch Changes

- 9f5e38a: Added class registration that was missed
  - @mj-biz-apps/tasks-core@1.0.1
  - @mj-biz-apps/tasks-entities@1.0.1
