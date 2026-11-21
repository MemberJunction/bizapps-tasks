import { describe, expect, it } from 'vitest';
import {
    DeleteSavedTaskFilterView,
    FormatTaskActivityTypeLabel,
    FormatTaskStatusLabel,
    MAX_SAVED_TASK_VIEWS,
    ParseSavedTaskFilterViews,
    SAVED_TASK_VIEWS_SETTING,
    SerializeSavedTaskFilterViews,
    UpsertSavedTaskFilterView,
    type SavedTaskFilterView,
} from '../task-saved-views.js';

describe('task-saved-views', () => {
    it('exports the canonical UserInfoEngine setting key', () => {
        expect(SAVED_TASK_VIEWS_SETTING).toBe('mj.tasks.savedFilterViews.v1');
    });

    it('gracefully handles empty, null, or malformed JSON', () => {
        expect(ParseSavedTaskFilterViews(null)).toEqual([]);
        expect(ParseSavedTaskFilterViews(undefined)).toEqual([]);
        expect(ParseSavedTaskFilterViews('')).toEqual([]);
        expect(ParseSavedTaskFilterViews('{not-json')).toEqual([]);
        expect(ParseSavedTaskFilterViews('{"ID":"1"}')).toEqual([]);
    });

    it('round-trips valid saved filter views and ignores corrupt entries', () => {
        const raw = JSON.stringify([
            {
                ID: 'v-close',
                Name: 'Month-End Close (Acme)',
                CategoryID: 'cat-1',
                ViewMode: 'kanban',
                SearchText: 'reconcile',
                Filters: { organization: 'org-1', status: ['Open', 'InProgress'] },
                CreatedAt: '2026-11-20T12:00:00.000Z',
            },
            { ID: '', Name: 'Missing ID' },
            { ID: 'v-bad-mode', Name: 'Fallback Mode', ViewMode: 'unknown', Filters: 'invalid' },
        ]);

        const parsed = ParseSavedTaskFilterViews(raw);
        expect(parsed).toHaveLength(2);
        expect(parsed[0]).toMatchObject({
            ID: 'v-close',
            Name: 'Month-End Close (Acme)',
            CategoryID: 'cat-1',
            ViewMode: 'kanban',
            SearchText: 'reconcile',
            Filters: { organization: 'org-1', status: ['Open', 'InProgress'] },
        });
        expect(parsed[1].ViewMode).toBeUndefined();
        expect(parsed[1].Filters).toEqual({});

        const reserialized = SerializeSavedTaskFilterViews(parsed);
        expect(ParseSavedTaskFilterViews(reserialized)).toEqual(parsed);
    });

    it('upserts by ID or case-insensitive Name and respects MAX_SAVED_TASK_VIEWS', () => {
        let views: SavedTaskFilterView[] = [];
        views = UpsertSavedTaskFilterView(views, {
            Name: '  Blocked Finance  ',
            CategoryID: null,
            ViewMode: 'list',
            SearchText: '',
            Filters: { status: ['Blocked'] },
        });
        expect(views).toHaveLength(1);
        expect(views[0].Name).toBe('Blocked Finance');

        // Case-insensitive overwrite keeps existing ID
        const firstId = views[0].ID;
        views = UpsertSavedTaskFilterView(views, {
            Name: 'blocked finance',
            CategoryID: 'cat-fin',
            ViewMode: 'gantt',
            SearchText: 'close',
            Filters: { status: ['Blocked', 'InProgress'] },
        });
        expect(views).toHaveLength(1);
        expect(views[0].ID).toBe(firstId);
        expect(views[0].ViewMode).toBe('gantt');
        expect(views[0].CategoryID).toBe('cat-fin');

        // Delete removes matching view
        expect(DeleteSavedTaskFilterView(views, firstId)).toEqual([]);

        // Cap enforcement
        let capped: SavedTaskFilterView[] = [];
        for (let i = 0; i < MAX_SAVED_TASK_VIEWS + 5; i++) {
            capped = UpsertSavedTaskFilterView(capped, {
                Name: `View ${i}`,
                CategoryID: null,
                Filters: {},
            });
        }
        expect(capped).toHaveLength(MAX_SAVED_TASK_VIEWS);
    });

    it('formats status and activity type enums into human-readable labels', () => {
        expect(FormatTaskStatusLabel('InProgress')).toBe('In Progress');
        expect(FormatTaskStatusLabel('NotStarted')).toBe('Not Started');
        expect(FormatTaskStatusLabel('OnTrack')).toBe('On Track');
        expect(FormatTaskStatusLabel('AtRisk')).toBe('At Risk');
        expect(FormatTaskStatusLabel('OffTrack')).toBe('Off Track');
        expect(FormatTaskStatusLabel('Completed')).toBe('Completed');
        expect(FormatTaskStatusLabel(null)).toBe('Open');

        expect(FormatTaskActivityTypeLabel('StatusChange')).toBe('Status Change');
        expect(FormatTaskActivityTypeLabel('AssignmentAdded')).toBe('Assignment Added');
        expect(FormatTaskActivityTypeLabel('Check_In')).toBe('Check In');
        expect(FormatTaskActivityTypeLabel(undefined)).toBe('Update');
    });
});
