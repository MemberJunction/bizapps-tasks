import { BaseEntity, EntitySaveOptions, ValidationResult, ValidationErrorInfo, ValidationErrorType, Metadata, RunView, CompositeKey } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";

/**
 * Custom entity subclass for MJ.BizApps.Tasks: Tasks.
 * Handles status transition side-effects, field validation, sub-task
 * rollup, and automatic activity logging.
 *
 * Registered with priority 1 to override the CodeGen-generated base class (priority 0).
 */
@RegisterClass(BaseEntity, 'MJ.BizApps.Tasks: Tasks', 1)
export class TaskEntity extends BaseEntity {

    // ---------------------------------------------------------------
    // Validation
    // ---------------------------------------------------------------

    public override Validate(): ValidationResult {
        const result = super.Validate();

        this.validatePercentComplete(result);
        this.validateDueAfterStart(result);
        this.applyStatusTransitionSideEffects();

        result.Success = result.Success && result.Errors.length === 0;
        return result;
    }

    private validatePercentComplete(result: ValidationResult): void {
        const pct = this.Get('PercentComplete') as number | null;
        if (pct != null && (pct < 0 || pct > 100)) {
            result.Errors.push(new ValidationErrorInfo(
                'PercentComplete',
                'Percent complete must be between 0 and 100.',
                pct,
                ValidationErrorType.Failure,
            ));
        }
    }

    private validateDueAfterStart(result: ValidationResult): void {
        const startedAt = this.Get('StartedAt') as Date | null;
        const dueAt = this.Get('DueAt') as Date | null;
        if (startedAt && dueAt && dueAt <= startedAt) {
            result.Errors.push(new ValidationErrorInfo(
                'DueAt',
                'Due date must be after the start date.',
                dueAt,
                ValidationErrorType.Failure,
            ));
        }
    }

    // ---------------------------------------------------------------
    // Status transition side-effects
    // ---------------------------------------------------------------

    private applyStatusTransitionSideEffects(): void {
        const statusField = this.Fields.find(f => f.CodeName === 'Status');
        if (!statusField || !statusField.Dirty) return;

        const oldStatus = statusField.OldValue as string | null;
        const newStatus = statusField.Value as string;

        if (newStatus === 'InProgress' && !this.Get('StartedAt')) {
            this.Set('StartedAt', new Date());
        }

        if (newStatus === 'Completed') {
            if (!this.Get('CompletedAt')) {
                this.Set('CompletedAt', new Date());
            }
            this.Set('PercentComplete', 100);
        }

        if (oldStatus === 'Completed' && newStatus !== 'Completed' && newStatus !== 'Cancelled') {
            this.Set('CompletedAt', null);
        }
    }

    // ---------------------------------------------------------------
    // Save override — triggers rollup + activity log after save
    // ---------------------------------------------------------------

    /**
     * Capture dirty fields before save, then trigger post-save side-effects.
     */
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        // Snapshot changed fields before save (save resets dirty flags)
        const statusChanged = this.Fields.find(f => f.CodeName === 'Status')?.Dirty ?? false;
        const pctChanged = this.Fields.find(f => f.CodeName === 'PercentComplete')?.Dirty ?? false;
        const priorityChanged = this.Fields.find(f => f.CodeName === 'Priority')?.Dirty ?? false;
        const dueChanged = this.Fields.find(f => f.CodeName === 'DueAt')?.Dirty ?? false;
        const isNew = !this.IsSaved;

        const oldStatus = this.Fields.find(f => f.CodeName === 'Status')?.OldValue as string | null;
        const oldPct = this.Fields.find(f => f.CodeName === 'PercentComplete')?.OldValue as number | null;
        const oldPriority = this.Fields.find(f => f.CodeName === 'Priority')?.OldValue as string | null;
        const oldDue = this.Fields.find(f => f.CodeName === 'DueAt')?.OldValue;

