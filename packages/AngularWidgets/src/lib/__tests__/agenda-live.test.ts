import '@angular/compiler';
import { describe, it, expect } from 'vitest';
import { agendaMinutes, agendaTree } from '../meeting-agenda.component';
import { elapsedSince, resolveLiveSelection, settleSubmittedDraft, shouldClearSubmittedDraft } from '../meeting-live.component';
import { canDraftNotesWithAI, canManageNoteProposals } from '../meeting-notes.component';
import { buildRecurrenceRule, describeRecurrenceRule, parseRecurrenceRuleDraft } from '../series-rule';
import { groupMeetingsByDay } from '../meeting-list.component';
import type { AgendaItemModel, MeetingRow } from '../types';

const item = (id: string, parentId: string | null, sequence: number, durationMinutes: number | null): AgendaItemModel => ({ id, parentId, sequence, name: id, description: null, typeId: null, typeName: null, typeCode: null, presenterPersonId: null, presenterName: null, durationMinutes, status: 'Planned', outcome: null, startedAt: null, endedAt: null });

describe('the agenda widget\'s tree', () => {
    const items = [item('b', null, 200, null), item('a', null, 100, 10), item('b2', 'B', 100, 5), item('b1', 'b', 50, 15)];

    it('walks siblings by sequence and sub-items under their parent, without regard to id case', () => {
        expect(agendaTree(items).map((e) => `${e.item.id}:${e.depth}`)).toEqual(['a:0', 'b:0', 'b1:1', 'b2:1']);
    });

    it('adds the sub-items where the parent has no length', () => {
        expect(agendaMinutes(items)).toBe(30);
    });
});

describe('the live meeting\'s clock', () => {
    it('counts from the start, and nothing before one', () => {
        const now = new Date('2026-11-03T15:10:00Z');
        expect(elapsedSince(new Date('2026-11-03T15:00:00Z'), now)).toBe(600);
        expect(elapsedSince(null, now)).toBe(0);
        expect(elapsedSince(new Date('2026-11-03T16:00:00Z'), now)).toBe(0);
    });

    it('preserves the typed outcome when Items reloads on the same item, and moves when the running item changes', () => {
        const i1: AgendaItemModel = { ...item('a', null, 100, 10), status: 'InProgress', outcome: 'Initial outcome' };
        const i2: AgendaItemModel = { ...item('b', null, 200, 10), status: 'Planned', outcome: null };
        const tree1 = agendaTree([i1, i2]);

        // Initial load selects the running item and seeds its outcome
        const s1 = resolveLiveSelection(tree1, { index: 0, currentItemId: null, runningItemId: null, outcome: '' });
        expect(s1).toEqual({ index: 0, currentItemId: 'a', runningItemId: 'a', outcome: 'Initial outcome' });

        // User types a new outcome and an attendance tap reloads Items with a fresh array reference
        const s2 = resolveLiveSelection(agendaTree([{ ...i1 }, { ...i2 }]), {
            ...s1,
            outcome: 'User is typing this outcome...',
        });
        expect(s2.index).toBe(0);
        expect(s2.outcome).toBe('User is typing this outcome...');

        // When item 'b' becomes InProgress on the server, the live view moves to 'b' and resets outcome to b's outcome
        const tree3 = agendaTree([
            { ...i1, status: 'Done' },
            { ...i2, status: 'InProgress', outcome: 'Second item outcome' },
        ]);
        const s3 = resolveLiveSelection(tree3, s2);
        expect(s3.index).toBe(1);
        expect(s3.currentItemId).toBe('b');
        expect(s3.runningItemId).toBe('b');
        expect(s3.outcome).toBe('Second item outcome');
    });

    it('keeps widget form drafts open when Busy finishes with an ErrorMessage, resets pending on error, and clears them only on clean completion', () => {
        // Still busy -> keep pending and do not clear
        expect(settleSubmittedDraft(true, true, '')).toBe('keep');
        expect(shouldClearSubmittedDraft(true, true, '')).toBe(false);
        // Finished with an error -> reset pending so a later unrelated save does not clear the kept draft
        expect(settleSubmittedDraft(true, false, 'AI service unreachable')).toBe('reset-pending');
        expect(shouldClearSubmittedDraft(true, false, 'AI service unreachable')).toBe(false);
        // Subsequent unrelated action after pending was reset -> keep draft
        expect(settleSubmittedDraft(false, false, '')).toBe('keep');
        // Finished cleanly without error -> clear draft
        expect(settleSubmittedDraft(true, false, '')).toBe('clear');
        expect(shouldClearSubmittedDraft(true, false, '')).toBe(true);
    });

    it('gates AI drafting to organizers/admins and proposal actions to note authors or organizers/admins, and supports YEARLY series rules', () => {
        expect(canDraftNotesWithAI(false)).toBe(false);
        expect(canDraftNotesWithAI(true)).toBe(true);
        expect(canManageNoteProposals(true, false, false)).toBe(false);
        expect(canManageNoteProposals(true, false, true)).toBe(true);
        expect(canManageNoteProposals(true, true, false)).toBe(true);

        const yearly = parseRecurrenceRuleDraft('FREQ=YEARLY;INTERVAL=2');
        expect(yearly?.frequency).toBe('YEARLY');
        expect(describeRecurrenceRule(yearly!)).toBe('Every 2 years');
        expect(buildRecurrenceRule(yearly!)).toBe('FREQ=YEARLY;INTERVAL=2');
    });
});

describe('the list\'s days', () => {
    const row = (id: string, iso: string): MeetingRow => ({ id, name: id, status: 'Scheduled', visibility: 'Standard', typeName: null, startsAt: new Date(iso), endsAt: new Date(new Date(iso).getTime() + 3600000), timeZone: 'UTC', locationType: 'Virtual', location: null, joinUrl: null, organizerName: null, seriesId: null, myResponse: null, isMine: false });

    it('groups by the viewer\'s day and keeps the order asked', () => {
        const rows = [row('late', '2026-11-04T15:00:00Z'), row('early', '2026-11-03T15:00:00Z'), row('mid', '2026-11-03T18:00:00Z')];
        const asc = groupMeetingsByDay(rows, 'America/Chicago', 'asc');
        expect(asc.map((g) => g.meetings.map((m) => m.id))).toEqual([['early', 'mid'], ['late']]);
        expect(asc[0].label).toBe('Tue, Nov 3');
        expect(groupMeetingsByDay(rows, 'America/Chicago', 'desc')[0].meetings[0].id).toBe('late');
    });
});
