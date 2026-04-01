import { BaseEntity, Metadata, RunView, ValidationResult, ValidationErrorInfo, ValidationErrorType } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";

/**
 * Custom entity subclass for MJ.BizApps.Tasks: Task Dependencies.
 * Prevents circular dependencies by walking the dependency graph
 * before allowing a save.
 *
 * Registered with priority 1 to override the CodeGen-generated base class.
 */
@RegisterClass(BaseEntity, 'MJ.BizApps.Tasks: Task Dependencies', 1)
export class TaskDependencyEntity extends BaseEntity {

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
        const taskID = this.Get('TaskID') as string;
        const dependsOnTaskID = this.Get('DependsOnTaskID') as string;
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
        const taskID = this.Get('TaskID') as string;
        const dependsOnTaskID = this.Get('DependsOnTaskID') as string;
        if (!taskID || !dependsOnTaskID) return;

        const visited = new Set<string>();
        const queue: string[] = [dependsOnTaskID];

        while (queue.length > 0) {
            const current = queue.shift()!;
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
            const upstream = await rv.RunView<BaseEntity>({
                EntityName: 'MJ.BizApps.Tasks: Task Dependencies',
                ExtraFilter: `TaskID = '${current}'`,
                ResultType: 'simple',
            });

            if (upstream?.Results) {
                for (const dep of upstream.Results) {
                    const upstreamID = (dep as any).DependsOnTaskID as string;
                    if (upstreamID && !visited.has(upstreamID)) {
                        queue.push(upstreamID);
                    }
                }
            }
        }
    }
}
