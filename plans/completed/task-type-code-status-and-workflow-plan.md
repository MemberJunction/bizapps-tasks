# Plan: TaskType Code, Dynamic Task Type Statuses, and Workflow Hooks

## 1. Objectives & Overview
Upgrade the `bizapps-tasks` application to support:
1. **Programmatic Identification (`Code`)**:
   - Add unique `Code` column to `TaskType` (`NVARCHAR(50) NOT NULL UNIQUE`).
   - Backfill existing standard task types: `GENERAL`, `ACTION_ITEM`, `FOLLOW_UP`, `DELIVERABLE`, `APPROVAL_REQUEST`.
2. **Lifecycle Workflow Triggers on `TaskType`**:
   - Add `OnCreateActionID` (`uniqueidentifier NULL` -> `MJ: Actions`).
   - Add `OnStatusChangeActionID` (`uniqueidentifier NULL` -> `MJ: Actions`).
   - Retain existing hooks: `OnAssignActionID`, `OnCompleteActionID`, `OnOverdueActionID`, `OnPercentChangeActionID`, `OnRejectActionID`, `OnCancelActionID`.
3. **Dynamic Task Type Statuses (`TaskTypeStatus`)**:
   - Create new table `TaskTypeStatus` to allow task types to define domain-specific stages while mapping back to core macro-states (`Open`, `InProgress`, `Blocked`, `Completed`, `Cancelled`).
   - Include per-status hooks (`OnEnterActionID`, `OnExitActionID`).
   - Add `TaskTypeStatusID` to `Task` table.
4. **MemberJunction Workflow Engine & Downstream App Extensibility**:
   - Enable downstream apps (Contracts, Sales, etc.) to define domain task types and workflows via metadata.
   - Leverage `TaskEntityServer` (the server-only `BaseEntity` subclass) for authoritative event dispatching and action execution.

---

## 2. Step-by-Step Execution Plan

### Step 1: Database Migration (Hand-written DDL)
Create migration file `migrations/V202608200800__v1.2.x_TaskType_Code_Statuses_Workflow_Hooks.sql`:
- **Table `TaskType`**:
  - `ALTER TABLE ${flyway:defaultSchema}.TaskType ADD Code NVARCHAR(50) NULL;`
  - Backfill existing rows by `Name`.
  - `ALTER TABLE ${flyway:defaultSchema}.TaskType ALTER COLUMN Code NVARCHAR(50) NOT NULL;`
  - `ALTER TABLE ${flyway:defaultSchema}.TaskType ADD CONSTRAINT UQ_TaskType_Code UNIQUE (Code);`
  - `ALTER TABLE ${flyway:defaultSchema}.TaskType ADD OnCreateActionID UNIQUEIDENTIFIER NULL;`
  - `ALTER TABLE ${flyway:defaultSchema}.TaskType ADD OnStatusChangeActionID UNIQUEIDENTIFIER NULL;`
  - Add FK constraints to `${mjSchema}.[Action](ID)`.
  - Add extended property documentation.
- **Table `TaskTypeStatus`**:
  - Create table with `ID`, `TaskTypeID`, `Name`, `Code`, `Description`, `MacroStatus`, `Sequence`, `IsDefault`, `IsTerminal`, `Color`, `IconClass`, `OnEnterActionID`, `OnExitActionID`, `IsActive`, `__mj_CreatedAt`, `__mj_UpdatedAt`.
  - Add constraints: `PK_TaskTypeStatus`, `FK_TaskTypeStatus_TaskType` (ON DELETE CASCADE), `UQ_TaskTypeStatus_TaskType_Code`, `UQ_TaskTypeStatus_TaskType_Name`, `CK_TaskTypeStatus_MacroStatus`, `FK_TaskTypeStatus_OnEnterAction`, `FK_TaskTypeStatus_OnExitAction`.
  - Add extended properties.
- **Table `Task`**:
  - `ALTER TABLE ${flyway:defaultSchema}.Task ADD TaskTypeStatusID UNIQUEIDENTIFIER NULL;`
  - Add FK constraint `FK_Task_TaskTypeStatus` referencing `${flyway:defaultSchema}.TaskTypeStatus(ID)`.
  - Add extended property documentation.

### Step 2: Apply Migration to Database
- Run the migration script against `bizapps_orders` on `localhost:1433`.

### Step 3: Run MemberJunction CodeGen & Append Output
- Run `npx mj codegen` (or `pnpm run codegen`) in `bizapps-tasks` with `excludeSchemas` scoping to `__mj_BizAppsTasks`.
- Capture generated migration SQL from `migrations/codegen/`.
- Append to `migrations/V202608200800__v1.2.x_TaskType_Code_Statuses_Workflow_Hooks.sql` after 50 blank lines and the standard CodeGen comment block.

### Step 4: Update Metadata Seed Files & Push
- Update `metadata/task-types/.task-types.json` with `Code` properties.
- Run `mj sync push --dir ./metadata`.

### Step 5: Build & Verify TypeScript/Angular Packages
- Rebuild `@mj-biz-apps/tasks-entities`, `@mj-biz-apps/tasks-actions`, `@mj-biz-apps/tasks-server`, and `@mj-biz-apps/tasks-ng`.
- Run unit tests to verify zero regressions.

### Step 6: Commit and Push
- Stage the clean migration, metadata, and generated entity/Angular files.
- Commit and push to origin branch `an-dev-3`.

### Step 7: Server Subclass Architecture (`TaskEntityServer`)
- Study `packages/EntitiesServer/src/TaskEntityServer.ts` and propose the execution architecture for lifecycle hooks and `TaskGraphSpec` / Action triggering.
