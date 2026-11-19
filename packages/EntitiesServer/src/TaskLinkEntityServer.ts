/**
 * Server-side subclass of TaskLink — guards the links that tie a task to a workflow step.
 *
 * A workflow's Human step can be put in front of people as a bizapps-tasks task (the `BizAppsTasks`
 * human-task provider in `@mj-biz-apps/tasks-server`). The provider links the task to the step's
 * `MJ: Tasks` row, and deciding the task completes that step — as the system user, because the
 * person deciding usually cannot read workflow rows. That makes the link a capability: whoever can
 * create one can complete any waiting step by deciding a task of their own. So only the provider
 * may create such a link, and nobody may move an existing link onto or off a workflow step.
 *
 * Links to any other entity are unaffected.
 */
import { BaseEntity, EntitySaveOptions, Metadata, ValidationErrorInfo, ValidationErrorType, ValidationResult } from '@memberjunction/core';
import { RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { mjBizAppsTasksTaskLinkEntity } from '@mj-biz-apps/tasks-entities';

export const TASK_LINK_ENTITY = 'MJ_BizApps_Tasks: Task Links';

/** The entity a workflow step lives in. A link to it is what lets a task complete the step. */
export const WORKFLOW_STEP_ENTITY = 'MJ: Tasks';

const REFUSAL =
    'A task can be linked to a workflow step only by the workflow itself. ' +
    'Decide the task the workflow raised instead of linking another one.';

@RegisterClass(BaseEntity, TASK_LINK_ENTITY)
export class TaskLinkEntityServer extends mjBizAppsTasksTaskLinkEntity {
    private workflowLinkAuthorized = false;

    /**
     * Allows the next save to create a link to a workflow step. Called only by the `BizAppsTasks`
     * human-task provider, on a link it is creating for a step it was asked to raise.
     */
    public AuthorizeWorkflowStepLink(): void {
        this.workflowLinkAuthorized = true;
    }

    public override Validate(): ValidationResult {
        const result = super.Validate();
        if (this.touchesWorkflowStep() && !this.workflowLinkAuthorized) {
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
            this.workflowLinkAuthorized = false;
        }
    }

    /** Whether this save creates a workflow-step link, or moves one onto or off a workflow step. */
    private touchesWorkflowStep(): boolean {
        const stepEntityID = Metadata.Provider?.EntityByName(WORKFLOW_STEP_ENTITY)?.ID;
        if (!stepEntityID) return false;
        const entityField = this.GetFieldByName('EntityID');
        const recordField = this.GetFieldByName('RecordID');
        const isStepNow = UUIDsEqual(this.EntityID, stepEntityID);
        if (!this.IsSaved) return isStepNow;
        const wasStep = UUIDsEqual(String(entityField?.OldValue ?? ''), stepEntityID);
        const moved = !!entityField?.Dirty || !!recordField?.Dirty;
        return moved && (isStepNow || wasStep);
    }
}
