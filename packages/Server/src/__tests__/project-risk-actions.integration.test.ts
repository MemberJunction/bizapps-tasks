import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { IMetadataProvider, RunViewParams, RunViewResult, UserInfo } from '@memberjunction/core';
import type { TaskRiskItem } from '@mj-biz-apps/tasks-entities';

/**
 * World-data-model end-to-end integration test suite for Epic 7a:
 *   - LoadBizAppsTasksServer() wiring ProjectRiskAnalystRegistry -> ProjectRiskAnalystService
 *   - Request Project Risk Review -> caller permission check -> owner-context evidence gathering ->
 *     calendar free/busy privacy boundary -> ML breach integration -> AgentRunner High-tier execution ->
 *     TaskRiskAssessmentEntityServer.Save() -> atomic root Task rollup sync
 *   - Get Project Risk -> persisted assessment + synchronized root Task fields + Weekly->Daily cadence
 */

const ROOT_TASK_ID = '10000000-0000-4000-8000-000000000001';
const SUBTASK_DONE_ID = '10000000-0000-4000-8000-000000000002';
const SUBTASK_BLOCKED_ID = '10000000-0000-4000-8000-000000000003';
const SUBTASK_BLOCKER_ID = '10000000-0000-4000-8000-000000000004';
const PRIVATE_TASK_ID = '10000000-0000-4000-8000-000000000099';
const OWNER_PERSON_ID = '20000000-0000-4000-8000-000000000001';
const OWNER_USER_ID = '30000000-0000-4000-8000-000000000001';
const CALLER_PERSON_ID = '20000000-0000-4000-8000-000000000002';
const CALLER_USER_ID = '30000000-0000-4000-8000-000000000002';
const OUTSIDER_USER_ID = '30000000-0000-4000-8000-000000000003';
const AGENT_ID = '40000000-0000-4000-8000-000000000001';
const HIGH_AI_CONFIG_ID = '40000000-0000-4000-8000-000000000002';
const PEOPLE_ENTITY_ID = '50000000-0000-4000-8000-000000000001';
const USERS_ENTITY_ID = '50000000-0000-4000-8000-000000000002';
const ROLES_ENTITY_ID = '50000000-0000-4000-8000-000000000003';

interface WorldTaskRow {
    ID: string;
    Name: string;
    ParentID: string | null;
    RootParentID: string | null;
    Status: 'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';
    Priority: 'Low' | 'Medium' | 'High' | 'Critical';
    Visibility: 'Standard' | 'Private';
    StartedAt: string | null;
    DueAt: string | null;
    CompletedAt: string | null;
    PercentComplete: number;
    BlockedReason: string | null;
    CreatedByPersonID: string | null;
    HealthStatus: 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused' | null;
    ConfidenceScore: number | null;
    ForecastCompletionDate: Date | string | null;
    PredictedSLABreachProbability: number | null;
    PredictedSLARiskBand: 'Low' | 'Medium' | 'High' | 'Critical' | null;
    PredictedSLAScoredAt: string | null;
    __mj_CreatedAt: string;
}

interface WorldAssessmentRow {
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
}

interface CapturedAgentRunCall {
    contextUserId: string;
    configurationId: string | undefined;
    effortLevel: number | undefined;
    data: Record<string, string>;
}

const {
    worldState,
    capturedAgentRuns,
    capturedRunViews,
    nextAgentResponseRef,
    providerState,
} = vi.hoisted(() => {
    const worldState = {
        tasks: new Map<string, WorldTaskRow>(),
        assessments: new Map<string, WorldAssessmentRow>(),
        assessmentCounter: 0,
        agentRunCounter: 0,
    };

    const capturedAgentRuns: CapturedAgentRunCall[] = [];
    const capturedRunViews: Array<{ entityName: string; contextUserId?: string; resultType?: string }> = [];

    const nextAgentResponseRef: {
        current: {
            healthStatus: 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused';
            forecastCompletionDate: string;
            forecastConfidence: number;
            summary: string;
            risks: TaskRiskItem[];
            promptTokens: number;
            completionTokens: number;
            totalCostUSD: number;
        };
    } = {
        current: {
            healthStatus: 'AtRisk',
            forecastCompletionDate: '2026-12-12T17:00:00.000Z',
            forecastConfidence: 63,
            summary: 'Vendor dependency and assignee calendar saturation create slip risk.',
            risks: [
                {
                    kind: 'dependency_blocker',
                    severity: 'high',
                    evidenceLinks: ['/resource/record/MJ_BizApps_Tasks%3A%20Tasks/10000000-0000-4000-8000-000000000004'],
                    suggestedMitigation: 'Escalate vendor sandbox approval.',
                },
            ],
            promptTokens: 1580,
            completionTokens: 340,
            totalCostUSD: 0.0445,
        },
    };

    const providerState: {
        metadataProvider: IMetadataProvider | null;
    } = {
        metadataProvider: null,
    };

    return {
        worldState,
        capturedAgentRuns,
        capturedRunViews,
        nextAgentResponseRef,
        providerState,
    };
});

