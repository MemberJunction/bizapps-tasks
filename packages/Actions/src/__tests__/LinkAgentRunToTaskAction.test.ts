import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, RunActionParams } from '@memberjunction/actions-base';

const TASK_ID = 'A0000000-0000-0000-0000-000000000001';
const RUN_ID = 'B0000000-0000-0000-0000-000000000001';
const USER_ID = 'C0000000-0000-0000-0000-000000000001';
const PERSON_ID = 'D0000000-0000-0000-0000-000000000001';
const LINK_ID = 'E0000000-0000-0000-0000-000000000001';
const TIME_ENTRY_ID = 'F0000000-0000-0000-0000-000000000001';

const fakeState = {
    taskExists: true,
    runExists: true,
    runStartedAt: '2026-04-15T14:00:00Z',
    runCompletedAt: '2026-04-15T14:25:00Z',
    linkSaveSucceeds: true,
    timeEntrySaveSucceeds: true,
    savedLink: null as Record<string, unknown> | null,
    savedTimeEntry: null as Record<string, unknown> | null,
};

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));
vi.mock('@memberjunction/core-entities', () => ({
    MJAIAgentRunEntity: class {},
}));
vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskAgentRunEntity: class {},
    mjBizAppsTasksTaskEntity: class {},
    mjBizAppsTasksTaskTimeEntryEntity: class {},
}));
vi.mock('@memberjunction/core', () => ({
    Metadata: class {
        async GetEntityObject(entityName: string) {
            if (entityName === 'MJ_BizApps_Tasks: Task Agent Runs') {
                const record: Record<string, unknown> = {
                    ID: LINK_ID,
                    NewRecord: vi.fn(),
                    Save: vi.fn(async () => {
                        fakeState.savedLink = record;
                        return fakeState.linkSaveSucceeds;
                    }),
                    LatestResult: { CompleteMessage: 'Authority check refused' },
                };
                return record;
            }
            if (entityName === 'MJ_BizApps_Tasks: Task Time Entries') {
                const record: Record<string, unknown> = {
                    ID: TIME_ENTRY_ID,
                    NewRecord: vi.fn(),
                    Save: vi.fn(async () => {
                        fakeState.savedTimeEntry = record;
                        return fakeState.timeEntrySaveSucceeds;
                    }),
                };
                return record;
            }
            throw new Error(`Unexpected entity ${entityName}`);
        }
    },
    RunView: class {
        async RunView(p: { EntityName: string }) {
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return {
                    Success: true,
                    Results: fakeState.taskExists ? [{ ID: TASK_ID, Name: 'Test Task' }] : [],
                };
            }
            if (p.EntityName === 'MJ: AI Agent Runs') {
                return {
                    Success: true,
                    Results: fakeState.runExists
                        ? [
                              {
                                  ID: RUN_ID,
                                  StartedAt: fakeState.runStartedAt,
                                  CompletedAt: fakeState.runCompletedAt,
                              },
                          ]
                        : [],
                };
            }
            return { Success: true, Results: [] };
        }
    },
}));

const { LinkAgentRunToTaskAction } = await import('../custom/LinkAgentRunToTaskAction.js');

class TestableLinkAgentRunAction extends LinkAgentRunToTaskAction {
    public run(params: RunActionParams) {
        return this.InternalRunAction(params);
    }
}

function makeParams(entries: Record<string, unknown>, includeUser = true): RunActionParams {
    const Params: ActionParam[] = Object.entries(entries).map(([Name, Value]) => ({
        Name,
        Type: 'Input',
        Value,
    }));
    return {
        Action: {} as RunActionParams['Action'],
        ContextUser: includeUser ? ({ ID: USER_ID } as RunActionParams['ContextUser']) : (undefined as unknown as RunActionParams['ContextUser']),
        Filters: [],
        Params,
    };
}

