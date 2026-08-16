import {
    ClampGanttGridWidth,
    GANTT_DEFAULT_GRID_WIDTH,
    GanttZoomLevelFromPercent,
    GanttZoomPercent,
    IsGanttZoomLevelName,
    SanitizeColumnWidths,
    type GanttZoomLevelName,
} from '@memberjunction/ng-gantt';

/** Combined Tasks Gantt prefs. Other apps should use their own key. */
export const TASKS_GANTT_PREF_SETTING = 'mj.tasks.gantt.v1';

/** @deprecated Read only to migrate zoom from the first zoom-only key. */
export const TASKS_GANTT_ZOOM_SETTING = 'mj.tasks.ganttZoom.v1';

/** Slightly zoomed out from week (100%) so a project timeline fits at first glance. */
export const TASKS_GANTT_DEFAULT_ZOOM: GanttZoomLevelName = 'month';

export interface TasksGanttPref {
    zoomLevel: GanttZoomLevelName;
    zoomPercent: number;
    gridWidth: number;
    columnWidths: Record<string, number>;
}

interface StoredGanttPref {
    level?: string;
    zoomLevel?: string;
    percent?: number;
    zoomPercent?: number;
    gridWidth?: number;
    columnWidths?: Record<string, number>;
}

export function DefaultTasksGanttPref(): TasksGanttPref {
    return {
        zoomLevel: TASKS_GANTT_DEFAULT_ZOOM,
        zoomPercent: GanttZoomPercent(TASKS_GANTT_DEFAULT_ZOOM),
        gridWidth: GANTT_DEFAULT_GRID_WIDTH,
        columnWidths: {},
    };
}

export function ParseTasksGanttPref(raw: string | undefined, legacyZoomRaw?: string): TasksGanttPref {
    const pref = DefaultTasksGanttPref();
    applyStoredPref(pref, legacyZoomRaw);
    applyStoredPref(pref, raw);
    return pref;
}

/** @deprecated Use {@link ParseTasksGanttPref}. */
export function ParseTasksGanttZoomPref(raw: string | undefined): GanttZoomLevelName {
    return ParseTasksGanttPref(undefined, raw).zoomLevel;
}

export function SerializeTasksGanttPref(pref: TasksGanttPref): string {
    return JSON.stringify({
        zoomLevel: pref.zoomLevel,
        zoomPercent: GanttZoomPercent(pref.zoomLevel),
        gridWidth: ClampGanttGridWidth(pref.gridWidth),
        columnWidths: SanitizeColumnWidths(pref.columnWidths),
    });
}

/** @deprecated Use {@link SerializeTasksGanttPref}. */
export function SerializeTasksGanttZoomPref(level: GanttZoomLevelName): string {
    return SerializeTasksGanttPref({
        ...DefaultTasksGanttPref(),
        zoomLevel: level,
        zoomPercent: GanttZoomPercent(level),
    });
}

function applyStoredPref(target: TasksGanttPref, raw: string | undefined): void {
    if (!raw) {
        return;
    }
    if (IsGanttZoomLevelName(raw)) {
        target.zoomLevel = raw;
        target.zoomPercent = GanttZoomPercent(raw);
        return;
    }
    try {
        const parsed = JSON.parse(raw) as StoredGanttPref;
        const level = parsed.zoomLevel ?? parsed.level;
        if (level && IsGanttZoomLevelName(level)) {
            target.zoomLevel = level;
            target.zoomPercent = GanttZoomPercent(level);
        } else {
            const percent = parsed.zoomPercent ?? parsed.percent;
            if (typeof percent === 'number') {
                target.zoomLevel = GanttZoomLevelFromPercent(percent);
                target.zoomPercent = GanttZoomPercent(target.zoomLevel);
            }
        }
        if (typeof parsed.gridWidth === 'number') {
            target.gridWidth = ClampGanttGridWidth(parsed.gridWidth);
        }
        if (parsed.columnWidths) {
            target.columnWidths = SanitizeColumnWidths(parsed.columnWidths);
        }
    } catch {
        // keep whatever was already applied
    }
}
