// @vitest-environment jsdom
import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { ChangeDetectorRef, ElementRef, Injector, runInInjectionContext } from '@angular/core';
import type { GanttStatic } from 'dhtmlx-gantt';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { UserInfoEngine } from '@memberjunction/core-entities';

const { runViewMock } = vi.hoisted(() => ({ runViewMock: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    Metadata: {
        Provider: {
            EntityByName: vi.fn(() => undefined),
            Roles: [],
        },
    },
    RunView: class {
        RunView = runViewMock;
    },
}));

import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TASKS_GANTT_PREF_SETTING } from '../components/task-gantt/gantt-zoom-pref';

const HERE = dirname(fileURLToPath(import.meta.url));
const ANGULAR_ROOT = resolve(HERE, '..', '..', '..');
const require = createRequire(import.meta.url);

interface DhtmlxEsModule {
    gantt: GanttStatic;
}

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

describe('dhtmlx-gantt ^10.x (MIT) upgrade & compatibility', () => {
    it('declares dhtmlx-gantt ^10.x in packages/Angular/package.json and resolves MIT 10.x', () => {
        const pkgJson = JSON.parse(readFileSync(resolve(ANGULAR_ROOT, 'package.json'), 'utf8')) as {
            dependencies: Record<string, string>;
        };
        expect(pkgJson.dependencies['dhtmlx-gantt']).toMatch(/^\^10\./);

        const resolvedPkgPath = require.resolve('dhtmlx-gantt/package.json', { paths: [ANGULAR_ROOT] });
        const resolvedPkg = JSON.parse(readFileSync(resolvedPkgPath, 'utf8')) as {
            version: string;
            license: string;
        };
        expect(resolvedPkg.version.startsWith('10.')).toBe(true);
        expect(resolvedPkg.license).toBe('MIT');

        const licenseText = readFileSync(resolve(dirname(resolvedPkgPath), 'LICENSE.md'), 'utf8');
        expect(licenseText).toContain('The MIT License (MIT)');
    });

    it('initializes dhtmlx-gantt v10, binds hierarchical tasks & links, handles zoom, and tears down cleanly', async () => {
        const container = document.createElement('div');
        container.id = 'gantt-v10-host';
        container.style.width = '960px';
        container.style.height = '480px';
        document.body.appendChild(container);

        try {
            const resolvedPkgPath = require.resolve('dhtmlx-gantt/package.json', { paths: [ANGULAR_ROOT] });
            const esmUrl = pathToFileURL(resolve(dirname(resolvedPkgPath), 'codebase/dhtmlxgantt.es.js')).href;
            const dhxModule = (await import(/* @vite-ignore */ esmUrl)) as DhtmlxEsModule;
            const gantt = dhxModule.gantt;
            expect(gantt.license).toBe('mit');
            expect(gantt.version.startsWith('10.')).toBe(true);

            gantt.config.date_format = '%Y-%m-%d %H:%i';
            gantt.config.readonly = true;
            gantt.config.open_tree_initially = true;
            gantt.init(container);

            gantt.ext.zoom.init({
                levels: [
                    { name: 'day', scale_height: 40, min_column_width: 40, scales: [{ unit: 'day', step: 1, format: '%d %M' }] },
                    { name: 'week', scale_height: 40, min_column_width: 50, scales: [{ unit: 'week', step: 1, format: 'W%W' }] },
                    { name: 'month', scale_height: 40, min_column_width: 60, scales: [{ unit: 'month', step: 1, format: '%M' }] },
                ],
            });
            gantt.ext.zoom.setLevel('month');
            expect(gantt.ext.zoom.getCurrentLevel()).toBe(2);
            gantt.ext.zoom.zoomIn();
            expect(gantt.ext.zoom.getCurrentLevel()).toBe(1);

            gantt.parse({
                data: [
                    { id: 'root-1', text: 'Q4 Close Parent', start_date: '2026-11-01 00:00', duration: 10, progress: 0.5, open: true },
                    { id: 'child-1', text: 'Reconcile Subledger', start_date: '2026-11-02 00:00', duration: 4, progress: 1, parent: 'root-1' },
                    { id: 'child-2', text: 'Controller Signoff', start_date: '2026-11-06 00:00', duration: 3, progress: 0.25, parent: 'root-1' },
                ],
                links: [{ id: 'link-1', source: 'child-1', target: 'child-2', type: '0' }],
            });

            expect(gantt.getTaskCount()).toBe(3);
            expect(gantt.getParent('child-1')).toBe('root-1');
            expect(gantt.getChildren('root-1')).toEqual(['child-1', 'child-2']);
            expect(gantt.getLinks()).toHaveLength(1);

            gantt.clearAll();
            expect(gantt.getTaskCount()).toBe(0);
            expect(gantt.getLinks()).toHaveLength(0);
        } finally {
            container.remove();
        }
    });
});

