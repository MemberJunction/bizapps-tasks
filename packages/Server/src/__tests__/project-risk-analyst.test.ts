import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { IMetadataProvider, IRunViewProvider, RunViewParams, RunViewResult, UserInfo } from '@memberjunction/core';
import type { TaskRiskItem } from '@mj-biz-apps/tasks-entities';
import {
    PROJECT_RISK_ANALYST_AGENT_NAME,
    PROJECT_RISK_ANALYST_CONFIG_NAME,
    ProjectRiskAnalystService,
    type ProjectRiskAgentExecutionInput,
    type ProjectRootTaskRow,
} from '../risk/ProjectRiskAnalystService.js';

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '../../../..');

const ROOT_TASK_ID = '11111111-1111-4111-8111-111111111111';
const SUBTASK_1_ID = '22222222-2222-4222-8222-222222222221';
const SUBTASK_2_ID = '22222222-2222-4222-8222-222222222222';
const SUBTASK_3_ID = '22222222-2222-4222-8222-222222222223';
const DEP_ID = '33333333-3333-4333-8333-333333333331';
const LINK_ID = '44444444-4444-4444-8444-444444444441';
const CHECKIN_ID = '55555555-5555-4555-8555-555555555551';
const OWNER_PERSON_ID = '66666666-6666-4666-8666-666666666661';
const OWNER_USER_ID = '77777777-7777-4777-8777-777777777771';
const CALLER_USER_ID = '88888888-8888-4888-8888-888888888881';
const AGENT_RUN_ID = '99999999-9999-4999-8999-999999999991';
const ASSESSMENT_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const PEOPLE_ENTITY_ID = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const USERS_ENTITY_ID = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';

interface CapturedRunViewCall {
    entityName: string;
    contextUserId: string | undefined;
    resultType: string | undefined;
}

interface MockAssessmentEntity {
    ID: string;
    TaskID: string;
    AssessedAt: Date;
    ForecastCompletionDate: Date | null;
    ForecastConfidence: number | null;
    HealthStatus: 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused';
    MLBreachProbability: number | null;
    Risks: string;
    AgentRunID: string | null;
    PromptTokens: number | null;
    CompletionTokens: number | null;
    TotalCostUSD: number | null;
    LatestResult: { CompleteMessage: string };
    NewRecord: () => void;
    SetParsedRisks: (items: ReadonlyArray<TaskRiskItem>) => void;
    Save: () => Promise<boolean>;
}

interface AgentMetadataRecord {
    fields: {
        Name: string;
        Status: string;
        ModelSelectionMode: string;
        DefaultPromptEffortLevel: number;
        TypeConfiguration: {
            executionIdentity: string;
            modelTier: string;
            cadencePolicy: {
                defaultFrequency: string;
                finalWindowPercent: number;
                escalatedFrequency: string;
            };
        };
    };
    relatedEntities: {
        'MJ: AI Agent Prompts': Array<{
            fields: { PromptID: string; Status: string };
        }>;
        'MJ: AI Agent Configurations': Array<{
            fields: {
                Name: string;
                AIConfigurationID: string;
                IsDefault: boolean;
                Status: string;
            };
        }>;
    };
}

interface PromptMetadataRecord {
    fields: {
        Name: string;
        ResponseFormat: string;
        PowerPreference: string;
        EffortLevel: number;
        Status: string;
        TemplateText: string;
    };
}

function makeUserInfo(id: string, name: string, email: string): UserInfo {
    return {
        ID: id,
        Name: name,
        Email: email,
        Type: 'User',
        IsActive: true,
    } as UserInfo;
}

