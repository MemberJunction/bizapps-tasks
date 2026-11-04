/**
 * What the meeting widgets draw. The host (the Meetings app's pages, a space's Meetings tab) reads the records and
 * builds these; the widgets show them and ask for changes through their outputs. Ids are strings as MemberJunction
 * gives them; dates are instants.
 */
export type MeetingStatus = 'Draft' | 'Scheduled' | 'Postponed' | 'InProgress' | 'Completed' | 'Cancelled';
export type MeetingVisibility = 'Standard' | 'Private';
export type MeetingLocationType = 'Virtual' | 'InPerson' | 'Hybrid' | 'Phone';
export type AttendeeRole = 'Organizer' | 'Required' | 'Optional';
export type ResponseStatus = 'None' | 'Accepted' | 'Tentative' | 'Declined';
export type AttendanceStatus = 'Unknown' | 'Present' | 'Late' | 'LeftEarly' | 'Absent' | 'Excused';
export type AgendaItemStatus = 'Planned' | 'InProgress' | 'Done' | 'Deferred' | 'Skipped';
export type NoteKind = 'Notes' | 'Summary' | 'Decision';

export interface MeetingRow {
    id: string;
    name: string;
    status: MeetingStatus;
    visibility: MeetingVisibility;
    typeName: string | null;
    typeIcon?: string | null;
    startsAt: Date;
    endsAt: Date;
    timeZone: string;
    locationType: MeetingLocationType;
    location: string | null;
    joinUrl: string | null;
    organizerName: string | null;
    seriesId: string | null;
    /** The viewer's own answer, when they are invited; null when they are not. */
    myResponse: ResponseStatus | null;
    /** Whether the viewer organizes it. */
    isMine: boolean;
    attendeeCount?: number;
}

export interface AttendeeModel {
    id: string;
    personId: string | null;
    userId: string | null;
    email: string | null;
    name: string;
    role: AttendeeRole;
    responseStatus: ResponseStatus;
    attendanceStatus: AttendanceStatus;
    isMe: boolean;
}

export interface AgendaItemModel {
    id: string;
    parentId: string | null;
    sequence: number;
    name: string;
    description: string | null;
    typeId: string | null;
    typeName: string | null;
    typeCode: string | null;
    presenterPersonId: string | null;
    presenterName: string | null;
    durationMinutes: number | null;
    status: AgendaItemStatus;
    outcome: string | null;
    startedAt: Date | null;
    endedAt: Date | null;
}

export interface AgendaItemDraft {
    id: string | null;
    parentId: string | null;
    name: string;
    description: string;
    typeId: string | null;
    presenterPersonId: string | null;
    durationMinutes: number | null;
}

export interface NoteModel {
    id: string;
    agendaItemId: string | null;
    kind: NoteKind;
    title: string | null;
    body: string;
    source: 'Manual' | 'AI';
    status: 'Draft' | 'Final';
    authorName: string | null;
    updatedLabel: string;
    isMine: boolean;
}

export interface NoteDraft {
    id: string | null;
    agendaItemId: string | null;
    kind: NoteKind;
    title: string;
    body: string;
    status: 'Draft' | 'Final';
}

export interface FollowUpModel {
    id: string;
    name: string;
    status: string;
    priority: string | null;
    dueAt: Date | null;
    assigneeNames: string[];
    agendaItemId: string | null;
}

export interface FollowUpDraft {
    name: string;
    agendaItemId: string | null;
    assigneePersonId: string | null;
    dueAt: Date | null;
}

export interface LinkModel {
    id: string;
    entityName: string;
    recordId: string;
    recordName: string | null;
    description: string | null;
}

export interface MeetingTypeOption {
    id: string;
    name: string;
    code: string;
    iconClass: string | null;
    defaultDurationMinutes: number | null;
    defaultLocationType: MeetingLocationType | null;
    defaultVisibility: MeetingVisibility | null;
}

export interface AgendaItemTypeOption {
    id: string;
    name: string;
    code: string;
    defaultDurationMinutes: number | null;
}

export interface PersonOption {
    id: string;
    name: string;
    email: string | null;
}

export interface VideoProviderOption {
    id: string;
    name: string;
    code: string;
}

/** What the viewer may do to this meeting; the host decides from the seat and the status. */
export interface MeetingPermissions {
    canEdit: boolean;
    /** Start, end, cancel: the organizer's, or an administrator's. */
    canRun: boolean;
    canInvite: boolean;
    canWriteNotes: boolean;
    canAddFollowUps: boolean;
}

export interface NewMeetingDraft {
    name: string;
    typeId: string | null;
    startsAt: Date;
    durationMinutes: number;
    timeZone: string;
    locationType: MeetingLocationType;
    location: string;
    videoProviderId: string | null;
    joinUrl: string;
    visibility: MeetingVisibility;
    description: string;
    attendeePersonIds: string[];
    guestEmails: string[];
    applyTemplate: boolean;
}

export interface SeriesRuleDraft {
    frequency: 'DAILY' | 'WEEKLY' | 'MONTHLY';
    interval: number;
    /** Two-letter RFC 5545 days, for a weekly rule: MO, TU, … */
    byDay: string[];
    ends: 'never' | 'until' | 'count';
    until: Date | null;
    count: number | null;
}

export interface SeriesModel {
    id: string;
    name: string;
    description: string | null;
    typeName: string | null;
    organizerName: string | null;
    recurrenceRule: string;
    timeZone: string;
    firstStartsAt: Date;
    durationMinutes: number;
    status: 'Active' | 'Ended' | 'Cancelled';
    materializedThrough: Date | null;
    occurrenceCount: number;
    nextOccurrenceAt: Date | null;
}
