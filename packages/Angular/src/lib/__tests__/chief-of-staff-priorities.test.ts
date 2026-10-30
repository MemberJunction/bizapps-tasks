/**
 * The "Priorities & To-dos" page the Tasks app adds to the Chief of Staff application: it resolves
 * the signed-in person, loads only their scoped tasks, completes to-dos through the Task entity,
 * reloads on task or assignment changes, and validates what the co-agent asks of it.
 */
import '@angular/compiler';
import { describe, expect, it, vi, beforeEach, type Mock } from 'vitest';
import { MJEventType, UUIDSet, type MJEvent } from '@memberjunction/global';
import { BaseEntity } from '@memberjunction/core';

const { runView, resolvePerson } = vi.hoisted(() => ({ runView: vi.fn(), resolvePerson: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        RunView: class {
            static FromMetadataProvider() {
                return { RunView: runView };
            }
            RunView = runView;
        },
    };
});
vi.mock('../current-person', () => ({
    ResolveCurrentPersonID: resolvePerson,
    NO_PERSON_MESSAGE: 'no person',
    PERSON_LOOKUP_FAILED_MESSAGE: 'lookup failed',
}));
vi.mock('../open-task-record', () => ({ OpenTaskRecord: vi.fn() }));

import { ChiefOfStaffPrioritiesResource, IsTasksEntityChange } from '../chief-of-staff/chief-of-staff-priorities.component';
import { BuildPrioritySummary, type PriorityTaskRow } from '@mj-biz-apps/tasks-core';

type Open = Record<string, unknown>;

interface FakeTaskEntity {
    Load: Mock<[string], Promise<boolean>>;
    Save: Mock<[], Promise<boolean>>;
    Status: string;
    LatestResult: { CompleteMessage: string } | null;
}

interface Harness {
    page: ChiefOfStaffPrioritiesResource;
    context: ReturnType<typeof vi.fn>;
    entity: FakeTaskEntity;
}

function createPage(): Harness {
    const page = Object.create(ChiefOfStaffPrioritiesResource.prototype) as ChiefOfStaffPrioritiesResource;
    const open = page as unknown as Open;
    const context = vi.fn();
    const entity: FakeTaskEntity = { Load: vi.fn(async (_id: string): Promise<boolean> => true), Save: vi.fn(async (): Promise<boolean> => true), Status: 'Open', LatestResult: null };
    open['cdr'] = { markForCheck: vi.fn() };
    open['navigationService'] = { IsResourceDetached: () => false, SetAgentContext: context };
    open['expanded'] = new UUIDSet();
    open['Summary'] = BuildPrioritySummary([]);
    open['HealthFilter'] = 'all';
    open['SearchText'] = '';
    open['BusyTodoID'] = null;
    open['Banner'] = null;
    open['initialParamsApplied'] = false;
    Object.defineProperty(page, 'ProviderToUse', {
        get: () => ({
            CurrentUser: { ID: 'U1' },
            Entities: [{ Name: 'MJ_BizApps_Common: People', ID: 'PEOPLE-ENTITY' }],
            GetEntityObject: vi.fn(async () => entity),
        }),
        configurable: true,
    });
    return { page, context, entity };
}

function task(over: Partial<PriorityTaskRow>): PriorityTaskRow {
    return {
        ID: 'R1', ParentID: null, Name: 'Launch', Description: null, Status: 'Open', Priority: 'High', HealthStatus: 'OnTrack',
        ConfidenceScore: null, PercentComplete: null, CheckInCadence: null, PlanningPeriod: '2026-Q4', BaselineValue: null,
        TargetValue: null, CurrentValue: null, UnitOfMeasure: null, MetricDirection: null, DueAt: null, LastCheckInAt: null,
        NextCheckInDueAt: null, Type: 'Objective', CreatedByPersonID: 'P1', ...over,
    };
}

function entityEvent(type: 'save' | 'remote-invalidate', entityName: string): MJEvent {
    const args = type === 'remote-invalidate'
        ? { type, entityName, baseEntity: null }
        : { type, baseEntity: { EntityInfo: { Name: entityName } } };
    return { event: MJEventType.ComponentEvent, eventCode: BaseEntity.BaseEventCode, args, component: null } as unknown as MJEvent;
}

