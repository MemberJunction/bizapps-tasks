import { describe, expect, it } from 'vitest';
import {
    PeriodFor,
    ResolveScheduleForDate,
    WeekBoundsFor,
    type EffectiveScheduleCandidate,
    type WeekdayName,
} from '../time/TimesheetPeriod.js';

describe('PeriodFor & ResolveScheduleForDate', () => {
    it('computes Weekly periods for every start day (Sunday through Saturday)', () => {
        // 2026-11-04 is a Wednesday
        const expectations: Array<{ day: WeekdayName; start: string; end: string }> = [
            { day: 'Sunday', start: '2026-11-01', end: '2026-11-07' },
            { day: 'Monday', start: '2026-11-02', end: '2026-11-08' },
            { day: 'Tuesday', start: '2026-11-03', end: '2026-11-09' },
            { day: 'Wednesday', start: '2026-11-04', end: '2026-11-10' },
            { day: 'Thursday', start: '2026-10-29', end: '2026-11-04' },
            { day: 'Friday', start: '2026-10-30', end: '2026-11-05' },
            { day: 'Saturday', start: '2026-10-31', end: '2026-11-06' },
        ];

        for (const exp of expectations) {
            const period = PeriodFor('2026-11-04', { Cadence: 'Weekly', WeekStartDay: exp.day });
            expect(period.PeriodStart).toBe(exp.start);
            expect(period.PeriodEnd).toBe(exp.end);
            expect(period.Days).toHaveLength(7);
        }

        const week = WeekBoundsFor('2026-12-31', 'Monday');
        expect(week.WeekStart).toBe('2026-12-28');
        expect(week.WeekEnd).toBe('2027-01-03');
    });

    it('computes BiWeekly periods before, on, and after the anchor date across year boundaries', () => {
        const anchor = '2026-01-05'; // Monday
        const onAnchor = PeriodFor('2026-01-05', { Cadence: 'BiWeekly', BiWeeklyAnchorDate: anchor });
        expect(onAnchor.PeriodStart).toBe('2026-01-05');
        expect(onAnchor.PeriodEnd).toBe('2026-01-18');
        expect(onAnchor.Days).toHaveLength(14);

        const endOfFirst = PeriodFor('2026-01-18', { Cadence: 'BiWeekly', BiWeeklyAnchorDate: anchor });
        expect(endOfFirst.PeriodStart).toBe('2026-01-05');
        expect(endOfFirst.PeriodEnd).toBe('2026-01-18');

        const startOfSecond = PeriodFor('2026-01-19', { Cadence: 'BiWeekly', BiWeeklyAnchorDate: anchor });
        expect(startOfSecond.PeriodStart).toBe('2026-01-19');
        expect(startOfSecond.PeriodEnd).toBe('2026-02-01');

        // Prior to anchor (crosses 2025/2026 year boundary)
        const beforeAnchor = PeriodFor('2026-01-04', { Cadence: 'BiWeekly', BiWeeklyAnchorDate: anchor });
        expect(beforeAnchor.PeriodStart).toBe('2025-12-22');
        expect(beforeAnchor.PeriodEnd).toBe('2026-01-04');
    });

    it('computes SemiMonthly periods on the 15th, 16th, non-leap Feb (2026), and leap Feb (2028)', () => {
        const firstHalf = PeriodFor('2026-11-15', { Cadence: 'SemiMonthly' });
        expect(firstHalf.PeriodStart).toBe('2026-11-01');
        expect(firstHalf.PeriodEnd).toBe('2026-11-15');
        expect(firstHalf.Days).toHaveLength(15);

        const secondHalf30 = PeriodFor('2026-11-16', { Cadence: 'SemiMonthly' });
        expect(secondHalf30.PeriodStart).toBe('2026-11-16');
        expect(secondHalf30.PeriodEnd).toBe('2026-11-30');
        expect(secondHalf30.Days).toHaveLength(15);

        const feb2026 = PeriodFor('2026-02-20', { Cadence: 'SemiMonthly' });
        expect(feb2026.PeriodStart).toBe('2026-02-16');
        expect(feb2026.PeriodEnd).toBe('2026-02-28');
        expect(feb2026.Days).toHaveLength(13);

        const feb2028 = PeriodFor('2028-02-20', { Cadence: 'SemiMonthly' });
        expect(feb2028.PeriodStart).toBe('2028-02-16');
        expect(feb2028.PeriodEnd).toBe('2028-02-29');
        expect(feb2028.Days).toHaveLength(14);
    });

    it('computes Monthly periods across 31-day, 30-day, and February months', () => {
        const dec = PeriodFor('2026-12-19', { Cadence: 'Monthly' });
        expect(dec.PeriodStart).toBe('2026-12-01');
        expect(dec.PeriodEnd).toBe('2026-12-31');
        expect(dec.Days).toHaveLength(31);
    });

    it('clamps PeriodStart after a schedule transition so periods never overlap', () => {
        // Person submitted Weekly through Sunday 2026-11-08, then switched to SemiMonthly for 2026-11-10.
        // Natural SemiMonthly period would be 2026-11-01..2026-11-15, which overlaps 2026-11-02..2026-11-08.
        // Transition clamps PeriodStart to 2026-11-09!
        const transition = PeriodFor('2026-11-10', {
            Cadence: 'SemiMonthly',
            LastSubmittedPeriodEnd: '2026-11-08',
        });
        expect(transition.IsTransition).toBe(true);
        expect(transition.PeriodStart).toBe('2026-11-09');
        expect(transition.PeriodEnd).toBe('2026-11-15');
    });

    it('computes contiguous OpenEnded periods starting the day after LastSubmittedPeriodEnd', () => {
        const open1 = PeriodFor('2026-11-05', {
            Cadence: 'OpenEnded',
            BiWeeklyAnchorDate: '2026-11-01',
            OpenEndedPeriodEnd: '2026-11-12',
        });
        expect(open1.PeriodStart).toBe('2026-11-01');
        expect(open1.PeriodEnd).toBe('2026-11-12');

        const open2 = PeriodFor('2026-11-20', {
            Cadence: 'OpenEnded',
            LastSubmittedPeriodEnd: '2026-11-12',
            OpenEndedPeriodEnd: '2026-11-25',
        });
        expect(open2.PeriodStart).toBe('2026-11-13');
        expect(open2.PeriodEnd).toBe('2026-11-25');
    });

    it('resolves the most specific effective schedule for a date', () => {
        const schedules: EffectiveScheduleCandidate[] = [
            {
                ID: 'global-1',
                PersonID: null,
                Cadence: 'Weekly',
                WeekStartDay: 'Monday',
                BiWeeklyAnchorDate: '2026-01-05',
                EffectiveFrom: '2026-01-01',
                EffectiveTo: null,
            },
            {
                ID: 'person-1',
                PersonID: 'P-100',
                Cadence: 'SemiMonthly',
                WeekStartDay: 'Monday',
                BiWeeklyAnchorDate: '2026-01-05',
                EffectiveFrom: '2026-06-01',
                EffectiveTo: '2026-12-31',
            },
        ];

        expect(ResolveScheduleForDate('2026-11-04', schedules, 'P-100')?.ID).toBe('person-1');
        expect(ResolveScheduleForDate('2026-03-15', schedules, 'P-100')?.ID).toBe('global-1');
        expect(ResolveScheduleForDate('2026-11-04', schedules, 'P-999')?.ID).toBe('global-1');
    });
});
