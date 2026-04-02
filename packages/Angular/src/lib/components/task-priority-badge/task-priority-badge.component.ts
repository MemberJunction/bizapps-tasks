import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

/**
 * Inline priority indicator with color-coded badge.
 *
 * Renders a small pill showing the priority level (Low, Medium, High, Critical)
 * with contextual background and text colors.
 *
 * @example
 * ```html
 * <bizapps-task-priority-badge [Priority]="'High'"></bizapps-task-priority-badge>
 * ```
 */
@Component({
    selector: 'bizapps-task-priority-badge',
    standalone: true,
    imports: [CommonModule],
    template: `
        <span class="priority-badge" [ngClass]="cssClass">{{ Priority }}</span>
    `,
    styles: [`
        .priority-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        .priority-low { background: #e0e7ff; color: #3730a3; }
        .priority-medium { background: #fef3c7; color: #92400e; }
        .priority-high { background: #fed7aa; color: #9a3412; }
        .priority-critical { background: #fecaca; color: #991b1b; }
    `]
})
export class TaskPriorityBadgeComponent {
    /**
     * Priority level to display. Must be one of: `'Low'`, `'Medium'`, `'High'`, `'Critical'`.
     * @default 'Medium'
     */
    @Input() Priority: string = 'Medium';

    /** @internal CSS class derived from the Priority value. */
    get cssClass(): string {
        return 'priority-' + (this.Priority || 'medium').toLowerCase();
    }
}
