import { describe, it, expect } from 'vitest';
import { agendaDurationTotal, agendaParentProblem, orderAgenda, type AgendaNode } from '../agenda.js';

const M = 'M1';
const node = (ID: string, ParentID: string | null, Sequence: number, DurationMinutes?: number | null, MeetingID = M): AgendaNode => ({ ID, MeetingID, ParentID, Sequence, DurationMinutes });

const agenda: AgendaNode[] = [
    node('a', null, 200, 10),
    node('b', null, 100, null),
    node('b1', 'b', 100, 15),
    node('b2', 'b', 50, 5),
    node('b2x', 'b2', 100, 99), // under b2, which has its own duration: not added again
    node('c', null, 300, null),
];

describe('an agenda\'s tree', () => {
    it('accepts a parent on the same meeting', () => {
        expect(agendaParentProblem(node('n', 'a', 100), agenda)).toBeNull();
        expect(agendaParentProblem(node('n', null, 100), agenda)).toBeNull();
    });

    it('refuses itself, a missing parent, and another meeting\'s item', () => {
        expect(agendaParentProblem(node('a', 'a', 100), agenda)).toBe('An agenda item cannot sit under itself.');
        expect(agendaParentProblem(node('n', 'zz', 100), agenda)).toBe('The parent item is not on this agenda.');
        expect(agendaParentProblem(node('n', 'a', 100, null, 'M2'), agenda)).toBe('An agenda item sits under an item of the same meeting.');
    });

    it('refuses a cycle', () => {
        // b would sit under b2x, which sits under b2, which sits under b
        expect(agendaParentProblem(node('b', 'b2x', 100), agenda)).toBe('An agenda item cannot sit under one of its own sub-items.');
    });

    it('is compared without regard to the id\'s case', () => {
        expect(agendaParentProblem(node('n', 'B2', 100), agenda)).toBeNull();
    });
});

describe('the agenda in order', () => {
    it('walks siblings by sequence and sub-items under their parent', () => {
        expect(orderAgenda(agenda).map((n) => n.ID)).toEqual(['b', 'b2', 'b2x', 'b1', 'a', 'c']);
    });

    it('treats an item whose parent is missing as top-level', () => {
        expect(orderAgenda([node('x', 'gone', 100), node('y', null, 50)]).map((n) => n.ID)).toEqual(['y', 'x']);
    });
});

describe('the agenda\'s length', () => {
    it('adds top-level durations, and sub-items where the parent has none', () => {
        // a: 10; b: no duration, so b1 15 + b2 5 (b2x is not counted under b2); c: 0
        expect(agendaDurationTotal(agenda)).toBe(30);
    });

    it('is 0 for an empty agenda', () => {
        expect(agendaDurationTotal([])).toBe(0);
    });
});
