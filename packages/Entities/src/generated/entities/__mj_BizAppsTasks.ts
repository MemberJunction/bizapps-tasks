import { BaseEntity, EntitySaveOptions, EntityDeleteOptions, CompositeKey, ValidationResult, ValidationErrorInfo, ValidationErrorType, Metadata, ProviderType, DatabaseProviderBase, RunView } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";
import { z } from "zod";

     
 
/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Agenda Item Types
 */
export const mjBizAppsTasksMeetingAgendaItemTypeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)
        * * Description: The type's display name. Unique.`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: A stable code apps and agenda templates refer to. Unique.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What items of this type are for.`),
    IconClass: z.string().nullable().describe(`
        * * Field Name: IconClass
        * * Display Name: Icon Class
        * * SQL Data Type: nvarchar(100)
        * * Description: Font Awesome icon class shown beside the item.`),
    DefaultDurationMinutes: z.number().nullable().describe(`
        * * Field Name: DefaultDurationMinutes
        * * Display Name: Default Duration Minutes
        * * SQL Data Type: int
        * * Description: How long an item of this type takes unless the agenda says otherwise. More than 0.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: When false, the type is kept for existing items but not offered for new ones.`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100
        * * Description: Display order among types.`),
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

export type mjBizAppsTasksMeetingAgendaItemTypeEntityType = z.infer<typeof mjBizAppsTasksMeetingAgendaItemTypeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Agenda Items
 */
export const mjBizAppsTasksMeetingAgendaItemSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    MeetingID: z.string().describe(`
        * * Field Name: MeetingID
        * * Display Name: Meeting ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
        * * Description: The meeting the item is on the agenda of.`),
    ParentID: z.string().nullable().describe(`
        * * Field Name: ParentID
        * * Display Name: Parent ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Items (vwMeetingAgendaItems.ID)
        * * Description: The item this one sits under, for a sub-item. Same meeting, no cycle.`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100
        * * Description: Order among its siblings.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(500)
        * * Description: The item's title.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What the item covers, in Markdown.`),
    TypeID: z.string().nullable().describe(`
        * * Field Name: TypeID
        * * Display Name: Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Item Types (vwMeetingAgendaItemTypes.ID)
        * * Description: The agenda item type: Information, Discussion, Decision, and so on.`),
    PresenterPersonID: z.string().nullable().describe(`
        * * Field Name: PresenterPersonID
        * * Display Name: Presenter Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who presents the item.`),
    DurationMinutes: z.number().nullable().describe(`
        * * Field Name: DurationMinutes
        * * Display Name: Duration Minutes
        * * SQL Data Type: int
        * * Description: How long the item is planned to take. 0 or more.`),
    Status: z.union([z.literal('Deferred'), z.literal('Done'), z.literal('InProgress'), z.literal('Planned'), z.literal('Skipped')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Planned
    * * Value List Type: List
    * * Possible Values 
    *   * Deferred
    *   * Done
    *   * InProgress
    *   * Planned
    *   * Skipped
        * * Description: Planned, InProgress, Done, Deferred or Skipped.`),
    StartedAt: z.date().nullable().describe(`
        * * Field Name: StartedAt
        * * Display Name: Started At
        * * SQL Data Type: datetimeoffset
        * * Description: When the item was started, from the live meeting.`),
    EndedAt: z.date().nullable().describe(`
        * * Field Name: EndedAt
        * * Display Name: Ended At
        * * SQL Data Type: datetimeoffset
        * * Description: When the item was ended.`),
    Outcome: z.string().nullable().describe(`
        * * Field Name: Outcome
        * * Display Name: Outcome
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What was agreed, in a sentence or two.`),
    DeferredToMeetingID: z.string().nullable().describe(`
        * * Field Name: DeferredToMeetingID
        * * Display Name: Deferred To Meeting ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
        * * Description: The later meeting a deferred item moved to.`),
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
    Meeting: z.string().describe(`
        * * Field Name: Meeting
        * * Display Name: Meeting
        * * SQL Data Type: nvarchar(255)`),
    Parent: z.string().nullable().describe(`
        * * Field Name: Parent
        * * Display Name: Parent
        * * SQL Data Type: nvarchar(500)`),
    Type: z.string().nullable().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
    PresenterPerson: z.string().nullable().describe(`
        * * Field Name: PresenterPerson
        * * Display Name: Presenter Person
        * * SQL Data Type: nvarchar(201)`),
    DeferredToMeeting: z.string().nullable().describe(`
        * * Field Name: DeferredToMeeting
        * * Display Name: Deferred To Meeting
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksMeetingAgendaItemEntityType = z.infer<typeof mjBizAppsTasksMeetingAgendaItemSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Attendees
 */
export const mjBizAppsTasksMeetingAttendeeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    MeetingID: z.string().describe(`
        * * Field Name: MeetingID
        * * Display Name: Meeting ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
        * * Description: The meeting the attendee is invited to.`),
    PersonID: z.string().nullable().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person invited, when they are a Person. Either this or Email is set.`),
    UserID: z.string().nullable().describe(`
        * * Field Name: UserID
        * * Display Name: User ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
        * * Description: The person's MemberJunction user, when they have one, filled from the person's account. My meetings and the private-meeting filter use it.`),
    Email: z.string().nullable().describe(`
        * * Field Name: Email
        * * Display Name: Email
        * * SQL Data Type: nvarchar(255)
        * * Description: A guest's address, or the address a person's invitation goes to.`),
    DisplayName: z.string().nullable().describe(`
        * * Field Name: DisplayName
        * * Display Name: Display Name
        * * SQL Data Type: nvarchar(255)
        * * Description: A guest's name.`),
    Role: z.union([z.literal('Optional'), z.literal('Organizer'), z.literal('Required')]).describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Required
    * * Value List Type: List
    * * Possible Values 
    *   * Optional
    *   * Organizer
    *   * Required
        * * Description: Organizer, Required or Optional. One Organizer row per meeting, kept in step with Meeting.OrganizerPersonID.`),
    ResponseStatus: z.union([z.literal('Accepted'), z.literal('Declined'), z.literal('None'), z.literal('Tentative')]).describe(`
        * * Field Name: ResponseStatus
        * * Display Name: Response Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: None
    * * Value List Type: List
    * * Possible Values 
    *   * Accepted
    *   * Declined
    *   * None
    *   * Tentative
        * * Description: The answer to the invitation: None, Accepted, Tentative or Declined.`),
    RespondedAt: z.date().nullable().describe(`
        * * Field Name: RespondedAt
        * * Display Name: Responded At
        * * SQL Data Type: datetimeoffset
        * * Description: When the invitation was answered.`),
    AttendanceStatus: z.union([z.literal('Absent'), z.literal('Excused'), z.literal('Late'), z.literal('LeftEarly'), z.literal('Present'), z.literal('Unknown')]).describe(`
        * * Field Name: AttendanceStatus
        * * Display Name: Attendance Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Unknown
    * * Value List Type: List
    * * Possible Values 
    *   * Absent
    *   * Excused
    *   * Late
    *   * LeftEarly
    *   * Present
    *   * Unknown
        * * Description: Whether they came: Unknown, Present, Late, LeftEarly, Absent or Excused.`),
    JoinedAt: z.date().nullable().describe(`
        * * Field Name: JoinedAt
        * * Display Name: Joined At
        * * SQL Data Type: datetimeoffset
        * * Description: When they joined, from the live meeting or the video provider.`),
    LeftAt: z.date().nullable().describe(`
        * * Field Name: LeftAt
        * * Display Name: Left At
        * * SQL Data Type: datetimeoffset
        * * Description: When they left.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(500)
        * * Description: A note on their attendance, such as why someone is excused.`),
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
    Meeting: z.string().describe(`
        * * Field Name: Meeting
        * * Display Name: Meeting
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(201)`),
    User: z.string().nullable().describe(`
        * * Field Name: User
        * * Display Name: User
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksMeetingAttendeeEntityType = z.infer<typeof mjBizAppsTasksMeetingAttendeeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Links
 */
export const mjBizAppsTasksMeetingLinkSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    MeetingID: z.string().nullable().describe(`
        * * Field Name: MeetingID
        * * Display Name: Meeting ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
        * * Description: The meeting that belongs to the record. Either this or SeriesID is set.`),
    SeriesID: z.string().nullable().describe(`
        * * Field Name: SeriesID
        * * Display Name: Series ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
        * * Description: The series that belongs to the record. Either this or MeetingID is set.`),
    EntityID: z.string().describe(`
        * * Field Name: EntityID
        * * Display Name: Entity ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
        * * Description: The entity of the record the meeting belongs to.`),
    RecordID: z.string().describe(`
        * * Field Name: RecordID
        * * Display Name: Record ID
        * * SQL Data Type: nvarchar(450)
        * * Description: The record's primary key, as on TaskLink.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(500)
        * * Description: Why the meeting belongs to the record.`),
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
    Meeting: z.string().nullable().describe(`
        * * Field Name: Meeting
        * * Display Name: Meeting
        * * SQL Data Type: nvarchar(255)`),
    Series: z.string().nullable().describe(`
        * * Field Name: Series
        * * Display Name: Series
        * * SQL Data Type: nvarchar(255)`),
    Entity: z.string().describe(`
        * * Field Name: Entity
        * * Display Name: Entity
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksMeetingLinkEntityType = z.infer<typeof mjBizAppsTasksMeetingLinkSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Notes
 */
export const mjBizAppsTasksMeetingNoteSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    MeetingID: z.string().describe(`
        * * Field Name: MeetingID
        * * Display Name: Meeting ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
        * * Description: The meeting the note is about.`),
    AgendaItemID: z.string().nullable().describe(`
        * * Field Name: AgendaItemID
        * * Display Name: Agenda Item ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Items (vwMeetingAgendaItems.ID)
        * * Description: The agenda item the note is about, for a note on one item.`),
    Kind: z.union([z.literal('Decision'), z.literal('Notes'), z.literal('Summary')]).describe(`
        * * Field Name: Kind
        * * Display Name: Kind
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Notes
    * * Value List Type: List
    * * Possible Values 
    *   * Decision
    *   * Notes
    *   * Summary
        * * Description: Notes, Summary or Decision.`),
    Title: z.string().nullable().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(255)
        * * Description: The note's title.`),
    Body: z.string().describe(`
        * * Field Name: Body
        * * Display Name: Body
        * * SQL Data Type: nvarchar(MAX)
        * * Description: The note, in Markdown.`),
    Source: z.union([z.literal('AI'), z.literal('Manual')]).describe(`
        * * Field Name: Source
        * * Display Name: Source
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Manual
    * * Value List Type: List
    * * Possible Values 
    *   * AI
    *   * Manual
        * * Description: Manual for a person's note; AI for a draft from a transcript.`),
    Status: z.union([z.literal('Draft'), z.literal('Final')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Draft
    *   * Final
        * * Description: Draft or Final. Approving minutes is governance and stays with the app that owns it.`),
    AuthorPersonID: z.string().nullable().describe(`
        * * Field Name: AuthorPersonID
        * * Display Name: Author Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who wrote the note, for a person's note.`),
    AIPromptRunID: z.string().nullable().describe(`
        * * Field Name: AIPromptRunID
        * * Display Name: AI Prompt Run ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: AI Prompt Runs (vwAIPromptRuns.ID)
        * * Description: The MJ: AI Prompt Runs record the draft came from, for an AI note.`),
    ProposedTasks: z.string().nullable().describe(`
        * * Field Name: ProposedTasks
        * * Display Name: Proposed Tasks
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON: the action items the notes propose, each with a title, an assignee, a due date, its agenda item, and the task's ID once a person accepted it. Nothing is filed without that approval.`),
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
    Meeting: z.string().describe(`
        * * Field Name: Meeting
        * * Display Name: Meeting
        * * SQL Data Type: nvarchar(255)`),
    AgendaItem: z.string().nullable().describe(`
        * * Field Name: AgendaItem
        * * Display Name: Agenda Item
        * * SQL Data Type: nvarchar(500)`),
    AuthorPerson: z.string().nullable().describe(`
        * * Field Name: AuthorPerson
        * * Display Name: Author Person
        * * SQL Data Type: nvarchar(201)`),
    AIPromptRun: z.string().nullable().describe(`
        * * Field Name: AIPromptRun
        * * Display Name: AI Prompt Run
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksMeetingNoteEntityType = z.infer<typeof mjBizAppsTasksMeetingNoteSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Series
 */
export const mjBizAppsTasksMeetingSeriesSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)
        * * Description: The series' title. Each new occurrence starts with it.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: The series' purpose, in Markdown. Each new occurrence starts with it.`),
    TypeID: z.string().nullable().describe(`
        * * Field Name: TypeID
        * * Display Name: Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Types (vwMeetingTypes.ID)
        * * Description: The meeting type each occurrence is made from.`),
    OrganizerPersonID: z.string().describe(`
        * * Field Name: OrganizerPersonID
        * * Display Name: Organizer Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who organizes the series. Each occurrence starts with them as its organizer.`),
    RecurrenceRule: z.string().describe(`
        * * Field Name: RecurrenceRule
        * * Display Name: Recurrence Rule
        * * SQL Data Type: nvarchar(500)
        * * Description: An RFC 5545 RRULE value, such as FREQ=WEEKLY;BYDAY=TU. Its UNTIL or COUNT ends the series.`),
    TimeZone: z.string().describe(`
        * * Field Name: TimeZone
        * * Display Name: Time Zone
        * * SQL Data Type: nvarchar(64)
        * * Description: The IANA time zone the rule is expanded in, such as America/Chicago, so a 9:00 meeting stays at 9:00 across daylight-saving changes.`),
    FirstStartsAt: z.date().describe(`
        * * Field Name: FirstStartsAt
        * * Display Name: First Starts At
        * * SQL Data Type: datetimeoffset
        * * Description: The rule's DTSTART: when the first occurrence starts.`),
    DurationMinutes: z.number().describe(`
        * * Field Name: DurationMinutes
        * * Display Name: Duration Minutes
        * * SQL Data Type: int
        * * Description: How long each occurrence lasts. More than 0.`),
    LocationType: z.union([z.literal('Hybrid'), z.literal('InPerson'), z.literal('Phone'), z.literal('Virtual')]).describe(`
        * * Field Name: LocationType
        * * Display Name: Location Type
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Virtual
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
        * * Description: The location each new occurrence starts with: Virtual, InPerson, Hybrid or Phone.`),
    Location: z.string().nullable().describe(`
        * * Field Name: Location
        * * Display Name: Location
        * * SQL Data Type: nvarchar(500)
        * * Description: The room or address each new occurrence starts with.`),
    VideoProviderID: z.string().nullable().describe(`
        * * Field Name: VideoProviderID
        * * Display Name: Video Provider ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
        * * Description: The video provider each new virtual occurrence is hosted on.`),
    Visibility: z.union([z.literal('Private'), z.literal('Standard')]).describe(`
        * * Field Name: Visibility
        * * Display Name: Visibility
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Standard
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
        * * Description: The visibility each new occurrence starts with: Standard, or Private for its attendees only.`),
    Status: z.union([z.literal('Active'), z.literal('Cancelled'), z.literal('Ended')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Active
    * * Value List Type: List
    * * Possible Values 
    *   * Active
    *   * Cancelled
    *   * Ended
        * * Description: Active while occurrences are still made; Ended once the rule has run out; Cancelled when the series was stopped.`),
    MaterializedThrough: z.date().nullable().describe(`
        * * Field Name: MaterializedThrough
        * * Display Name: Materialized Through
        * * SQL Data Type: datetimeoffset
        * * Description: Occurrences exist up to this point in time. The scheduled job and a save extend it.`),
    CreatedByPersonID: z.string().nullable().describe(`
        * * Field Name: CreatedByPersonID
        * * Display Name: Created By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who created the series, as Task.CreatedByPersonID.`),
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
    Type: z.string().nullable().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
    OrganizerPerson: z.string().describe(`
        * * Field Name: OrganizerPerson
        * * Display Name: Organizer Person
        * * SQL Data Type: nvarchar(201)`),
    VideoProvider: z.string().nullable().describe(`
        * * Field Name: VideoProvider
        * * Display Name: Video Provider
        * * SQL Data Type: nvarchar(100)`),
    CreatedByPerson: z.string().nullable().describe(`
        * * Field Name: CreatedByPerson
        * * Display Name: Created By Person
        * * SQL Data Type: nvarchar(201)`),
});

export type mjBizAppsTasksMeetingSeriesEntityType = z.infer<typeof mjBizAppsTasksMeetingSeriesSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Series Attendees
 */
export const mjBizAppsTasksMeetingSeriesAttendeeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    SeriesID: z.string().describe(`
        * * Field Name: SeriesID
        * * Display Name: Series ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
        * * Description: The series each new occurrence of which invites this attendee.`),
    PersonID: z.string().nullable().describe(`
        * * Field Name: PersonID
        * * Display Name: Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person invited, when they are a Person. Either this or Email is set.`),
    UserID: z.string().nullable().describe(`
        * * Field Name: UserID
        * * Display Name: User ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
        * * Description: The person's MemberJunction user, when they have one, filled from the person's account.`),
    Email: z.string().nullable().describe(`
        * * Field Name: Email
        * * Display Name: Email
        * * SQL Data Type: nvarchar(255)
        * * Description: A guest's address, or the address a person's invitation goes to.`),
    DisplayName: z.string().nullable().describe(`
        * * Field Name: DisplayName
        * * Display Name: Display Name
        * * SQL Data Type: nvarchar(255)
        * * Description: A guest's name.`),
    Role: z.union([z.literal('Optional'), z.literal('Required')]).describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Required
    * * Value List Type: List
    * * Possible Values 
    *   * Optional
    *   * Required
        * * Description: Required or Optional. The organizer is the series' own.`),
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
    Series: z.string().describe(`
        * * Field Name: Series
        * * Display Name: Series
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(201)`),
    User: z.string().nullable().describe(`
        * * Field Name: User
        * * Display Name: User
        * * SQL Data Type: nvarchar(100)`),
});

export type mjBizAppsTasksMeetingSeriesAttendeeEntityType = z.infer<typeof mjBizAppsTasksMeetingSeriesAttendeeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meeting Types
 */
export const mjBizAppsTasksMeetingTypeSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)
        * * Description: The type's display name. Unique.`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: A stable code apps refer to, as TaskType.Code. Unique.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What meetings of this type are for.`),
    IconClass: z.string().nullable().describe(`
        * * Field Name: IconClass
        * * Display Name: Icon Class
        * * SQL Data Type: nvarchar(100)
        * * Description: Font Awesome icon class shown beside the type.`),
    DefaultDurationMinutes: z.number().nullable().describe(`
        * * Field Name: DefaultDurationMinutes
        * * Display Name: Default Duration Minutes
        * * SQL Data Type: int
        * * Description: How long a new meeting of this type lasts unless the organizer says otherwise. More than 0.`),
    DefaultLocationType: z.union([z.literal('Hybrid'), z.literal('InPerson'), z.literal('Phone'), z.literal('Virtual')]).nullable().describe(`
        * * Field Name: DefaultLocationType
        * * Display Name: Default Location Type
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
        * * Description: The location a new meeting of this type starts with: Virtual, InPerson, Hybrid or Phone.`),
    DefaultVideoProviderID: z.string().nullable().describe(`
        * * Field Name: DefaultVideoProviderID
        * * Display Name: Default Video Provider ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
        * * Description: The video provider a new virtual meeting of this type is hosted on.`),
    DefaultVisibility: z.union([z.literal('Private'), z.literal('Standard')]).nullable().describe(`
        * * Field Name: DefaultVisibility
        * * Display Name: Default Visibility
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
        * * Description: The visibility a new meeting of this type starts with: Standard or Private.`),
    AgendaTemplate: z.string().nullable().describe(`
        * * Field Name: AgendaTemplate
        * * Display Name: Agenda Template
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON: the agenda a new meeting of this type starts with, as items with a title, an agenda item type code, a duration in minutes and sub-items.`),
    NotesPromptID: z.string().nullable().describe(`
        * * Field Name: NotesPromptID
        * * Display Name: Notes Prompt ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: AI Prompts (vwAIPrompts.ID)
        * * Description: The MJ: AI Prompts record that drafts notes from a transcript for this type, instead of the shipped prompt.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: When false, the type is kept for existing meetings but not offered for new ones.`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 100
        * * Description: Display order among types.`),
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
    DefaultVideoProvider: z.string().nullable().describe(`
        * * Field Name: DefaultVideoProvider
        * * Display Name: Default Video Provider
        * * SQL Data Type: nvarchar(100)`),
    NotesPrompt: z.string().nullable().describe(`
        * * Field Name: NotesPrompt
        * * Display Name: Notes Prompt
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksMeetingTypeEntityType = z.infer<typeof mjBizAppsTasksMeetingTypeSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Meetings
 */
export const mjBizAppsTasksMeetingSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(255)
        * * Description: The meeting's title, as Task.Name is a task's.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: The meeting's purpose, in Markdown.`),
    TypeID: z.string().nullable().describe(`
        * * Field Name: TypeID
        * * Display Name: Type ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Types (vwMeetingTypes.ID)
        * * Description: The meeting type it was made from, which gave its defaults and agenda template.`),
    SeriesID: z.string().nullable().describe(`
        * * Field Name: SeriesID
        * * Display Name: Series ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
        * * Description: The series this meeting is an occurrence of, when it is one.`),
    OccurrenceStartsAt: z.date().nullable().describe(`
        * * Field Name: OccurrenceStartsAt
        * * Display Name: Occurrence Starts At
        * * SQL Data Type: datetimeoffset
        * * Description: The series' original slot for this occurrence. It names the occurrence after it moves, so the series does not make it again. Set with SeriesID, empty without it.`),
    Status: z.union([z.literal('Cancelled'), z.literal('Completed'), z.literal('Draft'), z.literal('InProgress'), z.literal('Postponed'), z.literal('Scheduled')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Scheduled
    * * Value List Type: List
    * * Possible Values 
    *   * Cancelled
    *   * Completed
    *   * Draft
    *   * InProgress
    *   * Postponed
    *   * Scheduled
        * * Description: Draft, Scheduled, Postponed, InProgress, Completed or Cancelled. The server moves it forward: Draft to Scheduled to InProgress to Completed; Scheduled and Postponed either way; anything but Completed may be Cancelled.`),
    StartsAt: z.date().describe(`
        * * Field Name: StartsAt
        * * Display Name: Starts At
        * * SQL Data Type: datetimeoffset
        * * Description: When the meeting is planned to start.`),
    EndsAt: z.date().describe(`
        * * Field Name: EndsAt
        * * Display Name: Ends At
        * * SQL Data Type: datetimeoffset
        * * Description: When the meeting is planned to end. Later than StartsAt.`),
    TimeZone: z.string().describe(`
        * * Field Name: TimeZone
        * * Display Name: Time Zone
        * * SQL Data Type: nvarchar(64)
        * * Description: The IANA time zone the meeting is planned in, such as America/Chicago. Display and recurrence use it. Defaults from the organizer's setting, else the business time zone.`),
    LocationType: z.union([z.literal('Hybrid'), z.literal('InPerson'), z.literal('Phone'), z.literal('Virtual')]).describe(`
        * * Field Name: LocationType
        * * Display Name: Location Type
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Virtual
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
        * * Description: Virtual, InPerson, Hybrid or Phone.`),
    Location: z.string().nullable().describe(`
        * * Field Name: Location
        * * Display Name: Location
        * * SQL Data Type: nvarchar(500)
        * * Description: A room or an address, for an in-person or hybrid meeting.`),
    VideoProviderID: z.string().nullable().describe(`
        * * Field Name: VideoProviderID
        * * Display Name: Video Provider ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
        * * Description: The video provider the meeting is hosted on, for a virtual or hybrid meeting.`),
    VideoMeetingID: z.string().nullable().describe(`
        * * Field Name: VideoMeetingID
        * * Display Name: Video Meeting ID
        * * SQL Data Type: nvarchar(255)
        * * Description: The provider's own ID for the meeting, kept to update or delete it there.`),
    VideoJoinURL: z.string().nullable().describe(`
        * * Field Name: VideoJoinURL
        * * Display Name: Video Join URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: The link attendees join by, from the provider or typed in.`),
    DialInDetails: z.string().nullable().describe(`
        * * Field Name: DialInDetails
        * * Display Name: Dial In Details
        * * SQL Data Type: nvarchar(1000)
        * * Description: Phone numbers and access codes for joining by phone.`),
    OrganizerPersonID: z.string().describe(`
        * * Field Name: OrganizerPersonID
        * * Display Name: Organizer Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who organizes the meeting. Their calendar holds its event, and the meeting always has their attendee row.`),
    Visibility: z.union([z.literal('Private'), z.literal('Standard')]).describe(`
        * * Field Name: Visibility
        * * Display Name: Visibility
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Standard
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
        * * Description: Standard: readable by anyone who reads meetings. Private: readable only by its attendees, the organizer included.`),
    ActualStartedAt: z.date().nullable().describe(`
        * * Field Name: ActualStartedAt
        * * Display Name: Actual Started At
        * * SQL Data Type: datetimeoffset
        * * Description: When the live meeting was started.`),
    ActualEndedAt: z.date().nullable().describe(`
        * * Field Name: ActualEndedAt
        * * Display Name: Actual Ended At
        * * SQL Data Type: datetimeoffset
        * * Description: When the live meeting was ended.`),
    CancelledAt: z.date().nullable().describe(`
        * * Field Name: CancelledAt
        * * Display Name: Cancelled At
        * * SQL Data Type: datetimeoffset
        * * Description: When the meeting was cancelled. Stamped by the server with the status.`),
    CancellationReason: z.string().nullable().describe(`
        * * Field Name: CancellationReason
        * * Display Name: Cancellation Reason
        * * SQL Data Type: nvarchar(500)
        * * Description: Why the meeting was cancelled, for its attendees.`),
    VideoRecordingURL: z.string().nullable().describe(`
        * * Field Name: VideoRecordingURL
        * * Display Name: Video Recording URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: Where the provider's recording can be watched.`),
    TranscriptFileID: z.string().nullable().describe(`
        * * Field Name: TranscriptFileID
        * * Display Name: Transcript File ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Files (vwFiles.ID)
        * * Description: The MJ: Files record holding the transcript, uploaded by a person or saved there by the provider's driver. A transcript is a file in MemberJunction's storage, never a URL a user typed.`),
    CreatedByPersonID: z.string().nullable().describe(`
        * * Field Name: CreatedByPersonID
        * * Display Name: Created By Person ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The person who created the meeting, as Task.CreatedByPersonID.`),
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
    Type: z.string().nullable().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
    Series: z.string().nullable().describe(`
        * * Field Name: Series
        * * Display Name: Series
        * * SQL Data Type: nvarchar(255)`),
    VideoProvider: z.string().nullable().describe(`
        * * Field Name: VideoProvider
        * * Display Name: Video Provider
        * * SQL Data Type: nvarchar(100)`),
    OrganizerPerson: z.string().describe(`
        * * Field Name: OrganizerPerson
        * * Display Name: Organizer Person
        * * SQL Data Type: nvarchar(201)`),
    TranscriptFile: z.string().nullable().describe(`
        * * Field Name: TranscriptFile
        * * Display Name: Transcript File
        * * SQL Data Type: nvarchar(500)`),
    CreatedByPerson: z.string().nullable().describe(`
        * * Field Name: CreatedByPerson
        * * Display Name: Created By Person
        * * SQL Data Type: nvarchar(201)`),
});

export type mjBizAppsTasksMeetingEntityType = z.infer<typeof mjBizAppsTasksMeetingSchema>;

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
        * * SQL Data Type: nvarchar(201)`),
});

export type mjBizAppsTasksTaskActivityEntityType = z.infer<typeof mjBizAppsTasksTaskActivitySchema>;

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
        * * SQL Data Type: nvarchar(201)`),
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
        * * SQL Data Type: nvarchar(201)`),
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
        * * SQL Data Type: nvarchar(201)`),
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
        * * SQL Data Type: nvarchar(201)`),
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
        * * SQL Data Type: nvarchar(201)`),
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
});

