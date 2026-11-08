import { BaseEntity, EntitySaveOptions, EntityDeleteOptions, CompositeKey, ValidationResult, ValidationErrorInfo, ValidationErrorType, Metadata, ProviderType, DatabaseProviderBase, RunView } from "@memberjunction/core";
import { RegisterClass, UUIDsEqual } from "@memberjunction/global";
import { z } from "zod";

     
 
/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Activities
 */
export const mjBizAppsTasksTaskActivitySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    PersonID: z.string().nullable().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)`),
    ActivityType: z.union([z.literal('AssignmentAdded'), z.literal('AssignmentRemoved'), z.literal('Completed'), z.literal('Created'), z.literal('DecisionRecorded'), z.literal('DependencyAdded'), z.literal('DependencyRemoved'), z.literal('DueDateChanged'), z.literal('PercentCompleteChanged'), z.literal('PriorityChanged'), z.literal('StatusChange')]).describe(`
        * * Field Name: ActivityType
        * * Display Name: Activity Type
        * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * AssignmentAdded
    *   * AssignmentRemoved
    *   * Completed
    *   * Created
    *   * DecisionRecorded
    *   * DependencyAdded
    *   * DependencyRemoved
    *   * DueDateChanged
    *   * PercentCompleteChanged
    *   * PriorityChanged
    *   * StatusChange`),
    PreviousValue: z.string().nullable().describe(`
        * * Field Name: PreviousValue
        * * Display Name: Previous Value
        * * SQL Data Type: nvarchar(500)`),
    NewValue: z.string().nullable().describe(`
        * * Field Name: NewValue
        * * Display Name: New Value
        * * SQL Data Type: nvarchar(500)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTaskActivityEntityType = z.infer<typeof mjBizAppsTasksTaskActivitySchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Agent Runs
 */
export const mjBizAppsTasksTaskAgentRunSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the task agent run link.`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The task the AI agent run contributed to.`),
    AIAgentRunID: z.string().describe(`
        * * Field Name: AIAgentRunID
        * * Display Name: AI Agent Run ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: AI Agent Runs (vwAIAgentRuns.ID)
        * * Description: The MemberJunction AI Agent Run linked to the task.`),
    Role: z.union([z.literal('Assisted'), z.literal('Executed'), z.literal('Planned'), z.literal('Reviewed'), z.literal('Triaged')]).describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(30)
        * * Default Value: Executed
    * * Value List Type: List
    * * Possible Values 
    *   * Assisted
    *   * Executed
    *   * Planned
    *   * Reviewed
    *   * Triaged
        * * Description: How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Optional notes describing what the agent run did for the task.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    AIAgentRun: z.string().nullable().describe(`
        * * Field Name: AIAgentRun
        * * Display Name: AI Agent Run
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskAgentRunEntityType = z.infer<typeof mjBizAppsTasksTaskAgentRunSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Assignments
 */
export const mjBizAppsTasksTaskAssignmentSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    AssigneeEntityID: z.string().describe(`
        * * Field Name: AssigneeEntityID
        * * Display Name: Assignee Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)`),
    AssigneeRecordID: z.string().describe(`
        * * Field Name: AssigneeRecordID
        * * Display Name: Assignee Record ID
        * * SQL Data Type: nvarchar(450)`),
    RoleID: z.string().nullable().describe(`
        * * Field Name: RoleID
        * * Display Name: Role ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Roles (vwTaskRoles.ID)`),
    RoleNotes: z.string().nullable().describe(`
        * * Field Name: RoleNotes
        * * Display Name: Role Notes
        * * SQL Data Type: nvarchar(255)`),
    Status: z.union([z.literal('Completed'), z.literal('InProgress'), z.literal('Pending')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(50)
        * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Completed
    *   * InProgress
    *   * Pending`),
    AssignedByPersonID: z.string().nullable().describe(`
        * * Field Name: AssignedByPersonID
        * * Display Name: Assigned By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)`),
    AssignedAt: z.date().describe(`
        * * Field Name: AssignedAt
        * * Display Name: Assigned At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    AssigneeEntity: z.string().describe(`
        * * Field Name: AssigneeEntity
        * * Display Name: Assignee Entity
        * * SQL Data Type: nvarchar(255)`),
    Role: z.string().nullable().describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(100)`),
    AssignedByPerson: z.string().nullable().describe(`
        * * Field Name: AssignedByPerson
        * * Display Name: Assigned By Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTaskAssignmentEntityType = z.infer<typeof mjBizAppsTasksTaskAssignmentSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Categories
 */
export const mjBizAppsTasksTaskCategorySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    ParentID: z.string().nullable().describe(`
        * * Field Name: ParentID
        * * Display Name: Parent ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)`),
    ColorCode: z.string().nullable().describe(`
        * * Field Name: ColorCode
        * * Display Name: Color Code
        * * SQL Data Type: nvarchar(20)`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parent: z.string().nullable().describe(`
        * * Field Name: Parent
        * * Display Name: Parent
        * * SQL Data Type: nvarchar(255)`),
    RootParentID: z.string().nullable().describe(`
        * * Field Name: RootParentID
        * * Display Name: Root Parent ID
        * * SQL Data Type: uniqueidentifier`),
    ParentIDDepth: z.number().nullable().describe(`
        * * Field Name: ParentIDDepth
        * * Display Name: Parent ID Depth
        * * SQL Data Type: int`),
    ParentIDPath: z.string().nullable().describe(`
        * * Field Name: ParentIDPath
        * * Display Name: Parent ID Path
        * * SQL Data Type: nvarchar(MAX)`),
    ParentIDIsLeaf: z.boolean().nullable().describe(`
        * * Field Name: ParentIDIsLeaf
        * * Display Name: Parent ID Is Leaf
        * * SQL Data Type: bit`),
    ParentIDChildCount: z.number().nullable().describe(`
        * * Field Name: ParentIDChildCount
        * * Display Name: Parent ID Child Count
        * * SQL Data Type: int`),
});

export type mjBizAppsTasksTaskCategoryEntityType = z.infer<typeof mjBizAppsTasksTaskCategorySchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Check Ins
 */
export const mjBizAppsTasksTaskCheckInSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The task, priority objective, or key result this check-in updates.`),
    AuthorPersonID: z.string().nullable().describe(`
        * * Field Name: AuthorPersonID
        * * Display Name: Author Person
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: Optional Person record who authored or approved the check-in.`),
    AuthorUserID: z.string().nullable().describe(`
        * * Field Name: AuthorUserID
        * * Display Name: Author User
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
        * * Description: Optional MemberJunction User who authored or submitted the check-in.`),
    ReportedByAIAgentID: z.string().nullable().describe(`
        * * Field Name: ReportedByAIAgentID
        * * Display Name: Reported By AI Agent
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: AI Agents (vwAIAgents.ID)
        * * Description: Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.`),
    CheckInAt: z.date().describe(`
        * * Field Name: CheckInAt
        * * Display Name: Check-In At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: Timestamp when the check-in occurred.`),
    HealthStatus: z.union([z.literal('AtRisk'), z.literal('Completed'), z.literal('OffTrack'), z.literal('OnTrack'), z.literal('Paused')]).describe(`
        * * Field Name: HealthStatus
        * * Display Name: Health Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: OnTrack
    * * Value List Type: List
    * * Possible Values 
    *   * AtRisk
    *   * Completed
    *   * OffTrack
    *   * OnTrack
    *   * Paused
        * * Description: Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.`),
    ConfidenceScore: z.number().nullable().describe(`
        * * Field Name: ConfidenceScore
        * * Display Name: Confidence Score
        * * SQL Data Type: int
        * * Description: Confidence score (0-100) reported at the time of check-in.`),
    PreviousValue: z.number().nullable().describe(`
        * * Field Name: PreviousValue
        * * Display Name: Previous Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Metric value prior to this check-in.`),
    NewValue: z.number().nullable().describe(`
        * * Field Name: NewValue
        * * Display Name: New Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Updated metric value reported in this check-in.`),
    PercentComplete: z.number().nullable().describe(`
        * * Field Name: PercentComplete
        * * Display Name: Percent Complete
        * * SQL Data Type: int
        * * Description: Percent complete (0-100) reported or computed in this check-in.`),
    Summary: z.string().describe(`
        * * Field Name: Summary
        * * Display Name: Summary
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Narrative summary of accomplishments and status since the last check-in.`),
    Blockers: z.string().nullable().describe(`
        * * Field Name: Blockers
        * * Display Name: Blockers
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Risks, impediments, or cross-team blockers surfaced during the check-in.`),
    NextSteps: z.string().nullable().describe(`
        * * Field Name: NextSteps
        * * Display Name: Next Steps
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Planned next steps and commitments before the next check-in.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task Name
        * * SQL Data Type: nvarchar(255)`),
    AuthorPerson: z.string().nullable().describe(`
        * * Field Name: AuthorPerson
        * * Display Name: Author Person Name
        * * SQL Data Type: nvarchar(250)`),
    AuthorUser: z.string().nullable().describe(`
        * * Field Name: AuthorUser
        * * Display Name: Author User Name
        * * SQL Data Type: nvarchar(100)`),
    ReportedByAIAgent: z.string().nullable().describe(`
        * * Field Name: ReportedByAIAgent
        * * Display Name: Reported By AI Agent Name
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskCheckInEntityType = z.infer<typeof mjBizAppsTasksTaskCheckInSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Comments
 */
export const mjBizAppsTasksTaskCommentSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    ParentID: z.string().nullable().describe(`
        * * Field Name: ParentID
        * * Display Name: Parent ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Comments (vwTaskComments.ID)`),
    PersonID: z.string().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)`),
    Content: z.string().describe(`
        * * Field Name: Content
        * * Display Name: Content
        * * SQL Data Type: nvarchar(MAX)`),
    IsEdited: z.boolean().describe(`
        * * Field Name: IsEdited
        * * Display Name: Is Edited
        * * SQL Data Type: bit
        * * Default Value: 0`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
    RootParentID: z.string().nullable().describe(`
        * * Field Name: RootParentID
        * * Display Name: Root Parent ID
        * * SQL Data Type: uniqueidentifier`),
    ParentIDDepth: z.number().nullable().describe(`
        * * Field Name: ParentIDDepth
        * * Display Name: Parent ID Depth
        * * SQL Data Type: int`),
    ParentIDPath: z.string().nullable().describe(`
        * * Field Name: ParentIDPath
        * * Display Name: Parent ID Path
        * * SQL Data Type: nvarchar(MAX)`),
    ParentIDIsLeaf: z.boolean().nullable().describe(`
        * * Field Name: ParentIDIsLeaf
        * * Display Name: Parent ID Is Leaf
        * * SQL Data Type: bit`),
    ParentIDChildCount: z.number().nullable().describe(`
        * * Field Name: ParentIDChildCount
        * * Display Name: Parent ID Child Count
        * * SQL Data Type: int`),
});

export type mjBizAppsTasksTaskCommentEntityType = z.infer<typeof mjBizAppsTasksTaskCommentSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Decision Outcomes
 */
export const mjBizAppsTasksTaskDecisionOutcomeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)
        * * Description: Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions).`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions).`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100
        * * Description: Display ordering for the outcome in decision pickers.`),
    IsTerminal: z.boolean().describe(`
        * * Field Name: IsTerminal
        * * Display Name: Is Terminal
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: When 0, the outcome is hidden from new decision pickers but preserved on historical decisions.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type mjBizAppsTasksTaskDecisionOutcomeEntityType = z.infer<typeof mjBizAppsTasksTaskDecisionOutcomeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Decisions
 */
export const mjBizAppsTasksTaskDecisionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The task this decision was recorded against.`),
    OutcomeID: z.string().describe(`
        * * Field Name: OutcomeID
        * * Display Name: Outcome ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Decision Outcomes (vwTaskDecisionOutcomes.ID)
        * * Description: The decision outcome (FK to TaskDecisionOutcome).`),
    DecidedByPersonID: z.string().nullable().describe(`
        * * Field Name: DecidedByPersonID
        * * Display Name: Decided By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person who made the decision.`),
    DecidedAt: z.date().describe(`
        * * Field Name: DecidedAt
        * * Display Name: Decided At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()
        * * Description: When the decision was recorded.`),
    DecisionNotes: z.string().nullable().describe(`
        * * Field Name: DecisionNotes
        * * Display Name: Decision Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text rationale or conditions attached to the decision.`),
    TaskAssignmentID: z.string().nullable().describe(`
        * * Field Name: TaskAssignmentID
        * * Display Name: Task Assignment ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Assignments (vwTaskAssignments.ID)
        * * Description: Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Outcome: z.string().describe(`
        * * Field Name: Outcome
        * * Display Name: Outcome
        * * SQL Data Type: nvarchar(100)`),
    DecidedByPerson: z.string().nullable().describe(`
        * * Field Name: DecidedByPerson
        * * Display Name: Decided By Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTaskDecisionEntityType = z.infer<typeof mjBizAppsTasksTaskDecisionSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Dependencies
 */
export const mjBizAppsTasksTaskDependencySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    DependsOnTaskID: z.string().describe(`
        * * Field Name: DependsOnTaskID
        * * Display Name: Depends On Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    DependencyType: z.union([z.literal('FinishToFinish'), z.literal('FinishToStart'), z.literal('StartToFinish'), z.literal('StartToStart')]).describe(`
        * * Field Name: DependencyType
        * * Display Name: Dependency Type
        * * SQL Data Type: nvarchar(50)
        * * Default Value: FinishToStart
    * * Value List Type: List
    * * Possible Values 
    *   * FinishToFinish
    *   * FinishToStart
    *   * StartToFinish
    *   * StartToStart`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    DependsOnTask: z.string().describe(`
        * * Field Name: DependsOnTask
        * * Display Name: Depends On Task
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskDependencyEntityType = z.infer<typeof mjBizAppsTasksTaskDependencySchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Links
 */
export const mjBizAppsTasksTaskLinkSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    EntityID: z.string().describe(`
        * * Field Name: EntityID
        * * Display Name: Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)`),
    RecordID: z.string().describe(`
        * * Field Name: RecordID
        * * Display Name: Record ID
        * * SQL Data Type: nvarchar(450)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(500)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Entity: z.string().describe(`
        * * Field Name: Entity
        * * Display Name: Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskLinkEntityType = z.infer<typeof mjBizAppsTasksTaskLinkSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Notification Configs
 */
export const mjBizAppsTasksTaskNotificationConfigSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskTypeID: z.string().nullable().describe(`
        * * Field Name: TaskTypeID
        * * Display Name: Task Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)`),
    OverdueNotificationsEnabled: z.boolean().describe(`
        * * Field Name: OverdueNotificationsEnabled
        * * Display Name: Overdue Notifications Enabled
        * * SQL Data Type: bit
        * * Default Value: 1`),
    OverdueGracePeriodHours: z.number().describe(`
        * * Field Name: OverdueGracePeriodHours
        * * Display Name: Overdue Grace Period Hours
        * * SQL Data Type: int
        * * Default Value: 0`),
    OverdueRepeatIntervalHours: z.number().nullable().describe(`
        * * Field Name: OverdueRepeatIntervalHours
        * * Display Name: Overdue Repeat Interval Hours
        * * SQL Data Type: int`),
    NotifyAssignees: z.boolean().describe(`
        * * Field Name: NotifyAssignees
        * * Display Name: Notify Assignees
        * * SQL Data Type: bit
        * * Default Value: 1`),
    NotifyCreator: z.boolean().describe(`
        * * Field Name: NotifyCreator
        * * Display Name: Notify Creator
        * * SQL Data Type: bit
        * * Default Value: 1`),
    OverdueActionID: z.string().nullable().describe(`
        * * Field Name: OverdueActionID
        * * Display Name: Overdue Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    TaskType: z.string().nullable().describe(`
        * * Field Name: TaskType
        * * Display Name: Task Type
        * * SQL Data Type: nvarchar(100)`),
    OverdueAction: z.string().nullable().describe(`
        * * Field Name: OverdueAction
        * * Display Name: Overdue Action
        * * SQL Data Type: nvarchar(425)`),
});

export type mjBizAppsTasksTaskNotificationConfigEntityType = z.infer<typeof mjBizAppsTasksTaskNotificationConfigSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Notification Logs
 */
