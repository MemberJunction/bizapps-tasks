import { beforeEach, describe, expect, it, vi } from 'vitest';

const runViewMock = vi.fn();
const settingGetMock = vi.fn();
const settingConfigMock = vi.fn();

vi.mock('@memberjunction/global', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/global')>()),
    RegisterClass: () => () => {},
    OptionalKeyedSpecialization: () => () => {},
}));

const getSystemUserMock = vi.fn().mockResolvedValue({ ID: 'sys-user' });
const logErrorMock = vi.fn();

// The real module underneath: tasks-core now loads the generated entity classes and the remote
// operations at import time (the time-tracking services), and they extend classes from here.
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    CompositeKey: {
        FromID: (id: string) => ({
            ToCompactURLSegment: () => `ID|${id}`,
        }),
    },
    LogError: (...args: unknown[]) => logErrorMock(...args),
    Metadata: { Provider: {} },
    WellKnownUserSource: {
        Instance: {
            GetSystemUser: (...args: unknown[]) => getSystemUserMock(...args),
        },
    },
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

    it('saves calendar links using the elevated system user, appends VideoJoinURL and DialInDetails to Body without overwriting Location, and serializes enqueueSync per meeting', async () => {
        const systemUser = { ID: 'sys-user' } as unknown as UserInfo;
        getSystemUserMock.mockResolvedValueOnce(systemUser);

        const meetingRow = {
            ID: 'M-300',
            Name: 'Zoom Sync',
            Description: 'Weekly review',
            Status: 'Scheduled',
            StartsAt: new Date('2026-11-12T15:00:00Z'),
            EndsAt: new Date('2026-11-12T16:00:00Z'),
            TimeZone: 'America/Chicago',
            LocationType: 'Virtual',
            Location: null,
            OrganizerPersonID: 'P-ADA',
            VideoProviderID: 'VP-ZOOM',
            VideoJoinURL: 'https://zoom.us/j/999',
            DialInDetails: 'US: +1 312 626 6799',
            Load: vi.fn(async () => true),
            Save: vi.fn(async () => true),
        };

        const provider = {
            Applications: [{ ID: 'app-tasks', Name: 'Tasks' }],
            GetEntityObject: vi.fn(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Video Providers') {
                    return { ID: 'VP-ZOOM', Code: 'ZOOM', DriverClass: 'ZoomVideoProvider', Load: async () => true };
                }
                return meetingRow;
            }),
        } as unknown as IMetadataProvider;

        settingGetMock.mockImplementation((key: string) =>
            key === 'DefaultCalendarProviderName' ? 'Microsoft Graph' : undefined,
        );
        runViewMock.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return { Success: true, Results: [{ ID: 'P-ADA', Email: 'ada@example.org', DisplayName: 'Ada' }] };
            }
            return { Success: true, Results: [] };
        });

        const createLinkedEventMock = vi.fn().mockResolvedValue({
            Success: true,
            Event: { ExternalEventID: 'evt-300', ICalUID: 'ical-300' },
        });
        const fakeLinks = {
            CreateLinkedEvent: createLinkedEventMock,
            UpdateLinkedEvent: vi.fn(),
            CancelLinkedEvent: vi.fn(),
            SyncCalendar: vi.fn(),
        } as unknown as CalendarEventLinks;

        const service = new MeetingCalendarSyncService(provider, fakeLinks);
        await service.syncMeeting('M-300', USER);

        expect(createLinkedEventMock).toHaveBeenCalledTimes(1);
        // Link save used the elevated systemUser, not the UI caller
        expect(createLinkedEventMock.mock.calls[0][1]).toBe(systemUser);
        const eventArg = createLinkedEventMock.mock.calls[0][0].Event;
        expect(eventArg.Location).toBeUndefined();
        expect(eventArg.Body).toContain('Weekly review');
        expect(eventArg.Body).toContain('Join online: https://zoom.us/j/999');
        expect(eventArg.Body).toContain('Dial-in:\nUS: +1 312 626 6799');

        // Verify per-meeting serialization order and that a rejected task does not leak an unhandled rejection or break subsequent tasks
        const order: number[] = [];
        const p1 = MeetingCalendarSyncService.enqueueSync('M-300', async () => {
            await new Promise((r) => setTimeout(r, 20));
            order.push(1);
        });
        const pFail = MeetingCalendarSyncService.enqueueSync('m-300', async () => {
            order.push(2);
            throw new Error('simulated queue failure');
        });
        const p3 = MeetingCalendarSyncService.enqueueSync('M-300', async () => {
            order.push(3);
        });
        await expect(pFail).rejects.toThrow('simulated queue failure');
        await Promise.all([p1, p3]);
        expect(order).toEqual([1, 2, 3]);

        // Verify Draft meetings skip calendar sync (e.g., when adding an attendee to a Draft meeting)
        meetingRow.Status = 'Draft';
        expect(await service.syncMeeting('M-300', USER)).toBeNull();
        expect(createLinkedEventMock).toHaveBeenCalledTimes(1);

        // Verify that if GetSystemUser returns null, sync logs an error and refuses rather than silently falling back to the caller
        meetingRow.Status = 'Scheduled';
        getSystemUserMock.mockResolvedValueOnce(null);
        logErrorMock.mockClear();
        const uiCaller = { ID: 'ui-user', UserRoles: [{ Role: 'UI' }] } as unknown as UserInfo;
        expect(await service.syncMeeting('M-300', uiCaller)).toBeNull();
        expect(logErrorMock).toHaveBeenCalledTimes(1);
        expect(createLinkedEventMock).toHaveBeenCalledTimes(1);
    });
});
