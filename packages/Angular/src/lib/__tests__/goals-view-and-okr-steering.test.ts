import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, SimpleChange, runInInjectionContext } from '@angular/core';
import type { RunViewParams } from '@memberjunction/core';
import { LEGACY_OKR_TASK_TYPE_IDS } from '@mj-biz-apps/tasks-entities';

interface LegacyOkrTaskRow {
    ID: string;
    Name: string;
    Type: string | null;
    Status: string;
    PercentComplete: number | null;
    PlanningPeriod: string | null;
    HealthStatus: string | null;
}

interface MockTaskTypeOptionRow {
    ID: string;
    Name: string;
    Code: string;
    IconClass: string | null;
    DefaultPriority: 'Low' | 'Medium' | 'High' | 'Critical';
    IsApproval: boolean;
    OnCompleteAction: string | null;
    OnRejectAction: string | null;
    OnCancelAction: string | null;
    ExtensionEntity?: string | null;
    IsActive?: boolean | null;
}

type MockRunViewRow = LegacyOkrTaskRow | MockTaskTypeOptionRow;

interface MockRunViewResult<T = MockRunViewRow> {
    Success: boolean;
    Results: T[];
    ErrorMessage?: string;
}

const { runViewMock, openTaskRecordMock, getEntityObjectMock } = vi.hoisted(() => ({
    runViewMock: vi.fn<[RunViewParams], Promise<MockRunViewResult | undefined>>(),
    openTaskRecordMock: vi.fn<[string | null | undefined], void>(),
    getEntityObjectMock: vi.fn(),
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: [],
        Roles: [],
        EntityByName: () => undefined,
        EntityByID: () => undefined,
        GetEntityObject: (entityName: string) => getEntityObjectMock(entityName),
    };
    return {
        ...actual,
        RunView: class {
            static FromMetadataProvider() {
                return new this();
            }
            RunView(params: RunViewParams): Promise<MockRunViewResult | undefined> {
                return runViewMock(params);
            }
        },
        Metadata: Object.assign(
            class {
                Entities = [];
                GetEntityObject(entityName: string) {
                    return getEntityObjectMock(entityName);
                }
            },
            { Provider: provider },
        ),
    };
});

vi.mock('../open-task-record', () => ({
    OpenTaskRecord: (taskID: string | null | undefined) => openTaskRecordMock(taskID),
}));

import {
    GOALS_EMPTY_STATE_MESSAGE,
    GOALS_EMPTY_STATE_TITLE,
    GOALS_IMPORT_ACTION_NAME,
    GOALS_PLANNING_APP_NAME,
    GoalsViewComponent,
} from '../components/goals-view/goals-view.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ANGULAR_LIB_DIR = join(__dirname, '..');
const REPO_ROOT = join(ANGULAR_LIB_DIR, '../../../..');

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

function createInContext<T>(factory: () => T): T {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
    });
    return runInInjectionContext(injector, factory);
}

beforeEach(() => {
    vi.resetAllMocks();
});

