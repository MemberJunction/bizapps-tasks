import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

const { runView, logStatus, engine } = vi.hoisted(() => ({
    runView: vi.fn(),
    logStatus: vi.fn(),
    engine: {
        Config: vi.fn(),
        getCredentialByName: vi.fn(),
        getDefaultCredentialForType: vi.fn(),
        getCredential: vi.fn(),
    },
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));
vi.mock('@memberjunction/core', () => ({ RunView: class { RunView = runView; }, LogStatus: logStatus }));
vi.mock('@memberjunction/credentials', () => ({ CredentialEngine: { Instance: engine } }));

import { PostTaskAssignmentToTeamsAction } from '../custom/PostTaskAssignmentToTeamsAction.js';

const TYPE_ID = '3a1f0c52-7d4e-4b8a-9c6e-2f5d8b1e4a70';
const WEBHOOK = 'https://tenant.environment.api.powerplatform.com/powerautomate/workflows/x/invoke?sig=secret';
const fetchMock = vi.fn();

type Result = { Success: boolean; ResultCode: string; Message?: string };
async function run(params: Record<string, string>): Promise<Result> {
    const action = new PostTaskAssignmentToTeamsAction() as unknown as { InternalRunAction(p: unknown): Promise<Result> };
    return action.InternalRunAction({
        ContextUser: { ID: 'user-1' },
        Params: Object.entries(params).map(([Name, Value]) => ({ Name, Value, Type: 'Input' })),
    });
}

const baseParams = { TaskID: 'task-1', TaskName: 'Approve discount', TaskTypeID: TYPE_ID, AssigneeName: 'Pat Doe' };

beforeEach(() => {
    vi.clearAllMocks();
    vi.stubGlobal('fetch', fetchMock);
    runView.mockResolvedValue({ Success: true, Results: [{ ID: TYPE_ID, Name: 'Concession Approval', Code: 'CONCESSION_APPROVAL' }] });
    engine.getCredentialByName.mockReturnValue({ ID: 'cred-1', Name: 'CONCESSION_APPROVAL' });
    engine.getCredential.mockResolvedValue({ values: { webhookUrl: WEBHOOK, explorerUrl: 'https://app.example.com' } });
    fetchMock.mockResolvedValue({ ok: true, status: 202, text: async () => '' });
});

afterEach(() => vi.unstubAllGlobals());

describe('PostTaskAssignmentToTeamsAction', () => {
    it('posts the card to the credential named after the task type code', async () => {
        const result = await run(baseParams);

        expect(result).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(engine.getCredentialByName).toHaveBeenCalledWith('Teams Channel Webhook', 'CONCESSION_APPROVAL');
        const [url, init] = fetchMock.mock.calls[0];
        expect(url).toBe(WEBHOOK);
        const body = JSON.parse(init.body);
        expect(JSON.stringify(body)).toContain('Pat Doe');
        expect(JSON.stringify(body)).toContain('https://app.example.com/resource/record/');
    });

    it('uses an explicit CredentialName over the task type code', async () => {
        await run({ ...baseParams, CredentialName: 'Finance channel' });
        expect(engine.getCredentialByName).toHaveBeenCalledWith('Teams Channel Webhook', 'Finance channel');
    });

    it('falls back to the default credential of the type', async () => {
        engine.getCredentialByName.mockReturnValue(undefined);
        engine.getDefaultCredentialForType.mockReturnValue({ ID: 'cred-default', Name: 'Default' });

        const result = await run(baseParams);

        expect(result.Success).toBe(true);
        expect(engine.getCredential).toHaveBeenCalledWith('Default', expect.objectContaining({ credentialId: 'cred-default' }));
        expect(logStatus).toHaveBeenCalledWith(expect.stringContaining('using the default credential "Default"'));
    });

    it('rejects a TaskTypeID that is not a UUID before querying', async () => {
        const result = await run({ ...baseParams, TaskTypeID: "x' OR '1'='1" });

        expect(result).toMatchObject({ Success: false, ResultCode: 'INVALID_TASK_TYPE' });
        expect(runView).not.toHaveBeenCalled();
        expect(fetchMock).not.toHaveBeenCalled();
    });

    it('fails without posting when no credential exists', async () => {
        engine.getCredentialByName.mockReturnValue(undefined);
        engine.getDefaultCredentialForType.mockReturnValue(undefined);

        const result = await run(baseParams);

        expect(result).toMatchObject({ Success: false, ResultCode: 'MISSING_CREDENTIAL' });
        expect(fetchMock).not.toHaveBeenCalled();
    });

    it('rejects a webhook URL on another host', async () => {
        engine.getCredential.mockResolvedValue({ values: { webhookUrl: 'https://example.com/hook' } });

        const result = await run(baseParams);

        expect(result.ResultCode).toBe('INVALID_WEBHOOK_URL');
        expect(fetchMock).not.toHaveBeenCalled();
    });

    it('reports a non-2xx response without echoing the signed URL', async () => {
        fetchMock.mockResolvedValue({ ok: false, status: 401, text: async () => 'unauthorized' });

        const result = await run(baseParams);

        expect(result).toMatchObject({ Success: false, ResultCode: 'TEAMS_ERROR' });
        expect(result.Message).toContain('401');
        expect(result.Message).not.toContain('sig=secret');
    });

    it('requires the task ID and name', async () => {
        const result = await run({ TaskTypeID: TYPE_ID });
        expect(result.ResultCode).toBe('MISSING_TASK');
    });
});
