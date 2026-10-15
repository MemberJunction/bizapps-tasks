import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TaskEntityServer, TaskLifecycleContext } from '../TaskEntityServer.js';
import { ActionEngineServer } from '@memberjunction/actions';

// The provider each test Task was "created on". Tests swap fields to observe routing.
const H = vi.hoisted(() => {
  const makeEntityObject = () => ({
    NewRecord: vi.fn(),
    Save: vi.fn().mockResolvedValue(true),
    Load: vi.fn().mockResolvedValue(true),
  });
  return {
    makeEntityObject,
    provider: {} as Record<string, unknown>,
    globalGetEntityObject: vi.fn(),
    rollupParentProgress: vi.fn(async () => undefined),
    runViewProviders: [] as unknown[],
  };
});

function resetProvider(withScheduler: boolean) {
  for (const key of Object.keys(H.provider)) delete H.provider[key];
  H.provider.GetEntityObject = vi.fn(async () => H.makeEntityObject());
  H.provider.RunView = vi.fn(async () => ({ Success: true, Results: [] }));
  if (withScheduler) {
    H.provider.CapturePostCommitToken = vi.fn(() => ({ frame: 'caller-tx' }));
    H.provider.RunAfterCommit = vi.fn();
  }
}

// Mock MJ runtime
vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  BaseSingleton: class {
    public static getInstance() {
      return {};
    }
  },
}));

vi.mock('@memberjunction/core', () => {
  return {
    BaseEntity: class {
      public ContextCurrentUser = { ID: 'USER-1', Name: 'Test User' };
      public Fields: Array<{ CodeName: string; Dirty: boolean; Value: unknown; OldValue: unknown }> = [];
      public IsSaved = false;
      private _fieldValues: Record<string, unknown> = {};

      public Get(fieldName: string) {
        return this._fieldValues[fieldName];
      }
      public Set(fieldName: string, value: unknown) {
        this._fieldValues[fieldName] = value;
      }
      public GetAll() {
        return { ...this._fieldValues };
      }
      public get ProviderToUse() {
        return H.provider;
      }
      public get RunViewProviderToUse() {
        return H.provider;
      }
      public RegisterEventHandler() {}
      public async Save() {
        return true;
      }
    },
    BaseEngine: class {
      public static getInstance() {
        return {};
      }
    },
    LogError: vi.fn(),
    LogStatus: vi.fn(),
    Metadata: class {
      public async GetEntityObject() {
        H.globalGetEntityObject();
        return H.makeEntityObject();
      }
    },
    RunView: class {
      constructor(provider?: unknown) {
        H.runViewProviders.push(provider);
      }
      public async RunView() {
        return { Success: true, Results: [] };
      }
    },
  };
});

vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: {
    Instance: {
      Config: vi.fn().mockResolvedValue(undefined),
      Actions: [
        { ID: 'ACTION-CREATE', Name: 'On Task Created' },
        { ID: 'ACTION-STATUS-CHANGE', Name: 'On Status Changed' },
        { ID: 'ACTION-ENTER', Name: 'On Enter Stage' },
        { ID: 'ACTION-EXIT', Name: 'On Exit Stage' },
        { ID: 'ACTION-COMPLETE', Name: 'On Task Completed' },
        { ID: 'ACTION-CANCEL', Name: 'On Task Cancelled' },
        { ID: 'ACTION-REJECT', Name: 'On Task Rejected' },
        { ID: 'ACTION-PCT', Name: 'On Percent Changed' },
      ],
      RunAction: vi.fn().mockResolvedValue({ Success: true, Message: 'Action ran successfully' }),
    },
  },
}));

vi.mock('@mj-biz-apps/tasks-core', () => ({
  TaskService: class {
    public rollupParentProgress = H.rollupParentProgress;
  },
}));

