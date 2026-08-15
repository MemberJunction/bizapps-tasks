import {
    GanttZoomLevelFromPercent,
    GanttZoomPercent,
    IsGanttZoomLevelName,
    type GanttZoomLevelName,
} from '@memberjunction/ng-gantt';

/** UserInfoEngine key. Shape may grow; bump the suffix if it does. */
export const TASKS_GANTT_ZOOM_SETTING = 'mj.tasks.ganttZoom.v1';

/** Slightly zoomed out from week (100%) so a project timeline fits at first glance. */
export const TASKS_GANTT_DEFAULT_ZOOM: GanttZoomLevelName = 'month';

interface StoredZoomPref {
    level?: string;
    percent?: number;
}

export function ParseTasksGanttZoomPref(raw: string | undefined): GanttZoomLevelName {
    if (!raw) {
        return TASKS_GANTT_DEFAULT_ZOOM;
    }
    if (IsGanttZoomLevelName(raw)) {
        return raw;
    }
    try {
        const parsed = JSON.parse(raw) as StoredZoomPref;
        if (parsed.level && IsGanttZoomLevelName(parsed.level)) {
            return parsed.level;
        }
        if (typeof parsed.percent === 'number') {
            return GanttZoomLevelFromPercent(parsed.percent);
        }
    } catch {
        // fall through
    }
    return TASKS_GANTT_DEFAULT_ZOOM;
}

export function SerializeTasksGanttZoomPref(level: GanttZoomLevelName): string {
    return JSON.stringify({ level, percent: GanttZoomPercent(level) });
}
