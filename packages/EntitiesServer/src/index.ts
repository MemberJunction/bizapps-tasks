/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects that must run server-only (e.g. sub-task
 * progress rollup). Import this package and call LoadBizAppsTasksEntitiesServer()
 * from the API bootstrap so the @RegisterClass decorators fire and the
 * server-side subclasses win over the client-safe ones.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { TaskAssignmentEntityServer } from './TaskAssignmentEntityServer.js';

export { TaskEntityServer } from './TaskEntityServer.js';
export { TaskAssignmentEntityServer } from './TaskAssignmentEntityServer.js';

/**
 * Bootstrap / anti-tree-shaking anchor. Call once from MJAPI bootstrap.
 * Referencing the class here guarantees the decorator-registered server
 * subclass is included in the bundle and registered.
 */
export function LoadBizAppsTasksEntitiesServer(): void {
    // Reference the class so bundlers cannot tree-shake the registration away.
    const anchor = [TaskEntityServer, TaskAssignmentEntityServer];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
