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
    lastCreatedActivity: null as Record<string, unknown> | null,
    runViewCalls: [] as Array<{ EntityName?: string; ExtraFilter?: string }>,
    runViewImpl: null as ((params: { EntityName?: string; ExtraFilter?: string }) => Promise<{ Success: boolean; Results: unknown[]; ErrorMessage?: string }>) | null,
  };
});

function resetProvider(withScheduler: boolean) {
  for (const key of Object.keys(H.provider)) delete H.provider[key];
  H.lastCreatedActivity = null;
  H.provider.GetEntityObject = vi.fn(async (entityName?: string) => {
    const obj = H.makeEntityObject();
    if (entityName === 'MJ_BizApps_Tasks: Task Activities') {
      H.lastCreatedActivity = obj;
    }
    return obj;
  });
  H.provider.RunView = vi.fn(async () => ({ Success: true, Results: [] }));
  if (withScheduler) {
    H.provider.CapturePostCommitToken = vi.fn(() => ({ frame: 'caller-tx' }));
    H.provider.RunAfterCommit = vi.fn();
  }
}

// Mock MJ runtime
vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
  NormalizeUUID: (v: string) => v.trim().toLowerCase(),
  EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
  UUIDsEqual: (a?: string | null, b?: string | null) =>
    Boolean(a && b && a.toLowerCase() === b.toLowerCase()),
  BaseSingleton: class {
    public static getInstance() {
      return {};
    }
  },
}));

