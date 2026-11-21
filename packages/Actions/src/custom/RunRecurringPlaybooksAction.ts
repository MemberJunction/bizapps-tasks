import { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { RegisterClass } from '@memberjunction/global';
import {
    TasksRunRecurringPlaybooksOperation,
    type TemplateRoleAssignmentInput,
} from '@mj-biz-apps/tasks-core';
import {
    checkTypedPolicyGuard,
    failResult,
    TASKS_ENTITY,
} from './action-helpers.js';

const POLICY_CODE_PREFIX = /^\[(POLICY_DENIED|APPROVAL_REQUIRED|POLICY_DEFERRED)\]\s*/;

function extractPolicyResultCode(message: string | undefined, fallback: string): string {
    if (!message) return fallback;
    const match = POLICY_CODE_PREFIX.exec(message);
    return match ? match[1] : fallback;
}

/**
 * Action: `Run Recurring Playbooks` (`DriverClass: RunRecurringPlaybooksAction`).
 *
 * Thin MJ Action facade over the `BizAppsTasks.RunRecurringPlaybooks` Remotable Operation
 * so Flow Agents and MJ Scheduled Jobs can automatically roll out multi-entity playbooks
 * (such as Month-End or Quarter-End Financial Close) on schedule.
 */
@RegisterClass(BaseAction, 'RunRecurringPlaybooksAction')
export class RunRecurringPlaybooksAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) {
            return { Success: false, ResultCode: 'ERROR', Message: 'ContextUser is required' };
        }

        const templateID = readStringParam(params, 'TemplateID');
        const anchorDate = readStringParam(params, 'AnchorDate') ?? new Date().toISOString().slice(0, 10);
        const periodKey = readStringParam(params, 'PeriodKey') ?? anchorDate.slice(0, 7);
        const categoryID = readStringParam(params, 'CategoryID');
        const orgIdsRaw = readStringParam(params, 'OrganizationIDs');
        const allMirroredCompanies = readBoolParam(params, 'AllMirroredCompanies', !orgIdsRaw);
        const dryRun = readBoolParam(params, 'DryRun', false);
        const roleAssignmentsRaw = readStringParam(params, 'RoleAssignmentsJSON');

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: dryRun ? 'Read' : 'Create',
            actionName: 'Run Recurring Playbooks',
            isDestructive: !dryRun,
        });
        if (!guard.Allowed) {
            return guard.Failure ?? failResult('POLICY_DENIED', 'Blocked by agent user policy.', params);
        }

        if (!templateID) {
            return { Success: false, ResultCode: 'MISSING_PARAMS', Message: 'TemplateID is required' };
        }

        let organizationIDs: string[] | undefined;
        if (orgIdsRaw) {
            try {
                const parsed: string[] | string = JSON.parse(orgIdsRaw);
                organizationIDs = Array.isArray(parsed)
                    ? parsed.filter((v): v is string => typeof v === 'string' && v.trim().length > 0)
                    : orgIdsRaw.split(',').map((s) => s.trim()).filter(Boolean);
            } catch {
                organizationIDs = orgIdsRaw.split(',').map((s) => s.trim()).filter(Boolean);
            }
        }

        let roleAssignments: TemplateRoleAssignmentInput[] = [];
        if (roleAssignmentsRaw) {
            try {
                const parsed: TemplateRoleAssignmentInput[] = JSON.parse(roleAssignmentsRaw);
                if (Array.isArray(parsed)) {
                    roleAssignments = parsed;
                }
            } catch {
                return { Success: false, ResultCode: 'INVALID_PARAMS', Message: 'RoleAssignmentsJSON must be valid JSON array' };
            }
        }

        try {
            const result = await new TasksRunRecurringPlaybooksOperation().Execute(
                {
                    TemplateID: templateID,
                    AnchorDate: anchorDate,
                    PeriodKey: periodKey,
                    OrganizationIDs: organizationIDs,
                    AllMirroredCompanies: allMirroredCompanies,
                    CategoryID: categoryID,
                    RoleAssignments: roleAssignments,
                    DryRun: dryRun,
                },
                { user },
            );

            if (!result.Success || !result.Output) {
                const message = result.ErrorMessage ?? 'Recurring playbook execution failed';
                return {
                    Success: false,
                    ResultCode: extractPolicyResultCode(message, result.ResultCode ?? 'ERROR'),
                    Message: message,
                };
            }

            const output = result.Output;
            const outParams: ActionParam[] = [
                { Name: 'LaunchedCount', Value: output.LaunchedCount, Type: 'Output' },
                { Name: 'SkippedCount', Value: output.SkippedCount, Type: 'Output' },
                { Name: 'FailedCount', Value: output.FailedCount, Type: 'Output' },
                { Name: 'TotalTasksCreated', Value: output.TotalTasksCreated, Type: 'Output' },
                { Name: 'ResultJSON', Value: JSON.stringify(output), Type: 'Output' },
            ];
            params.Params.push(...outParams);

            return {
                Success: output.FailedCount === 0,
                ResultCode: output.FailedCount === 0 ? 'SUCCESS' : 'PARTIAL_FAILURE',
                Message: `Recurring playbook '${periodKey}': ${output.LaunchedCount} launched (${output.TotalTasksCreated} tasks), ${output.SkippedCount} skipped, ${output.FailedCount} failed.`,
            };
        } catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                ResultCode: extractPolicyResultCode(message, 'ERROR'),
                Message: message,
            };
        }
    }
}

function readStringParam(params: RunActionParams, name: string): string | null {
    const p = params.Params.find((item) => item.Name.toLowerCase() === name.toLowerCase());
    if (p?.Value == null) return null;
    const str = String(p.Value).trim();
    return str.length > 0 ? str : null;
}

function readBoolParam(params: RunActionParams, name: string, fallback: boolean): boolean {
    const raw = readStringParam(params, name);
    if (raw == null) return fallback;
    return raw.toLowerCase() === 'true' || raw === '1';
}
