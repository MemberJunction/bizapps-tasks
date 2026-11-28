import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { TaskHeaderPanel } from '../task-header.panel';

vi.mock('@memberjunction/ng-base-forms', () => ({
    BaseFormPanel: class {
        Record: unknown = null;
    },
}));

vi.mock('@memberjunction/core-entities', () => ({
    UserInfoEngine: {
        Instance: {
            GetSetting: vi.fn(() => null),
            SetSettingDebounced: vi.fn(),
        },
    },
}));

describe('TaskHeaderPanel', () => {
    function createHeaderPanel(record?: Partial<mjBizAppsTasksTaskEntity>): TaskHeaderPanel {
        const cdr: ChangeDetectorRef = {
            markForCheck: vi.fn(),
            detach: vi.fn(),
            detectChanges: vi.fn(),
            checkNoChanges: vi.fn(),
            reattach: vi.fn(),
        };
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: cdr }],
        });
        const panel = runInInjectionContext(injector, () => new TaskHeaderPanel());
        if (record) {
            panel.Record = record as mjBizAppsTasksTaskEntity;
        }
        return panel;
    }

    it('reads HoursEstimated and HoursActual from the typed Task entity (never non-existent EstimatedHours/ActualHours fields)', () => {
        const record = {
            ID: '11111111-1111-4111-8111-111111111111',
            Name: 'Ship MJ 6.3 RelatedRecordCollection',
            HoursEstimated: 12.5,
            HoursActual: 9.25,
            Get: vi.fn(() => {
                throw new Error('Must not call dynamic .Get()');
            }),
        } as unknown as Partial<mjBizAppsTasksTaskEntity>;

        const panel = createHeaderPanel(record);

        expect(panel.EstimatedHours).toBe(12.5);
        expect(panel.ActualHours).toBe(9.25);
        expect(panel.Title).toBe('Ship MJ 6.3 RelatedRecordCollection');
    });

    it('defaults EstimatedHours and ActualHours to 0 when unset or Record is null', () => {
        const emptyPanel = createHeaderPanel();
        expect(emptyPanel.EstimatedHours).toBe(0);
        expect(emptyPanel.ActualHours).toBe(0);

        const nullHoursPanel = createHeaderPanel({
            HoursEstimated: null,
            HoursActual: null,
        });
        expect(nullHoursPanel.EstimatedHours).toBe(0);
        expect(nullHoursPanel.ActualHours).toBe(0);
    });
});
