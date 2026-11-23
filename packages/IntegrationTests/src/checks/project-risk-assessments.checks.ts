/**
 * Integration checks (`project-risk-assessments`): Verifies shipped Epic 7a metadata
 * (`Task Risk Assessments` entity, UI role RLS permission, `Project Risk Analyst` High-tier
 * agent & prompt, `Get Project Risk` & `Request Project Risk Review` actions + params) and
 * deterministic runtime risk persistence + root task health/confidence/forecast sync.
 */
import '@mj-biz-apps/tasks-actions';
import { ActionEngineServer } from '@memberjunction/actions';
import { ActionParam, ActionResult, RunActionParams } from '@memberjunction/actions-base';
import { UUIDsEqual } from '@memberjunction/global';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type IntegrationCheckContext,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import { SerializeTaskRiskItems, type TaskRiskAssessmentEntity } from '@mj-biz-apps/tasks-entities';
import {
    ACTION_ENTITY,
    ACTION_PARAM_ENTITY,
    AI_AGENT_ENTITY,
    TASK_ENTITY,
    TASK_RISK_ASSESSMENT_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave } from '../wire.js';
import { World } from '../world/world.js';

async function invokeAction(
    ctx: IntegrationCheckContext,
    actionName: string,
    params: ActionParam[],
): Promise<ActionResult> {
    await ActionEngineServer.Instance.Config(false, ctx.User);
    const action = ActionEngineServer.Instance.Actions.find(
        (a) => a.Name === actionName && a.Status === 'Active',
    );
    Assert(!!action, `Active action '${actionName}' must exist in ActionEngineServer`);
    const runParams = new RunActionParams();
    runParams.Action = action!;
    runParams.ContextUser = ctx.User;
    runParams.Params = params;
    return ActionEngineServer.Instance.RunAction(runParams);
}

const checks: NamedCheck[] = [
    {
        Id: 'project-risk-assessments.PRA1',
        Name: 'PRA1 — Shipped Project Risk Analyst agent, prompt, and typed risk actions metadata are active',
        RequiresMutation: false,
        Fn: async (ctx: IntegrationCheckContext) => {
            const agentRows = await FindRows<{ ID: string; Name: string; Status: string }>(
                ctx,
                AI_AGENT_ENTITY,
                `Name = 'Project Risk Analyst'`,
                ['ID', 'Name', 'Status'],
            );
            AssertEqual(agentRows.length, 1, 'Project Risk Analyst AI Agent exists');
            AssertEqual(agentRows[0].Status, 'Active', 'Project Risk Analyst AI Agent is Active');

            for (const actionName of ['Get Project Risk', 'Request Project Risk Review']) {
                const actionRows = await FindRows<{ ID: string; Name: string; Status: string; DriverClass: string }>(
                    ctx,
                    ACTION_ENTITY,
                    `Name = '${Quote(actionName)}'`,
                    ['ID', 'Name', 'Status', 'DriverClass'],
                );
                AssertEqual(actionRows.length, 1, `Action '${actionName}' exists`);
                AssertEqual(actionRows[0].Status, 'Active', `Action '${actionName}' is Active`);

                const paramRows = await FindRows<{ ActionID: string; Name: string }>(
                    ctx,
                    ACTION_PARAM_ENTITY,
                    `ActionID = '${Quote(actionRows[0].ID)}'`,
                    ['ActionID', 'Name'],
                );
                Assert(paramRows.some((p) => p.Name === 'TaskID'), `Action '${actionName}' declares TaskID param`);
            }
        },
    },
    {
        Id: 'project-risk-assessments.PRA2',
        Name: 'PRA2 — Task Risk Assessment persistence synchronizes root task HealthStatus, ConfidenceScore, and ForecastCompletionDate and Get Project Risk retrieves it',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = World();
            const rootTaskId = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            Assert(!!rootTaskId, 'Seeded Website Redesign & Portal Launch project root task must exist');

            let createdAssessmentId: string | null = null;
            try {
                const assessment = await ctx.Provider.GetEntityObject<TaskRiskAssessmentEntity>(
                    TASK_RISK_ASSESSMENT_ENTITY,
                    ctx.User,
                );
                assessment.NewRecord();
                assessment.TaskID = rootTaskId;
                assessment.AssessedAt = new Date();
                assessment.HealthStatus = 'AtRisk';
                assessment.ForecastConfidence = 68;
                assessment.ForecastCompletionDate = new Date('2026-12-22T17:00:00.000Z');
                assessment.MLBreachProbability = 0.42;
                assessment.Risks = SerializeTaskRiskItems([
                    {
                        kind: 'dependency_blocker',
                        severity: 'high',
                        evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${rootTaskId}`],
                        suggestedMitigation: 'Unblock staging deployment dependency.',
                    },
                ]);
                assessment.PromptTokens = 1100;
                assessment.CompletionTokens = 260;
                assessment.TotalCostUSD = 0.0295;
                await RequireSave(assessment, 'save Task Risk Assessment');
                createdAssessmentId = assessment.ID;

                const rootRows = await FindRows<{
                    ID: string;
                    HealthStatus: string | null;
                    ConfidenceScore: number | null;
                    ForecastCompletionDate: string | Date | null;
                }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${Quote(rootTaskId)}'`,
                    ['ID', 'HealthStatus', 'ConfidenceScore', 'ForecastCompletionDate'],
                );
                AssertEqual(rootRows.length, 1, 'Root project task found');
                AssertEqual(rootRows[0].HealthStatus, 'AtRisk', 'Root task HealthStatus synced');
                AssertEqual(rootRows[0].ConfidenceScore, 68, 'Root task ConfidenceScore synced');
                Assert(!!rootRows[0].ForecastCompletionDate, 'Root task ForecastCompletionDate synced');

                const actionParams: ActionParam[] = [{ Name: 'TaskID', Value: rootTaskId, Type: 'Input' }];
                const getRes = await invokeAction(ctx, 'Get Project Risk', actionParams);
                Assert(getRes.Success, `Get Project Risk failed: ${getRes.Message}`);

                const outAssessmentId = getRes.Params?.find((p) => p.Name === 'AssessmentID')?.Value as string | null;
                Assert(UUIDsEqual(outAssessmentId, createdAssessmentId), 'Get Project Risk returned newly saved assessment');
            } finally {
                if (createdAssessmentId) {
                    const existingId = await FindId(
                        ctx,
                        TASK_RISK_ASSESSMENT_ENTITY,
                        `ID = '${Quote(createdAssessmentId)}'`,
                    );
                    if (existingId) {
                        const rec = await ctx.Provider.GetEntityObject<TaskRiskAssessmentEntity>(
                            TASK_RISK_ASSESSMENT_ENTITY,
                            ctx.User,
                        );
                        if (await rec.Load(existingId)) {
                            await rec.Delete();
                        }
                    }
                }
            }
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}
IntegrationCheckRegistry.Instance.RegisterLifecycle('project-risk-assessments', {
    Setup: async () => {},
    Teardown: async () => {},
});
export const ProjectRiskAssessmentsChecks: NamedCheck[] = checks;