function buildQueryResult(
    params: RunViewParams,
    options: {
        rootTask: ProjectRootTaskRow;
        latestAssessment: Array<{ ID: string; AssessedAt: string }>;
        subtasks: Array<{
            ID: string;
            Name: string;
            Status: string;
            Priority: string;
            ParentID: string | null;
            StartedAt: string | null;
            DueAt: string | null;
            CompletedAt: string | null;
            PercentComplete: number;
            BlockedReason: string | null;
        }>;
    },
): RunViewResult<object> {
    const entity = params.EntityName ?? '';
    if (entity === 'MJ_BizApps_Tasks: Tasks') {
        const filter = params.ExtraFilter ?? '';
        if (filter.startsWith(`ID = '${SUBTASK_1_ID}'`)) {
            return {
                Success: true,
                Results: [
                    {
                        ...options.rootTask,
                        ID: SUBTASK_1_ID,
                        Name: 'Subtask 1',
                        ParentID: ROOT_TASK_ID,
                        RootParentID: ROOT_TASK_ID,
                    },
                ],
                RowCount: 1,
                TotalRowCount: 1,
                ExecutionTime: 1,
                ErrorMessage: '',
                UserViewGridState: undefined,
            };
        }
        if (filter.startsWith(`ID = '${ROOT_TASK_ID}'`)) {
            return {
                Success: true,
                Results: [options.rootTask],
                RowCount: 1,
                TotalRowCount: 1,
                ExecutionTime: 1,
                ErrorMessage: '',
                UserViewGridState: undefined,
            };
        }
        return {
            Success: true,
            Results: options.subtasks,
            RowCount: options.subtasks.length,
            TotalRowCount: options.subtasks.length,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Assignments') {
        const filter = params.ExtraFilter ?? '';
        if (filter.includes(`TaskID = '${ROOT_TASK_ID}'`)) {
            return {
                Success: true,
                Results: [
                    {
                        ID: 'assign-owner',
                        TaskID: ROOT_TASK_ID,
                        AssigneeEntityID: PEOPLE_ENTITY_ID,
                        AssigneeEntity: 'MJ_BizApps_Common: People',
                        AssigneeRecordID: OWNER_PERSON_ID,
                        Role: 'Primary',
                        Status: 'InProgress',
                    },
                ],
                RowCount: 1,
                TotalRowCount: 1,
                ExecutionTime: 1,
                ErrorMessage: '',
                UserViewGridState: undefined,
            };
        }
        return {
            Success: true,
            Results: [
                {
                    ID: 'assign-owner',
                    TaskID: ROOT_TASK_ID,
                    AssigneeEntityID: PEOPLE_ENTITY_ID,
                    AssigneeEntity: 'MJ_BizApps_Common: People',
                    AssigneeRecordID: OWNER_PERSON_ID,
                    Role: 'Primary',
                    Status: 'InProgress',
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Common: People') {
        return {
            Success: true,
            Results: [
                {
                    ID: OWNER_PERSON_ID,
                    Email: 'owner@acme.test',
                    LinkedUserID: OWNER_USER_ID,
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ: Users') {
        return {
            Success: true,
            Results: [
                {
                    ID: OWNER_USER_ID,
                    Name: 'Project Owner',
                    FirstName: 'Project',
                    LastName: 'Owner',
                    Title: 'Lead',
                    Email: 'owner@acme.test',
                    Type: 'User',
                    IsActive: true,
                    LinkedRecordType: 'None',
                    EmployeeID: null,
                    LinkedEntityID: null,
                    LinkedEntityRecordID: null,
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Risk Assessments') {
        return {
            Success: true,
            Results: options.latestAssessment,
            RowCount: options.latestAssessment.length,
            TotalRowCount: options.latestAssessment.length,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Dependencies') {
        return {
            Success: true,
            Results: [
                {
                    ID: DEP_ID,
                    TaskID: SUBTASK_2_ID,
                    Task: 'Cutover Migration',
                    DependsOnTaskID: SUBTASK_3_ID,
                    DependsOnTask: 'Vendor API Provisioning',
                    DependencyType: 'FinishToStart',
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Links') {
        return {
            Success: true,
            Results: [
                {
                    ID: LINK_ID,
                    TaskID: ROOT_TASK_ID,
                    EntityID: 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
                    Entity: 'Contracts',
                    RecordID: 'contract-42',
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Check Ins') {
        return {
            Success: true,
            Results: [
                {
                    ID: CHECKIN_ID,
                    TaskID: ROOT_TASK_ID,
                    CheckInAt: '2026-11-21T15:00:00.000Z',
                    HealthStatus: 'AtRisk',
                    ConfidenceScore: 62,
                    PercentComplete: 55,
                    Summary: 'Core migration scripts complete; waiting on vendor credentials.',
                    Blockers: 'Vendor API sandbox key delayed by 3 days.',
                },
            ],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    return {
        Success: true,
        Results: [],
        RowCount: 0,
        TotalRowCount: 0,
        ExecutionTime: 1,
        ErrorMessage: '',
        UserViewGridState: undefined,
    };
}

describe('ProjectRiskAnalystService & High-Tier Metadata', () => {
    let service: ProjectRiskAnalystService;

    beforeEach(() => {
        service = new ProjectRiskAnalystService();
    });

    it('ships High-tier Project Risk Analyst agent + prompt metadata and valid directoryOrder', () => {
        const syncConfig = JSON.parse(readFileSync(join(REPO_ROOT, 'metadata/.mj-sync.json'), 'utf8')) as {
            directoryOrder: string[];
        };
        expect(syncConfig.directoryOrder).toContain('agents');
        expect(syncConfig.directoryOrder.indexOf('agents')).toBeGreaterThan(
            syncConfig.directoryOrder.indexOf('prompts'),
        );

        const agents = JSON.parse(
            readFileSync(join(REPO_ROOT, 'metadata/agents/.project-risk-analyst-agent.json'), 'utf8'),
        ) as AgentMetadataRecord[];
        expect(agents).toHaveLength(1);
        const agent = agents[0];
        expect(agent.fields.Name).toBe(PROJECT_RISK_ANALYST_AGENT_NAME);
        expect(agent.fields.Status).toBe('Active');
        expect(agent.fields.ModelSelectionMode).toBe('Agent');
        expect(agent.fields.DefaultPromptEffortLevel).toBe(85);
        expect(agent.fields.TypeConfiguration.executionIdentity).toBe('ProjectOwner');
        expect(agent.fields.TypeConfiguration.modelTier).toBe('High');
        expect(agent.fields.TypeConfiguration.cadencePolicy).toEqual({
            defaultFrequency: 'Weekly',
            finalWindowPercent: 20,
            escalatedFrequency: 'Daily',
        });

        const highConfig = agent.relatedEntities['MJ: AI Agent Configurations'].find(
            (c) => c.fields.Name === PROJECT_RISK_ANALYST_CONFIG_NAME,
        );
        expect(highConfig).toBeDefined();
        expect(highConfig?.fields.AIConfigurationID).toBe('@lookup:MJ: AI Configurations.Name=High Power');
        expect(highConfig?.fields.IsDefault).toBe(true);

        const promptLink = agent.relatedEntities['MJ: AI Agent Prompts'][0];
        expect(promptLink.fields.PromptID).toBe('@lookup:MJ: AI Prompts.Name=Tasks: Project Risk Analyst');

        const prompts = JSON.parse(
            readFileSync(join(REPO_ROOT, 'metadata/prompts/.project-risk-analyst-prompt.json'), 'utf8'),
        ) as PromptMetadataRecord[];
        expect(prompts[0].fields.PowerPreference).toBe('Highest');
        expect(prompts[0].fields.ResponseFormat).toBe('JSON');
        expect(prompts[0].fields.Status).toBe('Active');

        const template = readFileSync(
            join(REPO_ROOT, 'metadata/prompts/templates/project-risk-analyst.template.md'),
            'utf8',
        );
        expect(template).toContain('{{ freeBusyJson }}');
        expect(template).toContain('{{ mlBreachJson }}');
    });

    it('resolves project owner user, collects batched evidence, strips sensitive calendar fields, consumes ML breach, and saves assessment', async () => {
        const now = new Date('2026-11-22T12:00:00.000Z');
        const rootTask: ProjectRootTaskRow = {
            ID: ROOT_TASK_ID,
            Name: 'Q4 Core Billing Cutover',
            ParentID: null,
            RootParentID: null,
            Status: 'InProgress',
            Priority: 'High',
            StartedAt: '2026-11-01T00:00:00.000Z',
            DueAt: '2026-11-25T00:00:00.000Z', // ~88.5% elapsed => Daily cadence
            PercentComplete: 55,
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: 'OnTrack',
            ConfidenceScore: 80,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: 0.7425,
            PredictedSLARiskBand: 'High',
            PredictedSLAScoredAt: '2026-11-22T06:00:00.000Z',
            __mj_CreatedAt: '2026-11-01T00:00:00.000Z',
        };

        const subtasks = [
            {
                ID: SUBTASK_1_ID,
                Name: 'Schema Freeze',
                Status: 'Completed',
                Priority: 'High',
                ParentID: ROOT_TASK_ID,
                StartedAt: '2026-11-01T00:00:00.000Z',
                DueAt: '2026-11-10T00:00:00.000Z',
                CompletedAt: '2026-11-12T00:00:00.000Z',
                PercentComplete: 100,
                BlockedReason: null,
            },
            {
                ID: SUBTASK_2_ID,
                Name: 'Cutover Migration',
                Status: 'Blocked',
                Priority: 'Critical',
                ParentID: ROOT_TASK_ID,
                StartedAt: '2026-11-10T00:00:00.000Z',
                DueAt: '2026-11-20T00:00:00.000Z', // Overdue by 2 days
                CompletedAt: null,
                PercentComplete: 30,
                BlockedReason: 'Waiting on upstream vendor API',
            },
            {
                ID: SUBTASK_3_ID,
                Name: 'Vendor API Provisioning',
                Status: 'Blocked',
                Priority: 'High',
                ParentID: ROOT_TASK_ID,
                StartedAt: '2026-11-05T00:00:00.000Z',
                DueAt: '2026-11-18T00:00:00.000Z', // Overdue by 4 days
                CompletedAt: null,
                PercentComplete: 20,
                BlockedReason: 'Vendor ticket open',
            },
        ];

        const capturedCalls: CapturedRunViewCall[] = [];
        let runViewsBatchCount = 0;

        const rvProvider: IRunViewProvider = {
            RunView: vi.fn(async <T>(params: RunViewParams, contextUser?: UserInfo): Promise<RunViewResult<T>> => {
                capturedCalls.push({
                    entityName: params.EntityName ?? '',
                    contextUserId: contextUser?.ID,
                    resultType: params.ResultType,
                });
                return buildQueryResult(params, { rootTask, latestAssessment: [], subtasks }) as RunViewResult<T>;
            }),
            RunViews: vi.fn(async <T>(paramsList: RunViewParams[], contextUser?: UserInfo): Promise<RunViewResult<T>[]> => {
                runViewsBatchCount++;
                for (const params of paramsList) {
                    capturedCalls.push({
                        entityName: params.EntityName ?? '',
                        contextUserId: contextUser?.ID,
                        resultType: params.ResultType,
                    });
                }
                return paramsList.map(
                    (params) => buildQueryResult(params, { rootTask, latestAssessment: [], subtasks }) as RunViewResult<T>,
                );
            }),
        };

        let savedAssessment: MockAssessmentEntity | null = null;
        let savedEntityUser: UserInfo | undefined;

        const mdProvider: IMetadataProvider = {
            EntityByName: (name: string) => {
                if (name === 'MJ_BizApps_Common: People') return { ID: PEOPLE_ENTITY_ID } as ReturnType<IMetadataProvider['EntityByName']>;
                if (name === 'MJ: Users') return { ID: USERS_ENTITY_ID } as ReturnType<IMetadataProvider['EntityByName']>;
                return undefined;
            },
            GetEntityObject: vi.fn(async <T>(_entityName: string, contextUser?: UserInfo): Promise<T> => {
                savedEntityUser = contextUser;
                const entity: MockAssessmentEntity = {
                    ID: ASSESSMENT_ID,
                    TaskID: '',
                    AssessedAt: new Date(0),
                    ForecastCompletionDate: null,
                    ForecastConfidence: null,
                    HealthStatus: 'OnTrack',
                    MLBreachProbability: null,
                    Risks: '[]',
                    AgentRunID: null,
                    PromptTokens: null,
                    CompletionTokens: null,
                    TotalCostUSD: null,
                    LatestResult: { CompleteMessage: '' },
                    NewRecord: vi.fn(),
                    SetParsedRisks: (items: ReadonlyArray<TaskRiskItem>) => {
                        entity.Risks = JSON.stringify(items);
                    },
                    Save: vi.fn(async () => {
                        savedAssessment = entity;
                        return true;
                    }),
                };
                return entity as T;
            }),
        } as IMetadataProvider;

        let capturedAgentInput: ProjectRiskAgentExecutionInput | null = null;
        const callerUser = makeUserInfo(CALLER_USER_ID, 'Caller Admin', 'caller@acme.test');

        const result = await service.AssessProjectRisk({
            TaskID: SUBTASK_1_ID, // Pass subtask ID to verify root resolution
            Provider: mdProvider,
            RunViewProvider: rvProvider,
            CallerContextUser: callerUser,
            Now: now,
            FreeBusyProvider: async ({ OwnerUser }) => {
                expect(OwnerUser.ID).toBe(OWNER_USER_ID);
                return [
                    {
                        PersonID: OWNER_PERSON_ID,
                        UserID: OWNER_USER_ID,
                        Slots: [
                            {
                                StartTime: '2026-11-23T14:00:00.000Z',
                                EndTime: '2026-11-23T16:00:00.000Z',
                                Status: 'Busy',
                                Subject: 'CONFIDENTIAL M&A COMPENSATION REVIEW',
                                Body: 'Secret layoff details',
                                Location: 'Executive Suite',
                                Attendees: ['cfo@acme.test'],
                            },
                        ],
                    },
                ];
            },
            AgentExecutor: async (input) => {
                capturedAgentInput = input;
                return {
                    Success: true,
                    AgentRunID: AGENT_RUN_ID,
                    PromptTokens: 1450,
                    CompletionTokens: 320,
                    TotalCostUSD: 0.04215,
                    Payload: {
                        healthStatus: 'AtRisk',
                        forecastCompletionDate: '2026-11-29T17:00:00.000Z',
                        forecastConfidence: 64,
                        summary: 'Vendor API blocker and high ML breach score push forecast 4 days past due.',
                        risks: [
                            {
                                kind: 'dependency_blocker',
                                severity: 'high',
                                evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${SUBTASK_3_ID}`],
                                suggestedMitigation: 'Escalate vendor API provisioning ticket to executive sponsor.',
                            },
                        ],
                    },
                };
            },
        });

        // 1. Batched RunViews used with ResultType: 'simple' under OwnerUser
        expect(runViewsBatchCount).toBeGreaterThanOrEqual(2);
        const evidenceCalls = capturedCalls.filter(
            (c) =>
                c.entityName === 'MJ_BizApps_Tasks: Task Dependencies' ||
                c.entityName === 'MJ_BizApps_Tasks: Task Links' ||
                c.entityName === 'MJ_BizApps_Tasks: Task Check Ins' ||
                c.entityName === 'MJ_BizApps_Tasks: Task Risk Assessments',
        );
        expect(evidenceCalls.length).toBeGreaterThanOrEqual(4);
        for (const call of evidenceCalls) {
            expect(call.contextUserId).toBe(OWNER_USER_ID);
            expect(call.resultType).toBe('simple');
        }

        // 2. Agent executed as OwnerUser on High tier
        expect(capturedAgentInput).not.toBeNull();
        expect(capturedAgentInput?.OwnerUser.ID).toBe(OWNER_USER_ID);
        expect(capturedAgentInput?.PreferredConfigurationName).toBe('High');
        expect(capturedAgentInput?.RootTaskID).toBe(ROOT_TASK_ID);

        // 3. Free/Busy privacy boundary: ZERO sensitive calendar strings leaked into PromptData
        const serializedPrompt = JSON.stringify(capturedAgentInput?.PromptData ?? {});
        expect(serializedPrompt).not.toContain('CONFIDENTIAL M&A COMPENSATION REVIEW');
        expect(serializedPrompt).not.toContain('Secret layoff details');
        expect(serializedPrompt).not.toContain('Executive Suite');
        expect(serializedPrompt).not.toContain('cfo@acme.test');
        expect(capturedAgentInput?.Evidence.FreeBusy.Assignees[0].BusyMinutes).toBe(120);

        // 4. Evidence signals & ML breach integration
        expect(result.TaskID).toBe(ROOT_TASK_ID);
        expect(result.OwnerUserID).toBe(OWNER_USER_ID);
        expect(result.Cadence.Cadence).toBe('Daily');
        expect(result.Cadence.IsFinal20Percent).toBe(true);
        expect(result.Evidence?.Velocity.TotalSubtasks).toBe(3);
        expect(result.Evidence?.Velocity.CompletedCount).toBe(1);
        expect(result.Evidence?.Velocity.BlockedCount).toBe(2);
        expect(result.Evidence?.BlockedDependencies.BlockedDependencyCount).toBe(1);
        expect(result.Evidence?.CheckIns.TotalCheckIns).toBe(1);
        expect(result.Evidence?.OverdueItems.OverdueCount).toBe(2);
        expect(result.MLBreachProbability).toBe(0.7425);

        // 5. Persisted TaskRiskAssessmentEntity under OwnerUser
        expect(savedEntityUser?.ID).toBe(OWNER_USER_ID);
        expect(savedAssessment).not.toBeNull();
        expect(savedAssessment?.TaskID).toBe(ROOT_TASK_ID);
        expect(savedAssessment?.HealthStatus).toBe('AtRisk');
        expect(savedAssessment?.ForecastConfidence).toBe(64);
        expect(savedAssessment?.MLBreachProbability).toBe(0.7425);
        expect(savedAssessment?.AgentRunID).toBe(AGENT_RUN_ID);
        expect(savedAssessment?.PromptTokens).toBe(1450);
        expect(savedAssessment?.CompletionTokens).toBe(320);
        expect(savedAssessment?.TotalCostUSD).toBe(0.04215);
    });

    it('transitions cadence from Weekly to Daily at the final 20% timeline boundary (79% vs 80% vs 81% vs overdue)', () => {
        const baseTask = {
            Status: 'InProgress' as const,
            StartedAt: new Date('2026-11-01T00:00:00.000Z'), // 100-hour timeline
            DueAt: new Date('2026-11-05T04:00:00.000Z'),
            __mj_CreatedAt: new Date('2026-11-01T00:00:00.000Z'),
        };

        // 79% elapsed -> 21% remaining -> Weekly
        const at79 = service.EvaluateCadence(baseTask, null, new Date('2026-11-04T07:00:00.000Z'));
        expect(at79.Cadence).toBe('Weekly');
        expect(at79.IntervalHours).toBe(168);
        expect(at79.IsFinal20Percent).toBe(false);
        expect(at79.IsOverdue).toBe(false);
        expect(at79.Reason).toBe('First80Percent');

        // Exact 80% elapsed -> 20% remaining -> Daily
        const at80 = service.EvaluateCadence(baseTask, null, new Date('2026-11-04T08:00:00.000Z'));
        expect(at80.Cadence).toBe('Daily');
        expect(at80.IntervalHours).toBe(24);
        expect(at80.IsFinal20Percent).toBe(true);
        expect(at80.IsOverdue).toBe(false);
        expect(at80.Reason).toBe('Final20Percent');

        // 81% elapsed -> 19% remaining -> Daily
        const at81 = service.EvaluateCadence(baseTask, null, new Date('2026-11-04T09:00:00.000Z'));
        expect(at81.Cadence).toBe('Daily');
        expect(at81.IsFinal20Percent).toBe(true);
        expect(at81.Reason).toBe('Final20Percent');

        // Overdue -> Daily + IsOverdue
        const overdue = service.EvaluateCadence(baseTask, null, new Date('2026-11-06T00:00:00.000Z'));
        expect(overdue.Cadence).toBe('Daily');
        expect(overdue.IsOverdue).toBe(true);
        expect(overdue.IsFinal20Percent).toBe(true);
        expect(overdue.Reason).toBe('Overdue');

        // Missing DueAt -> fallback Weekly
        const missingBounds = service.EvaluateCadence(
            { Status: 'Open', StartedAt: null, DueAt: null, __mj_CreatedAt: new Date('2026-11-01T00:00:00.000Z') },
            null,
            new Date('2026-11-10T00:00:00.000Z'),
        );
        expect(missingBounds.Cadence).toBe('Weekly');
        expect(missingBounds.Reason).toBe('MissingTimelineDates');

        // Terminal status -> skip scheduled run
        const completed = service.EvaluateCadence(
            { ...baseTask, Status: 'Completed' },
            null,
            new Date('2026-11-04T09:00:00.000Z'),
        );
        expect(completed.ShouldSkipScheduledRun).toBe(true);
        expect(completed.Reason).toBe('TerminalTaskStatus');
    });

    it('skips scheduled runs within the active cadence cooldown window and deduplicates concurrent in-flight runs', async () => {
        const now = new Date('2026-11-22T12:00:00.000Z');
        const rootTask: ProjectRootTaskRow = {
            ID: ROOT_TASK_ID,
            Name: 'Cooldown Project',
            ParentID: null,
            RootParentID: null,
            Status: 'InProgress',
            Priority: 'Medium',
            StartedAt: '2026-11-01T00:00:00.000Z',
            DueAt: '2026-11-24T00:00:00.000Z', // Final 20% => Daily (24h cooldown)
            PercentComplete: 70,
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: 'OnTrack',
            ConfidenceScore: 75,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: 0.25,
            PredictedSLARiskBand: 'Low',
            PredictedSLAScoredAt: '2026-11-22T00:00:00.000Z',
            __mj_CreatedAt: '2026-11-01T00:00:00.000Z',
        };

        const rvProvider: IRunViewProvider = {
            RunView: vi.fn(async <T>(params: RunViewParams) =>
                buildQueryResult(params, {
                    rootTask,
                    latestAssessment: [{ ID: 'prev-1', AssessedAt: '2026-11-22T06:00:00.000Z' }],
                    subtasks: [],
                }) as RunViewResult<T>,
            ),
            RunViews: vi.fn(async <T>(paramsList: RunViewParams[]) =>
                paramsList.map(
                    (params) =>
                        buildQueryResult(params, {
                            rootTask,
                            latestAssessment: [{ ID: 'prev-1', AssessedAt: '2026-11-22T06:00:00.000Z' }],
                            subtasks: [],
                        }) as RunViewResult<T>,
                ),
            ),
        };

        const mdProvider: IMetadataProvider = {
            EntityByName: () => undefined,
            GetEntityObject: vi.fn(async <T>() => {
                const entity: MockAssessmentEntity = {
                    ID: ASSESSMENT_ID,
                    TaskID: ROOT_TASK_ID,
                    AssessedAt: now,
                    ForecastCompletionDate: null,
                    ForecastConfidence: 82,
                    HealthStatus: 'OnTrack',
                    MLBreachProbability: 0.25,
                    Risks: '[]',
                    AgentRunID: null,
                    PromptTokens: null,
                    CompletionTokens: null,
                    TotalCostUSD: null,
                    LatestResult: { CompleteMessage: '' },
                    NewRecord: vi.fn(),
                    SetParsedRisks: vi.fn(),
                    Save: vi.fn(async () => true),
                };
                return entity as T;
            }),
        } as IMetadataProvider;

        const agentExecutor = vi.fn(async () => ({
            Success: true,
            AgentRunID: AGENT_RUN_ID,
            PromptTokens: 100,
            CompletionTokens: 50,
            TotalCostUSD: 0.01,
            Payload: {
                healthStatus: 'OnTrack',
                forecastCompletionDate: '2026-11-24T00:00:00.000Z',
                forecastConfidence: 82,
                summary: 'Healthy trajectory.',
                risks: [],
            },
        }));

        const skipped = await service.AssessProjectRisk({
            TaskID: ROOT_TASK_ID,
            Provider: mdProvider,
            RunViewProvider: rvProvider,
            CallerContextUser: makeUserInfo(CALLER_USER_ID, 'Caller', 'caller@acme.test'),
            Force: false,
            Now: now,
            AgentExecutor: agentExecutor,
        });

        expect(skipped.Skipped).toBe(true);
        expect(skipped.Cadence.Cadence).toBe('Daily');
        expect(agentExecutor).not.toHaveBeenCalled();

        // Concurrent forced calls deduplicate into a single agent invocation
        const [first, second] = await Promise.all([
            service.AssessProjectRisk({
                TaskID: ROOT_TASK_ID,
                Provider: mdProvider,
                RunViewProvider: rvProvider,
                CallerContextUser: makeUserInfo(CALLER_USER_ID, 'Caller', 'caller@acme.test'),
                Force: true,
                Now: now,
                AgentExecutor: agentExecutor,
            }),
            service.AssessProjectRisk({
                TaskID: ROOT_TASK_ID,
                Provider: mdProvider,
                RunViewProvider: rvProvider,
                CallerContextUser: makeUserInfo(CALLER_USER_ID, 'Caller', 'caller@acme.test'),
                Force: true,
                Now: now,
                AgentExecutor: agentExecutor,
            }),
        ]);

        expect(agentExecutor).toHaveBeenCalledTimes(1);
        expect(first.AssessmentID).toBe(ASSESSMENT_ID);
        expect(second.AssessmentID).toBe(ASSESSMENT_ID);
    });
});