describe('GoalsViewComponent Empty State, In-App Help & Legacy OKR Readability', () => {
    it('exposes BizApps Planning and Import Tasks OKRs steering copy in empty state and in-app help', () => {
        const comp = createInContext(() => new GoalsViewComponent());

        expect(comp.PlanningAppName).toBe(GOALS_PLANNING_APP_NAME);
        expect(comp.ImportActionName).toBe(GOALS_IMPORT_ACTION_NAME);
        expect(comp.EmptyStateTitle).toContain('BizApps Planning');
        expect(comp.EmptyStateMessage).toContain('BizApps Planning');
        expect(comp.EmptyStateMessage).toContain('Import Tasks OKRs');
        expect(GOALS_EMPTY_STATE_TITLE).toContain('BizApps Planning');
        expect(GOALS_EMPTY_STATE_MESSAGE).toContain('PRIORITY_OBJECTIVE');
        expect(GOALS_EMPTY_STATE_MESSAGE).toContain('KEY_RESULT');
        expect(GOALS_EMPTY_STATE_MESSAGE).toContain('Import Tasks OKRs');

        const source = readFileSync(join(ANGULAR_LIB_DIR, 'components/goals-view/goals-view.component.ts'), 'utf8');
        expect(source).toContain('In-App Help: Migrating Goals &amp; OKRs');
        expect(source).toContain('DryRun: true');
        expect(source).toContain('PRIORITY_OBJECTIVE');
        expect(source).toContain('KEY_RESULT');
    });

    it('safely loads legacy PRIORITY_OBJECTIVE and KEY_RESULT tasks when present and handles empty/error states', async () => {
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [
                {
                    ID: '11111111-1111-4111-8111-111111111111',
                    Name: 'Legacy Annual Revenue Objective',
                    Type: 'Priority Objective',
                    Status: 'InProgress',
                    PercentComplete: 45,
                    PlanningPeriod: 'Q4 2026',
                    HealthStatus: 'OnTrack',
                },
                {
                    ID: '22222222-2222-4222-8222-222222222222',
                    Name: 'Legacy Net Retention KR',
                    Type: 'Key Result',
                    Status: 'Open',
                    PercentComplete: null,
                    PlanningPeriod: null,
                    HealthStatus: null,
                },
            ],
        });

        const comp = createInContext(() => new GoalsViewComponent());
        await comp.ngOnInit();

        expect(runViewMock).toHaveBeenCalledTimes(1);
        const queryArg = runViewMock.mock.calls[0][0];
        expect(queryArg.EntityName).toBe('MJ_BizApps_Tasks: Tasks');
        for (const legacyId of LEGACY_OKR_TASK_TYPE_IDS) {
            expect(queryArg.ExtraFilter).toContain(legacyId);
        }
        expect(comp.Loading).toBe(false);
        expect(comp.LoadError).toBeNull();
        expect(comp.LegacyTasks).toHaveLength(2);
        expect(comp.LegacyTasks[0].Name).toBe('Legacy Annual Revenue Objective');
        expect(comp.LegacyTasks[1].PercentComplete).toBe(0);

        const selected: string[] = [];
        comp.TaskSelected.subscribe((id) => selected.push(id));
        comp.OnSelectTask('11111111-1111-4111-8111-111111111111');
        expect(selected).toEqual(['11111111-1111-4111-8111-111111111111']);
        expect(openTaskRecordMock).toHaveBeenCalledWith('11111111-1111-4111-8111-111111111111');

        // Empty result transitions cleanly to empty state
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });
        await comp.LoadLegacyOkrTasks();
        expect(comp.LegacyTasks).toEqual([]);
        expect(comp.LoadError).toBeNull();

        // Failed query sets LoadError without throwing
        runViewMock.mockResolvedValueOnce({ Success: false, Results: [], ErrorMessage: 'Database unavailable' });
        await comp.LoadLegacyOkrTasks();
        expect(comp.LegacyTasks).toEqual([]);
        expect(comp.LoadError).toBe('Database unavailable');
    });

    it('TasksDashboardPageComponent exposes OKRs & Goals Help drawer and TaskEditPanelComponent surfaces legacy OKR steering text', async () => {
        const dashboard = createInContext(() => new TasksDashboardPageComponent());
        dashboard.OpenPanel('help');
        expect(dashboard.PanelMode).toBe('help');
        expect(dashboard.DrawerTitle).toBe('OKRs & Goals Help');
        dashboard.ClosePanel();
        expect(dashboard.PanelMode).toBe('none');

        const legacyKrType: MockTaskTypeOptionRow = {
            ID: '8d42a1b9-3e71-4c5a-9f20-1b6e8d3a9c02',
            Name: 'Key Result',
            Code: 'KEY_RESULT',
            IconClass: 'fa-solid fa-chart-line',
            DefaultPriority: 'High',
            IsApproval: false,
            OnCompleteAction: null,
            OnRejectAction: null,
            OnCancelAction: null,
            ExtensionEntity: null,
            IsActive: false,
        };
        const planningPriorityType: MockTaskTypeOptionRow = {
            ID: '7e100001-0000-0000-0000-000000000001',
            Name: 'Priority',
            Code: 'PRIORITY',
            IconClass: 'fa-solid fa-bullseye',
            DefaultPriority: 'High',
            IsApproval: false,
            OnCompleteAction: null,
            OnRejectAction: null,
            OnCancelAction: null,
            ExtensionEntity: 'MJ_BizApps_Planning: Priority Tasks',
            IsActive: true,
        };
        const generalType: MockTaskTypeOptionRow = {
            ID: 'f7c1e8de-8dac-4bf8-943e-3d5a1210be82',
            Name: 'General',
            Code: 'GENERAL',
            IconClass: 'fa-solid fa-circle-check',
            DefaultPriority: 'Medium',
            IsApproval: false,
            OnCompleteAction: null,
            OnRejectAction: null,
            OnCancelAction: null,
            ExtensionEntity: null,
            IsActive: true,
        };

        runViewMock.mockImplementation(async (params: RunViewParams): Promise<MockRunViewResult> => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
                return { Success: true, Results: [legacyKrType, planningPriorityType, generalType] };
            }
            return { Success: true, Results: [] };
        });

        const legacyTaskStub = {
            ID: '33333333-3333-4333-8333-333333333333',
            Name: 'Legacy KR',
            Description: null,
            Status: 'InProgress',
            Priority: 'High',
            StartedAt: null,
            DueAt: null,
            PercentComplete: 50,
            HoursEstimated: null,
            HoursActual: null,
            BlockedReason: null,
            CompletionNotes: null,
            TypeID: legacyKrType.ID,
            TaskTypeStatusID: null,
            CategoryID: null,
            OrganizationID: null,
            ParentID: null,
            BaselineValue: 0,
            TargetValue: 100,
            CurrentValue: 50,
            UnitOfMeasure: '%',
            MetricDirection: 'Increase',
            PlanningPeriod: 'Q4 2026',
            CheckInCadence: 'Weekly',
            InnerLoad: vi.fn(async () => true),
            Save: vi.fn(async () => true),
            LatestResult: { CompleteMessage: '' },
            Assignments: { Items: [], Load: vi.fn(async () => true), Create: vi.fn(), Remove: vi.fn() },
            TagLinks: { Items: [], Load: vi.fn(async () => true), Create: vi.fn(), Remove: vi.fn() },
            Links: { Items: [], Load: vi.fn(async () => true), Create: vi.fn(), Remove: vi.fn() },
        };
        getEntityObjectMock.mockResolvedValueOnce(legacyTaskStub);

        const editPanel = createInContext(() => new TaskEditPanelComponent());
        editPanel.TaskID = legacyTaskStub.ID;
        editPanel.ngOnChanges({ TaskID: new SimpleChange(null, legacyTaskStub.ID, true) });

        await vi.waitFor(() => {
            expect(editPanel.loading).toBe(false);
            expect(editPanel.form.Name).toBe('Legacy KR');
        });

        expect(editPanel.currentTypeOwnershipNote).toBe('Legacy OKR type (read-only)');
        expect(editPanel.legacyOkrMigrationHelpText).toContain('BizApps Planning');
        expect(editPanel.legacyOkrMigrationHelpText).toContain('Import Tasks OKRs');

        editPanel.form.TypeID = planningPriorityType.ID;
        expect(editPanel.currentTypeOwnershipNote).toBe('Managed in Planning');
        expect(editPanel.legacyOkrMigrationHelpText).toBeNull();
    });

    it('enforces strict --mj-* CSS custom properties with zero raw hex/rgb/hsl color literals in Goals view and updated Angular components', () => {
        const filesToLint = [
            'components/goals-view/goals-view.component.ts',
            'pages/tasks-dashboard.page.ts',
            'components/task-edit-panel/task-edit-panel.component.ts',
        ];

        for (const relPath of filesToLint) {
            const source = readFileSync(join(ANGULAR_LIB_DIR, relPath), 'utf8');
            expect(source).toContain('ChangeDetectionStrategy.OnPush');
            expect(source).not.toMatch(/\bwindow\.print\s*\(/);
            expect(source).not.toMatch(/\blocalStorage\s*[.\[]/);

            const stylesMatch = source.match(/styles:\s*\[`([\s\S]*?)`\]/);
            expect(stylesMatch, `Missing styles block in ${relPath}`).not.toBeNull();
            const css = stylesMatch![1];
            expect(css, `Must reference --mj-* tokens in ${relPath}`).toContain('--mj-');
            expect(css, `Forbidden #hex literal in CSS of ${relPath}`).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
            expect(css, `Forbidden rgb/rgba/hsl/hsla literal in CSS of ${relPath}`).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);

            const templateMatch = source.match(/template:\s*`([\s\S]*?)`/);
            expect(templateMatch, `Missing template block in ${relPath}`).not.toBeNull();
            const html = templateMatch![1];
            expect(html, `Forbidden #hex literal in HTML of ${relPath}`).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
            expect(html, `Forbidden rgb/rgba/hsl/hsla literal in HTML of ${relPath}`).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);

            expect(source, `Forbidden #hex literal in source of ${relPath}`).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
            expect(source, `Forbidden rgb/rgba/hsl/hsla literal in source of ${relPath}`).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);
        }
    });
});

