import '@angular/compiler';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';

const { runViewMock, getEntityObjectMock, entitiesMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    entitiesMock: [
        { ID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', Name: 'MJ_BizApps_Common: People' },
        { ID: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', Name: 'MJ_BizApps_Tasks: Tasks' },
    ],
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: entitiesMock,
        EntityByName: (name: string) => entitiesMock.find((e) => e.Name === name),
        GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args),
    };
    return {
        ...actual,
        RunView: class {
            static FromMetadataProvider() {
                return new this();
            }
            RunView(...args: unknown[]) {
                return runViewMock(...args);
            }
            RunViews(paramsList: unknown[]) {
                return Promise.all(paramsList.map((p) => runViewMock(p)));
            }
        },
        Metadata: Object.assign(
            class {
                Entities = entitiesMock;
                GetEntityObject(...args: unknown[]) {
                    return getEntityObjectMock(...args);
                }
            },
            { Provider: provider },
        ),
        CompositeKey: class {
            constructor(public KeyValuePairs: unknown[]) {}
        },
    };
});

import { TasksEngineBase } from '@mj-biz-apps/tasks-core';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';

const TASK_ID = '11111111-1111-4111-8111-111111111111';
const PERSON_1 = '22222222-2222-4222-8222-222222222221';
const PERSON_2 = '22222222-2222-4222-8222-222222222222';
const TAG_1 = '33333333-3333-4333-8333-333333333331';
const ROLE_1 = '44444444-4444-4444-8444-444444444441';
const TYPE_1 = '55555555-5555-4555-8555-555555555551';
const PEOPLE_ENTITY_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

function makeCollection(initial: Record<string, unknown>[] = []) {
    const items = [...initial];
    return {
        get Items() {
            return items;
        },
        Load: vi.fn(async () => true),
        Create: vi.fn(async () => {
            const child: Record<string, unknown> = { Save: vi.fn(async () => true) };
            items.push(child);
            return child;
        }),
        Remove: vi.fn((item: Record<string, unknown>) => {
            const idx = items.indexOf(item);
            if (idx >= 0) items.splice(idx, 1);
            return idx >= 0;
        }),
        Clear: vi.fn(() => {
            items.length = 0;
        }),
    };
}

function makeMockTaskEntity(id: string = TASK_ID) {
    return {
        ID: id,
        Name: '',
        Description: null as string | null,
        Status: 'Open',
        Priority: 'Medium',
        TypeID: null as string | null,
        CategoryID: null as string | null,
        ParentID: null as string | null,
        DueAt: null as Date | null,
        HoursEstimated: null as number | null,
        HoursActual: null as number | null,
        PercentComplete: 0,
        BlockedReason: null as string | null,
        CompletionNotes: null as string | null,
        NewRecord: vi.fn(),
        InnerLoad: vi.fn(async () => true),
        Save: vi.fn(async () => true),
        Delete: vi.fn(async () => true),
        LatestResult: { CompleteMessage: '' },
        Assignments: makeCollection(),
        TagLinks: makeCollection(),
        Links: makeCollection(),
        Dependencies: makeCollection(),
        Comments: makeCollection(),
        CheckIns: makeCollection(),
        Activities: makeCollection(),
        NotificationLogs: makeCollection(),
        SubTasks: makeCollection(),
    };
}

function makeCdr(): ChangeDetectorRef {
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
        providers: [{ provide: ChangeDetectorRef, useValue: makeCdr() }],
    });
    return runInInjectionContext(injector, factory);
}

beforeEach(() => {
    vi.resetAllMocks();
});

describe('TaskEditPanelComponent atomic RelatedRecordCollection save', () => {
    it('composes Task + Assignments + TagLinks into ONE atomic entity.Save() call', async () => {
        const panel = createInContext(() => new TaskEditPanelComponent());
        panel.isNew = true;
        (panel as unknown as { peopleEntityID: string | null }).peopleEntityID = PEOPLE_ENTITY_ID;
        panel.form.Name = 'Ship Composite Save';
        panel.form.Status = 'Open';
        panel.form.Priority = 'High';
        panel.form.TypeID = TYPE_1;
        panel.assignees = [{ PersonID: PERSON_1, PersonName: 'Alice Ng', RoleID: ROLE_1, IsNew: true }];
        panel.selectedTags = [{ ID: TAG_1, Name: 'Urgent', ColorCode: '#ff0000' }];

        const mockTask = makeMockTaskEntity(TASK_ID);
        getEntityObjectMock.mockResolvedValueOnce(mockTask);

        const savedEvents: string[] = [];
        panel.Saved.subscribe((id) => savedEvents.push(id));

        await panel.save();

        // Only 1 GetEntityObject call (the Task itself) — Assignments & TagLinks composed via collections
        expect(getEntityObjectMock).toHaveBeenCalledTimes(1);
        expect(getEntityObjectMock).toHaveBeenCalledWith('MJ_BizApps_Tasks: Tasks');

        expect(mockTask.Name).toBe('Ship Composite Save');
        expect(mockTask.Assignments.Items).toHaveLength(1);
        expect(mockTask.Assignments.Items[0]).toMatchObject({
            AssigneeEntityID: PEOPLE_ENTITY_ID,
            AssigneeRecordID: PERSON_1,
            RoleID: ROLE_1,
        });
        expect(mockTask.TagLinks.Items).toHaveLength(1);
        expect(mockTask.TagLinks.Items[0]).toMatchObject({
            TagID: TAG_1,
        });

        expect(mockTask.Save).toHaveBeenCalledTimes(1);
        expect(savedEvents).toEqual([TASK_ID]);
    });
});

