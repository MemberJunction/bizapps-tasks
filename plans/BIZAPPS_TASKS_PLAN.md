# BizAppsTasks — Reusable Task Management App

## Context

Committee management has extensive task management requirements (action items, follow-ups, assignments). Rather than building task management into each app individually, we're creating **BizAppsTasks** — a standalone, reusable task management app that any MJ-based application (Committees, Izzy, future PM apps, etc.) can depend on. This replaces the thin `ActionItem` entity currently in Committees and provides a much richer feature set: multi-person assignment with roles, sub-tasks, dependency graphs, hours tracking, categories, Kanban/Gantt views, and more.

### Key Decision: Own Entities, Not Extending MJ Core Tasks

The existing `MJ: Tasks` / `@memberjunction/ng-tasks` system is purpose-built for **AI agent orchestration** (Sage). It has fields like `AgentID`, `EnvironmentID`, `ConversationDetailID`, and mutual exclusivity validation between UserID and AgentID. BizAppsTasks is a **human-and-agent** task management system needing multi-person assignment, categories, comments, and hours tracking — none of which map cleanly onto the agent model. However, TaskAssignment uses a polymorphic assignee pattern so tasks can be assigned to humans (BizAppsCommon Person) *or* AI agents, bridging both worlds. We create our own entities but can reuse the same DHTMLX Gantt library for visualization.

### Evaluation: CDP PM App (BlueCypress/CDP)

The CDP repo (`BlueCypress/CDP`) has a `pm` schema with 12 entities (Project, Task, TaskAssignment, TaskType, TimeEntry, ProjectStatusType, ProjectBillingType, ProjectRateType, ProjectAssignmentPeriod, BudgetPeriod, Priority, AsanaWebhook). This was evaluated to determine if code or patterns could be reused.

**Conclusion: No code reuse is practical.** The CDP PM app is a professional services billing/resource planning tool, not a general task manager:

- **Billing-centric design**: Projects are revenue units with billing types, rate types, fixed fees, budget amounts — designed for consulting firms tracking billable hours
- **Single assignment model**: One AssignedEmployeeID per task + effort-based TaskAssignment within time periods. No multi-person roles.
- **No custom UI**: Only CodeGen-generated entity forms. No kanban, gantt, dashboards, or task-specific components.
- **No dependencies, comments, activity log, categories, or tags**
- **Different technical foundation**: INT IDENTITY PKs (vs GUID), `pm` schema (vs `__mj_BizAppsTasks`), Employee-based (vs BizAppsCommon Person-based)

**What's worth noting for the future:**
- The **TimeEntry** model (Date, Effort, Comment, IsInvoiced, IsLocked) is a reasonable reference for when BizAppsTasks adds time logging (backlog item)
- The **Asana webhook** integration pattern could inform the external integrations backlog item (Google Tasks / MS To-Do sync)
- If CDP PM is eventually retired, its billing/invoicing features are out of scope for BizAppsTasks — they'd need their own dedicated package

BizAppsTasks is correctly designed as a clean-sheet effort. The overlap with CDP PM is conceptual (both manage "tasks") but the use cases, data models, and target users are fundamentally different.

---

## 1. Schema Design — `__mj_BizAppsTasks`

### TaskType
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(100) NOT NULL | UNIQUE |
| Description | NVARCHAR(MAX) | |
| IconClass | NVARCHAR(100) | Font Awesome class |
| DefaultPriority | NVARCHAR(20) | DEFAULT 'Medium' |
| OnAssignActionID | UNIQUEIDENTIFIER FK | → __mj.Action (fires when someone is assigned a task of this type) |
| OnCompleteActionID | UNIQUEIDENTIFIER FK | → __mj.Action (fires when task is completed) |
| OnOverdueActionID | UNIQUEIDENTIFIER FK | → __mj.Action (fires when task passes DueAt) |
| OnPercentChangeActionID | UNIQUEIDENTIFIER FK | → __mj.Action (fires when PercentComplete updates) |
| IsActive | BIT NOT NULL | DEFAULT 1 |

All action FK columns are nullable — workflow implementations come later but the schema is ready. Entity subclass hooks check these columns and invoke the linked Action when present.

Seed data: General, Action Item, Follow-up, Deliverable