function extractUuidAfterEq(filter: string, field: string): string | null {
    const m = new RegExp(`${field}\\s*=\\s*'([^']+)'`, 'i').exec(filter);
    return m ? m[1] : null;
}

function executeWorldRunView<T>(params: RunViewParams, contextUser?: UserInfo): RunViewResult<T> {
    const entity = params.EntityName ?? '';
    capturedRunViews.push({
        entityName: entity,
        contextUserId: contextUser?.ID,
        resultType: params.ResultType,
    });

    const filter = params.ExtraFilter ?? '';

    if (entity === 'MJ_BizApps_Tasks: Tasks') {
        const idEq = extractUuidAfterEq(filter, 'ID');
        if (idEq && !filter.includes('ID <>')) {
            const found = worldState.tasks.get(idEq.toLowerCase());
            return {
                Success: true,
                Results: (found ? [{ ...found }] : []) as T[],
                RowCount: found ? 1 : 0,
                TotalRowCount: found ? 1 : 0,
                ExecutionTime: 1,
                ErrorMessage: '',
                UserViewGridState: undefined,
            };
        }
        const rootMatch = /RootParentID\s*=\s*'([^']+)'/i.exec(filter);
        if (rootMatch) {
            const rootId = rootMatch[1].toLowerCase();
            const children = [...worldState.tasks.values()].filter(
                (t) =>
                    t.ID.toLowerCase() !== rootId &&
                    (t.RootParentID?.toLowerCase() === rootId || t.ParentID?.toLowerCase() === rootId),
            );
            return {
                Success: true,
                Results: children as T[],
                RowCount: children.length,
                TotalRowCount: children.length,
                ExecutionTime: 1,
                ErrorMessage: '',
                UserViewGridState: undefined,
            };
        }
        return {
            Success: true,
            Results: [...worldState.tasks.values()] as T[],
            RowCount: worldState.tasks.size,
            TotalRowCount: worldState.tasks.size,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Assignments') {
        const rows = [
            {
                ID: '60000000-0000-4000-8000-000000000001',
                TaskID: ROOT_TASK_ID,
                AssigneeEntityID: PEOPLE_ENTITY_ID,
                AssigneeEntity: 'MJ_BizApps_Common: People',
                AssigneeRecordID: OWNER_PERSON_ID,
                Role: 'Primary',
                Status: 'InProgress',
            },
        ];
        const filtered = filter.includes(PRIVATE_TASK_ID) ? [] : rows;
        return {
            Success: true,
            Results: filtered as T[],
            RowCount: filtered.length,
            TotalRowCount: filtered.length,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Dependencies') {
        const rows = [
            {
                ID: '61000000-0000-4000-8000-000000000001',
                TaskID: SUBTASK_BLOCKED_ID,
                Task: 'Cutover Execution',
                DependsOnTaskID: SUBTASK_BLOCKER_ID,
                DependsOnTask: 'Vendor Sandbox Credentials',
                DependencyType: 'FinishToStart',
            },
        ];
        return {
            Success: true,
            Results: rows as T[],
            RowCount: rows.length,
            TotalRowCount: rows.length,
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
                    ID: '62000000-0000-4000-8000-000000000001',
                    TaskID: ROOT_TASK_ID,
                    EntityID: '62000000-0000-4000-8000-000000000099',
                    Entity: 'Contracts',
                    RecordID: 'MSA-2026-09',
                },
            ] as T[],
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
                    ID: '63000000-0000-4000-8000-000000000001',
                    TaskID: ROOT_TASK_ID,
                    CheckInAt: '2026-11-21T16:00:00.000Z',
                    HealthStatus: 'AtRisk',
                    ConfidenceScore: 65,
                    PercentComplete: 50,
                    Summary: 'Schema migration finished; waiting on vendor sandbox.',
                    Blockers: 'Vendor API key issuance pending.',
                },
            ] as T[],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Tasks: Task Risk Assessments') {
        const taskId = extractUuidAfterEq(filter, 'TaskID');
        const excludeIdMatch = /ID\s*<>\s*'([^']+)'/i.exec(filter);
        const excludeId = excludeIdMatch ? excludeIdMatch[1].toLowerCase() : null;
        const rows = [...worldState.assessments.values()]
            .filter((a) => (!taskId || a.TaskID.toLowerCase() === taskId.toLowerCase()) && a.ID.toLowerCase() !== excludeId)
            .sort((a, b) => b.AssessedAt.getTime() - a.AssessedAt.getTime())
            .slice(0, params.MaxRows ?? 50)
            .map((a) => ({ ...a }));
        return {
            Success: true,
            Results: rows as T[],
            RowCount: rows.length,
            TotalRowCount: rows.length,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ_BizApps_Common: People') {
        const allPeople = [
            { ID: OWNER_PERSON_ID, Email: 'owner@acme.test', LinkedUserID: OWNER_USER_ID },
            { ID: CALLER_PERSON_ID, Email: 'caller@acme.test', LinkedUserID: CALLER_USER_ID },
        ];
        const linkedUserId = extractUuidAfterEq(filter, 'LinkedUserID');
        const emailMatch = /Email\s*=\s*'([^']+)'/i.exec(filter)?.[1] ?? null;
        const filtered = allPeople.filter((p) => {
            if (linkedUserId) return p.LinkedUserID.toLowerCase() === linkedUserId.toLowerCase();
            if (emailMatch) return p.Email.toLowerCase() === emailMatch.toLowerCase();
            return true;
        });
        return {
            Success: true,
            Results: filtered as T[],
            RowCount: filtered.length,
            TotalRowCount: filtered.length,
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
                    Title: 'Director',
                    Email: 'owner@acme.test',
                    Type: 'User',
                    IsActive: true,
                    LinkedRecordType: 'None',
                    EmployeeID: null,
                    LinkedEntityID: null,
                    LinkedEntityRecordID: null,
                },
            ] as T[],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ: AI Agents') {
        return {
            Success: true,
            Results: [
                {
                    ID: AGENT_ID,
                    Name: 'Project Risk Analyst',
                    Status: 'Active',
                    DefaultPromptEffortLevel: 85,
                },
            ] as T[],
            RowCount: 1,
            TotalRowCount: 1,
            ExecutionTime: 1,
            ErrorMessage: '',
            UserViewGridState: undefined,
        };
    }

    if (entity === 'MJ: AI Agent Configurations') {
        return {
            Success: true,
            Results: [
                {
                    ID: '70000000-0000-4000-8000-000000000001',
                    Name: 'High',
                    AIConfigurationID: HIGH_AI_CONFIG_ID,
                    IsDefault: true,
                    Priority: 3,
                    Status: 'Active',
                },
            ] as T[],
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

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});
vi.mock('@memberjunction/ai-core-plus', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/ai-core-plus')>();
    return {
        ...actual,
        TypedActionPolicyGuard: {
            CheckEntityAccess: vi.fn(async () => ({ Allowed: true, DeniedFieldPatterns: [] })),
            MaskRecord: <T extends object>(rec: T): T => rec,
            MaskRows: <T extends object>(rows: readonly T[]): T[] => [...rows],
        },
        AgentUserPolicyEngine: {
            Instance: {
                GetEffectivePolicyAgentChain: () => [],
            },
        },
    };
});
vi.mock('@memberjunction/ai-agents', () => ({
    AgentRunner: class {
        public async RunAgent(params: {
            contextUser: UserInfo;
            configurationId?: string;
            effortLevel?: number;
            data: Record<string, string>;
        }) {
            capturedAgentRuns.push({
                contextUserId: params.contextUser.ID,
                configurationId: params.configurationId,
                effortLevel: params.effortLevel,
                data: params.data,
            });
            worldState.agentRunCounter++;
            const runId = `80000000-0000-4000-8000-00000000000${worldState.agentRunCounter}`;
            const resp = nextAgentResponseRef.current;
            return {
                success: true,
                payload: {
                    healthStatus: resp.healthStatus,
                    forecastCompletionDate: resp.forecastCompletionDate,
                    forecastConfidence: resp.forecastConfidence,
                    summary: resp.summary,
                    risks: resp.risks,
                },
                agentRun: {
                    ID: runId,
                    TotalPromptTokensUsedRollup: resp.promptTokens,
                    TotalCompletionTokensUsedRollup: resp.completionTokens,
                    TotalCostRollup: resp.totalCostUSD,
                },
            };
        }
    },
    AgentWakeTriggerService: { Instance: { TriggerWakeForWorkstream: vi.fn() } },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { GetSystemUser: vi.fn() } },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@memberjunction/notifications', () => ({}));
vi.mock('@memberjunction/scheduling-base-types', () => ({}));
vi.mock('@memberjunction/scheduling-engine', () => ({
    BaseScheduledJob: class {},
}));
vi.mock('@memberjunction/server', () => ({}));
vi.mock('@memberjunction/sqlserver-dataprovider', () => ({}));
vi.mock('@memberjunction/task-graph', () => ({
    BaseHumanTaskProvider: class {},
}));
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    class MockBaseEntity {
        public LatestResult = { CompleteMessage: '' };
        public ResultHistory: Array<{ Message: string }> = [];
        public ProviderToUse: IMetadataProvider | null = null;
        public ContextCurrentUser: UserInfo | undefined;
        protected backing: Record<string, string | number | boolean | Date | null | undefined> = {};

        public Get(field: string): string | number | boolean | Date | null | undefined {
            return this.backing[field];
        }
        public Set(field: string, value: string | number | boolean | Date | null | undefined): void {
            this.backing[field] = value;
        }
        public NewRecord(): void {
            this.backing = {};
        }
        public Validate() {
            return { Success: true, Errors: [] };
        }
        public async InnerLoad(): Promise<boolean> {
            return true;
        }
        public async Save(): Promise<boolean> {
            return true;
        }
    }

    return {
        ...actual,
        BaseEntity: MockBaseEntity,
        BaseRemotableOperation: class {},
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static get Provider(): IMetadataProvider {
                return providerState.metadataProvider!;
            }
        },
        RunView: class {
            public RunView<T>(params: RunViewParams, contextUser?: UserInfo): Promise<RunViewResult<T>> {
                return Promise.resolve(executeWorldRunView<T>(params, contextUser));
            }
            public RunViews<T>(paramsList: RunViewParams[], contextUser?: UserInfo): Promise<RunViewResult<T>[]> {
                return Promise.all(paramsList.map((p) => Promise.resolve(executeWorldRunView<T>(p, contextUser))));
            }
        },
    };
});

