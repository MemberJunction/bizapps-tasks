import { describe, expect, it } from 'vitest';
import {
    DeriveIntervalMinutes,
    TimeEntryRefusal,
    type TimeEntryFacts,
} from '../time/TimeEntryAuthority.js';

const ALICE_ID = '11111111-1111-4111-8111-111111111111';
const BOB_ID = '22222222-2222-4222-8222-222222222222';

function baseFacts(overrides: Partial<TimeEntryFacts> = {}): TimeEntryFacts {
    return {
        Operation: 'create',
        CallerPersonIDs: [ALICE_ID],
        CallerCanManageTimeEntries: false,
        EntryPersonID: ALICE_ID,
        EntryPersonName: 'Alice Martin',
        TaskExists: true,
        WorkDate: '2026-11-04',
        TodayInBusinessZone: '2026-11-04',
        Minutes: 60,
        LockApprovedTimeEntries: true,
        CoveringTimesheets: [],
        LinkedRecordDescriptions: [],
        ...overrides,
    };
}

describe('TimeEntryRefusal & DeriveIntervalMinutes (§6.1 R1–R8)', () => {
    it('accepts a valid time entry for the caller own Person', () => {
        expect(TimeEntryRefusal(baseFacts())).toBeNull();
    });

    it('R1: refuses when caller has no Person and EntryPersonID is missing', () => {
        const msg = TimeEntryRefusal(baseFacts({ CallerPersonIDs: [], EntryPersonID: null }));
        expect(msg).toBe("You can't log time: your user has no person record.");
    });

    it('R2: refuses creating, editing, or deleting another person entry without Manage Time Entries', () => {
        const deniedCreate = TimeEntryRefusal(
            baseFacts({ EntryPersonID: BOB_ID, EntryPersonName: 'Bob Chen' }),
        );
        expect(deniedCreate).toBe('Only Bob Chen or a time-entry manager can change this entry.');

        const allowedWithAuth = TimeEntryRefusal(
            baseFacts({
                EntryPersonID: BOB_ID,
                EntryPersonName: 'Bob Chen',
                CallerCanManageTimeEntries: true,
            }),
        );
        expect(allowedWithAuth).toBeNull();

        const deniedReassign = TimeEntryRefusal(
            baseFacts({
                Operation: 'update',
                OriginalPersonID: BOB_ID,
                EntryPersonID: ALICE_ID,
                EntryPersonName: 'Bob Chen',
            }),
        );
        expect(deniedReassign).toBe('Only Bob Chen or a time-entry manager can change this entry.');
    });

    it('R3: refuses when the target task does not exist or is unreadable', () => {
        expect(TimeEntryRefusal(baseFacts({ TaskExists: false }))).toBe('The task was not found.');
    });

    it('R4: derives duration in whole minutes (min 1) from [StartedAt, EndedAt] and validates Minutes', () => {
        expect(
            DeriveIntervalMinutes('2026-11-04T10:00:00.000Z', '2026-11-04T11:30:00.000Z'),
        ).toBe(90);
        expect(
            DeriveIntervalMinutes('2026-11-04T10:00:00.000Z', '2026-11-04T10:00:05.000Z'),
        ).toBe(1);
        expect(
            DeriveIntervalMinutes('2026-11-04T11:30:00.000Z', '2026-11-04T10:00:00.000Z'),
        ).toBeNull();

        expect(TimeEntryRefusal(baseFacts({ Minutes: 0 }))).toContain('between 1 and 1440');
        expect(TimeEntryRefusal(baseFacts({ Minutes: 1441 }))).toContain('between 1 and 1440');
    });

    it('R5: refuses logging time more than 1 day after today in the business timezone', () => {
        // Today is 2026-11-04; tomorrow (2026-11-05) is allowed; 2026-11-06 is refused
        expect(TimeEntryRefusal(baseFacts({ WorkDate: '2026-11-05' }))).toBeNull();
        expect(TimeEntryRefusal(baseFacts({ WorkDate: '2026-11-06' }))).toBe(
            "Time can't be logged for a future day.",
        );
    });

    it('R6: refuses create, update (into or out of), and delete when covered by a Submitted or Approved timesheet', () => {
        const submittedTs = {
            ID: 'TS-1',
            PeriodStart: '2026-11-02',
            PeriodEnd: '2026-11-08',
            Status: 'Submitted' as const,
        };
        const approvedTs = {
            ID: 'TS-2',
            PeriodStart: '2026-10-26',
            PeriodEnd: '2026-11-01',
            Status: 'Approved' as const,
        };

        expect(
            TimeEntryRefusal(baseFacts({ WorkDate: '2026-11-04', CoveringTimesheets: [submittedTs] })),
        ).toBe('The period 2026-11-02 to 2026-11-08 is Submitted. Reopen it to change its time.');

        // Moving an entry OUT of an Approved period into an open period
        expect(
            TimeEntryRefusal(
                baseFacts({
                    Operation: 'update',
                    OriginalWorkDate: '2026-10-28',
                    WorkDate: '2026-11-04',
                    CoveringTimesheets: [approvedTs],
                }),
            ),
        ).toBe('The period 2026-10-26 to 2026-11-01 is Approved. Reopen it to change its time.');

        // Deleting an entry inside a Submitted period (even for a Manage Time Entries holder)
        expect(
            TimeEntryRefusal(
                baseFacts({
                    Operation: 'delete',
                    CallerCanManageTimeEntries: true,
                    WorkDate: '2026-11-04',
                    CoveringTimesheets: [submittedTs],
                }),
            ),
        ).toBe('The period 2026-11-02 to 2026-11-08 is Submitted. Reopen it to change its time.');

        // Draft and Rejected timesheets do NOT lock the period
        expect(
            TimeEntryRefusal(
                baseFacts({
                    WorkDate: '2026-11-04',
                    CoveringTimesheets: [{ ...submittedTs, Status: 'Rejected' }],
                }),
            ),
        ).toBeNull();
    });

    it('R8: refuses updating or deleting an entry referenced by a TaskTimeEntryLink', () => {
        expect(
            TimeEntryRefusal(
                baseFacts({
                    Operation: 'update',
                    LinkedRecordDescriptions: ['Invoice Line #INV-204'],
                }),
            ),
        ).toBe('This entry is used by Invoice Line #INV-204. Remove that link to change it.');

        expect(
            TimeEntryRefusal(
                baseFacts({
                    Operation: 'delete',
                    LinkedRecordDescriptions: ['Invoice Line #INV-204'],
                }),
            ),
        ).toBe('This entry is used by Invoice Line #INV-204. Remove that link to change it.');
    });
});
