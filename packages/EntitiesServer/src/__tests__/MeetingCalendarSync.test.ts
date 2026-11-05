import { beforeEach, describe, expect, it, vi } from 'vitest';

const runViewMock = vi.fn();
const settingGetMock = vi.fn();
const settingConfigMock = vi.fn();

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    OptionalKeyedSpecialization: () => () => {},
}));

vi.mock('@memberjunction/core', () => ({
    CompositeKey: {
        FromID: (id: string) => ({
            ToCompactURLSegment: () => `ID|${id}`,
        }),
    },
    Metadata: { Provider: {} },
    RunView: {
        FromMetadataProvider: () => ({
            RunView: (...args: unknown[]) => runViewMock(...args),
        }),
    },
}));

vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: {
        Instance: {
            Config: (...args: unknown[]) => settingConfigMock(...args),
            GetSetting: (...args: unknown[]) => settingGetMock(...args),
        },
    },
}));

vi.mock('@memberjunction/communication-engine', () => ({
    BaseCalendarEventLinkHandler: class {},
    CalendarEventLinks: class {},
}));

vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolvePersonIDForUser: vi.fn().mockResolvedValue(null),
    ResolveUserIDForPerson: vi.fn().mockResolvedValue(null),
}));

import { MeetingCalendarSyncService } from '../calendar/MeetingCalendarSyncService.js';
import { MeetingCalendarEventLinkHandler, extractMeetingRecordId } from '../calendar/MeetingCalendarEventLinkHandler.js';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import type { CalendarEventLinks, CalendarLinkChange } from '@memberjunction/communication-engine';

const USER = { ID: 'user-ada' } as unknown as UserInfo;

