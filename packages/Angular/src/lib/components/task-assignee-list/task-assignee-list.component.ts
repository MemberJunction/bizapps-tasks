import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

/**
 * Represents a single assignee displayed by {@link TaskAssigneeListComponent}.
 */
export interface TaskAssigneeInfo {
    /** Unique record ID of the assignee (Person ID or Agent ID). */
    AssigneeRecordID: string;
    /** Human-readable display name (e.g. "Sarah Chen"). */
    DisplayName: string;
    /** Optional role name (e.g. "Reviewer", "Observer"). Shown as a tooltip. */
    RoleName?: string;
    /** Per-assignee progress status. Controls the indicator dot color. */
    Status: 'Pending' | 'InProgress' | 'Completed';
}

/**
 * Displays a horizontal list of assignee chips with per-person status indicator dots.
 *
 * Each chip shows the assignee's name and a colored dot reflecting their individual
 * status on the task: gray (Pending), blue (InProgress), green (Completed).
 * When no assignees are provided, renders "Unassigned" in muted text.
 *
 * @example
 * ```html
 * <bizapps-task-assignee-list
 *     [Assignees]="[
 *         { AssigneeRecordID: '...', DisplayName: 'Sarah Chen', RoleName: 'Primary', Status: 'InProgress' },
 *         { AssigneeRecordID: '...', DisplayName: 'Marcus Williams', RoleName: 'Reviewer', Status: 'Pending' }
 *     ]">
 * </bizapps-task-assignee-list>
 * ```
 */
@Component({
    selector: 'bizapps-task-assignee-list',
    standalone: true,
    imports: [CommonModule],
    template: `
        @if (Assignees.length === 0) {
            <span class="no-assignees">Unassigned</span>
        }
        @for (a of Assignees; track a.AssigneeRecordID) {
            <span class="assignee-chip" [title]="a.RoleName || ''">
                <span class="status-dot" [ngClass]="'dot-' + a.Status.toLowerCase()"></span>
                <span class="assignee-name">{{ a.DisplayName }}</span>
            </span>
        }
    `,
    styles: [`
        :host { display: inline-flex; flex-wrap: wrap; gap: 4px; align-items: center; }
        .no-assignees { color: var(--mj-text-disabled); font-size: 0.85rem; font-style: italic; }
        .assignee-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 8px; border-radius: var(--mj-radius-lg);
            background: var(--mj-bg-surface-sunken); font-size: 0.8rem;
        }
        .status-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
        }
        .dot-pending { background: var(--mj-text-disabled); }
        .dot-inprogress { background: var(--mj-status-info); }
        .dot-completed { background: var(--mj-status-success); }
        .assignee-name { white-space: nowrap; }
    `]
})
export class TaskAssigneeListComponent {
    /**
     * Array of assignees to render. Each entry produces one chip with a status dot
     * and display name. Pass an empty array to show the "Unassigned" placeholder.
     * @default []
     */
    @Input() Assignees: TaskAssigneeInfo[] = [];
}
