import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

export function TaskStatusChipClass(status: mjBizAppsTasksTaskEntity['Status'] | undefined): string {
    switch (status) {
        case 'Completed':
            return 'mjt-chip mjt-chip--ok';
        case 'InProgress':
            return 'mjt-chip mjt-chip--info';
        case 'Blocked':
            return 'mjt-chip mjt-chip--error';
        case 'Cancelled':
            return 'mjt-chip mjt-chip--muted';
        case 'Open':
        default:
            return 'mjt-chip';
    }
}

export function TaskPriorityChipClass(priority: mjBizAppsTasksTaskEntity['Priority'] | undefined): string {
    switch (priority) {
        case 'Critical':
        case 'High':
            return 'mjt-chip mjt-chip--warn';
        case 'Low':
            return 'mjt-chip mjt-chip--muted';
        case 'Medium':
        default:
            return 'mjt-chip';
    }
}

export function FormatTaskDate(value: Date | string | null | undefined): string {
    if (!value) return '—';
    return new Date(value).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
    });
}

export function TaskProgressLabel(percent: number | null | undefined): string {
    return `${Math.round(percent ?? 0)}%`;
}
