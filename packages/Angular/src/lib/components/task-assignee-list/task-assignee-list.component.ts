import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface TaskAssigneeInfo {
    AssigneeRecordID: string;
    DisplayName: string;
    RoleName?: string;
    Status: 'Pending' | 'InProgress' | 'Completed';
}

/**
 * Avatar/name chips for assigned entities (people, agents) with per-assignee
 * status indicator dots: green (Completed), blue (InProgress), gray (Pending).
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
        .no-assignees { color: #9ca3af; font-size: 0.85rem; font-style: italic; }
        .assignee-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 8px; border-radius: 12px;
            background: #f3f4f6; font-size: 0.8rem;
        }
        .status-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
        }
        .dot-pending { background: #9ca3af; }
        .dot-inprogress { background: #3b82f6; }
        .dot-completed { background: #22c55e; }
        .assignee-name { white-space: nowrap; }
    `]
})
export class TaskAssigneeListComponent {
    @Input() Assignees: TaskAssigneeInfo[] = [];
}