import { TaskRiskAssessmentEntityServer } from '@mj-biz-apps/tasks-entities-server';
import { GetProjectRiskAction, RequestProjectRiskReviewAction } from '@mj-biz-apps/tasks-actions';
import { LoadBizAppsTasksServer } from '../index.js';

class TestableGetProjectRiskAction extends GetProjectRiskAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableRequestProjectRiskReviewAction extends RequestProjectRiskReviewAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

function makeWorldMetadataProvider(): IMetadataProvider {
    const entities = [
        { ID: PEOPLE_ENTITY_ID, Name: 'MJ_BizApps_Common: People' },
        { ID: USERS_ENTITY_ID, Name: 'MJ: Users' },
        { ID: ROLES_ENTITY_ID, Name: 'MJ: Roles' },
        { ID: '50000000-0000-4000-8000-000000000004', Name: 'MJ_BizApps_Tasks: Tasks' },
    ];
    return {
        Entities: entities,
        EntityByName: (name: string) => entities.find((e) => e.Name === name),
        RunView: async <T>(params: RunViewParams, contextUser?: UserInfo) =>
            executeWorldRunView<T>(params, contextUser),
        RunViews: async <T>(paramsList: RunViewParams[], contextUser?: UserInfo) =>
            paramsList.map((p) => executeWorldRunView<T>(p, contextUser)),
        GetEntityObject: async <T>(entityName: string, contextUser?: UserInfo): Promise<T> => {
            if (entityName === 'MJ_BizApps_Tasks: Task Risk Assessments') {
                const record = new TaskRiskAssessmentEntityServer();
                record.ProviderToUse = providerState.metadataProvider as IMetadataProvider &
                    typeof record.ProviderToUse;
                record.ContextCurrentUser = contextUser;
                record.Save = async () => {
                    worldState.assessmentCounter++;
                    if (!record.ID) {
                        record.ID = `90000000-0000-4000-8000-00000000000${worldState.assessmentCounter}`;
                    }
                    const protoSave = TaskRiskAssessmentEntityServer.prototype.Save;
                    const originalBaseSave = Object.getPrototypeOf(TaskRiskAssessmentEntityServer.prototype).Save;
                    Object.getPrototypeOf(TaskRiskAssessmentEntityServer.prototype).Save = async function (
                        this: TaskRiskAssessmentEntityServer,
                    ) {
                        worldState.assessments.set(this.ID.toLowerCase(), {
                            ID: this.ID,
                            TaskID: this.TaskID,
                            AssessedAt: this.AssessedAt,
                            ForecastCompletionDate: this.ForecastCompletionDate,
                            ForecastConfidence: this.ForecastConfidence,
                            HealthStatus: this.HealthStatus,
                            MLBreachProbability: this.MLBreachProbability,
                            Risks: this.Risks,
                            AgentRunID: this.AgentRunID,
                            PromptTokens: this.PromptTokens,
                            CompletionTokens: this.CompletionTokens,
                            TotalCostUSD: this.TotalCostUSD,
                        });
                        return true;
                    };
                    try {
                        return await protoSave.call(record);
                    } finally {
                        Object.getPrototypeOf(TaskRiskAssessmentEntityServer.prototype).Save = originalBaseSave;
                    }
                };
                return record as T;
            }

            if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                const taskRecord = {
                    ID: '',
                    ParentID: null as string | null,
                    RootParentID: null as string | null,
                    HealthStatus: null as WorldTaskRow['HealthStatus'],
                    ConfidenceScore: null as number | null,
                    ForecastCompletionDate: null as Date | string | null,
                    LatestResult: { CompleteMessage: '' },
                    Load: async (id: string) => {
                        const row = worldState.tasks.get(id.toLowerCase());
                        if (!row) return false;
                        taskRecord.ID = row.ID;
                        taskRecord.ParentID = row.ParentID;
                        taskRecord.RootParentID = row.RootParentID;
                        taskRecord.HealthStatus = row.HealthStatus;
                        taskRecord.ConfidenceScore = row.ConfidenceScore;
                        taskRecord.ForecastCompletionDate = row.ForecastCompletionDate;
                        return true;
                    },
                    Save: async () => {
                        const existing = worldState.tasks.get(taskRecord.ID.toLowerCase());
                        if (!existing) return false;
                        existing.HealthStatus = taskRecord.HealthStatus;
                        existing.ConfidenceScore = taskRecord.ConfidenceScore;
                        existing.ForecastCompletionDate = taskRecord.ForecastCompletionDate;
                        return true;
                    },
                };
                return taskRecord as T;
            }

            if (entityName === 'MJ: AI Agents') {
                return {
                    ID: AGENT_ID,
                    Name: 'Project Risk Analyst',
                    Load: async () => true,
                } as T;
            }

            return {} as T;
        },
    } as Partial<IMetadataProvider> as IMetadataProvider;
}

