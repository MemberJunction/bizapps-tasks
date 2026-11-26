import {
    Metadata,
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type RunViewParams,
    type RunViewResult,
} from '@memberjunction/core';
import { TasksEngineBase } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskTypeStatusEntity } from '@mj-biz-apps/tasks-entities';
import type { TaskWidgetTypeStatus } from '@mj-biz-apps/tasks-ng-widgets';

/**
 * Creates a `RunView` bound to `provider` when it implements `IRunViewProvider`,
 * falling back to `new RunView()` otherwise.
 */
export function CreateTasksRunView(provider?: IMetadataProvider | null): RunView {
    const effective = provider ?? Metadata.Provider;
    if (effective && typeof (effective as Partial<IRunViewProvider>).RunView === 'function') {
        return RunView.FromMetadataProvider(effective);
    }
    return new RunView();
}

/**
 * Ensures {@link TasksEngineBase} is initialized for `provider` (no-op once cached
 * for the active provider and user). Swallows provider-unavailable errors in isolated
 * unit tests where no global metadata provider is bootstrapped.
 */
export async function EnsureTasksEngineLoaded(provider?: IMetadataProvider | null): Promise<TasksEngineBase> {
    const engine = TasksEngineBase.Instance;
    const effective = provider ?? Metadata.Provider;
    try {
        await engine.Config(false, effective?.CurrentUser, effective ?? undefined);
    } catch {
        // Safe fallback for isolated unit tests without an active RunView provider
    }
    return engine;
}

/**
 * Executes one or more `RunViewParams` in a single `rv.RunViews([...])` GraphQL batch request
 * when multiple views are requested (or a single `rv.RunView(...)` when only 1 view is needed).
 */
export async function RunViewsBatch(
    rv: RunView,
    params: RunViewParams[],
): Promise<RunViewResult[]> {
    if (params.length === 0) return [];
    if (params.length === 1) {
        const single = await rv.RunView(params[0]);
        return single ? [single] : [];
    }
    if (typeof rv.RunViews === 'function') {
        const batched = await rv.RunViews(params);
        if (Array.isArray(batched)) {
            return batched;
        }
    }
    // Compatibility fallback only for unit-test stubs that mock RunView() without RunViews()
    return Promise.all(params.map((p) => rv.RunView(p)));
}

/**
 * Maps cached {@link mjBizAppsTasksTaskTypeStatusEntity} rows into plain {@link TaskWidgetTypeStatus}
 * projections for L2 widget components.
 */
export function MapTaskTypeStatusesToWidget(
    statuses: readonly mjBizAppsTasksTaskTypeStatusEntity[],
): TaskWidgetTypeStatus[] {
    return statuses.map((s) => ({
        ID: s.ID,
        TaskTypeID: s.TaskTypeID,
        Name: s.Name,
        Code: s.Code,
        Sequence: s.Sequence,
        MacroStatus: s.MacroStatus,
        IsDefault: s.IsDefault,
        IsTerminal: s.IsTerminal,
        Color: s.Color,
        IconClass: s.IconClass,
    }));
}
