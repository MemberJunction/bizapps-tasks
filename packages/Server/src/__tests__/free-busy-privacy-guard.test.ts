import { describe, expect, it } from 'vitest';
import {
    AggregateProjectFreeBusy,
    AssertFreeBusyPromptPayloadIsClean,
    BuildAssigneeFreeBusySummary,
    FindSensitiveCalendarFields,
    FreeBusyPrivacyViolationError,
    MergeBusyIntervals,
    SanitizeFreeBusySlots,
    type RawFreeBusySlotInput,
} from '@mj-biz-apps/tasks-core';

describe('Calendar Free/Busy Privacy Guard', () => {
    const windowStart = new Date('2026-11-23T08:00:00.000Z');
    const windowEnd = new Date('2026-11-23T18:00:00.000Z'); // 600 minutes

    it('rejects any slot carrying sensitive calendar fields when mode is reject', () => {
        const sensitiveSlots: RawFreeBusySlotInput[] = [
            {
                StartTime: '2026-11-23T09:00:00.000Z',
                EndTime: '2026-11-23T10:00:00.000Z',
                Status: 'Busy',
                Subject: 'Secret Executive M&A Review',
                Body: 'Confidential deal terms',
                Title: 'Board Sync',
                Description: 'Private agenda notes',
                Location: 'Room 401',
                Attendees: ['ceo@example.com'],
            },
        ];

        let caught: Error | null = null;
        try {
            SanitizeFreeBusySlots(sensitiveSlots, windowStart, windowEnd, { mode: 'reject' });
        } catch (err: unknown) {
            caught = err instanceof Error ? err : new Error(String(err));
        }

        expect(caught).toBeInstanceOf(FreeBusyPrivacyViolationError);
        const violation = caught as FreeBusyPrivacyViolationError;
        expect(violation.OffendingFields).toEqual(
            expect.arrayContaining([
                'slots[0].Subject',
                'slots[0].Body',
                'slots[0].Title',
                'slots[0].Description',
                'slots[0].Location',
                'slots[0].Attendees',
            ]),
        );
        // Error message must never leak the sensitive calendar values themselves
        expect(violation.message).not.toContain('Secret Executive M&A Review');
        expect(violation.message).not.toContain('Confidential deal terms');
        expect(violation.message).not.toContain('ceo@example.com');
    });

    it('strips all sensitive calendar fields in strip mode and emits strictly free/busy windows', () => {
        const rawSlots: RawFreeBusySlotInput[] = [
            {
                StartTime: '2026-11-23T09:00:00.000Z',
                EndTime: '2026-11-23T11:00:00.000Z',
                Status: 'Busy',
                Subject: 'Medical Appointment',
                Body: 'Doctor notes',
                Location: 'Clinic',
                Attendees: ['doctor@clinic.org'],
            },
            {
                StartTime: '2026-11-23T11:00:00.000Z',
                EndTime: '2026-11-23T12:00:00.000Z',
                Status: 'Free',
                Subject: 'Focus Block',
            },
            {
                StartTime: '2026-11-23T17:00:00.000Z',
                EndTime: '2026-11-23T19:00:00.000Z', // Clamped to 18:00Z
                Status: 'OutOfOffice',
                Title: 'Flight',
            },
        ];

        const sanitized = SanitizeFreeBusySlots(rawSlots, windowStart, windowEnd, { mode: 'strip' });
        expect(sanitized).toEqual([
            {
                StartISO: '2026-11-23T09:00:00.000Z',
                EndISO: '2026-11-23T11:00:00.000Z',
                BusyMinutes: 120,
                Status: 'Busy',
            },
            {
                StartISO: '2026-11-23T17:00:00.000Z',
                EndISO: '2026-11-23T18:00:00.000Z',
                BusyMinutes: 60,
                Status: 'OutOfOffice',
            },
        ]);
        expect(FindSensitiveCalendarFields(sanitized)).toEqual([]);
    });

    it('merges overlapping busy intervals and computes accurate availability ratio', () => {
        const overlapping: RawFreeBusySlotInput[] = [
            {
                StartTime: '2026-11-23T09:00:00.000Z',
                EndTime: '2026-11-23T11:00:00.000Z',
                Status: 'Busy',
            },
            {
                StartTime: '2026-11-23T10:00:00.000Z',
                EndTime: '2026-11-23T12:00:00.000Z',
                Status: 'Tentative',
            },
        ];

        const merged = MergeBusyIntervals(SanitizeFreeBusySlots(overlapping, windowStart, windowEnd));
        expect(merged).toHaveLength(1);
        expect(merged[0]).toEqual({
            StartISO: '2026-11-23T09:00:00.000Z',
            EndISO: '2026-11-23T12:00:00.000Z',
            BusyMinutes: 180,
            Status: 'Busy',
        });

        const summary = BuildAssigneeFreeBusySummary({
            personId: '11111111-1111-4111-8111-111111111111',
            userId: '22222222-2222-4222-8222-222222222222',
            windowStart,
            windowEnd,
            slots: overlapping,
        });

        expect(summary.TotalWindowMinutes).toBe(600);
        expect(summary.BusyMinutes).toBe(180);
        expect(summary.FreeMinutes).toBe(420);
        expect(summary.AvailabilityRatio).toBe(0.7);
        expect(summary.AvailabilityKey).toBe('person:11111111-1111-4111-8111-111111111111');
    });

    it('verifies AssertFreeBusyPromptPayloadIsClean allows clean summaries and blocks contaminated payloads', () => {
        const summary = BuildAssigneeFreeBusySummary({
            personId: '11111111-1111-4111-8111-111111111111',
            userId: null,
            windowStart,
            windowEnd,
            slots: [
                {
                    StartTime: '2026-11-23T09:00:00.000Z',
                    EndTime: '2026-11-23T10:00:00.000Z',
                    Status: 'Busy',
                    Subject: 'Will be stripped',
                },
            ],
            mode: 'strip',
        });

        const aggregated = AggregateProjectFreeBusy({
            windowStart,
            windowEnd,
            assignees: [summary],
        });
        expect(() => AssertFreeBusyPromptPayloadIsClean(aggregated)).not.toThrow();

        const contaminatedInterval = {
            ...summary.BusyIntervals[0],
            subject: 'Leaked meeting title',
        };
        const contaminated = {
            ...aggregated,
            Assignees: [
                {
                    ...summary,
                    BusyIntervals: [contaminatedInterval],
                },
            ],
        };
        expect(() => AssertFreeBusyPromptPayloadIsClean(contaminated)).toThrow(
            FreeBusyPrivacyViolationError,
        );
    });
});
