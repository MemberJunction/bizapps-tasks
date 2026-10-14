/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects that must run server-only (e.g. sub-task
 * progress rollup, a meeting's organizer row and its video provider). Import this package and call
 * LoadBizAppsTasksEntitiesServer() from the API bootstrap so the @RegisterClass decorators fire and the
 * server-side subclasses win over the client-safe ones.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { MeetingEntityServer } from './MeetingEntityServer.js';
import { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
import { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
import { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';

export { TaskEntityServer } from './TaskEntityServer.js';
export { MeetingEntityServer } from './MeetingEntityServer.js';
export { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
export { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
export { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';
export * from './video/VideoProviderBase.js';
export { runAfterCommit } from './after-commit.js';

/**
 * Bootstrap / anti-tree-shaking anchor. Call once from MJAPI bootstrap.
 * Referencing the classes here guarantees the decorator-registered server
 * subclasses are included in the bundle and registered.
 */
export function LoadBizAppsTasksEntitiesServer(): void {
    // Reference the classes so bundlers cannot tree-shake the registrations away.
    const anchor = [
        TaskEntityServer,
        MeetingEntityServer,
        MeetingSeriesEntityServer,
        MeetingAttendeeEntityServer,
        MeetingSeriesAttendeeEntityServer,
        MeetingAgendaItemEntityServer,
        MeetingLinkEntityServer,
    ];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
