import { describe, it, expect, beforeEach, vi } from 'vitest';

// Capture LogStatus/LogError so we can assert the success vs failure branch.
const logStatus = vi.fn();
const logError = vi.fn();

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: (...a: unknown[]) => logError(...a),
  LogStatus: (...a: unknown[]) => logStatus(...a),
  Metadata: class {},
  RunView: class { RunView() { return Promise.resolve({ Results: [] }); } },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  MJGlobal: { Instance: { GetGlobalObjectStore: () => ({}), GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }) } },
}));

import { interpretActionHookResult } from '../TaskNotificationHandler.js';

beforeEach(() => vi.clearAllMocks());

describe('interpretActionHookResult (action-hook result capture)', () => {
  it('captures a SUCCESSFUL action result and logs success', () => {
    const out = interpretActionHookResult({ Success: true, Message: 'order returned to draft' }, 'OnRejectActionID', 'Approve PO');
    expect(out).toEqual({ Invoked: true, Success: true, Message: 'order returned to draft' });
    expect(logStatus).toHaveBeenCalledOnce();
    expect(logStatus.mock.calls[0][0]).toContain('Invoked OnRejectActionID');
    expect(logError).not.toHaveBeenCalled();
  });

  it('captures a FAILED action result and logs the failure loudly', () => {
    const out = interpretActionHookResult({ Success: false, Message: 'rollback failed' }, 'OnCancelActionID', 'Cancel PO');
    expect(out).toEqual({ Invoked: true, Success: false, Message: 'rollback failed' });
    expect(logError).toHaveBeenCalledOnce();
    expect(logError.mock.calls[0][0]).toContain('reported failure: rollback failed');
    expect(logStatus).not.toHaveBeenCalled();
  });

  it('treats a missing/null result as failure (non-blocking)', () => {
    const out = interpretActionHookResult(null, 'OnRejectActionID', 'X');
    expect(out.Invoked).toBe(true);
    expect(out.Success).toBe(false);
    expect(logError).toHaveBeenCalledOnce();
  });

  it('treats Success!==true (e.g. undefined) as failure', () => {
    const out = interpretActionHookResult({ Message: 'no success flag' }, 'OnCompleteActionID', 'Y');
    expect(out.Success).toBe(false);
    expect(logError.mock.calls[0][0]).toContain('no success flag');
  });
});
