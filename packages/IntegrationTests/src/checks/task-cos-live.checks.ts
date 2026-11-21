/**
 * TSK-10 (`task-cos-live`): Live-LLM heuristic integration checks exercising the real
 * `Chief of Staff` agent via `AgentRunner.RunAgent` against live DB + live LLM.
 *
 * Asserts deterministic framework invariants (`verifyAgentRun`, terminal `Status === 'Completed'`,
 * ZERO raw SQL/CRUD action invocations, typed Tasks/Meetings action selection, real DB side
 * effects, and live `ReadOnly` policy enforcement) with bounded 2-attempt retry on model
 * non-compliance (never retrying framework invariant failures) and full `finally` cleanup.
 */
import '@mj-biz-apps/tasks-actions';
import {
    CompositeKey,
    UserInfo,
    type IMetadataProvider,
} from '@memberjunction/core';
import type {
    MJAIAgentUserPolicyEntity,
    MJUserEntity,
    MJUserRoleEntity,
} from '@memberjunction/core-entities';
import { ActionEngineServer } from '@memberjunction/actions';
import { AgentRunner } from '@memberjunction/ai-agents';
import {
    AgentUserPolicyEngine,
    type ExecuteAgentParams,
    type MJAIAgentEntityExtended,
} from '@memberjunction/ai-core-plus';
import { AIEngine } from '@memberjunction/aiengine';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import { SkipCheck, verifyAgentRun } from '@memberjunction/testing-integration';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type IntegrationCheckContext,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import {
    ACTION_ENTITY,
    ACTION_EXECUTION_LOG_ENTITY,
    AI_AGENT_RUN_ENTITY,
    AI_AGENT_RUN_STEP_ENTITY,
    AI_AGENT_USER_POLICY_ENTITY,
    MEETING_NOTE_ENTITY,
    PERSON_ENTITY,
    ROLE_ENTITY,
    TASK_ACTIVITY_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_CHECK_IN_ENTITY,
    TASK_COMMENT_ENTITY,
    TASK_DEPENDENCY_ENTITY,
    TASK_ENTITY,
    TASK_LINK_ENTITY,
    TASK_TAG_LINK_ENTITY,
    USER_ENTITY,
    USER_ROLE_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave } from '../wire.js';
import { ACME_ORG_NAME, GetOrLoadWorld, SEEDED_MEETING_NAME } from '../world/load-world.js';

const COS_AGENT_NAME = 'Chief of Staff';
const MAX_COMPLIANCE_ATTEMPTS = 2;
const SETTLE_MS = 1500;

const FORBIDDEN_RAW_ACTIONS: ReadonlySet<string> = new Set([
    'execute ad-hoc sql',
    'get records',
    'create record',
    'update record',
    'delete record',
]);

class ModelNonComplianceError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'ModelNonComplianceError';
    }
}

interface InvokedActionEvidence {
    ActionName: string;
    ResultCode: string | null;
    LogID: string | null;
}

interface LiveRunSummary {
    RunID: string;
    RunTreeIDs: string[];
    Status: string;
    InvokedActions: InvokedActionEvidence[];
}

function sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

async function resolveChiefOfStaffAgent(ctx: IntegrationCheckContext): Promise<MJAIAgentEntityExtended> {
    // Prime ActionEngineServer & AIEngine with the server's privileged user (matching MJAPI boot)
    // so MJ: Action Execution Logs writes succeed while actions execute under the non-Owner UI caller.
    await ActionEngineServer.Instance.Config(false, ctx.User, ctx.Provider as IMetadataProvider);
    await AIEngine.Instance.Config(false, ctx.User, ctx.Provider as IMetadataProvider);
    const agent = AIEngine.Instance.Agents.find(
        (a) => a.Name === COS_AGENT_NAME && a.Status === 'Active',
    );
    if (!agent) {
        SkipCheck(`Active agent '${COS_AGENT_NAME}' not found in AIEngine metadata`);
    }
    return agent!;
}

