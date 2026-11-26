<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/MemberJunction/MJ/raw/main/MJ_logo_dark.png">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/MemberJunction/MJ/raw/main/MJ_logo.webp">
    <img alt="MemberJunction" src="https://github.com/MemberJunction/MJ/raw/main/MJ_logo.webp" width="220">
  </picture>
</p>

<h1 align="center">BizApps Tasks</h1>

<p align="center">
  <strong>Reusable task management for the <a href="https://github.com/MemberJunction/MJ">MemberJunction</a> platform</strong>
</p>

<p align="center">
  <a href="#installation">Install</a> &middot;
  <a href="#entity-model">Entity Model</a> &middot;
  <a href="#row-level-security--chain-of-command-visibility">Security &amp; RLS</a> &middot;
  <a href="#10-reusable-angular-components--full-dashboard-app">Components</a> &middot;
  <a href="#using-bizapps-tasks-in-your-code">Usage</a>
</p>

<p align="center">
  <img alt="MJ Version" src="https://img.shields.io/badge/MemberJunction-6.2.0%2B-blue?style=flat-square" />
  <img alt="Angular" src="https://img.shields.io/badge/Angular-21-DD0031?style=flat-square&logo=angular&logoColor=white" />
  <img alt="TypeScript" src="https://img.shields.io/badge/TypeScript-5.9-3178C6?style=flat-square&logo=typescript&logoColor=white" />
  <a href="./LICENSE"><img alt="License: BUSL-1.1" src="https://img.shields.io/badge/License-BUSL--1.1-green?style=flat-square" /></a>
  <img alt="Node" src="https://img.shields.io/badge/Node-18%2B-339933?style=flat-square&logo=node.js&logoColor=white" />
</p>

---

Task management is a universal need across business applications -- committees track action items, projects track deliverables, teams track follow-ups. BizApps Tasks provides a complete, reusable task management system as a **MemberJunction Open App** that any MJ application can depend on, eliminating the need for each app to build its own.

Features include multi-person assignment with roles, sub-task hierarchies, dependency graphs, hours tracking, categories, tags, comments, activity logging, templates, and Kanban/Gantt views.

---

## Installation

