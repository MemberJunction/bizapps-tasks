/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects and authoritative rules that must run server-only
 * (e.g. sub-task progress rollup, OKR check-in propagation, approval decision authority,
 * time entry validation/locking, agent run deduplication, timesheet approval outcome
 * reconciliation, and a meeting's organizer row and its video provider). Import this
 * package and call LoadBizAppsTasksEntitiesServer() from the API bootstrap so the
 * @RegisterClass decorators fire and the server-side subclasses win over the client-safe ones.
 *
 * NOTE: For TasksSettings, TASKS_SETTING, and TASKS_APPLICATION_NAME, import directly
 * from `@mj-biz-apps/tasks-core`.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
import { TaskDecisionEntityServer } from './TaskDecisionEntityServer.js';
import { TaskAssignmentEntityServer } from './TaskAssignmentEntityServer.js';
import { TaskLinkEntityServer } from './TaskLinkEntityServer.js';
import { TaskTimeEntryEntityServer } from './TaskTimeEntryEntityServer.js';
import { TaskTimerEntityServer } from './TaskTimerEntityServer.js';
import { TaskAgentRunEntityServer } from './TaskAgentRunEntityServer.js';
import { TimesheetEntityServer } from './TimesheetEntityServer.js';
import { TimesheetApprovalEntityServer } from './TimesheetApprovalEntityServer.js';
import { TimeApproverEntityServer } from './TimeApproverEntityServer.js';
import { TimesheetScheduleEntityServer } from './TimesheetScheduleEntityServer.js';
import { TimesheetLinkEntityServer } from './TimesheetLinkEntityServer.js';
import { TaskTimeEntryLinkEntityServer } from './TaskTimeEntryLinkEntityServer.js';
import { TaskLinkScopeApproverResolver } from './BaseTimeApproverResolver.js';
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
import {
    TasksBulkUpdateServerOperation,
    TasksInstantiateTemplateServerOperation,
    TasksRunRecurringPlaybooksServerOperation,
} from './TasksRemoteOperationsServer.js';

registerMeetingServerAIRuntime();

export { TaskEntityServer, REJECTED_STAGE_CODE, type TaskActionHookType, type TaskLifecycleContext, type TaskActionHookResult } from './TaskEntityServer.js';
export { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
export { TaskDecisionEntityServer, TASK_DECISION_ENTITY } from './TaskDecisionEntityServer.js';
export { TaskAssignmentEntityServer, TASK_ASSIGNMENT_ENTITY } from './TaskAssignmentEntityServer.js';
export { TaskLinkEntityServer, TASK_LINK_ENTITY, WORKFLOW_STEP_ENTITY, AGENT_REQUEST_ENTITY } from './TaskLinkEntityServer.js';
export {
    TasksBulkUpdateServerOperation,
    TasksInstantiateTemplateServerOperation,
    TasksRunRecurringPlaybooksServerOperation,
} from './TasksRemoteOperationsServer.js';
export { TaskDecisionRefusal, DeciderAssignments, type TaskDecisionFacts, type DecisionAssignmentFact } from './TaskDecisionAuthority.js';
export { TaskTimeEntryEntityServer, TASK_TIME_ENTRY_ENTITY } from './TaskTimeEntryEntityServer.js';
export { TaskTimerEntityServer, TASK_TIMER_ENTITY } from './TaskTimerEntityServer.js';
export { TaskAgentRunEntityServer, TASK_AGENT_RUN_ENTITY } from './TaskAgentRunEntityServer.js';
export { TimesheetEntityServer, TIMESHEET_ENTITY } from './TimesheetEntityServer.js';
export { TimesheetApprovalEntityServer, TIMESHEET_APPROVAL_ENTITY } from './TimesheetApprovalEntityServer.js';
export { TimeApproverEntityServer, TIME_APPROVER_ENTITY } from './TimeApproverEntityServer.js';
export { TimesheetScheduleEntityServer, TIMESHEET_SCHEDULE_ENTITY } from './TimesheetScheduleEntityServer.js';
export { TimesheetLinkEntityServer, TIMESHEET_LINK_ENTITY } from './TimesheetLinkEntityServer.js';
export { TaskTimeEntryLinkEntityServer, TASK_TIME_ENTRY_LINK_ENTITY } from './TaskTimeEntryLinkEntityServer.js';
export {
    BaseTimeApproverResolver,
    TaskLinkScopeApproverResolver,
} from './BaseTimeApproverResolver.js';
export {
    ApplyTimesheetApprovalOutcomeForTask,
    TIMESHEET_APPROVAL_TASK_TYPE_CODE,
    type TimesheetApprovalOutcomeResult,
} from './TimesheetApprovalOutcome.js';
export {
    VerifyPolymorphicRecordExists,
    type PolymorphicTargetCheckResult,
} from './PolymorphicRecordValidation.js';
export {
    IsPeopleEntity,
    PEOPLE_ENTITY,
    PeopleFilterForUser,
    PeopleForUser,
    PrimaryPersonIDForUser,
} from './UserPeople.js';
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
export { capturePostCommitToken, runAfterCommit } from './after-commit.js';
export {
    resolveAssigneeUserIDsForTarget,
    resolveTaskAssigneeUserIDsByTask,
    wakeAssigneesForTaskAssignment,
    wakeAssigneesForTaskUnblock,
    wakeMeetingParticipantsForTranscript,
} from './cos-wake-helpers.js';

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
        TaskTimeEntryEntityServer,
        TaskTimerEntityServer,
        TaskAgentRunEntityServer,
        TimesheetEntityServer,
        TimesheetApprovalEntityServer,
        TimeApproverEntityServer,
        TimesheetScheduleEntityServer,
        TimesheetLinkEntityServer,
        TaskTimeEntryLinkEntityServer,
        TaskLinkScopeApproverResolver,
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
        TasksBulkUpdateServerOperation,
        TasksInstantiateTemplateServerOperation,
        TasksRunRecurringPlaybooksServerOperation,
    ];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