### TaskCategory (nested/hierarchical)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(255) NOT NULL | |
| Description | NVARCHAR(MAX) | |
| ParentID | UNIQUEIDENTIFIER FK | Self-ref for nesting |
| ColorCode | NVARCHAR(20) | For UI color-coding |
| Sequence | INT NOT NULL | DEFAULT 100, ordering |
| IsActive | BIT NOT NULL | DEFAULT 1 |

Key integration point — consuming apps create categories to group their tasks (e.g., "Finance Committee", "Q1 Audit").

### Task
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(255) NOT NULL | |
| Description | NVARCHAR(MAX) | |
| TypeID | UNIQUEIDENTIFIER FK | → TaskType |
| CategoryID | UNIQUEIDENTIFIER FK | → TaskCategory (nullable) |
| ParentID | UNIQUEIDENTIFIER FK | Self-ref for sub-tasks |
| Status | NVARCHAR(50) NOT NULL | DEFAULT 'Open'. CHECK: Open, InProgress, Blocked, Completed, Cancelled |
| Priority | NVARCHAR(20) NOT NULL | DEFAULT 'Medium'. CHECK: Low, Medium, High, Critical |
| StartedAt | DATETIMEOFFSET | When work began |
| DueAt | DATETIMEOFFSET | Deadline |
| CompletedAt | DATETIMEOFFSET | When finished |
| HoursEstimated | DECIMAL(8,2) | |
| HoursActual | DECIMAL(8,2) | |
| PercentComplete | INT | 0–100 |
| Sequence | INT NOT NULL | DEFAULT 100, for manual reordering within a category/parent — enables drag-to-reorder in list and kanban |
| BlockedReason | NVARCHAR(MAX) | Explanation when Status = 'Blocked', e.g. "Waiting on legal review" |
| CompletionNotes | NVARCHAR(MAX) | |
| CreatedByPersonID | UNIQUEIDENTIFIER FK | → BizAppsCommon.Person |

Entity subclass validation:
- Auto-set `StartedAt` when Status transitions to InProgress (if not already set)
- Auto-set `CompletedAt` + `PercentComplete=100` when Status → Completed
- PercentComplete must be 0–100
- DueAt must be after StartedAt (if both set)
- **Sub-task progress rollup**: When a child task's PercentComplete or Status changes, the parent's PercentComplete is auto-calculated as the weighted average of children (weighted by HoursEstimated if available, equal weight otherwise). Parent Status auto-transitions to Completed when all children are Completed. Rollup is recursive up the hierarchy.

### TaskRole (lookup)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(100) NOT NULL | UNIQUE. E.g. Primary, Reviewer, Observer |
| Description | NVARCHAR(MAX) | |
| Sequence | INT NOT NULL | DEFAULT 100 |

### TaskAssignment (join table — many assignees per task, polymorphic)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task |
| AssigneeEntityID | UNIQUEIDENTIFIER FK NOT NULL | → __mj.Entity (e.g. "MJ.BizApps.Common: People" or "MJ: AI Agents") |
| AssigneeRecordID | NVARCHAR(450) NOT NULL | Record ID within the assignee entity — NVARCHAR(450) for indexability and composite PK support |
| RoleID | UNIQUEIDENTIFIER FK | → TaskRole (nullable) |
| RoleNotes | NVARCHAR(255) | Free-text qualifier for ad-hoc context, e.g. "reviewing financial section only" |
| Status | NVARCHAR(50) NOT NULL | DEFAULT 'Pending'. CHECK: Pending, InProgress, Completed. Per-assignee progress — lets the chair see who is holding things up on multi-person tasks |
| AssignedByPersonID | UNIQUEIDENTIFIER FK | → BizAppsCommon.Person |
| AssignedAt | DATETIMEOFFSET | DEFAULT GETUTCDATE() |

UNIQUE on (TaskID, AssigneeEntityID, AssigneeRecordID, RoleID)

The polymorphic assignee pattern (EntityID + RecordID) allows tasks to be assigned to any entity type — BizAppsCommon People, MJ AI Agents, or future entity types — without schema changes. This bridges the gap between human task management and agent-oriented automation.