describe('IsTasksEntityChange', () => {
    it('matches saves and remote invalidations of tasks and task assignments only', () => {
        expect(IsTasksEntityChange(entityEvent('remote-invalidate', 'MJ_BizApps_Tasks: Tasks'))).toBe(true);
        expect(IsTasksEntityChange(entityEvent('save', 'mj_bizapps_tasks: task assignments'))).toBe(true);
        expect(IsTasksEntityChange(entityEvent('save', 'MJ: AI Agent Requests'))).toBe(false);
        expect(IsTasksEntityChange({ event: MJEventType.ComponentEvent, eventCode: 'other', args: {}, component: null } as unknown as MJEvent)).toBe(false);
    });
});

describe('ChiefOfStaffPrioritiesResource.Load', () => {
    beforeEach(() => {
        runView.mockReset();
        resolvePerson.mockReset();
    });

    it('shows the no-person message and runs no task query when the user has no People record', async () => {
        resolvePerson.mockResolvedValue(null);
        const { page } = createPage();

        await page.Load();

        expect(page.PersonMessage).toBe('no person');
        expect(runView).not.toHaveBeenCalled();
        expect(page.IsLoading).toBe(false);
    });

    it('loads only the person\'s scoped tasks and builds the summary', async () => {
        resolvePerson.mockResolvedValue('P1');
        runView.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks' && (params as { Fields?: string[] }).Fields?.includes('Name')) {
                return { Success: true, Results: [task({}), task({ ID: 'M1', ParentID: 'R1', Name: 'Step', Type: 'Milestone', HealthStatus: null })] };
            }
            return { Success: true, Results: [] };
        });
        const { page, context } = createPage();

        await page.Load();

        const taskQuery = runView.mock.calls.map((c) => c[0] as { EntityName: string; ExtraFilter?: string; Fields?: string[] })
            .find((p) => p.EntityName === 'MJ_BizApps_Tasks: Tasks' && p.Fields?.includes('Name'));
        expect(taskQuery?.ExtraFilter).toBe("CreatedByPersonID = 'P1'");
        expect(page.Summary.PriorityObjectiveCount).toBe(1);
        expect(page.Summary.Cards[0].Milestones.map((m) => m.Task.ID)).toEqual(['M1']);
        expect(context).toHaveBeenCalled();
        expect(page.PersonMessage).toBeNull();
    });

    it('reports a failed person lookup instead of loading', async () => {
        resolvePerson.mockRejectedValue(new Error('down'));
        const { page } = createPage();
        await page.Load();
        expect(page.PersonMessage).toBe('lookup failed');
        expect(runView).not.toHaveBeenCalled();
    });
});

describe('ChiefOfStaffPrioritiesResource.MarkTodoDone', () => {
    beforeEach(() => {
        runView.mockReset().mockResolvedValue({ Success: true, Results: [] });
        resolvePerson.mockReset().mockResolvedValue('P1');
    });

    it('completes the task through the Task entity', async () => {
        const { page, entity } = createPage();
        await page.MarkTodoDone(task({ ID: 'T1', Name: 'Call Mom', Type: 'General' }));
        expect(entity.Load).toHaveBeenCalledWith('T1');
        expect(entity.Status).toBe('Completed');
        expect(entity.Save).toHaveBeenCalled();
        expect(page.Banner?.Type).toBe('success');
        expect(page.BusyTodoID).toBeNull();
    });

    it('shows the save error when the entity refuses', async () => {
        const { page, entity } = createPage();
        entity.Save.mockResolvedValue(false);
        entity.LatestResult = { CompleteMessage: 'not allowed' };
        await page.MarkTodoDone(task({ ID: 'T1', Name: 'Call Mom', Type: 'General' }));
        expect(page.Banner).toEqual({ Type: 'error', Message: 'Could not mark "Call Mom" done: not allowed' });
    });
});