BizApps Tasks is a [MemberJunction Open App](https://github.com/MemberJunction/MJ/tree/main/packages/OpenApp). Install it into any MJ environment using the [MJ CLI](https://github.com/MemberJunction/MJ/tree/main/packages/MJCLI):

```bash
mj app install https://github.com/MemberJunction/bizapps-tasks
```

This single command:

1. Fetches the `mj-app.json` manifest from this repository
2. Validates MJ version compatibility (`>=6.2.0 <7.0.0`)
3. Installs the dependency [BizApps Common](https://github.com/MemberJunction/bizapps-common) if not already present
4. Creates the `__mj_BizAppsTasks` database schema
5. Runs Skyway migrations to create all 27 tables with seed data
6. Installs npm packages into your MJAPI and MJExplorer workspaces
7. Configures server bootstrap (`@mj-biz-apps/tasks-server`) in `mj.config.cjs`
8. Adds client bootstrap (`@mj-biz-apps/tasks-ng`) to `open-app-bootstrap.generated.ts`

After installation, restart MJAPI and rebuild MJExplorer to activate.

### Manage the App

```bash
mj app list                     # See installed apps
mj app info bizapps-tasks       # Show details and version
mj app upgrade bizapps-tasks    # Upgrade to latest release
mj app disable bizapps-tasks    # Temporarily disable
mj app enable bizapps-tasks     # Re-enable
mj app remove bizapps-tasks     # Uninstall (--keep-data to preserve schema)
```

---

## Architecture & Lifecycle Guides

- [**Task Workflow & Lifecycle Guide**](./guides/TASK_WORKFLOW_AND_LIFECYCLE_GUIDE.md) — Deep dive on **Task Types**, **Dynamic Task Type Statuses (`TaskTypeStatus`)**, **Event-Driven Action Hooks**, **Flow Agent Integration**, and **Multi-Domain Project Structures**.
- [**Work Bus Extensions, Field Suggestions & Work Reports Guide**](./guides/WORK_BUS_AND_WORK_REPORTS_GUIDE.md) — Declarative IS-A subtype extensions (`TaskType.ExtensionEntity` + `SubtypeSelector`), `FIELD_SUGGESTION` review chips on `Tasks`, and **Work Reports** (`WorkReport`, `WorkReportItem`, Chief of Staff `Reports` resource, skill, and supervisor review handoff).
- [**Time Tracking, AI Agent Effort & Timesheets Guide**](./guides/TIME_TRACKING_GUIDE.md) — User, host administrator, and developer guide covering **Live Task Timers (`TaskTimer`)**, **Manual & Weekly Time Logging (`TaskTimeEntry`)**, **AI Agent Effort & Cost Rollups (`TaskAgentRun`)**, **Multi-Project Timesheet Approvals (`Timesheet`, `TimesheetApproval`, `BaseTimeApproverResolver`)**, and **Shipped Reporting Queries**.
- [**Tasks UX, Organization Scoping & Server-Side Bulk Operations Guide**](./guides/TASKS_UX_ORGANIZATION_AND_BULK_OPS_GUIDE.md) ([**Self-Contained Illustrated HTML Version w/ Embedded 2× HiDPI Screenshots**](./guides/TASKS_UX_ORGANIZATION_AND_BULK_OPS_GUIDE.html)) — Golden Hybrid 3-layer WCAG 2.1 AA UX architecture (`My Work` default tab, `All Work` List/Board/Gantt, **UserInfoEngine Saved Filter Views**, shared **Multi-View Bulk Action Dock** across Tree List, Board & Gantt, Zero-Bounce inline-saving Inspector, Express Create, Command Palette, Clean Selectable Approvals Split-Pane, Playbook Launcher, Dark Mode & Mobile `390px`), canonical **Organization / Company scoping** (`OrganizationID` on aggregate roots + parent inheritance), and **server-side Remotable Operations + Actions** (`BizAppsTasks.BulkUpdateTasks`, `BizAppsTasks.InstantiateTemplate`, `BizAppsTasks.RunRecurringPlaybooks`, `Run Recurring Playbooks`).
- [**OKR Deprecation & BizApps Planning Migration Guide**](./docs/OKR_DEPRECATION_AND_PLANNING_MIGRATION.md) — Documents the `1.x` deactivation (`IsActive = false`) of legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types while preserving OKR columns on `Task`, and migrating historical OKR tasks into **BizApps Planning** via **`Import Tasks OKRs`**.
- [**WorkReport & MeetingNote MJ Docs (`ArtifactID`) Convergence Spec**](./.mj/specs/add-additive-nullable-artifactid-fk-on-workreport-meetingnote-ca/SPEC.md) — Additive nullable `ArtifactID` foreign keys (`[__mj].[Artifact]([ID])`) on `WorkReport` (Category A) and `MeetingNote` (Category B) with split-bake PostgreSQL parity, batched `ArtifactDualReadResolver`, idempotent `Tasks.PublishMeetingNoteAsMJDoc` server action, Angular `<mj-artifact-viewer-panel>` integration, and Category A/B/C storage rubric.

---

## OKRs & Strategic Planning Migration (1.x Deprecation)

Strategic Objectives and Key Results (OKRs) are now managed in **BizApps Planning** (`MemberJunction/bizapps-planning`).

- **Deactivated Legacy Task Types (`IsActive = false`)**: In `1.x` installs and upgrades (`metadata/task-types/.task-types.json`, `migrations/V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.sql`, and `migrations-pg/V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.pg.sql`), the legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types are deactivated (`IsActive = false`) and excluded from active task type selectors and new task creation paths.
- **Deprecate-Then-Remove Column Compatibility**: All existing OKR columns on `__mj_BizAppsTasks.Task` (`BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure`, `MetricDirection`, `PlanningPeriod`, `CheckInCadence`, `HealthStatus`, `ConfidenceScore`) are preserved in `1.x` so existing legacy OKR tasks remain safely readable and generic measurable tasks continue to work.
- **Migrating Existing OKR Tasks**: Use the **`Import Tasks OKRs`** action in **BizApps Planning** (run with `DryRun: true` first to preview) to migrate existing `PRIORITY_OBJECTIVE` and `KEY_RESULT` tasks into `PriorityTask`, `CriticalNumber`, `CriticalNumberTarget`, and `PriorityKeyResult` records. See [`docs/OKR_DEPRECATION_AND_PLANNING_MIGRATION.md`](./docs/OKR_DEPRECATION_AND_PLANNING_MIGRATION.md) for full details.

---

## What You Get

### 40 Database Tables

All tables live in the `__mj_BizAppsTasks` SQL schema, deployed via migrations.

| Category | Tables | Purpose |
|----------|--------|---------|
| **Core & Workflow** | Task, TaskType, TaskTypeStatus, TaskCategory, TaskRole, TaskCheckIn, TaskDecision, TaskDecisionOutcome | Work items, IS-A `ExtensionEntity` subtype routing, dynamic domain stages, measurable task check-ins, formal decisions, and action hooks |
| **Risk & Forecasting** | TaskRiskAssessment | AI project delivery risk & completion forecast snapshots (`HealthStatus`, `ForecastCompletionDate`, `ForecastConfidence`, `MLBreachProbability`, typed `Risks` JSON, `AgentRunID`, token/cost metrics) synced atomically onto root project `Task` records |
| **Work Reporting** | WorkReport, WorkReportItem | Daily/weekly structured work summaries (`Draft` -> `Submitted` -> `Reviewed`) and supervisor feedback routed via `MJ: Employees.SupervisorID` |
| **Time & Effort** | TaskTimeEntry, TaskTimer, TaskAgentRun, TaskTimeEntryLink | Human time entries, running timers, AI agent run links, and external record locks (`R8`) |
| **Timesheets & Approvals** | Timesheet, TimesheetApproval, TimesheetSchedule, TimesheetLink, TimeApprover | Period timesheets, per-project approval parts, cadence overrides, and polymorphic approver rules |
| **Assignment** | TaskAssignment | Multi-person polymorphic assignment (People and AI Agents) |
| **Linking** | TaskLink | Polymorphic attachment to any entity (contracts, orders, committees, meetings) |
| **Collaboration** | TaskComment, TaskActivity, TaskNotificationConfig, TaskNotificationLog | Threaded discussion, server-authoritative audit log, and notifications |
| **Structure** | TaskDependency, TaskTag, TaskTagLink | Dependency graphs, critical paths, and cross-cutting labels |
| **Templates** | TaskTemplate, TaskTemplateItem, TaskTemplateItemDependency, TaskTemplateItemRole | Reusable task structures for recurring workflows |
| **Meetings** | Meeting, MeetingSeries, MeetingSeriesAttendee, MeetingAttendee, MeetingAgendaItem, MeetingAgendaItemType, MeetingNote, MeetingLink, MeetingType, VideoProvider | Meetings and agendas as a first-class app: one-off and recurring meetings, who is invited and whether they came, nested agendas with typed items, notes, what a meeting belongs to, and the video providers that host it. Follow-ups are tasks of the `ACTION_ITEM` type linked through `TaskLink`; a transcript is an MJ file; calendar events are MemberJunction's |

### 6 TypeScript Packages

| Package | NPM Name | Role |
|---------|----------|------|
| **Entities** | `@mj-biz-apps/tasks-entities` | Strongly-typed entity classes with Zod validation, custom subclasses for status transitions, cycle detection, and `TaskRiskAssessmentEntity` typed `Risks` JSON parsing |
| **Entities Server** | `@mj-biz-apps/tasks-entities-server` | Authoritative server subclasses (`TaskEntityServer`, `TaskRiskAssessmentEntityServer` root task health/confidence/forecast sync, and the `Meeting*EntityServer`s), dynamic status sync, terminal completion, action hook dispatching, and the meetings' rules: times and zone, the status moving forward, the organizer's attendee row, a series' occurrences, the video driver after the commit |
| **Actions** | `@mj-biz-apps/tasks-actions` | Server-side action handlers and subclasses (`Get Project Risk`, `Request Project Risk Review`, typed Task, Meeting, and Work Report actions) |
| **Core** | `@mj-biz-apps/tasks-core` | TaskService, TaskAssignmentService, TaskTemplateService, TaskOrchestrationService; MeetingService, MeetingSeriesService, MeetingAgendaService, MeetingCalendarFile, and pure project risk rules (`EvaluateProjectRiskCadence`, free/busy privacy guard, `ProjectRiskAnalystRegistry`) |
| **Server** | `@mj-biz-apps/tasks-server` | GraphQL resolvers, notification handlers, scheduled jobs, `ProjectRiskAnalystService` (High-tier owner-context risk analysis with weekly-to-daily final-20% cadence escalation), and server bootstrap |
| **Angular** | `@mj-biz-apps/tasks-ng` | UI components, generated forms, Kanban, Gantt, and Dashboard |

### 10 Reusable Angular Components + Full Dashboard App

All components are standalone with `@if`/`@for` block syntax. No routing -- events only. Consuming apps own navigation.

| Component | Selector | Purpose |
|-----------|----------|---------|
| **Task List** | `<bizapps-task-list>` | Embeddable, filterable task list. Inputs: CategoryID, ExtraFilter, StatusFilter, ShowCreateButton, Compact, SearchText. Built-in text search across Name/Description. Checkbox multi-select for bulk operations. Before/After events for selection, status changes, creation |
| **My Tasks** | `<bizapps-my-tasks>` | Wrapper around TaskListComponent filtered to the current user's PersonID (via TaskAssignment), sorted by DueAt. The #1 daily use case -- "what do I need to do?" Embeddable by any consuming app |
| **Task Detail Panel** | `<bizapps-task-detail-panel>` | Read-only slide-in detail view -- the default when clicking a task. Shows all fields, activity+comment timeline (with inline comment creation), assignee status dots, sub-task progress rollup, tags, TaskLinks. Has an "Edit" button to switch to TaskEditPanelComponent. Read-first, edit-intentionally |
| **Task Edit Panel** | `<bizapps-task-edit-panel>` | Slide-in panel for create/edit. Handles assignments (polymorphic -- people and agents), tags, TaskLinks, all fields. Inputs: TaskID, DefaultCategoryID, AssigneeScope (ExtraFilter or ID[] to narrow the assignee picker for consuming apps) |
| **Kanban Board** | `<bizapps-task-kanban>` | Board with columns per status. Drag-and-drop for status changes and reordering (Sequence). Before/AfterStatusChange events |
| **Gantt Chart** | `<bizapps-task-gantt>` | Gantt chart using DHTMLX Gantt library with data mapper for BizAppsTasks entities. Shows dependencies, sub-tasks, timeline |
| **Template Wizard** | `<bizapps-task-template-wizard>` | Multi-step flow for template instantiation: pick template, set start date, preview generated timeline, assign people to role placeholders, optionally customize, create |
| **Bulk Actions Bar** | `<bizapps-task-bulk-actions-bar>` | Appears when items are multi-selected in TaskList. Actions: bulk Status change, bulk Reassign, bulk Cancel |
| **Priority Badge** | `<bizapps-task-priority-badge>` | Inline priority indicator (color-coded) |
| **Assignee List** | `<bizapps-task-assignee-list>` | Avatar/name chips for assigned entities (people, agents), with per-assignee status indicator (Pending/InProgress/Completed) |

**Task Dashboard** (`<bizapps-task-dashboard>`) -- Full Tasks dashboard/app registered as its own MJ Application with nav, combining list + kanban + gantt views with view toggle and advanced filters. Embeds the detail/edit panels and template wizard as slide-in side panels.

---

## Entity Model

```
┌────────────┐     ┌──────────────┐     ┌───────────────┐
│  TaskType  │────►│     Task     │◄────│ TaskCategory  │
└────────────┘     │              │     │  (hierarchical)│
                   │  Status      │     └───────────────┘
                   │  Priority    │
                   │  DueAt       │◄──┐ ParentID (sub-tasks)
                   │  PercentComplete │
                   └──────┬───────┘
                          │
          ┌───────────────┼───────────────┬──────────────────┐
          │               │               │                  │
          ▼               ▼               ▼                  ▼
┌─────────────────┐ ┌───────────┐ ┌──────────────┐ ┌──────────────┐
│ TaskAssignment  │ │ TaskLink  │ │TaskDependency│ │ TaskComment  │
│ (polymorphic:   │ │(polymorphic│ │ (FinishToStart│ │ (threaded)  │
│  Person or Agent│ │ to any    │ │  StartToStart │ └──────────────┘
│  via EntityID + │ │ entity)   │ │  etc.)        │
│  RecordID)      │ └───────────┘ └──────────────┘
│                 │
│ ──► TaskRole    │     ┌─────────────────┐    ┌───────────┐
└─────────────────┘     │  TaskActivity   │    │  TaskTag  │
                        │  (auto audit    │    │  ──► TaskTagLink
                        │   log)          │    └───────────┘
                        └─────────────────┘

┌────────────────┐     ┌──────────────────────┐
│ TaskTemplate   │────►│  TaskTemplateItem     │◄── TaskTemplateItemDependency
│ (reusable      │     │  (DaysFromStart,      │◄── TaskTemplateItemRole
│  workflows)    │     │   hierarchy, sequence) │
└────────────────┘     └──────────────────────┘
```

### Key Design Patterns

**Polymorphic Assignment** -- TaskAssignment uses `AssigneeEntityID + AssigneeRecordID` to assign tasks to any entity type -- BizAppsCommon People, MJ AI Agents, or future entity types -- without schema changes.

**Role Assignment** -- An assignment whose `AssigneeEntityID` is `MJ: Roles` and `AssigneeRecordID` a Role ID gives the task to everyone who holds that role: it lists in each holder's My Tasks and approval inbox, each active holder is notified on assignment, completion, block, comment and overdue, and any holder may decide an approval assigned to the role. Membership is read when it is needed, so someone who joins the role later sees the open tasks.

**Polymorphic Linking** -- TaskLink replaces dedicated bridge tables. Consuming apps link tasks to their own entities (committees, meetings, agenda items) via `EntityID + RecordID`. A single task can link to multiple records across multiple entity types.

**Sub-task Rollup** -- When a child task's progress changes, the parent's PercentComplete is auto-calculated as a weighted average (by HoursEstimated). Parent Status auto-transitions to Completed when all children complete.

**Circular Dependency Prevention** -- TaskDependency validates against cycles via BFS graph traversal in `ValidateAsync()` before any save.

**Automatic Activity Logging** -- Status changes, assignment adds/removes, priority changes, and other auditable events are automatically recorded in TaskActivity.

### Form chrome

The Task form uses MJ's **left-nav** layout (`Entity.Configuration.UI.Form.Layout`). First-class sections are Details, Sub-tasks (the gantt/kanban contribution claims `ParentID`), and Assignments. Comments, activity, links, decisions, and approval JE batches sit in More.

Task Dependencies are **not** on the form. Both join ends (`TaskID` and `DependsOnTaskID`) are `inclusion: None` — they are the internal graph edges the gantt already draws. Tag-link and notification-log grids are also None (junction / audit, not a Task-form surface). Created-by Tasks on a Person are None.

---

## Row-Level Security & Chain-of-Command Visibility

BizApps Tasks enforces row-level read (and Work Report Item draft write) authorization at the MemberJunction data-provider layer via `MJ: Row Level Security Filters` (`metadata/row-level-security-filters/`) bound to `EntityPermissions` (`metadata/entities/.ui-role-permissions.json`). Every filter ships with balanced, indexed `EXISTS` semi-join predicates in both **SQL Server** (`FilterText`) and **PostgreSQL** (`PlatformVariants.FilterText.postgresql`) dialects, traversing reporting hierarchies at arbitrary depth through `bizapps-common`'s recursive `vwPersonReportingChain` view.

### `Task.Visibility` Tiers

| Value | Default | Who Can Read |
|---|---|---|
| **`Team`** | Yes (`Team`) | Task creator, direct assignees (`People`, `MJ: Users`, `MJ: Roles`), root-task (`RootParentID`) creator/assignees, and every manager/director up their reporting chains at any depth via `vwPersonReportingChain`. |
| **`Private`** | No | Task creator and direct assignees only. Managers/directors in `vwPersonReportingChain`, root-task owners, and organization members do **not** inherit access. |
| **`Organization`** | No | Everyone included under `Team` visibility **plus** active members of `Task.OrganizationID` (via `PersonToOrganization` relationships or `Employee.CompanyID -> Organization.LinkedCompanyID`), strictly isolated from external organizations. |

### Governed Entities & RLS Filter Matrix

| Governed Entity | Bound `ReadRLSFilterID` | Key Enforcement Invariants |
|---|---|---|
| `MJ_BizApps_Tasks: Tasks` | `Tasks: Visible Tasks` | Enforces `Private` / `Team` / `Organization`, assignee & `RootParentID` inheritance, and arbitrary-depth `vwPersonReportingChain` via `Person.LinkedUserID` and `User.LinkedEntityRecordID`. |
| `MJ_BizApps_Tasks: Task Assignments` | `Tasks: Rows Of Visible Tasks` | Delegates to parent `vwTasks` visibility so private/cross-chain assignments never leak. |
| `MJ_BizApps_Tasks: Task Dependencies` | `Tasks: Visible Task Dependencies` | Requires visibility on **both** `TaskID` and `DependsOnTaskID` so a `Team -> Private` edge never exposes a private task to managers or peers. |
| `MJ_BizApps_Tasks: Task Check Ins` | `Tasks: Rows Of Visible Tasks` | Inherits parent `vwTasks` visibility. |
| `MJ_BizApps_Tasks: Task Comments` | `Tasks: Rows Of Visible Tasks` | Inherits parent `vwTasks` visibility. |
| `MJ_BizApps_Tasks: Task Links` | `Tasks: Rows Of Visible Tasks` | Inherits parent `vwTasks` visibility. |
| `MJ_BizApps_Tasks: Task Activities` | `Tasks: Rows Of Visible Tasks` | Inherits parent `vwTasks` visibility. |
| `MJ_BizApps_Tasks: Task Risk Assessments` | `Tasks: Rows Of Visible Tasks` | Inherits parent `vwTasks` visibility. |
| `MJ_BizApps_Tasks: Task Time Entries` | `Tasks: Visible Task Time Entries` | Author always reads own entries; standalone entries (`TaskID IS NULL`) follow `vwPersonReportingChain`; task-linked entries follow parent task visibility without leaking `Private` tasks. |
| `MJ_BizApps_Tasks: Meetings` | `Tasks: Visible Meetings` | Differentiates `Private` (organizer, creator, attendees only) vs `Standard` (organizer/creator/attendee reporting chains via `vwPersonReportingChain` plus visible linked tasks). Supporting filters govern `Meeting Series`, `Meeting Series Attendees`, `Meeting Links`, `Meeting Attendees`, `Meeting Agenda Items`, and `Meeting Notes`. |
| `MJ_BizApps_Tasks: Work Reports` | `UI: Work Reports - Author or Supervisor Chain` | Author, arbitrary-depth upward reporting chain via `vwPersonReportingChain`, or administrative roles (`Owner`, `System Administrator`, `Administrator`, `Admin`, `Administration`). `Work Report Items` enforce matching chain-of-command reads and `Draft`-author-only creates/updates. |

### Verifying RLS Rules

- **Metadata & Migration Parity**: `pnpm --filter @mj-biz-apps/tasks-entities test`
- **Multi-Chain & Manager Hierarchy Relational Suite (SQL Server + PostgreSQL)**: `pnpm --filter @mj-biz-apps/tasks-server test`

---

## Using BizApps Tasks in Your Code

### Creating a Task

```typescript
import { Metadata } from '@memberjunction/core';

const task = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
task.NewRecord();
task.Set('Name', 'Review Q2 budget proposal');
task.Set('TypeID', actionItemTypeID);
task.Set('CategoryID', financeCommitteeCategoryID);
task.Set('Priority', 'High');
task.Set('DueAt', new Date('2026-05-15'));
await task.Save();
```

### Assigning People to Tasks

```typescript
import { TaskAssignmentService } from '@mj-biz-apps/tasks-core';

const svc = new TaskAssignmentService();
await svc.assignToTask({
    taskID: task.Get('ID'),
    assigneeEntityID: peopleEntityID,
    assigneeRecordID: personID,
    roleID: primaryRoleID,
    assignedByPersonID: currentPersonID,
});
```

### Approval Tasks: Who May Assign, Close and Create

On a task whose type has `IsApproval` set, the server checks three writes, whoever makes them:

- **Adding an assignee.** The person recorded as the task's creator names its approvers while the request is open. Anyone else needs the reassign right (the `ApprovalReassignRoles` setting; everyone holds it while the setting is empty) and can never add themselves, as a person, as a user, or through a role they hold.
- **Closing the task.** `Completed` follows an approving decision, and `Cancelled` a rejecting one. With no such decision, only someone who could record the decision can complete the task, and a cancel is a withdrawal: the creator, an active assignee or a holder of the reassign right can make it, and it never approves anything. An approval task's type can't be changed to a type that isn't an approval.
- **Naming the creator.** A new task's `CreatedByPersonID` is the person creating it, on every task type. Leave it empty and the server records them.

A refused save returns `false` with the reason in `LatestResult.CompleteMessage`.

Server code that decides these itself vouches for one save of one record, just before saving it:

```typescript
import {
    SanctionApprovalAssignment,
    SanctionApprovalWithdrawal,
    SanctionOnBehalfCreator,
} from '@mj-biz-apps/tasks-entities-server';

SanctionOnBehalfCreator(task);          // the task is raised for someone else, or for nobody
SanctionApprovalAssignment(assignment); // the server chose this assignee
SanctionApprovalWithdrawal(task);       // the server is withdrawing a request it raised
```

Each returns `false` when the record isn't a server-side Tasks record. `TaskOrchestrationService.CreateTask` and `CreateApprovalRequest` take a `BeforeSave` callback, and `TaskAssignmentService.assignToTask` a `beforeSave` one, so a caller of the services can vouch without depending on the entity classes. Nothing vouches for completing an approval: that takes a decision, or a person who could record one. Use these only where the server decided what is written, never to pass along a value a caller supplied.

### Instantiating a Template

```typescript
import { TaskTemplateService } from '@mj-biz-apps/tasks-core';

const svc = new TaskTemplateService();
const tasks = await svc.instantiateTemplate({
    templateID: boardMeetingPrepTemplateID,
    startDate: new Date('2026-05-01'),
    categoryID: financeCommitteeCategoryID,
    assigneeMap: new Map([
        [primaryRoleID, { entityID: peopleEntityID, recordID: chairPersonID }],
        [reviewerRoleID, { entityID: peopleEntityID, recordID: treasurerPersonID }],
    ]),
});
```

### Embedding Components (Committees Example)

```html
<!-- Task list scoped to a committee's category -->
<bizapps-task-list
    [CategoryID]="committeeCategoryId"
    [ShowCreateButton]="isOfficer"
    (BeforeTaskSelected)="onBeforeTaskSelected($event)"
    (AfterTaskSelected)="onTaskSelected($event)">
</bizapps-task-list>

<!-- Current user's tasks across all committees -->
<bizapps-my-tasks
    [PersonID]="currentPersonId"
    [ShowCreateButton]="true"
    (AfterTaskSelected)="openDetail($event)">
</bizapps-my-tasks>

<!-- Kanban board for a project category -->
<bizapps-task-kanban
    [CategoryID]="projectCategoryId"
    (BeforeStatusChange)="onBeforeStatusChange($event)"
    (TaskClicked)="openDetail($event)">
</bizapps-task-kanban>
```

---

### Answering Workflow Human Steps and Agent Questions

BizApps Tasks is a MemberJunction **human-task provider**, registered under the key `BizAppsTasks`. When an MJ workflow (task graph) reaches a Human step, or an agent asks a question, the provider puts it in front of people as an ordinary Tasks task. They see it in their Tasks inbox, with assignees, notifications and the usual decision rules. When they decide or complete the task, the answer goes back to the workflow or the agent. This needs MJ with the human-task provider contract (MJ #6763, #6777): MJ `next` today, and the next MJ edge build.

**Two ways to route work to Tasks:**

- **Per step.** Name the provider on the Human step:

  ```typescript
  import { TaskNode } from '@memberjunction/ai-core-plus';

  TaskNode.Human(
      { tempId: 'review', name: 'Approve the contract', description: 'Legal sign-off', dependsOn: ['draft'] },
      {
          provider: 'BizAppsTasks',
          instructions: 'Review the contract and approve or reject it.',
          expiresInHours: 72,
          providerConfiguration: {
              title: 'Approve the contract',
              assignees: [{ entity: 'MJ: Roles', recordID: legalRoleID }],
              linkedRecord: { entity: 'MJ_BizApps_Contracts: Contracts', recordID: 'payload.contractID' },
          },
      },
  );
  ```

- **For the whole install.** Set the default provider in the host's `mj.config.cjs`:

  ```javascript
  humanTasks: { defaultProvider: 'BizAppsTasks' }   // or MJ_HUMAN_TASKS_DEFAULT_PROVIDER
  ```

  Every Human step that names no provider then goes to Tasks, and so does every agent's question (a Chat step's feedback request). Plan-mode approvals stay in MJ's inbox. Without the setting, nothing changes.

**`providerConfiguration` keys** for a workflow step:

| Key | Meaning |
|---|---|
| `taskType` | Task type `Code` or `Name`. Default `APPROVAL_REQUEST`. |
| `title` | Task name. Default: the step's name. |
| `priority` | `Low` / `Medium` / `High` / `Critical`. Default `High`. |
| `approverPersonIDs` | People to assign: an ID, a list, or `payload.<path>` holding either. |
| `assignees` | `[{ entity, recordID }]` for People, `MJ: Users` or `MJ: Roles`; `recordID` may be `payload.<path>`. |
| `linkedRecord` | `{ entity, recordID }`: the record the decision is about, shown on the task. |
| `outputKey` | Payload key the decision is written under. Default `approval`. |

A workflow step must name someone through `approverPersonIDs` or `assignees`, or be assigned to a user. It never falls back to the workflow's owner, who is often the person asking for approval, so a step naming no one is refused. An agent's question goes to the user the request names, else to the user who ran the agent. Settings the provider can't use fail the step permanently, with a message naming the problem.

**What comes back:**

- **A workflow step** completes with this under its `outputKey`, so later steps can branch on `payload.approval.Approved`:

  ```json
  { "Outcome": "Approved", "Approved": true, "Notes": "…", "DecidedByPersonID": "…", "TaskID": "…" }
  ```

  Only a recorded approving decision on a completed task approves. A task closed without one completes the step with `Approved: false`, so Tasks' decision rules decide who can release a step. That includes `PreventSelfApproval`, which is on by default.
- **An agent's question** is answered through MJ's `AnswerAgentRequestFromProvider`, which resumes the agent:
  - an approving decision approves, and a rejecting one rejects;
  - a task completed without a decision responds with the task's completion notes;
  - a task cancelled without a decision leaves the question open in MJ's inbox.
- **Withdrawn elsewhere.** If the step expires, its run is cancelled, or the question is answered in MJ first, the provider cancels the open task.

**Safety.** Answering a linked task settles the ask without the person deciding needing access to the workflow, so a link to an `MJ: Tasks` step or an `MJ: AI Agent Requests` row works like a key. Only the provider may create those links, and nobody may move an existing link onto or off one (`TaskLinkEntityServer`).

**Code and tests:**

- The provider: `packages/Server/src/workflow/BizAppsTasksHumanTaskProvider.ts`
- Settling: `packages/Server/src/workflow/workflow-step-completion.ts`
- The live check, run against a database on MJ's real dispatcher: `MJ_IT_LOAD_ENTITIES_SERVER=1 node test-harnesses/integration.mjs workflow-human-tasks`
- A full example user: Forms' publish approval (`bizapps-forms`, `FormPublishReview.ts`)
- MJ's guide: [`guides/WORKFLOW_AND_TASK_GRAPH_GUIDE.md`](https://github.com/MemberJunction/MJ/blob/next/guides/WORKFLOW_AND_TASK_GRAPH_GUIDE.md)

## Seed Data

Deployed via migrations. Fully customizable per deployment.

| Type Table | Included Records |
|------------|-----------------|
| **TaskType** | General, Action Item, Follow-up, Deliverable |
| **TaskRole** | Primary, Reviewer, Observer |
| **MeetingType** | General, One-on-one, Team, Client, Review, each with a default length and an agenda template (metadata, `metadata/meeting-types`) |
| **MeetingAgendaItemType** | Information, Discussion, Decision, Report, Presentation, Action review, Break (metadata) |
| **VideoProvider** | Zoom, Microsoft Teams, Google Meet, shipped inactive until a host gives each a credential of the *Video Provider OAuth* type and turns it on (metadata) |

---

## Building an App That Depends on BizApps Tasks

Declare the dependency in your `mj-app.json`:

```json
{
  "dependencies": [
    {
      "name": "mj-bizapps-tasks",
      "repository": "https://github.com/MemberJunction/bizapps-tasks",
      "versionRange": ">=1.0.0 <2.0.0"
    }
  ]
}
```

When users install your app, the MJ CLI will automatically install BizApps Tasks (and its dependency BizApps Common) first.

---

## Contributing (Developer Setup)

To work on BizApps Tasks itself, clone the repo and set up a local development environment:

```bash
git clone https://github.com/MemberJunction/bizapps-tasks.git
cd bizapps-tasks
npm install
```

### Configure Environment

Create a `.env` file at the repo root:

```env
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=YourDatabase
CODEGEN_DB_USERNAME=MJ_CodeGen
CODEGEN_DB_PASSWORD=yourpassword
DB_USERNAME=MJ_Connect
DB_PASSWORD=yourpassword
MJ_CORE_SCHEMA=__mj
```

### Prerequisites

BizApps Tasks requires an existing MJ database with:
1. **MJ Core** (`__mj` schema) -- run MJ core migrations first
2. **BizApps Common** (`__mj_BizAppsCommon` schema) -- run BizApps Common migrations

### Deploy and Build

```bash
# Run migrations (specify schema and directory)
npx @memberjunction/cli migrate --schema __mj_BizAppsTasks --dir ./migrations

# Generate TypeScript/GraphQL/Angular code
npm run mj:codegen

# Build all packages (Turborepo)
npm run build
```

---

### Related-Record Collections & Lifecycle Ownership

BizApps Tasks declares 15 database-backed (`Source: "database"`, `Load: "explicit"`) `RelatedRecordCollection` accessors in `metadata/entity-relationships/.entity-relationships.json` and emits matching strongly-typed `DeclareRelatedRecords<...>` properties on the generated entity subclasses:

- **`mjBizAppsTasksTaskEntity`**: `Assignments`, `TagLinks`, `Links`, `Dependencies`, `Decisions` (`OnRemove: "refuse"`), `Comments`, `CheckIns`, `Activities`, `NotificationLogs`, `SubTasks` (`OnRemove: "orphan"`)
- **`mjBizAppsTasksTaskTypeEntity`**: `Statuses` (auto-sequenced `Sequence` from `1`)
- **`mjBizAppsTasksTaskTemplateEntity`**: `Items` (auto-sequenced `Sequence` from `1`)
- **`mjBizAppsTasksTaskTemplateItemEntity`**: `Roles`, `Dependencies`
- **`mjBizAppsTasksWorkReportEntity`**: `Items` (auto-sequenced `Sequence` from `1`)

**Single-owner lifecycle action hook dispatch**: `TaskEntityServer` is the sole dispatcher for task lifecycle hooks (`OnCreate`, `OnStatusChange`, `OnEnterStatus`, `OnExitStatus`, `OnComplete`, `OnCancel`, `OnReject`, `OnPercentChange`), firing `OnReject` only on `Cancelled` tasks with a recorded `Rejected` decision (and `OnCancel` otherwise). `TaskNotificationHandler` handles user notifications and `OnAssignActionID` only, deferred via `RunAfterCommit`.

---

## Repository Structure

```
bizapps-tasks/
├── mj-app.json                    # MJ Open App manifest
├── mj.config.cjs                  # CodeGen configuration
├── packages/
│   ├── Entities/                   # @mj-biz-apps/tasks-entities
│   │   └── src/custom/             # Task validation, cycle detection
│   ├── Actions/                    # @mj-biz-apps/tasks-actions
│   ├── Core/                       # @mj-biz-apps/tasks-core
│   │   └── src/services/           # TaskService, TaskAssignmentService, TaskTemplateService
│   ├── Server/                     # @mj-biz-apps/tasks-server
│   └── Angular/                    # @mj-biz-apps/tasks-ng
│       └── src/lib/components/     # 8 standalone Angular components
├── migrations/                     # Skyway SQL migrations
├── metadata/                       # Seed data
└── plans/                          # Design documentation
```

### Build Dependency Graph

```
Entities ──► Core ──► Server
    │          │
    └──► Angular
```

---

## Runtime Limits, Runaway Guards & Standards Enforcement

All backend safety bounds, query row caps, recursion/iteration ceilings, briefing contributor limits, and tuning defaults across `@mj-biz-apps/tasks-core`, `@mj-biz-apps/tasks-actions`, `@mj-biz-apps/tasks-entities-server`, and `@mj-biz-apps/tasks-server` are centralized in `TasksLimitsResolver` (`@mj-biz-apps/tasks-core`, also available standalone via `@mj-biz-apps/tasks-core/limits`).

### Override Precedence (Lowest to Highest)

1. **`CodeFallback`** — Approved defaults (`CODE_FALLBACK_TASKS_LIMITS` in `packages/Core/src/config/TasksLimits.ts`).
2. **`MjLimitsConfig`** — Propagates `BriefingContributorTimeoutMs` and `BriefingMaxContributorChars` from `@memberjunction/core`'s `LimitsConfigResolver`.
3. **`Env`** — Optional `MJ_TASKS_LIMITS_JSON` JSON override or key-specific `MJ_TASKS_LIMIT_<KEY>` environment variables.
4. **`AppConfig`** — Host-registered overrides via `TasksLimitsResolver.Instance.RegisterConfigOverrides(...)`.
5. **`RuntimeOverride`** — Per-invocation override passed to `TasksLimitsResolver.Instance.Resolve({ RuntimeOverride: ... })`.

Every override is validated against `TASKS_LIMIT_SAFETY_BOUNDS`: non-finite, `NaN`, malformed, or non-positive (`<= 0`) values are ignored so runaway and resource guards can never be disabled, and oversized integers are clamped to per-key safety ceilings (with `default <= ceiling` consistency enforced).

### Configuration Sections & Key Groups

- **`RunawayGuards`**: `MaxBulkTasks`, `MaxHierarchyDepth`, `MaxSupervisorChainDepth`, `MaxDependencyWalkIterations`, `MaxTemplateSortIterations`, `MaxSeriesOccurrences`, `BriefingMaxItemsCeiling`, `BriefingMaxHorizonDays`, `BriefingMaxLookbackDays`, `BriefingWorkReportsMaxLookbackDays`, `FindMeetingsMaxHorizonDays`, `FindMeetingsMaxPastHours`, `FindMeetingsMaxLimit`, `FindSimilarTasksMaxWindowDays`, `FindSimilarTasksMaxLimit`.
- **`ResourceGuards`**: `DefaultLookupSingleRow`, `AmbiguousLookupMaxRows`, `RecentLinksMaxRows`, `RecentContextMaxRows`, `CandidateLookupMaxRows`, `RelatedSearchMaxRows`, `StandardListMaxRows`, `StandardBatchMaxRows`, `ExtendedSearchMaxRows`, `WorkflowBatchMaxRows`, `BriefingTasksMaxRows`, `BroadEntityQueryMaxRows`, `LargeTreeQueryMaxRows`, `SeriesMaterializationMaxRows`, `SubtreeEffortMaxRows`, `FindTasksDefaultMaxRows`, `FindTasksMaxRowsCeiling`, `FindTasksSemanticSearchFloor`, `FindTasksSearchFetchCeiling`, `FindWorkReportsDefaultMaxRows`, `FindWorkReportsMaxRowsCeiling`, `ReconcileTimesheetApprovalsDefaultMaxRows`, `ReconcileTimesheetApprovalsMaxRowsCeiling`, `SqlInClauseChunkSize`, `MaxSavedTaskViews`, `MaxMeetingTranscriptChars`, `ZoomApiTimeoutMs`, `TeamsWebhookTimeoutMs`.
- **`Briefing`**: `ContributorTimeoutMs`, `MaxContributorChars`, `DefaultBriefingMaxItems`, `DefaultBriefingHorizonDays`, `DefaultMeetingsBriefingLookbackDays`, `DefaultWorkReportsBriefingLookbackDays`, `MeetingNoteExcerptMaxChars`, `NotificationPreviewMaxChars`, `TranscriptExcerptMaxLines` (plus shared helpers in `packages/Core/src/config/BriefingLimitsHelper.ts`).
- **`Tuning`**: `DefaultSeriesHorizonDays`, `DefaultMeetingDurationMinutes`, `DefaultAgendaItemDurationMinutes`, `DefaultAgendaSequenceStep`, `DefaultTaskSimilarityLimit`, `TranscriptDedupMatchLimit`, `FindSimilarDefaultWindowDays`, `FindMeetingsDefaultDaysAhead`, `FindMeetingsDefaultLimit`, `ProposedTaskClaimTtlMs`, `CompletionNotesMaxChars`, `FailureNotesMaxChars`, `HttpErrorDetailMaxChars`, `ZoomTokenSafetyMarginMs`.

### Classified Limits Inventory & CI Standards Guard

- **Limits sweep & classified CSV generation**:
  ```bash
  node scripts/sweep-limits.mjs --out scripts/limits-sweep-classified.csv --also .mj/specs/limits-sweep-bizapps-tasks.csv
  node scripts/sweep-limits.mjs --check-runaway
  ```
- **Static standards & limits parity check** (enforced in CI by `.github/workflows/repo-checks.yml`):
  ```bash
  npm run check:standards
  ```
  `scripts/check-standards.mjs` verifies zero unapproved `RunawayGuard` or unrouted backend `ResourceGuard`/`Tuning` literals, deterministic CSV parity with `scripts/sweep-limits.mjs`, zero `any` types, zero lazy `unknown` casts (`as unknown as Record<...>` / standalone `as unknown`), and zero `BaseEntity.Get()` / `BaseEntity.Set()` calls across backend packages.

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Platform** | [MemberJunction](https://github.com/MemberJunction/MJ) | 6.1.6 |
| **Runtime** | Node.js | 18+ |
| **Language** | TypeScript | 5.9 |
| **Database** | SQL Server / Azure SQL | 2019+ |
| **API** | GraphQL (TypeGraphQL) | -- |
| **UI Framework** | Angular | 21 |
| **Build** | Turborepo | 2.9 |
| **Validation** | Zod | 3.24 |

---

## License

Business Source License 1.1 — see [LICENSE](./LICENSE) for details.

---

<p align="center">
  Built on <a href="https://github.com/MemberJunction/MJ">MemberJunction</a> -- the metadata-driven application platform.
</p>
