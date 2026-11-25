/**
 * Pure helpers for UserInfoEngine-persisted Saved Filter Views (zero `localStorage`)
 * and human-readable formatting of Task statuses and activity types.
 */

import { TasksLimitsResolver } from '../config/TasksLimits.js';

export const SAVED_TASK_VIEWS_SETTING = 'mj.tasks.savedFilterViews.v1';
export const MAX_SAVED_TASK_VIEWS: number = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxSavedTaskViews;

export type SavedTaskFilterValue = string | number | boolean | null | string[];
export type SavedTaskFilterMap = Record<string, SavedTaskFilterValue>;

export interface SavedTaskFilterView {
    ID: string;
    Name: string;
    CategoryID: string | null;
    ViewMode?: 'wbs' | 'list' | 'kanban' | 'gantt';
    SearchText?: string;
    Filters: SavedTaskFilterMap;
    CreatedAt: string;
}

interface RawSavedTaskFilterView {
    ID?: string;
    Name?: string;
    CategoryID?: string | null;
    ViewMode?: string;
    SearchText?: string;
    Filters?: SavedTaskFilterMap;
    CreatedAt?: string;
}

/**
 * Safely parses a JSON-serialized saved views list from `UserInfoEngine.Instance.GetSetting(...)`.
 */
export function ParseSavedTaskFilterViews(raw: string | null | undefined): SavedTaskFilterView[] {
    if (!raw || typeof raw !== 'string') return [];
    try {
        const maxSavedViews = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxSavedTaskViews;
        const parsed: RawSavedTaskFilterView[] = JSON.parse(raw);
        if (!Array.isArray(parsed)) return [];
        const out: SavedTaskFilterView[] = [];
        for (const entry of parsed) {
            if (!entry || typeof entry !== 'object') continue;
            const id = typeof entry.ID === 'string' ? entry.ID.trim() : '';
            const name = typeof entry.Name === 'string' ? entry.Name.trim() : '';
            if (!id || !name) continue;
            const viewModeRaw = entry.ViewMode;
            const viewMode =
                viewModeRaw === 'wbs' || viewModeRaw === 'list' || viewModeRaw === 'kanban' || viewModeRaw === 'gantt'
                    ? viewModeRaw
                    : undefined;
            const filtersRaw = entry.Filters;
            const filters: SavedTaskFilterMap =
                filtersRaw && typeof filtersRaw === 'object' && !Array.isArray(filtersRaw)
                    ? { ...filtersRaw }
                    : {};
            out.push({
                ID: id,
                Name: name,
                CategoryID: typeof entry.CategoryID === 'string' ? entry.CategoryID : null,
                ViewMode: viewMode,
                SearchText: typeof entry.SearchText === 'string' ? entry.SearchText : '',
                Filters: filters,
                CreatedAt: typeof entry.CreatedAt === 'string' ? entry.CreatedAt : new Date().toISOString(),
            });
            if (out.length >= maxSavedViews) break;
        }
        return out;
    } catch {
        return [];
    }
}

/**
 * Serializes saved filter views for storage in `UserInfoEngine`.
 */
export function SerializeSavedTaskFilterViews(views: readonly SavedTaskFilterView[]): string {
    const maxSavedViews = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxSavedTaskViews;
    return JSON.stringify(views.slice(0, maxSavedViews));
}

/**
 * Inserts or updates a saved filter view (matching by ID or case-insensitive Name).
 */
export function UpsertSavedTaskFilterView(
    existing: readonly SavedTaskFilterView[],
    incoming: Omit<SavedTaskFilterView, 'ID' | 'CreatedAt'> & { ID?: string; CreatedAt?: string },
): SavedTaskFilterView[] {
    const cleanName = incoming.Name.trim();
    if (!cleanName) return [...existing];

    const lowerName = cleanName.toLowerCase();
    const matchIdx = existing.findIndex(
        (v) => (incoming.ID && v.ID === incoming.ID) || v.Name.trim().toLowerCase() === lowerName,
    );

    const record: SavedTaskFilterView = {
        ID: incoming.ID || (matchIdx >= 0 ? existing[matchIdx].ID : `view-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`),
        Name: cleanName,
        CategoryID: incoming.CategoryID ?? null,
        ViewMode: incoming.ViewMode,
        SearchText: incoming.SearchText ?? '',
        Filters: { ...(incoming.Filters ?? {}) },
        CreatedAt: incoming.CreatedAt ?? (matchIdx >= 0 ? existing[matchIdx].CreatedAt : new Date().toISOString()),
    };

    const next = [...existing];
    if (matchIdx >= 0) {
        next[matchIdx] = record;
    } else {
        next.unshift(record);
    }
    const maxSavedViews = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxSavedTaskViews;
    return next.slice(0, maxSavedViews);
}

/**
 * Removes a saved filter view by ID.
 */
export function DeleteSavedTaskFilterView(
    existing: readonly SavedTaskFilterView[],
    viewId: string,
): SavedTaskFilterView[] {
    return existing.filter((v) => v.ID !== viewId);
}

/**
 * Formats PascalCase status enums into clean human-readable labels
 * (e.g., `'InProgress'` → `'In Progress'`, `'NotStarted'` → `'Not Started'`).
 */
export function FormatTaskStatusLabel(status: string | null | undefined): string {
    if (!status) return 'Open';
    switch (status) {
        case 'InProgress':
            return 'In Progress';
        case 'NotStarted':
            return 'Not Started';
        case 'OnTrack':
            return 'On Track';
        case 'AtRisk':
            return 'At Risk';
        case 'OffTrack':
            return 'Off Track';
        default:
            return status.replace(/([a-z])([A-Z])/g, '$1 $2');
    }
}

/**
 * Formats PascalCase activity types into clean human-readable labels
 * (e.g., `'StatusChange'` → `'Status Change'`, `'AssignmentAdded'` → `'Assignment Added'`).
 */
export function FormatTaskActivityTypeLabel(activityType: string | null | undefined): string {
    if (!activityType) return 'Update';
    return activityType.replace(/([a-z])([A-Z])/g, '$1 $2').replace(/_/g, ' ');
}
