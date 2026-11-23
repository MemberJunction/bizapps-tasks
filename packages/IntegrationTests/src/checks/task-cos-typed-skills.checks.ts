/**
 * TSK-09 (`task-cos-typed-skills`): Deterministic integration checks for Chief of Staff
 * typed Tasks, Work Reports, and Meetings & Transcripts skills, policy enforcement on both
 * typed actions and the 3 Tasks Remotable Operations, RLS isolation, and metadata governance.
 *
 * Self-cleaning: every ephemeral task, policy, work report, meeting, note, and action log
 * created inside TCOS1–TCOS5 is purged in `finally`, leaving `TSK-00` Task World untouched.
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
import { ActionParam, ActionResult, RunActionParams } from '@memberjunction/actions-base';
import { AgentUserPolicyEngine } from '@memberjunction/ai-core-plus';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type IntegrationCheckContext,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import {
    TasksBulkUpdateOperation,
    TasksInstantiateTemplateOperation,
    TasksRunRecurringPlaybooksOperation,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ACTION_ENTITY,
    ACTION_EXECUTION_LOG_ENTITY,
    ACTION_PARAM_ENTITY,
    AI_AGENT_ENTITY,
    AI_AGENT_REQUEST_ENTITY,
    AI_AGENT_SKILL_ENTITY,
    AI_AGENT_USER_POLICY_ENTITY,
    AI_SKILL_ACTION_ENTITY,
    AI_SKILL_ENTITY,
    ENTITY_DOCUMENT_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    PERSON_ENTITY,
    RHYTHM_TEMPLATE_ENTITY,
    ROLE_ENTITY,
    TASK_ACTIVITY_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_CHECK_IN_ENTITY,
    TASK_COMMENT_ENTITY,
    TASK_DEPENDENCY_ENTITY,
    TASK_ENTITY,
    TASK_LINK_ENTITY,
    TASK_TAG_LINK_ENTITY,
    TASK_TYPE_ENTITY,
    USER_ENTITY,
    USER_ROLE_ENTITY,
    WORK_REPORT_ENTITY,
    WORK_REPORT_ITEM_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave, View, VouchForSeed } from '../wire.js';
import { ACME_ORG_NAME, GetOrLoadWorld } from '../world/load-world.js';

const COS_AGENT_NAME = 'Chief of Staff';
const FORBIDDEN_RAW_ACTIONS: ReadonlySet<string> = new Set([
    'execute ad-hoc sql',
    'get records',
    'create record',
    'update record',
    'delete record',
]);

const EXPECTED_COS_SKILLS = [
    'Chief of Staff Tasks & To-dos',
    'Chief of Staff Meetings & Transcripts',
    'Work reports',
] as const;

const EXPECTED_RHYTHM_KEYS = [
    'tasks-daily-triage',
    'tasks-weekly-review',
    'daily-work-report',
] as const;

function inputParam(name: string, value: string | number | boolean): ActionParam {
    return { Name: name, Value: value, Type: 'Input' };
}

function readOutParam(result: ActionResult, params: ActionParam[], name: string): string | number | boolean | null {
    const needle = name.toLowerCase();
    const fromResult = result.Params?.find((p) => p.Name.toLowerCase() === needle);
    if (fromResult && fromResult.Value !== undefined) {
        return fromResult.Value as string | number | boolean | null;
    }
    const fromInput = params.find((p) => p.Name.toLowerCase() === needle);
    return (fromInput?.Value as string | number | boolean | null | undefined) ?? null;
}

async function runTypedAction(
    ctx: IntegrationCheckContext,
    actionName: string,
    user: UserInfo,
    params: ActionParam[],
    createdLogIds: string[],
    actionContext?: Record<string, string>,
): Promise<ActionResult> {
    await ActionEngineServer.Instance.Config(false, ctx.User);
    const action = ActionEngineServer.Instance.Actions.find(
        (a) => a.Name === actionName && a.Status === 'Active',
    );
    Assert(!!action, `Active MJ: Action '${actionName}' must exist in metadata`);

    const run = new RunActionParams();
    run.Action = action!;
    run.ContextUser = user;
    run.Params = params;
    run.Filters = [];
    if (actionContext) {
        run.Context = actionContext;
    }

    const result = await ActionEngineServer.Instance.RunAction(run);
    if (result.LogEntry?.ID) {
        createdLogIds.push(result.LogEntry.ID);
    }
    return result;
}

async function ensureUIUserForPerson(
    ctx: IntegrationCheckContext,
    person: { ID: string; Email: string; FirstName: string; LastName: string },
): Promise<UserInfo> {
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.EntityByName(PERSON_ENTITY);
    Assert(!!peopleEntity, `${PERSON_ENTITY} entity metadata missing`);
    const uiRoleId = await FindId(ctx, ROLE_ENTITY, `Name = 'UI'`);
    Assert(!!uiRoleId, 'UI role missing from MJ: Roles');

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
    await RequireSave(userEntity, `UI user for ${person.Email}`);

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
        // Best-effort cleanup in finally blocks
    }
}

async function deleteTaskCascade(ctx: IntegrationCheckContext, taskID: string): Promise<void> {
    if (!IsValidUUID(taskID)) return;
    const escaped = EscapeSQLString(taskID);
    const childQueries: Array<{ entity: string; filter: string }> = [
        { entity: TASK_DEPENDENCY_ENTITY, filter: `TaskID = '${escaped}' OR DependsOnTaskID = '${escaped}'` },
        { entity: TASK_ASSIGNMENT_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_COMMENT_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_CHECK_IN_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_LINK_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_TAG_LINK_ENTITY, filter: `TaskID = '${escaped}'` },
        { entity: TASK_ACTIVITY_ENTITY, filter: `TaskID = '${escaped}'` },
    ];

    for (const q of childQueries) {
        try {
            const rows = await FindRows<{ ID: string }>(ctx, q.entity, q.filter, ['ID']);
            for (const row of rows) {
                await deleteEntityById(ctx, q.entity, row.ID);
            }
        } catch {
            // Continue cascading other children
        }
    }
    await deleteEntityById(ctx, TASK_ENTITY, taskID);
}

async function cleanupActionLogs(ctx: IntegrationCheckContext, logIds: readonly string[]): Promise<void> {
    for (const id of logIds) {
        await deleteEntityById(ctx, ACTION_EXECUTION_LOG_ENTITY, id);
    }
}

const checks: NamedCheck[] = [
    // =========================================================================
    // TCOS1: Full CoS Tasks Typed Actions Lifecycle under Non-Owner UI User
    // =========================================================================
    {
        Id: 'task-cos-typed-skills.TCOS1',
        Name: 'TCOS1 — Non-Owner UI user executes Find/Create/Update/AddUpdate/Assign/Complete/FindSimilar/Briefing with OrganizationID & idempotency',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarahPerson = world.People['sarah.connor@task-world.test'];
            const alexPerson = world.People['alex.chen@task-world.test'];
            const marcusPerson = world.People['marcus.vance@task-world.test'];
            const acmeOrg = world.Organizations[ACME_ORG_NAME];
            Assert(!!sarahPerson && !!alexPerson && !!marcusPerson && !!acmeOrg, 'TSK-00 people and Acme org must exist');

            const sarahUser = await ensureUIUserForPerson(ctx, sarahPerson);
            const marcusUser = await ensureUIUserForPerson(ctx, marcusPerson);
            const createdTaskIds: string[] = [];
            const logIds: string[] = [];
            const stamp = Date.now();
            const taskTitle = `TCOS1 Acme Renewal Deliverable ${stamp}`;
            const requestKey = `tcos1-key-${stamp}`;

            try {
                // 1. Create Task with OrganizationName + ClientRequestKey
                const createParams = [
                    inputParam('Name', taskTitle),
                    inputParam('Description', 'TCOS1 verification task scoped to Acme Enterprise Corp'),
                    inputParam('Priority', 'High'),
                    inputParam('OrganizationName', ACME_ORG_NAME),
                    inputParam('DueAt', new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString()),
                    inputParam('ClientRequestKey', requestKey),
                ];
                const createRes = await runTypedAction(ctx, 'Create Task', sarahUser, createParams, logIds);
                Assert(createRes.Success, `Create Task failed: ${createRes.Message}`);
                const taskID = String(readOutParam(createRes, createParams, 'TaskID') ?? '');
                Assert(IsValidUUID(taskID), 'Create Task returned valid TaskID');
                createdTaskIds.push(taskID);
                AssertEqual(readOutParam(createRes, createParams, 'IdempotentHit'), false, 'first Create Task is not an idempotent hit');
                Assert(
                    UUIDsEqual(String(readOutParam(createRes, createParams, 'OrganizationID') ?? ''), acmeOrg.ID),
                    'Create Task stamped and returned Acme OrganizationID',
                );

                // 2. Idempotent retry with identical ClientRequestKey returns same TaskID
                const retryParams = [
                    inputParam('Name', taskTitle),
                    inputParam('OrganizationID', acmeOrg.ID),
                    inputParam('ClientRequestKey', requestKey),
                ];
                const retryRes = await runTypedAction(ctx, 'Create Task', sarahUser, retryParams, logIds);
                Assert(retryRes.Success, `Idempotent Create Task retry failed: ${retryRes.Message}`);
                Assert(
                    UUIDsEqual(String(readOutParam(retryRes, retryParams, 'TaskID') ?? ''), taskID),
                    'Idempotent Create Task reused original TaskID',
                );
                AssertEqual(readOutParam(retryRes, retryParams, 'IdempotentHit'), true, 'IdempotentHit is true on retry');

                // 3. Find Tasks with OrganizationID filter + NULL-safe planning exclusion
                const findParams = [
                    inputParam('Scope', 'Mine'),
                    inputParam('OrganizationID', acmeOrg.ID),
                    inputParam('SearchText', `TCOS1 Acme Renewal Deliverable ${stamp}`),
                ];
                const findRes = await runTypedAction(ctx, 'Find Tasks', sarahUser, findParams, logIds);
                Assert(findRes.Success, `Find Tasks failed: ${findRes.Message}`);
                const foundRows = JSON.parse(String(readOutParam(findRes, findParams, 'Tasks') ?? '[]')) as Array<{
                    ID: string;
                    Type: string;
                    OrganizationID: string | null;
                    Organization: string | null;
                }>;
                Assert(foundRows.some((r) => UUIDsEqual(r.ID, taskID)), 'Find Tasks returned created Acme task');
                const matchedRow = foundRows.find((r) => UUIDsEqual(r.ID, taskID))!;
                Assert(UUIDsEqual(matchedRow.OrganizationID, acmeOrg.ID), 'Find Tasks row includes OrganizationID');
                AssertEqual(matchedRow.Organization, ACME_ORG_NAME, 'Find Tasks row includes Organization name');
                Assert(
                    foundRows.every((r) => !['priority objective', 'key result', 'priority'].includes((r.Type ?? '').toLowerCase())),
                    'Find Tasks excludes strategic planning types by default',
                );

                // 4. Update Task
                const updateParams = [
                    inputParam('TaskID', taskID),
                    inputParam('Status', 'InProgress'),
                    inputParam('PercentComplete', 50),
                    inputParam('Priority', 'Critical'),
                ];
                const updateRes = await runTypedAction(ctx, 'Update Task', sarahUser, updateParams, logIds);
                Assert(updateRes.Success, `Update Task failed: ${updateRes.Message}`);

                // 5. Add Task Update (comment + structured check-in)
                const commentParams = [
                    inputParam('TaskID', taskID),
                    inputParam('Content', 'TCOS1 status comment recorded.'),
                ];
                const commentRes = await runTypedAction(ctx, 'Add Task Update', sarahUser, commentParams, logIds);
                Assert(commentRes.Success, `Add Task Update (comment) failed: ${commentRes.Message}`);
                AssertEqual(readOutParam(commentRes, commentParams, 'UpdateKind'), 'Comment', 'comment UpdateKind');

                const checkInParams = [
                    inputParam('TaskID', taskID),
                    inputParam('Content', 'TCOS1 check-in on track.'),
                    inputParam('HealthStatus', 'OnTrack'),
                    inputParam('ConfidenceScore', 85),
                ];
                const checkInRes = await runTypedAction(ctx, 'Add Task Update', sarahUser, checkInParams, logIds);
                Assert(checkInRes.Success, `Add Task Update (check-in) failed: ${checkInRes.Message}`);
                AssertEqual(readOutParam(checkInRes, checkInParams, 'UpdateKind'), 'CheckIn', 'check-in UpdateKind');

                // 6. Assign Task
                const assignParams = [
                    inputParam('TaskID', taskID),
                    inputParam('AssigneeEmail', alexPerson.Email),
                    inputParam('Role', 'Reviewer'),
                ];
                const assignRes = await runTypedAction(ctx, 'Assign Task', sarahUser, assignParams, logIds);
                Assert(assignRes.Success, `Assign Task failed: ${assignRes.Message}`);
                Assert(
                    IsValidUUID(String(readOutParam(assignRes, assignParams, 'TaskAssignmentID') ?? '')),
                    'Assign Task created TaskAssignmentID',
                );

                // 7. Find Similar Tasks (30-day lexical dedup)
                const simParams = [inputParam('Text', taskTitle)];
                const simRes = await runTypedAction(ctx, 'Find Similar Tasks', sarahUser, simParams, logIds);
                Assert(simRes.Success, `Find Similar Tasks failed: ${simRes.Message}`);
                AssertEqual(readOutParam(simRes, simParams, 'HasLikelyDuplicate'), true, 'Find Similar Tasks flagged duplicate');
                const matches = JSON.parse(String(readOutParam(simRes, simParams, 'Matches') ?? '[]')) as Array<{ TaskID: string }>;
                Assert(matches.some((m) => UUIDsEqual(m.TaskID, taskID)), 'Find Similar Tasks matched created task');

                // 8. Get My Tasks Briefing (org-scoped + metadata verifies Role='Briefing', ExposeToModel=false)
                // Because Step 6 delegated this task to Alex, Get My Tasks Briefing classifies it under WaitingOnOthers.
                const briefParams = [
                    inputParam('HorizonDays', 7),
                    inputParam('OrganizationName', ACME_ORG_NAME),
                ];
                const briefRes = await runTypedAction(ctx, 'Get My Tasks Briefing', sarahUser, briefParams, logIds);
                Assert(briefRes.Success, `Get My Tasks Briefing failed: ${briefRes.Message}`);
                const briefing = JSON.parse(String(readOutParam(briefRes, briefParams, 'Briefing') ?? '{}')) as {
                    OrganizationID: string | null;
                    OrganizationName: string | null;
                    UpcomingTasks: Array<{ ID: string; OrganizationID: string | null }>;
                    WaitingOnOthersTasks: Array<{ ID: string; OrganizationID: string | null }>;
                };
                Assert(UUIDsEqual(briefing.OrganizationID, acmeOrg.ID), 'Briefing stamped OrganizationID');
                AssertEqual(briefing.OrganizationName, ACME_ORG_NAME, 'Briefing stamped OrganizationName');
                const briefingTasks = [...(briefing.UpcomingTasks ?? []), ...(briefing.WaitingOnOthersTasks ?? [])];
                Assert(
                    briefingTasks.some((t) => UUIDsEqual(t.ID, taskID)),
                    'Briefing includes Acme task (in UpcomingTasks or WaitingOnOthersTasks after delegation)',
                );

                const briefingSkillActions = await FindRows<{ Role: string; ExposeToModel: boolean }>(
                    ctx,
                    AI_SKILL_ACTION_ENTITY,
                    `ActionID IN (SELECT ID FROM [__mj].[vwActions] WHERE Name = 'Get My Tasks Briefing')`,
                    ['Role', 'ExposeToModel'],
                );
                Assert(briefingSkillActions.length >= 1, 'Get My Tasks Briefing linked to skill');
                AssertEqual(briefingSkillActions[0].Role, 'Briefing', 'Get My Tasks Briefing Role=Briefing');
                AssertEqual(briefingSkillActions[0].ExposeToModel, false, 'Get My Tasks Briefing ExposeToModel=false');

                // 9. Mark Task Complete + idempotent repeat
                const compParams = [
                    inputParam('TaskID', taskID),
                    inputParam('CompletionNote', 'TCOS1 verified complete.'),
                ];
                const compRes = await runTypedAction(ctx, 'Mark Task Complete', sarahUser, compParams, logIds);
                Assert(compRes.Success, `Mark Task Complete failed: ${compRes.Message}`);
                AssertEqual(readOutParam(compRes, compParams, 'AlreadyCompleted'), false, 'first Mark Task Complete not already completed');

                const compRepeatParams = [inputParam('TaskID', taskID)];
                const compRepeatRes = await runTypedAction(ctx, 'Mark Task Complete', sarahUser, compRepeatParams, logIds);
                Assert(compRepeatRes.Success, 'repeat Mark Task Complete succeeded');
                AssertEqual(compRepeatRes.Result?.ResultCode, 'ALREADY_COMPLETED', 'repeat Mark Task Complete returns ALREADY_COMPLETED');

                // 10. Task.Visibility = 'Private' RLS isolation: User A (Sarah) sees it; User B (Marcus) sees 0 rows
                const privateTitle = `TCOS1 Private Executive Task ${stamp}`;
                const createPrivateParams = [
                    inputParam('Name', privateTitle),
                    inputParam('Description', 'Confidential task visible only to Sarah'),
                    inputParam('Priority', 'High'),
                    inputParam('Visibility', 'Private'),
                ];
                const createPrivateRes = await runTypedAction(ctx, 'Create Task', sarahUser, createPrivateParams, logIds);
                Assert(createPrivateRes.Success, `Create Private Task failed: ${createPrivateRes.Message}`);
                const privateTaskID = String(readOutParam(createPrivateRes, createPrivateParams, 'TaskID') ?? '');
                Assert(IsValidUUID(privateTaskID), 'Create Private Task returned valid TaskID');
                createdTaskIds.push(privateTaskID);
                const createdPrivateJson = JSON.parse(String(readOutParam(createPrivateRes, createPrivateParams, 'Task') ?? '{}')) as {
                    Visibility?: string;
                };
                AssertEqual(createdPrivateJson.Visibility, 'Private', 'Created task has Visibility = Private');

                // Add a comment on the private task so child-entity RLS (Task Comments) is also verified
                const privateCommentRes = await runTypedAction(
                    ctx,
                    'Add Task Update',
                    sarahUser,
                    [inputParam('TaskID', privateTaskID), inputParam('Content', 'Confidential private comment')],
                    logIds,
                );
                Assert(privateCommentRes.Success, `Add comment on private task failed: ${privateCommentRes.Message}`);

                // User A (Sarah) sees her Private task via Find Tasks (Scope = 'Team') and Get Task
                const sarahTeamFindParams = [
                    inputParam('Scope', 'Team'),
                    inputParam('SearchText', privateTitle),
                ];
                const sarahTeamFindRes = await runTypedAction(ctx, 'Find Tasks', sarahUser, sarahTeamFindParams, logIds);
                Assert(sarahTeamFindRes.Success, `Sarah Find Tasks (Team) failed: ${sarahTeamFindRes.Message}`);
                const sarahTeamRows = JSON.parse(String(readOutParam(sarahTeamFindRes, sarahTeamFindParams, 'Tasks') ?? '[]')) as Array<{ ID: string }>;
                Assert(sarahTeamRows.some((r) => UUIDsEqual(r.ID, privateTaskID)), 'User A (Sarah) sees her own Private task');

                const sarahGetPrivateRes = await runTypedAction(
                    ctx,
                    'Get Task',
                    sarahUser,
                    [inputParam('TaskID', privateTaskID)],
                    logIds,
                );
                Assert(sarahGetPrivateRes.Success, `User A (Sarah) can Get her own Private task: ${sarahGetPrivateRes.Message}`);

                // User B (Marcus, UI role, neither creator nor assignee) MUST see 0 rows via DB RLS and Find Tasks (Scope = 'Team')
                const marcusDirectRlsRes = await View(ctx).RunView<{ ID: string }>(
                    {
                        EntityName: TASK_ENTITY,
                        ExtraFilter: `ID = '${EscapeSQLString(privateTaskID)}'`,
                        Fields: ['ID'],
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    marcusUser,
                );
                Assert(marcusDirectRlsRes.Success, `Marcus RLS RunView failed: ${marcusDirectRlsRes.ErrorMessage}`);
                AssertEqual((marcusDirectRlsRes.Results ?? []).length, 0, 'User B (Marcus) sees 0 rows for User A Private task via DB RLS');

                const marcusCommentsRlsRes = await View(ctx).RunView<{ ID: string }>(
                    {
                        EntityName: TASK_COMMENT_ENTITY,
                        ExtraFilter: `TaskID = '${EscapeSQLString(privateTaskID)}'`,
                        Fields: ['ID'],
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    marcusUser,
                );
                Assert(marcusCommentsRlsRes.Success, `Marcus Task Comments RLS RunView failed: ${marcusCommentsRlsRes.ErrorMessage}`);
                AssertEqual((marcusCommentsRlsRes.Results ?? []).length, 0, 'User B (Marcus) sees 0 Task Comments for User A Private task via DB RLS');

                const marcusTeamFindParams = [
                    inputParam('Scope', 'Team'),
                    inputParam('SearchText', privateTitle),
                ];
                const marcusTeamFindRes = await runTypedAction(ctx, 'Find Tasks', marcusUser, marcusTeamFindParams, logIds);
                Assert(marcusTeamFindRes.Success, `Marcus Find Tasks (Team) failed: ${marcusTeamFindRes.Message}`);
                const marcusTeamRows = JSON.parse(String(readOutParam(marcusTeamFindRes, marcusTeamFindParams, 'Tasks') ?? '[]')) as Array<{ ID: string }>;
                Assert(
                    !marcusTeamRows.some((r) => UUIDsEqual(r.ID, privateTaskID)),
                    'User B (Marcus) must NOT see User A Private task in Find Tasks (Scope = Team)',
                );

                const marcusGetPrivateRes = await runTypedAction(
                    ctx,
                    'Get Task',
                    marcusUser,
                    [inputParam('TaskID', privateTaskID)],
                    logIds,
                );
                Assert(!marcusGetPrivateRes.Success, 'User B (Marcus) cannot Get User A Private task');
            } finally {
                // Clean up any novel task created during Accept Meeting Commitments even if a later step threw
                try {
                    const extraTasks = await FindRows<{ ID: string }>(
                        ctx,
                        TASK_ENTITY,
                        `Name LIKE '%${EscapeSQLString(String(stamp))}%'`,
                        ['ID'],
                    );
                    for (const t of extraTasks) {
                        if (!createdTaskIds.some((id) => UUIDsEqual(id, t.ID))) {
                            createdTaskIds.push(t.ID);
                        }
                    }
                } catch {
                    // Best-effort cleanup
                }
                for (const id of createdTaskIds) {
                    await deleteTaskCascade(ctx, id);
                }
                await cleanupActionLogs(ctx, logIds);
            }
        },
    },

    // =========================================================================
    // TCOS2: TypedActionPolicyGuard Enforcement across Typed Actions + 3 Remotable Ops
    // =========================================================================
    {
        Id: 'task-cos-typed-skills.TCOS2',
        Name: 'TCOS2 — TypedActionPolicyGuard blocks ReadOnly/ApprovalRequired on typed Task actions and all 3 Remotable Operations while ReadWrite & direct human calls succeed',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarahPerson = world.People['sarah.connor@task-world.test'];
            const acmeOrg = world.Organizations[ACME_ORG_NAME];
            Assert(!!sarahPerson && !!acmeOrg, 'TSK-00 people and org must exist');

            const sarahUser = await ensureUIUserForPerson(ctx, sarahPerson);
            const cosAgentId = await FindId(ctx, AI_AGENT_ENTITY, `Name = '${Quote(COS_AGENT_NAME)}'`);
            Assert(!!cosAgentId, `Agent '${COS_AGENT_NAME}' must exist in metadata`);

            const createdTaskIds: string[] = [];
            const logIds: string[] = [];
            let policyCreatedByTest = false;
            let savedPolicyId: string | null = null;
            let priorMode: MJAIAgentUserPolicyEntity['DefaultDataAccessMode'] | null = null;
            let priorDestructive: boolean | null = null;
            let priorStatus: MJAIAgentUserPolicyEntity['Status'] | null = null;

            const engine = AgentUserPolicyEngine.Instance;

            try {
                // Create an ephemeral task owned by Sarah for Update / BulkUpdate checks
                const generalType = world.TaskTypes['GENERAL'] ?? world.TaskTypes['General'];
                const probeTask = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                probeTask.NewRecord();
                probeTask.Name = `TCOS2 Policy Guard Probe ${Date.now()}`;
                probeTask.TypeID = generalType.ID;
                probeTask.OrganizationID = acmeOrg.ID;
                probeTask.CreatedByPersonID = sarahPerson.ID;
                probeTask.Status = 'Open';
                probeTask.Priority = 'Medium';
                VouchForSeed(probeTask, 'AuthorizeCreatorOnBehalf');
                await RequireSave(probeTask, 'TCOS2 probe task');
                createdTaskIds.push(probeTask.ID);

                // Find or create Sarah's CoS policy row
                const existingPolicyId = await FindId(
                    ctx,
                    AI_AGENT_USER_POLICY_ENTITY,
                    `AgentID = '${Quote(cosAgentId!)}' AND UserID = '${Quote(sarahUser.ID)}'`,
                );
                const policy = await ctx.Provider.GetEntityObject<MJAIAgentUserPolicyEntity>(
                    AI_AGENT_USER_POLICY_ENTITY,
                    ctx.User,
                );
                if (existingPolicyId) {
                    await policy.Load(existingPolicyId);
                    priorMode = policy.DefaultDataAccessMode;
                    priorDestructive = policy.RequireApprovalForDestructiveActions;
                    priorStatus = policy.Status;
                    savedPolicyId = policy.ID;
                } else {
                    policy.NewRecord();
                    policy.AgentID = cosAgentId!;
                    policy.UserID = sarahUser.ID;
                    policyCreatedByTest = true;
                }

                const applyPolicy = async (
                    mode: MJAIAgentUserPolicyEntity['DefaultDataAccessMode'],
                    requireDestructiveApproval: boolean,
                ): Promise<void> => {
                    policy.Status = 'Active';
                    policy.DefaultDataAccessMode = mode;
                    policy.RequireApprovalForDestructiveActions = requireDestructiveApproval;
                    await RequireSave(policy, `TCOS2 policy (${mode}, destructive=${requireDestructiveApproval})`);
                    savedPolicyId = policy.ID;
                    engine.ClearCache(cosAgentId!, sarahUser.ID);
                    engine.ClearCache(cosAgentId!, sarahUser.ID, ctx.Provider);
                    engine.SetCachedPolicy(policy);
                    engine.SetCachedPolicy(policy, ctx.Provider);
                };

                // Phase A: ReadOnly blocks all write typed actions + all 3 Remotable Operations (live), while allowing reads & DryRun
                await applyPolicy('ReadOnly', true);

                await engine.RunWithExecutingAgentContext(cosAgentId!, async () => {
                    const createBlocked = await runTypedAction(
                        ctx,
                        'Create Task',
                        sarahUser,
                        [inputParam('Name', 'TCOS2 Should Not Persist')],
                        logIds,
                        { AgentID: cosAgentId! },
                    );
                    Assert(!createBlocked.Success, 'Create Task blocked under ReadOnly');
                    AssertEqual(createBlocked.Result?.ResultCode, 'POLICY_DENIED', 'Create Task returns POLICY_DENIED');

                    const updateBlocked = await runTypedAction(
                        ctx,
                        'Update Task',
                        sarahUser,
                        [inputParam('TaskID', probeTask.ID), inputParam('Priority', 'Critical')],
                        logIds,
                        { AgentID: cosAgentId! },
                    );
                    Assert(!updateBlocked.Success, 'Update Task blocked under ReadOnly');
                    AssertEqual(updateBlocked.Result?.ResultCode, 'POLICY_DENIED', 'Update Task returns POLICY_DENIED');

                    const findAllowed = await runTypedAction(
                        ctx,
                        'Find Tasks',
                        sarahUser,
                        [inputParam('OrganizationID', acmeOrg.ID)],
                        logIds,
                        { AgentID: cosAgentId! },
                    );
                    Assert(findAllowed.Success, `Find Tasks should be allowed under ReadOnly: ${findAllowed.Message}`);

                    const bulkBlocked = await new TasksBulkUpdateOperation().Execute(
                        { TaskIDs: [probeTask.ID], Priority: 'Critical' },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(!bulkBlocked.Success, 'BulkUpdateTasks blocked under ReadOnly');
                    Assert(
                        (bulkBlocked.ErrorMessage ?? '').includes('POLICY_DENIED'),
                        `BulkUpdateTasks error must include POLICY_DENIED, got: ${bulkBlocked.ErrorMessage}`,
                    );

                    const instBlocked = await new TasksInstantiateTemplateOperation().Execute(
                        { TemplateID: world.CloseTemplateID, StartDate: '2026-12-01', OrganizationID: acmeOrg.ID },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(!instBlocked.Success, 'InstantiateTemplate blocked under ReadOnly');
                    Assert(
                        (instBlocked.ErrorMessage ?? '').includes('POLICY_DENIED'),
                        `InstantiateTemplate error must include POLICY_DENIED, got: ${instBlocked.ErrorMessage}`,
                    );

                    const recurBlocked = await new TasksRunRecurringPlaybooksOperation().Execute(
                        {
                            TemplateID: world.CloseTemplateID,
                            AnchorDate: '2026-12-01',
                            PeriodKey: `TCOS2-${Date.now()}`,
                            OrganizationIDs: [acmeOrg.ID],
                            DryRun: false,
                        },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(!recurBlocked.Success, 'RunRecurringPlaybooks (live) blocked under ReadOnly');
                    Assert(
                        (recurBlocked.ErrorMessage ?? '').includes('POLICY_DENIED'),
                        `RunRecurringPlaybooks error must include POLICY_DENIED, got: ${recurBlocked.ErrorMessage}`,
                    );

                    const recurDry = await new TasksRunRecurringPlaybooksOperation().Execute(
                        {
                            TemplateID: world.CloseTemplateID,
                            AnchorDate: '2026-12-01',
                            PeriodKey: `TCOS2-DRY-${Date.now()}`,
                            OrganizationIDs: [acmeOrg.ID],
                            DryRun: true,
                        },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(recurDry.Success, `RunRecurringPlaybooks DryRun allowed under ReadOnly: ${recurDry.ErrorMessage}`);
                });

                // Phase B: UserCeiling + RequireApprovalForDestructiveActions=true blocks destructive BulkUpdate / Rollover with APPROVAL_REQUIRED
                await applyPolicy('UserCeiling', true);
                await engine.RunWithExecutingAgentContext(cosAgentId!, async () => {
                    const bulkApproval = await new TasksBulkUpdateOperation().Execute(
                        { TaskIDs: [probeTask.ID], Priority: 'High' },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(!bulkApproval.Success, 'BulkUpdateTasks requires approval when RequireApprovalForDestructiveActions=true');
                    Assert(
                        (bulkApproval.ErrorMessage ?? '').includes('APPROVAL_REQUIRED'),
                        `Expected APPROVAL_REQUIRED, got: ${bulkApproval.ErrorMessage}`,
                    );
                });

                // Phase C: UserCeiling + RequireApprovalForDestructiveActions=false permits BulkUpdate & InstantiateTemplate
                await applyPolicy('UserCeiling', false);
                await engine.RunWithExecutingAgentContext(cosAgentId!, async () => {
                    const bulkOk = await new TasksBulkUpdateOperation().Execute(
                        { TaskIDs: [probeTask.ID], Priority: 'High' },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(bulkOk.Success, `BulkUpdateTasks should succeed under permissive UserCeiling: ${bulkOk.ErrorMessage}`);

                    const instOk = await new TasksInstantiateTemplateOperation().Execute(
                        { TemplateID: world.CloseTemplateID, StartDate: '2026-12-01', OrganizationID: acmeOrg.ID },
                        { provider: ctx.Provider, user: sarahUser },
                    );
                    Assert(instOk.Success, `InstantiateTemplate should succeed under UserCeiling: ${instOk.ErrorMessage}`);
                    for (const tid of instOk.Output?.CreatedTaskIDs ?? []) {
                        createdTaskIds.push(tid);
                    }
                });

                // Phase D: Direct human call (outside RunWithExecutingAgentContext) succeeds even while ReadOnly policy exists
                await applyPolicy('ReadOnly', true);
                const directHumanOk = await new TasksBulkUpdateOperation().Execute(
                    { TaskIDs: [probeTask.ID], Priority: 'Low' },
                    { provider: ctx.Provider, user: sarahUser },
                );
                Assert(directHumanOk.Success, `Direct human BulkUpdateTasks must bypass agent policy: ${directHumanOk.ErrorMessage}`);
            } finally {
                engine.ClearCache(cosAgentId!, sarahUser.ID);
                engine.ClearCache(cosAgentId!, sarahUser.ID, ctx.Provider);
                if (policyCreatedByTest && savedPolicyId) {
                    await deleteEntityById(ctx, AI_AGENT_USER_POLICY_ENTITY, savedPolicyId);
                } else if (savedPolicyId && priorMode !== null && priorDestructive !== null && priorStatus !== null) {
                    const restore = await ctx.Provider.GetEntityObject<MJAIAgentUserPolicyEntity>(
                        AI_AGENT_USER_POLICY_ENTITY,
                        ctx.User,
                    );
                    if (await restore.Load(savedPolicyId)) {
                        restore.DefaultDataAccessMode = priorMode;
                        restore.RequireApprovalForDestructiveActions = priorDestructive;
                        restore.Status = priorStatus;
                        await restore.Save();
                    }
                }
                for (const id of createdTaskIds) {
                    await deleteTaskCascade(ctx, id);
                }
                await cleanupActionLogs(ctx, logIds);
            }
        },
    },

    // =========================================================================
    // TCOS3: Work Reports Lifecycle (Draft -> Submit -> Get -> List -> Review) + RLS Check
    // =========================================================================
    {
        Id: 'task-cos-typed-skills.TCOS3',
        Name: 'TCOS3 — Work Reports lifecycle (Draft -> Submit -> Get -> List -> Review) under non-Owner UI user + third-party RLS isolation',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarahPerson = world.People['sarah.connor@task-world.test'];
            const alexPerson = world.People['alex.chen@task-world.test'];
            const marcusPerson = world.People['marcus.vance@task-world.test'];
            Assert(!!sarahPerson && !!alexPerson && !!marcusPerson, 'TSK-00 Sarah, Alex, and Marcus must exist');

            const sarahUser = await ensureUIUserForPerson(ctx, sarahPerson);
            const alexUser = await ensureUIUserForPerson(ctx, alexPerson);
            const marcusUser = await ensureUIUserForPerson(ctx, marcusPerson);

            const createdTaskIds: string[] = [];
            const logIds: string[] = [];
            let createdReportId: string | null = null;
            let supervisorRequestId: string | null = null;

            try {
                // Create a task touched by Sarah so Draft Work Report finds real activity
                const createTaskParams = [
                    inputParam('Name', `TCOS3 Work Report Activity Task ${Date.now()}`),
                    inputParam('Priority', 'Medium'),
                ];
                const taskRes = await runTypedAction(ctx, 'Create Task', sarahUser, createTaskParams, logIds);
                Assert(taskRes.Success, `TCOS3 setup task creation failed: ${taskRes.Message}`);
                const taskID = String(readOutParam(taskRes, createTaskParams, 'TaskID') ?? '');
                Assert(IsValidUUID(taskID), 'TCOS3 setup TaskID valid');
                createdTaskIds.push(taskID);

                // Pick a unique historical 1-day window that cannot collide with seeded world reports
                const now = new Date();
                const periodStart = new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString();
                const periodEnd = new Date(now.getTime() + 2 * 60 * 60 * 1000).toISOString();

                // 1. Draft Work Report as Sarah
                const draftParams = [
                    inputParam('PeriodStart', periodStart),
                    inputParam('PeriodEnd', periodEnd),
                    inputParam('Title', `TCOS3 Work Report ${Date.now()}`),
                    inputParam('Body', '### Completed\n- Completed TCOS3 integration verification task.'),
                ];
                const draftRes = await runTypedAction(ctx, 'Draft Work Report', sarahUser, draftParams, logIds);
                Assert(draftRes.Success, `Draft Work Report failed: ${draftRes.Message}`);
                createdReportId = String(readOutParam(draftRes, draftParams, 'WorkReportID') ?? '');
                Assert(IsValidUUID(createdReportId), `Draft Work Report returned valid WorkReportID (got '${createdReportId}')`);

                // 2. Get Work Report as author Sarah
                const getParams = [inputParam('WorkReportID', createdReportId)];
                const getRes = await runTypedAction(ctx, 'Get Work Report', sarahUser, getParams, logIds);
                Assert(getRes.Success, `Get Work Report failed: ${getRes.Message}`);

                // 3. List Work Reports as author Sarah
                const listParams = [inputParam('Scope', 'Mine')];
                const listRes = await runTypedAction(ctx, 'List Work Reports', sarahUser, listParams, logIds);
                Assert(listRes.Success, `List Work Reports failed: ${listRes.Message}`);
                const listed = JSON.parse(String(readOutParam(listRes, listParams, 'WorkReports') ?? '[]')) as Array<{ ID: string }>;
                Assert(listed.some((r) => UUIDsEqual(r.ID, createdReportId!)), 'List Work Reports includes drafted report');

                // 4. Submit Work Report as Sarah
                const submitParams = [inputParam('WorkReportID', createdReportId)];
                const submitRes = await runTypedAction(ctx, 'Submit Work Report', sarahUser, submitParams, logIds);
                Assert(submitRes.Success, `Submit Work Report failed: ${submitRes.Message}`);
                const reqIdRaw = String(readOutParam(submitRes, submitParams, 'SupervisorRequestID') ?? '');
                if (IsValidUUID(reqIdRaw)) {
                    supervisorRequestId = reqIdRaw;
                }

                // 5. RLS isolation: unrelated third-party UI user Marcus sees 0 rows
                const rlsRes = await View(ctx).RunView<{ ID: string }>(
                    {
                        EntityName: WORK_REPORT_ENTITY,
                        ExtraFilter: `ID = '${EscapeSQLString(createdReportId)}'`,
                        Fields: ['ID'],
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    marcusUser,
                );
                Assert(rlsRes.Success, `RLS RunView as Marcus failed: ${rlsRes.ErrorMessage}`);
                AssertEqual((rlsRes.Results ?? []).length, 0, 'Unrelated UI user Marcus must see 0 rows for Sarah work report via RLS');

                const marcusGetParams = [inputParam('WorkReportID', createdReportId)];
                const marcusGetRes = await runTypedAction(ctx, 'Get Work Report', marcusUser, marcusGetParams, logIds);
                Assert(!marcusGetRes.Success, 'Unrelated UI user Marcus cannot Get Sarah work report');

                // 5b. Get My Work Reports Briefing as supervisor Alex includes Sarah's submitted report awaiting review
                const wrBriefParams = [inputParam('LookbackDays', 14)];
                const wrBriefRes = await runTypedAction(ctx, 'Get My Work Reports Briefing', alexUser, wrBriefParams, logIds);
                Assert(wrBriefRes.Success, `Get My Work Reports Briefing failed: ${wrBriefRes.Message}`);
                const wrBriefing = JSON.parse(String(readOutParam(wrBriefRes, wrBriefParams, 'Briefing') ?? '{}')) as {
                    DirectReportsAwaitingReview?: Array<{ ID: string }>;
                };
                Assert(
                    (wrBriefing.DirectReportsAwaitingReview ?? []).some((r) => UUIDsEqual(r.ID, createdReportId!)),
                    'Get My Work Reports Briefing surfaces direct report submitted report awaiting review',
                );

                // 6. Review Work Report as supervisor Alex
                const reviewParams = [
                    inputParam('WorkReportID', createdReportId),
                    inputParam('SupervisorFeedback', 'TCOS3 supervisor review approved — great execution.'),
                ];
                const reviewRes = await runTypedAction(ctx, 'Review Work Report', alexUser, reviewParams, logIds);
                Assert(reviewRes.Success, `Review Work Report as supervisor Alex failed: ${reviewRes.Message}`);

                const [reviewedRow] = await FindRows<{ Status: string; SupervisorFeedback: string | null }>(
                    ctx,
                    WORK_REPORT_ENTITY,
                    `ID = '${EscapeSQLString(createdReportId)}'`,
                    ['Status', 'SupervisorFeedback'],
                );
                AssertEqual(reviewedRow?.Status, 'Reviewed', 'WorkReport transitioned to Reviewed');
                Assert(
                    (reviewedRow?.SupervisorFeedback ?? '').includes('TCOS3 supervisor review approved'),
                    'SupervisorFeedback persisted',
                );
            } finally {
                if (supervisorRequestId) {
                    await deleteEntityById(ctx, AI_AGENT_REQUEST_ENTITY, supervisorRequestId);
                }
                if (createdReportId) {
                    const itemRows = await FindRows<{ ID: string }>(
                        ctx,
                        WORK_REPORT_ITEM_ENTITY,
                        `WorkReportID = '${EscapeSQLString(createdReportId)}'`,
                        ['ID'],
                    );
                    for (const row of itemRows) {
                        await deleteEntityById(ctx, WORK_REPORT_ITEM_ENTITY, row.ID);
                    }
                    await deleteEntityById(ctx, WORK_REPORT_ENTITY, createdReportId);
                }
                for (const id of createdTaskIds) {
                    await deleteTaskCascade(ctx, id);
                }
                await cleanupActionLogs(ctx, logIds);
            }
        },
    },

    // =========================================================================
    // TCOS4: Meetings & Transcripts Lifecycle with 30-Day Similarity Dedup
    // =========================================================================
    {
        Id: 'task-cos-typed-skills.TCOS4',
        Name: 'TCOS4 — Meetings & Transcripts (Upcoming Meetings, Brief, Process Transcript, Accept Commitments w/ 30-day dedup, Get Notes)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const alexPerson = world.People['alex.chen@task-world.test'];
            const sarahPerson = world.People['sarah.connor@task-world.test'];
            Assert(!!alexPerson && !!sarahPerson, 'TSK-00 Alex and Sarah must exist');

            const alexUser = await ensureUIUserForPerson(ctx, alexPerson);
            const createdTaskIds: string[] = [];
            const createdNoteIds: string[] = [];
            const logIds: string[] = [];
            let createdMeetingId: string | null = null;
            const stamp = Date.now();

            try {
                // Seed an existing open task so Process Meeting Transcript deduplicates against it
                const existingTitle = `Finalize Acme Q4 Vendor Renewal Addendum ${stamp}`;
                const createExistingParams = [
                    inputParam('Name', existingTitle),
                    inputParam('Priority', 'High'),
                ];
                const existingRes = await runTypedAction(ctx, 'Create Task', alexUser, createExistingParams, logIds);
                Assert(existingRes.Success, `TCOS4 existing task creation failed: ${existingRes.Message}`);
                const existingTaskID = String(readOutParam(existingRes, createExistingParams, 'TaskID') ?? '');
                Assert(IsValidUUID(existingTaskID), 'TCOS4 existing TaskID valid');
                createdTaskIds.push(existingTaskID);

                // Create an ephemeral meeting organized by Alex starting 1 hour from now
                const startsAt = new Date(Date.now() + 60 * 60 * 1000);
                const endsAt = new Date(Date.now() + 2 * 60 * 60 * 1000);
                const meeting = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
                meeting.NewRecord();
                meeting.Name = `TCOS4 Executive Strategy Sync ${stamp}`;
                meeting.Description = 'Verify typed Meetings & Transcripts actions and 30-day dedup.';
                meeting.OrganizerPersonID = alexPerson.ID;
                meeting.StartsAt = startsAt;
                meeting.EndsAt = endsAt;
                meeting.TimeZone = 'America/Chicago';
                meeting.LocationType = 'Virtual';
                meeting.Visibility = 'Standard';
                meeting.Status = 'Scheduled';
                await RequireSave(meeting, 'TCOS4 meeting');
                createdMeetingId = meeting.ID;

                const attendee = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(
                    MEETING_ATTENDEE_ENTITY,
                    ctx.User,
                );
                attendee.NewRecord();
                attendee.MeetingID = meeting.ID;
                attendee.PersonID = sarahPerson.ID;
                attendee.Email = sarahPerson.Email;
                attendee.DisplayName = `${sarahPerson.FirstName} ${sarahPerson.LastName}`;
                attendee.Role = 'Required';
                attendee.ResponseStatus = 'Accepted';
                await RequireSave(attendee, 'TCOS4 attendee');

                // 1. Get My Upcoming Meetings
                const upcomingParams = [inputParam('DaysAhead', 7), inputParam('IncludePastHours', 4)];
                const upcomingRes = await runTypedAction(ctx, 'Get My Upcoming Meetings', alexUser, upcomingParams, logIds);
                Assert(upcomingRes.Success, `Get My Upcoming Meetings failed: ${upcomingRes.Message}`);
                const upcomingMeetings = JSON.parse(String(readOutParam(upcomingRes, upcomingParams, 'Meetings') ?? '[]')) as Array<{ ID: string }>;
                Assert(
                    upcomingMeetings.some((m) => UUIDsEqual(m.ID, meeting.ID)),
                    'Get My Upcoming Meetings includes ephemeral meeting',
                );

                // 1b. Get My Meetings Briefing includes ephemeral upcoming meeting
                const mBriefParams = [inputParam('HorizonDays', 7), inputParam('LookbackDays', 7)];
                const mBriefRes = await runTypedAction(ctx, 'Get My Meetings Briefing', alexUser, mBriefParams, logIds);
                Assert(mBriefRes.Success, `Get My Meetings Briefing failed: ${mBriefRes.Message}`);
                const mBriefing = JSON.parse(String(readOutParam(mBriefRes, mBriefParams, 'Briefing') ?? '{}')) as {
                    UpcomingMeetings?: Array<{ ID: string }>;
                };
                Assert(
                    (mBriefing.UpcomingMeetings ?? []).some((m) => UUIDsEqual(m.ID, meeting.ID)),
                    'Get My Meetings Briefing includes ephemeral upcoming meeting',
                );

                // 2. Prepare Meeting Brief
                const briefParams = [inputParam('MeetingID', meeting.ID)];
                const briefRes = await runTypedAction(ctx, 'Prepare Meeting Brief', alexUser, briefParams, logIds);
                Assert(briefRes.Success, `Prepare Meeting Brief failed: ${briefRes.Message}`);
                const brief = JSON.parse(String(readOutParam(briefRes, briefParams, 'Brief') ?? '{}')) as {
                    Meeting?: { ID: string };
                    Attendees?: Array<{ Email: string | null }>;
                };
                Assert(UUIDsEqual(brief.Meeting?.ID, meeting.ID), 'Prepare Meeting Brief targets meeting');
                Assert((brief.Attendees?.length ?? 0) >= 1, 'Prepare Meeting Brief includes attendees');

                // 3. Process Meeting Transcript (inline WebVTT with duplicate + novel commitment + decision)
                const vtt = [
                    'WEBVTT',
                    '',
                    '00:00:05.000 --> 00:00:20.000',
                    '<v Alex Chen>DECISION: We approved the Q4 rollout timeline for enterprise customers.</v>',
                    '',
                    '00:00:21.000 --> 00:00:40.000',
                    `<v Alex Chen>ACTION: ${existingTitle}</v>`,
                    '',
                    '00:00:41.000 --> 00:00:59.000',
                    `<v Sarah Connor>ACTION: Publish Partner Enablement Runbook ${stamp}</v>`,
                ].join('\n');

                const procParams = [
                    inputParam('MeetingID', meeting.ID),
                    inputParam('TranscriptText', vtt),
                    inputParam('WindowDays', 30),
                ];
                const procRes = await runTypedAction(ctx, 'Process Meeting Transcript', alexUser, procParams, logIds);
                Assert(procRes.Success, `Process Meeting Transcript failed: ${procRes.Message}`);
                AssertEqual(readOutParam(procRes, procParams, 'Status'), 'PROCESSED', 'Transcript status is PROCESSED');
                const noteID = String(readOutParam(procRes, procParams, 'NoteID') ?? '');
                Assert(IsValidUUID(noteID), 'Process Meeting Transcript created NoteID');
                createdNoteIds.push(noteID);

                const procPayload = JSON.parse(String(readOutParam(procRes, procParams, 'Result') ?? '{}')) as {
                    Decisions: string[];
                    MatchedExistingTasks: Array<{ ProposalID: string; MatchedTask: { TaskID: string } }>;
                    ProposedNewCommitments: Array<{ ProposalID: string; Title: string }>;
                };
                Assert(procPayload.Decisions.length >= 1, 'Extracted at least 1 decision');
                Assert(
                    procPayload.MatchedExistingTasks.some((m) => UUIDsEqual(m.MatchedTask.TaskID, existingTaskID)),
                    '30-day similarity dedup matched existing task instead of proposing a duplicate',
                );
                Assert(procPayload.ProposedNewCommitments.length >= 1, 'Proposed at least 1 novel commitment');

                // 4. Accept Meeting Commitments (links matched existing task + creates novel task)
                const matchedEntry = procPayload.MatchedExistingTasks.find((m) =>
                    UUIDsEqual(m.MatchedTask.TaskID, existingTaskID),
                )!;
                const acceptParams = [
                    inputParam('MeetingNoteID', noteID),
                    inputParam('ProposalIDs', procPayload.ProposedNewCommitments.map((p) => p.ProposalID).join(',')),
                    inputParam(
                        'LinkExistingMatches',
                        JSON.stringify([{ ProposalID: matchedEntry.ProposalID, ExistingTaskID: existingTaskID }]),
                    ),
                ];
                const acceptRes = await runTypedAction(ctx, 'Accept Meeting Commitments', alexUser, acceptParams, logIds);
                Assert(acceptRes.Success, `Accept Meeting Commitments failed: ${acceptRes.Message}`);
                const acceptedTasks = JSON.parse(String(readOutParam(acceptRes, acceptParams, 'AcceptedTasks') ?? '[]')) as Array<{ TaskID: string }>;
                const linkedTasks = JSON.parse(String(readOutParam(acceptRes, acceptParams, 'LinkedTasks') ?? '[]')) as Array<{ ExistingTaskID: string }>;
                for (const t of acceptedTasks) {
                    createdTaskIds.push(t.TaskID);
                }
                Assert(acceptedTasks.length >= 1, 'Accept Meeting Commitments created novel task');
                Assert(
                    linkedTasks.some((l) => UUIDsEqual(l.ExistingTaskID, existingTaskID)),
                    'Accept Meeting Commitments linked existing matched task without duplicating it',
                );

                // 5. Get Meeting Notes
                const notesParams = [inputParam('MeetingID', meeting.ID)];
                const notesRes = await runTypedAction(ctx, 'Get Meeting Notes', alexUser, notesParams, logIds);
                Assert(notesRes.Success, `Get Meeting Notes failed: ${notesRes.Message}`);
                const notesPayload = JSON.parse(String(readOutParam(notesRes, notesParams, 'MeetingNotes') ?? '{}')) as {
                    Notes?: Array<{ ID: string }>;
                    LinkedTasks?: Array<{ TaskID: string }>;
                };
                const notes = notesPayload.Notes ?? [];
                Assert(notes.some((n) => UUIDsEqual(n.ID, noteID)), 'Get Meeting Notes returned drafted transcript note');
                Assert(
                    (notesPayload.LinkedTasks ?? []).some((t) => UUIDsEqual(t.TaskID, existingTaskID)),
                    'Get Meeting Notes includes linked existing task',
                );
            } finally {
                // Clean up any novel task created during Accept Meeting Commitments even if a later step threw
                try {
                    const extraTasks = await FindRows<{ ID: string }>(
                        ctx,
                        TASK_ENTITY,
                        `Name LIKE '%${EscapeSQLString(String(stamp))}%'`,
                        ['ID'],
                    );
                    for (const t of extraTasks) {
                        if (!createdTaskIds.some((id) => UUIDsEqual(id, t.ID))) {
                            createdTaskIds.push(t.ID);
                        }
                    }
                } catch {
                    // Best-effort cleanup
                }
                for (const id of createdTaskIds) {
                    await deleteTaskCascade(ctx, id);
                }
                for (const nid of createdNoteIds) {
                    await deleteEntityById(ctx, MEETING_NOTE_ENTITY, nid);
                }
                if (createdMeetingId) {
                    const extraNotes = await FindRows<{ ID: string }>(
                        ctx,
                        MEETING_NOTE_ENTITY,
                        `MeetingID = '${EscapeSQLString(createdMeetingId)}'`,
                        ['ID'],
                    );
                    for (const n of extraNotes) {
                        await deleteEntityById(ctx, MEETING_NOTE_ENTITY, n.ID);
                    }
                    const attendees = await FindRows<{ ID: string }>(
                        ctx,
                        MEETING_ATTENDEE_ENTITY,
                        `MeetingID = '${EscapeSQLString(createdMeetingId)}'`,
                        ['ID'],
                    );
                    for (const a of attendees) {
                        await deleteEntityById(ctx, MEETING_ATTENDEE_ENTITY, a.ID);
                    }
                    await deleteEntityById(ctx, MEETING_ENTITY, createdMeetingId);
                }
                await cleanupActionLogs(ctx, logIds);
            }
        },
    },

    // =========================================================================
    // TCOS5: Governance & Metadata Integrity (3 Skills, 0 Raw CRUD, Params, Entity Doc, 3 Rhythms)
    // =========================================================================
    {
        Id: 'task-cos-typed-skills.TCOS5',
        Name: 'TCOS5 — Metadata governance: 3 CoS skills active, 0 raw SQL/CRUD actions, full MJ: Action Params, Search Entity Document, and 3 Rhythm Templates active',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const cosAgentId = await FindId(ctx, AI_AGENT_ENTITY, `Name = '${Quote(COS_AGENT_NAME)}'`);
            Assert(!!cosAgentId, `Agent '${COS_AGENT_NAME}' exists`);

            // 1. All 3 CoS skills active and granted to Chief of Staff
            const skillIn = EXPECTED_COS_SKILLS.map((n) => `'${Quote(n)}'`).join(', ');
            const skills = await FindRows<{ ID: string; Name: string; Status: string }>(
                ctx,
                AI_SKILL_ENTITY,
                `Name IN (${skillIn})`,
                ['ID', 'Name', 'Status'],
            );
            AssertEqual(skills.length, EXPECTED_COS_SKILLS.length, 'All 3 CoS Tasks skills exist');
            for (const skill of skills) {
                AssertEqual(skill.Status, 'Active', `Skill '${skill.Name}' is Active`);
                const grants = await FindRows<{ ID: string; Status: string }>(
                    ctx,
                    AI_AGENT_SKILL_ENTITY,
                    `AgentID = '${Quote(cosAgentId!)}' AND SkillID = '${Quote(skill.ID)}' AND Status = 'Active'`,
                    ['ID', 'Status'],
                );
                Assert(grants.length >= 1, `Skill '${skill.Name}' is actively granted to Chief of Staff`);
            }

            // 2. Inspect every action bound to the 3 skills: 0 raw SQL/CRUD & every action has MJ: Action Params
            const skillIdsIn = skills.map((s) => `'${Quote(s.ID)}'`).join(', ');
            const skillActions = await FindRows<{ ActionID: string; Role: string; ExposeToModel: boolean }>(
                ctx,
                AI_SKILL_ACTION_ENTITY,
                `SkillID IN (${skillIdsIn})`,
                ['ActionID', 'Role', 'ExposeToModel'],
            );
            Assert(skillActions.length >= 15, `Expected >= 15 typed actions across the 3 skills, found ${skillActions.length}`);

            const actionIds = Array.from(new Set(skillActions.map((sa) => sa.ActionID)));
            const actionIdsIn = actionIds.map((id) => `'${Quote(id)}'`).join(', ');
            const actions = await FindRows<{ ID: string; Name: string; Status: string }>(
                ctx,
                ACTION_ENTITY,
                `ID IN (${actionIdsIn})`,
                ['ID', 'Name', 'Status'],
            );
            for (const act of actions) {
                AssertEqual(act.Status, 'Active', `Skill action '${act.Name}' is Active`);
                Assert(
                    !FORBIDDEN_RAW_ACTIONS.has(act.Name.trim().toLowerCase()),
                    `Forbidden raw SQL/CRUD action '${act.Name}' must NEVER be attached to CoS Tasks skills`,
                );
            }

            const params = await FindRows<{ ActionID: string }>(
                ctx,
                ACTION_PARAM_ENTITY,
                `ActionID IN (${actionIdsIn})`,
                ['ActionID'],
            );
            for (const act of actions) {
                const count = params.filter((p) => UUIDsEqual(p.ActionID, act.ID)).length;
                Assert(count > 0, `Skill action '${act.Name}' must declare MJ: Action Params (found 0)`);
            }

            // 3. Tasks Search Entity Document is Active
            const docs = await FindRows<{ ID: string; Name: string; Status: string }>(
                ctx,
                ENTITY_DOCUMENT_ENTITY,
                `Name = 'BizApps Tasks Search'`,
                ['ID', 'Name', 'Status'],
            );
            Assert(docs.length === 1 && docs[0].Status === 'Active', 'BizApps Tasks Search Entity Document is Active');

            // 4. All 3 Rhythm Templates are Active
            const keyIn = EXPECTED_RHYTHM_KEYS.map((k) => `'${Quote(k)}'`).join(', ');
            const rhythms = await FindRows<{ ID: string; WorkstreamKey: string; Status: string }>(
                ctx,
                RHYTHM_TEMPLATE_ENTITY,
                `WorkstreamKey IN (${keyIn})`,
                ['ID', 'WorkstreamKey', 'Status'],
            );
            AssertEqual(rhythms.length, EXPECTED_RHYTHM_KEYS.length, 'All 3 Tasks Rhythm Templates exist');
            for (const r of rhythms) {
                AssertEqual(r.Status, 'Active', `Rhythm Template '${r.WorkstreamKey}' is Active`);
            }

            // 5. All 3 Briefing actions bound with Role = 'Briefing' and ExposeToModel = false
            for (const briefingActionName of [
                'Get My Tasks Briefing',
                'Get My Meetings Briefing',
                'Get My Work Reports Briefing',
            ]) {
                const links = await FindRows<{ Role: string; ExposeToModel: boolean }>(
                    ctx,
                    AI_SKILL_ACTION_ENTITY,
                    `ActionID IN (SELECT ID FROM [__mj].[vwActions] WHERE Name = '${Quote(briefingActionName)}')`,
                    ['Role', 'ExposeToModel'],
                );
                Assert(links.length >= 1, `${briefingActionName} must be bound to its CoS skill`);
                AssertEqual(links[0].Role, 'Briefing', `${briefingActionName} Role = 'Briefing'`);
                AssertEqual(links[0].ExposeToModel, false, `${briefingActionName} ExposeToModel = false`);
            }

            // 6. Canonical Agent Task (AGENT_TASK) Task Type exists with OnAssignActionID -> Execute Assigned Agent
            const agentTaskTypes = await FindRows<{ ID: string; Code: string; OnAssignActionID: string | null }>(
                ctx,
                TASK_TYPE_ENTITY,
                `Code = 'AGENT_TASK'`,
                ['ID', 'Code', 'OnAssignActionID'],
            );
            AssertEqual(agentTaskTypes.length, 1, 'Canonical Agent Task (AGENT_TASK) Task Type must exist');
            const executeAgentActionId = await FindId(ctx, ACTION_ENTITY, `Name = 'Execute Assigned Agent'`);
            Assert(!!executeAgentActionId, 'Execute Assigned Agent action must exist');
            Assert(
                UUIDsEqual(agentTaskTypes[0].OnAssignActionID, executeAgentActionId),
                'Agent Task OnAssignActionID must point to Execute Assigned Agent',
            );
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-cos-typed-skills', {
    Setup: async () => {},
    Teardown: async () => {},
});
export const TaskCosTypedSkillsChecks: NamedCheck[] = checks;
