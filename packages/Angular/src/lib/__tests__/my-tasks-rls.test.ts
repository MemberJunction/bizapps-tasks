import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import type { IMetadataProvider, IRunViewProvider, RunViewParams, UserInfo } from '@memberjunction/core';
import { MyTasksComponent } from '../components/my-tasks/my-tasks.component';
import { TaskListComponent } from '../components/task-list/task-list.component';

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

function createMyTasks(): MyTasksComponent {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
    });
    return runInInjectionContext(injector, () => new MyTasksComponent());
}

function createTaskList(): TaskListComponent {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
    });
    return runInInjectionContext(injector, () => new TaskListComponent());
}

interface MockEntityPermission {
    CanRead: boolean;
}

function createMockProvider(options: {
    runView: ReturnType<typeof vi.fn>;
    currentUser?: Partial<UserInfo>;
    readableEntities?: Record<string, boolean>;
    rolesEntityId?: string;
}): IMetadataProvider & IRunViewProvider {
    const rolesEntityId = options.rolesEntityId ?? 'A0000000-0000-0000-0000-000000000003';
    const readable = options.readableEntities ?? {};
    return {
        CurrentUser: options.currentUser as UserInfo | undefined,
        Roles: [],
        EntityByName: (name: string) => {
            if (name === 'MJ: Roles') {
                return {
                    ID: rolesEntityId,
                    Name: name,
                    GetUserPermisions: (): MockEntityPermission => ({ CanRead: true }),
                };
            }
            if (name in readable) {
                return {
                    ID: `entity-${name}`,
                    Name: name,
                    GetUserPermisions: (): MockEntityPermission => ({ CanRead: readable[name] }),
                };
            }
            return {
                ID: `entity-${name}`,
                Name: name,
                GetUserPermisions: (): MockEntityPermission => ({ CanRead: true }),
            };
        },
        RunView: options.runView,
        RunViews: vi.fn(),
    } as unknown as IMetadataProvider & IRunViewProvider;
}

describe('MyTasksComponent RLS-safe two-step lookup', () => {
    it('resolves assigned TaskIDs via first-class Task Assignments RunView with zero vwTaskAssignments subqueries', async () => {
        const personId = '11111111-1111-4111-8111-111111111111';
        const roleId = '22222222-2222-4222-8222-222222222222';
        const runView = vi.fn().mockResolvedValue({
            Success: true,
            Results: [
                { TaskID: 'AAAA0001-0000-4000-8000-000000000001' },
                { TaskID: 'aaaa0001-0000-4000-8000-000000000001' },
                { TaskID: 'AAAA0002-0000-4000-8000-000000000002' },
            ],
        });
        const provider = createMockProvider({
            runView,
            currentUser: { ID: 'u-1', UserRoles: [{ RoleID: roleId }] as UserInfo['UserRoles'] },
        });

        const component = createMyTasks();
        component.Provider = provider;
        component.PersonID = personId;
        await component.Refresh();

        expect(component.loadError).toBeNull();
        expect(component.assignmentsLoaded).toBe(true);
        expect(component.assignedTaskIds).toEqual([
            'AAAA0001-0000-4000-8000-000000000001',
            'AAAA0002-0000-4000-8000-000000000002',
        ]);
        expect(runView).toHaveBeenCalledTimes(1);
        const params = runView.mock.calls[0][0] as RunViewParams;
        expect(params.EntityName).toBe('MJ_BizApps_Tasks: Task Assignments');
        expect(params.Fields).toEqual(['TaskID']);
        expect(params.ResultType).toBe('simple');
        expect(params.ExtraFilter).toContain(`AssigneeRecordID = '${personId}'`);
        expect(params.ExtraFilter).toContain(roleId.toUpperCase());
        expect(params.ExtraFilter).not.toContain('vwTaskAssignments');
    });

    it('surfaces Task Assignments RunView failure instead of silently showing empty state', async () => {
        const runView = vi.fn().mockResolvedValue({
            Success: false,
            ErrorMessage: 'RLS lookup failed',
            Results: [],
        });
        const component = createMyTasks();
        component.Provider = createMockProvider({ runView });
        component.PersonID = 'person-1';
        await component.Refresh();

        expect(component.loadError).toBe('RLS lookup failed');
        expect(component.assignedTaskIds).toEqual([]);
        expect(component.assignmentsLoaded).toBe(true);
    });

    it('fires zero queries when PersonID is empty', async () => {
        const runView = vi.fn();
        const component = createMyTasks();
        component.Provider = createMockProvider({ runView });
        component.PersonID = '';
        await component.Refresh();

        expect(runView).not.toHaveBeenCalled();
        expect(component.assignedTaskIds).toEqual([]);
        expect(component.assignmentsLoaded).toBe(true);
    });
});

