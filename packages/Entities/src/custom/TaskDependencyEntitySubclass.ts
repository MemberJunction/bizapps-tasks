import { BaseEntity, RunView, ValidationResult, ValidationErrorInfo, ValidationErrorType } from "@memberjunction/core";
import { IsValidUUID, RegisterClass } from "@memberjunction/global";
import { mjBizAppsTasksTaskDependencyEntity } from "../generated/entity_subclasses.js";

/**
 * Custom entity subclass for MJ_BizApps_Tasks: Task Dependencies.
 * Prevents circular dependencies by walking the dependency graph
 * before allowing a save.
 *
 * Extends the CodeGen-generated entity (per MJ convention) so the strongly-typed
 * field accessors are inherited; registered without an explicit priority so
 * `ClassFactory` auto-increments above the generated base class's priority 1.
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Dependencies')
export class TaskDependencyEntity extends mjBizAppsTasksTaskDependencyEntity {

    public override Validate(): ValidationResult {
        const result = super.Validate();

        this.validateNoSelfReference(result);

        result.Success = result.Success && result.Errors.length === 0;
        return result;
    }

    /**
     * Redundant safety check (also enforced by DB CHECK constraint).
     */
    private validateNoSelfReference(result: ValidationResult): void {
        const taskID = this.TaskID;
        const dependsOnTaskID = this.DependsOnTaskID;
        if (taskID && dependsOnTaskID && taskID === dependsOnTaskID) {
            result.Errors.push(new ValidationErrorInfo(
                'DependsOnTaskID',
                'A task cannot depend on itself.',
                dependsOnTaskID,
                ValidationErrorType.Failure,
            ));
        }
    }

    /**
     * Async validation: walk the dependency graph starting from DependsOnTaskID
     * and check whether we eventually reach TaskID (which would create a cycle).
     */
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();

        await this.validateNoCycle(result);

        result.Success = result.Success && result.Errors.length === 0;
        return result;
    }

    /**
     * BFS/iterative walk of the dependency graph to detect cycles.
     *
     * Starting from `DependsOnTaskID`, follow all outgoing DependsOnTaskID edges.
     * If we reach `TaskID`, saving this row would create a cycle → reject.
     */
    private async validateNoCycle(result: ValidationResult): Promise<void> {
        const taskID = this.TaskID;
        const dependsOnTaskID = this.DependsOnTaskID;
        if (!taskID || !dependsOnTaskID) return;

        // Every ID walked here is interpolated into an ExtraFilter, so refuse anything that is not
        // a UUID before it can reach SQL text (the first walked value is caller-supplied).
        for (const [field, value] of [['TaskID', taskID], ['DependsOnTaskID', dependsOnTaskID]] as const) {
            if (!IsValidUUID(value)) {
                result.Errors.push(new ValidationErrorInfo(
                    field,
                    `${field} '${value}' is not a valid ID.`,
                    value,
                    ValidationErrorType.Failure,
                ));
            }
        }
        if (result.Errors.length > 0) return;

        const visited = new Set<string>();
        const queue: string[] = [dependsOnTaskID];

        while (queue.length > 0) {
            const current = queue.shift()!;
            if (!IsValidUUID(current)) {
                // Defense in depth: a walked dependency row carried a non-UUID TaskID.
                result.Errors.push(new ValidationErrorInfo(
                    'DependsOnTaskID',
                    `A walked dependency ID '${current}' is not a valid ID.`,
                    current,
                    ValidationErrorType.Failure,
                ));
                return;
            }
            if (current === taskID) {
                result.Errors.push(new ValidationErrorInfo(
                    'DependsOnTaskID',
                    'This dependency would create a circular reference.',
                    dependsOnTaskID,
                    ValidationErrorType.Failure,
                ));
                return;
            }
            if (visited.has(current)) continue;
            visited.add(current);

            // Load all tasks that `current` depends on
            const rv = new RunView();
            const upstream = await rv.RunView<{ DependsOnTaskID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                ExtraFilter: `TaskID = '${current}'`,
                ResultType: 'simple',
            });

            if (upstream?.Results) {
                for (const dep of upstream.Results) {
                    const upstreamID = dep.DependsOnTaskID;
                    if (upstreamID && !visited.has(upstreamID)) {
                        queue.push(upstreamID);
                    }
                }
            }
        }
    }
}
