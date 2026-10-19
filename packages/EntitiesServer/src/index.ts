/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects that must run server-only (e.g. sub-task
 * progress rollup and OKR check-in propagation). Import this package and call
 * LoadBizAppsTasksEntitiesServer() from the API bootstrap so the @RegisterClass
 * decorators fire and the server-side subclasses win over the client-safe ones.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';

export { TaskEntityServer } from './TaskEntityServer.js';
export { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';

/**
 * Bootstrap / anti-tree-shaking anchor. Call once from MJAPI bootstrap.
 * Referencing the classes here guarantees the decorator-registered server
 * subclasses are included in the bundle and registered.
 */
export function LoadBizAppsTasksEntitiesServer(): void {
    // Reference the classes so bundlers cannot tree-shake the registrations away.
    const anchor = [TaskEntityServer, TaskCheckInEntityServer];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