describe('TaskListComponent RLS-safe PreloadedTaskIds, error handling, and permission gating', () => {
    it('fires zero RunView queries when PreloadedTaskIds is an empty array', async () => {
        const runView = vi.fn();
        const list = createTaskList();
        list.Provider = createMockProvider({ runView });
        list.PreloadedTaskIds = [];

        await list.loadTasks();

        expect(runView).not.toHaveBeenCalled();
        expect(list.tasks).toEqual([]);
        expect(list.filteredTasks).toEqual([]);
        expect(list.loadError).toBeNull();
    });

    it('chunks PreloadedTaskIds > 400 cleanly and never emits raw vwTaskAssignments subqueries', async () => {
        const ids = Array.from({ length: 450 }, (_, idx) => `00000000-0000-4000-8000-${String(idx + 1).padStart(12, '0')}`);
        const runView = vi.fn().mockImplementation((params: RunViewParams) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: ids[0],
                            Name: 'Deliverable A',
                            Description: null,
                            Status: 'Open',
                            Priority: 'High',
                            DueAt: null,
                            PercentComplete: 0,
                            HoursEstimated: null,
                            ParentID: null,
                            TaskTypeStatus: null,
                        },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const list = createTaskList();
        list.ReadOnly = true;
        list.Provider = createMockProvider({ runView });
        list.PreloadedTaskIds = ids;

        await list.loadTasks();

        const taskCalls = runView.mock.calls
            .map(([p]) => p as RunViewParams)
            .filter((p) => p.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(taskCalls).toHaveLength(2);
        for (const call of taskCalls) {
            expect(call.ExtraFilter).toContain('ID IN (');
            expect(call.ExtraFilter).not.toContain('vwTaskAssignments');
        }
        expect(list.tasks).toHaveLength(1);
        expect(list.loadError).toBeNull();
    });

    it('surfaces Tasks RunView failure via loadError instead of silently treating it as empty', async () => {
        const runView = vi.fn().mockResolvedValue({
            Success: false,
            ErrorMessage: 'Invalid ExtraFilter: entity is row-level-security filtered',
            Results: [],
        });

        const list = createTaskList();
        list.Provider = createMockProvider({ runView });

        await list.loadTasks();

        expect(list.loadError).toBe('Invalid ExtraFilter: entity is row-level-security filtered');
        expect(list.tasks).toEqual([]);
        expect(list.filteredTasks).toEqual([]);
        // Does not issue enrichment lookups after main query fails
        expect(runView).toHaveBeenCalledTimes(1);
    });

    it('gates optional lookup RunViews on CanRead so Space Participant users produce zero permission errors', async () => {
        const runView = vi.fn().mockImplementation((params: RunViewParams) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: '11111111-1111-4111-8111-111111111111',
                            Name: 'Participant Deliverable',
                            Description: null,
                            Status: 'Open',
                            Priority: 'Medium',
                            DueAt: null,
                            PercentComplete: 0,
                            HoursEstimated: null,
                            ParentID: null,
                            TaskTypeStatus: null,
                        },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const list = createTaskList();
        list.ReadOnly = false;
        list.Provider = createMockProvider({
            runView,
            currentUser: { ID: 'space-participant-user' },
            readableEntities: {
                'MJ_BizApps_Tasks: Tasks': true,
                'MJ_BizApps_Tasks: Task Assignments': true,
                'MJ_BizApps_Tasks: Task Roles': true,
                'MJ_BizApps_Tasks: Task Tag Links': true,
                'MJ_BizApps_Tasks: Task Tags': true,
                'MJ_BizApps_Tasks: Task Categories': true,
                'MJ_BizApps_Tasks: Task Types': true,
                'MJ_BizApps_Tasks: Task Type Status': true,
                'MJ_BizApps_Tasks: Task Links': false,
                'MJ_BizApps_Common: Organizations': false,
                'MJ_BizApps_Common: People': true,
            },
        });
        list.PreloadedTaskIds = ['11111111-1111-4111-8111-111111111111'];

        await list.loadTasks();

        const queriedEntities = runView.mock.calls.map(([p]) => (p as RunViewParams).EntityName);
        expect(queriedEntities).toContain('MJ_BizApps_Tasks: Tasks');
        expect(queriedEntities).not.toContain('MJ_BizApps_Common: Organizations');
        expect(queriedEntities).not.toContain('MJ_BizApps_Tasks: Task Links');
        expect(list.tasks).toHaveLength(1);
        expect(list.loadError).toBeNull();
    });
});
