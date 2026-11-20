/**
 * Server-side subclass of `MJ_BizApps_Tasks: Task Types` (`AN-BC` review round 2 #4 on PR #165).
 *
 * Guards against changing `ExtensionEntity` on a `TaskType` that already has `Task` rows:
 *   - `MJ_BizApps_Tasks: Tasks` uses `SubtypeSelectorConfig` with `OnSubtypeChange: 'Replace'` so
 *     changing an individual Task's `TypeID` replaces its extension subtype row.
 *   - However, if an admin modifies `TaskType.ExtensionEntity` on a `TaskType` that already has Tasks,
 *     the next save of any existing Task of that type (including automated status rollups or SLA saves)
 *     would see a mismatch between the Task's existing child row and the newly configured
 *     `TaskType.ExtensionEntity` and would delete the existing extension row.
 *   - Therefore, changing `ExtensionEntity` on a `TaskType` that already has Tasks is refused at
 *     validation time and must be performed as a coordinated database migration.
 */
import {
    BaseEntity,
    LogError,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
    type IRunViewProvider,
} from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTaskTypeEntity } from '@mj-biz-apps/tasks-entities';
import { TASKS_ENTITY_NAME } from '@mj-biz-apps/tasks-core';
import { IsEntityRunViewProvider } from './WorkReportAuthority.js';

export const TASK_TYPE_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const VALIDATE_SOURCE = 'TaskTypeEntityServer.ValidateAsync';

@RegisterClass(BaseEntity, TASK_TYPE_ENTITY)
export class TaskTypeEntityServer extends mjBizAppsTasksTaskTypeEntity {
    /** Async validation enforces the `ExtensionEntity` immutability guard when Tasks exist. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        if (!this.IsSaved) {
            return result;
        }

        const extState = this.readExtensionEntityChange();
        if (!extState.Changed) {
            return result;
        }

        try {
            const refusal = await this.evaluateExtensionEntityRefusal();
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(VALIDATE_SOURCE, refusal, null));
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskTypeEntityServer: failed to verify existing Tasks for TaskType ${this.ID}: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(
                    VALIDATE_SOURCE,
                    `The TaskType could not be saved because existing Task usage could not be verified (${msg}).`,
                    null,
                ),
            );
        }

        return result;
    }

    private readExtensionEntityChange(): { Changed: boolean; OldValue: string | null; NewValue: string | null } {
        const field =
            this.GetFieldByName?.('ExtensionEntity') ??
            this.Fields?.find((f) => f.CodeName === 'ExtensionEntity' || f.Name === 'ExtensionEntity');
        const normalize = (v: string | number | boolean | null | undefined): string | null => {
            if (v == null) {
                return null;
            }
            const trimmed = String(v).trim();
            return trimmed.length > 0 ? trimmed : null;
        };
        const newVal = normalize(this.ExtensionEntity);
        if (!field || !field.Dirty) {
            return { Changed: false, OldValue: newVal, NewValue: newVal };
        }
        const oldVal = normalize(field.OldValue as string | null | undefined);
        return {
            Changed: oldVal !== newVal,
            OldValue: oldVal,
            NewValue: newVal,
        };
    }

    private async evaluateExtensionEntityRefusal(): Promise<string | null> {
        if (!this.ID || !IsValidUUID(this.ID)) {
            return 'Cannot change ExtensionEntity on a saved TaskType without a valid ID.';
        }

        const rvProvider: IRunViewProvider | undefined = IsEntityRunViewProvider(this.ProviderToUse)
            ? this.ProviderToUse
            : this.RunViewProviderToUse;
        const rv = new RunView(rvProvider);
        const tasksRes = await rv.RunView<{ ID: string }>(
            {
                EntityName: TASKS_ENTITY_NAME,
                ExtraFilter: `TypeID = '${EscapeSQLString(this.ID)}'`,
                Fields: ['ID'],
                ResultType: 'count_only',
                BypassCache: true,
            },
            this.ContextCurrentUser,
        );

        if (!tasksRes?.Success) {
            throw new Error(tasksRes?.ErrorMessage ?? `RunView on ${TASKS_ENTITY_NAME} failed`);
        }

        const count = tasksRes.TotalRowCount ?? (tasksRes.Results?.length ?? 0);
        if (count > 0) {
            const label = this.Name?.trim() || this.ID;
            return (
                `Cannot change ExtensionEntity on TaskType '${label}' because ${count} Task record(s) already use this type. ` +
                `With OnSubtypeChange='Replace', saving those Tasks would delete their existing extension rows. ` +
                `Re-pointing ExtensionEntity on an in-use TaskType is a migration-level operation.`
            );
        }

        return null;
    }
}

export function LoadTaskTypeEntityServer(): void {
    // Prevent tree-shaking of @RegisterClass side effects.
    if (!TaskTypeEntityServer) {
        throw new Error('TaskTypeEntityServer failed to load');
    }
}
