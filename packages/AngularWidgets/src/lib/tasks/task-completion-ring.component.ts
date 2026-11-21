import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import type { TaskStatusValue } from './task-models';

/**
 * Tactile 1-click completion ring (L1 presentational widget).
 *
 * Distinct from bulk multi-select checkboxes: clicking toggles a task between
 * Completed and Open (or triggers the host's custom transition handler).
 * Includes an invisible `::after` hit-target expansion to satisfy 44px touch
 * ergonomics on mobile without bloating compact desktop rows.
 */
@Component({
    selector: 'mjt-completion-ring',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <button
            type="button"
            class="mjt-ring"
            [class.is-done]="Status === 'Completed'"
            [class.is-prog]="Status === 'InProgress'"
            [class.is-blocked]="Status === 'Blocked'"
            [class.is-cancelled]="Status === 'Cancelled'"
            [class.is-lg]="Size === 'lg'"
            [disabled]="Disabled"
            [attr.aria-pressed]="Status === 'Completed'"
            [attr.aria-label]="ariaLabel"
            [title]="ariaLabel"
            (click)="onClick($event)">
            @if (Status === 'Completed') {
                <i class="fa-solid fa-check" aria-hidden="true"></i>
            } @else if (Status === 'Blocked') {
                <i class="fa-solid fa-exclamation" aria-hidden="true"></i>
            } @else if (Status === 'Cancelled') {
                <i class="fa-solid fa-minus" aria-hidden="true"></i>
            }
        </button>
    `,
    styles: [`
        :host {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .mjt-ring {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            position: relative;
            padding: 0;
            border: 2px solid var(--mj-border-strong);
            background: transparent;
            color: var(--mj-brand-on-primary, #ffffff);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            transition: border-color 140ms ease, background 140ms ease, transform 120ms ease, box-shadow 140ms ease;
        }
        .mjt-ring.is-lg {
            width: 24px;
            height: 24px;
            font-size: 11px;
        }
        /* Expanded touch target (WCAG 2.5.5) without changing visual footprint */
        .mjt-ring::after {
            content: '';
            position: absolute;
            inset: -11px;
        }
        .mjt-ring:hover:not(:disabled) {
            border-color: var(--mj-brand-primary);
            background: color-mix(in srgb, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            transform: scale(1.06);
        }
        .mjt-ring:focus-visible {
            outline: 2px solid var(--mj-border-focus, var(--mj-brand-primary));
            outline-offset: 2px;
        }
        .mjt-ring.is-done {
            background: var(--mj-status-success);
            border-color: var(--mj-status-success);
            color: var(--mj-brand-on-primary, #ffffff);
        }
        .mjt-ring.is-done:hover:not(:disabled) {
            background: var(--mj-status-success-text);
            border-color: var(--mj-status-success-text);
        }
        .mjt-ring.is-prog {
            border-color: var(--mj-brand-primary);
            box-shadow: inset 0 0 0 3px var(--mj-bg-surface), inset 0 0 0 8px var(--mj-brand-primary);
        }
        .mjt-ring.is-blocked {
            border-color: var(--mj-status-error);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
        }
        .mjt-ring.is-cancelled {
            border-color: var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-muted);
        }
        .mjt-ring:disabled {
            opacity: 0.45;
            cursor: default;
        }
    `],
})
export class TaskCompletionRingComponent {
    @Input() Status: TaskStatusValue = 'Open';
    @Input() TaskName = 'task';
    @Input() Size: 'md' | 'lg' = 'md';
    @Input() Disabled = false;

    /** Emits the target status (`'Completed'` if currently open/in-progress/blocked, `'Open'` if completed). */
    @Output() Toggled = new EventEmitter<TaskStatusValue>();

    public get ariaLabel(): string {
        return this.Status === 'Completed'
            ? `Reopen ${this.TaskName}`
            : `Mark ${this.TaskName} complete`;
    }

    public onClick(event: MouseEvent): void {
        event.stopPropagation();
        if (this.Disabled) return;
        const next: TaskStatusValue = this.Status === 'Completed' ? 'Open' : 'Completed';
        this.Toggled.emit(next);
    }
}
