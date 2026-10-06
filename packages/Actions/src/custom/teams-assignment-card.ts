/**
 * Pure helpers for posting a task assignment to a Microsoft Teams channel. Kept free of MJ
 * runtime imports so they can be unit tested directly.
 */

/** Credential type holding a Teams channel's webhook URL. Shipped in this repo's metadata. */
export const TEAMS_WEBHOOK_CREDENTIAL_TYPE = 'Teams Channel Webhook';

/** Fields of a {@link TEAMS_WEBHOOK_CREDENTIAL_TYPE} credential. */
export type TeamsWebhookCredentialValues = {
    /** The channel's incoming webhook URL. */
    webhookUrl: string;
    /** Explorer base URL, used to link the card to the task. Optional. */
    explorerUrl?: string;
};

/**
 * Hosts a Teams channel webhook may live on: Office 365 connector webhooks, and the Power
 * Automate Workflows webhooks that replace them.
 */
const TEAMS_WEBHOOK_HOST_SUFFIXES = ['.webhook.office.com', '.environment.api.powerplatform.com', '.logic.azure.com'];

/** True when `url` is an https URL on a Teams connector or Power Automate Workflows host. */
export function IsSupportedTeamsWebhookURL(url: string): boolean {
    let parsed: URL;
    try {
        parsed = new URL(url);
    } catch {
        return false;
    }
    if (parsed.protocol !== 'https:') return false;
    const host = parsed.hostname.toLowerCase();
    return TEAMS_WEBHOOK_HOST_SUFFIXES.some((suffix) => host.endsWith(suffix));
}

/** Explorer link to a task record, or null when no Explorer base URL is configured. */
export function BuildTaskLink(explorerUrl: string | undefined, taskID: string): string | null {
    const base = explorerUrl?.trim().replace(/\/+$/, '');
    if (!base) return null;
    return `${base}/resource/record/${encodeURIComponent('MJ_BizApps_Tasks: Tasks')}/${encodeURIComponent(taskID)}`;
}

/** What the card says about the assignment. */
export type AssignmentCardInput = {
    TaskName: string;
    TaskTypeName: string | null;
    AssigneeName: string | null;
    TaskLink: string | null;
};

/**
 * Teams message payload carrying an Adaptive Card. Both connector and Workflows webhooks
 * accept this `message` + `attachments` shape.
 */
export function BuildAssignmentCardPayload(input: AssignmentCardInput): Record<string, unknown> {
    const heading = input.TaskTypeName ? `New ${input.TaskTypeName.toLowerCase()}` : 'New task assigned';
    const facts = [
        { title: 'Task', value: input.TaskName },
        ...(input.AssigneeName ? [{ title: 'Assigned to', value: input.AssigneeName }] : []),
    ];
    const card: Record<string, unknown> = {
        $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
        type: 'AdaptiveCard',
        version: '1.4',
        body: [
            { type: 'TextBlock', text: heading, weight: 'Bolder', size: 'Medium', wrap: true },
            { type: 'FactSet', facts },
        ],
        ...(input.TaskLink ? { actions: [{ type: 'Action.OpenUrl', title: 'Open task', url: input.TaskLink }] } : {}),
    };
    return {
        type: 'message',
        attachments: [{ contentType: 'application/vnd.microsoft.card.adaptive', contentUrl: null, content: card }],
    };
}