describe('TaskGanttComponent lifecycle, data binding, zoom persistence & teardown', () => {
    beforeEach(() => {
        runViewMock.mockReset();
    });

    it('binds hierarchical tasks, dependency links, zoom preferences via UserInfoEngine, and cleans up on destroy', async () => {
        const PARENT_ID = '11111111-1111-4111-8111-111111111111';
        const CHILD_ID = '22222222-2222-4222-8222-222222222222';
        const DEP_ID = '33333333-3333-4333-8333-333333333333';

        const getSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(
            JSON.stringify({ zoomLevel: 'week', zoomPercent: 100, gridWidth: 640 }),
        );
        const setSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});

        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: PARENT_ID,
                            Name: 'Close Cycle',
                            Description: null,
                            StartedAt: '2026-11-01T00:00:00Z',
                            DueAt: '2026-11-15T00:00:00Z',
                            PercentComplete: 40,
                            HoursEstimated: 16,
                            ParentID: null,
                            Status: 'InProgress',
                            Priority: 'High',
                            TaskTypeStatus: null,
                            OrganizationID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                            Organization: 'Acme US LLC',
                            Sequence: 1,
                        },
                        {
                            ID: CHILD_ID,
                            Name: 'Approve Close',
                            Description: null,
                            StartedAt: '2026-11-05T00:00:00Z',
                            DueAt: '2026-11-10T00:00:00Z',
                            PercentComplete: 0,
                            HoursEstimated: 4,
                            ParentID: PARENT_ID,
                            Status: 'Open',
                            Priority: 'Critical',
                            TaskTypeStatus: null,
                            OrganizationID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                            Organization: 'Acme US LLC',
                            Sequence: 2,
                        },
                    ],
                });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Dependencies') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        { ID: DEP_ID, TaskID: CHILD_ID, DependsOnTaskID: PARENT_ID, DependencyType: 'FinishToStart' },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const hostEl = document.createElement('div');
        const addListenerSpy = vi.spyOn(hostEl, 'addEventListener');
        const removeListenerSpy = vi.spyOn(hostEl, 'removeEventListener');

        const injector = Injector.create({
            providers: [
                { provide: ChangeDetectorRef, useValue: createCdr() },
                { provide: ElementRef, useValue: { nativeElement: hostEl } },
            ],
        });

        const ganttComp = runInInjectionContext(injector, () => new TaskGanttComponent());
        try {
            ganttComp.ngOnInit();
            expect(ganttComp.ZoomLevel).toBe('week');

            await ganttComp.LoadData();
            expect(ganttComp.items).toHaveLength(2);
            expect(ganttComp.items[1].ParentID).toBe(PARENT_ID);
            expect(ganttComp.links).toEqual([
                { ID: DEP_ID, SourceID: PARENT_ID, TargetID: CHILD_ID, Type: 'FS' },
            ]);

            ganttComp.OnAfterZoomChange({ Level: 'month', Percent: 75, PreviousLevel: 'week' });
            expect(ganttComp.ZoomLevel).toBe('month');
            expect(setSettingSpy).toHaveBeenCalledWith(
                TASKS_GANTT_PREF_SETTING,
                expect.stringContaining('"zoomLevel":"month"'),
            );

            ganttComp.ngAfterViewInit();
            expect(addListenerSpy).toHaveBeenCalledWith('click', expect.any(Function), true);
            ganttComp.ngOnDestroy();
            expect(removeListenerSpy).toHaveBeenCalledWith('click', expect.any(Function), true);
        } finally {
            getSettingSpy.mockRestore();
            setSettingSpy.mockRestore();
        }
    });
});