export type mjBizAppsTasksTaskEntityType = z.infer<typeof mjBizAppsTasksTaskSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Video Providers
 */
export const mjBizAppsTasksVideoProviderSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()
        * * Description: Primary key.`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(100)
        * * Description: The provider's display name. Unique.`),
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: Code
        * * SQL Data Type: nvarchar(50)
        * * Description: A stable code apps refer to: ZOOM, TEAMS or GOOGLE_MEET. Unique.`),
    DriverClass: z.string().describe(`
        * * Field Name: DriverClass
        * * Display Name: Driver Class
        * * SQL Data Type: nvarchar(255)
        * * Description: The class the driver registers with MemberJunction's class factory under VideoProviderBase.`),
    Description: z.string().nullable().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What this provider is and when to use it.`),
    IconClass: z.string().nullable().describe(`
        * * Field Name: IconClass
        * * Display Name: Icon Class
        * * SQL Data Type: nvarchar(100)
        * * Description: Font Awesome icon class shown beside the provider.`),
    CredentialID: z.string().nullable().describe(`
        * * Field Name: CredentialID
        * * Display Name: Credential ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: Credentials (vwCredentials.ID)
        * * Description: The MJ: Credentials record holding the provider's secrets, decrypted through CredentialEngine. Never stored here.`),
    Configuration: z.string().nullable().describe(`
        * * Field Name: Configuration
        * * Display Name: Configuration
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON: settings that are not secret, such as the organizer account or default meeting options.`),
    SupportsTranscripts: z.boolean().describe(`
        * * Field Name: SupportsTranscripts
        * * Display Name: Supports Transcripts
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: When true, the driver can fetch a transcript of a recorded meeting.`),
    IsDefault: z.boolean().describe(`
        * * Field Name: IsDefault
        * * Display Name: Is Default
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: When true, this is the provider a new virtual meeting uses unless its type says otherwise. One provider at most.`),
    IsActive: z.boolean().describe(`
        * * Field Name: IsActive
        * * Display Name: Is Active
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: When true, the provider is configured and offered. Ships as 0.`),
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
    Credential: z.string().nullable().describe(`
        * * Field Name: Credential
        * * Display Name: Credential
        * * SQL Data Type: nvarchar(200)`),
});