        const result = await super.Save(options);
        if (!result) return false;

        // Post-save side-effects — awaited so rollup completes before caller reloads
        await this.postSaveSideEffects(isNew, statusChanged, pctChanged, priorityChanged, dueChanged,
            oldStatus, oldPct, oldPriority, oldDue).catch(() => {});

        return true;
    }

    private async postSaveSideEffects(
        isNew: boolean, statusChanged: boolean, pctChanged: boolean,
        priorityChanged: boolean, dueChanged: boolean,
        oldStatus: string | null, oldPct: number | null,
        oldPriority: string | null, oldDue: any,
    ): Promise<void> {
        const taskID = this.Get('ID') as string;

        // 1. Activity logging
        if (isNew) {
            await this.logActivity(taskID, 'Created', `Task created: ${this.Get('Name')}`);
        }
        if (statusChanged && !isNew) {
            await this.logActivity(taskID, 'StatusChange',
                `Status changed from ${oldStatus} to ${this.Get('Status')}`,
                oldStatus ?? undefined, this.Get('Status') as string);
        }
        if (pctChanged && !isNew) {
            await this.logActivity(taskID, 'PercentCompleteChanged',
                `Progress updated to ${this.Get('PercentComplete')}%`,
                String(oldPct ?? 0), String(this.Get('PercentComplete')));
        }
        if (priorityChanged && !isNew) {
            await this.logActivity(taskID, 'PriorityChanged',
                `Priority changed from ${oldPriority} to ${this.Get('Priority')}`,
                oldPriority ?? undefined, this.Get('Priority') as string);
        }
        if (dueChanged && !isNew) {
            await this.logActivity(taskID, 'DueDateChanged',
                `Due date changed`, String(oldDue ?? ''), String(this.Get('DueAt') ?? ''));
        }
        if (statusChanged && this.Get('Status') === 'Completed') {
            await this.logActivity(taskID, 'Completed', `Task completed: ${this.Get('Name')}`);
        }

        // 2. Sub-task rollup — if this task has a parent, recalculate parent's progress
        const parentID = this.Get('ParentID') as string | null;
        if (parentID && (pctChanged || statusChanged)) {
            await this.rollupParentProgress(parentID);
        }
    }

    // ---------------------------------------------------------------
    // Sub-task progress rollup
    // ---------------------------------------------------------------

    private async rollupParentProgress(parentID: string): Promise<void> {
        const rv = new RunView();
        const children = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ParentID = '${parentID}'`,
            ResultType: 'simple',
        });

        if (!children?.Results?.length) return;

        let totalWeight = 0;
        let weightedSum = 0;
        for (const child of children.Results) {
            const pct = child.PercentComplete as number ?? 0;
            weightedSum += pct;
            totalWeight += 1;
        }

        const newPct = totalWeight > 0 ? Math.round(weightedSum / totalWeight) : 0;

        const parent = await Metadata.Provider.GetEntityObject<TaskEntity>('MJ.BizApps.Tasks: Tasks');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: parentID }]);
        await parent.InnerLoad(pk);

        const currentPct = parent.Get('PercentComplete') as number;
        if (currentPct !== newPct) {
            parent.Set('PercentComplete', newPct);
            await parent.Save();
            // Recursive — parent.Save() will trigger its own rollup if it has a grandparent
        }
    }

    // ---------------------------------------------------------------
    // Activity logging helper
    // ---------------------------------------------------------------

    private async logActivity(
        taskID: string, activityType: string, description: string,
        previousValue?: string, newValue?: string,
    ): Promise<void> {
        const activity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Activities');
        activity.NewRecord();
        activity.Set('TaskID', taskID);
        activity.Set('ActivityType', activityType);
        activity.Set('Description', description);
        if (previousValue) activity.Set('PreviousValue', previousValue);
        if (newValue) activity.Set('NewValue', newValue);
        await activity.Save();
    }
}
