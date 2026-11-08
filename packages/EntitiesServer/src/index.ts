/**
 * BizApps Tasks — server-side entity subclasses.
 *
 * These subclasses add side-effects and authoritative rules that must run server-only
 * (e.g. sub-task progress rollup, OKR check-in propagation, approval decision authority,
 * time entry validation/locking, agent run deduplication, and timesheet approval outcome
 * reconciliation). Import this package and call LoadBizAppsTasksEntitiesServer() from
 * the API bootstrap so the @RegisterClass decorators fire and the server-side subclasses
 * win over the client-safe ones.
 *
 * NOTE: For TasksSettings, TASKS_SETTING, and TASKS_APPLICATION_NAME, import directly
 * from `@mj-biz-apps/tasks-core`.
 */
import { TaskEntityServer } from './TaskEntityServer.js';
import { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
import { TaskDecisionEntityServer } from './TaskDecisionEntityServer.js';
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

export { TaskEntityServer, type TaskActionHookType, type TaskLifecycleContext, type TaskActionHookResult } from './TaskEntityServer.js';
export { TaskCheckInEntityServer } from './TaskCheckInEntityServer.js';
export { TaskDecisionEntityServer, TASK_DECISION_ENTITY } from './TaskDecisionEntityServer.js';
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
    GuidLiteral,
    IsPeopleEntity,
    PEOPLE_ENTITY,
    PeopleFilterForUser,
    PeopleForUser,
    PrimaryPersonIDForUser,
} from './UserPeople.js';

/**
 * Bootstrap / anti-tree-shaking anchor. Call once from MJAPI bootstrap.
 * Referencing the classes here guarantees the decorator-registered server
 * subclasses are included in the bundle and registered.
 */
export function LoadBizAppsTasksEntitiesServer(): void {
    const anchor = [
        TaskEntityServer,
        TaskCheckInEntityServer,
        TaskDecisionEntityServer,
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
    ];
    if (!anchor.length) {
        throw new Error('TaskEntityServer anchor missing');
    }
}
