import { CompositeKey } from '@memberjunction/core';
import { SharedService } from '@memberjunction/ng-shared';

export const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';

/**
 * Open a Task record in the host (Explorer tab). Uses SharedService so
 * widgets never depend on an optional NavigationService inject that can
 * be null and silently no-op.
 */
export function OpenTaskRecord(taskID: string | null | undefined): void {
    if (!taskID) return;
    SharedService.Instance.OpenEntityRecord(TASKS_ENTITY, CompositeKey.FromID(taskID));
}