async function ensureLiveUIUser(
    ctx: IntegrationCheckContext,
    person: { ID: string; Email: string; FirstName: string; LastName: string },
): Promise<UserInfo> {
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.EntityByName(PERSON_ENTITY);
    Assert(!!peopleEntity, `${PERSON_ENTITY} entity metadata missing`);
    const uiRoleId = await FindId(ctx, ROLE_ENTITY, `Name = 'UI'`);
    Assert(!!uiRoleId, 'UI role missing');

    const existingUserId = await FindId(ctx, USER_ENTITY, `LOWER(Email) = LOWER('${Quote(person.Email)}')`);
    const userEntity = await ctx.Provider.GetEntityObject<MJUserEntity>(USER_ENTITY, ctx.User);
    if (existingUserId) {
        await userEntity.Load(existingUserId);
    } else {
        userEntity.NewRecord();
        userEntity.Type = 'User';
    }
    userEntity.Name = `${person.FirstName} ${person.LastName}`;
    userEntity.FirstName = person.FirstName;
    userEntity.LastName = person.LastName;
    userEntity.Email = person.Email;
    userEntity.IsActive = true;
    userEntity.LinkedEntityID = peopleEntity!.ID;
    userEntity.LinkedEntityRecordID = person.ID;
    await RequireSave(userEntity, `live UI user ${person.Email}`);

    const existingRoleLink = await FindId(
        ctx,
        USER_ROLE_ENTITY,
        `UserID = '${Quote(userEntity.ID)}' AND RoleID = '${Quote(uiRoleId!)}'`,
    );
    if (!existingRoleLink) {
        const userRole = await ctx.Provider.GetEntityObject<MJUserRoleEntity>(USER_ROLE_ENTITY, ctx.User);
        userRole.NewRecord();
        userRole.UserID = userEntity.ID;
        userRole.RoleID = uiRoleId!;
        await RequireSave(userRole, `UI role grant for ${person.Email}`);
    }

    return new UserInfo(provider, {
        ID: userEntity.ID,
        Name: userEntity.Name,
        FirstName: userEntity.FirstName,
        LastName: userEntity.LastName,
        Email: userEntity.Email,
        Type: 'User',
        IsActive: true,
        LinkedEntityID: peopleEntity!.ID,
        LinkedEntityRecordID: person.ID,
        UserRoles: [{ UserID: userEntity.ID, RoleID: uiRoleId!, Role: 'UI' }],
    });
}

async function collectRunTreeIds(ctx: IntegrationCheckContext, rootRunId: string): Promise<string[]> {
    const all: string[] = [rootRunId];
    let frontier: string[] = [rootRunId];
    let guard = 0;
    while (frontier.length > 0 && guard++ < 8) {
        const inList = frontier.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        const children = await FindRows<{ ID: string }>(
            ctx,
            AI_AGENT_RUN_ENTITY,
            `ParentRunID IN (${inList})`,
            ['ID'],
        );
        const next: string[] = [];
        for (const child of children) {
            if (!all.some((id) => UUIDsEqual(id, child.ID))) {
                all.push(child.ID);
                next.push(child.ID);
            }
        }
        frontier = next;
    }
    return all;
}

