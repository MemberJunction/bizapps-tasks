import { beforeEach, describe, expect, it, vi } from 'vitest';

const runViewMock = vi.fn();
const recordEventMock = vi.fn();

vi.mock('@memberjunction/core', () => ({
    RunView: class {
        RunView(params: { EntityName: string; ExtraFilter: string; Fields?: string[]; ResultType?: string; MaxRows?: number }) {
            return runViewMock(params);
        }
    },
    TelemetryManager: {
        Instance: {
            RecordEvent: (...args: Array<string | number | boolean | Record<string, string | number | boolean>>) =>
                recordEventMock(...args),
        },
    },
}));

import {
    DefaultApprovalRouteScrubber,
    QueryApprovalLatencyMetrics,
    RecordApprovalDecisionLatency,
    RedactTelemetryText,
} from '../ApprovalLatencyService.js';

const ORG_ID = '11111111-1111-4111-8111-111111111111';
const TYPE_ID = '22222222-2222-4222-8222-222222222222';
const TASK_1 = '33333333-3333-4333-8333-333333333331';
const TASK_2 = '33333333-3333-4333-8333-333333333332';
const DEC_1 = '44444444-4444-4444-8444-444444444441';
const DEC_2 = '44444444-4444-4444-8444-444444444442';
const OUTCOME_ID = '55555555-5555-4555-8555-555555555555';

beforeEach(() => {
    vi.clearAllMocks();
});

describe('ApprovalLatencyService — RouteScrubber and PII/UUID redaction', () => {
    it('scrubs UUIDs, emails, query strings, and search terms using fail-closed RouteScrubber rules', () => {
        expect(
            DefaultApprovalRouteScrubber.Scrub(`app/Tasks/record/Task/${TASK_1}?email=alice@example.com`),
        ).toEqual({
            RouteTemplate: 'app/:appName/record/:entityName/:recordId',
            ScrubbedPath: '/app/Tasks/record/Task/_id_',
        });
        expect(DefaultApprovalRouteScrubber.Scrub('resource/search/secret%20payroll?token=abc')).toEqual({
            RouteTemplate: 'resource/search/:searchInput',
            ScrubbedPath: '/resource/search/[REDACTED]',
        });
        expect(DefaultApprovalRouteScrubber.Scrub('/unrecognized/route/123')).toEqual({
            RouteTemplate: 'unknown',
            ScrubbedPath: '/unknown',
        });
        expect(
            RedactTelemetryText(`Task ${TASK_1} failed for alice@acme.com Bearer secret.jwt.token`),
        ).toBe('Task _id_ failed for [REDACTED_EMAIL] Bearer [REDACTED]');
    });

    it('emits approval creation-to-decision latency via TelemetryManager.Instance with zero UUID or PII leakage', () => {
        const attrs = RecordApprovalDecisionLatency({
            CreatedAt: '2026-11-23T00:00:00.000Z',
            DecidedAt: '2026-11-23T00:05:30.000Z',
            OutcomeCode: 'Approved',
            IsTerminal: true,
            Success: true,
            Route: `app/Tasks/record/Task/${TASK_1}?user=bob@example.com`,
            ErrorCode: 'NONE',
            ErrorMessage: `Blocked for user alice@example.com on ${TASK_2}`,
        });

        expect(attrs.latencyMs).toBe(330000);
        expect(attrs.routeTemplate).toBe('app/:appName/record/:entityName/:recordId');
        expect(attrs.scrubbedPath).toBe('/app/Tasks/record/Task/_id_');
        expect(recordEventMock).toHaveBeenCalledTimes(1);

        const [category, operation, emittedParams, elapsedMs] = recordEventMock.mock.calls[0];
        expect(category).toBe('Custom');
        expect(operation).toBe('BizAppsTasks:ApprovalDecisionLatency');
        expect(elapsedMs).toBe(330000);

        const serialized = JSON.stringify(emittedParams);
        expect(serialized).not.toContain(TASK_1);
        expect(serialized).not.toContain(TASK_2);
        expect(serialized).not.toContain('alice@example.com');
        expect(serialized).not.toContain('bob@example.com');
        expect(serialized).toContain('_id_');
        expect(serialized).toContain('[REDACTED_EMAIL]');
    });
});

describe('QueryApprovalLatencyMetrics', () => {
    it('queries Task Decisions and Tasks via RunView Simple with zero MaxRows caps and computes percentiles', async () => {
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: TASK_1, TypeID: TYPE_ID, OrganizationID: ORG_ID, Status: 'Completed', __mj_CreatedAt: '2026-11-23T00:00:00.000Z', CompletedAt: '2026-11-23T00:01:00.000Z' },
                    { ID: TASK_2, TypeID: TYPE_ID, OrganizationID: ORG_ID, Status: 'Cancelled', __mj_CreatedAt: '2026-11-23T00:00:00.000Z', CompletedAt: '2026-11-23T00:03:00.000Z' },
                ],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: DEC_1, TaskID: TASK_1, OutcomeID: OUTCOME_ID, Outcome: 'Approved', DecidedAt: '2026-11-23T00:01:00.000Z', __mj_CreatedAt: '2026-11-23T00:01:00.000Z' },
                    { ID: DEC_2, TaskID: TASK_2, OutcomeID: OUTCOME_ID, Outcome: 'Rejected', DecidedAt: '2026-11-23T00:03:00.000Z', __mj_CreatedAt: '2026-11-23T00:03:00.000Z' },
                ],
            });

        const res = await QueryApprovalLatencyMetrics({
            OrganizationID: ORG_ID,
            TaskTypeID: TYPE_ID,
            Since: '2026-11-22T00:00:00.000Z',
            Until: '2026-11-24T00:00:00.000Z',
        });

        expect(runViewMock).toHaveBeenCalledTimes(2);
        for (const call of runViewMock.mock.calls) {
            const params = call[0] as { ResultType: string; Fields?: string[]; MaxRows?: number };
            expect(params.ResultType).toBe('simple');
            expect(Array.isArray(params.Fields) && params.Fields.length > 0).toBe(true);
            expect(params.MaxRows).toBeUndefined();
        }
        expect(res.Records).toHaveLength(2);
        expect(res.Summary).toEqual({
            Count: 2,
            MinLatencyMs: 60000,
            MaxLatencyMs: 180000,
            AvgLatencyMs: 120000,
            P95LatencyMs: 180000,
        });
    });

    it('rejects malformed OrganizationID filters before issuing SQL queries', async () => {
        await expect(
            QueryApprovalLatencyMetrics({ OrganizationID: "bad' OR 1=1--" }),
        ).rejects.toThrow(/OrganizationID .* is not a valid ID/);
        expect(runViewMock).not.toHaveBeenCalled();
    });
});