describe('Chief of Staff Tasks Skill & Documentation OKR Steering', () => {
    it('updates Chief of Staff Tasks skill prompt and metadata to steer OKRs to BizApps Planning and Import Tasks OKRs', () => {
        const skillPrompt = readFileSync(
            join(REPO_ROOT, 'metadata/chief-of-staff-skills/templates/chief-of-staff-tasks.skill.md'),
            'utf8',
        );
        const skillJson = readFileSync(
            join(REPO_ROOT, 'metadata/chief-of-staff-skills/.chief-of-staff-tasks-skill.json'),
            'utf8',
        );

        expect(skillPrompt).toContain('BizApps Planning');
        expect(skillPrompt).toContain('Import Tasks OKRs');
        expect(skillPrompt).toContain('PRIORITY_OBJECTIVE');
        expect(skillPrompt).toContain('KEY_RESULT');
        expect(skillPrompt).toContain('IsActive = false');

        expect(skillJson).toContain('BizApps Planning');
        expect(skillJson).toContain('Import Tasks OKRs');
    });

    it('updates README.md, docs/, and guides/ to document 1.x OKR deactivation, column preservation, BizApps Planning, and Import Tasks OKRs', () => {
        const readme = readFileSync(join(REPO_ROOT, 'README.md'), 'utf8');
        const migrationDoc = readFileSync(join(REPO_ROOT, 'docs/OKR_DEPRECATION_AND_PLANNING_MIGRATION.md'), 'utf8');
        const workflowGuide = readFileSync(join(REPO_ROOT, 'guides/TASK_WORKFLOW_AND_LIFECYCLE_GUIDE.md'), 'utf8');
        const workBusGuide = readFileSync(join(REPO_ROOT, 'guides/WORK_BUS_AND_15FIVE_REPORTS_GUIDE.md'), 'utf8');

        for (const doc of [readme, migrationDoc, workflowGuide, workBusGuide]) {
            expect(doc).toContain('PRIORITY_OBJECTIVE');
            expect(doc).toContain('KEY_RESULT');
            expect(doc).toContain('IsActive = false');
            expect(doc).toContain('BizApps Planning');
            expect(doc).toContain('Import Tasks OKRs');
        }

        expect(readme.toLowerCase()).toContain('deprecate-then-remove');
        expect(readme).toContain('docs/OKR_DEPRECATION_AND_PLANNING_MIGRATION.md');
        expect(migrationDoc).toContain('V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.sql');
        expect(migrationDoc).toContain('V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.pg.sql');
    });
});