### TaskLink (polymorphic — link tasks to any entity record)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task |
| EntityID | UNIQUEIDENTIFIER FK NOT NULL | → __mj.Entity |
| RecordID | NVARCHAR(450) NOT NULL | Record ID within the linked entity — NVARCHAR(450) for indexability and composite PK support |
| Description | NVARCHAR(500) | Optional context for the link, e.g. "Budget discussion from March meeting" |

UNIQUE on (TaskID, EntityID, RecordID)

TaskLink replaces the need for dedicated bridge tables (like CommitteeTask). Consuming apps link tasks to their own entities via TaskLink — Committees links to Committee/Meeting/AgendaItem records, Izzy could link to its own entities, etc. A single task can link to multiple records across multiple entity types.

### TaskDependency (join table — dependency graph)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task (the dependent) |
| DependsOnTaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task (the prerequisite) |
| DependencyType | NVARCHAR(50) NOT NULL | DEFAULT 'FinishToStart'. CHECK: FinishToStart, StartToStart, FinishToFinish, StartToFinish |

UNIQUE on (TaskID, DependsOnTaskID)

Entity subclass validation:
- **Circular dependency prevention**: BeforeSave walks the dependency graph from DependsOnTaskID and rejects if it reaches TaskID (cycle detected). Non-negotiable for Gantt rendering and dependency-based scheduling.

### TaskTag
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(100) NOT NULL | UNIQUE |
| ColorCode | NVARCHAR(20) | For UI color-coding |
| Description | NVARCHAR(MAX) | |

### TaskTagLink (join table — many tags per task)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task |
| TagID | UNIQUEIDENTIFIER FK NOT NULL | → TaskTag |

UNIQUE on (TaskID, TagID)

Tags are lightweight, cross-cutting labels independent of the hierarchical TaskCategory. Users create their own organizational schemes (e.g. `budget`, `urgent-board-review`, `q2-deliverable`). Especially valuable for "My Tasks" views across multiple committees and for external integration sync (maps to Google Tasks labels).

### TaskComment
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task |
| ParentID | UNIQUEIDENTIFIER FK | Self-ref for threaded replies |
| PersonID | UNIQUEIDENTIFIER FK NOT NULL | → BizAppsCommon.Person |
| Content | NVARCHAR(MAX) NOT NULL | |
| IsEdited | BIT NOT NULL | DEFAULT 0 |

Follows the same pattern as `__mj_Committees.Comment`.

### TaskTemplate
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| Name | NVARCHAR(255) NOT NULL | E.g. "Board Meeting Prep", "Quarterly Audit" |
| Description | NVARCHAR(MAX) | |
| CategoryID | UNIQUEIDENTIFIER FK | → TaskCategory (default category for instantiated tasks) |
| TypeID | UNIQUEIDENTIFIER FK | → TaskType (default type for instantiated tasks) |
| IsActive | BIT NOT NULL | DEFAULT 1 |

### TaskTemplateItem (sub-task structure within a template)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TemplateID | UNIQUEIDENTIFIER FK NOT NULL | → TaskTemplate |
| Name | NVARCHAR(255) NOT NULL | |
| Description | NVARCHAR(MAX) | |
| ParentItemID | UNIQUEIDENTIFIER FK | Self-ref for sub-task hierarchy within template |
| Priority | NVARCHAR(20) NOT NULL | DEFAULT 'Medium' |
| DaysFromStart | INT | Relative due date offset from instantiation date |
| HoursEstimated | DECIMAL(8,2) | |
| Sequence | INT NOT NULL | DEFAULT 100, ordering |

### TaskTemplateItemDependency
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| ItemID | UNIQUEIDENTIFIER FK NOT NULL | → TaskTemplateItem |
| DependsOnItemID | UNIQUEIDENTIFIER FK NOT NULL | → TaskTemplateItem |
| DependencyType | NVARCHAR(50) NOT NULL | DEFAULT 'FinishToStart' |

UNIQUE on (ItemID, DependsOnItemID)

### TaskTemplateItemRole (pre-defined assignment roles per template item)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| ItemID | UNIQUEIDENTIFIER FK NOT NULL | → TaskTemplateItem |
| RoleID | UNIQUEIDENTIFIER FK NOT NULL | → TaskRole |

UNIQUE on (ItemID, RoleID)

A "Create from Template" action hydrates real Tasks from the template — converting DaysFromStart to actual DueAt dates, creating the sub-task hierarchy, dependencies, and placeholder assignments with the pre-defined roles.

