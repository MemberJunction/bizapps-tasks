/** The meetings entities, by the names CodeGen gave them (the meetings plan, § 2). */
export const MEETING_ENTITY = 'MJ_BizApps_Tasks: Meetings';
export const MEETING_SERIES_ENTITY = 'MJ_BizApps_Tasks: Meeting Series';
export const MEETING_SERIES_ATTENDEE_ENTITY = 'MJ_BizApps_Tasks: Meeting Series Attendees';
export const MEETING_ATTENDEE_ENTITY = 'MJ_BizApps_Tasks: Meeting Attendees';
export const MEETING_AGENDA_ITEM_ENTITY = 'MJ_BizApps_Tasks: Meeting Agenda Items';
export const MEETING_AGENDA_ITEM_TYPE_ENTITY = 'MJ_BizApps_Tasks: Meeting Agenda Item Types';
export const MEETING_NOTE_ENTITY = 'MJ_BizApps_Tasks: Meeting Notes';
export const MEETING_LINK_ENTITY = 'MJ_BizApps_Tasks: Meeting Links';
export const MEETING_TYPE_ENTITY = 'MJ_BizApps_Tasks: Meeting Types';
export const VIDEO_PROVIDER_ENTITY = 'MJ_BizApps_Tasks: Video Providers';

/** The reason a save or delete failed, as the entity reports it: over the wire the full text, locally the short one. */
export function entityFailure(entity: { LatestResult?: { CompleteMessage?: string | null; Message?: string | null } | null }, fallback = 'unknown error'): string {
    return entity.LatestResult?.CompleteMessage || entity.LatestResult?.Message || fallback;
}