describe('LinkAgentRunToTaskAction', () => {
    beforeEach(() => {
        fakeState.taskExists = true;
        fakeState.runExists = true;
        fakeState.runStartedAt = '2026-04-15T14:00:00Z';
        fakeState.runCompletedAt = '2026-04-15T14:25:00Z';
        fakeState.linkSaveSucceeds = true;
        fakeState.timeEntrySaveSucceeds = true;
        fakeState.savedLink = null;
        fakeState.savedTimeEntry = null;
    });

    it('fails with ERROR when ContextUser is missing', async () => {
        const action = new TestableLinkAgentRunAction();
        const res = await action.run(makeParams({ TaskID: TASK_ID, AIAgentRunID: RUN_ID }, false));
        expect(res.Success).toBe(false);
        expect(res.ResultCode).toBe('ERROR');
    });

    it('fails with MISSING_PARAMS when TaskID or AIAgentRunID is missing or not a UUID', async () => {
        const action = new TestableLinkAgentRunAction();
        const res1 = await action.run(makeParams({ TaskID: TASK_ID }));
        expect(res1.Success).toBe(false);
        expect(res1.ResultCode).toBe('MISSING_PARAMS');

        const res2 = await action.run(makeParams({ TaskID: 'not-a-uuid', AIAgentRunID: RUN_ID }));
        expect(res2.Success).toBe(false);
        expect(res2.ResultCode).toBe('MISSING_PARAMS');
    });

    it('fails with NOT_FOUND when Task or AI Agent Run does not exist', async () => {
        const action = new TestableLinkAgentRunAction();
        fakeState.taskExists = false;
        const res1 = await action.run(makeParams({ TaskID: TASK_ID, AIAgentRunID: RUN_ID }));
        expect(res1.Success).toBe(false);
        expect(res1.ResultCode).toBe('NOT_FOUND');

        fakeState.taskExists = true;
        fakeState.runExists = false;
        const res2 = await action.run(makeParams({ TaskID: TASK_ID, AIAgentRunID: RUN_ID }));
        expect(res2.Success).toBe(false);
        expect(res2.ResultCode).toBe('NOT_FOUND');
    });

    it('creates a TaskAgentRun link and populates TaskAgentRunID output param', async () => {
        const action = new TestableLinkAgentRunAction();
        const params = makeParams({
            TaskID: TASK_ID,
            AIAgentRunID: RUN_ID,
            Role: 'Reviewed',
            Notes: 'Automated PR review',
        });
        const res = await action.run(params);
        expect(res.Success).toBe(true);
        expect(res.ResultCode).toBe('SUCCESS');
        expect(fakeState.savedLink?.TaskID).toBe(TASK_ID);
        expect(fakeState.savedLink?.AIAgentRunID).toBe(RUN_ID);
        expect(fakeState.savedLink?.Role).toBe('Reviewed');
        expect(fakeState.savedLink?.Notes).toBe('Automated PR review');
        expect(params.Params.find((p) => p.Name === 'TaskAgentRunID')?.Value).toBe(LINK_ID);
        expect(fakeState.savedTimeEntry).toBeNull();
    });

    it('also logs an Agent TaskTimeEntry when LogWallClockAsTimeEntry is true', async () => {
        const action = new TestableLinkAgentRunAction();
        const params = makeParams({
            TaskID: TASK_ID,
            AgentRunID: RUN_ID, // alias supported per §6.3
            LogWallClockAsTimeEntry: 'true',
            PersonID: PERSON_ID,
            Notes: 'Agent execution time',
        });
        const res = await action.run(params);
        expect(res.Success).toBe(true);
        expect(fakeState.savedTimeEntry).not.toBeNull();
        expect(fakeState.savedTimeEntry?.TaskID).toBe(TASK_ID);
        expect(fakeState.savedTimeEntry?.PersonID).toBe(PERSON_ID);
        expect(fakeState.savedTimeEntry?.Minutes).toBe(25);
        expect(fakeState.savedTimeEntry?.Source).toBe('Agent');
        expect(fakeState.savedTimeEntry?.IsBillable).toBe(false);
        expect(params.Params.find((p) => p.Name === 'TaskTimeEntryID')?.Value).toBe(TIME_ENTRY_ID);
    });
});