async function inspectRunTreeActions(
    ctx: IntegrationCheckContext,
    runTreeIds: readonly string[],
): Promise<InvokedActionEvidence[]> {
    if (runTreeIds.length === 0) return [];
    const inRuns = runTreeIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const steps = await FindRows<{
        ID: string;
        StepType: string | null;
        TargetID: string | null;
        TargetLogID: string | null;
    }>(
        ctx,
        AI_AGENT_RUN_STEP_ENTITY,
        `AgentRunID IN (${inRuns})`,
        ['ID', 'StepType', 'TargetID', 'TargetLogID'],
    );

    const actionSteps = steps.filter((s) => {
        const st = (s.StepType ?? '').toLowerCase();
        return st === 'actions' || st === 'action' || st === 'tool';
    });

    const targetActionIds = Array.from(
        new Set(actionSteps.map((s) => s.TargetID).filter((id): id is string => Boolean(id && IsValidUUID(id)))),
    );
    const targetLogIds = Array.from(
        new Set(actionSteps.map((s) => s.TargetLogID).filter((id): id is string => Boolean(id && IsValidUUID(id)))),
    );

    const actionNamesById = new Map<string, string>();
    if (targetActionIds.length > 0) {
        const inActions = targetActionIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        const actionRows = await FindRows<{ ID: string; Name: string }>(
            ctx,
            ACTION_ENTITY,
            `ID IN (${inActions})`,
            ['ID', 'Name'],
        );
        for (const row of actionRows) {
            actionNamesById.set(row.ID.toLowerCase(), row.Name);
        }
    }

    const logRowsById = new Map<string, { Action: string | null; ResultCode: string | null }>();
    if (targetLogIds.length > 0) {
        const inLogs = targetLogIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        const logRows = await FindRows<{ ID: string; Action: string | null; ResultCode: string | null }>(
            ctx,
            ACTION_EXECUTION_LOG_ENTITY,
            `ID IN (${inLogs})`,
            ['ID', 'Action', 'ResultCode'],
        );
        for (const row of logRows) {
            logRowsById.set(row.ID.toLowerCase(), {
                Action: row.Action ?? null,
                ResultCode: row.ResultCode ?? null,
            });
        }
    }

    const evidence: InvokedActionEvidence[] = [];
    for (const step of actionSteps) {
        const logInfo = step.TargetLogID ? logRowsById.get(step.TargetLogID.toLowerCase()) : undefined;
        const nameFromAction = step.TargetID ? actionNamesById.get(step.TargetID.toLowerCase()) : undefined;
        const resolvedName = logInfo?.Action ?? nameFromAction ?? '';
        if (resolvedName) {
            evidence.push({
                ActionName: resolvedName,
                ResultCode: logInfo?.ResultCode ?? null,
                LogID: step.TargetLogID ?? null,
            });
        }
    }
    return evidence;
}

function assertZeroForbiddenRawActions(evidence: readonly InvokedActionEvidence[], label: string): void {
    const violations = evidence.filter((e) => FORBIDDEN_RAW_ACTIONS.has(e.ActionName.trim().toLowerCase()));
    AssertEqual(
        violations.length,
        0,
        `${label}: Chief of Staff MUST NEVER call raw SQL/CRUD actions; saw [${violations.map((v) => v.ActionName).join(', ')}]`,
    );
}

async function runLiveChiefOfStaffTurn(
    ctx: IntegrationCheckContext,
    agent: MJAIAgentEntityExtended,
    callerUser: UserInfo,
    prompt: string,
    trackedRunIds: string[],
    label: string,
): Promise<LiveRunSummary> {
    const provider = ctx.Provider as IMetadataProvider;
    const runner = new AgentRunner(provider);
    const params: ExecuteAgentParams = {
        agent,
        conversationMessages: [{ role: 'user', content: prompt }],
        contextUser: callerUser,
        userId: callerUser.ID,
    };

    const result = await runner.RunAgent(params);
    await sleep(SETTLE_MS);

    const runId = result.agentRun?.ID;
    Assert(!!runId && IsValidUUID(runId), `${label}: AgentRunner.RunAgent persisted a valid AIAgentRun ID`);
    trackedRunIds.push(runId!);

    // Framework invariant: deep verify run + steps + target logs (never retried on failure)
    await verifyAgentRun(runId!, ctx.User, true);

    const [runRow] = await FindRows<{ ID: string; Status: string | null; ErrorMessage: string | null }>(
        ctx,
        AI_AGENT_RUN_ENTITY,
        `ID = '${EscapeSQLString(runId!)}'`,
        ['ID', 'Status', 'ErrorMessage'],
    );
    AssertEqual(
        runRow?.Status,
        'Completed',
        `${label}: AIAgentRun.Status must be Completed (got '${runRow?.Status}', err='${runRow?.ErrorMessage ?? ''}')`,
    );

    const runTreeIds = await collectRunTreeIds(ctx, runId!);
    const invokedActions = await inspectRunTreeActions(ctx, runTreeIds);

    // Hard security invariant: ZERO raw SQL/CRUD calls (never retried on failure)
    assertZeroForbiddenRawActions(invokedActions, label);

    return {
        RunID: runId!,
        RunTreeIDs: runTreeIds,
        Status: runRow?.Status ?? '',
        InvokedActions: invokedActions,
    };
}