function makeActionRunParams(
    userId: string,
    inputs: Record<string, string | number | boolean>,
    roles: string[] = ['UI'],
): RunActionParams {
    const Params: ActionParam[] = Object.entries(inputs).map(([Name, Value]) => ({
        Name,
        Value,
        Type: 'Input',
    }));
    return {
        ContextUser: {
            ID: userId,
            Name: userId === OUTSIDER_USER_ID ? 'Outsider User' : 'Caller User',
            Email: userId === OUTSIDER_USER_ID ? 'outsider@acme.test' : 'caller@acme.test',
            UserRoles: roles.map((Role) => ({ Role, RoleID: '50000000-0000-4000-8000-000000000090' })),
        } as Partial<UserInfo> as UserInfo,
        Params,
    } as Partial<RunActionParams> as RunActionParams;
}

function readOut<T>(res: ActionResultSimple, name: string): T {
    const param = res.Params?.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    return param?.Value as T;
}

describe('Epic 7a World-Data-Model End-to-End Integration', () => {
    let getRiskAction: TestableGetProjectRiskAction;
    let requestReviewAction: TestableRequestProjectRiskReviewAction;

    beforeEach(() => {
        worldState.tasks.clear();
        worldState.assessments.clear();
        worldState.assessmentCounter = 0;
        worldState.agentRunCounter = 0;
        capturedAgentRuns.length = 0;
        capturedRunViews.length = 0;

        providerState.metadataProvider = makeWorldMetadataProvider();
        LoadBizAppsTasksServer();

        const nowMs = Date.now();
        // Start project 30 days ago, due 70 days from now (~30% elapsed -> Weekly cadence)
        const startedAt = new Date(nowMs - 30 * 86_400_000).toISOString();
        const dueAt = new Date(nowMs + 70 * 86_400_000).toISOString();

        worldState.tasks.set(ROOT_TASK_ID.toLowerCase(), {
            ID: ROOT_TASK_ID,
            Name: 'Global Payroll Modernization',
            ParentID: null,
            RootParentID: null,
            Status: 'InProgress',
            Priority: 'High',
            Visibility: 'Standard',
            StartedAt: startedAt,
            DueAt: dueAt,
            CompletedAt: null,
            PercentComplete: 40,
            BlockedReason: null,
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: null,
            ConfidenceScore: null,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: 0.35,
            PredictedSLARiskBand: 'Medium',
            PredictedSLAScoredAt: new Date(nowMs - 86_400_000).toISOString(),
            __mj_CreatedAt: startedAt,
        });
        worldState.tasks.set(SUBTASK_DONE_ID.toLowerCase(), {
            ID: SUBTASK_DONE_ID,
            Name: 'Payroll Schema Freeze',
            ParentID: ROOT_TASK_ID,
            RootParentID: ROOT_TASK_ID,
            Status: 'Completed',
            Priority: 'High',
            Visibility: 'Standard',
            StartedAt: startedAt,
            DueAt: new Date(nowMs - 5 * 86_400_000).toISOString(),
            CompletedAt: new Date(nowMs - 6 * 86_400_000).toISOString(),
            PercentComplete: 100,
            BlockedReason: null,
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: null,
            ConfidenceScore: null,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: null,
            PredictedSLARiskBand: null,
            PredictedSLAScoredAt: null,
            __mj_CreatedAt: startedAt,
        });
        worldState.tasks.set(SUBTASK_BLOCKED_ID.toLowerCase(), {
            ID: SUBTASK_BLOCKED_ID,
            Name: 'Cutover Execution',
            ParentID: ROOT_TASK_ID,
            RootParentID: ROOT_TASK_ID,
            Status: 'Blocked',
            Priority: 'Critical',
            Visibility: 'Standard',
            StartedAt: startedAt,
            DueAt: new Date(nowMs + 15 * 86_400_000).toISOString(),
            CompletedAt: null,
            PercentComplete: 25,
            BlockedReason: 'Waiting on vendor sandbox credentials',
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: null,
            ConfidenceScore: null,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: null,
            PredictedSLARiskBand: null,
            PredictedSLAScoredAt: null,
            __mj_CreatedAt: startedAt,
        });
        worldState.tasks.set(SUBTASK_BLOCKER_ID.toLowerCase(), {
            ID: SUBTASK_BLOCKER_ID,
            Name: 'Vendor Sandbox Credentials',
            ParentID: ROOT_TASK_ID,
            RootParentID: ROOT_TASK_ID,
            Status: 'Blocked',
            Priority: 'High',
            Visibility: 'Standard',
            StartedAt: startedAt,
            DueAt: new Date(nowMs - 2 * 86_400_000).toISOString(),
            CompletedAt: null,
            PercentComplete: 15,
            BlockedReason: 'Pending vendor security review',
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: null,
            ConfidenceScore: null,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: null,
            PredictedSLARiskBand: null,
            PredictedSLAScoredAt: null,
            __mj_CreatedAt: startedAt,
        });
        worldState.tasks.set(PRIVATE_TASK_ID.toLowerCase(), {
            ID: PRIVATE_TASK_ID,
            Name: 'Confidential M&A Integration',
            ParentID: null,
            RootParentID: null,
            Status: 'InProgress',
            Priority: 'Critical',
            Visibility: 'Private',
            StartedAt: startedAt,
            DueAt: dueAt,
            CompletedAt: null,
            PercentComplete: 10,
            BlockedReason: null,
            CreatedByPersonID: OWNER_PERSON_ID,
            HealthStatus: null,
            ConfidenceScore: null,
            ForecastCompletionDate: null,
            PredictedSLABreachProbability: null,
            PredictedSLARiskBand: null,
            PredictedSLAScoredAt: null,
            __mj_CreatedAt: startedAt,
        });

        getRiskAction = new TestableGetProjectRiskAction();
        requestReviewAction = new TestableRequestProjectRiskReviewAction();
    });

    it('executes full lifecycle: NO_ASSESSMENT -> Private caller refusal -> Request review (owner, ML breach, free/busy privacy, root sync) -> Get risk -> Final 20% Daily escalation', async () => {
        // 1. Empty state before any assessment
        const initialGet = await getRiskAction.Run(
            makeActionRunParams(CALLER_USER_ID, { TaskID: ROOT_TASK_ID }),
        );
        expect(initialGet.Success).toBe(true);
        expect(initialGet.ResultCode).toBe('NO_ASSESSMENT');
        expect(readOut<boolean>(initialGet, 'HasAssessment')).toBe(false);
        expect(readOut<string>(initialGet, 'Cadence')).toBe('Weekly');

        // 2. Unauthorized caller blocked from private project prior to owner context switch
        const privateRefusal = await requestReviewAction.Run(
            makeActionRunParams(OUTSIDER_USER_ID, { TaskID: PRIVATE_TASK_ID }),
        );
        expect(privateRefusal.Success).toBe(false);
        expect(privateRefusal.ResultCode).toBe('PERMISSION_DENIED');
        expect(capturedAgentRuns).toHaveLength(0);

        // 3. Request Project Risk Review via subtask ID, with ML breach override & calendar slots containing sensitive subject/body
        const futureBusyStart = new Date(Date.now() + 2 * 86_400_000).toISOString();
        const futureBusyEnd = new Date(Date.now() + 2 * 86_400_000 + 180 * 60_000).toISOString();

        const review1 = await requestReviewAction.Run(
            makeActionRunParams(CALLER_USER_ID, {
                TaskID: SUBTASK_BLOCKED_ID,
                MLBreachProbability: 0.725,
                MLBreachRiskBand: 'High',
                FreeBusyJSON: JSON.stringify([
                    {
                        PersonID: OWNER_PERSON_ID,
                        UserID: OWNER_USER_ID,
                        Slots: [
                            {
                                StartTime: futureBusyStart,
                                EndTime: futureBusyEnd,
                                Status: 'Busy',
                                Subject: 'TOP SECRET LAYOFF DISCUSSION',
                                Body: 'Confidential HR restructuring details',
                                Location: 'Boardroom 9',
                                Attendees: ['ceo@acme.test'],
                            },
                        ],
                    },
                ]),
            }),
        );
        expect(review1.Success).toBe(true);
        expect(review1.ResultCode).toBe('SUCCESS');

        // Verify High-tier AgentRunner executed as OwnerUser with zero sensitive calendar leakage
        expect(capturedAgentRuns).toHaveLength(1);
        expect(capturedAgentRuns[0].contextUserId).toBe(OWNER_USER_ID);
        expect(capturedAgentRuns[0].configurationId).toBe(HIGH_AI_CONFIG_ID);
        expect(capturedAgentRuns[0].effortLevel).toBe(85);
        const serializedAgentInput = JSON.stringify(capturedAgentRuns[0].data);
        expect(serializedAgentInput).not.toContain('TOP SECRET LAYOFF DISCUSSION');
        expect(serializedAgentInput).not.toContain('Confidential HR restructuring details');
        expect(serializedAgentInput).not.toContain('Boardroom 9');
        expect(serializedAgentInput).not.toContain('ceo@acme.test');
        expect(capturedAgentRuns[0].data.freeBusyJson).toContain('"BusyMinutes":180');
        expect(capturedAgentRuns[0].data.mlBreachJson).toContain('0.725');

        // Verify persisted TaskRiskAssessment row + automatic root task synchronization
        expect(worldState.assessments.size).toBe(1);
        const persisted1 = [...worldState.assessments.values()][0];
        expect(persisted1.TaskID).toBe(ROOT_TASK_ID);
        expect(persisted1.HealthStatus).toBe('AtRisk');
        expect(persisted1.ForecastConfidence).toBe(63);
        expect(persisted1.MLBreachProbability).toBe(0.725);
        expect(persisted1.AgentRunID).toBe('80000000-0000-4000-8000-000000000001');
        expect(persisted1.PromptTokens).toBe(1580);
        expect(persisted1.CompletionTokens).toBe(340);
        expect(persisted1.TotalCostUSD).toBe(0.0445);

        const syncedRoot1 = worldState.tasks.get(ROOT_TASK_ID.toLowerCase())!;
        expect(syncedRoot1.HealthStatus).toBe('AtRisk');
        expect(syncedRoot1.ConfidenceScore).toBe(63);
        expect(new Date(syncedRoot1.ForecastCompletionDate!).toISOString()).toBe('2026-12-12T17:00:00.000Z');

        // 4. Get Project Risk retrieves persisted typed assessment + Weekly cadence + root task rollup
        const get1 = await getRiskAction.Run(
            makeActionRunParams(CALLER_USER_ID, { TaskID: ROOT_TASK_ID }),
        );
        expect(get1.Success).toBe(true);
        expect(readOut<boolean>(get1, 'HasAssessment')).toBe(true);
        expect(readOut<string>(get1, 'AssessmentID')).toBe(persisted1.ID);
        expect(readOut<string>(get1, 'HealthStatus')).toBe('AtRisk');
        expect(readOut<number>(get1, 'ForecastConfidence')).toBe(63);
        expect(readOut<number>(get1, 'MLBreachProbability')).toBe(0.725);
        expect(readOut<string>(get1, 'Cadence')).toBe('Weekly');

        // 5. Force=false within Weekly cooldown skips duplicate run
        const skippedCooldown = await requestReviewAction.Run(
            makeActionRunParams(CALLER_USER_ID, { TaskID: ROOT_TASK_ID, Force: false }),
        );
        expect(skippedCooldown.Success).toBe(true);
        expect(skippedCooldown.ResultCode).toBe('SKIPPED_COOLDOWN');
        expect(capturedAgentRuns).toHaveLength(1);

        // 6. Move project into final 20% of timeline (85% elapsed) -> cadence escalates from Weekly to Daily
        const rootTask = worldState.tasks.get(ROOT_TASK_ID.toLowerCase())!;
        rootTask.StartedAt = new Date(Date.now() - 85 * 86_400_000).toISOString();
        rootTask.DueAt = new Date(Date.now() + 15 * 86_400_000).toISOString();

        nextAgentResponseRef.current = {
            healthStatus: 'OffTrack',
            forecastCompletionDate: '2026-12-28T17:00:00.000Z',
            forecastConfidence: 42,
            summary: 'Project entered final 20% window with unresolved vendor blocker.',
            risks: [
                {
                    kind: 'sla_breach_imminent',
                    severity: 'critical',
                    evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${ROOT_TASK_ID}`],
                    suggestedMitigation: 'Activate contingency cutover plan.',
                },
            ],
            promptTokens: 1710,
            completionTokens: 390,
            totalCostUSD: 0.052,
        };

        const review2 = await requestReviewAction.Run(
            makeActionRunParams(CALLER_USER_ID, { TaskID: ROOT_TASK_ID, MLBreachProbability: 0.89 }),
        );
        expect(review2.Success).toBe(true);
        expect(readOut<string>(review2, 'Cadence')).toBe('Daily');
        expect(readOut<string>(review2, 'HealthStatus')).toBe('OffTrack');
        expect(readOut<number>(review2, 'ForecastConfidence')).toBe(42);
        expect(worldState.assessments.size).toBe(2);

        const syncedRoot2 = worldState.tasks.get(ROOT_TASK_ID.toLowerCase())!;
        expect(syncedRoot2.HealthStatus).toBe('OffTrack');
        expect(syncedRoot2.ConfidenceScore).toBe(42);
        expect(new Date(syncedRoot2.ForecastCompletionDate!).toISOString()).toBe('2026-12-28T17:00:00.000Z');

        const get2 = await getRiskAction.Run(
            makeActionRunParams(CALLER_USER_ID, {
                TaskID: ROOT_TASK_ID,
                IncludeHistory: true,
                HistoryLimit: 10,
            }),
        );
        expect(get2.Success).toBe(true);
        expect(readOut<string>(get2, 'Cadence')).toBe('Daily');
        expect(readOut<string>(get2, 'HealthStatus')).toBe('OffTrack');
        const history = JSON.parse(readOut<string>(get2, 'History')) as Array<{
            HealthStatus: string;
            Risks: TaskRiskItem[];
        }>;
        expect(history).toHaveLength(2);
        expect(history[0].HealthStatus).toBe('OffTrack');
        expect(history[0].Risks[0].kind).toBe('sla_breach_imminent');
        expect(history[1].HealthStatus).toBe('AtRisk');
    });
});
