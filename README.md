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
  <a href="#angular-components">Components</a> &middot;
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
- [**Work Bus Extensions, Field Suggestions & 15Five Work Reports Guide**](./guides/WORK_BUS_AND_15FIVE_REPORTS_GUIDE.md) — Declarative IS-A subtype extensions (`TaskType.ExtensionEntity` + `SubtypeSelector`), `FIELD_SUGGESTION` review chips on `Tasks`, and **15Five Work Reports** (`WorkReport`, `WorkReportItem`, Chief of Staff `Reports` resource, skill, and supervisor review handoff).
- [**Time Tracking, AI Agent Effort & Timesheets Guide**](./guides/TIME_TRACKING_GUIDE.md) — User, host administrator, and developer guide covering **Live Task Timers (`TaskTimer`)**, **Manual & Weekly Time Logging (`TaskTimeEntry`)**, **AI Agent Effort & Cost Rollups (`TaskAgentRun`)**, **Multi-Project Timesheet Approvals (`Timesheet`, `TimesheetApproval`, `BaseTimeApproverResolver`)**, and **Shipped Reporting Queries**.
- [**Tasks UX, Organization Scoping & Server-Side Bulk Operations Guide**](./guides/TASKS_UX_ORGANIZATION_AND_BULK_OPS_GUIDE.md) ([**Self-Contained Illustrated HTML Version w/ Embedded 2× Screenshots**](./guides/TASKS_UX_ORGANIZATION_AND_BULK_OPS_GUIDE.html)) — Golden Hybrid 3-layer WCAG 2.1 AA UX architecture (`My Work` default tab, `All Work` List/Board/Gantt, **UserInfoEngine Saved Filter Views**, shared **Multi-View Bulk Action Dock** across Tree List, Smart Board & Gantt, Zero-Bounce inline-saving Inspector, Express Create, Command Palette, Clean Selectable Approvals Split-Pane, Playbook Launcher, Dark Mode & Mobile `390px`), canonical **Organization / Company scoping** (`OrganizationID` on aggregate roots + parent inheritance), and **server-side Remotable Operations + Actions** (`BizAppsTasks.BulkUpdateTasks`, `BizAppsTasks.InstantiateTemplate`, `BizAppsTasks.RunRecurringPlaybooks`, `Run Recurring Playbooks`).

---

## What You Get

### 39 Database Tables

All tables live in the `__mj_BizAppsTasks` SQL schema, deployed via migrations.

| Category | Tables | Purpose |
|----------|--------|---------|
| **Core & Workflow** | Task, TaskType, TaskTypeStatus, TaskCategory, TaskRole, TaskCheckIn, TaskDecision, TaskDecisionOutcome | Work items, IS-A `ExtensionEntity` subtype routing, dynamic domain stages, measurable task check-ins, formal decisions, and action hooks |
| **Reporting (15Five)** | WorkReport, WorkReportItem | Daily/weekly 5-minute work summaries (`Draft` -> `Submitted` -> `Reviewed`) and supervisor feedback routed via `MJ: Employees.SupervisorID` |
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
| **Entities** | `@mj-biz-apps/tasks-entities` | Strongly-typed entity classes with Zod validation, custom subclasses for status transitions and cycle detection |
| **Entities Server** | `@mj-biz-apps/tasks-entities-server` | Authoritative server subclasses (`TaskEntityServer`, the `Meeting*EntityServer`s), dynamic status sync, terminal completion, action hook dispatching, and the meetings' rules: times and zone, the status moving forward, the organizer's attendee row, a series' occurrences, the video driver after the commit |
| **Actions** | `@mj-biz-apps/tasks-actions` | Server-side action handlers and subclasses |
| **Core** | `@mj-biz-apps/tasks-core` | TaskService, TaskAssignmentService, TaskTemplateService, TaskOrchestrationService; MeetingService, MeetingSeriesService, MeetingAgendaService, MeetingCalendarFile, and the pure meetings rules (status moves, recurrence in a zone, agenda trees, the `.ics` file) |
| **Server** | `@mj-biz-apps/tasks-server` | GraphQL resolvers, notification handlers, scheduled jobs (overdue tasks, meeting series materialization), and server bootstrap |
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