async function runWithModelComplianceRetry(
    label: string,
    attemptFn: (attempt: number) => Promise<void>,
): Promise<void> {
    let lastComplianceError: ModelNonComplianceError | null = null;
    for (let attempt = 1; attempt <= MAX_COMPLIANCE_ATTEMPTS; attempt++) {
        try {
            await attemptFn(attempt);
            return;
        } catch (err) {
            if (err instanceof ModelNonComplianceError && attempt < MAX_COMPLIANCE_ATTEMPTS) {
                lastComplianceError = err;
                console.warn(`  [retry ${attempt}/${MAX_COMPLIANCE_ATTEMPTS}] ${label}: ${err.message}`);
                continue;
            }
            throw err;
        }
    }
    if (lastComplianceError) {
        throw lastComplianceError;
    }
}

async function deleteEntityById(
    ctx: IntegrationCheckContext,
    entityName: string,
    id: string,
): Promise<void> {
    if (!IsValidUUID(id)) return;
    try {
        const rec = await ctx.Provider.GetEntityObject(entityName, ctx.User);
        if (await rec.InnerLoad(CompositeKey.FromID(id))) {
            await rec.Delete();
        }
    } catch {
        // Best-effort teardown
    }
}

async function deleteTaskCascade(ctx: IntegrationCheckContext, taskID: string): Promise<void> {
    if (!IsValidUUID(taskID)) return;
    const escaped = EscapeSQLString(taskID);
    const children: Array<{ entity: string; filter: string }> = [
        { entity: TASK_DEPENDENCY_ENTITY, filter: `TaskID = '${escaped}' OR DependsOnTaskID = '${escaped}'` },
        { entity: TASK_ASSIGNMENT_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_COMMENT_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_CHECK_IN_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_LINK_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_TAG_LINK_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_ACTIVITY_ENTITY, filter: `TaskID = '${escaped}'` },
    ];
    for (const c of children) {
        try {
            const rows = await FindRows<{ ID: string }>(ctx, c.entity, c.filter, ['ID']);
            for (const row of rows) {
                await deleteEntityById(ctx, c.entity, row.ID);
            }
        } catch {
            // Continue cascading
        }
    }
    await deleteEntityById(ctx, TASK_ENTITY, taskID);
}

async function purgeAgentRunTrees(ctx: IntegrationCheckContext, rootRunIds: readonly string[]): Promise<void> {
    for (const rootId of rootRunIds) {
        try {
            const treeIds = await collectRunTreeIds(ctx, rootId);
            const inRuns = treeIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
            const steps = await FindRows<{ ID: string; StepType: string | null; TargetLogID: string | null }>(
                ctx,
                AI_AGENT_RUN_STEP_ENTITY,
                `AgentRunID IN (${inRuns})`,
                ['ID', 'StepType', 'TargetLogID'],
            );

            const promptRunIds: string[] = [];
            const actionLogIds: string[] = [];
            for (const s of steps) {
                if (s.TargetLogID && IsValidUUID(s.TargetLogID)) {
                    const st = (s.StepType ?? '').toLowerCase();
                    if (st === 'prompt') promptRunIds.push(s.TargetLogID);
                    else if (st === 'actions' || st === 'action' || st === 'tool') actionLogIds.push(s.TargetLogID);
                }
                await deleteEntityById(ctx, AI_AGENT_RUN_STEP_ENTITY, s.ID);
            }
            for (const lid of actionLogIds) {
                await deleteEntityById(ctx, ACTION_EXECUTION_LOG_ENTITY, lid);
            }
            for (const pid of promptRunIds) {
                await deleteEntityById(ctx, 'MJ: AI Prompt Runs', pid);
            }
            // Delete child runs before parent runs
            for (const runId of [...treeIds].reverse()) {
                await deleteEntityById(ctx, AI_AGENT_RUN_ENTITY, runId);
            }
        } catch {
            // Best-effort teardown
        }
    }
}