### TaskActivity (automatic audit log)
| Column | Type | Notes |
|--------|------|-------|
| ID | UNIQUEIDENTIFIER PK | NEWSEQUENTIALID() |
| TaskID | UNIQUEIDENTIFIER FK NOT NULL | → Task |
| PersonID | UNIQUEIDENTIFIER FK | → BizAppsCommon.Person (who made the change; null for system-generated) |
| ActivityType | NVARCHAR(50) NOT NULL | CHECK: StatusChange, AssignmentAdded, AssignmentRemoved, DueDateChanged, PriorityChanged, PercentCompleteChanged, DependencyAdded, DependencyRemoved, Created, Completed |
| PreviousValue | NVARCHAR(500) | |
| NewValue | NVARCHAR(500) | |
| Description | NVARCHAR(MAX) | Auto-generated human-readable text, e.g. "Status changed from Open to InProgress" |

Activity entries are created automatically by the Task entity subclass (in `BeforeSave`/`AfterSave` hooks) and by TaskAssignment/TaskDependency subclass hooks. In the UI, comments and activity entries interleave in a single chronological timeline (like GitHub issue threads).

---

## 2. Package Structure

**Separate repository**: `github.com/MemberJunction/bizapps-tasks` (same pattern as `bizapps-common`)

```
bizapps-tasks/
  migrations/                  # SQL schema + seed data
  packages/
    Entities/                  # @mj-biz-apps/tasks-entities (CodeGen + custom subclasses)
    Actions/                   # @mj-biz-apps/tasks-actions
    Core/                      # @mj-biz-apps/tasks-core (TaskService, TaskAssignmentService)
    Server/                    # @mj-biz-apps/tasks-server (bootstrap + resolvers)
    Angular/                   # @mj-biz-apps/tasks-ng (UI components)
```

### How consuming apps wire it in

**Server** (`apps/MJAPI/src/index.ts`):
```typescript
import '@mj-biz-apps/tasks-entities';
import { LoadBizAppsTasksServer } from '@mj-biz-apps/tasks-server';
LoadBizAppsTasksServer();
```

**Client** (`apps/MJExplorer/src/app/app.module.ts`):
```typescript
import { LoadBizAppsTasksClient } from '@mj-biz-apps/tasks-ng';
LoadBizAppsTasksClient();
```

**Config** (`mj.config.cjs`):
```javascript
entityPackageName: {
  '__mj_BizAppsCommon': '@mj-biz-apps/common-entities',
  '__mj_BizAppsTasks': '@mj-biz-apps/tasks-entities',  // ← add
}
```

---

## 3. Committees Integration — ActionItem Migration

### Strategy: Replace ActionItems entirely with BizAppsTasks

The current ActionItem (11 columns, single assignee, no sub-tasks/dependencies/comments/hours) is a strict subset of Task + TaskAssignment. We replace it cleanly.

### Integration via TaskLink (no dedicated bridge table)

Committees links tasks to its own entities via the generic TaskLink table. No need for a dedicated CommitteeTask bridge — TaskLink's polymorphic FK (EntityID + RecordID) handles all entity types:

```
TaskLink rows for a committee action item:
  - TaskID → the task, EntityID → "Committees" entity, RecordID → committee ID
  - TaskID → the task, EntityID → "Meetings" entity, RecordID → meeting ID
  - TaskID → the task, EntityID → "Agenda Items" entity, RecordID → agenda item ID
```

A single task can link to multiple committees (cross-committee joint deliverables) via multiple TaskLink rows.

### Data Migration Script
1. Create TaskCategory per committee (name = committee name)
2. For each ActionItem → insert Task (Title→Name, Description, DueDate→DueAt, Priority, Status, CompletedAt, CompletionNotes)
3. Insert TaskAssignment for AssignedToPersonID with Role = "Primary" (using polymorphic assignee pointing to BizAppsCommon People entity)
4. Insert TaskLink rows for CommitteeID, MeetingID, AgendaItemID associations
5. Update Artifact/Comment FKs that referenced ActionItemID
6. Drop ActionItem table + entity

### UI Migration
- Replace `ActionItemTrackerComponent` with embedded `<bizapps-task-list>` scoped to the committee
- Replace `ActionItemEditDialogComponent` with `TaskEditPanelComponent` (slide-in panel)

