import { describe, expect, it } from 'vitest';
import {
    DEFAULT_WORKFLOW_OUTPUT_KEY,
    DEFAULT_WORKFLOW_TASK_TYPE,
    ResolveWorkflowTaskRequest,
    WORKFLOW_ASSIGNEE_PEOPLE_ENTITY,
    WORKFLOW_ASSIGNEE_USERS_ENTITY,
    WorkflowOutputKey,
    type WorkflowTaskRequestInput,
} from '../workflow-task-request.js';

const ANA = 'B0000000-0000-0000-0000-000000000001';
const BEN = 'B0000000-0000-0000-0000-000000000002';
const STEP_USER = 'C0000000-0000-0000-0000-000000000001';
const VERSION = 'D0000000-0000-0000-0000-000000000001';

function input(config: Record<string, unknown>, payload: Record<string, unknown> = {}, assignedUserID: string | null = null): WorkflowTaskRequestInput {
    return {
        Name: 'Approve the form',
        Instructions: 'Check the questions read well.',
        DueAt: null,
        AssignedUserID: assignedUserID,
        ProviderConfiguration: config,
        Payload: payload,
    };
}

function request(config: Record<string, unknown>, payload: Record<string, unknown> = {}, assignedUserID: string | null = null) {
    const result = ResolveWorkflowTaskRequest(input(config, payload, assignedUserID));
    if ('Error' in result) throw new Error(`expected a request, got: ${result.Error}`);
    return result.Request;
}

function refusal(config: Record<string, unknown>, payload: Record<string, unknown> = {}): string {
    const result = ResolveWorkflowTaskRequest(input(config, payload));
    if (!('Error' in result)) throw new Error('expected a refusal');
    return result.Error;
}

describe('ResolveWorkflowTaskRequest', () => {
    it('defaults to an approval request named after the step, at High priority', () => {
        const r = request({ approverPersonIDs: ANA });
        expect(r.TaskType).toBe(DEFAULT_WORKFLOW_TASK_TYPE);
        expect(r.Title).toBe('Approve the form');
        expect(r.Description).toBe('Check the questions read well.');
        expect(r.Priority).toBe('High');
        expect(r.Assignees).toEqual([{ EntityName: WORKFLOW_ASSIGNEE_PEOPLE_ENTITY, RecordID: ANA }]);
        expect(r.LinkedRecord).toBeNull();
    });

    it('reads approvers, the linked record and the title from the payload', () => {
        const r = request(
            {
                approverPersonIDs: 'payload.review.approvers',
                linkedRecord: { entity: 'MJ_BizApps_Forms: Form Versions', recordID: 'payload.versionID' },
                title: 'payload.review.title',
            },
            { review: { approvers: [ANA, BEN], title: 'Publish "Intake" v3' }, versionID: VERSION },
        );
        expect(r.Assignees.map((a) => a.RecordID)).toEqual([ANA, BEN]);
        expect(r.LinkedRecord).toEqual({ EntityName: 'MJ_BizApps_Forms: Form Versions', RecordID: VERSION });
        expect(r.Title).toBe('Publish "Intake" v3');
    });

    it('treats a string without the payload. prefix as a literal', () => {
        expect(request({ approverPersonIDs: ANA, title: 'review.title' }).Title).toBe('review.title');
    });

    it('takes explicit assignees of any entity and drops duplicates, whatever their case', () => {
        const r = request({
            approverPersonIDs: [ANA],
            assignees: [
                { entity: WORKFLOW_ASSIGNEE_PEOPLE_ENTITY, recordID: ANA.toLowerCase() },
                { entity: 'MJ: Roles', recordID: 'payload.roleID' },
            ],
        }, { roleID: BEN });
        expect(r.Assignees).toEqual([
            { EntityName: WORKFLOW_ASSIGNEE_PEOPLE_ENTITY, RecordID: ANA },
            { EntityName: 'MJ: Roles', RecordID: BEN },
        ]);
    });

    it("falls back to the step's own assignee only when nothing else names one", () => {
        expect(request({}, {}, STEP_USER).Assignees).toEqual([{ EntityName: WORKFLOW_ASSIGNEE_USERS_ENTITY, RecordID: STEP_USER }]);
        expect(request({ approverPersonIDs: ANA }, {}, STEP_USER).Assignees).toHaveLength(1);
    });

    it('refuses a step that names no one', () => {
        expect(refusal({})).toMatch(/names no one to ask/);
        expect(refusal({ approverPersonIDs: 'payload.missing' })).toMatch(/names no one to ask/);
    });

    it('refuses settings it cannot use, naming the setting', () => {
        expect(refusal({ approverPersonIDs: ANA, priority: 'Urgent' })).toMatch(/priority must be one of/);
        expect(refusal({ approverPersonIDs: [ANA, { id: BEN }] })).toMatch(/approverPersonIDs must hold IDs/);
        expect(refusal({ assignees: 'everyone' })).toMatch(/assignees must be a list/);
        expect(refusal({ assignees: [{ recordID: ANA }] })).toMatch(/assignees\[0\] needs an entity/);
        expect(refusal({ assignees: [{ entity: 'MJ: Users', recordID: 'payload.nobody' }] })).toMatch(/assignees\[0\]\.recordID resolved to nothing/);
        expect(refusal({ approverPersonIDs: ANA, linkedRecord: { entity: 'X', recordID: 'payload.none' } })).toMatch(/linkedRecord\.recordID resolved to nothing/);
    });

    it('accepts priority in any case', () => {
        expect(request({ approverPersonIDs: ANA, priority: 'critical' }).Priority).toBe('Critical');
    });
});

describe('WorkflowOutputKey', () => {
    it('defaults to approval and honours outputKey', () => {
        expect(WorkflowOutputKey(undefined)).toBe(DEFAULT_WORKFLOW_OUTPUT_KEY);
        expect(WorkflowOutputKey({ outputKey: ' legalReview ' })).toBe('legalReview');
        expect(WorkflowOutputKey({ outputKey: '' })).toBe(DEFAULT_WORKFLOW_OUTPUT_KEY);
    });
});
