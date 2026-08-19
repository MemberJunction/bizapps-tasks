/**
 * BizApps Tasks Angular Bootstrap
 *
 * Client-side bootstrap package for the BizApps Tasks Open App.
 * Imports the entity classes, generated form components, and the class
 * registration manifest so every @RegisterClass decorator fires and nothing
 * gets tree-shaken out of consumer builds.
 */

// Import entity package to trigger @RegisterClass decorators for entity
// subclasses (incl. the custom priority-1 TaskEntity / TaskDependencyEntity).
import '@mj-biz-apps/tasks-entities';

// Import generated form components (triggers @RegisterClass for form components).
import './lib/generated/generated-forms.module.js';

// Import section resources
import './lib/sections/tasks-sections.component.js';
import { LoadTasksSectionResources } from './lib/sections/tasks-sections.component.js';

// Form contributions (header + sub-task gantt/kanban)
import './lib/form-panels/task-forms.module.js';

// Import the class registrations manifest (static code path the bundler can't
// tree-shake — anchors every @RegisterClass class from tasks-entities).
import { CLASS_REGISTRATIONS } from './lib/generated/class-registrations-manifest.js';

// Re-export for consumers.
export { CLASS_REGISTRATIONS } from './lib/generated/class-registrations-manifest.js';

// Generated forms
export * from './lib/generated/generated-forms.module.js';

// Module + bootstrap
export * from './lib/tasks.module.js';

// Standalone components
export * from './lib/components/task-priority-badge/task-priority-badge.component.js';
export * from './lib/components/task-assignee-list/task-assignee-list.component.js';
export * from './lib/components/task-bulk-actions-bar/task-bulk-actions-bar.component.js';
export * from './lib/components/task-list/task-list.component.js';
export * from './lib/components/my-tasks/my-tasks.component.js';
export * from './lib/components/task-detail-panel/task-detail-panel.component.js';
export * from './lib/components/task-edit-panel/task-edit-panel.component.js';
export * from './lib/components/task-kanban/task-kanban.component.js';
export * from './lib/components/task-gantt/task-gantt.component.js';
export * from './lib/components/task-template-wizard/task-template-wizard.component.js';
export * from './lib/components/task-dashboard/task-dashboard.component.js';
export * from './lib/components/task-panel/task-panel.component.js';
export * from './lib/components/approval-decision-panel/approval-decision-panel.component.js';
export * from './lib/components/approval-inbox/approval-inbox.component.js';
export * from './lib/components/task-overview/task-overview.component.js';
export * from './lib/form-panels/task-overview.panel.js';
export * from './lib/form-panels/task-header.panel.js';
export * from './lib/form-panels/task-category-hierarchy.panel.js';
export * from './lib/form-panels/task-template-item-hierarchy.panel.js';

// Pages & Section Resources
export * from './lib/pages/tasks-dashboard.page.js';
export * from './lib/pages/my-tasks.page.js';
export * from './lib/pages/approvals.page.js';
export * from './lib/pages/templates.page.js';
export * from './lib/sections/tasks-sections.component.js';