export type mjBizAppsTasksVideoProviderEntityType = z.infer<typeof mjBizAppsTasksVideoProviderSchema>;
 
 

/**
 * MJ_BizApps_Tasks: Meeting Agenda Item Types - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingAgendaItemType
 * * Base View: vwMeetingAgendaItemTypes
 * * @description A kind of agenda item: Information, Discussion, Decision, Report, Presentation, Action review, Break, or one an app adds, such as Committees' Vote. A lookup rather than a fixed list, so apps extend it.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Agenda Item Types')
export class mjBizAppsTasksMeetingAgendaItemTypeEntity extends BaseEntity<mjBizAppsTasksMeetingAgendaItemTypeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Agenda Item Types record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Agenda Item Types record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingAgendaItemTypeEntity
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
    * * Description: Primary key.
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
    * * Description: The type's display name. Unique.
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
    * * Description: A stable code apps and agenda templates refer to. Unique.
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
    * * Description: What items of this type are for.
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
    * * Description: Font Awesome icon class shown beside the item.
    */
    get IconClass(): string | null {
        return this.Get('IconClass');
    }
    set IconClass(value: string | null) {
        this.Set('IconClass', value);
    }

    /**
    * * Field Name: DefaultDurationMinutes
    * * Display Name: Default Duration Minutes
    * * SQL Data Type: int
    * * Description: How long an item of this type takes unless the agenda says otherwise. More than 0.
    */
    get DefaultDurationMinutes(): number | null {
        return this.Get('DefaultDurationMinutes');
    }
    set DefaultDurationMinutes(value: number | null) {
        this.Set('DefaultDurationMinutes', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: When false, the type is kept for existing items but not offered for new ones.
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    * * Description: Display order among types.
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
 * MJ_BizApps_Tasks: Meeting Agenda Items - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingAgendaItem
 * * Base View: vwMeetingAgendaItems
 * * @description One item on a meeting's agenda, nestable under a parent item of the same meeting, with its type, presenter, planned duration, what happened to it and what was agreed.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Agenda Items')
export class mjBizAppsTasksMeetingAgendaItemEntity extends BaseEntity<mjBizAppsTasksMeetingAgendaItemEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Agenda Items record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Agenda Items record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingAgendaItemEntity
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
    * * Description: Primary key.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: MeetingID
    * * Display Name: Meeting ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
    * * Description: The meeting the item is on the agenda of.
    */
    get MeetingID(): string {
        return this.Get('MeetingID');
    }
    set MeetingID(value: string) {
        this.Set('MeetingID', value);
    }

    /**
    * * Field Name: ParentID
    * * Display Name: Parent ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Items (vwMeetingAgendaItems.ID)
    * * Description: The item this one sits under, for a sub-item. Same meeting, no cycle.
    */
    get ParentID(): string | null {
        return this.Get('ParentID');
    }
    set ParentID(value: string | null) {
        this.Set('ParentID', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    * * Description: Order among its siblings.
    */
    get Sequence(): number {
        return this.Get('Sequence');
    }
    set Sequence(value: number) {
        this.Set('Sequence', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(500)
    * * Description: The item's title.
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
    * * Description: What the item covers, in Markdown.
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
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Item Types (vwMeetingAgendaItemTypes.ID)
    * * Description: The agenda item type: Information, Discussion, Decision, and so on.
    */
    get TypeID(): string | null {
        return this.Get('TypeID');
    }
    set TypeID(value: string | null) {
        this.Set('TypeID', value);
    }

    /**
    * * Field Name: PresenterPersonID
    * * Display Name: Presenter Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who presents the item.
    */
    get PresenterPersonID(): string | null {
        return this.Get('PresenterPersonID');
    }
    set PresenterPersonID(value: string | null) {
        this.Set('PresenterPersonID', value);
    }

    /**
    * * Field Name: DurationMinutes
    * * Display Name: Duration Minutes
    * * SQL Data Type: int
    * * Description: How long the item is planned to take. 0 or more.
    */
    get DurationMinutes(): number | null {
        return this.Get('DurationMinutes');
    }
    set DurationMinutes(value: number | null) {
        this.Set('DurationMinutes', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Planned
    * * Value List Type: List
    * * Possible Values 
    *   * Deferred
    *   * Done
    *   * InProgress
    *   * Planned
    *   * Skipped
    * * Description: Planned, InProgress, Done, Deferred or Skipped.
    */
    get Status(): 'Deferred' | 'Done' | 'InProgress' | 'Planned' | 'Skipped' {
        return this.Get('Status');
    }
    set Status(value: 'Deferred' | 'Done' | 'InProgress' | 'Planned' | 'Skipped') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: StartedAt
    * * Display Name: Started At
    * * SQL Data Type: datetimeoffset
    * * Description: When the item was started, from the live meeting.
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
    * * Description: When the item was ended.
    */
    get EndedAt(): Date | null {
        return this.Get('EndedAt');
    }
    set EndedAt(value: Date | null) {
        this.Set('EndedAt', value);
    }

    /**
    * * Field Name: Outcome
    * * Display Name: Outcome
    * * SQL Data Type: nvarchar(MAX)
    * * Description: What was agreed, in a sentence or two.
    */
    get Outcome(): string | null {
        return this.Get('Outcome');
    }
    set Outcome(value: string | null) {
        this.Set('Outcome', value);
    }

    /**
    * * Field Name: DeferredToMeetingID
    * * Display Name: Deferred To Meeting ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
    * * Description: The later meeting a deferred item moved to.
    */
    get DeferredToMeetingID(): string | null {
        return this.Get('DeferredToMeetingID');
    }
    set DeferredToMeetingID(value: string | null) {
        this.Set('DeferredToMeetingID', value);
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
    * * Field Name: Meeting
    * * Display Name: Meeting
    * * SQL Data Type: nvarchar(255)
    */
    get Meeting(): string {
        return this.Get('Meeting');
    }

    /**
    * * Field Name: Parent
    * * Display Name: Parent
    * * SQL Data Type: nvarchar(500)
    */
    get Parent(): string | null {
        return this.Get('Parent');
    }

    /**
    * * Field Name: Type
    * * Display Name: Type
    * * SQL Data Type: nvarchar(100)
    */
    get Type(): string | null {
        return this.Get('Type');
    }

    /**
    * * Field Name: PresenterPerson
    * * Display Name: Presenter Person
    * * SQL Data Type: nvarchar(201)
    */
    get PresenterPerson(): string | null {
        return this.Get('PresenterPerson');
    }

    /**
    * * Field Name: DeferredToMeeting
    * * Display Name: Deferred To Meeting
    * * SQL Data Type: nvarchar(255)
    */
    get DeferredToMeeting(): string | null {
        return this.Get('DeferredToMeeting');
    }
}


/**
 * MJ_BizApps_Tasks: Meeting Attendees - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingAttendee
 * * Base View: vwMeetingAttendees
 * * @description Someone invited to a meeting: a person, or a guest by email address; their answer to the invitation; and whether they came. A meeting has exactly one Organizer row.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Attendees')
export class mjBizAppsTasksMeetingAttendeeEntity extends BaseEntity<mjBizAppsTasksMeetingAttendeeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Attendees record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Attendees record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingAttendeeEntity
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
    * * Description: Primary key.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: MeetingID
    * * Display Name: Meeting ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
    * * Description: The meeting the attendee is invited to.
    */
    get MeetingID(): string {
        return this.Get('MeetingID');
    }
    set MeetingID(value: string) {
        this.Set('MeetingID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person invited, when they are a Person. Either this or Email is set.
    */
    get PersonID(): string | null {
        return this.Get('PersonID');
    }
    set PersonID(value: string | null) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: UserID
    * * Display Name: User ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
    * * Description: The person's MemberJunction user, when they have one, filled from the person's account. My meetings and the private-meeting filter use it.
    */
    get UserID(): string | null {
        return this.Get('UserID');
    }
    set UserID(value: string | null) {
        this.Set('UserID', value);
    }

    /**
    * * Field Name: Email
    * * Display Name: Email
    * * SQL Data Type: nvarchar(255)
    * * Description: A guest's address, or the address a person's invitation goes to.
    */
    get Email(): string | null {
        return this.Get('Email');
    }
    set Email(value: string | null) {
        this.Set('Email', value);
    }

    /**
    * * Field Name: DisplayName
    * * Display Name: Display Name
    * * SQL Data Type: nvarchar(255)
    * * Description: A guest's name.
    */
    get DisplayName(): string | null {
        return this.Get('DisplayName');
    }
    set DisplayName(value: string | null) {
        this.Set('DisplayName', value);
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Required
    * * Value List Type: List
    * * Possible Values 
    *   * Optional
    *   * Organizer
    *   * Required
    * * Description: Organizer, Required or Optional. One Organizer row per meeting, kept in step with Meeting.OrganizerPersonID.
    */
    get Role(): 'Optional' | 'Organizer' | 'Required' {
        return this.Get('Role');
    }
    set Role(value: 'Optional' | 'Organizer' | 'Required') {
        this.Set('Role', value);
    }

    /**
    * * Field Name: ResponseStatus
    * * Display Name: Response Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: None
    * * Value List Type: List
    * * Possible Values 
    *   * Accepted
    *   * Declined
    *   * None
    *   * Tentative
    * * Description: The answer to the invitation: None, Accepted, Tentative or Declined.
    */
    get ResponseStatus(): 'Accepted' | 'Declined' | 'None' | 'Tentative' {
        return this.Get('ResponseStatus');
    }
    set ResponseStatus(value: 'Accepted' | 'Declined' | 'None' | 'Tentative') {
        this.Set('ResponseStatus', value);
    }

    /**
    * * Field Name: RespondedAt
    * * Display Name: Responded At
    * * SQL Data Type: datetimeoffset
    * * Description: When the invitation was answered.
    */
    get RespondedAt(): Date | null {
        return this.Get('RespondedAt');
    }
    set RespondedAt(value: Date | null) {
        this.Set('RespondedAt', value);
    }

    /**
    * * Field Name: AttendanceStatus
    * * Display Name: Attendance Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Unknown
    * * Value List Type: List
    * * Possible Values 
    *   * Absent
    *   * Excused
    *   * Late
    *   * LeftEarly
    *   * Present
    *   * Unknown
    * * Description: Whether they came: Unknown, Present, Late, LeftEarly, Absent or Excused.
    */
    get AttendanceStatus(): 'Absent' | 'Excused' | 'Late' | 'LeftEarly' | 'Present' | 'Unknown' {
        return this.Get('AttendanceStatus');
    }
    set AttendanceStatus(value: 'Absent' | 'Excused' | 'Late' | 'LeftEarly' | 'Present' | 'Unknown') {
        this.Set('AttendanceStatus', value);
    }

    /**
    * * Field Name: JoinedAt
    * * Display Name: Joined At
    * * SQL Data Type: datetimeoffset
    * * Description: When they joined, from the live meeting or the video provider.
    */
    get JoinedAt(): Date | null {
        return this.Get('JoinedAt');
    }
    set JoinedAt(value: Date | null) {
        this.Set('JoinedAt', value);
    }

    /**
    * * Field Name: LeftAt
    * * Display Name: Left At
    * * SQL Data Type: datetimeoffset
    * * Description: When they left.
    */
    get LeftAt(): Date | null {
        return this.Get('LeftAt');
    }
    set LeftAt(value: Date | null) {
        this.Set('LeftAt', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(500)
    * * Description: A note on their attendance, such as why someone is excused.
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
    * * Field Name: Meeting
    * * Display Name: Meeting
    * * SQL Data Type: nvarchar(255)
    */
    get Meeting(): string {
        return this.Get('Meeting');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(201)
    */
    get Person(): string | null {
        return this.Get('Person');
    }

    /**
    * * Field Name: User
    * * Display Name: User
    * * SQL Data Type: nvarchar(100)
    */
    get User(): string | null {
        return this.Get('User');
    }
}


/**
 * MJ_BizApps_Tasks: Meeting Links - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingLink
 * * Base View: vwMeetingLinks
 * * @description What a meeting or a series belongs to: any record of any entity, the way TaskLink ties a task to a record. Each new occurrence of a series copies the series' links.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Links')
export class mjBizAppsTasksMeetingLinkEntity extends BaseEntity<mjBizAppsTasksMeetingLinkEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Links record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Links record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingLinkEntity
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
    * * Description: Primary key.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: MeetingID
    * * Display Name: Meeting ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
    * * Description: The meeting that belongs to the record. Either this or SeriesID is set.
    */
    get MeetingID(): string | null {
        return this.Get('MeetingID');
    }
    set MeetingID(value: string | null) {
        this.Set('MeetingID', value);
    }

    /**
    * * Field Name: SeriesID
    * * Display Name: Series ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
    * * Description: The series that belongs to the record. Either this or MeetingID is set.
    */
    get SeriesID(): string | null {
        return this.Get('SeriesID');
    }
    set SeriesID(value: string | null) {
        this.Set('SeriesID', value);
    }

    /**
    * * Field Name: EntityID
    * * Display Name: Entity ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Entities (vwEntities.ID)
    * * Description: The entity of the record the meeting belongs to.
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
    * * Description: The record's primary key, as on TaskLink.
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
    * * Description: Why the meeting belongs to the record.
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
    * * Field Name: Meeting
    * * Display Name: Meeting
    * * SQL Data Type: nvarchar(255)
    */
    get Meeting(): string | null {
        return this.Get('Meeting');
    }

    /**
    * * Field Name: Series
    * * Display Name: Series
    * * SQL Data Type: nvarchar(255)
    */
    get Series(): string | null {
        return this.Get('Series');
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
 * MJ_BizApps_Tasks: Meeting Notes - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingNote
 * * Base View: vwMeetingNotes
 * * @description The record of what happened in a meeting, or on one of its agenda items: written by a person, or drafted by AI from a transcript with the tasks it proposes.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Notes')
export class mjBizAppsTasksMeetingNoteEntity extends BaseEntity<mjBizAppsTasksMeetingNoteEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Notes record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Notes record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingNoteEntity
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
    * * Description: Primary key.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: MeetingID
    * * Display Name: Meeting ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meetings (vwMeetings.ID)
    * * Description: The meeting the note is about.
    */
    get MeetingID(): string {
        return this.Get('MeetingID');
    }
    set MeetingID(value: string) {
        this.Set('MeetingID', value);
    }

    /**
    * * Field Name: AgendaItemID
    * * Display Name: Agenda Item ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Agenda Items (vwMeetingAgendaItems.ID)
    * * Description: The agenda item the note is about, for a note on one item.
    */
    get AgendaItemID(): string | null {
        return this.Get('AgendaItemID');
    }
    set AgendaItemID(value: string | null) {
        this.Set('AgendaItemID', value);
    }

    /**
    * * Field Name: Kind
    * * Display Name: Kind
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Notes
    * * Value List Type: List
    * * Possible Values 
    *   * Decision
    *   * Notes
    *   * Summary
    * * Description: Notes, Summary or Decision.
    */
    get Kind(): 'Decision' | 'Notes' | 'Summary' {
        return this.Get('Kind');
    }
    set Kind(value: 'Decision' | 'Notes' | 'Summary') {
        this.Set('Kind', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(255)
    * * Description: The note's title.
    */
    get Title(): string | null {
        return this.Get('Title');
    }
    set Title(value: string | null) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: Body
    * * Display Name: Body
    * * SQL Data Type: nvarchar(MAX)
    * * Description: The note, in Markdown.
    */
    get Body(): string {
        return this.Get('Body');
    }
    set Body(value: string) {
        this.Set('Body', value);
    }

    /**
    * * Field Name: Source
    * * Display Name: Source
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Manual
    * * Value List Type: List
    * * Possible Values 
    *   * AI
    *   * Manual
    * * Description: Manual for a person's note; AI for a draft from a transcript.
    */
    get Source(): 'AI' | 'Manual' {
        return this.Get('Source');
    }
    set Source(value: 'AI' | 'Manual') {
        this.Set('Source', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Draft
    *   * Final
    * * Description: Draft or Final. Approving minutes is governance and stays with the app that owns it.
    */
    get Status(): 'Draft' | 'Final' {
        return this.Get('Status');
    }
    set Status(value: 'Draft' | 'Final') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: AuthorPersonID
    * * Display Name: Author Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who wrote the note, for a person's note.
    */
    get AuthorPersonID(): string | null {
        return this.Get('AuthorPersonID');
    }
    set AuthorPersonID(value: string | null) {
        this.Set('AuthorPersonID', value);
    }

    /**
    * * Field Name: AIPromptRunID
    * * Display Name: AI Prompt Run ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: AI Prompt Runs (vwAIPromptRuns.ID)
    * * Description: The MJ: AI Prompt Runs record the draft came from, for an AI note.
    */
    get AIPromptRunID(): string | null {
        return this.Get('AIPromptRunID');
    }
    set AIPromptRunID(value: string | null) {
        this.Set('AIPromptRunID', value);
    }

    /**
    * * Field Name: ProposedTasks
    * * Display Name: Proposed Tasks
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON: the action items the notes propose, each with a title, an assignee, a due date, its agenda item, and the task's ID once a person accepted it. Nothing is filed without that approval.
    */
    get ProposedTasks(): string | null {
        return this.Get('ProposedTasks');
    }
    set ProposedTasks(value: string | null) {
        this.Set('ProposedTasks', value);
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
    * * Field Name: Meeting
    * * Display Name: Meeting
    * * SQL Data Type: nvarchar(255)
    */
    get Meeting(): string {
        return this.Get('Meeting');
    }

    /**
    * * Field Name: AgendaItem
    * * Display Name: Agenda Item
    * * SQL Data Type: nvarchar(500)
    */
    get AgendaItem(): string | null {
        return this.Get('AgendaItem');
    }

    /**
    * * Field Name: AuthorPerson
    * * Display Name: Author Person
    * * SQL Data Type: nvarchar(201)
    */
    get AuthorPerson(): string | null {
        return this.Get('AuthorPerson');
    }

    /**
    * * Field Name: AIPromptRun
    * * Display Name: AI Prompt Run
    * * SQL Data Type: nvarchar(255)
    */
    get AIPromptRun(): string | null {
        return this.Get('AIPromptRun');
    }
}


/**
 * MJ_BizApps_Tasks: Meeting Series - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingSeries
 * * Base View: vwMeetingSeries
 * * @description A recurring meeting. Its occurrences are real Meeting rows, made ahead of time up to a horizon; each keeps its own agenda and attendance, and one can move or be cancelled without touching the rest.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Series')
export class mjBizAppsTasksMeetingSeriesEntity extends BaseEntity<mjBizAppsTasksMeetingSeriesEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Series record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Series record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingSeriesEntity
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
    * * Description: Primary key.
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
    * * Description: The series' title. Each new occurrence starts with it.
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
    * * Description: The series' purpose, in Markdown. Each new occurrence starts with it.
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
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Types (vwMeetingTypes.ID)
    * * Description: The meeting type each occurrence is made from.
    */
    get TypeID(): string | null {
        return this.Get('TypeID');
    }
    set TypeID(value: string | null) {
        this.Set('TypeID', value);
    }

    /**
    * * Field Name: OrganizerPersonID
    * * Display Name: Organizer Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who organizes the series. Each occurrence starts with them as its organizer.
    */
    get OrganizerPersonID(): string {
        return this.Get('OrganizerPersonID');
    }
    set OrganizerPersonID(value: string) {
        this.Set('OrganizerPersonID', value);
    }

    /**
    * * Field Name: RecurrenceRule
    * * Display Name: Recurrence Rule
    * * SQL Data Type: nvarchar(500)
    * * Description: An RFC 5545 RRULE value, such as FREQ=WEEKLY;BYDAY=TU. Its UNTIL or COUNT ends the series.
    */
    get RecurrenceRule(): string {
        return this.Get('RecurrenceRule');
    }
    set RecurrenceRule(value: string) {
        this.Set('RecurrenceRule', value);
    }

    /**
    * * Field Name: TimeZone
    * * Display Name: Time Zone
    * * SQL Data Type: nvarchar(64)
    * * Description: The IANA time zone the rule is expanded in, such as America/Chicago, so a 9:00 meeting stays at 9:00 across daylight-saving changes.
    */
    get TimeZone(): string {
        return this.Get('TimeZone');
    }
    set TimeZone(value: string) {
        this.Set('TimeZone', value);
    }

    /**
    * * Field Name: FirstStartsAt
    * * Display Name: First Starts At
    * * SQL Data Type: datetimeoffset
    * * Description: The rule's DTSTART: when the first occurrence starts.
    */
    get FirstStartsAt(): Date {
        return this.Get('FirstStartsAt');
    }
    set FirstStartsAt(value: Date) {
        this.Set('FirstStartsAt', value);
    }

    /**
    * * Field Name: DurationMinutes
    * * Display Name: Duration Minutes
    * * SQL Data Type: int
    * * Description: How long each occurrence lasts. More than 0.
    */
    get DurationMinutes(): number {
        return this.Get('DurationMinutes');
    }
    set DurationMinutes(value: number) {
        this.Set('DurationMinutes', value);
    }

    /**
    * * Field Name: LocationType
    * * Display Name: Location Type
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Virtual
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
    * * Description: The location each new occurrence starts with: Virtual, InPerson, Hybrid or Phone.
    */
    get LocationType(): 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual' {
        return this.Get('LocationType');
    }
    set LocationType(value: 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual') {
        this.Set('LocationType', value);
    }

    /**
    * * Field Name: Location
    * * Display Name: Location
    * * SQL Data Type: nvarchar(500)
    * * Description: The room or address each new occurrence starts with.
    */
    get Location(): string | null {
        return this.Get('Location');
    }
    set Location(value: string | null) {
        this.Set('Location', value);
    }

    /**
    * * Field Name: VideoProviderID
    * * Display Name: Video Provider ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
    * * Description: The video provider each new virtual occurrence is hosted on.
    */
    get VideoProviderID(): string | null {
        return this.Get('VideoProviderID');
    }
    set VideoProviderID(value: string | null) {
        this.Set('VideoProviderID', value);
    }

    /**
    * * Field Name: Visibility
    * * Display Name: Visibility
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Standard
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
    * * Description: The visibility each new occurrence starts with: Standard, or Private for its attendees only.
    */
    get Visibility(): 'Private' | 'Standard' {
        return this.Get('Visibility');
    }
    set Visibility(value: 'Private' | 'Standard') {
        this.Set('Visibility', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Active
    * * Value List Type: List
    * * Possible Values 
    *   * Active
    *   * Cancelled
    *   * Ended
    * * Description: Active while occurrences are still made; Ended once the rule has run out; Cancelled when the series was stopped.
    */
    get Status(): 'Active' | 'Cancelled' | 'Ended' {
        return this.Get('Status');
    }
    set Status(value: 'Active' | 'Cancelled' | 'Ended') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: MaterializedThrough
    * * Display Name: Materialized Through
    * * SQL Data Type: datetimeoffset
    * * Description: Occurrences exist up to this point in time. The scheduled job and a save extend it.
    */
    get MaterializedThrough(): Date | null {
        return this.Get('MaterializedThrough');
    }
    set MaterializedThrough(value: Date | null) {
        this.Set('MaterializedThrough', value);
    }

    /**
    * * Field Name: CreatedByPersonID
    * * Display Name: Created By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who created the series, as Task.CreatedByPersonID.
    */
    get CreatedByPersonID(): string | null {
        return this.Get('CreatedByPersonID');
    }
    set CreatedByPersonID(value: string | null) {
        this.Set('CreatedByPersonID', value);
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
    * * Field Name: Type
    * * Display Name: Type
    * * SQL Data Type: nvarchar(100)
    */
    get Type(): string | null {
        return this.Get('Type');
    }

    /**
    * * Field Name: OrganizerPerson
    * * Display Name: Organizer Person
    * * SQL Data Type: nvarchar(201)
    */
    get OrganizerPerson(): string {
        return this.Get('OrganizerPerson');
    }

    /**
    * * Field Name: VideoProvider
    * * Display Name: Video Provider
    * * SQL Data Type: nvarchar(100)
    */
    get VideoProvider(): string | null {
        return this.Get('VideoProvider');
    }

    /**
    * * Field Name: CreatedByPerson
    * * Display Name: Created By Person
    * * SQL Data Type: nvarchar(201)
    */
    get CreatedByPerson(): string | null {
        return this.Get('CreatedByPerson');
    }
}


/**
 * MJ_BizApps_Tasks: Meeting Series Attendees - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingSeriesAttendee
 * * Base View: vwMeetingSeriesAttendees
 * * @description Who each new occurrence of a series invites: a person, or a guest by email address. The organizer comes from the series itself.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Series Attendees')
export class mjBizAppsTasksMeetingSeriesAttendeeEntity extends BaseEntity<mjBizAppsTasksMeetingSeriesAttendeeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Series Attendees record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Series Attendees record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingSeriesAttendeeEntity
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
    * * Description: Primary key.
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: SeriesID
    * * Display Name: Series ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
    * * Description: The series each new occurrence of which invites this attendee.
    */
    get SeriesID(): string {
        return this.Get('SeriesID');
    }
    set SeriesID(value: string) {
        this.Set('SeriesID', value);
    }

    /**
    * * Field Name: PersonID
    * * Display Name: Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person invited, when they are a Person. Either this or Email is set.
    */
    get PersonID(): string | null {
        return this.Get('PersonID');
    }
    set PersonID(value: string | null) {
        this.Set('PersonID', value);
    }

    /**
    * * Field Name: UserID
    * * Display Name: User ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Users (vwUsers.ID)
    * * Description: The person's MemberJunction user, when they have one, filled from the person's account.
    */
    get UserID(): string | null {
        return this.Get('UserID');
    }
    set UserID(value: string | null) {
        this.Set('UserID', value);
    }

    /**
    * * Field Name: Email
    * * Display Name: Email
    * * SQL Data Type: nvarchar(255)
    * * Description: A guest's address, or the address a person's invitation goes to.
    */
    get Email(): string | null {
        return this.Get('Email');
    }
    set Email(value: string | null) {
        this.Set('Email', value);
    }

    /**
    * * Field Name: DisplayName
    * * Display Name: Display Name
    * * SQL Data Type: nvarchar(255)
    * * Description: A guest's name.
    */
    get DisplayName(): string | null {
        return this.Get('DisplayName');
    }
    set DisplayName(value: string | null) {
        this.Set('DisplayName', value);
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Required
    * * Value List Type: List
    * * Possible Values 
    *   * Optional
    *   * Required
    * * Description: Required or Optional. The organizer is the series' own.
    */
    get Role(): 'Optional' | 'Required' {
        return this.Get('Role');
    }
    set Role(value: 'Optional' | 'Required') {
        this.Set('Role', value);
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
    * * Field Name: Series
    * * Display Name: Series
    * * SQL Data Type: nvarchar(255)
    */
    get Series(): string {
        return this.Get('Series');
    }

    /**
    * * Field Name: Person
    * * Display Name: Person
    * * SQL Data Type: nvarchar(201)
    */
    get Person(): string | null {
        return this.Get('Person');
    }

    /**
    * * Field Name: User
    * * Display Name: User
    * * SQL Data Type: nvarchar(100)
    */
    get User(): string | null {
        return this.Get('User');
    }
}


/**
 * MJ_BizApps_Tasks: Meeting Types - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: MeetingType
 * * Base View: vwMeetingTypes
 * * @description A kind of meeting: General, One-on-one, Team, Client, Review, or one an app adds. Carries the defaults a new meeting of the type starts with and its agenda template.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meeting Types')
export class mjBizAppsTasksMeetingTypeEntity extends BaseEntity<mjBizAppsTasksMeetingTypeEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meeting Types record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meeting Types record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingTypeEntity
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
    * * Description: Primary key.
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
    * * Description: The type's display name. Unique.
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
    * * Description: A stable code apps refer to, as TaskType.Code. Unique.
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
    * * Description: What meetings of this type are for.
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
    * * Description: Font Awesome icon class shown beside the type.
    */
    get IconClass(): string | null {
        return this.Get('IconClass');
    }
    set IconClass(value: string | null) {
        this.Set('IconClass', value);
    }

    /**
    * * Field Name: DefaultDurationMinutes
    * * Display Name: Default Duration Minutes
    * * SQL Data Type: int
    * * Description: How long a new meeting of this type lasts unless the organizer says otherwise. More than 0.
    */
    get DefaultDurationMinutes(): number | null {
        return this.Get('DefaultDurationMinutes');
    }
    set DefaultDurationMinutes(value: number | null) {
        this.Set('DefaultDurationMinutes', value);
    }

    /**
    * * Field Name: DefaultLocationType
    * * Display Name: Default Location Type
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
    * * Description: The location a new meeting of this type starts with: Virtual, InPerson, Hybrid or Phone.
    */
    get DefaultLocationType(): 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual' | null {
        return this.Get('DefaultLocationType');
    }
    set DefaultLocationType(value: 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual' | null) {
        this.Set('DefaultLocationType', value);
    }

    /**
    * * Field Name: DefaultVideoProviderID
    * * Display Name: Default Video Provider ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
    * * Description: The video provider a new virtual meeting of this type is hosted on.
    */
    get DefaultVideoProviderID(): string | null {
        return this.Get('DefaultVideoProviderID');
    }
    set DefaultVideoProviderID(value: string | null) {
        this.Set('DefaultVideoProviderID', value);
    }

    /**
    * * Field Name: DefaultVisibility
    * * Display Name: Default Visibility
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
    * * Description: The visibility a new meeting of this type starts with: Standard or Private.
    */
    get DefaultVisibility(): 'Private' | 'Standard' | null {
        return this.Get('DefaultVisibility');
    }
    set DefaultVisibility(value: 'Private' | 'Standard' | null) {
        this.Set('DefaultVisibility', value);
    }

    /**
    * * Field Name: AgendaTemplate
    * * Display Name: Agenda Template
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON: the agenda a new meeting of this type starts with, as items with a title, an agenda item type code, a duration in minutes and sub-items.
    */
    get AgendaTemplate(): string | null {
        return this.Get('AgendaTemplate');
    }
    set AgendaTemplate(value: string | null) {
        this.Set('AgendaTemplate', value);
    }

    /**
    * * Field Name: NotesPromptID
    * * Display Name: Notes Prompt ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: AI Prompts (vwAIPrompts.ID)
    * * Description: The MJ: AI Prompts record that drafts notes from a transcript for this type, instead of the shipped prompt.
    */
    get NotesPromptID(): string | null {
        return this.Get('NotesPromptID');
    }
    set NotesPromptID(value: string | null) {
        this.Set('NotesPromptID', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: When false, the type is kept for existing meetings but not offered for new ones.
    */
    get IsActive(): boolean {
        return this.Get('IsActive');
    }
    set IsActive(value: boolean) {
        this.Set('IsActive', value);
    }

    /**
    * * Field Name: Sequence
    * * Display Name: Sequence
    * * SQL Data Type: int
    * * Default Value: 100
    * * Description: Display order among types.
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
    * * Field Name: DefaultVideoProvider
    * * Display Name: Default Video Provider
    * * SQL Data Type: nvarchar(100)
    */
    get DefaultVideoProvider(): string | null {
        return this.Get('DefaultVideoProvider');
    }

    /**
    * * Field Name: NotesPrompt
    * * Display Name: Notes Prompt
    * * SQL Data Type: nvarchar(255)
    */
    get NotesPrompt(): string | null {
        return this.Get('NotesPrompt');
    }
}


/**
 * MJ_BizApps_Tasks: Meetings - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: Meeting
 * * Base View: vwMeetings
 * * @description One meeting: a single occurrence with its own time, place, attendees, agenda, notes and follow-ups. An occurrence of a series points at its series and keeps the series' original slot as its name.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Meetings')
export class mjBizAppsTasksMeetingEntity extends BaseEntity<mjBizAppsTasksMeetingEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Meetings record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Meetings record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksMeetingEntity
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
    * * Description: Primary key.
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
    * * Description: The meeting's title, as Task.Name is a task's.
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
    * * Description: The meeting's purpose, in Markdown.
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
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Types (vwMeetingTypes.ID)
    * * Description: The meeting type it was made from, which gave its defaults and agenda template.
    */
    get TypeID(): string | null {
        return this.Get('TypeID');
    }
    set TypeID(value: string | null) {
        this.Set('TypeID', value);
    }

    /**
    * * Field Name: SeriesID
    * * Display Name: Series ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Meeting Series (vwMeetingSeries.ID)
    * * Description: The series this meeting is an occurrence of, when it is one.
    */
    get SeriesID(): string | null {
        return this.Get('SeriesID');
    }
    set SeriesID(value: string | null) {
        this.Set('SeriesID', value);
    }

    /**
    * * Field Name: OccurrenceStartsAt
    * * Display Name: Occurrence Starts At
    * * SQL Data Type: datetimeoffset
    * * Description: The series' original slot for this occurrence. It names the occurrence after it moves, so the series does not make it again. Set with SeriesID, empty without it.
    */
    get OccurrenceStartsAt(): Date | null {
        return this.Get('OccurrenceStartsAt');
    }
    set OccurrenceStartsAt(value: Date | null) {
        this.Set('OccurrenceStartsAt', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Scheduled
    * * Value List Type: List
    * * Possible Values 
    *   * Cancelled
    *   * Completed
    *   * Draft
    *   * InProgress
    *   * Postponed
    *   * Scheduled
    * * Description: Draft, Scheduled, Postponed, InProgress, Completed or Cancelled. The server moves it forward: Draft to Scheduled to InProgress to Completed; Scheduled and Postponed either way; anything but Completed may be Cancelled.
    */
    get Status(): 'Cancelled' | 'Completed' | 'Draft' | 'InProgress' | 'Postponed' | 'Scheduled' {
        return this.Get('Status');
    }
    set Status(value: 'Cancelled' | 'Completed' | 'Draft' | 'InProgress' | 'Postponed' | 'Scheduled') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: StartsAt
    * * Display Name: Starts At
    * * SQL Data Type: datetimeoffset
    * * Description: When the meeting is planned to start.
    */
    get StartsAt(): Date {
        return this.Get('StartsAt');
    }
    set StartsAt(value: Date) {
        this.Set('StartsAt', value);
    }

    /**
    * * Field Name: EndsAt
    * * Display Name: Ends At
    * * SQL Data Type: datetimeoffset
    * * Description: When the meeting is planned to end. Later than StartsAt.
    */
    get EndsAt(): Date {
        return this.Get('EndsAt');
    }
    set EndsAt(value: Date) {
        this.Set('EndsAt', value);
    }

    /**
    * * Field Name: TimeZone
    * * Display Name: Time Zone
    * * SQL Data Type: nvarchar(64)
    * * Description: The IANA time zone the meeting is planned in, such as America/Chicago. Display and recurrence use it. Defaults from the organizer's setting, else the business time zone.
    */
    get TimeZone(): string {
        return this.Get('TimeZone');
    }
    set TimeZone(value: string) {
        this.Set('TimeZone', value);
    }

    /**
    * * Field Name: LocationType
    * * Display Name: Location Type
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Virtual
    * * Value List Type: List
    * * Possible Values 
    *   * Hybrid
    *   * InPerson
    *   * Phone
    *   * Virtual
    * * Description: Virtual, InPerson, Hybrid or Phone.
    */
    get LocationType(): 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual' {
        return this.Get('LocationType');
    }
    set LocationType(value: 'Hybrid' | 'InPerson' | 'Phone' | 'Virtual') {
        this.Set('LocationType', value);
    }

    /**
    * * Field Name: Location
    * * Display Name: Location
    * * SQL Data Type: nvarchar(500)
    * * Description: A room or an address, for an in-person or hybrid meeting.
    */
    get Location(): string | null {
        return this.Get('Location');
    }
    set Location(value: string | null) {
        this.Set('Location', value);
    }

    /**
    * * Field Name: VideoProviderID
    * * Display Name: Video Provider ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Video Providers (vwVideoProviders.ID)
    * * Description: The video provider the meeting is hosted on, for a virtual or hybrid meeting.
    */
    get VideoProviderID(): string | null {
        return this.Get('VideoProviderID');
    }
    set VideoProviderID(value: string | null) {
        this.Set('VideoProviderID', value);
    }

    /**
    * * Field Name: VideoMeetingID
    * * Display Name: Video Meeting ID
    * * SQL Data Type: nvarchar(255)
    * * Description: The provider's own ID for the meeting, kept to update or delete it there.
    */
    get VideoMeetingID(): string | null {
        return this.Get('VideoMeetingID');
    }
    set VideoMeetingID(value: string | null) {
        this.Set('VideoMeetingID', value);
    }

    /**
    * * Field Name: VideoJoinURL
    * * Display Name: Video Join URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: The link attendees join by, from the provider or typed in.
    */
    get VideoJoinURL(): string | null {
        return this.Get('VideoJoinURL');
    }
    set VideoJoinURL(value: string | null) {
        this.Set('VideoJoinURL', value);
    }

    /**
    * * Field Name: DialInDetails
    * * Display Name: Dial In Details
    * * SQL Data Type: nvarchar(1000)
    * * Description: Phone numbers and access codes for joining by phone.
    */
    get DialInDetails(): string | null {
        return this.Get('DialInDetails');
    }
    set DialInDetails(value: string | null) {
        this.Set('DialInDetails', value);
    }

    /**
    * * Field Name: OrganizerPersonID
    * * Display Name: Organizer Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who organizes the meeting. Their calendar holds its event, and the meeting always has their attendee row.
    */
    get OrganizerPersonID(): string {
        return this.Get('OrganizerPersonID');
    }
    set OrganizerPersonID(value: string) {
        this.Set('OrganizerPersonID', value);
    }

    /**
    * * Field Name: Visibility
    * * Display Name: Visibility
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Standard
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
    * * Description: Standard: readable by anyone who reads meetings. Private: readable only by its attendees, the organizer included.
    */
    get Visibility(): 'Private' | 'Standard' {
        return this.Get('Visibility');
    }
    set Visibility(value: 'Private' | 'Standard') {
        this.Set('Visibility', value);
    }

    /**
    * * Field Name: ActualStartedAt
    * * Display Name: Actual Started At
    * * SQL Data Type: datetimeoffset
    * * Description: When the live meeting was started.
    */
    get ActualStartedAt(): Date | null {
        return this.Get('ActualStartedAt');
    }
    set ActualStartedAt(value: Date | null) {
        this.Set('ActualStartedAt', value);
    }

    /**
    * * Field Name: ActualEndedAt
    * * Display Name: Actual Ended At
    * * SQL Data Type: datetimeoffset
    * * Description: When the live meeting was ended.
    */
    get ActualEndedAt(): Date | null {
        return this.Get('ActualEndedAt');
    }
    set ActualEndedAt(value: Date | null) {
        this.Set('ActualEndedAt', value);
    }

    /**
    * * Field Name: CancelledAt
    * * Display Name: Cancelled At
    * * SQL Data Type: datetimeoffset
    * * Description: When the meeting was cancelled. Stamped by the server with the status.
    */
    get CancelledAt(): Date | null {
        return this.Get('CancelledAt');
    }
    set CancelledAt(value: Date | null) {
        this.Set('CancelledAt', value);
    }

    /**
    * * Field Name: CancellationReason
    * * Display Name: Cancellation Reason
    * * SQL Data Type: nvarchar(500)
    * * Description: Why the meeting was cancelled, for its attendees.
    */
    get CancellationReason(): string | null {
        return this.Get('CancellationReason');
    }
    set CancellationReason(value: string | null) {
        this.Set('CancellationReason', value);
    }

    /**
    * * Field Name: VideoRecordingURL
    * * Display Name: Video Recording URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: Where the provider's recording can be watched.
    */
    get VideoRecordingURL(): string | null {
        return this.Get('VideoRecordingURL');
    }
    set VideoRecordingURL(value: string | null) {
        this.Set('VideoRecordingURL', value);
    }

    /**
    * * Field Name: TranscriptFileID
    * * Display Name: Transcript File ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Files (vwFiles.ID)
    * * Description: The MJ: Files record holding the transcript, uploaded by a person or saved there by the provider's driver. A transcript is a file in MemberJunction's storage, never a URL a user typed.
    */
    get TranscriptFileID(): string | null {
        return this.Get('TranscriptFileID');
    }
    set TranscriptFileID(value: string | null) {
        this.Set('TranscriptFileID', value);
    }

    /**
    * * Field Name: CreatedByPersonID
    * * Display Name: Created By Person ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
    * * Description: The person who created the meeting, as Task.CreatedByPersonID.
    */
    get CreatedByPersonID(): string | null {
        return this.Get('CreatedByPersonID');
    }
    set CreatedByPersonID(value: string | null) {
        this.Set('CreatedByPersonID', value);
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
    * * Field Name: Type
    * * Display Name: Type
    * * SQL Data Type: nvarchar(100)
    */
    get Type(): string | null {
        return this.Get('Type');
    }

    /**
    * * Field Name: Series
    * * Display Name: Series
    * * SQL Data Type: nvarchar(255)
    */
    get Series(): string | null {
        return this.Get('Series');
    }

    /**
    * * Field Name: VideoProvider
    * * Display Name: Video Provider
    * * SQL Data Type: nvarchar(100)
    */
    get VideoProvider(): string | null {
        return this.Get('VideoProvider');
    }

    /**
    * * Field Name: OrganizerPerson
    * * Display Name: Organizer Person
    * * SQL Data Type: nvarchar(201)
    */
    get OrganizerPerson(): string {
        return this.Get('OrganizerPerson');
    }

    /**
    * * Field Name: TranscriptFile
    * * Display Name: Transcript File
    * * SQL Data Type: nvarchar(500)
    */
    get TranscriptFile(): string | null {
        return this.Get('TranscriptFile');
    }

    /**
    * * Field Name: CreatedByPerson
    * * Display Name: Created By Person
    * * SQL Data Type: nvarchar(201)
    */
    get CreatedByPerson(): string | null {
        return this.Get('CreatedByPerson');
    }
}


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
    * * SQL Data Type: nvarchar(201)
    */
    get Person(): string | null {
        return this.Get('Person');
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
    * * SQL Data Type: nvarchar(201)
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
    * * SQL Data Type: nvarchar(201)
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
    * * SQL Data Type: nvarchar(201)
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
    * * SQL Data Type: nvarchar(201)
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
    	if (this.TaskID != null && this.DependsOnTaskID != null && this.TaskID === this.DependsOnTaskID) {
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
    	if (this.ItemID != null && this.DependsOnItemID != null && this.ItemID === this.DependsOnItemID) {
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
    * * SQL Data Type: nvarchar(201)
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
}


/**
 * MJ_BizApps_Tasks: Video Providers - strongly typed entity sub-class
 * * Schema: __mj_BizAppsTasks
 * * Base Table: VideoProvider
 * * Base View: vwVideoProviders
 * * @description A video-conferencing provider a meeting can be hosted on: Zoom, Teams or Google Meet. Its secrets live in MemberJunction's credential store; the row holds only the driver and non-secret settings. Ships inactive until a host configures it.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Video Providers')
export class mjBizAppsTasksVideoProviderEntity extends BaseEntity<mjBizAppsTasksVideoProviderEntityType> {
    /**
    * Loads the MJ_BizApps_Tasks: Video Providers record from the database
    * @param ID: string - primary key value to load the MJ_BizApps_Tasks: Video Providers record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof mjBizAppsTasksVideoProviderEntity
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
    * * Description: Primary key.
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
    * * Description: The provider's display name. Unique.
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
    * * Description: A stable code apps refer to: ZOOM, TEAMS or GOOGLE_MEET. Unique.
    */
    get Code(): string {
        return this.Get('Code');
    }
    set Code(value: string) {
        this.Set('Code', value);
    }

    /**
    * * Field Name: DriverClass
    * * Display Name: Driver Class
    * * SQL Data Type: nvarchar(255)
    * * Description: The class the driver registers with MemberJunction's class factory under VideoProviderBase.
    */
    get DriverClass(): string {
        return this.Get('DriverClass');
    }
    set DriverClass(value: string) {
        this.Set('DriverClass', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    * * Description: What this provider is and when to use it.
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
    * * Description: Font Awesome icon class shown beside the provider.
    */
    get IconClass(): string | null {
        return this.Get('IconClass');
    }
    set IconClass(value: string | null) {
        this.Set('IconClass', value);
    }

    /**
    * * Field Name: CredentialID
    * * Display Name: Credential ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: MJ: Credentials (vwCredentials.ID)
    * * Description: The MJ: Credentials record holding the provider's secrets, decrypted through CredentialEngine. Never stored here.
    */
    get CredentialID(): string | null {
        return this.Get('CredentialID');
    }
    set CredentialID(value: string | null) {
        this.Set('CredentialID', value);
    }

    /**
    * * Field Name: Configuration
    * * Display Name: Configuration
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON: settings that are not secret, such as the organizer account or default meeting options.
    */
    get Configuration(): string | null {
        return this.Get('Configuration');
    }
    set Configuration(value: string | null) {
        this.Set('Configuration', value);
    }

    /**
    * * Field Name: SupportsTranscripts
    * * Display Name: Supports Transcripts
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: When true, the driver can fetch a transcript of a recorded meeting.
    */
    get SupportsTranscripts(): boolean {
        return this.Get('SupportsTranscripts');
    }
    set SupportsTranscripts(value: boolean) {
        this.Set('SupportsTranscripts', value);
    }

    /**
    * * Field Name: IsDefault
    * * Display Name: Is Default
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: When true, this is the provider a new virtual meeting uses unless its type says otherwise. One provider at most.
    */
    get IsDefault(): boolean {
        return this.Get('IsDefault');
    }
    set IsDefault(value: boolean) {
        this.Set('IsDefault', value);
    }

    /**
    * * Field Name: IsActive
    * * Display Name: Is Active
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: When true, the provider is configured and offered. Ships as 0.
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
    * * Field Name: Credential
    * * Display Name: Credential
    * * SQL Data Type: nvarchar(200)
    */
    get Credential(): string | null {
        return this.Get('Credential');
    }
}