const checks: NamedCheck[] = [
    // =========================================================================
    // TCOSL1: Briefing & Org-Scoped Tasks Discovery
    // =========================================================================
    {
        Id: 'task-cos-live.TCOSL1',
        Name: 'TCOSL1 — Live CoS briefing & org-scoped task discovery for Acme Enterprise Corp (0 raw SQL/CRUD)',
        RequiresLiveModel: true,
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const agent = await resolveChiefOfStaffAgent(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            Assert(!!sarah, 'TSK-00 Sarah Connor must exist');
            const sarahUser = await ensureLiveUIUser(ctx, sarah);
            const trackedRunIds: string[] = [];

            try {
                await runWithModelComplianceRetry('TCOSL1', async () => {
                    const run = await runLiveChiefOfStaffTurn(
                        ctx,
                        agent,
                        sarahUser,
                        `Give me my tasks briefing for ${ACME_ORG_NAME} and list my open tasks.`,
                        trackedRunIds,
                        'TCOSL1',
                    );
                    const allowedNames = new Set([
                        'assemble my briefing',
                        'get my tasks briefing',
                        'find tasks',
                    ]);
                    const hit = run.InvokedActions.some((a) =>
                        allowedNames.has(a.ActionName.trim().toLowerCase()),
                    );
                    if (!hit) {
                        throw new ModelNonComplianceError(
                            `Expected typed Tasks/Briefing action (Assemble My Briefing / Get My Tasks Briefing / Find Tasks), saw [${run.InvokedActions.map((a) => a.ActionName).join(', ')}]`,
                        );
                    }
                });
            } finally {
                await purgeAgentRunTrees(ctx, trackedRunIds);
            }
        },
    },

    // =========================================================================
    // TCOSL2: Deduplicated Task Creation
    // =========================================================================
    {
        Id: 'task-cos-live.TCOSL2',
        Name: 'TCOSL2 — Live CoS checks duplicates and creates Q4 Acme Board Audit Pack under Acme Enterprise Corp (0 raw SQL/CRUD)',
        RequiresLiveModel: true,
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const agent = await resolveChiefOfStaffAgent(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            Assert(!!sarah, 'TSK-00 Sarah Connor must exist');
            const sarahUser = await ensureLiveUIUser(ctx, sarah);
            const trackedRunIds: string[] = [];
            const titleNeedle = 'Q4 Acme Board Audit Pack';

            try {
                await runWithModelComplianceRetry('TCOSL2', async () => {
                    const run = await runLiveChiefOfStaffTurn(
                        ctx,
                        agent,
                        sarahUser,
                        `Check if I already have a task for '${titleNeedle}', and if not, create it under ${ACME_ORG_NAME}.`,
                        trackedRunIds,
                        'TCOSL2',
                    );
                    const typedCreationActions = new Set(['find similar tasks', 'create task']);
                    const usedTyped = run.InvokedActions.some((a) =>
                        typedCreationActions.has(a.ActionName.trim().toLowerCase()),
                    );
                    if (!usedTyped) {
                        throw new ModelNonComplianceError(
                            `Expected Find Similar Tasks and/or Create Task, saw [${run.InvokedActions.map((a) => a.ActionName).join(', ')}]`,
                        );
                    }

                    const createdRows = await FindRows<{ ID: string; Name: string; OrganizationID: string | null }>(
                        ctx,
                        TASK_ENTITY,
                        `Name LIKE '%${EscapeSQLString(titleNeedle)}%'`,
                        ['ID', 'Name', 'OrganizationID'],
                    );
                    if (createdRows.length === 0) {
                        throw new ModelNonComplianceError(
                            `Model completed without persisting a Task matching '${titleNeedle}'.`,
                        );
                    }
                });
            } finally {
                const cleanupTasks = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_ENTITY,
                    `Name LIKE '%${EscapeSQLString(titleNeedle)}%'`,
                    ['ID'],
                );
                for (const row of cleanupTasks) {
                    await deleteTaskCascade(ctx, row.ID);
                }
                await purgeAgentRunTrees(ctx, trackedRunIds);
            }
        },
    },

    // =========================================================================
    // TCOSL3: Meeting Transcript Processing
    // =========================================================================
    {
        Id: 'task-cos-live.TCOSL3',
        Name: 'TCOSL3 — Live CoS looks up recent completed meetings and reviews/processes notes for Q4 Executive Alignment Sync (0 raw SQL/CRUD)',
        RequiresLiveModel: true,
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const agent = await resolveChiefOfStaffAgent(ctx);
            const alex = world.People['alex.chen@task-world.test'];
            Assert(!!alex, 'TSK-00 Alex Chen must exist');
            const alexUser = await ensureLiveUIUser(ctx, alex);
            const trackedRunIds: string[] = [];

            // Snapshot existing notes on the seeded meeting so finally cleans only ephemeral notes
            const baselineNotes = await FindRows<{ ID: string }>(
                ctx,
                MEETING_NOTE_ENTITY,
                `MeetingID = '${EscapeSQLString(world.TranscriptMeetingID)}'`,
                ['ID'],
            );
            const baselineNoteIds = new Set(baselineNotes.map((n) => n.ID.toLowerCase()));

            try {
                await runWithModelComplianceRetry('TCOSL3', async () => {
                    const run = await runLiveChiefOfStaffTurn(
                        ctx,
                        agent,
                        alexUser,
                        `Look up my recent completed meetings and review or process notes for ${SEEDED_MEETING_NAME}.`,
                        trackedRunIds,
                        'TCOSL3',
                    );
                    const meetingActions = new Set([
                        'get my upcoming meetings',
                        'get meeting notes',
                        'prepare meeting brief',
                        'process meeting transcript',
                    ]);
                    const hit = run.InvokedActions.some((a) =>
                        meetingActions.has(a.ActionName.trim().toLowerCase()),
                    );
                    if (!hit) {
                        throw new ModelNonComplianceError(
                            `Expected typed Meetings action, saw [${run.InvokedActions.map((a) => a.ActionName).join(', ')}]`,
                        );
                    }
                });
            } finally {
                const currentNotes = await FindRows<{ ID: string }>(
                    ctx,
                    MEETING_NOTE_ENTITY,
                    `MeetingID = '${EscapeSQLString(world.TranscriptMeetingID)}'`,
                    ['ID'],
                );
                for (const note of currentNotes) {
                    if (!baselineNoteIds.has(note.ID.toLowerCase())) {
                        await deleteEntityById(ctx, MEETING_NOTE_ENTITY, note.ID);
                    }
                }
                await purgeAgentRunTrees(ctx, trackedRunIds);
            }
        },
    },

    // =========================================================================
    // TCOSL4: Live Policy Enforcement Under ReadOnly Ceiling
    // =========================================================================
    {
        Id: 'task-cos-live.TCOSL4',
        Name: 'TCOSL4 — Live CoS under EntityAccessRules Tasks=ReadOnly creates 0 unauthorized tasks (refuses cleanly or logs POLICY_DENIED)',
        RequiresLiveModel: true,
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const agent = await resolveChiefOfStaffAgent(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            Assert(!!sarah, 'TSK-00 Sarah Connor must exist');
            const sarahUser = await ensureLiveUIUser(ctx, sarah);
            const trackedRunIds: string[] = [];
            const forbiddenTitle = 'Unauthorized Live CoS Write Test';

            const engine = AgentUserPolicyEngine.Instance;
            let policyCreatedByTest = false;
            let policyId: string | null = null;
            let priorStatus: MJAIAgentUserPolicyEntity['Status'] | null = null;
            let priorDefaultMode: MJAIAgentUserPolicyEntity['DefaultDataAccessMode'] | null = null;
            let priorRules: string | null = null;

            try {
                const existingPolicyId = await FindId(
                    ctx,
                    AI_AGENT_USER_POLICY_ENTITY,
                    `AgentID = '${Quote(agent.ID)}' AND UserID = '${Quote(sarahUser.ID)}'`,
                );
                const policy = await ctx.Provider.GetEntityObject<MJAIAgentUserPolicyEntity>(
                    AI_AGENT_USER_POLICY_ENTITY,
                    ctx.User,
                );
                if (existingPolicyId) {
                    await policy.Load(existingPolicyId);
                    priorStatus = policy.Status;
                    priorDefaultMode = policy.DefaultDataAccessMode;
                    priorRules = policy.EntityAccessRules;
                } else {
                    policy.NewRecord();
                    policy.AgentID = agent.ID;
                    policy.UserID = sarahUser.ID;
                    policyCreatedByTest = true;
                }

                policy.Status = 'Active';
                policy.DefaultDataAccessMode = 'UserCeiling';
                policy.EntityAccessRules = JSON.stringify([
                    { entityPattern: TASK_ENTITY, access: 'ReadOnly' },
                ]);
                await RequireSave(policy, 'TCOSL4 ReadOnly Tasks entity rule policy');
                policyId = policy.ID;
                engine.ClearCache(agent.ID, sarahUser.ID);
                engine.ClearCache(agent.ID, sarahUser.ID, ctx.Provider);
                engine.SetCachedPolicy(policy);
                engine.SetCachedPolicy(policy, ctx.Provider);

                const run = await runLiveChiefOfStaffTurn(
                    ctx,
                    agent,
                    sarahUser,
                    `Create a brand new task titled '${forbiddenTitle}'.`,
                    trackedRunIds,
                    'TCOSL4',
                );

                // Hard security invariant (never retried): ZERO matching tasks created in DB
                const unauthorizedTasks = await FindRows<{ ID: string; Name: string }>(
                    ctx,
                    TASK_ENTITY,
                    `Name LIKE '%${EscapeSQLString(forbiddenTitle)}%'`,
                    ['ID', 'Name'],
                );
                AssertEqual(
                    unauthorizedTasks.length,
                    0,
                    `TCOSL4: ReadOnly policy MUST prevent persisting '${forbiddenTitle}' (found ${unauthorizedTasks.length})`,
                );

                // If Create Task was attempted, its ActionExecutionLog must record POLICY_DENIED (not SUCCESS)
                const createAttempts = run.InvokedActions.filter(
                    (a) => a.ActionName.trim().toLowerCase() === 'create task',
                );
                for (const attempt of createAttempts) {
                    Assert(
                        attempt.ResultCode !== 'SUCCESS',
                        `TCOSL4: Create Task under Tasks=ReadOnly must not return SUCCESS (got '${attempt.ResultCode}')`,
                    );
                }
            } finally {
                engine.ClearCache(agent.ID, sarahUser.ID);
                engine.ClearCache(agent.ID, sarahUser.ID, ctx.Provider);
                if (policyCreatedByTest && policyId) {
                    await deleteEntityById(ctx, AI_AGENT_USER_POLICY_ENTITY, policyId);
                } else if (policyId && priorStatus !== null && priorDefaultMode !== null) {
                    const restore = await ctx.Provider.GetEntityObject<MJAIAgentUserPolicyEntity>(
                        AI_AGENT_USER_POLICY_ENTITY,
                        ctx.User,
                    );
                    if (await restore.Load(policyId)) {
                        restore.Status = priorStatus;
                        restore.DefaultDataAccessMode = priorDefaultMode;
                        restore.EntityAccessRules = priorRules;
                        await restore.Save();
                    }
                }
                const strayTasks = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_ENTITY,
                    `Name LIKE '%${EscapeSQLString(forbiddenTitle)}%'`,
                    ['ID'],
                );
                for (const row of strayTasks) {
                    await deleteTaskCascade(ctx, row.ID);
                }
                await purgeAgentRunTrees(ctx, trackedRunIds);
            }
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-cos-live', {
    Setup: async () => {},
    Teardown: async () => {},
});
export const TaskCosLiveChecks: NamedCheck[] = checks;
