import { describe, it, expect } from 'vitest';
import { ParseQuickTaskInput } from '../task-quick-parse.js';

describe('ParseQuickTaskInput', () => {
    // Fixed Wednesday, Nov 18, 2026
    const refDate = new Date(2026, 10, 18, 10, 0, 0, 0);

    it('extracts title, tomorrow due date, @assignee, #tag, !priority, and ~hours', () => {
        const parsed = ParseQuickTaskInput('Call CFO tomorrow @Jordan #Finance !high ~1.5h', refDate);
        expect(parsed.Title).toBe('Call CFO');
        expect(parsed.Priority).toBe('High');
        expect(parsed.AssigneeQuery).toBe('Jordan');
        expect(parsed.AssigneeQueries).toEqual(['Jordan']);
        expect(parsed.TagNames).toEqual(['Finance']);
        expect(parsed.HoursEstimated).toBe(1.5);
        expect(parsed.DueLabel).toBe('Tomorrow');
        expect(parsed.DueAt?.getFullYear()).toBe(2026);
        expect(parsed.DueAt?.getMonth()).toBe(10);
        expect(parsed.DueAt?.getDate()).toBe(19);
    });

    it('supports critical/urgent/p1 aliases, minutes effort, multiple tags and assignees', () => {
        const parsed = ParseQuickTaskInput('Fix billing outage !urgent @Elena.Vance @Marcus #Ops #SLA ~45m today', refDate);
        expect(parsed.Title).toBe('Fix billing outage');
        expect(parsed.Priority).toBe('Critical');
        expect(parsed.AssigneeQueries).toEqual(['Elena Vance', 'Marcus']);
        expect(parsed.TagNames).toEqual(['Ops', 'SLA']);
        expect(parsed.HoursEstimated).toBe(0.75);
        expect(parsed.DueLabel).toBe('Today');
        expect(parsed.DueAt?.getDate()).toBe(18);
    });

    it('parses explicit month+day, weekday, ISO date, and relative in Nd', () => {
        const nov = ParseQuickTaskInput('Submit audit by Nov 25', refDate);
        expect(nov.Title).toBe('Submit audit');
        expect(nov.DueAt?.getMonth()).toBe(10);
        expect(nov.DueAt?.getDate()).toBe(25);

        const fri = ParseQuickTaskInput('Ship release notes by fri', refDate);
        expect(fri.Title).toBe('Ship release notes');
        expect(fri.DueAt?.getDate()).toBe(20); // Wed 18 -> Fri 20

        const iso = ParseQuickTaskInput('Board deck 2026-12-03', refDate);
        expect(iso.Title).toBe('Board deck');
        expect(iso.DueAt?.getMonth()).toBe(11);
        expect(iso.DueAt?.getDate()).toBe(3);

        const rel = ParseQuickTaskInput('Follow up in 3d', refDate);
        expect(rel.Title).toBe('Follow up');
        expect(rel.DueAt?.getDate()).toBe(21);
    });

    it('returns plain title with null metadata when no tokens exist', () => {
        const parsed = ParseQuickTaskInput('Review quarterly budget notes', refDate);
        expect(parsed.Title).toBe('Review quarterly budget notes');
        expect(parsed.Priority).toBeNull();
        expect(parsed.DueAt).toBeNull();
        expect(parsed.AssigneeQuery).toBeNull();
        expect(parsed.TagNames).toEqual([]);
        expect(parsed.HoursEstimated).toBeNull();
    });
});
