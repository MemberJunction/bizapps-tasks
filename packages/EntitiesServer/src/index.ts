/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects that must run server-only (e.g. sub-task
 * progress rollup and OKR check-in propagation, a meeting's organizer row and its video provider). Import this
 * package and call LoadBizAppsTasksEntitiesServer() from the API bootstrap so the @RegisterClass decorators fire and
 * the server-side subclasses win over the client-safe ones.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
import { TaskDecisionEntityServer } from './TaskDecisionEntityServer.js';
import { MeetingEntityServer } from './MeetingEntityServer.js';
import { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
import { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
import { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';
import { MeetingNoteEntityServer } from './MeetingNoteEntityServer.js';


export { TaskEntityServer } from './TaskEntityServer.js';
export { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
export { TaskDecisionEntityServer, TASK_DECISION_ENTITY } from './TaskDecisionEntityServer.js';
export { TaskDecisionRefusal, DeciderAssignments, type TaskDecisionFacts, type DecisionAssignmentFact } from './TaskDecisionAuthority.js';
export { TasksSettings, TASKS_SETTING, TASKS_APPLICATION_NAME, type TasksSettingKey } from './TasksSettings.js';
export { MeetingEntityServer } from './MeetingEntityServer.js';
export { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
export { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
export { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';
export { MeetingNoteEntityServer } from './MeetingNoteEntityServer.js';
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
        TaskCheckInEntityServer,
        TaskDecisionEntityServer,
        MeetingEntityServer,
        MeetingSeriesEntityServer,
        MeetingAttendeeEntityServer,
        MeetingSeriesAttendeeEntityServer,
        MeetingAgendaItemEntityServer,
        MeetingLinkEntityServer,
        MeetingNoteEntityServer,
    ];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