---

## 4. UI Components (tasks-ng)

### Component Design Pattern: ng-trees Reference

All components follow the patterns established in `@memberjunction/ng-trees`:

- **PascalCase for all public-facing class members** (properties, methods, `@Input()`, `@Output()`)
- **Cancellable Before events**: `@Output() BeforeTaskSelected`, `@Output() BeforeStatusChange`, etc. — emit an event object with a `Cancel` property that consuming apps can set to `true` to prevent the action
- **After events**: `@Output() AfterTaskSelected`, `@Output() AfterStatusChange`, etc. — fire after the action completes, for consuming apps to react
- **Extensive Input properties** for controlling functionality and appearance
- **Public methods** like `Refresh()`, `SelectTask()`, `ClearSelection()` for programmatic control
- **No routing** — components raise events only. Consuming apps (Committees, Izzy, etc.) wire up events to their own routing. This is critically important for reusability across different applications

### Components

| Component | Type | Purpose |
|-----------|------|---------|
| `TaskListComponent` | Standalone | Embeddable, filterable task list. Inputs: CategoryID, ExtraFilter, StatusFilter, ShowCreateButton, Compact, SearchText. Built-in text search across Name/Description. Supports checkbox multi-select for bulk operations. Before/After events for selection, status changes, creation |
| `MyTasksComponent` | Standalone | Wrapper around TaskListComponent filtered to the current user's PersonID (via TaskAssignment), sorted by DueAt. The #1 daily use case — "what do I need to do?" Embeddable by any consuming app |
| `TaskDetailPanelComponent` | Standalone | Read-only slide-in detail view — the default when clicking a task. Shows all fields, activity+comment timeline (with inline comment creation), assignee status dots, sub-task progress rollup, tags, TaskLinks. Has an "Edit" button to switch to TaskEditPanelComponent. Read-first, edit-intentionally. |
| `TaskEditPanelComponent` | Standalone | Slide-in panel for create/edit. Handles assignments (polymorphic — people and agents), tags, TaskLinks, all fields. Inputs: TaskID, DefaultCategoryID, AssigneeScope (ExtraFilter or ID[] to narrow the assignee picker for consuming apps). Opened from TaskDetailPanel's Edit button, or directly for "New Task" |
| `TaskKanbanComponent` | Standalone | Board with columns per status. Drag-and-drop for status changes and reordering (Sequence). Before/AfterStatusChange events |
| `TaskBulkActionsBarComponent` | Standalone | Appears when items are multi-selected in TaskList. Actions: bulk Status change, bulk Reassign, bulk Cancel |
| `TaskTemplateWizardComponent` | Standalone | Multi-step flow for template instantiation: pick template → set start date → preview generated timeline → assign people to role placeholders → optionally customize → create |
| `TaskPriorityBadgeComponent` | Standalone | Inline priority indicator (color-coded) |
| `TaskAssigneeListComponent` | Standalone | Avatar/name chips for assigned entities (people, agents), with per-assignee status indicator (Pending/InProgress/Completed) |
| `TaskGanttComponent` | Standalone | Gantt chart using DHTMLX Gantt library with data mapper for BizAppsTasks entities. Shows dependencies, sub-tasks, timeline |

### Design Rules
- All standalone components with `@if`/`@for` block syntax and `inject()` function
- Slide-in panels, never popup modals
- `<mj-loading>` for spinners
- `@RegisterClass()` for resource-type components
- **No routing in components** — events only, consuming apps own routing

### Urgency & Overdue Indicators
Committee volunteers have day jobs — they need unmissable visual signals to act on tasks:
- **Red highlight** on overdue tasks (DueAt < now, Status not Completed/Cancelled)
- **Amber highlight** on tasks due within 48 hours
- **Overdue badge count** on the nav tab and embedded widget header (e.g. "Action Items (3 overdue)")
- **Per-assignee status dots** on TaskAssigneeListComponent — green (Completed), blue (InProgress), gray (Pending) — so the chair sees at a glance who hasn't started

### Scoped Assignee Picker
TaskEditPanelComponent accepts an optional `AssigneeScope` input — an ExtraFilter string or ID[] array — that consuming apps provide to narrow the assignment picker. In Committees, this scopes to the committee's members. Without scoping, the picker searches all People in BizAppsCommon, which is unusable at scale. The picker supports both Person and Agent entity types via the polymorphic assignee model.