export const mjBizAppsTasksTaskNotificationLogSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    NotificationType: z.union([z.literal('Overdue'), z.literal('OverdueReminder')]).describe(`
        * * Field Name: NotificationType
        * * Display Name: Notification Type
        * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * Overdue
    *   * OverdueReminder`),
    NotifiedUserID: z.string().describe(`
        * * Field Name: NotifiedUserID
        * * Display Name: Notified User ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)`),
    NotifiedAt: z.date().describe(`
        * * Field Name: NotifiedAt
        * * Display Name: Notified At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    NotifiedUser: z.string().describe(`
        * * Field Name: NotifiedUser
        * * Display Name: Notified User
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksTaskNotificationLogEntityType = z.infer<typeof mjBizAppsTasksTaskNotificationLogSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Roles
 */
export const mjBizAppsTasksTaskRoleSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type mjBizAppsTasksTaskRoleEntityType = z.infer<typeof mjBizAppsTasksTaskRoleSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Tag Links
 */
export const mjBizAppsTasksTaskTagLinkSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    TagID: z.string().describe(`
        * * Field Name: TagID
        * * Display Name: Tag ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Tags (vwTaskTags.ID)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Tag: z.string().describe(`
        * * Field Name: Tag
        * * Display Name: Tag
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksTaskTagLinkEntityType = z.infer<typeof mjBizAppsTasksTaskTagLinkSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Tags
 */
export const mjBizAppsTasksTaskTagSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)`),
    ColorCode: z.string().nullable().describe(`
        * * Field Name: ColorCode
        * * Display Name: Color Code
        * * SQL Data Type: nvarchar(20)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type mjBizAppsTasksTaskTagEntityType = z.infer<typeof mjBizAppsTasksTaskTagSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Template Item Dependencies
 */
export const mjBizAppsTasksTaskTemplateItemDependencySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ItemID: z.string().describe(`
        * * Field Name: ItemID
        * * Display Name: Item ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)`),
    DependsOnItemID: z.string().describe(`
        * * Field Name: DependsOnItemID
        * * Display Name: Depends On Item ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)`),
    DependencyType: z.union([z.literal('FinishToFinish'), z.literal('FinishToStart'), z.literal('StartToFinish'), z.literal('StartToStart')]).describe(`
        * * Field Name: DependencyType
        * * Display Name: Dependency Type
        * * SQL Data Type: nvarchar(50)
        * * Default Value: FinishToStart
    * * Value List Type: List
    * * Possible Values 
    *   * FinishToFinish
    *   * FinishToStart
    *   * StartToFinish
    *   * StartToStart`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Item: z.string().describe(`
        * * Field Name: Item
        * * Display Name: Item
        * * SQL Data Type: nvarchar(255)`),
    DependsOnItem: z.string().describe(`
        * * Field Name: DependsOnItem
        * * Display Name: Depends On Item
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskTemplateItemDependencyEntityType = z.infer<typeof mjBizAppsTasksTaskTemplateItemDependencySchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Template Item Roles
 */
export const mjBizAppsTasksTaskTemplateItemRoleSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ItemID: z.string().describe(`
        * * Field Name: ItemID
        * * Display Name: Item ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)`),
    RoleID: z.string().describe(`
        * * Field Name: RoleID
        * * Display Name: Role ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Roles (vwTaskRoles.ID)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Item: z.string().describe(`
        * * Field Name: Item
        * * Display Name: Item
        * * SQL Data Type: nvarchar(255)`),
    Role: z.string().describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksTaskTemplateItemRoleEntityType = z.infer<typeof mjBizAppsTasksTaskTemplateItemRoleSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Template Items
 */
export const mjBizAppsTasksTaskTemplateItemSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TemplateID: z.string().describe(`
        * * Field Name: TemplateID
        * * Display Name: Template ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Templates (vwTaskTemplates.ID)`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    ParentItemID: z.string().nullable().describe(`
        * * Field Name: ParentItemID
        * * Display Name: Parent Item ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)`),
    Priority: z.union([z.literal('Critical'), z.literal('High'), z.literal('Low'), z.literal('Medium')]).describe(`
        * * Field Name: Priority
        * * Display Name: Priority
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium`),
    DaysFromStart: z.number().nullable().describe(`
        * * Field Name: DaysFromStart
        * * Display Name: Days From Start
        * * SQL Data Type: int`),
    HoursEstimated: z.number().nullable().describe(`
        * * Field Name: HoursEstimated
        * * Display Name: Hours Estimated
        * * SQL Data Type: decimal(8, 2)`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Template: z.string().describe(`
        * * Field Name: Template
        * * Display Name: Template
        * * SQL Data Type: nvarchar(255)`),
    ParentItem: z.string().nullable().describe(`
        * * Field Name: ParentItem
        * * Display Name: Parent Item
        * * SQL Data Type: nvarchar(255)`),
    RootParentItemID: z.string().nullable().describe(`
        * * Field Name: RootParentItemID
        * * Display Name: Root Parent Item ID
        * * SQL Data Type: uniqueidentifier`),
    ParentItemIDDepth: z.number().nullable().describe(`
        * * Field Name: ParentItemIDDepth
        * * Display Name: Parent Item ID Depth
        * * SQL Data Type: int`),
    ParentItemIDPath: z.string().nullable().describe(`
        * * Field Name: ParentItemIDPath
        * * Display Name: Parent Item ID Path
        * * SQL Data Type: nvarchar(MAX)`),
    ParentItemIDIsLeaf: z.boolean().nullable().describe(`
        * * Field Name: ParentItemIDIsLeaf
        * * Display Name: Parent Item ID Is Leaf
        * * SQL Data Type: bit`),
    ParentItemIDChildCount: z.number().nullable().describe(`
        * * Field Name: ParentItemIDChildCount
        * * Display Name: Parent Item ID Child Count
        * * SQL Data Type: int`),
});

export type mjBizAppsTasksTaskTemplateItemEntityType = z.infer<typeof mjBizAppsTasksTaskTemplateItemSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Templates
 */
export const mjBizAppsTasksTaskTemplateSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    CategoryID: z.string().nullable().describe(`
        * * Field Name: CategoryID
        * * Display Name: Category ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)`),
    TypeID: z.string().nullable().describe(`
        * * Field Name: TypeID
        * * Display Name: Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Category: z.string().nullable().describe(`
        * * Field Name: Category
        * * Display Name: Category
        * * SQL Data Type: nvarchar(255)`),
    Type: z.string().nullable().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksTaskTemplateEntityType = z.infer<typeof mjBizAppsTasksTaskTemplateSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Time Entries
 */
export const mjBizAppsTasksTaskTimeEntrySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the task time entry.`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The task this time entry is logged against.`),
    PersonID: z.string().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person who performed the work.`),
    WorkDate: z.date().describe(`
        * * Field Name: WorkDate
        * * Display Name: Work Date
        * * SQL Data Type: date
        * * Description: Business calendar date the work was performed on.`),
    Minutes: z.number().describe(`
        * * Field Name: Minutes
        * * Display Name: Minutes
        * * SQL Data Type: int
        * * Description: Duration of work in whole minutes (1 to 1440).`),
    StartedAt: z.date().nullable().describe(`
        * * Field Name: StartedAt
        * * Display Name: Started At
        * * SQL Data Type: datetimeoffset
        * * Description: Optional timestamp when the work interval started (populated for timer-backed entries).`),
    EndedAt: z.date().nullable().describe(`
        * * Field Name: EndedAt
        * * Display Name: Ended At
        * * SQL Data Type: datetimeoffset
        * * Description: Optional timestamp when the work interval ended (populated for timer-backed entries).`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Narrative description of what was accomplished during this time entry.`),
    Source: z.union([z.literal('Agent'), z.literal('Imported'), z.literal('Manual'), z.literal('Timer')]).describe(`
        * * Field Name: Source
        * * Display Name: Source
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Manual
    * * Value List Type: List
    * * Possible Values 
    *   * Agent
    *   * Imported
    *   * Manual
    *   * Timer
        * * Description: How the time entry was created: Manual, Timer, Imported, or Agent.`),
    IsBillable: z.boolean().describe(`
        * * Field Name: IsBillable
        * * Display Name: Is Billable
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Whether this time entry is billable to a client or external party.`),
    TimesheetID: z.string().nullable().describe(`
        * * Field Name: TimesheetID
        * * Display Name: Timesheet ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
        * * Description: Optional Timesheet this time entry has been attached to.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTaskTimeEntryEntityType = z.infer<typeof mjBizAppsTasksTaskTimeEntrySchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Time Entry Links
 */
export const mjBizAppsTasksTaskTimeEntryLinkSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the task time entry link.`),
    TaskTimeEntryID: z.string().describe(`
        * * Field Name: TaskTimeEntryID
        * * Display Name: Task Time Entry ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Time Entries (vwTaskTimeEntries.ID)
        * * Description: The TaskTimeEntry being linked.`),
    EntityID: z.string().describe(`
        * * Field Name: EntityID
        * * Display Name: Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
        * * Description: Target MemberJunction Entity ID for the linked external record.`),
    RecordID: z.string().describe(`
        * * Field Name: RecordID
        * * Display Name: Record ID
        * * SQL Data Type: nvarchar(450)
        * * Description: Primary key value of the linked record in EntityID.`),
    Relationship: z.union([z.literal('Commit'), z.literal('InvoiceLine'), z.literal('JournalEntryLine'), z.literal('PullRequest'), z.literal('Related')]).describe(`
        * * Field Name: Relationship
        * * Display Name: Relationship
        * * SQL Data Type: nvarchar(30)
        * * Default Value: Related
    * * Value List Type: List
    * * Possible Values 
    *   * Commit
    *   * InvoiceLine
    *   * JournalEntryLine
    *   * PullRequest
    *   * Related
        * * Description: Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Entity: z.string().describe(`
        * * Field Name: Entity
        * * Display Name: Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTaskTimeEntryLinkEntityType = z.infer<typeof mjBizAppsTasksTaskTimeEntryLinkSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Timers
 */
export const mjBizAppsTasksTaskTimerSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the running timer.`),
    TaskID: z.string().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The task currently being timed.`),
    PersonID: z.string().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person whose stopwatch is running (unique across TaskTimer).`),
    StartedAt: z.date().describe(`
        * * Field Name: StartedAt
        * * Display Name: Started At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: Timestamp when the timer was started.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.`),
    IsBillable: z.boolean().describe(`
        * * Field Name: IsBillable
        * * Display Name: Is Billable
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Task: z.string().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTaskTimerEntityType = z.infer<typeof mjBizAppsTasksTaskTimerSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Type Status
 */
export const mjBizAppsTasksTaskTypeStatusSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    TaskTypeID: z.string().describe(`
        * * Field Name: TaskTypeID
        * * Display Name: Task Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)
        * * Description: The Task Type this status belongs to.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)
        * * Description: Display name of the status (e.g. Legal Review, Redlining, Pending Signature).`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    MacroStatus: z.union([z.literal('Blocked'), z.literal('Cancelled'), z.literal('Completed'), z.literal('InProgress'), z.literal('Open')]).describe(`
        * * Field Name: MacroStatus
        * * Display Name: Macro Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cancelled
    *   * Completed
    *   * InProgress
    *   * Open
        * * Description: The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100
        * * Description: Ordering sequence for pickers, stage progression bars, and Kanban columns.`),
    IsDefault: z.boolean().describe(`
        * * Field Name: IsDefault
        * * Display Name: Is Default
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Whether this is the initial default status when a task of this type is created.`),
    IsTerminal: z.boolean().describe(`
        * * Field Name: IsTerminal
        * * Display Name: Is Terminal
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Whether this status represents a closed terminal state for the task.`),
    Color: z.string().nullable().describe(`
        * * Field Name: Color
        * * Display Name: Color
        * * SQL Data Type: nvarchar(50)`),
    IconClass: z.string().nullable().describe(`
        * * Field Name: IconClass
        * * Display Name: Icon Class
        * * SQL Data Type: nvarchar(100)`),
    OnEnterActionID: z.string().nullable().describe(`
        * * Field Name: OnEnterActionID
        * * Display Name: On Enter Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked when a task enters this specific status.`),
    OnExitActionID: z.string().nullable().describe(`
        * * Field Name: OnExitActionID
        * * Display Name: On Exit Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked when a task leaves this specific status.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    TaskType: z.string().describe(`
        * * Field Name: TaskType
        * * Display Name: Task Type
        * * SQL Data Type: nvarchar(100)`),
    OnEnterAction: z.string().nullable().describe(`
        * * Field Name: OnEnterAction
        * * Display Name: On Enter Action
        * * SQL Data Type: nvarchar(425)`),
    OnExitAction: z.string().nullable().describe(`
        * * Field Name: OnExitAction
        * * Display Name: On Exit Action
        * * SQL Data Type: nvarchar(425)`),
});

export type mjBizAppsTasksTaskTypeStatusEntityType = z.infer<typeof mjBizAppsTasksTaskTypeStatusSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Task Types
 */
export const mjBizAppsTasksTaskTypeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    IconClass: z.string().nullable().describe(`
        * * Field Name: IconClass
        * * Display Name: Icon Class
        * * SQL Data Type: nvarchar(100)`),
    DefaultPriority: z.union([z.literal('Critical'), z.literal('High'), z.literal('Low'), z.literal('Medium')]).describe(`
        * * Field Name: DefaultPriority
        * * Display Name: Default Priority
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium`),
    OnAssignActionID: z.string().nullable().describe(`
        * * Field Name: OnAssignActionID
        * * Display Name: On Assign Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)`),
    OnCompleteActionID: z.string().nullable().describe(`
        * * Field Name: OnCompleteActionID
        * * Display Name: On Complete Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)`),
    OnOverdueActionID: z.string().nullable().describe(`
        * * Field Name: OnOverdueActionID
        * * Display Name: On Overdue Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)`),
    OnPercentChangeActionID: z.string().nullable().describe(`
        * * Field Name: OnPercentChangeActionID
        * * Display Name: On Percent Change Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    OnRejectActionID: z.string().nullable().describe(`
        * * Field Name: OnRejectActionID
        * * Display Name: On Reject Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows.`),
    OnCancelActionID: z.string().nullable().describe(`
        * * Field Name: OnCancelActionID
        * * Display Name: On Cancel Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking).`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: Stable unique machine code for programmatic lookups and cross-app metadata references.`),
    OnCreateActionID: z.string().nullable().describe(`
        * * Field Name: OnCreateActionID
        * * Display Name: On Create Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).`),
    OnStatusChangeActionID: z.string().nullable().describe(`
        * * Field Name: OnStatusChangeActionID
        * * Display Name: On Status Change Action ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
        * * Description: Action invoked whenever a task of this type changes status.`),
    IsApproval: z.boolean().describe(`
        * * Field Name: IsApproval
        * * Display Name: Is Approval
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: When true, tasks of this type are approvals: they appear in the approvals inbox of each assignee, who records a decision on them.`),
    RequiresAssigneeDecision: z.boolean().describe(`
        * * Field Name: RequiresAssigneeDecision
        * * Display Name: Requires Assignee Decision
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.`),
    OnAssignAction: z.string().nullable().describe(`
        * * Field Name: OnAssignAction
        * * Display Name: On Assign Action
        * * SQL Data Type: nvarchar(425)`),
    OnCompleteAction: z.string().nullable().describe(`
        * * Field Name: OnCompleteAction
        * * Display Name: On Complete Action
        * * SQL Data Type: nvarchar(425)`),
    OnOverdueAction: z.string().nullable().describe(`
        * * Field Name: OnOverdueAction
        * * Display Name: On Overdue Action
        * * SQL Data Type: nvarchar(425)`),
    OnPercentChangeAction: z.string().nullable().describe(`
        * * Field Name: OnPercentChangeAction
        * * Display Name: On Percent Change Action
        * * SQL Data Type: nvarchar(425)`),
    OnRejectAction: z.string().nullable().describe(`
        * * Field Name: OnRejectAction
        * * Display Name: On Reject Action
        * * SQL Data Type: nvarchar(425)`),
    OnCancelAction: z.string().nullable().describe(`
        * * Field Name: OnCancelAction
        * * Display Name: On Cancel Action
        * * SQL Data Type: nvarchar(425)`),
    OnCreateAction: z.string().nullable().describe(`
        * * Field Name: OnCreateAction
        * * Display Name: On Create Action
        * * SQL Data Type: nvarchar(425)`),
    OnStatusChangeAction: z.string().nullable().describe(`
        * * Field Name: OnStatusChangeAction
        * * Display Name: On Status Change Action
        * * SQL Data Type: nvarchar(425)`),
});

export type mjBizAppsTasksTaskTypeEntityType = z.infer<typeof mjBizAppsTasksTaskTypeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Tasks
 */
export const mjBizAppsTasksTaskSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)`),
    TypeID: z.string().describe(`
        * * Field Name: TypeID
        * * Display Name: Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)`),
    CategoryID: z.string().nullable().describe(`
        * * Field Name: CategoryID
        * * Display Name: Category ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)`),
    ParentID: z.string().nullable().describe(`
        * * Field Name: ParentID
        * * Display Name: Parent ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)`),
    Status: z.union([z.literal('Blocked'), z.literal('Cancelled'), z.literal('Completed'), z.literal('InProgress'), z.literal('Open')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(50)
        * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cancelled
    *   * Completed
    *   * InProgress
    *   * Open`),
    Priority: z.union([z.literal('Critical'), z.literal('High'), z.literal('Low'), z.literal('Medium')]).describe(`
        * * Field Name: Priority
        * * Display Name: Priority
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium`),
    StartedAt: z.date().nullable().describe(`
        * * Field Name: StartedAt
        * * Display Name: Started At
        * * SQL Data Type: datetimeoffset`),
    DueAt: z.date().nullable().describe(`
        * * Field Name: DueAt
        * * Display Name: Due Date
        * * SQL Data Type: datetimeoffset`),
    CompletedAt: z.date().nullable().describe(`
        * * Field Name: CompletedAt
        * * Display Name: Completed At
        * * SQL Data Type: datetimeoffset`),
    HoursEstimated: z.number().nullable().describe(`
        * * Field Name: HoursEstimated
        * * Display Name: Hours Estimated
        * * SQL Data Type: decimal(8, 2)`),
    HoursActual: z.number().nullable().describe(`
        * * Field Name: HoursActual
        * * Display Name: Hours Actual
        * * SQL Data Type: decimal(8, 2)`),
    PercentComplete: z.number().describe(`
        * * Field Name: PercentComplete
        * * Display Name: Percent Complete
        * * SQL Data Type: int
        * * Default Value: 0`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100`),
    BlockedReason: z.string().nullable().describe(`
        * * Field Name: BlockedReason
        * * Display Name: Blocked Reason
        * * SQL Data Type: nvarchar(MAX)`),
    CompletionNotes: z.string().nullable().describe(`
        * * Field Name: CompletionNotes
        * * Display Name: Completion Notes
        * * SQL Data Type: nvarchar(MAX)`),
    CreatedByPersonID: z.string().nullable().describe(`
        * * Field Name: CreatedByPersonID
        * * Display Name: Created By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)`),
    OverdueNotifiedAt: z.date().nullable().describe(`
        * * Field Name: OverdueNotifiedAt
        * * Display Name: Overdue Notified At
        * * SQL Data Type: datetimeoffset`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    TaskTypeStatusID: z.string().nullable().describe(`
        * * Field Name: TaskTypeStatusID
        * * Display Name: Task Type Status
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Type Status (vwTaskTypeStatus.ID)
        * * Description: Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.`),
    PredictedSLABreachProbability: z.number().nullable().describe(`
        * * Field Name: PredictedSLABreachProbability
        * * Display Name: SLA Breach Probability
        * * SQL Data Type: decimal(5, 4)
        * * Description: Predicted probability (0.0000 - 1.0000) that this task breaches its target due date or SLA.`),
    PredictedSLARiskBand: z.union([z.literal('Critical'), z.literal('High'), z.literal('Low'), z.literal('Medium')]).nullable().describe(`
        * * Field Name: PredictedSLARiskBand
        * * Display Name: SLA Risk Band
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium
        * * Description: Operational SLA breach risk tier: Low (<0.30), Medium (0.30-0.70), High (>0.70), or Critical.`),
    PredictedSLAScoredAt: z.date().nullable().describe(`
        * * Field Name: PredictedSLAScoredAt
        * * Display Name: SLA Scored At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when this task was last scored by the predictive SLA breach model.`),
    HealthStatus: z.union([z.literal('AtRisk'), z.literal('Completed'), z.literal('OffTrack'), z.literal('OnTrack'), z.literal('Paused')]).nullable().describe(`
        * * Field Name: HealthStatus
        * * Display Name: Health Status
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * AtRisk
    *   * Completed
    *   * OffTrack
    *   * OnTrack
    *   * Paused
        * * Description: Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.`),
    ConfidenceScore: z.number().nullable().describe(`
        * * Field Name: ConfidenceScore
        * * Display Name: Confidence Score
        * * SQL Data Type: int
        * * Description: Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.`),
    BaselineValue: z.number().nullable().describe(`
        * * Field Name: BaselineValue
        * * Display Name: Baseline Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Starting baseline value for measurable key results or quantitative deliverables.`),
    TargetValue: z.number().nullable().describe(`
        * * Field Name: TargetValue
        * * Display Name: Target Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Target goal value for measurable key results or quantitative deliverables.`),
    CurrentValue: z.number().nullable().describe(`
        * * Field Name: CurrentValue
        * * Display Name: Current Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.`),
    UnitOfMeasure: z.string().nullable().describe(`
        * * Field Name: UnitOfMeasure
        * * Display Name: Unit of Measure
        * * SQL Data Type: nvarchar(50)
        * * Description: Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).`),
    MetricDirection: z.union([z.literal('Decrease'), z.literal('Increase'), z.literal('Maintain')]).nullable().describe(`
        * * Field Name: MetricDirection
        * * Display Name: Metric Direction
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Decrease
    *   * Increase
    *   * Maintain
        * * Description: Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.`),
    RollupWeight: z.number().describe(`
        * * Field Name: RollupWeight
        * * Display Name: Rollup Weight
        * * SQL Data Type: decimal(8, 2)
        * * Default Value: 1.00
        * * Description: Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.`),
    PlanningPeriod: z.string().nullable().describe(`
        * * Field Name: PlanningPeriod
        * * Display Name: Planning Period
        * * SQL Data Type: nvarchar(50)
        * * Description: Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).`),
    CheckInCadence: z.union([z.literal('BiWeekly'), z.literal('Daily'), z.literal('Monthly'), z.literal('None'), z.literal('Quarterly'), z.literal('Weekly')]).nullable().describe(`
        * * Field Name: CheckInCadence
        * * Display Name: Check-In Cadence
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * BiWeekly
    *   * Daily
    *   * Monthly
    *   * None
    *   * Quarterly
    *   * Weekly
        * * Description: Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.`),
    LastCheckInAt: z.date().nullable().describe(`
        * * Field Name: LastCheckInAt
        * * Display Name: Last Check-In At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the most recent TaskCheckIn was recorded for this task.`),
    NextCheckInDueAt: z.date().nullable().describe(`
        * * Field Name: NextCheckInDueAt
        * * Display Name: Next Check-In Due At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.`),
    Type: z.string().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
    Category: z.string().nullable().describe(`
        * * Field Name: Category
        * * Display Name: Category
        * * SQL Data Type: nvarchar(255)`),
    Parent: z.string().nullable().describe(`
        * * Field Name: Parent
        * * Display Name: Parent
        * * SQL Data Type: nvarchar(255)`),
    CreatedByPerson: z.string().nullable().describe(`
        * * Field Name: CreatedByPerson
        * * Display Name: Created By Person
        * * SQL Data Type: nvarchar(250)`),
    TaskTypeStatus: z.string().nullable().describe(`
        * * Field Name: TaskTypeStatus
        * * Display Name: Task Type Status Name
        * * SQL Data Type: nvarchar(100)`),
    RootParentID: z.string().nullable().describe(`
        * * Field Name: RootParentID
        * * Display Name: Root Parent ID
        * * SQL Data Type: uniqueidentifier`),
    IsSLABreached: z.string().nullable().describe(`
        * * Field Name: IsSLABreached
        * * Display Name: Is SLA Breached
        * * SQL Data Type: varchar(8)`),
    LeadDays: z.number().nullable().describe(`
        * * Field Name: LeadDays
        * * Display Name: Lead Days
        * * SQL Data Type: int`),
    AssignmentsCount: z.number().describe(`
        * * Field Name: AssignmentsCount
        * * Display Name: Assignments Count
        * * SQL Data Type: int`),
    CommentsCount: z.number().describe(`
        * * Field Name: CommentsCount
        * * Display Name: Comments Count
        * * SQL Data Type: int`),
    LoggedMinutes: z.number().describe(`
        * * Field Name: LoggedMinutes
        * * Display Name: Logged Minutes
        * * SQL Data Type: int`),
    AgentRunCount: z.number().describe(`
        * * Field Name: AgentRunCount
        * * Display Name: Agent Run Count
        * * SQL Data Type: int`),
    AgentCost: z.number().describe(`
        * * Field Name: AgentCost
        * * Display Name: Agent Cost
        * * SQL Data Type: decimal(38, 8)`),
    AgentTokens: z.number().describe(`
        * * Field Name: AgentTokens
        * * Display Name: Agent Tokens
        * * SQL Data Type: int`),
});

export type mjBizAppsTasksTaskEntityType = z.infer<typeof mjBizAppsTasksTaskSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Time Approvers
 */
export const mjBizAppsTasksTimeApproverSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the time approver rule.`),
    ApproverPersonID: z.string().describe(`
        * * Field Name: ApproverPersonID
        * * Display Name: Approver Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person who is granted time approval authority by this rule.`),
    WorkerPersonID: z.string().nullable().describe(`
        * * Field Name: WorkerPersonID
        * * Display Name: Worker Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: Optional Worker Person whose time this rule applies to (NULL matches any worker).`),
    ScopeTaskID: z.string().nullable().describe(`
        * * Field Name: ScopeTaskID
        * * Display Name: Scope Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: Optional project/parent Task this rule scopes approval to (NULL matches any task).`),
    IncludeDescendants: z.boolean().describe(`
        * * Field Name: IncludeDescendants
        * * Display Name: Include Descendants
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.`),
    ScopeEntityID: z.string().nullable().describe(`
        * * Field Name: ScopeEntityID
        * * Display Name: Scope Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
        * * Description: Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.`),
    ScopeRecordID: z.string().nullable().describe(`
        * * Field Name: ScopeRecordID
        * * Display Name: Scope Record ID
        * * SQL Data Type: nvarchar(450)
        * * Description: Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.`),
    EffectiveFrom: z.date().nullable().describe(`
        * * Field Name: EffectiveFrom
        * * Display Name: Effective From
        * * SQL Data Type: date
        * * Description: Optional start date from which this approver rule is effective.`),
    EffectiveTo: z.date().nullable().describe(`
        * * Field Name: EffectiveTo
        * * Display Name: Effective To
        * * SQL Data Type: date
        * * Description: Optional end date through which this approver rule is effective.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: Whether this approver rule is currently active.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Optional administrative notes about this approver rule.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    ApproverPerson: z.string().describe(`
        * * Field Name: ApproverPerson
        * * Display Name: Approver Person
        * * SQL Data Type: nvarchar(250)`),
    WorkerPerson: z.string().nullable().describe(`
        * * Field Name: WorkerPerson
        * * Display Name: Worker Person
        * * SQL Data Type: nvarchar(250)`),
    ScopeTask: z.string().nullable().describe(`
        * * Field Name: ScopeTask
        * * Display Name: Scope Task
        * * SQL Data Type: nvarchar(255)`),
    ScopeEntity: z.string().nullable().describe(`
        * * Field Name: ScopeEntity
        * * Display Name: Scope Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTimeApproverEntityType = z.infer<typeof mjBizAppsTasksTimeApproverSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Timesheet Approvals
 */
export const mjBizAppsTasksTimesheetApprovalSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the timesheet approval part.`),
    TimesheetID: z.string().describe(`
        * * Field Name: TimesheetID
        * * Display Name: Timesheet ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
        * * Description: The Timesheet this approval slice belongs to.`),
    SubmissionRound: z.number().describe(`
        * * Field Name: SubmissionRound
        * * Display Name: Submission Round
        * * SQL Data Type: int
        * * Default Value: 1
        * * Description: Submission round number (1 on initial submit, incremented on each resubmit).`),
    ScopeTaskID: z.string().nullable().describe(`
        * * Field Name: ScopeTaskID
        * * Display Name: Scope Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.`),
    ApprovalTaskID: z.string().describe(`
        * * Field Name: ApprovalTaskID
        * * Display Name: Approval Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: The approval Task created in the Tasks inbox for this slice.`),
    Minutes: z.number().describe(`
        * * Field Name: Minutes
        * * Display Name: Minutes
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Total minutes in this approval slice at submission time.`),
    BillableMinutes: z.number().describe(`
        * * Field Name: BillableMinutes
        * * Display Name: Billable Minutes
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Total billable minutes in this approval slice at submission time.`),
    EntryCount: z.number().describe(`
        * * Field Name: EntryCount
        * * Display Name: Entry Count
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Number of TaskTimeEntry rows included in this approval slice.`),
    SnapshotHash: z.string().describe(`
        * * Field Name: SnapshotHash
        * * Display Name: Snapshot Hash
        * * SQL Data Type: nvarchar(64)
        * * Description: Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.`),
    Status: z.union([z.literal('Approved'), z.literal('Canceled'), z.literal('Pending'), z.literal('Rejected')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Approved
    *   * Canceled
    *   * Pending
    *   * Rejected
        * * Description: Current status of this approval slice: Pending, Approved, Rejected, or Canceled.`),
    DecidedByPersonID: z.string().nullable().describe(`
        * * Field Name: DecidedByPersonID
        * * Display Name: Decided By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person who recorded the approval or rejection decision.`),
    DecidedAt: z.date().nullable().describe(`
        * * Field Name: DecidedAt
        * * Display Name: Decided At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the decision on this slice was recorded.`),
    DecisionNotes: z.string().nullable().describe(`
        * * Field Name: DecisionNotes
        * * Display Name: Decision Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Notes or feedback provided by the approver when deciding this slice.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    ScopeTask: z.string().nullable().describe(`
        * * Field Name: ScopeTask
        * * Display Name: Scope Task
        * * SQL Data Type: nvarchar(255)`),
    ApprovalTask: z.string().describe(`
        * * Field Name: ApprovalTask
        * * Display Name: Approval Task
        * * SQL Data Type: nvarchar(255)`),
    DecidedByPerson: z.string().nullable().describe(`
        * * Field Name: DecidedByPerson
        * * Display Name: Decided By Person
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksTimesheetApprovalEntityType = z.infer<typeof mjBizAppsTasksTimesheetApprovalSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Timesheet Links
 */
export const mjBizAppsTasksTimesheetLinkSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the timesheet link.`),
    TimesheetID: z.string().describe(`
        * * Field Name: TimesheetID
        * * Display Name: Timesheet ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
        * * Description: The Timesheet being linked.`),
    EntityID: z.string().describe(`
        * * Field Name: EntityID
        * * Display Name: Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
        * * Description: Target MemberJunction Entity ID for the linked external record.`),
    RecordID: z.string().describe(`
        * * Field Name: RecordID
        * * Display Name: Record ID
        * * SQL Data Type: nvarchar(450)
        * * Description: Primary key value of the linked record in EntityID.`),
    Relationship: z.union([z.literal('ExpenseReport'), z.literal('Invoice'), z.literal('PayrollBatch'), z.literal('Related')]).describe(`
        * * Field Name: Relationship
        * * Display Name: Relationship
        * * SQL Data Type: nvarchar(30)
        * * Default Value: Related
    * * Value List Type: List
    * * Possible Values 
    *   * ExpenseReport
    *   * Invoice
    *   * PayrollBatch
    *   * Related
        * * Description: Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Entity: z.string().describe(`
        * * Field Name: Entity
        * * Display Name: Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTimesheetLinkEntityType = z.infer<typeof mjBizAppsTasksTimesheetLinkSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Timesheet Schedules
 */
export const mjBizAppsTasksTimesheetScheduleSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the timesheet schedule.`),
    PersonID: z.string().nullable().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).`),
    ScopeEntityID: z.string().nullable().describe(`
        * * Field Name: ScopeEntityID
        * * Display Name: Scope Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
        * * Description: Optional MJ Entity ID when scoping the schedule to an organization or department record.`),
    ScopeRecordID: z.string().nullable().describe(`
        * * Field Name: ScopeRecordID
        * * Display Name: Scope Record ID
        * * SQL Data Type: nvarchar(450)
        * * Description: Companion record ID in ScopeEntityID for entity-scoped schedules.`),
    Cadence: z.union([z.literal('BiWeekly'), z.literal('Monthly'), z.literal('SemiMonthly'), z.literal('Weekly')]).describe(`
        * * Field Name: Cadence
        * * Display Name: Cadence
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * BiWeekly
    *   * Monthly
    *   * SemiMonthly
    *   * Weekly
        * * Description: Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.`),
    WeekStartDay: z.union([z.literal('Monday'), z.literal('Saturday'), z.literal('Sunday')]).describe(`
        * * Field Name: WeekStartDay
        * * Display Name: Week Start Day
        * * SQL Data Type: nvarchar(10)
        * * Default Value: Monday
    * * Value List Type: List
    * * Possible Values 
    *   * Monday
    *   * Saturday
    *   * Sunday
        * * Description: First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.`),
    BiWeeklyAnchorDate: z.date().describe(`
        * * Field Name: BiWeeklyAnchorDate
        * * Display Name: Bi Weekly Anchor Date
        * * SQL Data Type: date
        * * Default Value: 2026-01-05
        * * Description: Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.`),
    EffectiveFrom: z.date().describe(`
        * * Field Name: EffectiveFrom
        * * Display Name: Effective From
        * * SQL Data Type: date
        * * Description: Inclusive start date from which this schedule is effective (must fall on a period boundary).`),
    EffectiveTo: z.date().nullable().describe(`
        * * Field Name: EffectiveTo
        * * Display Name: Effective To
        * * SQL Data Type: date
        * * Description: Optional inclusive end date through which this schedule is effective.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Optional notes explaining this schedule or cadence change.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
    ScopeEntity: z.string().nullable().describe(`
        * * Field Name: ScopeEntity
        * * Display Name: Scope Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksTimesheetScheduleEntityType = z.infer<typeof mjBizAppsTasksTimesheetScheduleSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Timesheets
 */
export const mjBizAppsTasksTimesheetSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key for the timesheet.`),
    PersonID: z.string().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person whose time entries are covered by this timesheet.`),
    PeriodStart: z.date().describe(`
        * * Field Name: PeriodStart
        * * Display Name: Period Start
        * * SQL Data Type: date
        * * Description: Inclusive start date of the timesheet period.`),
    PeriodEnd: z.date().describe(`
        * * Field Name: PeriodEnd
        * * Display Name: Period End
        * * SQL Data Type: date
        * * Description: Inclusive end date of the timesheet period.`),
    Status: z.union([z.literal('Approved'), z.literal('Draft'), z.literal('Rejected'), z.literal('Submitted')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Approved
    *   * Draft
    *   * Rejected
    *   * Submitted
        * * Description: Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.`),
    SubmittedAt: z.date().nullable().describe(`
        * * Field Name: SubmittedAt
        * * Display Name: Submitted At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the timesheet was most recently submitted.`),
    SubmittedByUserID: z.string().nullable().describe(`
        * * Field Name: SubmittedByUserID
        * * Display Name: Submitted By User ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
        * * Description: The MemberJunction User who submitted the timesheet.`),
    TotalMinutes: z.number().describe(`
        * * Field Name: TotalMinutes
        * * Display Name: Total Minutes
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Total minutes across all time entries attached to this timesheet.`),
    BillableMinutes: z.number().describe(`
        * * Field Name: BillableMinutes
        * * Display Name: Billable Minutes
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Total billable minutes across all time entries attached to this timesheet.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Worker notes or comments submitted with the timesheet.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Person: z.string().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
    SubmittedByUser: z.string().nullable().describe(`
        * * Field Name: SubmittedByUser
        * * Display Name: Submitted By User
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksTimesheetEntityType = z.infer<typeof mjBizAppsTasksTimesheetSchema>;
 
 

/**
 * MJ_BizApps_Tasks: Task Activities - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskActivity
 * * Base View: vwTaskActivities
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Activities')
export class mjBizAppsTasksTaskActivityEntity extends BaseEntity<mjBizAppsTasksTaskActivityEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Activities record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Activities record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskActivityEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    */
    get PersonID(): string | null {
        return this.Get('PersonID');
    }
    set PersonID(value: string | null) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: ActivityType
    * * Display Name: Activity Type
    * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * AssignmentAdded
    *   * AssignmentRemoved
    *   * Completed
    *   * Created
    *   * DecisionRecorded
    *   * DependencyAdded
    *   * DependencyRemoved
    *   * DueDateChanged
    *   * PercentCompleteChanged
    *   * PriorityChanged
    *   * StatusChange
    */
    get ActivityType(): 'AssignmentAdded' | 'AssignmentRemoved' | 'Completed' | 'Created' | 'DecisionRecorded' | 'DependencyAdded' | 'DependencyRemoved' | 'DueDateChanged' | 'PercentCompleteChanged' | 'PriorityChanged' | 'StatusChange' {
        return this.Get('ActivityType');
    }
    set ActivityType(value: 'AssignmentAdded' | 'AssignmentRemoved' | 'Completed' | 'Created' | 'DecisionRecorded' | 'DependencyAdded' | 'DependencyRemoved' | 'DueDateChanged' | 'PercentCompleteChanged' | 'PriorityChanged' | 'StatusChange') {
        this.Set('ActivityType', value);
    }

    /**
    * * Field Name: PreviousValue
    * * Display Name: Previous Value
    * * SQL Data Type: nvarchar(500)
    */
    get PreviousValue(): string | null {
        return this.Get('PreviousValue');
    }
    set PreviousValue(value: string | null) {
        this.Set('PreviousValue', value);
    }

    /**
    * * Field Name: NewValue
    * * Display Name: New Value
    * * SQL Data Type: nvarchar(500)
    */
    get NewValue(): string | null {
        return this.Get('NewValue');
    }
    set NewValue(value: string | null) {
        this.Set('NewValue', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string | null {
        return this.Get('Person');
    }
}


/**
 * MJ_BizApps_Tasks: Task Agent Runs - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskAgentRun
 * * Base View: vwTaskAgentRuns
 * * @description Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Agent Runs')
export class mjBizAppsTasksTaskAgentRunEntity extends BaseEntity<mjBizAppsTasksTaskAgentRunEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Agent Runs record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Agent Runs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskAgentRunEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the task agent run link.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The task the AI agent run contributed to.
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: AIAgentRunID
    * * Display Name: AI Agent Run ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: AI Agent Runs (vwAIAgentRuns.ID)
    * * Description: The MemberJunction AI Agent Run linked to the task.
    */
    get AIAgentRunID(): string {
        return this.Get('AIAgentRunID');
    }
    set AIAgentRunID(value: string) {
        this.Set('AIAgentRunID', value);
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(30)
    * * Default Value: Executed
    * * Value List Type: List
    * * Possible Values 
    *   * Assisted
    *   * Executed
    *   * Planned
    *   * Reviewed
    *   * Triaged
    * * Description: How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.
    */
    get Role(): 'Assisted' | 'Executed' | 'Planned' | 'Reviewed' | 'Triaged' {
        return this.Get('Role');
    }
    set Role(value: 'Assisted' | 'Executed' | 'Planned' | 'Reviewed' | 'Triaged') {
        this.Set('Role', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Optional notes describing what the agent run did for the task.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: AIAgentRun
    * * Display Name: AI Agent Run
    * * SQL Data Type: nvarchar(255)
    */
    get AIAgentRun(): string | null {
        return this.Get('AIAgentRun');
    }
}


/**
 * MJ_BizApps_Tasks: Task Assignments - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskAssignment
 * * Base View: vwTaskAssignments
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Assignments')
export class mjBizAppsTasksTaskAssignmentEntity extends BaseEntity<mjBizAppsTasksTaskAssignmentEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Assignments record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Assignments record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskAssignmentEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: AssigneeEntityID
    * * Display Name: Assignee Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    */
    get AssigneeEntityID(): string {
        return this.Get('AssigneeEntityID');
    }
    set AssigneeEntityID(value: string) {
        this.Set('AssigneeEntityID', value);
    }

    /**
    * * Field Name: AssigneeRecordID
    * * Display Name: Assignee Record ID
    * * SQL Data Type: nvarchar(450)
    */
    get AssigneeRecordID(): string {
        return this.Get('AssigneeRecordID');
    }
    set AssigneeRecordID(value: string) {
        this.Set('AssigneeRecordID', value);
    }

    /**
    * * Field Name: RoleID
    * * Display Name: Role ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Roles (vwTaskRoles.ID)
    */
    get RoleID(): string | null {
        return this.Get('RoleID');
    }
    set RoleID(value: string | null) {
        this.Set('RoleID', value);
    }

    /**
    * * Field Name: RoleNotes
    * * Display Name: Role Notes
    * * SQL Data Type: nvarchar(255)
    */
    get RoleNotes(): string | null {
        return this.Get('RoleNotes');
    }
    set RoleNotes(value: string | null) {
        this.Set('RoleNotes', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(50)
    * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Completed
    *   * InProgress
    *   * Pending
    */
    get Status(): 'Completed' | 'InProgress' | 'Pending' {
        return this.Get('Status');
    }
    set Status(value: 'Completed' | 'InProgress' | 'Pending') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: AssignedByPersonID
    * * Display Name: Assigned By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    */
    get AssignedByPersonID(): string | null {
        return this.Get('AssignedByPersonID');
    }
    set AssignedByPersonID(value: string | null) {
        this.Set('AssignedByPersonID', value);
    }

    /**
    * * Field Name: AssignedAt
    * * Display Name: Assigned At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get AssignedAt(): Date {
        return this.Get('AssignedAt');
    }
    set AssignedAt(value: Date) {
        this.Set('AssignedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: AssigneeEntity
    * * Display Name: Assignee Entity
    * * SQL Data Type: nvarchar(255)
    */
    get AssigneeEntity(): string {
        return this.Get('AssigneeEntity');
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(100)
    */
    get Role(): string | null {
        return this.Get('Role');
    }

    /**
    * * Field Name: AssignedByPerson
    * * Display Name: Assigned By Person
    * * SQL Data Type: nvarchar(250)
    */
    get AssignedByPerson(): string | null {
        return this.Get('AssignedByPerson');
    }
}


/**
 * MJ_BizApps_Tasks: Task Categories - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskCategory
 * * Base View: vwTaskCategories
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Categories')
export class mjBizAppsTasksTaskCategoryEntity extends BaseEntity<mjBizAppsTasksTaskCategoryEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Categories record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Categories record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskCategoryEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(255)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: ParentID
    * * Display Name: Parent ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)
    */
    get ParentID(): string | null {
        return this.Get('ParentID');
    }
    set ParentID(value: string | null) {
        this.Set('ParentID', value);
    }

    /**
    * * Field Name: ColorCode
    * * Display Name: Color Code
    * * SQL Data Type: nvarchar(20)
    */
    get ColorCode(): string | null {
        return this.Get('ColorCode');
    }
    set ColorCode(value: string | null) {
        this.Set('ColorCode', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parent
    * * Display Name: Parent
    * * SQL Data Type: nvarchar(255)
    */
    get Parent(): string | null {
        return this.Get('Parent');
    }

    /**
    * * Field Name: RootParentID
    * * Display Name: Root Parent ID
    * * SQL Data Type: uniqueidentifier
    */
    get RootParentID(): string | null {
        return this.Get('RootParentID');
    }

    /**
    * * Field Name: ParentIDDepth
    * * Display Name: Parent ID Depth
    * * SQL Data Type: int
    */
    get ParentIDDepth(): number | null {
        return this.Get('ParentIDDepth');
    }

    /**
    * * Field Name: ParentIDPath
    * * Display Name: Parent ID Path
    * * SQL Data Type: nvarchar(MAX)
    */
    get ParentIDPath(): string | null {
        return this.Get('ParentIDPath');
    }

    /**
    * * Field Name: ParentIDIsLeaf
    * * Display Name: Parent ID Is Leaf
    * * SQL Data Type: bit
    */
    get ParentIDIsLeaf(): boolean | null {
        return this.Get('ParentIDIsLeaf');
    }

    /**
    * * Field Name: ParentIDChildCount
    * * Display Name: Parent ID Child Count
    * * SQL Data Type: int
    */
    get ParentIDChildCount(): number | null {
        return this.Get('ParentIDChildCount');
    }
}


/**
 * MJ_BizApps_Tasks: Task Check Ins - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskCheckIn
 * * Base View: vwTaskCheckIns
 * * @description Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Check Ins')
export class mjBizAppsTasksTaskCheckInEntity extends BaseEntity<mjBizAppsTasksTaskCheckInEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Check Ins record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Check Ins record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskCheckInEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Task Check Ins entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * ConfidenceScore: Confidence score must be between 0 and 100 if specified.
    * * PercentComplete: Percent complete must be between 0 and 100 when provided.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateConfidenceScoreRange(result);
        this.ValidatePercentCompleteRange(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Confidence score must be between 0 and 100 if specified.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateConfidenceScoreRange(result: ValidationResult) {
    	if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"ConfidenceScore",
    			"Confidence score must be between 0 and 100.",
    			this.ConfidenceScore,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * Percent complete must be between 0 and 100 when provided.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidatePercentCompleteRange(result: ValidationResult) {
    	if (this.PercentComplete != null && (this.PercentComplete < 0 || this.PercentComplete > 100)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"PercentComplete",
    			"Percent complete must be between 0 and 100.",
    			this.PercentComplete,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The task, priority objective, or key result this check-in updates.
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: AuthorPersonID
    * * Display Name: Author Person
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: Optional Person record who authored or approved the check-in.
    */
    get AuthorPersonID(): string | null {
        return this.Get('AuthorPersonID');
    }
    set AuthorPersonID(value: string | null) {
        this.Set('AuthorPersonID', value);
    }

    /**
    * * Field Name: AuthorUserID
    * * Display Name: Author User
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
    * * Description: Optional MemberJunction User who authored or submitted the check-in.
    */
    get AuthorUserID(): string | null {
        return this.Get('AuthorUserID');
    }
    set AuthorUserID(value: string | null) {
        this.Set('AuthorUserID', value);
    }

    /**
    * * Field Name: ReportedByAIAgentID
    * * Display Name: Reported By AI Agent
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: AI Agents (vwAIAgents.ID)
    * * Description: Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.
    */
    get ReportedByAIAgentID(): string | null {
        return this.Get('ReportedByAIAgentID');
    }
    set ReportedByAIAgentID(value: string | null) {
        this.Set('ReportedByAIAgentID', value);
    }

    /**
    * * Field Name: CheckInAt
    * * Display Name: Check-In At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: Timestamp when the check-in occurred.
    */
    get CheckInAt(): Date {
        return this.Get('CheckInAt');
    }
    set CheckInAt(value: Date) {
        this.Set('CheckInAt', value);
    }

    /**
    * * Field Name: HealthStatus
    * * Display Name: Health Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: OnTrack
    * * Value List Type: List
    * * Possible Values 
    *   * AtRisk
    *   * Completed
    *   * OffTrack
    *   * OnTrack
    *   * Paused
    * * Description: Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.
    */
    get HealthStatus(): 'AtRisk' | 'Completed' | 'OffTrack' | 'OnTrack' | 'Paused' {
        return this.Get('HealthStatus');
    }
    set HealthStatus(value: 'AtRisk' | 'Completed' | 'OffTrack' | 'OnTrack' | 'Paused') {
        this.Set('HealthStatus', value);
    }

    /**
    * * Field Name: ConfidenceScore
    * * Display Name: Confidence Score
    * * SQL Data Type: int
    * * Description: Confidence score (0-100) reported at the time of check-in.
    */
    get ConfidenceScore(): number | null {
        return this.Get('ConfidenceScore');
    }
    set ConfidenceScore(value: number | null) {
        this.Set('ConfidenceScore', value);
    }

    /**
    * * Field Name: PreviousValue
    * * Display Name: Previous Value
    * * SQL Data Type: decimal(18, 4)
    * * Description: Metric value prior to this check-in.
    */
    get PreviousValue(): number | null {
        return this.Get('PreviousValue');
    }
    set PreviousValue(value: number | null) {
        this.Set('PreviousValue', value);
    }

    /**
    * * Field Name: NewValue
    * * Display Name: New Value
    * * SQL Data Type: decimal(18, 4)
    * * Description: Updated metric value reported in this check-in.
    */
    get NewValue(): number | null {
        return this.Get('NewValue');
    }
    set NewValue(value: number | null) {
        this.Set('NewValue', value);
    }

    /**
    * * Field Name: PercentComplete
    * * Display Name: Percent Complete
    * * SQL Data Type: int
    * * Description: Percent complete (0-100) reported or computed in this check-in.
    */
    get PercentComplete(): number | null {
        return this.Get('PercentComplete');
    }
    set PercentComplete(value: number | null) {
        this.Set('PercentComplete', value);
    }

    /**
    * * Field Name: Summary
    * * Display Name: Summary
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Narrative summary of accomplishments and status since the last check-in.
    */
    get Summary(): string {
        return this.Get('Summary');
    }
    set Summary(value: string) {
        this.Set('Summary', value);
    }

    /**
    * * Field Name: Blockers
    * * Display Name: Blockers
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Risks, impediments, or cross-team blockers surfaced during the check-in.
    */
    get Blockers(): string | null {
        return this.Get('Blockers');
    }
    set Blockers(value: string | null) {
        this.Set('Blockers', value);
    }

    /**
    * * Field Name: NextSteps
    * * Display Name: Next Steps
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Planned next steps and commitments before the next check-in.
    */
    get NextSteps(): string | null {
        return this.Get('NextSteps');
    }
    set NextSteps(value: string | null) {
        this.Set('NextSteps', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task Name
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: AuthorPerson
    * * Display Name: Author Person Name
    * * SQL Data Type: nvarchar(250)
    */
    get AuthorPerson(): string | null {
        return this.Get('AuthorPerson');
    }

    /**
    * * Field Name: AuthorUser
    * * Display Name: Author User Name
    * * SQL Data Type: nvarchar(100)
    */
    get AuthorUser(): string | null {
        return this.Get('AuthorUser');
    }

    /**
    * * Field Name: ReportedByAIAgent
    * * Display Name: Reported By AI Agent Name
    * * SQL Data Type: nvarchar(255)
    */
    get ReportedByAIAgent(): string | null {
        return this.Get('ReportedByAIAgent');
    }
}


/**
 * MJ_BizApps_Tasks: Task Comments - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskComment
 * * Base View: vwTaskComments
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Comments')
export class mjBizAppsTasksTaskCommentEntity extends BaseEntity<mjBizAppsTasksTaskCommentEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Comments record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Comments record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskCommentEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: ParentID
    * * Display Name: Parent ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Comments (vwTaskComments.ID)
    */
    get ParentID(): string | null {
        return this.Get('ParentID');
    }
    set ParentID(value: string | null) {
        this.Set('ParentID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    */
    get PersonID(): string {
        return this.Get('PersonID');
    }
    set PersonID(value: string) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: Content
    * * Display Name: Content
    * * SQL Data Type: nvarchar(MAX)
    */
    get Content(): string {
        return this.Get('Content');
    }
    set Content(value: string) {
        this.Set('Content', value);
    }

    /**
    * * Field Name: IsEdited
    * * Display Name: Is Edited
    * * SQL Data Type: bit
    * * Default Value: 0
    */
    get IsEdited(): boolean {
        return this.Get('IsEdited');
    }
    set IsEdited(value: boolean) {
        this.Set('IsEdited', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string {
        return this.Get('Person');
    }

    /**
    * * Field Name: RootParentID
    * * Display Name: Root Parent ID
    * * SQL Data Type: uniqueidentifier
    */
    get RootParentID(): string | null {
        return this.Get('RootParentID');
    }

    /**
    * * Field Name: ParentIDDepth
    * * Display Name: Parent ID Depth
    * * SQL Data Type: int
    */
    get ParentIDDepth(): number | null {
        return this.Get('ParentIDDepth');
    }

    /**
    * * Field Name: ParentIDPath
    * * Display Name: Parent ID Path
    * * SQL Data Type: nvarchar(MAX)
    */
    get ParentIDPath(): string | null {
        return this.Get('ParentIDPath');
    }

    /**
    * * Field Name: ParentIDIsLeaf
    * * Display Name: Parent ID Is Leaf
    * * SQL Data Type: bit
    */
    get ParentIDIsLeaf(): boolean | null {
        return this.Get('ParentIDIsLeaf');
    }

    /**
    * * Field Name: ParentIDChildCount
    * * Display Name: Parent ID Child Count
    * * SQL Data Type: int
    */
    get ParentIDChildCount(): number | null {
        return this.Get('ParentIDChildCount');
    }
}


/**
 * MJ_BizApps_Tasks: Task Decision Outcomes - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskDecisionOutcome
 * * Base View: vwTaskDecisionOutcomes
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Decision Outcomes')
export class mjBizAppsTasksTaskDecisionOutcomeEntity extends BaseEntity<mjBizAppsTasksTaskDecisionOutcomeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Decision Outcomes record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Decision Outcomes record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskDecisionOutcomeEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(100)
    * * Description: Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions).
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Code
    * * Display Name: Code
    * * SQL Data Type: nvarchar(50)
    * * Description: Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions).
    */
    get Code(): string {
        return this.Get('Code');
    }
    set Code(value: string) {
        this.Set('Code', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    * * Description: Display ordering for the outcome in decision pickers.
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: IsTerminal
    * * Display Name: Is Terminal
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open.
    */
    get IsTerminal(): boolean {
        return this.Get('IsTerminal');
    }
    set IsTerminal(value: boolean) {
        this.Set('IsTerminal', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: When 0, the outcome is hidden from new decision pickers but preserved on historical decisions.
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * MJ_BizApps_Tasks: Task Decisions - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskDecision
 * * Base View: vwTaskDecisions
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Decisions')
export class mjBizAppsTasksTaskDecisionEntity extends BaseEntity<mjBizAppsTasksTaskDecisionEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Decisions record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Decisions record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskDecisionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The task this decision was recorded against.
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: OutcomeID
    * * Display Name: Outcome ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Decision Outcomes (vwTaskDecisionOutcomes.ID)
    * * Description: The decision outcome (FK to TaskDecisionOutcome).
    */
    get OutcomeID(): string {
        return this.Get('OutcomeID');
    }
    set OutcomeID(value: string) {
        this.Set('OutcomeID', value);
    }

    /**
    * * Field Name: DecidedByPersonID
    * * Display Name: Decided By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person who made the decision.
    */
    get DecidedByPersonID(): string | null {
        return this.Get('DecidedByPersonID');
    }
    set DecidedByPersonID(value: string | null) {
        this.Set('DecidedByPersonID', value);
    }

    /**
    * * Field Name: DecidedAt
    * * Display Name: Decided At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    * * Description: When the decision was recorded.
    */
    get DecidedAt(): Date {
        return this.Get('DecidedAt');
    }
    set DecidedAt(value: Date) {
        this.Set('DecidedAt', value);
    }

    /**
    * * Field Name: DecisionNotes
    * * Display Name: Decision Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text rationale or conditions attached to the decision.
    */
    get DecisionNotes(): string | null {
        return this.Get('DecisionNotes');
    }
    set DecisionNotes(value: string | null) {
        this.Set('DecisionNotes', value);
    }

    /**
    * * Field Name: TaskAssignmentID
    * * Display Name: Task Assignment ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Assignments (vwTaskAssignments.ID)
    * * Description: Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision.
    */
    get TaskAssignmentID(): string | null {
        return this.Get('TaskAssignmentID');
    }
    set TaskAssignmentID(value: string | null) {
        this.Set('TaskAssignmentID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Outcome
    * * Display Name: Outcome
    * * SQL Data Type: nvarchar(100)
    */
    get Outcome(): string {
        return this.Get('Outcome');
    }

    /**
    * * Field Name: DecidedByPerson
    * * Display Name: Decided By Person
    * * SQL Data Type: nvarchar(250)
    */
    get DecidedByPerson(): string | null {
        return this.Get('DecidedByPerson');
    }
}


/**
 * MJ_BizApps_Tasks: Task Dependencies - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskDependency
 * * Base View: vwTaskDependencies
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Dependencies')
export class mjBizAppsTasksTaskDependencyEntity extends BaseEntity<mjBizAppsTasksTaskDependencyEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Dependencies record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Dependencies record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskDependencyEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Task Dependencies entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: A task cannot depend on itself.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateTaskIDNotEqualToDependsOnTaskID(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * A task cannot depend on itself.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateTaskIDNotEqualToDependsOnTaskID(result: ValidationResult) {
    	if (this.TaskID != null && this.DependsOnTaskID != null && UUIDsEqual(this.TaskID, this.DependsOnTaskID)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"DependsOnTaskID",
    			"A task cannot depend on itself. TaskID and DependsOnTaskID must be different.",
    			this.DependsOnTaskID,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: DependsOnTaskID
    * * Display Name: Depends On Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get DependsOnTaskID(): string {
        return this.Get('DependsOnTaskID');
    }
    set DependsOnTaskID(value: string) {
        this.Set('DependsOnTaskID', value);
    }

    /**
    * * Field Name: DependencyType
    * * Display Name: Dependency Type
    * * SQL Data Type: nvarchar(50)
    * * Default Value: FinishToStart
    * * Value List Type: List
    * * Possible Values 
    *   * FinishToFinish
    *   * FinishToStart
    *   * StartToFinish
    *   * StartToStart
    */
    get DependencyType(): 'FinishToFinish' | 'FinishToStart' | 'StartToFinish' | 'StartToStart' {
        return this.Get('DependencyType');
    }
    set DependencyType(value: 'FinishToFinish' | 'FinishToStart' | 'StartToFinish' | 'StartToStart') {
        this.Set('DependencyType', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: DependsOnTask
    * * Display Name: Depends On Task
    * * SQL Data Type: nvarchar(255)
    */
    get DependsOnTask(): string {
        return this.Get('DependsOnTask');
    }
}


/**
 * MJ_BizApps_Tasks: Task Links - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskLink
 * * Base View: vwTaskLinks
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Links')
export class mjBizAppsTasksTaskLinkEntity extends BaseEntity<mjBizAppsTasksTaskLinkEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Links record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Links record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskLinkEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: EntityID
    * * Display Name: Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    */
    get EntityID(): string {
        return this.Get('EntityID');
    }
    set EntityID(value: string) {
        this.Set('EntityID', value);
    }

    /**
    * * Field Name: RecordID
    * * Display Name: Record ID
    * * SQL Data Type: nvarchar(450)
    */
    get RecordID(): string {
        return this.Get('RecordID');
    }
    set RecordID(value: string) {
        this.Set('RecordID', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(500)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Entity
    * * Display Name: Entity
    * * SQL Data Type: nvarchar(255)
    */
    get Entity(): string {
        return this.Get('Entity');
    }
}


/**
 * MJ_BizApps_Tasks: Task Notification Configs - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskNotificationConfig
 * * Base View: vwTaskNotificationConfigs
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Notification Configs')
export class mjBizAppsTasksTaskNotificationConfigEntity extends BaseEntity<mjBizAppsTasksTaskNotificationConfigEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Notification Configs record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Notification Configs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskNotificationConfigEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskTypeID
    * * Display Name: Task Type ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)
    */
    get TaskTypeID(): string | null {
        return this.Get('TaskTypeID');
    }
    set TaskTypeID(value: string | null) {
        this.Set('TaskTypeID', value);
    }

    /**
    * * Field Name: OverdueNotificationsEnabled
    * * Display Name: Overdue Notifications Enabled
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get OverdueNotificationsEnabled(): boolean {
        return this.Get('OverdueNotificationsEnabled');
    }
    set OverdueNotificationsEnabled(value: boolean) {
        this.Set('OverdueNotificationsEnabled', value);
    }

    /**
    * * Field Name: OverdueGracePeriodHours
    * * Display Name: Overdue Grace Period Hours
    * * SQL Data Type: int
    * * Default Value: 0
    */
    get OverdueGracePeriodHours(): number {
        return this.Get('OverdueGracePeriodHours');
    }
    set OverdueGracePeriodHours(value: number) {
        this.Set('OverdueGracePeriodHours', value);
    }

    /**
    * * Field Name: OverdueRepeatIntervalHours
    * * Display Name: Overdue Repeat Interval Hours
    * * SQL Data Type: int
    */
    get OverdueRepeatIntervalHours(): number | null {
        return this.Get('OverdueRepeatIntervalHours');
    }
    set OverdueRepeatIntervalHours(value: number | null) {
        this.Set('OverdueRepeatIntervalHours', value);
    }

    /**
    * * Field Name: NotifyAssignees
    * * Display Name: Notify Assignees
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get NotifyAssignees(): boolean {
        return this.Get('NotifyAssignees');
    }
    set NotifyAssignees(value: boolean) {
        this.Set('NotifyAssignees', value);
    }

    /**
    * * Field Name: NotifyCreator
    * * Display Name: Notify Creator
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get NotifyCreator(): boolean {
        return this.Get('NotifyCreator');
    }
    set NotifyCreator(value: boolean) {
        this.Set('NotifyCreator', value);
    }

    /**
    * * Field Name: OverdueActionID
    * * Display Name: Overdue Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    */
    get OverdueActionID(): string | null {
        return this.Get('OverdueActionID');
    }
    set OverdueActionID(value: string | null) {
        this.Set('OverdueActionID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: TaskType
    * * Display Name: Task Type
    * * SQL Data Type: nvarchar(100)
    */
    get TaskType(): string | null {
        return this.Get('TaskType');
    }

    /**
    * * Field Name: OverdueAction
    * * Display Name: Overdue Action
    * * SQL Data Type: nvarchar(425)
    */
    get OverdueAction(): string | null {
        return this.Get('OverdueAction');
    }
}


/**
 * MJ_BizApps_Tasks: Task Notification Logs - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskNotificationLog
 * * Base View: vwTaskNotificationLogs
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Notification Logs')
export class mjBizAppsTasksTaskNotificationLogEntity extends BaseEntity<mjBizAppsTasksTaskNotificationLogEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Notification Logs record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Notification Logs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskNotificationLogEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: NotificationType
    * * Display Name: Notification Type
    * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * Overdue
    *   * OverdueReminder
    */
    get NotificationType(): 'Overdue' | 'OverdueReminder' {
        return this.Get('NotificationType');
    }
    set NotificationType(value: 'Overdue' | 'OverdueReminder') {
        this.Set('NotificationType', value);
    }

    /**
    * * Field Name: NotifiedUserID
    * * Display Name: Notified User ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
    */
    get NotifiedUserID(): string {
        return this.Get('NotifiedUserID');
    }
    set NotifiedUserID(value: string) {
        this.Set('NotifiedUserID', value);
    }

    /**
    * * Field Name: NotifiedAt
    * * Display Name: Notified At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get NotifiedAt(): Date {
        return this.Get('NotifiedAt');
    }
    set NotifiedAt(value: Date) {
        this.Set('NotifiedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: NotifiedUser
    * * Display Name: Notified User
    * * SQL Data Type: nvarchar(100)
    */
    get NotifiedUser(): string {
        return this.Get('NotifiedUser');
    }
}


/**
 * MJ_BizApps_Tasks: Task Roles - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskRole
 * * Base View: vwTaskRoles
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Roles')
export class mjBizAppsTasksTaskRoleEntity extends BaseEntity<mjBizAppsTasksTaskRoleEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Roles record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Roles record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskRoleEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(100)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * MJ_BizApps_Tasks: Task Tag Links - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTagLink
 * * Base View: vwTaskTagLinks
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Tag Links')
export class mjBizAppsTasksTaskTagLinkEntity extends BaseEntity<mjBizAppsTasksTaskTagLinkEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Tag Links record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Tag Links record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTagLinkEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: TagID
    * * Display Name: Tag ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Tags (vwTaskTags.ID)
    */
    get TagID(): string {
        return this.Get('TagID');
    }
    set TagID(value: string) {
        this.Set('TagID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Tag
    * * Display Name: Tag
    * * SQL Data Type: nvarchar(100)
    */
    get Tag(): string {
        return this.Get('Tag');
    }
}


/**
 * MJ_BizApps_Tasks: Task Tags - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTag
 * * Base View: vwTaskTags
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Tags')
export class mjBizAppsTasksTaskTagEntity extends BaseEntity<mjBizAppsTasksTaskTagEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Tags record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Tags record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTagEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(100)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: ColorCode
    * * Display Name: Color Code
    * * SQL Data Type: nvarchar(20)
    */
    get ColorCode(): string | null {
        return this.Get('ColorCode');
    }
    set ColorCode(value: string | null) {
        this.Set('ColorCode', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * MJ_BizApps_Tasks: Task Template Item Dependencies - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTemplateItemDependency
 * * Base View: vwTaskTemplateItemDependencies
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Template Item Dependencies')
export class mjBizAppsTasksTaskTemplateItemDependencyEntity extends BaseEntity<mjBizAppsTasksTaskTemplateItemDependencyEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Template Item Dependencies record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Template Item Dependencies record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTemplateItemDependencyEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Task Template Item Dependencies entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: An item cannot depend on itself, preventing circular self-dependencies.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateItemIDNotEqualToDependsOnItemID(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * An item cannot depend on itself, preventing circular self-dependencies.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateItemIDNotEqualToDependsOnItemID(result: ValidationResult) {
    	if (this.ItemID != null && this.DependsOnItemID != null && UUIDsEqual(this.ItemID, this.DependsOnItemID)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"DependsOnItemID",
    			"An item cannot depend on itself. ItemID and DependsOnItemID must be different.",
    			this.DependsOnItemID,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ItemID
    * * Display Name: Item ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)
    */
    get ItemID(): string {
        return this.Get('ItemID');
    }
    set ItemID(value: string) {
        this.Set('ItemID', value);
    }

    /**
    * * Field Name: DependsOnItemID
    * * Display Name: Depends On Item ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)
    */
    get DependsOnItemID(): string {
        return this.Get('DependsOnItemID');
    }
    set DependsOnItemID(value: string) {
        this.Set('DependsOnItemID', value);
    }

    /**
    * * Field Name: DependencyType
    * * Display Name: Dependency Type
    * * SQL Data Type: nvarchar(50)
    * * Default Value: FinishToStart
    * * Value List Type: List
    * * Possible Values 
    *   * FinishToFinish
    *   * FinishToStart
    *   * StartToFinish
    *   * StartToStart
    */
    get DependencyType(): 'FinishToFinish' | 'FinishToStart' | 'StartToFinish' | 'StartToStart' {
        return this.Get('DependencyType');
    }
    set DependencyType(value: 'FinishToFinish' | 'FinishToStart' | 'StartToFinish' | 'StartToStart') {
        this.Set('DependencyType', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Item
    * * Display Name: Item
    * * SQL Data Type: nvarchar(255)
    */
    get Item(): string {
        return this.Get('Item');
    }

    /**
    * * Field Name: DependsOnItem
    * * Display Name: Depends On Item
    * * SQL Data Type: nvarchar(255)
    */
    get DependsOnItem(): string {
        return this.Get('DependsOnItem');
    }
}


/**
 * MJ_BizApps_Tasks: Task Template Item Roles - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTemplateItemRole
 * * Base View: vwTaskTemplateItemRoles
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Template Item Roles')
export class mjBizAppsTasksTaskTemplateItemRoleEntity extends BaseEntity<mjBizAppsTasksTaskTemplateItemRoleEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Template Item Roles record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Template Item Roles record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTemplateItemRoleEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ItemID
    * * Display Name: Item ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)
    */
    get ItemID(): string {
        return this.Get('ItemID');
    }
    set ItemID(value: string) {
        this.Set('ItemID', value);
    }

    /**
    * * Field Name: RoleID
    * * Display Name: Role ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Roles (vwTaskRoles.ID)
    */
    get RoleID(): string {
        return this.Get('RoleID');
    }
    set RoleID(value: string) {
        this.Set('RoleID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Item
    * * Display Name: Item
    * * SQL Data Type: nvarchar(255)
    */
    get Item(): string {
        return this.Get('Item');
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(100)
    */
    get Role(): string {
        return this.Get('Role');
    }
}


/**
 * MJ_BizApps_Tasks: Task Template Items - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTemplateItem
 * * Base View: vwTaskTemplateItems
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Template Items')
export class mjBizAppsTasksTaskTemplateItemEntity extends BaseEntity<mjBizAppsTasksTaskTemplateItemEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Template Items record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Template Items record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTemplateItemEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TemplateID
    * * Display Name: Template ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Templates (vwTaskTemplates.ID)
    */
    get TemplateID(): string {
        return this.Get('TemplateID');
    }
    set TemplateID(value: string) {
        this.Set('TemplateID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(255)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: ParentItemID
    * * Display Name: Parent Item ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Template Items (vwTaskTemplateItems.ID)
    */
    get ParentItemID(): string | null {
        return this.Get('ParentItemID');
    }
    set ParentItemID(value: string | null) {
        this.Set('ParentItemID', value);
    }

    /**
    * * Field Name: Priority
    * * Display Name: Priority
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium
    */
    get Priority(): 'Critical' | 'High' | 'Low' | 'Medium' {
        return this.Get('Priority');
    }
    set Priority(value: 'Critical' | 'High' | 'Low' | 'Medium') {
        this.Set('Priority', value);
    }

    /**
    * * Field Name: DaysFromStart
    * * Display Name: Days From Start
    * * SQL Data Type: int
    */
    get DaysFromStart(): number | null {
        return this.Get('DaysFromStart');
    }
    set DaysFromStart(value: number | null) {
        this.Set('DaysFromStart', value);
    }

    /**
    * * Field Name: HoursEstimated
    * * Display Name: Hours Estimated
    * * SQL Data Type: decimal(8, 2)
    */
    get HoursEstimated(): number | null {
        return this.Get('HoursEstimated');
    }
    set HoursEstimated(value: number | null) {
        this.Set('HoursEstimated', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Template
    * * Display Name: Template
    * * SQL Data Type: nvarchar(255)
    */
    get Template(): string {
        return this.Get('Template');
    }

    /**
    * * Field Name: ParentItem
    * * Display Name: Parent Item
    * * SQL Data Type: nvarchar(255)
    */
    get ParentItem(): string | null {
        return this.Get('ParentItem');
    }

    /**
    * * Field Name: RootParentItemID
    * * Display Name: Root Parent Item ID
    * * SQL Data Type: uniqueidentifier
    */
    get RootParentItemID(): string | null {
        return this.Get('RootParentItemID');
    }

    /**
    * * Field Name: ParentItemIDDepth
    * * Display Name: Parent Item ID Depth
    * * SQL Data Type: int
    */
    get ParentItemIDDepth(): number | null {
        return this.Get('ParentItemIDDepth');
    }

    /**
    * * Field Name: ParentItemIDPath
    * * Display Name: Parent Item ID Path
    * * SQL Data Type: nvarchar(MAX)
    */
    get ParentItemIDPath(): string | null {
        return this.Get('ParentItemIDPath');
    }

    /**
    * * Field Name: ParentItemIDIsLeaf
    * * Display Name: Parent Item ID Is Leaf
    * * SQL Data Type: bit
    */
    get ParentItemIDIsLeaf(): boolean | null {
        return this.Get('ParentItemIDIsLeaf');
    }

    /**
    * * Field Name: ParentItemIDChildCount
    * * Display Name: Parent Item ID Child Count
    * * SQL Data Type: int
    */
    get ParentItemIDChildCount(): number | null {
        return this.Get('ParentItemIDChildCount');
    }
}


/**
 * MJ_BizApps_Tasks: Task Templates - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTemplate
 * * Base View: vwTaskTemplates
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Templates')
export class mjBizAppsTasksTaskTemplateEntity extends BaseEntity<mjBizAppsTasksTaskTemplateEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Templates record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Templates record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTemplateEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(255)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: CategoryID
    * * Display Name: Category ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)
    */
    get CategoryID(): string | null {
        return this.Get('CategoryID');
    }
    set CategoryID(value: string | null) {
        this.Set('CategoryID', value);
    }

    /**
    * * Field Name: TypeID
    * * Display Name: Type ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)
    */
    get TypeID(): string | null {
        return this.Get('TypeID');
    }
    set TypeID(value: string | null) {
        this.Set('TypeID', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Category
    * * Display Name: Category
    * * SQL Data Type: nvarchar(255)
    */
    get Category(): string | null {
        return this.Get('Category');
    }

    /**
    * * Field Name: Type
    * * Display Name: Type
    * * SQL Data Type: nvarchar(100)
    */
    get Type(): string | null {
        return this.Get('Type');
    }
}


/**
 * MJ_BizApps_Tasks: Task Time Entries - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTimeEntry
 * * Base View: vwTaskTimeEntries
 * * @description Individual time entries logged by a person against a task on a specific business calendar date.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entries')
export class mjBizAppsTasksTaskTimeEntryEntity extends BaseEntity<mjBizAppsTasksTaskTimeEntryEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Time Entries record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Time Entries record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTimeEntryEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Task Time Entries entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Minutes: Minutes worked must be greater than 0 and cannot exceed 1,440 minutes (24 hours) in a single entry.
    * * Table-Level: If both start and end times are recorded, the end time must be at or after the start time.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateMinutesRange(result);
        this.ValidateEndedAtOnOrAfterStartedAt(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Minutes worked must be greater than 0 and cannot exceed 1,440 minutes (24 hours) in a single entry.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateMinutesRange(result: ValidationResult) {
    	if (this.Minutes != null && (this.Minutes <= 0 || this.Minutes > 1440)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"Minutes",
    			"Minutes worked must be greater than 0 and cannot exceed 1440 (24 hours).",
    			this.Minutes,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * If both start and end times are recorded, the end time must be at or after the start time.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateEndedAtOnOrAfterStartedAt(result: ValidationResult) {
    	if (this.StartedAt != null && this.EndedAt != null && new Date(this.EndedAt).getTime() < new Date(this.StartedAt).getTime()) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EndedAt",
    			"End time must be on or after the start time.",
    			this.EndedAt,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the task time entry.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The task this time entry is logged against.
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person who performed the work.
    */
    get PersonID(): string {
        return this.Get('PersonID');
    }
    set PersonID(value: string) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: WorkDate
    * * Display Name: Work Date
    * * SQL Data Type: date
    * * Description: Business calendar date the work was performed on.
    */
    get WorkDate(): Date {
        return this.Get('WorkDate');
    }
    set WorkDate(value: Date) {
        this.Set('WorkDate', value);
    }

    /**
    * * Field Name: Minutes
    * * Display Name: Minutes
    * * SQL Data Type: int
    * * Description: Duration of work in whole minutes (1 to 1440).
    */
    get Minutes(): number {
        return this.Get('Minutes');
    }
    set Minutes(value: number) {
        this.Set('Minutes', value);
    }

    /**
    * * Field Name: StartedAt
    * * Display Name: Started At
    * * SQL Data Type: datetimeoffset
    * * Description: Optional timestamp when the work interval started (populated for timer-backed entries).
    */
    get StartedAt(): Date | null {
        return this.Get('StartedAt');
    }
    set StartedAt(value: Date | null) {
        this.Set('StartedAt', value);
    }

    /**
    * * Field Name: EndedAt
    * * Display Name: Ended At
    * * SQL Data Type: datetimeoffset
    * * Description: Optional timestamp when the work interval ended (populated for timer-backed entries).
    */
    get EndedAt(): Date | null {
        return this.Get('EndedAt');
    }
    set EndedAt(value: Date | null) {
        this.Set('EndedAt', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Narrative description of what was accomplished during this time entry.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: Source
    * * Display Name: Source
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Manual
    * * Value List Type: List
    * * Possible Values 
    *   * Agent
    *   * Imported
    *   * Manual
    *   * Timer
    * * Description: How the time entry was created: Manual, Timer, Imported, or Agent.
    */
    get Source(): 'Agent' | 'Imported' | 'Manual' | 'Timer' {
        return this.Get('Source');
    }
    set Source(value: 'Agent' | 'Imported' | 'Manual' | 'Timer') {
        this.Set('Source', value);
    }

    /**
    * * Field Name: IsBillable
    * * Display Name: Is Billable
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Whether this time entry is billable to a client or external party.
    */
    get IsBillable(): boolean {
        return this.Get('IsBillable');
    }
    set IsBillable(value: boolean) {
        this.Set('IsBillable', value);
    }

    /**
    * * Field Name: TimesheetID
    * * Display Name: Timesheet ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
    * * Description: Optional Timesheet this time entry has been attached to.
    */
    get TimesheetID(): string | null {
        return this.Get('TimesheetID');
    }
    set TimesheetID(value: string | null) {
        this.Set('TimesheetID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string {
        return this.Get('Person');
    }
}


/**
 * MJ_BizApps_Tasks: Task Time Entry Links - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTimeEntryLink
 * * Base View: vwTaskTimeEntryLinks
 * * @description Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entry Links')
export class mjBizAppsTasksTaskTimeEntryLinkEntity extends BaseEntity<mjBizAppsTasksTaskTimeEntryLinkEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Time Entry Links record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Time Entry Links record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTimeEntryLinkEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the task time entry link.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskTimeEntryID
    * * Display Name: Task Time Entry ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Time Entries (vwTaskTimeEntries.ID)
    * * Description: The TaskTimeEntry being linked.
    */
    get TaskTimeEntryID(): string {
        return this.Get('TaskTimeEntryID');
    }
    set TaskTimeEntryID(value: string) {
        this.Set('TaskTimeEntryID', value);
    }

    /**
    * * Field Name: EntityID
    * * Display Name: Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    * * Description: Target MemberJunction Entity ID for the linked external record.
    */
    get EntityID(): string {
        return this.Get('EntityID');
    }
    set EntityID(value: string) {
        this.Set('EntityID', value);
    }

    /**
    * * Field Name: RecordID
    * * Display Name: Record ID
    * * SQL Data Type: nvarchar(450)
    * * Description: Primary key value of the linked record in EntityID.
    */
    get RecordID(): string {
        return this.Get('RecordID');
    }
    set RecordID(value: string) {
        this.Set('RecordID', value);
    }

    /**
    * * Field Name: Relationship
    * * Display Name: Relationship
    * * SQL Data Type: nvarchar(30)
    * * Default Value: Related
    * * Value List Type: List
    * * Possible Values 
    *   * Commit
    *   * InvoiceLine
    *   * JournalEntryLine
    *   * PullRequest
    *   * Related
    * * Description: Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.
    */
    get Relationship(): 'Commit' | 'InvoiceLine' | 'JournalEntryLine' | 'PullRequest' | 'Related' {
        return this.Get('Relationship');
    }
    set Relationship(value: 'Commit' | 'InvoiceLine' | 'JournalEntryLine' | 'PullRequest' | 'Related') {
        this.Set('Relationship', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Entity
    * * Display Name: Entity
    * * SQL Data Type: nvarchar(255)
    */
    get Entity(): string {
        return this.Get('Entity');
    }
}


/**
 * MJ_BizApps_Tasks: Task Timers - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTimer
 * * Base View: vwTaskTimers
 * * @description Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Timers')
export class mjBizAppsTasksTaskTimerEntity extends BaseEntity<mjBizAppsTasksTaskTimerEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Timers record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Timers record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTimerEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the running timer.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskID
    * * Display Name: Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The task currently being timed.
    */
    get TaskID(): string {
        return this.Get('TaskID');
    }
    set TaskID(value: string) {
        this.Set('TaskID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person whose stopwatch is running (unique across TaskTimer).
    */
    get PersonID(): string {
        return this.Get('PersonID');
    }
    set PersonID(value: string) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: StartedAt
    * * Display Name: Started At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: Timestamp when the timer was started.
    */
    get StartedAt(): Date {
        return this.Get('StartedAt');
    }
    set StartedAt(value: Date) {
        this.Set('StartedAt', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: IsBillable
    * * Display Name: Is Billable
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.
    */
    get IsBillable(): boolean {
        return this.Get('IsBillable');
    }
    set IsBillable(value: boolean) {
        this.Set('IsBillable', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Task
    * * Display Name: Task
    * * SQL Data Type: nvarchar(255)
    */
    get Task(): string {
        return this.Get('Task');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string {
        return this.Get('Person');
    }
}


/**
 * MJ_BizApps_Tasks: Task Type Status - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskTypeStatus
 * * Base View: vwTaskTypeStatus
 * * @description Dynamic domain statuses and lifecycle stages configured per Task Type.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Type Status')
export class mjBizAppsTasksTaskTypeStatusEntity extends BaseEntity<mjBizAppsTasksTaskTypeStatusEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Type Status record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Type Status record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTypeStatusEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TaskTypeID
    * * Display Name: Task Type ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)
    * * Description: The Task Type this status belongs to.
    */
    get TaskTypeID(): string {
        return this.Get('TaskTypeID');
    }
    set TaskTypeID(value: string) {
        this.Set('TaskTypeID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(100)
    * * Description: Display name of the status (e.g. Legal Review, Redlining, Pending Signature).
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Code
    * * Display Name: Code
    * * SQL Data Type: nvarchar(50)
    * * Description: Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).
    */
    get Code(): string {
        return this.Get('Code');
    }
    set Code(value: string) {
        this.Set('Code', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: MacroStatus
    * * Display Name: Macro Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cancelled
    *   * Completed
    *   * InProgress
    *   * Open
    * * Description: The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.
    */
    get MacroStatus(): 'Blocked' | 'Cancelled' | 'Completed' | 'InProgress' | 'Open' {
        return this.Get('MacroStatus');
    }
    set MacroStatus(value: 'Blocked' | 'Cancelled' | 'Completed' | 'InProgress' | 'Open') {
        this.Set('MacroStatus', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    * * Description: Ordering sequence for pickers, stage progression bars, and Kanban columns.
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: IsDefault
    * * Display Name: Is Default
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Whether this is the initial default status when a task of this type is created.
    */
    get IsDefault(): boolean {
        return this.Get('IsDefault');
    }
    set IsDefault(value: boolean) {
        this.Set('IsDefault', value);
    }

    /**
    * * Field Name: IsTerminal
    * * Display Name: Is Terminal
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Whether this status represents a closed terminal state for the task.
    */
    get IsTerminal(): boolean {
        return this.Get('IsTerminal');
    }
    set IsTerminal(value: boolean) {
        this.Set('IsTerminal', value);
    }

    /**
    * * Field Name: Color
    * * Display Name: Color
    * * SQL Data Type: nvarchar(50)
    */
    get Color(): string | null {
        return this.Get('Color');
    }
    set Color(value: string | null) {
        this.Set('Color', value);
    }

    /**
    * * Field Name: IconClass
    * * Display Name: Icon Class
    * * SQL Data Type: nvarchar(100)
    */
    get IconClass(): string | null {
        return this.Get('IconClass');
    }
    set IconClass(value: string | null) {
        this.Set('IconClass', value);
    }

    /**
    * * Field Name: OnEnterActionID
    * * Display Name: On Enter Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked when a task enters this specific status.
    */
    get OnEnterActionID(): string | null {
        return this.Get('OnEnterActionID');
    }
    set OnEnterActionID(value: string | null) {
        this.Set('OnEnterActionID', value);
    }

    /**
    * * Field Name: OnExitActionID
    * * Display Name: On Exit Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked when a task leaves this specific status.
    */
    get OnExitActionID(): string | null {
        return this.Get('OnExitActionID');
    }
    set OnExitActionID(value: string | null) {
        this.Set('OnExitActionID', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: TaskType
    * * Display Name: Task Type
    * * SQL Data Type: nvarchar(100)
    */
    get TaskType(): string {
        return this.Get('TaskType');
    }

    /**
    * * Field Name: OnEnterAction
    * * Display Name: On Enter Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnEnterAction(): string | null {
        return this.Get('OnEnterAction');
    }

    /**
    * * Field Name: OnExitAction
    * * Display Name: On Exit Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnExitAction(): string | null {
        return this.Get('OnExitAction');
    }
}


/**
 * MJ_BizApps_Tasks: Task Types - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TaskType
 * * Base View: vwTaskTypes
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Types')
export class mjBizAppsTasksTaskTypeEntity extends BaseEntity<mjBizAppsTasksTaskTypeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Task Types record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Task Types record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskTypeEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(100)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: IconClass
    * * Display Name: Icon Class
    * * SQL Data Type: nvarchar(100)
    */
    get IconClass(): string | null {
        return this.Get('IconClass');
    }
    set IconClass(value: string | null) {
        this.Set('IconClass', value);
    }

    /**
    * * Field Name: DefaultPriority
    * * Display Name: Default Priority
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium
    */
    get DefaultPriority(): 'Critical' | 'High' | 'Low' | 'Medium' {
        return this.Get('DefaultPriority');
    }
    set DefaultPriority(value: 'Critical' | 'High' | 'Low' | 'Medium') {
        this.Set('DefaultPriority', value);
    }

    /**
    * * Field Name: OnAssignActionID
    * * Display Name: On Assign Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    */
    get OnAssignActionID(): string | null {
        return this.Get('OnAssignActionID');
    }
    set OnAssignActionID(value: string | null) {
        this.Set('OnAssignActionID', value);
    }

    /**
    * * Field Name: OnCompleteActionID
    * * Display Name: On Complete Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    */
    get OnCompleteActionID(): string | null {
        return this.Get('OnCompleteActionID');
    }
    set OnCompleteActionID(value: string | null) {
        this.Set('OnCompleteActionID', value);
    }

    /**
    * * Field Name: OnOverdueActionID
    * * Display Name: On Overdue Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    */
    get OnOverdueActionID(): string | null {
        return this.Get('OnOverdueActionID');
    }
    set OnOverdueActionID(value: string | null) {
        this.Set('OnOverdueActionID', value);
    }

    /**
    * * Field Name: OnPercentChangeActionID
    * * Display Name: On Percent Change Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    */
    get OnPercentChangeActionID(): string | null {
        return this.Get('OnPercentChangeActionID');
    }
    set OnPercentChangeActionID(value: string | null) {
        this.Set('OnPercentChangeActionID', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: OnRejectActionID
    * * Display Name: On Reject Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows.
    */
    get OnRejectActionID(): string | null {
        return this.Get('OnRejectActionID');
    }
    set OnRejectActionID(value: string | null) {
        this.Set('OnRejectActionID', value);
    }

    /**
    * * Field Name: OnCancelActionID
    * * Display Name: On Cancel Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking).
    */
    get OnCancelActionID(): string | null {
        return this.Get('OnCancelActionID');
    }
    set OnCancelActionID(value: string | null) {
        this.Set('OnCancelActionID', value);
    }

    /**
    * * Field Name: Code
    * * Display Name: Code
    * * SQL Data Type: nvarchar(50)
    * * Description: Stable unique machine code for programmatic lookups and cross-app metadata references.
    */
    get Code(): string {
        return this.Get('Code');
    }
    set Code(value: string) {
        this.Set('Code', value);
    }

    /**
    * * Field Name: OnCreateActionID
    * * Display Name: On Create Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).
    */
    get OnCreateActionID(): string | null {
        return this.Get('OnCreateActionID');
    }
    set OnCreateActionID(value: string | null) {
        this.Set('OnCreateActionID', value);
    }

    /**
    * * Field Name: OnStatusChangeActionID
    * * Display Name: On Status Change Action ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Actions (vwActions.ID)
    * * Description: Action invoked whenever a task of this type changes status.
    */
    get OnStatusChangeActionID(): string | null {
        return this.Get('OnStatusChangeActionID');
    }
    set OnStatusChangeActionID(value: string | null) {
        this.Set('OnStatusChangeActionID', value);
    }

    /**
    * * Field Name: IsApproval
    * * Display Name: Is Approval
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: When true, tasks of this type are approvals: they appear in the approvals inbox of each assignee, who records a decision on them.
    */
    get IsApproval(): boolean {
        return this.Get('IsApproval');
    }
    set IsApproval(value: boolean) {
        this.Set('IsApproval', value);
    }

    /**
    * * Field Name: RequiresAssigneeDecision
    * * Display Name: Requires Assignee Decision
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.
    */
    get RequiresAssigneeDecision(): boolean {
        return this.Get('RequiresAssigneeDecision');
    }
    set RequiresAssigneeDecision(value: boolean) {
        this.Set('RequiresAssigneeDecision', value);
    }

    /**
    * * Field Name: OnAssignAction
    * * Display Name: On Assign Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnAssignAction(): string | null {
        return this.Get('OnAssignAction');
    }

    /**
    * * Field Name: OnCompleteAction
    * * Display Name: On Complete Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnCompleteAction(): string | null {
        return this.Get('OnCompleteAction');
    }

    /**
    * * Field Name: OnOverdueAction
    * * Display Name: On Overdue Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnOverdueAction(): string | null {
        return this.Get('OnOverdueAction');
    }

    /**
    * * Field Name: OnPercentChangeAction
    * * Display Name: On Percent Change Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnPercentChangeAction(): string | null {
        return this.Get('OnPercentChangeAction');
    }

    /**
    * * Field Name: OnRejectAction
    * * Display Name: On Reject Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnRejectAction(): string | null {
        return this.Get('OnRejectAction');
    }

    /**
    * * Field Name: OnCancelAction
    * * Display Name: On Cancel Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnCancelAction(): string | null {
        return this.Get('OnCancelAction');
    }

    /**
    * * Field Name: OnCreateAction
    * * Display Name: On Create Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnCreateAction(): string | null {
        return this.Get('OnCreateAction');
    }

    /**
    * * Field Name: OnStatusChangeAction
    * * Display Name: On Status Change Action
    * * SQL Data Type: nvarchar(425)
    */
    get OnStatusChangeAction(): string | null {
        return this.Get('OnStatusChangeAction');
    }
}


/**
 * MJ_BizApps_Tasks: Tasks - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: Task
 * * Base View: vwTasks
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')
export class mjBizAppsTasksTaskEntity extends BaseEntity<mjBizAppsTasksTaskEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Tasks record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Tasks record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTaskEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Tasks entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * ConfidenceScore: Confidence score must be between 0 and 100 if specified.
    * * PercentComplete: Percent complete must be a valid percentage between 0 and 100
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateConfidenceScoreRange(result);
        this.ValidatePercentCompleteRange(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Confidence score must be between 0 and 100 if specified.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateConfidenceScoreRange(result: ValidationResult) {
    	if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"ConfidenceScore",
    			"Confidence score must be between 0 and 100.",
    			this.ConfidenceScore,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * Percent complete must be a valid percentage between 0 and 100
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidatePercentCompleteRange(result: ValidationResult) {
    	if (this.PercentComplete < 0 || this.PercentComplete > 100) {
    		result.Errors.push(new ValidationErrorInfo(
    			"PercentComplete",
    			"Percent complete must be between 0 and 100.",
    			this.PercentComplete,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(255)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    */
    get Description(): string | null {
        return this.Get('Description');
    }
    set Description(value: string | null) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: TypeID
    * * Display Name: Type ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Types (vwTaskTypes.ID)
    */
    get TypeID(): string {
        return this.Get('TypeID');
    }
    set TypeID(value: string) {
        this.Set('TypeID', value);
    }

    /**
    * * Field Name: CategoryID
    * * Display Name: Category ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Categories (vwTaskCategories.ID)
    */
    get CategoryID(): string | null {
        return this.Get('CategoryID');
    }
    set CategoryID(value: string | null) {
        this.Set('CategoryID', value);
    }

    /**
    * * Field Name: ParentID
    * * Display Name: Parent ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    */
    get ParentID(): string | null {
        return this.Get('ParentID');
    }
    set ParentID(value: string | null) {
        this.Set('ParentID', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(50)
    * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cancelled
    *   * Completed
    *   * InProgress
    *   * Open
    */
    get Status(): 'Blocked' | 'Cancelled' | 'Completed' | 'InProgress' | 'Open' {
        return this.Get('Status');
    }
    set Status(value: 'Blocked' | 'Cancelled' | 'Completed' | 'InProgress' | 'Open') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: Priority
    * * Display Name: Priority
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium
    */
    get Priority(): 'Critical' | 'High' | 'Low' | 'Medium' {
        return this.Get('Priority');
    }
    set Priority(value: 'Critical' | 'High' | 'Low' | 'Medium') {
        this.Set('Priority', value);
    }

    /**
    * * Field Name: StartedAt
    * * Display Name: Started At
    * * SQL Data Type: datetimeoffset
    */
    get StartedAt(): Date | null {
        return this.Get('StartedAt');
    }
    set StartedAt(value: Date | null) {
        this.Set('StartedAt', value);
    }

    /**
    * * Field Name: DueAt
    * * Display Name: Due Date
    * * SQL Data Type: datetimeoffset
    */
    get DueAt(): Date | null {
        return this.Get('DueAt');
    }
    set DueAt(value: Date | null) {
        this.Set('DueAt', value);
    }

    /**
    * * Field Name: CompletedAt
    * * Display Name: Completed At
    * * SQL Data Type: datetimeoffset
    */
    get CompletedAt(): Date | null {
        return this.Get('CompletedAt');
    }
    set CompletedAt(value: Date | null) {
        this.Set('CompletedAt', value);
    }

    /**
    * * Field Name: HoursEstimated
    * * Display Name: Hours Estimated
    * * SQL Data Type: decimal(8, 2)
    */
    get HoursEstimated(): number | null {
        return this.Get('HoursEstimated');
    }
    set HoursEstimated(value: number | null) {
        this.Set('HoursEstimated', value);
    }

    /**
    * * Field Name: HoursActual
    * * Display Name: Hours Actual
    * * SQL Data Type: decimal(8, 2)
    */
    get HoursActual(): number | null {
        return this.Get('HoursActual');
    }
    set HoursActual(value: number | null) {
        this.Set('HoursActual', value);
    }

    /**
    * * Field Name: PercentComplete
    * * Display Name: Percent Complete
    * * SQL Data Type: int
    * * Default Value: 0
    */
    get PercentComplete(): number {
        return this.Get('PercentComplete');
    }
    set PercentComplete(value: number) {
        this.Set('PercentComplete', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: BlockedReason
    * * Display Name: Blocked Reason
    * * SQL Data Type: nvarchar(MAX)
    */
    get BlockedReason(): string | null {
        return this.Get('BlockedReason');
    }
    set BlockedReason(value: string | null) {
        this.Set('BlockedReason', value);
    }

    /**
    * * Field Name: CompletionNotes
    * * Display Name: Completion Notes
    * * SQL Data Type: nvarchar(MAX)
    */
    get CompletionNotes(): string | null {
        return this.Get('CompletionNotes');
    }
    set CompletionNotes(value: string | null) {
        this.Set('CompletionNotes', value);
    }

    /**
    * * Field Name: CreatedByPersonID
    * * Display Name: Created By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    */
    get CreatedByPersonID(): string | null {
        return this.Get('CreatedByPersonID');
    }
    set CreatedByPersonID(value: string | null) {
        this.Set('CreatedByPersonID', value);
    }

    /**
    * * Field Name: OverdueNotifiedAt
    * * Display Name: Overdue Notified At
    * * SQL Data Type: datetimeoffset
    */
    get OverdueNotifiedAt(): Date | null {
        return this.Get('OverdueNotifiedAt');
    }
    set OverdueNotifiedAt(value: Date | null) {
        this.Set('OverdueNotifiedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: TaskTypeStatusID
    * * Display Name: Task Type Status
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Task Type Status (vwTaskTypeStatus.ID)
    * * Description: Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.
    */
    get TaskTypeStatusID(): string | null {
        return this.Get('TaskTypeStatusID');
    }
    set TaskTypeStatusID(value: string | null) {
        this.Set('TaskTypeStatusID', value);
    }

    /**
    * * Field Name: PredictedSLABreachProbability
    * * Display Name: SLA Breach Probability
    * * SQL Data Type: decimal(5, 4)
    * * Description: Predicted probability (0.0000 - 1.0000) that this task breaches its target due date or SLA.
    */
    get PredictedSLABreachProbability(): number | null {
        return this.Get('PredictedSLABreachProbability');
    }
    set PredictedSLABreachProbability(value: number | null) {
        this.Set('PredictedSLABreachProbability', value);
    }

    /**
    * * Field Name: PredictedSLARiskBand
    * * Display Name: SLA Risk Band
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Critical
    *   * High
    *   * Low
    *   * Medium
    * * Description: Operational SLA breach risk tier: Low (<0.30), Medium (0.30-0.70), High (>0.70), or Critical.
    */
    get PredictedSLARiskBand(): 'Critical' | 'High' | 'Low' | 'Medium' | null {
        return this.Get('PredictedSLARiskBand');
    }
    set PredictedSLARiskBand(value: 'Critical' | 'High' | 'Low' | 'Medium' | null) {
        this.Set('PredictedSLARiskBand', value);
    }

    /**
    * * Field Name: PredictedSLAScoredAt
    * * Display Name: SLA Scored At
    * * SQL Data Type: datetimeoffset
    * * Description: Timestamp when this task was last scored by the predictive SLA breach model.
    */
    get PredictedSLAScoredAt(): Date | null {
        return this.Get('PredictedSLAScoredAt');
    }
    set PredictedSLAScoredAt(value: Date | null) {
        this.Set('PredictedSLAScoredAt', value);
    }

    /**
    * * Field Name: HealthStatus
    * * Display Name: Health Status
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * AtRisk
    *   * Completed
    *   * OffTrack
    *   * OnTrack
    *   * Paused
    * * Description: Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.
    */
    get HealthStatus(): 'AtRisk' | 'Completed' | 'OffTrack' | 'OnTrack' | 'Paused' | null {
        return this.Get('HealthStatus');
    }
    set HealthStatus(value: 'AtRisk' | 'Completed' | 'OffTrack' | 'OnTrack' | 'Paused' | null) {
        this.Set('HealthStatus', value);
    }

    /**
    * * Field Name: ConfidenceScore
    * * Display Name: Confidence Score
    * * SQL Data Type: int
    * * Description: Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.
    */
    get ConfidenceScore(): number | null {
        return this.Get('ConfidenceScore');
    }
    set ConfidenceScore(value: number | null) {
        this.Set('ConfidenceScore', value);
    }

    /**
    * * Field Name: BaselineValue
    * * Display Name: Baseline Value
    * * SQL Data Type: decimal(18, 4)
    * * Description: Starting baseline value for measurable key results or quantitative deliverables.
    */
    get BaselineValue(): number | null {
        return this.Get('BaselineValue');
    }
    set BaselineValue(value: number | null) {
        this.Set('BaselineValue', value);
    }

    /**
    * * Field Name: TargetValue
    * * Display Name: Target Value
    * * SQL Data Type: decimal(18, 4)
    * * Description: Target goal value for measurable key results or quantitative deliverables.
    */
    get TargetValue(): number | null {
        return this.Get('TargetValue');
    }
    set TargetValue(value: number | null) {
        this.Set('TargetValue', value);
    }

    /**
    * * Field Name: CurrentValue
    * * Display Name: Current Value
    * * SQL Data Type: decimal(18, 4)
    * * Description: Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.
    */
    get CurrentValue(): number | null {
        return this.Get('CurrentValue');
    }
    set CurrentValue(value: number | null) {
        this.Set('CurrentValue', value);
    }

    /**
    * * Field Name: UnitOfMeasure
    * * Display Name: Unit of Measure
    * * SQL Data Type: nvarchar(50)
    * * Description: Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).
    */
    get UnitOfMeasure(): string | null {
        return this.Get('UnitOfMeasure');
    }
    set UnitOfMeasure(value: string | null) {
        this.Set('UnitOfMeasure', value);
    }

    /**
    * * Field Name: MetricDirection
    * * Display Name: Metric Direction
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Decrease
    *   * Increase
    *   * Maintain
    * * Description: Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.
    */
    get MetricDirection(): 'Decrease' | 'Increase' | 'Maintain' | null {
        return this.Get('MetricDirection');
    }
    set MetricDirection(value: 'Decrease' | 'Increase' | 'Maintain' | null) {
        this.Set('MetricDirection', value);
    }

    /**
    * * Field Name: RollupWeight
    * * Display Name: Rollup Weight
    * * SQL Data Type: decimal(8, 2)
    * * Default Value: 1.00
    * * Description: Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.
    */
    get RollupWeight(): number {
        return this.Get('RollupWeight');
    }
    set RollupWeight(value: number) {
        this.Set('RollupWeight', value);
    }

    /**
    * * Field Name: PlanningPeriod
    * * Display Name: Planning Period
    * * SQL Data Type: nvarchar(50)
    * * Description: Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).
    */
    get PlanningPeriod(): string | null {
        return this.Get('PlanningPeriod');
    }
    set PlanningPeriod(value: string | null) {
        this.Set('PlanningPeriod', value);
    }

    /**
    * * Field Name: CheckInCadence
    * * Display Name: Check-In Cadence
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * BiWeekly
    *   * Daily
    *   * Monthly
    *   * None
    *   * Quarterly
    *   * Weekly
    * * Description: Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.
    */
    get CheckInCadence(): 'BiWeekly' | 'Daily' | 'Monthly' | 'None' | 'Quarterly' | 'Weekly' | null {
        return this.Get('CheckInCadence');
    }
    set CheckInCadence(value: 'BiWeekly' | 'Daily' | 'Monthly' | 'None' | 'Quarterly' | 'Weekly' | null) {
        this.Set('CheckInCadence', value);
    }

    /**
    * * Field Name: LastCheckInAt
    * * Display Name: Last Check-In At
    * * SQL Data Type: datetimeoffset
    * * Description: Timestamp when the most recent TaskCheckIn was recorded for this task.
    */
    get LastCheckInAt(): Date | null {
        return this.Get('LastCheckInAt');
    }
    set LastCheckInAt(value: Date | null) {
        this.Set('LastCheckInAt', value);
    }

    /**
    * * Field Name: NextCheckInDueAt
    * * Display Name: Next Check-In Due At
    * * SQL Data Type: datetimeoffset
    * * Description: Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.
    */
    get NextCheckInDueAt(): Date | null {
        return this.Get('NextCheckInDueAt');
    }
    set NextCheckInDueAt(value: Date | null) {
        this.Set('NextCheckInDueAt', value);
    }

    /**
    * * Field Name: Type
    * * Display Name: Type
    * * SQL Data Type: nvarchar(100)
    */
    get Type(): string {
        return this.Get('Type');
    }

    /**
    * * Field Name: Category
    * * Display Name: Category
    * * SQL Data Type: nvarchar(255)
    */
    get Category(): string | null {
        return this.Get('Category');
    }

    /**
    * * Field Name: Parent
    * * Display Name: Parent
    * * SQL Data Type: nvarchar(255)
    */
    get Parent(): string | null {
        return this.Get('Parent');
    }

    /**
    * * Field Name: CreatedByPerson
    * * Display Name: Created By Person
    * * SQL Data Type: nvarchar(250)
    */
    get CreatedByPerson(): string | null {
        return this.Get('CreatedByPerson');
    }

    /**
    * * Field Name: TaskTypeStatus
    * * Display Name: Task Type Status Name
    * * SQL Data Type: nvarchar(100)
    */
    get TaskTypeStatus(): string | null {
        return this.Get('TaskTypeStatus');
    }

    /**
    * * Field Name: RootParentID
    * * Display Name: Root Parent ID
    * * SQL Data Type: uniqueidentifier
    */
    get RootParentID(): string | null {
        return this.Get('RootParentID');
    }

    /**
    * * Field Name: IsSLABreached
    * * Display Name: Is SLA Breached
    * * SQL Data Type: varchar(8)
    */
    get IsSLABreached(): string | null {
        return this.Get('IsSLABreached');
    }

    /**
    * * Field Name: LeadDays
    * * Display Name: Lead Days
    * * SQL Data Type: int
    */
    get LeadDays(): number | null {
        return this.Get('LeadDays');
    }

    /**
    * * Field Name: AssignmentsCount
    * * Display Name: Assignments Count
    * * SQL Data Type: int
    */
    get AssignmentsCount(): number {
        return this.Get('AssignmentsCount');
    }

    /**
    * * Field Name: CommentsCount
    * * Display Name: Comments Count
    * * SQL Data Type: int
    */
    get CommentsCount(): number {
        return this.Get('CommentsCount');
    }

    /**
    * * Field Name: LoggedMinutes
    * * Display Name: Logged Minutes
    * * SQL Data Type: int
    */
    get LoggedMinutes(): number {
        return this.Get('LoggedMinutes');
    }

    /**
    * * Field Name: AgentRunCount
    * * Display Name: Agent Run Count
    * * SQL Data Type: int
    */
    get AgentRunCount(): number {
        return this.Get('AgentRunCount');
    }

    /**
    * * Field Name: AgentCost
    * * Display Name: Agent Cost
    * * SQL Data Type: decimal(38, 8)
    */
    get AgentCost(): number {
        return this.Get('AgentCost');
    }

    /**
    * * Field Name: AgentTokens
    * * Display Name: Agent Tokens
    * * SQL Data Type: int
    */
    get AgentTokens(): number {
        return this.Get('AgentTokens');
    }
}


/**
 * MJ_BizApps_Tasks: Time Approvers - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TimeApprover
 * * Base View: vwTimeApprovers
 * * @description Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Time Approvers')
export class mjBizAppsTasksTimeApproverEntity extends BaseEntity<mjBizAppsTasksTimeApproverEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Time Approvers record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Time Approvers record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTimeApproverEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Time Approvers entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: The effective end date must be on or after the effective start date when both dates are provided.
    * * Table-Level: Scope entity and scope record must either both be specified or both be left empty to ensure consistent scoping.
    * * Table-Level: The worker person cannot be the same as the approver person.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateEffectiveToOnOrAfterEffectiveFrom(result);
        this.ValidateScopeEntityAndRecordPair(result);
        this.ValidateWorkerPersonIDNotEqualToApproverPersonID(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * The effective end date must be on or after the effective start date when both dates are provided.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
    	if (this.EffectiveFrom != null && this.EffectiveTo != null && this.EffectiveTo < this.EffectiveFrom) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EffectiveTo",
    			"Effective To date must be on or after the Effective From date.",
    			this.EffectiveTo,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * Scope entity and scope record must either both be specified or both be left empty to ensure consistent scoping.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    	public ValidateScopeEntityAndRecordPair(result: ValidationResult) {
    		const hasEntity = this.ScopeEntityID != null;
    		const hasRecord = this.ScopeRecordID != null && this.ScopeRecordID.trim() !== "";
    
    		if ((hasEntity && !hasRecord) || (!hasEntity && hasRecord)) {
    			result.Errors.push(new ValidationErrorInfo(
    				"ScopeEntityID",
    				"Scope Entity and Scope Record must either both be provided or both be left empty.",
    				this.ScopeEntityID,
    				ValidationErrorType.Failure
    			));
    		}
    	}

    /**
    * The worker person cannot be the same as the approver person.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateWorkerPersonIDNotEqualToApproverPersonID(result: ValidationResult) {
    	if (this.WorkerPersonID != null && UUIDsEqual(this.WorkerPersonID, this.ApproverPersonID)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"WorkerPersonID",
    			"The worker cannot be the same person as the approver.",
    			this.WorkerPersonID,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the time approver rule.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ApproverPersonID
    * * Display Name: Approver Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person who is granted time approval authority by this rule.
    */
    get ApproverPersonID(): string {
        return this.Get('ApproverPersonID');
    }
    set ApproverPersonID(value: string) {
        this.Set('ApproverPersonID', value);
    }

    /**
    * * Field Name: WorkerPersonID
    * * Display Name: Worker Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: Optional Worker Person whose time this rule applies to (NULL matches any worker).
    */
    get WorkerPersonID(): string | null {
        return this.Get('WorkerPersonID');
    }
    set WorkerPersonID(value: string | null) {
        this.Set('WorkerPersonID', value);
    }

    /**
    * * Field Name: ScopeTaskID
    * * Display Name: Scope Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: Optional project/parent Task this rule scopes approval to (NULL matches any task).
    */
    get ScopeTaskID(): string | null {
        return this.Get('ScopeTaskID');
    }
    set ScopeTaskID(value: string | null) {
        this.Set('ScopeTaskID', value);
    }

    /**
    * * Field Name: IncludeDescendants
    * * Display Name: Include Descendants
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.
    */
    get IncludeDescendants(): boolean {
        return this.Get('IncludeDescendants');
    }
    set IncludeDescendants(value: boolean) {
        this.Set('IncludeDescendants', value);
    }

    /**
    * * Field Name: ScopeEntityID
    * * Display Name: Scope Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    * * Description: Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.
    */
    get ScopeEntityID(): string | null {
        return this.Get('ScopeEntityID');
    }
    set ScopeEntityID(value: string | null) {
        this.Set('ScopeEntityID', value);
    }

    /**
    * * Field Name: ScopeRecordID
    * * Display Name: Scope Record ID
    * * SQL Data Type: nvarchar(450)
    * * Description: Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.
    */
    get ScopeRecordID(): string | null {
        return this.Get('ScopeRecordID');
    }
    set ScopeRecordID(value: string | null) {
        this.Set('ScopeRecordID', value);
    }

    /**
    * * Field Name: EffectiveFrom
    * * Display Name: Effective From
    * * SQL Data Type: date
    * * Description: Optional start date from which this approver rule is effective.
    */
    get EffectiveFrom(): Date | null {
        return this.Get('EffectiveFrom');
    }
    set EffectiveFrom(value: Date | null) {
        this.Set('EffectiveFrom', value);
    }

    /**
    * * Field Name: EffectiveTo
    * * Display Name: Effective To
    * * SQL Data Type: date
    * * Description: Optional end date through which this approver rule is effective.
    */
    get EffectiveTo(): Date | null {
        return this.Get('EffectiveTo');
    }
    set EffectiveTo(value: Date | null) {
        this.Set('EffectiveTo', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: Whether this approver rule is currently active.
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Optional administrative notes about this approver rule.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: ApproverPerson
    * * Display Name: Approver Person
    * * SQL Data Type: nvarchar(250)
    */
    get ApproverPerson(): string {
        return this.Get('ApproverPerson');
    }

    /**
    * * Field Name: WorkerPerson
    * * Display Name: Worker Person
    * * SQL Data Type: nvarchar(250)
    */
    get WorkerPerson(): string | null {
        return this.Get('WorkerPerson');
    }

    /**
    * * Field Name: ScopeTask
    * * Display Name: Scope Task
    * * SQL Data Type: nvarchar(255)
    */
    get ScopeTask(): string | null {
        return this.Get('ScopeTask');
    }

    /**
    * * Field Name: ScopeEntity
    * * Display Name: Scope Entity
    * * SQL Data Type: nvarchar(255)
    */
    get ScopeEntity(): string | null {
        return this.Get('ScopeEntity');
    }
}


/**
 * MJ_BizApps_Tasks: Timesheet Approvals - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TimesheetApproval
 * * Base View: vwTimesheetApprovals
 * * @description Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Approvals')
export class mjBizAppsTasksTimesheetApprovalEntity extends BaseEntity<mjBizAppsTasksTimesheetApprovalEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Timesheet Approvals record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Timesheet Approvals record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTimesheetApprovalEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Timesheet Approvals entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * SubmissionRound: Submission round must be 1 or greater.
    * * Table-Level: Minutes, billable minutes, and entry count must all be non-negative (zero or greater), and billable minutes cannot exceed the total minutes recorded.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateSubmissionRoundMinimum(result);
        this.ValidateTimesheetMinutesAndEntryCount(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Submission round must be 1 or greater.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    	public ValidateSubmissionRoundMinimum(result: ValidationResult) {
    		if (this.SubmissionRound != null && this.SubmissionRound < 1) {
    			result.Errors.push(new ValidationErrorInfo(
    				"SubmissionRound",
    				"Submission round must be at least 1.",
    				this.SubmissionRound,
    				ValidationErrorType.Failure
    			));
    		}
    	}

    /**
    * Minutes, billable minutes, and entry count must all be non-negative (zero or greater), and billable minutes cannot exceed the total minutes recorded.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateTimesheetMinutesAndEntryCount(result: ValidationResult) {
    	if (this.Minutes != null && this.Minutes < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"Minutes",
    			"Minutes cannot be negative.",
    			this.Minutes,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.BillableMinutes != null && this.BillableMinutes < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"BillableMinutes",
    			"Billable minutes cannot be negative.",
    			this.BillableMinutes,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.BillableMinutes != null && this.Minutes != null && this.BillableMinutes > this.Minutes) {
    		result.Errors.push(new ValidationErrorInfo(
    			"BillableMinutes",
    			"Billable minutes cannot exceed total minutes.",
    			this.BillableMinutes,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.EntryCount != null && this.EntryCount < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EntryCount",
    			"Entry count cannot be negative.",
    			this.EntryCount,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the timesheet approval part.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TimesheetID
    * * Display Name: Timesheet ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
    * * Description: The Timesheet this approval slice belongs to.
    */
    get TimesheetID(): string {
        return this.Get('TimesheetID');
    }
    set TimesheetID(value: string) {
        this.Set('TimesheetID', value);
    }

    /**
    * * Field Name: SubmissionRound
    * * Display Name: Submission Round
    * * SQL Data Type: int
    * * Default Value: 1
    * * Description: Submission round number (1 on initial submit, incremented on each resubmit).
    */
    get SubmissionRound(): number {
        return this.Get('SubmissionRound');
    }
    set SubmissionRound(value: number) {
        this.Set('SubmissionRound', value);
    }

    /**
    * * Field Name: ScopeTaskID
    * * Display Name: Scope Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.
    */
    get ScopeTaskID(): string | null {
        return this.Get('ScopeTaskID');
    }
    set ScopeTaskID(value: string | null) {
        this.Set('ScopeTaskID', value);
    }

    /**
    * * Field Name: ApprovalTaskID
    * * Display Name: Approval Task ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
    * * Description: The approval Task created in the Tasks inbox for this slice.
    */
    get ApprovalTaskID(): string {
        return this.Get('ApprovalTaskID');
    }
    set ApprovalTaskID(value: string) {
        this.Set('ApprovalTaskID', value);
    }

    /**
    * * Field Name: Minutes
    * * Display Name: Minutes
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Total minutes in this approval slice at submission time.
    */
    get Minutes(): number {
        return this.Get('Minutes');
    }
    set Minutes(value: number) {
        this.Set('Minutes', value);
    }

    /**
    * * Field Name: BillableMinutes
    * * Display Name: Billable Minutes
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Total billable minutes in this approval slice at submission time.
    */
    get BillableMinutes(): number {
        return this.Get('BillableMinutes');
    }
    set BillableMinutes(value: number) {
        this.Set('BillableMinutes', value);
    }

    /**
    * * Field Name: EntryCount
    * * Display Name: Entry Count
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Number of TaskTimeEntry rows included in this approval slice.
    */
    get EntryCount(): number {
        return this.Get('EntryCount');
    }
    set EntryCount(value: number) {
        this.Set('EntryCount', value);
    }

    /**
    * * Field Name: SnapshotHash
    * * Display Name: Snapshot Hash
    * * SQL Data Type: nvarchar(64)
    * * Description: Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.
    */
    get SnapshotHash(): string {
        return this.Get('SnapshotHash');
    }
    set SnapshotHash(value: string) {
        this.Set('SnapshotHash', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Approved
    *   * Canceled
    *   * Pending
    *   * Rejected
    * * Description: Current status of this approval slice: Pending, Approved, Rejected, or Canceled.
    */
    get Status(): 'Approved' | 'Canceled' | 'Pending' | 'Rejected' {
        return this.Get('Status');
    }
    set Status(value: 'Approved' | 'Canceled' | 'Pending' | 'Rejected') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: DecidedByPersonID
    * * Display Name: Decided By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person who recorded the approval or rejection decision.
    */
    get DecidedByPersonID(): string | null {
        return this.Get('DecidedByPersonID');
    }
    set DecidedByPersonID(value: string | null) {
        this.Set('DecidedByPersonID', value);
    }

    /**
    * * Field Name: DecidedAt
    * * Display Name: Decided At
    * * SQL Data Type: datetimeoffset
    * * Description: Timestamp when the decision on this slice was recorded.
    */
    get DecidedAt(): Date | null {
        return this.Get('DecidedAt');
    }
    set DecidedAt(value: Date | null) {
        this.Set('DecidedAt', value);
    }

    /**
    * * Field Name: DecisionNotes
    * * Display Name: Decision Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Notes or feedback provided by the approver when deciding this slice.
    */
    get DecisionNotes(): string | null {
        return this.Get('DecisionNotes');
    }
    set DecisionNotes(value: string | null) {
        this.Set('DecisionNotes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: ScopeTask
    * * Display Name: Scope Task
    * * SQL Data Type: nvarchar(255)
    */
    get ScopeTask(): string | null {
        return this.Get('ScopeTask');
    }

    /**
    * * Field Name: ApprovalTask
    * * Display Name: Approval Task
    * * SQL Data Type: nvarchar(255)
    */
    get ApprovalTask(): string {
        return this.Get('ApprovalTask');
    }

    /**
    * * Field Name: DecidedByPerson
    * * Display Name: Decided By Person
    * * SQL Data Type: nvarchar(250)
    */
    get DecidedByPerson(): string | null {
        return this.Get('DecidedByPerson');
    }
}


/**
 * MJ_BizApps_Tasks: Timesheet Links - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TimesheetLink
 * * Base View: vwTimesheetLinks
 * * @description Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Links')
export class mjBizAppsTasksTimesheetLinkEntity extends BaseEntity<mjBizAppsTasksTimesheetLinkEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Timesheet Links record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Timesheet Links record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTimesheetLinkEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the timesheet link.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: TimesheetID
    * * Display Name: Timesheet ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Timesheets (vwTimesheets.ID)
    * * Description: The Timesheet being linked.
    */
    get TimesheetID(): string {
        return this.Get('TimesheetID');
    }
    set TimesheetID(value: string) {
        this.Set('TimesheetID', value);
    }

    /**
    * * Field Name: EntityID
    * * Display Name: Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    * * Description: Target MemberJunction Entity ID for the linked external record.
    */
    get EntityID(): string {
        return this.Get('EntityID');
    }
    set EntityID(value: string) {
        this.Set('EntityID', value);
    }

    /**
    * * Field Name: RecordID
    * * Display Name: Record ID
    * * SQL Data Type: nvarchar(450)
    * * Description: Primary key value of the linked record in EntityID.
    */
    get RecordID(): string {
        return this.Get('RecordID');
    }
    set RecordID(value: string) {
        this.Set('RecordID', value);
    }

    /**
    * * Field Name: Relationship
    * * Display Name: Relationship
    * * SQL Data Type: nvarchar(30)
    * * Default Value: Related
    * * Value List Type: List
    * * Possible Values 
    *   * ExpenseReport
    *   * Invoice
    *   * PayrollBatch
    *   * Related
    * * Description: Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.
    */
    get Relationship(): 'ExpenseReport' | 'Invoice' | 'PayrollBatch' | 'Related' {
        return this.Get('Relationship');
    }
    set Relationship(value: 'ExpenseReport' | 'Invoice' | 'PayrollBatch' | 'Related') {
        this.Set('Relationship', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Entity
    * * Display Name: Entity
    * * SQL Data Type: nvarchar(255)
    */
    get Entity(): string {
        return this.Get('Entity');
    }
}


/**
 * MJ_BizApps_Tasks: Timesheet Schedules - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: TimesheetSchedule
 * * Base View: vwTimesheetSchedules
 * * @description Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Schedules')
export class mjBizAppsTasksTimesheetScheduleEntity extends BaseEntity<mjBizAppsTasksTimesheetScheduleEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Timesheet Schedules record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Timesheet Schedules record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTimesheetScheduleEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Timesheet Schedules entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: Effective to date must be on or after the effective from date, ensuring the validity period is chronologically correct.
    * * Table-Level: A record cannot be assigned to both a specific person and a scope entity at the same time; at least one of these assignments must remain empty.
    * * Table-Level: Scope entity and scope record must either both be provided or both be left empty.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateEffectiveToOnOrAfterEffectiveFrom(result);
        this.ValidatePersonIDAndScopeEntityIDMutualExclusivity(result);
        this.ValidateScopeEntityIDAndScopeRecordIDCoexistence(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Effective to date must be on or after the effective from date, ensuring the validity period is chronologically correct.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
    	if (this.EffectiveTo != null && this.EffectiveFrom != null && this.EffectiveTo < this.EffectiveFrom) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EffectiveTo",
    			"Effective To date must be on or after the Effective From date.",
    			this.EffectiveTo,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * A record cannot be assigned to both a specific person and a scope entity at the same time; at least one of these assignments must remain empty.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    	public ValidatePersonIDAndScopeEntityIDMutualExclusivity(result: ValidationResult) {
    		if (this.PersonID != null && this.ScopeEntityID != null) {
    			result.Errors.push(new ValidationErrorInfo(
    				"PersonID",
    				"A record cannot have both a Person and a Scope Entity specified.",
    				this.PersonID,
    				ValidationErrorType.Failure
    			));
    		}
    	}

    /**
    * Scope entity and scope record must either both be provided or both be left empty.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateScopeEntityIDAndScopeRecordIDCoexistence(result: ValidationResult) {
    	const hasEntity = this.ScopeEntityID != null;
    	const hasRecord = this.ScopeRecordID != null && this.ScopeRecordID.trim() !== "";
    
    	if ((hasEntity && !hasRecord) || (!hasEntity && hasRecord)) {
    		result.Errors.push(new ValidationErrorInfo(
    			"ScopeEntityID",
    			"Both Scope Entity and Scope Record must be provided together, or both must be omitted.",
    			this.ScopeEntityID,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the timesheet schedule.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).
    */
    get PersonID(): string | null {
        return this.Get('PersonID');
    }
    set PersonID(value: string | null) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: ScopeEntityID
    * * Display Name: Scope Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    * * Description: Optional MJ Entity ID when scoping the schedule to an organization or department record.
    */
    get ScopeEntityID(): string | null {
        return this.Get('ScopeEntityID');
    }
    set ScopeEntityID(value: string | null) {
        this.Set('ScopeEntityID', value);
    }

    /**
    * * Field Name: ScopeRecordID
    * * Display Name: Scope Record ID
    * * SQL Data Type: nvarchar(450)
    * * Description: Companion record ID in ScopeEntityID for entity-scoped schedules.
    */
    get ScopeRecordID(): string | null {
        return this.Get('ScopeRecordID');
    }
    set ScopeRecordID(value: string | null) {
        this.Set('ScopeRecordID', value);
    }

    /**
    * * Field Name: Cadence
    * * Display Name: Cadence
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * BiWeekly
    *   * Monthly
    *   * SemiMonthly
    *   * Weekly
    * * Description: Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.
    */
    get Cadence(): 'BiWeekly' | 'Monthly' | 'SemiMonthly' | 'Weekly' {
        return this.Get('Cadence');
    }
    set Cadence(value: 'BiWeekly' | 'Monthly' | 'SemiMonthly' | 'Weekly') {
        this.Set('Cadence', value);
    }

    /**
    * * Field Name: WeekStartDay
    * * Display Name: Week Start Day
    * * SQL Data Type: nvarchar(10)
    * * Default Value: Monday
    * * Value List Type: List
    * * Possible Values 
    *   * Monday
    *   * Saturday
    *   * Sunday
    * * Description: First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.
    */
    get WeekStartDay(): 'Monday' | 'Saturday' | 'Sunday' {
        return this.Get('WeekStartDay');
    }
    set WeekStartDay(value: 'Monday' | 'Saturday' | 'Sunday') {
        this.Set('WeekStartDay', value);
    }

    /**
    * * Field Name: BiWeeklyAnchorDate
    * * Display Name: Bi Weekly Anchor Date
    * * SQL Data Type: date
    * * Default Value: 2026-01-05
    * * Description: Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.
    */
    get BiWeeklyAnchorDate(): Date {
        return this.Get('BiWeeklyAnchorDate');
    }
    set BiWeeklyAnchorDate(value: Date) {
        this.Set('BiWeeklyAnchorDate', value);
    }

    /**
    * * Field Name: EffectiveFrom
    * * Display Name: Effective From
    * * SQL Data Type: date
    * * Description: Inclusive start date from which this schedule is effective (must fall on a period boundary).
    */
    get EffectiveFrom(): Date {
        return this.Get('EffectiveFrom');
    }
    set EffectiveFrom(value: Date) {
        this.Set('EffectiveFrom', value);
    }

    /**
    * * Field Name: EffectiveTo
    * * Display Name: Effective To
    * * SQL Data Type: date
    * * Description: Optional inclusive end date through which this schedule is effective.
    */
    get EffectiveTo(): Date | null {
        return this.Get('EffectiveTo');
    }
    set EffectiveTo(value: Date | null) {
        this.Set('EffectiveTo', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Optional notes explaining this schedule or cadence change.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string | null {
        return this.Get('Person');
    }

    /**
    * * Field Name: ScopeEntity
    * * Display Name: Scope Entity
    * * SQL Data Type: nvarchar(255)
    */
    get ScopeEntity(): string | null {
        return this.Get('ScopeEntity');
    }
}


/**
 * MJ_BizApps_Tasks: Timesheets - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: Timesheet
 * * Base View: vwTimesheets
 * * @description Period timesheet header for a person, grouping task time entries across a date range for submission and approval.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheets')
export class mjBizAppsTasksTimesheetEntity extends BaseEntity<mjBizAppsTasksTimesheetEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Timesheets record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Timesheets record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksTimesheetEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for MJ_BizApps_Tasks: Timesheets entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: Period end date must be on or after the period start date.
    * * Table-Level: Total minutes and billable minutes must both be zero or positive, and billable minutes cannot exceed total minutes.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidatePeriodEndOnOrAfterPeriodStart(result);
        this.ValidateTotalAndBillableMinutes(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Period end date must be on or after the period start date.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidatePeriodEndOnOrAfterPeriodStart(result: ValidationResult) {
    	if (this.PeriodStart != null && this.PeriodEnd != null && this.PeriodEnd < this.PeriodStart) {
    		result.Errors.push(new ValidationErrorInfo(
    			"PeriodEnd",
    			"The period end date must be on or after the period start date.",
    			this.PeriodEnd,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * Total minutes and billable minutes must both be zero or positive, and billable minutes cannot exceed total minutes.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateTotalAndBillableMinutes(result: ValidationResult) {
    	if (this.TotalMinutes != null && this.TotalMinutes < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"TotalMinutes",
    			"Total minutes cannot be negative.",
    			this.TotalMinutes,
    			ValidationErrorType.Failure
    		));
    	}
    
    	if (this.BillableMinutes != null && this.BillableMinutes < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"BillableMinutes",
    			"Billable minutes cannot be negative.",
    			this.BillableMinutes,
    			ValidationErrorType.Failure
    		));
    	}
    
    	if (this.TotalMinutes != null && this.BillableMinutes != null && this.BillableMinutes > this.TotalMinutes) {
    		result.Errors.push(new ValidationErrorInfo(
    			"BillableMinutes",
    			"Billable minutes cannot exceed total minutes.",
    			this.BillableMinutes,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    * * Description: Primary key for the timesheet.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The Person whose time entries are covered by this timesheet.
    */
    get PersonID(): string {
        return this.Get('PersonID');
    }
    set PersonID(value: string) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: PeriodStart
    * * Display Name: Period Start
    * * SQL Data Type: date
    * * Description: Inclusive start date of the timesheet period.
    */
    get PeriodStart(): Date {
        return this.Get('PeriodStart');
    }
    set PeriodStart(value: Date) {
        this.Set('PeriodStart', value);
    }

    /**
    * * Field Name: PeriodEnd
    * * Display Name: Period End
    * * SQL Data Type: date
    * * Description: Inclusive end date of the timesheet period.
    */
    get PeriodEnd(): Date {
        return this.Get('PeriodEnd');
    }
    set PeriodEnd(value: Date) {
        this.Set('PeriodEnd', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Approved
    *   * Draft
    *   * Rejected
    *   * Submitted
    * * Description: Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.
    */
    get Status(): 'Approved' | 'Draft' | 'Rejected' | 'Submitted' {
        return this.Get('Status');
    }
    set Status(value: 'Approved' | 'Draft' | 'Rejected' | 'Submitted') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: SubmittedAt
    * * Display Name: Submitted At
    * * SQL Data Type: datetimeoffset
    * * Description: Timestamp when the timesheet was most recently submitted.
    */
    get SubmittedAt(): Date | null {
        return this.Get('SubmittedAt');
    }
    set SubmittedAt(value: Date | null) {
        this.Set('SubmittedAt', value);
    }

    /**
    * * Field Name: SubmittedByUserID
    * * Display Name: Submitted By User ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
    * * Description: The MemberJunction User who submitted the timesheet.
    */
    get SubmittedByUserID(): string | null {
        return this.Get('SubmittedByUserID');
    }
    set SubmittedByUserID(value: string | null) {
        this.Set('SubmittedByUserID', value);
    }

    /**
    * * Field Name: TotalMinutes
    * * Display Name: Total Minutes
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Total minutes across all time entries attached to this timesheet.
    */
    get TotalMinutes(): number {
        return this.Get('TotalMinutes');
    }
    set TotalMinutes(value: number) {
        this.Set('TotalMinutes', value);
    }

    /**
    * * Field Name: BillableMinutes
    * * Display Name: Billable Minutes
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Total billable minutes across all time entries attached to this timesheet.
    */
    get BillableMinutes(): number {
        return this.Get('BillableMinutes');
    }
    set BillableMinutes(value: number) {
        this.Set('BillableMinutes', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Worker notes or comments submitted with the timesheet.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(250)
    */
    get Person(): string {
        return this.Get('Person');
    }

    /**
    * * Field Name: SubmittedByUser
    * * Display Name: Submitted By User
    * * SQL Data Type: nvarchar(100)
    */
    get SubmittedByUser(): string | null {
        return this.Get('SubmittedByUser');
    }
}
