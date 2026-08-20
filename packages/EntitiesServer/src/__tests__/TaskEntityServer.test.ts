import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TaskEntityServer, TaskLifecycleContext } from '../TaskEntityServer.js';
import { ActionEngineServer } from '@memberjunction/actions';

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
        return {
          NewRecord: vi.fn(),
          Save: vi.fn().mockResolvedValue(true),
          Load: vi.fn().mockResolvedValue(true),
        };
      }
    },
    RunView: class {
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
    public async rollupParentProgress() {
      return true;
    }
  },
}));

describe('TaskEntityServer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
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
});
