import { LoadGeneratedEntities as LoadTaskEntities } from '@mj-biz-apps/tasks-entities';
import { LoadGeneratedEntities as LoadCommonEntities } from '@mj-biz-apps/common-entities';
import { LoadBizAppsTasksEntitiesServer } from '@mj-biz-apps/tasks-entities-server';

LoadCommonEntities();
LoadTaskEntities();
LoadBizAppsTasksEntitiesServer();

export * from './entity-names.js';
export * from './wire.js';
export * from './world/world.js';
export * from './world/load-world.js';
export * from './checks/task-world.checks.js';
export * from './checks/task-hierarchy.checks.js';
export * from './checks/task-dependencies.checks.js';
export * from './checks/task-assignments.checks.js';
export * from './checks/task-decisions.checks.js';
export * from './checks/task-templates.checks.js';
export * from './checks/task-statuses.checks.js';
export * from './checks/task-action-hooks.checks.js';

export function LoadTasksIntegrationTests(): void {}
