import { LoadGeneratedEntities as LoadTaskEntities } from '@mj-biz-apps/tasks-entities';
import { LoadGeneratedEntities as LoadCommonEntities } from '@mj-biz-apps/common-entities';

LoadCommonEntities();
LoadTaskEntities();

// The harness is a GraphQL CLIENT: MJAPI runs TaskEntityServer (status sync, activity logging,
// lifecycle hook dispatch) on every save. Registering the server subclass here as well makes the
// client entity re-run those post-save side effects over GraphQL — duplicate TaskActivity rows and
// a second hook dispatch from a process that has no action classes. The @RegisterClass decorators
// fire on module evaluation, so this must be a guarded dynamic import (runtime opt-in for
// direct-DB runs only), not a static import behind an `if`.
if (process.env.MJ_IT_LOAD_ENTITIES_SERVER === '1') {
    const { LoadBizAppsTasksEntitiesServer } = await import('@mj-biz-apps/tasks-entities-server');
    LoadBizAppsTasksEntitiesServer();
}

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
export * from './checks/task-hook-routing.checks.js';

export function LoadTasksIntegrationTests(): void {}
