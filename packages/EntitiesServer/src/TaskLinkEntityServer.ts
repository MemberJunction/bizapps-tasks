/**
 * Server-side subclass of TaskLink — guards the links that tie a task to a human ask: a workflow
 * step, or an agent's question.
 *
 * The `BizAppsTasks` human-task provider (`@mj-biz-apps/tasks-server`) puts a workflow's Human step,
 * or an agent's question, in front of people as a bizapps-tasks task. It links the task to the step's
 * `MJ: Tasks` row or to the `MJ: AI Agent Requests` row, and deciding the task answers that ask: it
 * completes the step as the system user, or answers the request as its owner, which resumes the
 * agent. That makes the link a capability: whoever can create one can answer any open ask by deciding
 * a task of their own. So only the provider may create such a link, and nobody may move an existing
 * link onto or off one of those entities.
 *
 * Links to any other entity are unaffected.
 */
import { BaseEntity, EntitySaveOptions, Metadata, ValidationErrorInfo, ValidationErrorType, ValidationResult } from '@memberjunction/core';
import { RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { mjBizAppsTasksTaskLinkEntity } from '@mj-biz-apps/tasks-entities';

export const TASK_LINK_ENTITY = 'MJ_BizApps_Tasks: Task Links';

/** The entity a workflow step lives in. A link to it is what lets a task complete the step. */
export const WORKFLOW_STEP_ENTITY = 'MJ: Tasks';

/** The entity an agent's question lives in. A link to it is what lets a task answer the question. */
export const AGENT_REQUEST_ENTITY = 'MJ: AI Agent Requests';

/** The entities a link to which answers an ask. */
const HUMAN_ASK_ENTITIES = [WORKFLOW_STEP_ENTITY, AGENT_REQUEST_ENTITY];

const REFUSAL =
    'A task can be linked to a workflow step or an agent request only by the workflow or agent that raised it. ' +
    'Decide the task it raised instead of linking another one.';

@RegisterClass(BaseEntity, TASK_LINK_ENTITY)
export class TaskLinkEntityServer extends mjBizAppsTasksTaskLinkEntity {
    private askLinkAuthorized = false;

    /**
     * Allows the next save to create a link to a workflow step or an agent request. Called only by
     * the `BizAppsTasks` human-task provider, on a link it is creating for an ask it was asked to raise.
     */
    public AuthorizeHumanAskLink(): void {
        this.askLinkAuthorized = true;
    }

    public override Validate(): ValidationResult {
        const result = super.Validate();
        if (this.touchesHumanAsk() && !this.askLinkAuthorized) {
            result.Errors.push(new ValidationErrorInfo('EntityID', REFUSAL, this.EntityID, ValidationErrorType.Failure));
            result.Success = false;
        }
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        try {
            return await super.Save(options);
        } finally {
            // Authorizes one save, never a later one made through the same object.
            this.askLinkAuthorized = false;
        }
    }

    /** Whether this save creates a link to an ask, or moves one onto or off an ask's entity. */
    private touchesHumanAsk(): boolean {
        const askEntityIDs = HUMAN_ASK_ENTITIES
            .map((name) => Metadata.Provider?.EntityByName(name)?.ID)
            .filter((id): id is string => !!id);
        if (askEntityIDs.length === 0) return false;
        const isAsk = (id: string) => askEntityIDs.some((askID) => UUIDsEqual(id, askID));
        const entityField = this.GetFieldByName('EntityID');
        const recordField = this.GetFieldByName('RecordID');
        const isAskNow = isAsk(this.EntityID);
        if (!this.IsSaved) return isAskNow;
        const wasAsk = isAsk(String(entityField?.OldValue ?? ''));
        const moved = !!entityField?.Dirty || !!recordField?.Dirty;
        return moved && (isAskNow || wasAsk);
    }
}
