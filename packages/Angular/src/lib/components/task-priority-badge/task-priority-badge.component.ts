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
            border-radius: var(--mj-radius-sm);
            font-size: 0.75rem;
            font-weight: var(--mj-font-semibold);
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        .priority-low { background: var(--mj-bg-surface-sunken); color: var(--mj-text-muted); }
        .priority-medium { background: var(--mj-status-info-bg); color: var(--mj-status-info-text); }
        .priority-high { background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text); }
        .priority-critical { background: var(--mj-status-error-bg); color: var(--mj-status-error-text); }
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