vi.mock('@memberjunction/core', () => {
  return {
    BaseEntity: class {
      public ContextCurrentUser = { ID: '00000000-0000-0000-0000-000000000001', Name: 'Test User' };
      public Fields: Array<{ CodeName: string; Dirty: boolean; Value: unknown; OldValue: unknown }> = [];
      public IsSaved = false;
      public TransactionGroup: unknown = null;
      private _fieldValues: Record<string, unknown> = {};

      public DeclareRelatedRecords() {
        return { Items: [] as unknown[] };
      }
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
    Metadata: Object.assign(
      class {
        public async GetEntityObject() {
          H.globalGetEntityObject();
          return H.makeEntityObject();
        }
      },
      { Provider: { EntityByID: () => null } },
    ),
    RunView: class {
      constructor(provider?: unknown) {
        H.runViewProviders.push(provider);
      }
      public async RunView(params: { EntityName?: string; ExtraFilter?: string }) {
        H.runViewCalls.push(params);
        if (H.runViewImpl) return H.runViewImpl(params);
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

vi.mock('@mj-biz-apps/tasks-core', async () => ({
  ...(await vi.importActual<typeof import('@mj-biz-apps/tasks-core')>('@mj-biz-apps/tasks-core')),
  TaskService: class {
    public rollupParentProgress = H.rollupParentProgress;
    public static computeQuantitativePercentComplete(
      baseline: number | null | undefined,
      target: number | null | undefined,
      current: number | null | undefined,
    ): number | null {
      if (target == null || current == null) return null;
      const b = baseline ?? 0;
      const span = target - b;
      if (span <= 0) return current >= target ? 100 : 0;
      return Math.max(0, Math.min(100, Math.round(((current - b) / span) * 100)));
    }
    public static computeNextCheckInDueAt(from: Date, cadence: string | null | undefined): Date | null {
      if (!cadence || cadence === 'None') return null;
      const next = new Date(from.getTime());
      if (cadence === 'Weekly') {
        next.setUTCDate(next.getUTCDate() + 7);
        return next;
      }
      return null;
    }
  },
}));

// IDs that reach an ExtraFilter via GuidLiteral must be valid UUIDs.
const TYPE_UUID = 'E0000000-0000-0000-0000-000000000001';
const TASK_UUID = 'D0000000-0000-0000-0000-000000000001';
const OUTCOME_UUID = 'F0000000-0000-0000-0000-000000000001';

describe('TaskEntityServer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    H.runViewProviders.length = 0;
    H.runViewCalls.length = 0;
    H.runViewImpl = null;
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

    function cancelledCtx(): TaskLifecycleContext {
      return {
        isNew: false,
        statusChanged: true,
        typeStatusChanged: false,
        pctChanged: false,
        priorityChanged: false,
        dueChanged: false,
        oldStatus: 'InProgress',
        newStatus: 'Cancelled',
        oldTypeStatusID: null,
        newTypeStatusID: null,
        oldPct: 50,
        newPct: 50,
        oldPriority: 'Medium',
        newPriority: 'Medium',
        oldDue: null,
        newDue: null,
        typeID: TYPE_UUID,
      };
    }

    it('fires ONLY OnCancel (never OnReject) on a plain cancellation', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'APPROVAL_REQUEST',
        OnCancelActionID: 'ACTION-CANCEL',
        OnRejectActionID: 'ACTION-REJECT',
      });
      vi.spyOn(server as unknown as { taskHasRejectedDecision: () => Promise<boolean> }, 'taskHasRejectedDecision')
        .mockResolvedValue(false);

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      await server.dispatchLifecycleActionHooks(cancelledCtx());

      expect(invokeSpy).toHaveBeenCalledWith('ACTION-CANCEL', 'OnCancel', 'APPROVAL_REQUEST', null, 'InProgress');
      const hookTypes = invokeSpy.mock.calls.map(c => c[1]);
      expect(hookTypes).not.toContain('OnReject');
    });

    it('fires ONLY OnReject (never OnCancel) when a Rejected decision drove the cancellation', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'APPROVAL_REQUEST',
        OnCancelActionID: 'ACTION-CANCEL',
        OnRejectActionID: 'ACTION-REJECT',
      });
      vi.spyOn(server as unknown as { taskHasRejectedDecision: () => Promise<boolean> }, 'taskHasRejectedDecision')
        .mockResolvedValue(true);

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      await server.dispatchLifecycleActionHooks(cancelledCtx());

      expect(invokeSpy).toHaveBeenCalledWith('ACTION-REJECT', 'OnReject', 'APPROVAL_REQUEST', null, 'InProgress');
      const hookTypes = invokeSpy.mock.calls.map(c => c[1]);
      expect(hookTypes).not.toContain('OnCancel');
    });

    it('fires OnReject when the task lands on the REJECTED stage even with no decision row (status-dropdown path)', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.TaskTypeStatusID = 'STATUS-REJECTED';
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'APPROVAL_REQUEST',
        OnCancelActionID: 'ACTION-CANCEL',
        OnRejectActionID: 'ACTION-REJECT',
      });
      vi.spyOn(server as unknown as { loadTaskTypeStatus: (id: string) => Promise<unknown> }, 'loadTaskTypeStatus')
        .mockResolvedValue({ ID: 'STATUS-REJECTED', Code: 'REJECTED', MacroStatus: 'Cancelled' });
      const decisionSpy = vi.spyOn(server as unknown as { taskHasRejectedDecision: () => Promise<boolean> }, 'taskHasRejectedDecision')
        .mockResolvedValue(false);

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      await server.dispatchLifecycleActionHooks(cancelledCtx());

      expect(invokeSpy).toHaveBeenCalledWith('ACTION-REJECT', 'OnReject', 'APPROVAL_REQUEST', 'REJECTED', 'InProgress');
      expect(invokeSpy.mock.calls.map(c => c[1])).not.toContain('OnCancel');
      // The stage signal short-circuits — no decision query needed.
      expect(decisionSpy).not.toHaveBeenCalled();
    });

    it('does NOT fall back to OnCancel on a rejection when OnRejectActionID is unwired', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'APPROVAL_REQUEST',
        OnCancelActionID: 'ACTION-CANCEL',
        OnRejectActionID: null,
      });
      vi.spyOn(server as unknown as { taskHasRejectedDecision: () => Promise<boolean> }, 'taskHasRejectedDecision')
        .mockResolvedValue(true);

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      await server.dispatchLifecycleActionHooks(cancelledCtx());

      expect(invokeSpy).not.toHaveBeenCalled();
    });

    it('skips the rejected-decision query when the type wires neither OnCancel nor OnReject', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'GENERAL',
        OnCancelActionID: null,
        OnRejectActionID: null,
      });
      const decisionSpy = vi.spyOn(server as unknown as { taskHasRejectedDecision: () => Promise<boolean> }, 'taskHasRejectedDecision')
        .mockResolvedValue(false);
      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      await server.dispatchLifecycleActionHooks(cancelledCtx());

      expect(decisionSpy).not.toHaveBeenCalled();
      expect(invokeSpy).not.toHaveBeenCalled();
    });

    it('does NOT fire OnReject when a task merely becomes Blocked', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      server.Status = 'Blocked';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: TYPE_UUID,
        Code: 'APPROVAL_REQUEST',
        OnRejectActionID: 'ACTION-REJECT',
      });

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      const ctx = cancelledCtx();
      ctx.newStatus = 'Blocked';
      await server.dispatchLifecycleActionHooks(ctx);

      const hookTypes = invokeSpy.mock.calls.map(c => c[1]);
      expect(hookTypes).not.toContain('OnReject');
      expect(hookTypes).not.toContain('OnCancel');
    });

    it('routes taskHasRejectedDecision queries through the Task provider and GuidLiteral', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      H.runViewImpl = async (params) => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Decision Outcomes') {
          return { Success: true, Results: [{ ID: OUTCOME_UUID }] };
        }
        return { Success: true, Results: [{ ID: 'decision-1' }] };
      };

      const check = server as unknown as { taskHasRejectedDecision: () => Promise<boolean> };
      expect(await check.taskHasRejectedDecision()).toBe(true);
      expect(H.runViewProviders).toEqual([H.provider]);
      expect(H.runViewCalls[1]?.ExtraFilter).toBe(`TaskID = '${TASK_UUID}' AND OutcomeID = '${OUTCOME_UUID}'`);
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
    it('dispatches OnReject ONLY (not OnCancel) when Cancelled with a Rejected decision, and OnCancel ONLY when Cancelled without one', async () => {
      const TASK_UUID = '11111111-1111-4111-8111-111111111111';
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = 'TYPE-1';
      server.Status = 'Cancelled';

      vi.spyOn(server as unknown as { loadTaskType: (id: string) => Promise<unknown> }, 'loadTaskType').mockResolvedValue({
        ID: 'TYPE-1',
        Code: 'APPROVAL_REQUEST',
        OnCancelActionID: 'ACTION-CANCEL',
        OnRejectActionID: 'ACTION-REJECT',
      });

      const invokeSpy = vi.spyOn(server, 'invokeAction').mockResolvedValue({ Invoked: true, Success: true });

      const cancelCtx: TaskLifecycleContext = {
        isNew: false,
        statusChanged: true,
        typeStatusChanged: false,
        pctChanged: false,
        priorityChanged: false,
        dueChanged: false,
        oldStatus: 'Open',
        newStatus: 'Cancelled',
        oldTypeStatusID: null,
        newTypeStatusID: null,
        oldPct: 0,
        newPct: 0,
        oldPriority: 'High',
        newPriority: 'High',
        oldDue: null,
        newDue: null,
        typeID: 'TYPE-1',
      };

      // Case 1: Rejected decision exists -> OnReject ONLY
      H.runViewImpl = async (params) => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Decision Outcomes') {
          return { Success: true, Results: [{ ID: '22222222-2222-4222-8222-222222222222' }] };
        }
        return { Success: true, Results: [{ ID: '33333333-3333-4333-8333-333333333333' }] };
      };

      await server.dispatchLifecycleActionHooks(cancelCtx);
      expect(invokeSpy).toHaveBeenCalledWith('ACTION-REJECT', 'OnReject', 'APPROVAL_REQUEST', null, 'Open');
      expect(invokeSpy).not.toHaveBeenCalledWith('ACTION-CANCEL', 'OnCancel', expect.anything(), expect.anything(), expect.anything());

      // Case 2: No Rejected decision -> OnCancel ONLY
      invokeSpy.mockClear();
      H.runViewImpl = async (params) => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Decision Outcomes') {
          return { Success: true, Results: [{ ID: '22222222-2222-4222-8222-222222222222' }] };
        }
        return { Success: true, Results: [] };
      };

      await server.dispatchLifecycleActionHooks(cancelCtx);
      expect(invokeSpy).toHaveBeenCalledWith('ACTION-CANCEL', 'OnCancel', 'APPROVAL_REQUEST', null, 'Open');
      expect(invokeSpy).not.toHaveBeenCalledWith('ACTION-REJECT', 'OnReject', expect.anything(), expect.anything(), expect.anything());

      // Case 3: Blocked status -> NEVER dispatches OnReject or OnCancel
      invokeSpy.mockClear();
      server.Status = 'Blocked';
      await server.dispatchLifecycleActionHooks({ ...cancelCtx, newStatus: 'Blocked' });
      expect(invokeSpy).not.toHaveBeenCalled();
    });
  });

  describe('provider routing (#78), TransactionGroup / composite CheckIns, and pre-save SQL guards', () => {
    it('loads the task type and statuses through the provider the Task was created on', async () => {
      const TYPE_UUID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      const server = new TaskEntityServer();
      const loader = server as unknown as {
        loadTaskType: (id: string) => Promise<unknown>;
        loadTaskTypeStatus: (id: string) => Promise<unknown>;
        loadDefaultTaskTypeStatus: (id: string) => Promise<unknown>;
      };

      await loader.loadTaskType(TYPE_UUID);
      await loader.loadTaskTypeStatus('STATUS-1');
      await loader.loadDefaultTaskTypeStatus(TYPE_UUID);

      expect(H.provider.GetEntityObject).toHaveBeenCalledTimes(2);
      expect(H.runViewProviders).toEqual([H.provider]);
      expect(H.globalGetEntityObject).not.toHaveBeenCalled();
    });

    it('attaches this.TransactionGroup to TaskActivity so activity saves join the same transaction (zero FK_TaskActivity_Task)', async () => {
      const server = new TaskEntityServer();
      const txGroup = { id: 'tx-group-1' };
      server.ID = '11111111-1111-4111-8111-111111111111';
      server.Name = 'Task in TransactionGroup';
      server.TransactionGroup = txGroup as never;
      vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      const saved = await server.Save();
      expect(saved).toBe(true);
      expect(H.lastCreatedActivity).not.toBeNull();
      expect(H.lastCreatedActivity?.TransactionGroup).toBe(txGroup);
    });

    it('applies unsaved composite task.CheckIns pre-save onto the parent Task and populates check-in defaults', async () => {
      const server = new TaskEntityServer();
      server.ID = '11111111-1111-4111-8111-111111111111';
      server.Name = 'OKR Key Result';
      server.BaselineValue = 10;
      server.TargetValue = 50;
      server.CurrentValue = 20;
      server.MetricDirection = 'Increase';
      server.CheckInCadence = 'Weekly';

      const pendingCheckIn = {
        IsSaved: false,
        HealthStatus: 'AtRisk',
        ConfidenceScore: 70,
        PreviousValue: null as number | null,
        NewValue: 30,
        PercentComplete: null as number | null,
        CheckInAt: new Date('2026-11-10T12:00:00.000Z'),
      };
      (server.CheckIns as unknown as { Items: unknown[] }).Items.push(pendingCheckIn);
      vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      const saved = await server.Save();
      expect(saved).toBe(true);
      expect(pendingCheckIn.PreviousValue).toBe(20);
      expect(pendingCheckIn.PercentComplete).toBe(50);
      expect(server.CurrentValue).toBe(30);
      expect(server.PercentComplete).toBe(50);
      expect(server.HealthStatus).toBe('AtRisk');
      expect(server.ConfidenceScore).toBe(70);
      expect(server.LastCheckInAt?.toISOString()).toBe('2026-11-10T12:00:00.000Z');
      expect(server.NextCheckInDueAt?.toISOString()).toBe('2026-11-17T12:00:00.000Z');
    });

    it('refuses a non-UUID TypeID in loadDefaultTaskTypeStatus before any RunView query runs', async () => {
      const server = new TaskEntityServer();
      const loader = server as unknown as {
        loadDefaultTaskTypeStatus: (id: string) => Promise<unknown>;
      };

      await expect(loader.loadDefaultTaskTypeStatus("x' OR 1=1 --")).rejects.toThrow(/TypeID .* is not a valid ID/);
      expect(H.runViewCalls).toHaveLength(0);
    });

    it('runs hook actions on the Task\'s provider', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.Name = 'Task';

      await server.invokeAction('ACTION-CREATE', 'OnCreate', 'TYPE', null, null);

      const callArgs = (ActionEngineServer.Instance.RunAction as unknown as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(callArgs.Provider).toBe(H.provider);
    });

    it('writes activity rows on the Task\'s provider and queues the hooks until the caller commits', async () => {
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.Name = 'New task';
      server.TypeID = TYPE_UUID;
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
      server.ID = TASK_UUID;
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
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      vi.spyOn(server, 'dispatchLifecycleActionHooks').mockRejectedValue(new Error('read failed'));

      await server.Save();
      const task = (H.provider.RunAfterCommit as ReturnType<typeof vi.fn>).mock.calls[0][0] as () => Promise<void>;

      await expect(task()).resolves.toBeUndefined();
      expect(LogError).toHaveBeenCalledWith(`TaskEntityServer: action hook dispatch error for task ${TASK_UUID}: read failed`);
    });

    it('starts the hooks right away on a provider without a post-commit scheduler', async () => {
      resetProvider(false);
      const server = new TaskEntityServer();
      server.ID = TASK_UUID;
      server.TypeID = TYPE_UUID;
      const dispatchSpy = vi.spyOn(server, 'dispatchLifecycleActionHooks').mockResolvedValue(undefined);

      await server.Save();

      expect(dispatchSpy).toHaveBeenCalledTimes(1);
    });

    it('refuses a provider that cannot load entities instead of falling back to the global one', async () => {
      delete H.provider.GetEntityObject;
      const server = new TaskEntityServer();
      const loader = server as unknown as { loadTaskType: (id: string) => Promise<unknown> };

      await expect(loader.loadTaskType(TYPE_UUID)).rejects.toThrow(/server-only/);
      expect(H.globalGetEntityObject).not.toHaveBeenCalled();
    });
  });
});