describe('TaskEntityServer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    H.runViewProviders.length = 0;
    resetProvider(true);
  });

  describe('invokeAction', () => {
    it('constructs universal payload and executes action through ActionEngineServer', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-100';
      server.Name = 'Review Sales Order';
      server.Status = 'InProgress';
      server.TaskTypeStatusID = 'STATUS-LEGAL';
      server.TypeID = 'TYPE-APPROVAL';
      server.PercentComplete = 50;
      server.Priority = 'High';

      const result = await server.invokeAction(
        'ACTION-STATUS-CHANGE',
        'OnStatusChange',
        'APPROVAL_REQUEST',
        'LEGAL_REVIEW',
        'Open'
      );

      expect(result.Invoked).toBe(true);
      expect(result.Success).toBe(true);
      expect(ActionEngineServer.Instance.RunAction).toHaveBeenCalledTimes(1);

      const callArgs = (ActionEngineServer.Instance.RunAction as unknown as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(callArgs.Action.ID).toBe('ACTION-STATUS-CHANGE');

      const params = callArgs.Params as Array<{ Name: string; Value: unknown; Type: string }>;
      const taskIDParam = params.find(p => p.Name === 'TaskID');
      const recordIDParam = params.find(p => p.Name === 'RecordID');
      const taskNameParam = params.find(p => p.Name === 'TaskName');
      const typeCodeParam = params.find(p => p.Name === 'TaskTypeCode');
      const statusParam = params.find(p => p.Name === 'Status');
      const prevStatusParam = params.find(p => p.Name === 'PreviousStatus');
      const payloadParam = params.find(p => p.Name === 'Payload');

      expect(taskIDParam?.Value).toBe('TASK-100');
      expect(recordIDParam?.Value).toBe('TASK-100');
      expect(taskNameParam?.Value).toBe('Review Sales Order');
      expect(typeCodeParam?.Value).toBe('APPROVAL_REQUEST');
      expect(statusParam?.Value).toBe('InProgress');
      expect(prevStatusParam?.Value).toBe('Open');
      expect(typeof payloadParam?.Value).toBe('string');

      const parsedPayload = JSON.parse(payloadParam?.Value as string);
      expect(parsedPayload.taskID).toBe('TASK-100');
      expect(parsedPayload.taskTypeCode).toBe('APPROVAL_REQUEST');
      expect(parsedPayload.status).toBe('InProgress');
    });

    it('returns Invoked=false when action ID is not found in ActionEngine', async () => {
      const server = new TaskEntityServer();
      const result = await server.invokeAction(
        'NON-EXISTENT-ACTION',
        'OnCreate',
        'GENERAL',
        null,
        null
      );

      expect(result.Invoked).toBe(false);
      expect(result.Message).toContain('NON-EXISTENT-ACTION');
    });
  });

  describe('dispatchLifecycleActionHooks', () => {
    it('dispatches OnCreate when isNew=true', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-1';
      server.TypeID = 'TYPE-1';

      // Mock loadTaskType
      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: 'TYPE-1',
        Code: 'GENERAL',
        OnCreateActionID: 'ACTION-CREATE',
        OnStatusChangeActionID: null,
      });

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      const ctx: TaskLifecycleContext = {
        isNew: true,
        statusChanged: false,
        typeStatusChanged: false,
        pctChanged: false,
        priorityChanged: false,
        dueChanged: false,
        oldStatus: null,
        newStatus: 'Open',
        oldTypeStatusID: null,
        newTypeStatusID: null,
        oldPct: null,
        newPct: 0,
        oldPriority: null,
        newPriority: 'Medium',
        oldDue: null,
        newDue: null,
        typeID: 'TYPE-1',
      };

      await server.dispatchLifecycleActionHooks(ctx);

      expect(invokeSpy).toHaveBeenCalledWith(
        'ACTION-CREATE',
        'OnCreate',
        'GENERAL',
        null,
        null
      );
    });

    it('dispatches OnStatusChange and OnComplete when completed', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-2';
      server.TypeID = 'TYPE-1';
      server.Status = 'Completed';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: 'TYPE-1',
        Code: 'APPROVAL_REQUEST',
        OnStatusChangeActionID: 'ACTION-STATUS-CHANGE',
        OnCompleteActionID: 'ACTION-COMPLETE',
      });

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      const ctx: TaskLifecycleContext = {
        isNew: false,
        statusChanged: true,
        typeStatusChanged: false,
        pctChanged: false,
        priorityChanged: false,
        dueChanged: false,
        oldStatus: 'InProgress',
        newStatus: 'Completed',
        oldTypeStatusID: null,
        newTypeStatusID: null,
        oldPct: 50,
        newPct: 100,
        oldPriority: 'High',
        newPriority: 'High',
        oldDue: null,
        newDue: null,
        typeID: 'TYPE-1',
      };

      await server.dispatchLifecycleActionHooks(ctx);

      expect(invokeSpy).toHaveBeenCalledWith(
        'ACTION-STATUS-CHANGE',
        'OnStatusChange',
        'APPROVAL_REQUEST',
        null,
        'InProgress'
      );
      expect(invokeSpy).toHaveBeenCalledWith(
        'ACTION-COMPLETE',
        'OnComplete',
        'APPROVAL_REQUEST',
        null,
        'InProgress'
      );
    });

    it('dispatches OnExitStatus and OnEnterStatus on stage transition', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-3';
      server.TypeID = 'TYPE-1';
      server.TaskTypeStatusID = 'STAGE-2';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: 'TYPE-1',
        Code: 'CONTRACT_REVIEW',
      });

      vi.spyOn(server as unknown as { loadTaskTypeStatus: (id: string) => Promise<unknown> }, 'loadTaskTypeStatus')
        .mockImplementation(async (id: string) => {
          if (id === 'STAGE-1') {
            return { ID: 'STAGE-1', Code: 'DRAFT', OnExitActionID: 'ACTION-EXIT' };
          }
          if (id === 'STAGE-2') {
            return { ID: 'STAGE-2', Code: 'LEGAL', OnEnterActionID: 'ACTION-ENTER' };
          }
          return null;
        });

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      const ctx: TaskLifecycleContext = {
        isNew: false,
        statusChanged: false,
        typeStatusChanged: true,
        pctChanged: false,
        priorityChanged: false,
        dueChanged: false,
        oldStatus: 'InProgress',
        newStatus: 'InProgress',
        oldTypeStatusID: 'STAGE-1',
        newTypeStatusID: 'STAGE-2',
        oldPct: 20,
        newPct: 40,
        oldPriority: 'Medium',
        newPriority: 'Medium',
        oldDue: null,
        newDue: null,
        typeID: 'TYPE-1',
      };

      await server.dispatchLifecycleActionHooks(ctx);

      expect(invokeSpy).toHaveBeenCalledWith(
        'ACTION-EXIT',
        'OnExitStatus',
        'CONTRACT_REVIEW',
        'DRAFT',
        'InProgress'
      );
      expect(invokeSpy).toHaveBeenCalledWith(
        'ACTION-ENTER',
        'OnEnterStatus',
        'CONTRACT_REVIEW',
        'LEGAL',
        'InProgress'
      );
    });
  });
  describe('provider routing (#78)', () => {
    it('loads the task type and statuses through the provider the Task was created on', async () => {
      const server = new TaskEntityServer();
      const loader = server as unknown as {
        loadTaskType: (id: string) => Promise<unknown>;
        loadTaskTypeStatus: (id: string) => Promise<unknown>;
        loadDefaultTaskTypeStatus: (id: string) => Promise<unknown>;
      };

      await loader.loadTaskType('TYPE-1');
      await loader.loadTaskTypeStatus('STATUS-1');
      await loader.loadDefaultTaskTypeStatus('TYPE-1');

      expect(H.provider.GetEntityObject).toHaveBeenCalledTimes(2);
      expect(H.runViewProviders).toEqual([H.provider]);
      expect(H.globalGetEntityObject).not.toHaveBeenCalled();
    });

    it('runs hook actions on the Task\'s provider', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-1';
      server.Name = 'Task';

      await server.invokeAction('ACTION-CREATE', 'OnCreate', 'TYPE', null, null);

      const callArgs = (ActionEngineServer.Instance.RunAction as unknown as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(callArgs.Provider).toBe(H.provider);
    });

    it('writes activity rows on the Task\'s provider and queues the hooks until the caller commits', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-2';
      server.Name = 'New task';
      server.TypeID = 'TYPE-1';
      const dispatchSpy = vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      const saved = await server.Save();

      expect(saved).toBe(true);
      expect(H.provider.GetEntityObject).toHaveBeenCalledWith('MJ_BizApps_Tasks: Task Activities', server.ContextCurrentUser);
      expect(H.globalGetEntityObject).not.toHaveBeenCalled();

      // Queued against the transaction open when Save began, not started yet.
      const runAfterCommit = H.provider.RunAfterCommit as ReturnType<typeof vi.fn>;
      expect(runAfterCommit).toHaveBeenCalledTimes(1);
      const [task, description, token] = runAfterCommit.mock.calls[0];
      expect(description).toBe('Task lifecycle action hooks');
      expect(token).toEqual({ frame: 'caller-tx' });
      expect(dispatchSpy).not.toHaveBeenCalled();

      // The provider runs it on commit (and never calls it on rollback).
      await (task as () => Promise<void>)();
      expect(dispatchSpy).toHaveBeenCalledTimes(1);
    });

    it('queues the parent rollup after commit and runs it on the Task\'s provider', async () => {
      const server = new TaskEntityServer();
      server.ID = 'TASK-5';
      server.ParentID = 'PARENT-1';
      let saveHandler: ((event: { type: string }) => void) | undefined;
      vi.spyOn(server, 'RegisterEventHandler').mockImplementation((handler) => {
        saveHandler = handler as unknown as (event: { type: string }) => void;
      });
      vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      await server.Save();
      saveHandler?.({ type: 'save' });

      const runAfterCommit = H.provider.RunAfterCommit as ReturnType<typeof vi.fn>;
      const rollupCall = runAfterCommit.mock.calls.find(([, description]) => description === 'Task parent-progress rollup');
      expect(rollupCall).toBeDefined();
      expect(H.rollupParentProgress).not.toHaveBeenCalled();

      await (rollupCall?.[0] as () => Promise<void>)();
      expect(H.rollupParentProgress).toHaveBeenCalledWith('PARENT-1', server.ContextCurrentUser, H.provider);
    });

    it('a failed dispatch is logged and does not reject the post-commit task', async () => {
      const { LogError } = await import('@memberjunction/core');
      const server = new TaskEntityServer();
      server.ID = 'TASK-3';
      server.TypeID = 'TYPE-1';
      vi.spyOn(server, 'dispatchLifecycleActionHooks').mockRejectedValue(new Error('read failed'));

      await server.Save();
      const task = (H.provider.RunAfterCommit as ReturnType<typeof vi.fn>).mock.calls[0][0] as () => Promise<void>;

      await expect(task()).resolves.toBeUndefined();
      expect(LogError).toHaveBeenCalledWith('TaskEntityServer: action hook dispatch error for task TASK-3: read failed');
    });

    it('starts the hooks right away on a provider without a post-commit scheduler', async () => {
      resetProvider(false);
      const server = new TaskEntityServer();
      server.ID = 'TASK-4';
      server.TypeID = 'TYPE-1';
      const dispatchSpy = vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      await server.Save();

      expect(dispatchSpy).toHaveBeenCalledTimes(1);
    });

    it('refuses a provider that cannot load entities instead of falling back to the global one', async () => {
      delete H.provider.GetEntityObject;
      const server = new TaskEntityServer();
      const loader = server as unknown as { loadTaskType: (id: string) => Promise<unknown> };

      await expect(loader.loadTaskType('TYPE-1')).rejects.toThrow(/server-only/);
      expect(H.globalGetEntityObject).not.toHaveBeenCalled();
    });
  });
});
