import { beforeEach, describe, expect, it, vi } from 'vitest';

const STEP_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const FORM_VERSION_ENTITY_ID = 'A0000000-0000-0000-0000-000000000002';
const STEP_ID = 'C0000000-0000-0000-0000-000000000001';
const AGENT_REQUEST_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    UUIDsEqual: (a: string, b: string) => a.toLowerCase() === b.toLowerCase(),
}));

vi.mock('@memberjunction/core', () => {
    class ValidationResult { Success = true; Errors: Array<{ Message: string }> = []; }
    class ValidationErrorInfo { constructor(public Source: string, public Message: string, public Value: unknown) {} }
    return {
        BaseEntity: class {},
        ValidationResult,
        ValidationErrorInfo,
        ValidationErrorType: { Failure: 'Failure' },
        Metadata: {
            Provider: {
                EntityByName: (n: string) =>
                    n === 'MJ: Tasks' ? { ID: STEP_ENTITY_ID } : n === 'MJ: AI Agent Requests' ? { ID: AGENT_REQUEST_ENTITY_ID } : undefined,
            },
        },
    };
});

/** The generated base class, reduced to what the guard reads. */
vi.mock('@mj-biz-apps/tasks-entities', async () => {
    const { ValidationResult } = await import('@memberjunction/core');
    class FakeTaskLink {
        public EntityID = '';
        public RecordID = '';
        public IsSaved = false;
        public Original: { EntityID: string; RecordID: string } | null = null;
        public SaveCalls = 0;
        public GetFieldByName(name: 'EntityID' | 'RecordID') {
            const current = this[name];
            const old = this.Original?.[name] ?? null;
            return { Dirty: this.IsSaved && old !== current, OldValue: old };
        }
        public Validate() { return new ValidationResult(); }
        public async Save(): Promise<boolean> {
            this.SaveCalls++;
            return this.Validate().Success;
        }
    }
    return { mjBizAppsTasksTaskLinkEntity: FakeTaskLink };
});

import { TaskLinkEntityServer } from '../TaskLinkEntityServer.js';

type Testable = TaskLinkEntityServer & { IsSaved: boolean; Original: { EntityID: string; RecordID: string } | null };

function newLink(entityID: string, recordID: string): Testable {
    const link = new TaskLinkEntityServer() as Testable;
    link.EntityID = entityID;
    link.RecordID = recordID;
    return link;
}

function savedLink(entityID: string, recordID: string): Testable {
    const link = newLink(entityID, recordID);
    link.IsSaved = true;
    link.Original = { EntityID: entityID, RecordID: recordID };
    return link;
}

describe('TaskLinkEntityServer', () => {
    let link: Testable;
    beforeEach(() => { link = newLink(STEP_ENTITY_ID, STEP_ID); });

    it('refuses creating a link to a workflow step without the provider authorizing it', () => {
        const result = link.Validate();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/only by the workflow or agent that raised it/);
    });

    it('accepts the link the provider authorized, for one save only', async () => {
        link.AuthorizeHumanAskLink();
        expect(await link.Save()).toBe(true);
        expect(link.Validate().Success).toBe(false);
    });

    it('leaves links to any other entity alone', () => {
        expect(newLink(FORM_VERSION_ENTITY_ID, STEP_ID).Validate().Success).toBe(true);
        expect(newLink(STEP_ENTITY_ID.toLowerCase(), STEP_ID).Validate().Success).toBe(false);
    });

    it('refuses pointing an existing link at a different step, or onto or off a workflow step', () => {
        const repointed = savedLink(STEP_ENTITY_ID, STEP_ID);
        repointed.RecordID = 'C0000000-0000-0000-0000-000000000009';
        expect(repointed.Validate().Success).toBe(false);

        const moved = savedLink(FORM_VERSION_ENTITY_ID, STEP_ID);
        moved.EntityID = STEP_ENTITY_ID;
        expect(moved.Validate().Success).toBe(false);

        const movedOff = savedLink(STEP_ENTITY_ID, STEP_ID);
        movedOff.EntityID = FORM_VERSION_ENTITY_ID;
        expect(movedOff.Validate().Success).toBe(false);
    });

    it('guards links to an agent request the same way', async () => {
        const toRequest = newLink(AGENT_REQUEST_ENTITY_ID, STEP_ID);
        expect(toRequest.Validate().Success).toBe(false);
        toRequest.AuthorizeHumanAskLink();
        expect(await toRequest.Save()).toBe(true);

        const movedOnto = savedLink(FORM_VERSION_ENTITY_ID, STEP_ID);
        movedOnto.EntityID = AGENT_REQUEST_ENTITY_ID;
        expect(movedOnto.Validate().Success).toBe(false);
    });

    it('lets an existing workflow link be saved when neither end changes', () => {
        expect(savedLink(STEP_ENTITY_ID, STEP_ID).Validate().Success).toBe(true);
    });
});
