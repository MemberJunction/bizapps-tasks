import { describe, it, expect } from 'vitest';
import { BuildAssignmentCardPayload, BuildTaskLink, EscapeTeamsMarkdown, IsSupportedTeamsWebhookURL } from '../custom/teams-assignment-card.js';

type Card = { body: Array<{ type: string; text?: string; facts?: Array<{ title: string; value: string }> }>; actions?: Array<{ url: string }> };
const cardOf = (payload: Record<string, unknown>): Card =>
    (payload.attachments as Array<{ content: Card }>)[0].content;

describe('IsSupportedTeamsWebhookURL', () => {
    it('accepts Office 365 connector webhooks', () => {
        expect(IsSupportedTeamsWebhookURL('https://contoso.webhook.office.com/webhookb2/abc')).toBe(true);
    });

    it('accepts Power Automate Workflows webhooks', () => {
        expect(IsSupportedTeamsWebhookURL('https://default0000.b1.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/x/triggers/manual/paths/invoke?sig=y')).toBe(true);
        expect(IsSupportedTeamsWebhookURL('https://prod-01.westus.logic.azure.com/workflows/x/triggers/manual/paths/invoke')).toBe(true);
    });

    it('rejects plain http, other hosts, look-alike hosts and junk', () => {
        expect(IsSupportedTeamsWebhookURL('http://contoso.webhook.office.com/webhookb2/abc')).toBe(false);
        expect(IsSupportedTeamsWebhookURL('https://example.com/hook')).toBe(false);
        expect(IsSupportedTeamsWebhookURL('https://webhook.office.com.example.com/x')).toBe(false);
        expect(IsSupportedTeamsWebhookURL('not a url')).toBe(false);
    });
});

describe('BuildTaskLink', () => {
    it('links to the task record under the Explorer base URL', () => {
        expect(BuildTaskLink('https://app.example.com/', 'ABC-1')).toBe(
            'https://app.example.com/resource/record/MJ_BizApps_Tasks%3A%20Tasks/ABC-1',
        );
    });

    it('returns null without a base URL', () => {
        expect(BuildTaskLink(undefined, 'ABC-1')).toBeNull();
        expect(BuildTaskLink('  ', 'ABC-1')).toBeNull();
    });
});

describe('BuildAssignmentCardPayload', () => {
    it('builds a message with an Adaptive Card naming the task type, task and assignee', () => {
        const payload = BuildAssignmentCardPayload({
            TaskName: 'Approve discount',
            TaskTypeName: 'Concession Approval',
            AssigneeName: 'Pat Doe',
            TaskLink: 'https://app.example.com/resource/record/x/1',
        });
        expect(payload.type).toBe('message');
        const card = cardOf(payload);
        expect(card.body[0].text).toBe('New concession approval');
        expect(card.body[1].facts).toEqual([
            { title: 'Task', value: 'Approve discount' },
            { title: 'Assigned to', value: 'Pat Doe' },
        ]);
        expect(card.actions?.[0].url).toBe('https://app.example.com/resource/record/x/1');
    });

    it('omits the assignee fact and the link button when unknown', () => {
        const card = cardOf(BuildAssignmentCardPayload({ TaskName: 'T', TaskTypeName: null, AssigneeName: null, TaskLink: null }));
        expect(card.body[0].text).toBe('New task assigned');
        expect(card.body[1].facts).toEqual([{ title: 'Task', value: 'T' }]);
        expect(card.actions).toBeUndefined();
    });
});

describe('EscapeTeamsMarkdown', () => {
    it('escapes link and emphasis characters so names show as typed', () => {
        expect(EscapeTeamsMarkdown('[click](http://evil)')).toBe('\\[click\\](http://evil)');
        expect(EscapeTeamsMarkdown('*bold* _it_ a\\b')).toBe('\\*bold\\* \\_it\\_ a\\\\b');
        expect(EscapeTeamsMarkdown('Pat Doe-Smith')).toBe('Pat Doe-Smith');
    });

    it('is applied to the task and assignee names on the card', () => {
        const card = cardOf(BuildAssignmentCardPayload({ TaskName: '[click](http://evil)', TaskTypeName: null, AssigneeName: '*Pat*', TaskLink: null }));
        const facts = card.body.find((b) => b.type === 'FactSet')!.facts!;
        expect(facts).toEqual([
            { title: 'Task', value: '\\[click\\](http://evil)' },
            { title: 'Assigned to', value: '\\*Pat\\*' },
        ]);
    });
});