describe('MeetingCalendarSyncService & MeetingCalendarEventLinkHandler (T2)', () => {
    beforeEach(() => {
        runViewMock.mockReset();
        settingGetMock.mockReset();
        settingConfigMock.mockReset();
    });

    it('creates a linked calendar event on the organizer mailbox, requests an online meeting, and saves OnlineMeetingUrl to Meeting.VideoJoinURL', async () => {
        const meetingRow = {
            ID: 'M-100',
            Name: 'Architecture Review',
            Description: 'Review service boundaries',
            Status: 'Scheduled',
            StartsAt: new Date('2026-11-12T15:00:00Z'),
            EndsAt: new Date('2026-11-12T16:00:00Z'),
            TimeZone: 'America/Chicago',
            LocationType: 'Virtual',
            Location: null,
            OrganizerPersonID: 'P-ADA',
            VideoProviderID: null,
            VideoJoinURL: null as string | null,
            Load: vi.fn(async () => true),
            Save: vi.fn(async () => true),
        };

        const provider = {
            Applications: [{ ID: 'app-tasks', Name: 'Tasks' }],
            GetEntityObject: vi.fn(async () => meetingRow),
        } as unknown as IMetadataProvider;

        settingGetMock.mockImplementation((key: string) => {
            if (key === 'DefaultCalendarProviderName') return 'Microsoft Graph';
            return undefined;
        });

        runViewMock.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return {
                    Success: true,
                    Results: [
                        { ID: 'P-ADA', Email: 'ada@example.org', DisplayName: 'Ada Lovelace' },
                        { ID: 'P-SAM', Email: 'sam@example.org', DisplayName: 'Sam Member' },
                    ],
                };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') {
                return {
                    Success: true,
                    Results: [
                        { PersonID: 'P-ADA', Email: null, DisplayName: null, Person: 'Ada Lovelace', Role: 'Organizer' },
                        { PersonID: 'P-SAM', Email: null, DisplayName: null, Person: 'Sam Member', Role: 'Required' },
                    ],
                };
            }
            if (params.EntityName === 'MJ: Calendar Event Links') {
                return { Success: true, Results: [] };
            }
            return { Success: true, Results: [] };
        });

        const createLinkedEventMock = vi.fn().mockResolvedValue({
            Success: true,
            Event: {
                ExternalEventID: 'graph-evt-1',
                ICalUID: 'ical-uid-100',
                OnlineMeetingUrl: 'https://teams.microsoft.com/l/meetup-join/100',
            },
        });

        const fakeLinks = {
            CreateLinkedEvent: createLinkedEventMock,
            UpdateLinkedEvent: vi.fn(),
            CancelLinkedEvent: vi.fn(),
            SyncCalendar: vi.fn(),
        } as unknown as CalendarEventLinks;

        const service = new MeetingCalendarSyncService(provider, fakeLinks);
        const result = await service.syncMeeting('M-100', USER);

        expect(result?.Success).toBe(true);
        expect(createLinkedEventMock).toHaveBeenCalledTimes(1);
        const callArg = createLinkedEventMock.mock.calls[0][0];
        expect(callArg.ProviderName).toBe('Microsoft Graph');
        expect(callArg.Target).toEqual({ Identifier: 'ada@example.org' });
        expect(callArg.Event).toMatchObject({
            Subject: 'Architecture Review',
            IsOnlineMeeting: true,
            Attendees: [{ Email: 'sam@example.org', Name: 'Sam Member', Type: 'Required' }],
        });
        expect(meetingRow.VideoJoinURL).toBe('https://teams.microsoft.com/l/meetup-join/100');
        expect(meetingRow.Save).toHaveBeenCalledTimes(1);
    });

    it('applies inbound calendar changes (times, location, RSVP responses, and cancellation) to Meeting and MeetingAttendee', async () => {
        expect(extractMeetingRecordId('ID|M-200')).toBe('M-200');
        expect(extractMeetingRecordId('M-200')).toBe('M-200');

        const meetingRow = {
            ID: 'M-200',
            Name: 'Old Title',
            Status: 'Scheduled',
            StartsAt: new Date('2026-11-12T15:00:00Z'),
            EndsAt: new Date('2026-11-12T16:00:00Z'),
            Location: 'Room 1A',
            VideoJoinURL: null as string | null,
            CancelledAt: null as Date | null,
            Load: vi.fn(async () => true),
            Save: vi.fn(async () => true),
        };

        const samAttendee = {
            PersonID: 'P-SAM',
            Email: null,
            Role: 'Required',
            ResponseStatus: 'None',
            RespondedAt: null as Date | null,
            Save: vi.fn(async () => true),
        };

        const provider = {
            GetEntityObject: vi.fn(async () => meetingRow),
        } as unknown as IMetadataProvider;

        runViewMock.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') {
                return { Success: true, Results: [samAttendee] };
            }
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return { Success: true, Results: [{ ID: 'P-SAM', Email: 'sam@example.org' }] };
            }
            return { Success: true, Results: [] };
        });

        const handler = new MeetingCalendarEventLinkHandler();
        const newStart = new Date('2026-11-12T17:00:00Z');
        const newEnd = new Date('2026-11-12T18:00:00Z');

        const handled = await handler.HandleChange(
            {
                Link: { RecordID: 'ID|M-200' } as CalendarLinkChange['Link'],
                Kind: 'Upserted',
                IsCancelled: false,
                Event: {
                    ExternalEventID: 'evt-200',
                    SeriesID: null,
                    ICalUID: 'ical-200',
                    Subject: 'Moved Title',
                    Body: '',
                    Start: newStart,
                    End: newEnd,
                    IsAllDay: false,
                    Location: 'Room 2B',
                    Organizer: { Email: 'ada@example.org' },
                    Attendees: [{ Email: 'sam@example.org', Name: 'Sam', Type: 'Required', Response: 'Accepted' }],
                    IsCancelled: false,
                    OnlineMeetingUrl: 'https://meet.google.com/abc-defg-hij',
                    LastModified: new Date(),
                },
            },
            USER,
            provider,
        );

        expect(handled).toBe(true);
        expect(meetingRow.Name).toBe('Moved Title');
        expect(meetingRow.StartsAt).toEqual(newStart);
        expect(meetingRow.EndsAt).toEqual(newEnd);
        expect(meetingRow.Location).toBe('Room 2B');
        expect(meetingRow.VideoJoinURL).toBe('https://meet.google.com/abc-defg-hij');
        expect(samAttendee.ResponseStatus).toBe('Accepted');
        expect(samAttendee.RespondedAt).toBeInstanceOf(Date);

        // Now test cancellation
        const cancelled = await handler.HandleChange(
            {
                Link: { RecordID: 'ID|M-200' } as CalendarLinkChange['Link'],
                Kind: 'Removed',
                IsCancelled: true,
            },
            USER,
            provider,
        );
        expect(cancelled).toBe(true);
        expect(meetingRow.Status).toBe('Cancelled');
        expect(meetingRow.CancelledAt).toBeInstanceOf(Date);
    });
});
