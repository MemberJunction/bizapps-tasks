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
import { TaskAssignmentEntityServer } from './TaskAssignmentEntityServer.js';
import { TaskLinkEntityServer } from './TaskLinkEntityServer.js';
import { TaskTypeEntityServer, LoadTaskTypeEntityServer } from './TaskTypeEntityServer.js';
import { WorkReportEntityServer, LoadWorkReportEntityServer } from './WorkReportEntityServer.js';
import { WorkReportItemEntityServer, LoadWorkReportItemEntityServer } from './WorkReportItemEntityServer.js';
import { MeetingEntityServer } from './MeetingEntityServer.js';
import { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
import { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
import { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';
import { MeetingNoteEntityServer } from './MeetingNoteEntityServer.js';
import { ZoomVideoProvider } from './video/ZoomVideoProvider.js';
import { MeetingCalendarEventLinkHandler } from './calendar/MeetingCalendarEventLinkHandler.js';
import { registerMeetingServerAIRuntime } from './ai/meeting-ai-runtime.js';

registerMeetingServerAIRuntime();

export { TaskEntityServer, REJECTED_STAGE_CODE } from './TaskEntityServer.js';
export { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
export { TaskDecisionEntityServer, TASK_DECISION_ENTITY } from './TaskDecisionEntityServer.js';
export { TaskAssignmentEntityServer, TASK_ASSIGNMENT_ENTITY } from './TaskAssignmentEntityServer.js';
export { TaskLinkEntityServer, TASK_LINK_ENTITY, WORKFLOW_STEP_ENTITY, AGENT_REQUEST_ENTITY } from './TaskLinkEntityServer.js';
export { PEOPLE_ENTITY } from './UserPeople.js';
export { TaskDecisionRefusal, DeciderAssignments, type TaskDecisionFacts, type DecisionAssignmentFact } from './TaskDecisionAuthority.js';
export { TaskTypeEntityServer, TASK_TYPE_ENTITY, LoadTaskTypeEntityServer } from './TaskTypeEntityServer.js';
export { WorkReportEntityServer, WORK_REPORT_ENTITY, LoadWorkReportEntityServer } from './WorkReportEntityServer.js';
export { WorkReportItemEntityServer, WORK_REPORT_ITEM_ENTITY, LoadWorkReportItemEntityServer } from './WorkReportItemEntityServer.js';
export {
    WorkReportRefusal,
    WorkReportDeleteRefusal,
    WorkReportItemRefusal,
    type WorkReportAuthorityFacts,
    type WorkReportDeleteAuthorityFacts,
    type WorkReportItemAuthorityFacts,
    type WorkReportStatus,
} from './WorkReportAuthority.js';
export { TasksSettings, TASKS_SETTING, TASKS_APPLICATION_NAME, type TasksSettingKey } from './TasksSettings.js';
export { MeetingEntityServer } from './MeetingEntityServer.js';
export { MeetingSeriesEntityServer } from './MeetingSeriesEntityServer.js';
export { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from './MeetingAttendeeEntityServer.js';
export { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from './MeetingAgendaItemEntityServer.js';
export { MeetingNoteEntityServer } from './MeetingNoteEntityServer.js';
export * from './video/VideoProviderBase.js';
export { ZoomVideoProvider } from './video/ZoomVideoProvider.js';
export { MeetingCalendarSyncService, type MeetingCalendarSyncOptions } from './calendar/MeetingCalendarSyncService.js';
export { MeetingCalendarEventLinkHandler, extractMeetingRecordId } from './calendar/MeetingCalendarEventLinkHandler.js';
export { registerMeetingServerAIRuntime, executeServerMeetingAIPrompt, readServerMeetingTranscriptFile } from './ai/meeting-ai-runtime.js';
export { runAfterCommit } from './after-commit.js';

/**
 * Bootstrap / anti-tree-shaking anchor. Call once from MJAPI bootstrap.
 * Referencing the classes here guarantees the decorator-registered server
 * subclasses are included in the bundle and registered.
 */
export function LoadBizAppsTasksEntitiesServer(): void {
    LoadTaskTypeEntityServer();
    LoadWorkReportEntityServer();
    LoadWorkReportItemEntityServer();
    registerMeetingServerAIRuntime();
    // Reference the classes so bundlers cannot tree-shake the registrations away.
    const anchor = [
        TaskEntityServer,
        TaskCheckInEntityServer,
        TaskDecisionEntityServer,
        TaskAssignmentEntityServer,
        TaskLinkEntityServer,
        TaskTypeEntityServer,
        WorkReportEntityServer,
        WorkReportItemEntityServer,
        MeetingEntityServer,
        MeetingSeriesEntityServer,
        MeetingAttendeeEntityServer,
        MeetingSeriesAttendeeEntityServer,
        MeetingAgendaItemEntityServer,
        MeetingLinkEntityServer,
        MeetingNoteEntityServer,
        ZoomVideoProvider,
        MeetingCalendarEventLinkHandler,
    ];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
