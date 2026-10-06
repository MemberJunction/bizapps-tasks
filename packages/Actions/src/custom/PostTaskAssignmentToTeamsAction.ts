import { RunView, UserInfo } from '@memberjunction/core';
import { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { CredentialEngine } from '@memberjunction/credentials';
import { RegisterClass } from '@memberjunction/global';
import {
    BuildAssignmentCardPayload,
    BuildTaskLink,
    IsSupportedTeamsWebhookURL,
    TEAMS_WEBHOOK_CREDENTIAL_TYPE,
    TeamsWebhookCredentialValues,
} from './teams-assignment-card.js';

type TaskTypeRow = { ID: string; Name: string; Code: string | null };

/**
 * Action: Tasks.PostAssignmentToTeams
 *
 * Wired as a Task Type's OnAssign action. Posts a card naming the task and its assignee to the
 * Teams channel whose webhook is held in a {@link TEAMS_WEBHOOK_CREDENTIAL_TYPE} credential:
 * the one named `CredentialName` when given, else the one named after the task type's Code,
 * else the credential type's default. The URL lives in a credential because it carries a
 * signature that grants posting rights.
 */
@RegisterClass(BaseAction, 'Tasks.PostAssignmentToTeams')
export class PostTaskAssignmentToTeamsAction extends BaseAction {
    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return fail('ERROR', 'ContextUser is required');

        const taskID = paramValue(params, 'TaskID');
        const taskName = paramValue(params, 'TaskName');
        if (!taskID || !taskName) return fail('MISSING_TASK', 'TaskID and TaskName are required');

        const taskType = await loadTaskType(paramValue(params, 'TaskTypeID'), user);
        const credential = await resolveWebhookCredential(paramValue(params, 'CredentialName') ?? taskType?.Code ?? null, user);
        if (!credential) {
            return fail('MISSING_CREDENTIAL', `No "${TEAMS_WEBHOOK_CREDENTIAL_TYPE}" credential found for task type ${taskType?.Code ?? '(none)'}`);
        }
        if (!IsSupportedTeamsWebhookURL(credential.webhookUrl)) {
            return fail('INVALID_WEBHOOK_URL', 'The credential\'s webhookUrl is not an https Teams or Power Automate webhook URL');
        }

        const payload = BuildAssignmentCardPayload({
            TaskName: taskName,
            TaskTypeName: taskType?.Name ?? null,
            AssigneeName: paramValue(params, 'AssigneeName'),
            TaskLink: BuildTaskLink(credential.explorerUrl, taskID),
        });
        return postToTeams(credential.webhookUrl, payload);
    }
}

function paramValue(params: RunActionParams, name: string): string | null {
    const value = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase())?.Value;
    return typeof value === 'string' && value.trim() ? value : null;
}

function fail(resultCode: string, message: string): ActionResultSimple {
    return { Success: false, ResultCode: resultCode, Message: message };
}

async function loadTaskType(taskTypeID: string | null, user: UserInfo): Promise<TaskTypeRow | null> {
    if (!taskTypeID) return null;
    const result = await new RunView().RunView<TaskTypeRow>({
        EntityName: 'MJ_BizApps_Tasks: Task Types',
        ExtraFilter: `ID = '${taskTypeID}'`,
        Fields: ['ID', 'Name', 'Code'],
        ResultType: 'simple',
        MaxRows: 1,
    }, user);
    return result?.Success ? result.Results?.[0] ?? null : null;
}

/** The named credential of the webhook type, falling back to the type's default credential. */
async function resolveWebhookCredential(name: string | null, user: UserInfo): Promise<TeamsWebhookCredentialValues | null> {
    const engine = CredentialEngine.Instance;
    await engine.Config(false, user);
    const credential = (name ? engine.getCredentialByName(TEAMS_WEBHOOK_CREDENTIAL_TYPE, name) : undefined)
        ?? engine.getDefaultCredentialForType(TEAMS_WEBHOOK_CREDENTIAL_TYPE);
    if (!credential) return null;
    const resolved = await engine.getCredential<TeamsWebhookCredentialValues>(credential.Name, {
        credentialId: credential.ID,
        contextUser: user,
        subsystem: 'BizApps Tasks',
    });
    return resolved.values?.webhookUrl ? resolved.values : null;
}

async function postToTeams(webhookUrl: string, payload: Record<string, unknown>): Promise<ActionResultSimple> {
    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        });
        if (response.ok) return { Success: true, ResultCode: 'SUCCESS', Message: 'Posted to Teams' };
        // The URL carries a signature, so it never goes into the message.
        const detail = (await response.text()).slice(0, 300);
        return fail('TEAMS_ERROR', `Teams webhook returned HTTP ${response.status}: ${detail}`);
    } catch (err) {
        return fail('TEAMS_ERROR', `Teams webhook request failed: ${err instanceof Error ? err.message : String(err)}`);
    }
}
