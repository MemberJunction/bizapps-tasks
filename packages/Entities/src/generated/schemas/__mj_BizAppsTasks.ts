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
    Meeting: z.string().nullable().describe(`
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
        * * SQL Data Type: nvarchar(250)`),
    DeferredToMeeting: z.string().nullable().describe(`
        * * Field Name: DeferredToMeeting
        * * Display Name: Deferred To Meeting
        * * SQL Data Type: nvarchar(255)`),
    RootParentID: z.string().nullable().describe(`
        * * Field Name: RootParentID
        * * Display Name: Root Parent
        * * SQL Data Type: uniqueidentifier`),
    ParentIDDepth: z.number().nullable().describe(`
        * * Field Name: ParentIDDepth
        * * Display Name: Depth
        * * SQL Data Type: int`),
    ParentIDPath: z.string().nullable().describe(`
        * * Field Name: ParentIDPath
        * * Display Name: Path
        * * SQL Data Type: nvarchar(MAX)`),
    ParentIDIsLeaf: z.boolean().nullable().describe(`
        * * Field Name: ParentIDIsLeaf
        * * Display Name: Is Leaf
        * * SQL Data Type: bit`),
    ParentIDChildCount: z.number().nullable().describe(`
        * * Field Name: ParentIDChildCount
        * * Display Name: Child Count
        * * SQL Data Type: int`),
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
    Meeting: z.string().nullable().describe(`
        * * Field Name: Meeting
        * * Display Name: Meeting
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
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
    Entity: z.string().nullable().describe(`
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
    Meeting: z.string().nullable().describe(`
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
        * * SQL Data Type: nvarchar(250)`),
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
    OrganizerPerson: z.string().nullable().describe(`
        * * Field Name: OrganizerPerson
        * * Display Name: Organizer Person
        * * SQL Data Type: nvarchar(250)`),
    VideoProvider: z.string().nullable().describe(`
        * * Field Name: VideoProvider
        * * Display Name: Video Provider
        * * SQL Data Type: nvarchar(100)`),
    CreatedByPerson: z.string().nullable().describe(`
        * * Field Name: CreatedByPerson
        * * Display Name: Created By Person
        * * SQL Data Type: nvarchar(250)`),
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
    Series: z.string().nullable().describe(`
        * * Field Name: Series
        * * Display Name: Series
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
        * * Field Name: Person
        * * Display Name: Person
        * * SQL Data Type: nvarchar(250)`),
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
    OrganizerPerson: z.string().nullable().describe(`
        * * Field Name: OrganizerPerson
        * * Display Name: Organizer Person
        * * SQL Data Type: nvarchar(250)`),
    TranscriptFile: z.string().nullable().describe(`
        * * Field Name: TranscriptFile
        * * Display Name: Transcript File
        * * SQL Data Type: nvarchar(500)`),
    CreatedByPerson: z.string().nullable().describe(`
        * * Field Name: CreatedByPerson
        * * Display Name: Created By Person
        * * SQL Data Type: nvarchar(250)`),
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
    Task: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    AssigneeEntity: z.string().nullable().describe(`
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
    OrganizationID: z.string().nullable().describe(`
        * * Field Name: OrganizationID
        * * Display Name: Organization
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: Organizations (vwOrganizations.ID)
        * * Description: Optional scoping Organization for this category. NULL indicates a shared/global category available across all organizations.`),
    Parent: z.string().nullable().describe(`
        * * Field Name: Parent
        * * Display Name: Parent
        * * SQL Data Type: nvarchar(255)`),
    Organization: z.string().nullable().describe(`
        * * Field Name: Organization
        * * Display Name: Organization Name
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
        * * Description: The measurable task or deliverable this check-in updates.`),
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
    Task: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Person: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Outcome: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    DependsOnTask: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Entity: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    NotifiedUser: z.string().nullable().describe(`
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task
        * * SQL Data Type: nvarchar(255)`),
    Tag: z.string().nullable().describe(`
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
    Item: z.string().nullable().describe(`
        * * Field Name: Item
        * * Display Name: Item
        * * SQL Data Type: nvarchar(255)`),
    DependsOnItem: z.string().nullable().describe(`
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
    Item: z.string().nullable().describe(`
        * * Field Name: Item
        * * Display Name: Item
        * * SQL Data Type: nvarchar(255)`),
    Role: z.string().nullable().describe(`
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
    Template: z.string().nullable().describe(`
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
    OrganizationID: z.string().nullable().describe(`
        * * Field Name: OrganizationID
        * * Display Name: Organization
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: Organizations (vwOrganizations.ID)
        * * Description: Optional default Organization for tasks instantiated from this template. NULL indicates a global reusable playbook whose target Organization can be supplied at launch time.`),
    Category: z.string().nullable().describe(`
        * * Field Name: Category
        * * Display Name: Category
        * * SQL Data Type: nvarchar(255)`),
    Type: z.string().nullable().describe(`
        * * Field Name: Type
        * * Display Name: Type
        * * SQL Data Type: nvarchar(100)`),
    Organization: z.string().nullable().describe(`
        * * Field Name: Organization
        * * Display Name: Organization Name
        * * SQL Data Type: nvarchar(255)`),
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
    TaskType: z.string().nullable().describe(`
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
    ExtensionEntity: z.string().nullable().describe(`
        * * Field Name: ExtensionEntity
        * * Display Name: Extension Entity
        * * SQL Data Type: nvarchar(255)
        * * Description: Optional MemberJunction Entity name (e.g. MJ_BizApps_Tasks_GitHub: Git Hub Issue Tasks, MJ_BizApps_Planning: Priority Tasks) of the disjoint IS-A child of MJ_BizApps_Tasks: Tasks provisioned for tasks of this type. Read declaratively by Task SubtypeSelector (TypeID.ExtensionEntity).`),
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
        * * Description: Qualitative health status for measurable or tracked tasks: OnTrack, AtRisk, OffTrack, Completed, or Paused.`),
    ConfidenceScore: z.number().nullable().describe(`
        * * Field Name: ConfidenceScore
        * * Display Name: Confidence Score
        * * SQL Data Type: int
        * * Description: Owner confidence score (0-100) that this task will achieve its target or deliverable on time.`),
    BaselineValue: z.number().nullable().describe(`
        * * Field Name: BaselineValue
        * * Display Name: Baseline Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Starting baseline value for a measurable task or quantitative deliverable.`),
    TargetValue: z.number().nullable().describe(`
        * * Field Name: TargetValue
        * * Display Name: Target Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Target goal value for a measurable task or quantitative deliverable.`),
    CurrentValue: z.number().nullable().describe(`
        * * Field Name: CurrentValue
        * * Display Name: Current Value
        * * SQL Data Type: decimal(18, 4)
        * * Description: Latest actual measured value for a measurable task or deliverable, updated automatically by TaskCheckIn records.`),
    UnitOfMeasure: z.string().nullable().describe(`
        * * Field Name: UnitOfMeasure
        * * Display Name: Unit of Measure
        * * SQL Data Type: nvarchar(50)
        * * Description: Unit of measure for BaselineValue, TargetValue, and CurrentValue on measurable tasks (e.g., %, USD, Hours, Days, Items, NPS).`),
    MetricDirection: z.union([z.literal('Decrease'), z.literal('Increase'), z.literal('Maintain')]).nullable().describe(`
        * * Field Name: MetricDirection
        * * Display Name: Metric Direction
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Decrease
    *   * Increase
    *   * Maintain
        * * Description: Direction of improvement for quantitative task metrics: Increase, Decrease, or Maintain.`),
    RollupWeight: z.number().describe(`
        * * Field Name: RollupWeight
        * * Display Name: Rollup Weight
        * * SQL Data Type: decimal(8, 2)
        * * Default Value: 1.00
        * * Description: Relative weight (default 1.00) when rolling up child task progress, health, and confidence into a parent task.`),
    PlanningPeriod: z.string().nullable().describe(`
        * * Field Name: PlanningPeriod
        * * Display Name: Planning Period
        * * SQL Data Type: nvarchar(50)
        * * Description: Tracking period or cycle identifier for scheduled or measurable tasks (e.g., 2026-Q4, FY2027, H1-2026).`),
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
        * * Description: Expected progress check-in frequency for this task: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.`),
    LastCheckInAt: z.date().nullable().describe(`
        * * Field Name: LastCheckInAt
        * * Display Name: Last Check-In At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the most recent Task Check In progress update was recorded for this task.`),
    NextCheckInDueAt: z.date().nullable().describe(`
        * * Field Name: NextCheckInDueAt
        * * Display Name: Next Check-In Due At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when the next progress check-in is due based on CheckInCadence; used for scheduled check-in reminders.`),
    OrganizationID: z.string().nullable().describe(`
        * * Field Name: OrganizationID
        * * Display Name: Organization
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: Organizations (vwOrganizations.ID)
        * * Description: Optional owning or scoping Organization for this task (supports both internal legal entities mirrored from MJ: Companies via Organization.LinkedCompanyID and external client/partner organizations). Child sub-tasks inherit their parent OrganizationID by default.`),
    Visibility: z.union([z.literal('Private'), z.literal('Standard')]).describe(`
        * * Field Name: Visibility
        * * Display Name: Visibility
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Standard
    * * Value List Type: List
    * * Possible Values 
    *   * Private
    *   * Standard
        * * Description: Controls who may read this task and its child records (assignments, check-ins, comments, activities). Standard (default) is visible across the organization; Private restricts visibility to the creator, assignees (direct Person or MJ Role members), and creator/assignees of the root parent task.`),
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
    Organization: z.string().nullable().describe(`
        * * Field Name: Organization
        * * Display Name: Organization Name
        * * SQL Data Type: nvarchar(255)`),
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
 * zod schema definition for the entity MJ_BizApps_Tasks: Work Report Items
 */
export const mjBizAppsTasksWorkReportItemSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    WorkReportID: z.string().describe(`
        * * Field Name: WorkReportID
        * * Display Name: Work Report
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Work Reports (vwWorkReports.ID)
        * * Description: Parent WorkReport that owns this line item.`),
    TaskID: z.string().nullable().describe(`
        * * Field Name: TaskID
        * * Display Name: Task ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Tasks: Tasks (vwTasks.ID)
        * * Description: Optional Task referenced by this report item.`),
    Section: z.union([z.literal('AtRisk'), z.literal('Blockers'), z.literal('Completed'), z.literal('InProgress'), z.literal('Next')]).describe(`
        * * Field Name: Section
        * * Display Name: Section
        * * SQL Data Type: nvarchar(50)
        * * Default Value: Completed
    * * Value List Type: List
    * * Possible Values 
    *   * AtRisk
    *   * Blockers
    *   * Completed
    *   * InProgress
    *   * Next
        * * Description: Report section this line belongs to: Completed, InProgress, Next, Blockers, or AtRisk.`),
    Summary: z.string().describe(`
        * * Field Name: Summary
        * * Display Name: Summary
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Concise description of the progress, next step, blocker, or risk for this line item.`),
    Sequence: z.number().describe(`
        * * Field Name: Sequence
        * * Display Name: Sequence
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Display order within the parent WorkReport (ascending).`),
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
    Task: z.string().nullable().describe(`
        * * Field Name: Task
        * * Display Name: Task Description
        * * SQL Data Type: nvarchar(255)`),
});

export type mjBizAppsTasksWorkReportItemEntityType = z.infer<typeof mjBizAppsTasksWorkReportItemSchema>;

/**
 * zod schema definition for the entity MJ_BizApps_Tasks: Work Reports
 */
export const mjBizAppsTasksWorkReportSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    PersonID: z.string().describe(`
        * * Field Name: PersonID
        * * Display Name: Person
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The Person record whose work is summarized in this report.`),
    PeriodStart: z.date().describe(`
        * * Field Name: PeriodStart
        * * Display Name: Period Start
        * * SQL Data Type: date
        * * Description: Inclusive start date of the reporting window.`),
    PeriodEnd: z.date().describe(`
        * * Field Name: PeriodEnd
        * * Display Name: Period End
        * * SQL Data Type: date
        * * Description: Inclusive end date of the reporting window.`),
    Title: z.string().nullable().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(255)
        * * Description: Optional concise headline for the report (e.g., Daily 15Five — 2026-11-09).`),
    Body: z.string().describe(`
        * * Field Name: Body
        * * Display Name: Body
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Markdown body of the work report covering accomplishments, next priorities, blockers, and at-risk objectives.`),
    Status: z.union([z.literal('Draft'), z.literal('Reviewed'), z.literal('Submitted')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Draft
    *   * Reviewed
    *   * Submitted
        * * Description: Lifecycle status of the report: Draft (awaiting author approval), Submitted (approved by author, awaiting supervisor review), or Reviewed (supervisor feedback recorded).`),
    AuthoredByAgentRunID: z.string().nullable().describe(`
        * * Field Name: AuthoredByAgentRunID
        * * Display Name: Authored By Agent Run
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ: AI Agent Runs (vwAIAgentRuns.ID)
        * * Description: Optional AI Agent Run that drafted this work report.`),
    SupervisorFeedback: z.string().nullable().describe(`
        * * Field Name: SupervisorFeedback
        * * Display Name: Supervisor Feedback
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Feedback drafted by the supervisor Chief of Staff and approved/edited by the supervisor.`),
    ReviewedByPersonID: z.string().nullable().describe(`
        * * Field Name: ReviewedByPersonID
        * * Display Name: Reviewed By Person
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: MJ_BizApps_Common: People (vwPeople.ID)
        * * Description: The supervisor Person record who reviewed and approved feedback on this report.`),
    ReviewedAt: z.date().nullable().describe(`
        * * Field Name: ReviewedAt
        * * Display Name: Reviewed At
        * * SQL Data Type: datetimeoffset
        * * Description: Timestamp when supervisor feedback was approved and recorded on this report.`),
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
        * * Display Name: Person Name
        * * SQL Data Type: nvarchar(250)`),
    AuthoredByAgentRun: z.string().nullable().describe(`
        * * Field Name: AuthoredByAgentRun
        * * Display Name: Authored By Agent Run Name
        * * SQL Data Type: nvarchar(255)`),
    ReviewedByPerson: z.string().nullable().describe(`
        * * Field Name: ReviewedByPerson
        * * Display Name: Reviewed By Person Name
        * * SQL Data Type: nvarchar(250)`),
});

export type mjBizAppsTasksWorkReportEntityType = z.infer<typeof mjBizAppsTasksWorkReportSchema>;
