<p align="center">
  <img src="https://raw.githubusercontent.com/MemberJunction/MJ/main/logo.png" alt="MemberJunction" width="120" />
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
  <img alt="MJ Version" src="https://img.shields.io/badge/MemberJunction-5.21.0-blue?style=flat-square" />
  <img alt="Angular" src="https://img.shields.io/badge/Angular-21-DD0031?style=flat-square&logo=angular&logoColor=white" />
  <img alt="TypeScript" src="https://img.shields.io/badge/TypeScript-5.9-3178C6?style=flat-square&logo=typescript&logoColor=white" />
  <img alt="License" src="https://img.shields.io/badge/License-ISC-green?style=flat-square" />
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
2. Validates MJ version compatibility (`>=5.0.0 <6.0.0`)
3. Installs the dependency [BizApps Common](https://github.com/MemberJunction/bizapps-common) if not already present
4. Creates the `__mj_BizAppsTasks` database schema
5. Runs Skyway migrations to create all 15 tables with seed data
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

## What You Get

### 15 Database Tables

All tables live in the `__mj_BizAppsTasks` SQL schema, deployed via migrations.

| Category | Tables | Purpose |
|----------|--------|---------|
| **Core** | Task, TaskType, TaskCategory, TaskRole | Work items and their classification |
| **Assignment** | TaskAssignment | Multi-person polymorphic assignment (People and AI Agents) |
| **Linking** | TaskLink | Polymorphic attachment to any entity (committees, meetings, etc.) |
| **Collaboration** | TaskComment, TaskActivity | Threaded discussion and automatic audit log |
| **Structure** | TaskDependency, TaskTag, TaskTagLink | Dependency graphs and cross-cutting labels |
| **Templates** | TaskTemplate, TaskTemplateItem, TaskTemplateItemDependency, TaskTemplateItemRole | Reusable task structures for recurring workflows |

### 5 TypeScript Packages

| Package | NPM Name | Role |
|---------|----------|------|
| **Entities** | `@mj-biz-apps/tasks-entities` | Strongly-typed entity classes with Zod validation, custom subclasses for status transitions and cycle detection |
| **Actions** | `@mj-biz-apps/tasks-actions` | Server-side action handlers |
| **Core** | `@mj-biz-apps/tasks-core` | TaskService, TaskAssignmentService, TaskTemplateService |
| **Server** | `@mj-biz-apps/tasks-server` | GraphQL resolvers and server bootstrap |
| **Angular** | `@mj-biz-apps/tasks-ng` | UI components, generated forms, module |

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

**Polymorphic Linking** -- TaskLink replaces dedicated bridge tables. Consuming apps link tasks to their own entities (committees, meetings, agenda items) via `EntityID + RecordID`. A single task can link to multiple records across multiple entity types.

**Sub-task Rollup** -- When a child task's progress changes, the parent's PercentComplete is auto-calculated as a weighted average (by HoursEstimated). Parent Status auto-transitions to Completed when all children complete.

**Circular Dependency Prevention** -- TaskDependency validates against cycles via BFS graph traversal in `ValidateAsync()` before any save.

**Automatic Activity Logging** -- Status changes, assignment adds/removes, priority changes, and other auditable events are automatically recorded in TaskActivity.

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

## Seed Data

Deployed via migrations. Fully customizable per deployment.

| Type Table | Included Records |
|------------|-----------------|
| **TaskType** | General, Action Item, Follow-up, Deliverable |
| **TaskRole** | Primary, Reviewer, Observer |

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
| **Platform** | [MemberJunction](https://github.com/MemberJunction/MJ) | 5.21.0 |
| **Runtime** | Node.js | 18+ |
| **Language** | TypeScript | 5.9 |
| **Database** | SQL Server / Azure SQL | 2019+ |
| **API** | GraphQL (TypeGraphQL) | -- |
| **UI Framework** | Angular | 21 |
| **Build** | Turborepo | 2.9 |
| **Validation** | Zod | 3.24 |

---

## License

ISC

---

<p align="center">
  Built on <a href="https://github.com/MemberJunction/MJ">MemberJunction</a> -- the open-source metadata-driven application platform.
</p>