### Mobile UX Strategy
All components must work well on mobile — this isn't a separate mobile app, but responsive design that makes the mobile browser experience first-class:

- **Touch targets**: All interactive elements (buttons, status chips, checkboxes) minimum 44px tap target per iOS/Android guidelines
- **Swipe-to-complete**: TaskListComponent supports swipe-right gesture to mark a task completed on touch devices — the most common mobile action per RK's note
- **Responsive layout breakpoints**: TaskListComponent switches from multi-column table to single-column card layout on narrow screens (<768px). TaskEditPanel goes full-screen on mobile instead of side panel. Kanban board scrolls horizontally with snap-to-column on mobile
- **Quick-action toolbar**: On mobile task list, a sticky bottom bar with the top 3 actions — Complete, Change Status, Reassign — so users don't have to open the full edit panel for common operations
- **Compact mode**: TaskListComponent has a `Compact` input that reduces padding, hides secondary fields (HoursEstimated, Category), and shows only Name, assignee avatar, priority badge, and due date — optimized for scanning on small screens

### Consuming App Usage (Committees example)
```html
<bizapps-task-list
    [CategoryID]="committeeCategoryId"
    [ShowCreateButton]="isOfficer"
    (BeforeTaskSelected)="onBeforeTaskSelected($event)"
    (AfterTaskSelected)="onTaskSelected($event)">
</bizapps-task-list>
```

---

## 5. Scope & Backlog

### Phase 1 (Full Launch)
- **17 database tables** + views + seed data: Task, TaskType, TaskCategory, TaskRole, TaskAssignment, TaskLink, TaskDependency, TaskTag, TaskTagLink, TaskComment, TaskActivity, TaskTemplate, TaskTemplateItem, TaskTemplateItemDependency, TaskTemplateItemRole
- Entity subclasses with validation logic (status transitions, sub-task rollup, cycle detection, circular dependency prevention) + automatic activity log generation in BeforeSave/AfterSave hooks
- Core services: TaskService, TaskAssignmentService, TaskTemplateService
- Server bootstrap (LoadBizAppsTasksServer)
- UI: All components — TaskListComponent (with search + urgency indicators + multi-select), MyTasksComponent, TaskDetailPanelComponent (read-first with inline comment creation + TaskLinks), TaskEditPanelComponent (with scoped assignee picker + polymorphic assignment), TaskKanbanComponent (drag-and-drop), TaskBulkActionsBarComponent, TaskTemplateWizardComponent, TaskGanttComponent, TaskPriorityBadgeComponent, TaskAssigneeListComponent
- **Full Tasks dashboard/app** — register as its own MJ Application with nav, combining list + kanban + gantt views with view toggle, advanced filters
- Committees integration: TaskLink-based linking, data migration from ActionItem, UI swap

### Backlog
- **Recurring tasks** — RecurrenceRule field (RRULE format), server-side scheduler
- **External integrations** — Google Tasks / Microsoft To-Do sync via MJ Actions
- **Notifications** — event handlers on assignment, status changes, overdue
- **Time logging** — separate TimeEntry entity for detailed hours tracking
- **Workflow triggers** — TaskType-based automation (on assignment, completion, overdue)
- **Advanced filtering** — saved filters, saved views

---

## 6. Verification Plan

1. **Schema**: Run migration, verify all 17 tables/FKs/constraints created in `__mj_BizAppsTasks`
2. **CodeGen**: Run `npm run mj:codegen`, verify entity subclasses generated in tasks-entities
3. **Build**: `npm run build` from repo root — all packages compile cleanly
4. **CRUD**: Use GraphQL playground (port 4101) to create/read/update tasks, assignments, dependencies, TaskLinks
5. **Entity validation**: Verify status transition logic (auto-set StartedAt, CompletedAt, PercentComplete), circular dependency rejection, polymorphic assignment to both Person and Agent
6. **UI**: Start Explorer (port 4301), verify all components render with test data — list, kanban, gantt, detail panel, edit panel
7. **Committees**: Verify TaskLink-based linking works, tasks show on committee dashboard
8. **Data migration**: Run migration script, verify all ActionItems converted to Tasks with correct assignments and TaskLink records
