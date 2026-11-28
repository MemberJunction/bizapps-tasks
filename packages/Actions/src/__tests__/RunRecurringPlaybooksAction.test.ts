import { describe, expect, it, vi, beforeEach } from 'vitest';
import { RunActionParams } from '@memberjunction/actions-base';
import { UserInfo } from '@memberjunction/core';
import { TasksRunRecurringPlaybooksOperation } from '@mj-biz-apps/tasks-core';
import { RunRecurringPlaybooksAction } from '../custom/RunRecurringPlaybooksAction.js';

const mockUser = { ID: 'user-1', Name: 'Controller' } as UserInfo;

describe('RunRecurringPlaybooksAction', () => {
    beforeEach(() => {
        vi.restoreAllMocks();
    });

    it('returns MISSING_PARAMS when TemplateID is omitted', async () => {
        const action = new RunRecurringPlaybooksAction();
        const params: RunActionParams = {
            Action: {} as RunActionParams['Action'],
            ContextUser: mockUser,
            Params: [],
            Filters: [],
        };
        const result = await action.Run(params);
        expect(result.Success).toBe(false);
        expect(result.ResultCode).toBe('MISSING_PARAMS');
    });

    it('returns INVALID_PARAMS when RoleAssignmentsJSON is not valid JSON', async () => {
        const action = new RunRecurringPlaybooksAction();
        const params: RunActionParams = {
            Action: {} as RunActionParams['Action'],
            ContextUser: mockUser,
            Params: [
                { Name: 'TemplateID', Value: 'tmpl-1', Type: 'Input' },
                { Name: 'RoleAssignmentsJSON', Value: '{invalid', Type: 'Input' },
            ],
            Filters: [],
        };
        const result = await action.Run(params);
        expect(result.Success).toBe(false);
        expect(result.ResultCode).toBe('INVALID_PARAMS');
    });

    it('delegates to TasksRunRecurringPlaybooksOperation and populates output params', async () => {
        const executeSpy = vi
            .spyOn(TasksRunRecurringPlaybooksOperation.prototype, 'Execute')
            .mockResolvedValue({
                Success: true,
                Output: {
                    TemplateID: 'tmpl-close',
                    PeriodKey: '2026-12',
                    AnchorDate: '2026-12-01',
                    DryRun: false,
                    TargetOrganizations: 2,
                    LaunchedCount: 1,
                    SkippedCount: 1,
                    FailedCount: 0,
                    TotalTasksCreated: 6,
                    Results: [
                        {
                            OrganizationID: 'org-1',
                            OrganizationName: 'Acme Corp',
                            Status: 'created',
                            CreatedCount: 6,
                            CreatedTaskIDs: ['t1', 't2', 't3', 't4', 't5', 't6'],
                        },
                        {
                            OrganizationID: 'org-2',
                            OrganizationName: 'Beta LLC',
                            Status: 'skipped',
                            CreatedCount: 0,
                            CreatedTaskIDs: [],
                            Reason: 'Already launched',
                        },
                    ],
                },
            });

        const action = new RunRecurringPlaybooksAction();
        const params: RunActionParams = {
            Action: {} as RunActionParams['Action'],
            ContextUser: mockUser,
            Params: [
                { Name: 'TemplateID', Value: 'tmpl-close', Type: 'Input' },
                { Name: 'AnchorDate', Value: '2026-12-01', Type: 'Input' },
                { Name: 'PeriodKey', Value: '2026-12', Type: 'Input' },
                { Name: 'OrganizationIDs', Value: 'org-1, org-2', Type: 'Input' },
                { Name: 'DryRun', Value: 'false', Type: 'Input' },
            ],
            Filters: [],
        };

        const result = await action.Run(params);
        expect(result.Success).toBe(true);
        expect(result.ResultCode).toBe('SUCCESS');
        expect(executeSpy).toHaveBeenCalledWith(
            expect.objectContaining({
                TemplateID: 'tmpl-close',
                AnchorDate: '2026-12-01',
                PeriodKey: '2026-12',
                OrganizationIDs: ['org-1', 'org-2'],
                AllMirroredCompanies: false,
                DryRun: false,
            }),
            { user: mockUser },
        );

        const outMap = new Map(params.Params.filter((p) => p.Type === 'Output').map((p) => [p.Name, p.Value]));
        expect(outMap.get('LaunchedCount')).toBe(1);
        expect(outMap.get('SkippedCount')).toBe(1);
        expect(outMap.get('TotalTasksCreated')).toBe(6);
    });

    it('returns PARTIAL_FAILURE when one or more organizations fail', async () => {
        vi.spyOn(TasksRunRecurringPlaybooksOperation.prototype, 'Execute').mockResolvedValue({
            Success: true,
            Output: {
                TemplateID: 'tmpl-close',
                PeriodKey: '2026-12',
                AnchorDate: '2026-12-01',
                DryRun: false,
                TargetOrganizations: 2,
                LaunchedCount: 1,
                SkippedCount: 0,
                FailedCount: 1,
                TotalTasksCreated: 3,
                Results: [],
            },
        });

        const action = new RunRecurringPlaybooksAction();
        const params: RunActionParams = {
            Action: {} as RunActionParams['Action'],
            ContextUser: mockUser,
            Params: [{ Name: 'TemplateID', Value: 'tmpl-close', Type: 'Input' }],
            Filters: [],
        };

        const result = await action.Run(params);
        expect(result.Success).toBe(false);
        expect(result.ResultCode).toBe('PARTIAL_FAILURE');
    });
});