describe('TaskListComponent.quickAddTask atomic save', () => {
    it('composes optional assignee onto entity.Assignments and saves in ONE entity.Save()', async () => {
        const list = createInContext(() => new TaskListComponent());
        list.QuickAddDefaultTypeID = TYPE_1;
        list.quickAddName = 'Quick Composite Task';
        list.quickAddPersonID = PERSON_1;
        vi.spyOn(list, 'loadTasks').mockResolvedValue();

        const mockTask = makeMockTaskEntity(TASK_ID);
        getEntityObjectMock.mockResolvedValueOnce(mockTask);

        await list.quickAddTask();

        expect(getEntityObjectMock).toHaveBeenCalledTimes(1);
        expect(mockTask.Name).toBe('Quick Composite Task');
        expect(mockTask.Priority).toBe('Medium');
        expect(mockTask.Assignments.Items).toHaveLength(1);
        expect(mockTask.Assignments.Items[0]).toMatchObject({
            AssigneeEntityID: PEOPLE_ENTITY_ID,
            AssigneeRecordID: PERSON_1,
            Status: 'Pending',
        });
        expect(mockTask.Save).toHaveBeenCalledTimes(1);
    });
});

describe('TaskDetailPanelComponent scoped People queries, typed PostComment & atomic onDelete', () => {
    it('loads People scoped to referenced UUIDs only (never unbounded ExtraFilter: "")', async () => {
        const detail = createInContext(() => new TaskDetailPanelComponent());
        detail.TaskID = TASK_ID;

        runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter?: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return {
                    Success: true,
                    Results: [
                        { ID: 'a1', AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: PERSON_1, RoleID: null, Status: 'Pending' },
                        { ID: 'a2', AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: 'not-a-uuid', RoleID: null, Status: 'Pending' },
                    ],
                };
            }
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return {
                    Success: true,
                    Results: [{ ID: PERSON_1, FirstName: 'Alice', LastName: 'Ng' }],
                };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Roles') {
                return { Success: true, Results: [] };
            }
            return { Success: true, Results: [] };
        });

        TasksEngineBase.Instance.ClearUserScopedCaches();
        await detail.LoadTask();

        const peopleCalls = runViewMock.mock.calls.filter(
            ([p]) => (p as { EntityName: string }).EntityName === 'MJ_BizApps_Common: People',
        );
        expect(peopleCalls).toHaveLength(1);
        const filter = String((peopleCalls[0][0] as { ExtraFilter?: string }).ExtraFilter);
        expect(filter).toContain(`ID IN ('${PERSON_1}')`);
        expect(filter).not.toContain('not-a-uuid');
        expect(detail.assignees[0].DisplayName).toBe('Alice Ng');
    });

    it('uses typed properties in PostComment without calling .Set()', async () => {
        const detail = createInContext(() => new TaskDetailPanelComponent());
        detail.TaskID = TASK_ID;
        detail.PersonID = PERSON_2;
        detail.newComment = 'Typed comment body';
        vi.spyOn(detail as unknown as { loadTimeline: () => Promise<void> }, 'loadTimeline').mockResolvedValue();

        const commentObj = {
            NewRecord: vi.fn(),
            Save: vi.fn(async () => true),
            TaskID: '',
            Content: '',
            PersonID: null as string | null,
            LatestResult: { CompleteMessage: '' },
        };
        getEntityObjectMock.mockResolvedValueOnce(commentObj);

        await detail.PostComment();

        expect(commentObj.TaskID).toBe(TASK_ID);
        expect(commentObj.Content).toBe('Typed comment body');
        expect(commentObj.PersonID).toBe(PERSON_2);
        expect(commentObj.Save).toHaveBeenCalledOnce();
    });

    it('onDelete loads OnRemove:delete collections, orphans SubTasks, and executes atomic entity.Delete()', async () => {
        const detail = createInContext(() => new TaskDetailPanelComponent());
        detail.TaskID = TASK_ID;

        const subTask = { ID: 'sub-1', ParentID: TASK_ID };
        const mockTask = makeMockTaskEntity(TASK_ID);
        mockTask.SubTasks = makeCollection([subTask]);

        const incomingDepEntity = {
            TaskID: '99999999-9999-4999-8999-999999999999',
            Delete: vi.fn(async () => true),
        };
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [incomingDepEntity],
        });
        getEntityObjectMock.mockResolvedValueOnce(mockTask);

        const deletedEvents: string[] = [];
        detail.DeleteRequested.subscribe((id) => deletedEvents.push(id));

        await detail.onDelete();

        // Loaded all OnRemove: 'delete' collections + SubTasks
        expect(mockTask.Assignments.Load).toHaveBeenCalledWith(true);
        expect(mockTask.TagLinks.Load).toHaveBeenCalledWith(true);
        expect(mockTask.Links.Load).toHaveBeenCalledWith(true);
        expect(mockTask.Dependencies.Load).toHaveBeenCalledWith(true);
        expect(mockTask.Comments.Load).toHaveBeenCalledWith(true);
        expect(mockTask.CheckIns.Load).toHaveBeenCalledWith(true);
        expect(mockTask.Activities.Load).toHaveBeenCalledWith(true);
        expect(mockTask.NotificationLogs.Load).toHaveBeenCalledWith(true);
        expect(mockTask.SubTasks.Load).toHaveBeenCalledWith(true);

        // Orphaned subtask via SubTasks.Clear() + Save()
        expect(mockTask.SubTasks.Clear).toHaveBeenCalledOnce();
        expect(mockTask.Save).toHaveBeenCalledOnce();
        // Deleted incoming dependency edge
        expect(incomingDepEntity.Delete).toHaveBeenCalledOnce();
        // Atomic composite Delete()
        expect(mockTask.Delete).toHaveBeenCalledOnce();
        expect(deletedEvents).toEqual([TASK_ID]);
    });
});
