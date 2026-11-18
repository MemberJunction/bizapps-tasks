import { describe, expect, it } from 'vitest';
import {
    markProposedTaskAccepted,
    markProposedTaskDismissed,
    parseProposedTasks,
    serializeProposedTasks,
} from '../proposed-tasks.js';

describe('proposed-tasks', () => {
    it('returns an empty list for null or blank JSON', () => {
        expect(parseProposedTasks(null)).toEqual([]);
        expect(parseProposedTasks('')).toEqual([]);
        expect(parseProposedTasks('   ')).toEqual([]);
    });

    it('parses a JSON array or an object with items/tasks and assigns default IDs and Pending status', () => {
        const fromArray = parseProposedTasks(
            JSON.stringify([
                {
                    title: '  Send Q4 forecast to board  ',
                    description: 'Include revised variance table',
                    assigneePersonId: '11111111-1111-4111-8111-111111111111',
                    assigneeName: 'Ivy Chen',
                    dueAt: '2026-11-15',
                    agendaItemId: '22222222-2222-4222-8222-222222222222',
                },
            ]),
        );
        expect(fromArray).toEqual([
            {
                id: 'proposal-1',
                title: 'Send Q4 forecast to board',
                description: 'Include revised variance table',
                assigneePersonId: '11111111-1111-4111-8111-111111111111',
                assigneeName: 'Ivy Chen',
                dueAt: '2026-11-15',
                agendaItemId: '22222222-2222-4222-8222-222222222222',
                status: 'Pending',
                taskId: null,
            },
        ]);

        const fromObject = parseProposedTasks(
            JSON.stringify({
                items: [{ id: 'p-custom', title: 'Update charter', status: 'Dismissed' }],
            }),
        );
        expect(fromObject[0].id).toBe('p-custom');
        expect(fromObject[0].status).toBe('Dismissed');
    });

    it('refuses invalid JSON, missing titles, or Accepted status without a taskId', () => {
        expect(() => parseProposedTasks('{bad')).toThrow(/not valid JSON/);
        expect(() => parseProposedTasks(JSON.stringify([{ title: '   ' }]))).toThrow(/no title/);
        expect(() =>
            parseProposedTasks(JSON.stringify([{ id: 'p1', title: 'Follow up', status: 'Accepted' }])),
        ).toThrow(/Accepted without a taskId/);
    });

    it('accepts a pending proposal and records the created taskId', () => {
        const initial = parseProposedTasks(JSON.stringify([{ id: 'p1', title: 'Draft budget memo' }]));
        const accepted = markProposedTaskAccepted(initial, 'P1', '33333333-3333-4333-8333-333333333333');
        expect(accepted[0].status).toBe('Accepted');
        expect(accepted[0].taskId).toBe('33333333-3333-4333-8333-333333333333');

        // Idempotent with the same taskId, refuses a different taskId or dismissing after acceptance
        expect(markProposedTaskAccepted(accepted, 'p1', '33333333-3333-4333-8333-333333333333')).toEqual(accepted);
        expect(() => markProposedTaskAccepted(accepted, 'p1', '44444444-4444-4444-8444-444444444444')).toThrow(
            /already accepted/,
        );
        expect(() => markProposedTaskDismissed(accepted, 'p1')).toThrow(/already accepted/);
    });

    it('dismisses a pending proposal and refuses accepting a dismissed one', () => {
        const initial = parseProposedTasks(JSON.stringify([{ id: 'p1', title: 'Optional check-in' }]));
        const dismissed = markProposedTaskDismissed(initial, 'p1');
        expect(dismissed[0].status).toBe('Dismissed');
        expect(dismissed[0].taskId).toBeNull();
        expect(() => markProposedTaskAccepted(dismissed, 'p1', '33333333-3333-4333-8333-333333333333')).toThrow(
            /already dismissed/,
        );
        const roundTrip = parseProposedTasks(serializeProposedTasks(dismissed));
        expect(roundTrip).toEqual(dismissed);
    });
});

