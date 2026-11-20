import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { ParseQuickTaskInput, type ParsedQuickTask } from '@mj-biz-apps/tasks-core';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskQuickCaptureSubmitEvent, TaskWidgetLinkedRecord } from './task-models';

/**
 * Natural-language Quick-Capture bar (L1 presentational widget).
 *
 * Parses `@person`, `tomorrow`/`fri`/`Nov 22`, `#Tag`, `!high`/`!critical`, and `~2h`
 * live via `ParseQuickTaskInput` from `@mj-biz-apps/tasks-core` and previews extracted
 * structured tokens right beneath the input. Zero Explorer or Router dependencies.
 */
@Component({
    selector: 'mjt-quick-capture',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-qc" [class.is-compact]="Compact" [class.is-focused]="IsFocused">
            <div class="mjt-qc-row">
                <i class="fa-solid fa-plus mjt-qc-lead" aria-hidden="true"></i>
                <input
                    type="text"
                    class="mjt-qc-input"
                    [(ngModel)]="DraftText"
                    [placeholder]="Placeholder"
                    [disabled]="Busy"
                    aria-label="Quick add task"
                    (focus)="IsFocused = true"
                    (blur)="IsFocused = false"
                    (keydown.enter)="submit()" />

                @if (ShowLinkRecordButton && !LinkedRecord) {
                    <button
                        type="button"
                        mjButton
                        variant="flat"
                        size="sm"
                        class="mjt-qc-link-btn"
                        [disabled]="Busy"
                        title="Connect this task to an MJ record"
                        (click)="LinkRecordRequested.emit()">
                        <i class="fa-solid fa-link" aria-hidden="true"></i>
                        <span class="mjt-qc-link-text">Link Record</span>
                    </button>
                }

                <button
                    type="button"
                    mjButton
                    variant="primary"
                    size="sm"
                    [disabled]="Busy || !Parsed.Title"
                    (click)="submit()">
                    @if (Busy) {
                        <i class="fa-solid fa-spinner fa-spin" aria-hidden="true"></i>
                    } @else {
                        <i class="fa-solid fa-arrow-turn-down fa-rotate-90" aria-hidden="true"></i>
                    }
                    <span>{{ SubmitLabel }}</span>
                </button>
            </div>

            @if (HasPreviewChips) {
                <div class="mjt-qc-preview" aria-live="polite">
                    @if (LinkedRecord) {
                        <span class="mjt-pill mjt-pill--brand">
                            <i [class]="LinkedRecord.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                            <span>{{ LinkedRecord.DisplayName }}</span>
                            @if (!LockedLinkedRecord) {
                                <button
                                    type="button"
                                    class="mjt-chip-x"
                                    aria-label="Remove linked record"
                                    (click)="ClearLinkedRecord.emit()">
                                    <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                                </button>
                            }
                        </span>
                    }
                    @if (Parsed.DueLabel) {
                        <span class="mjt-pill mjt-pill--info">
                            <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                            {{ Parsed.DueLabel }}
                        </span>
                    }
                    @if (Parsed.AssigneeQuery) {
                        <span class="mjt-pill mjt-pill--violet">
                            <i class="fa-solid fa-user" aria-hidden="true"></i>
                            &#64;{{ Parsed.AssigneeQuery }}
                        </span>
                    }
                    @if (Parsed.Priority) {
                        <span class="mjt-pill" [class]="priorityPillClass(Parsed.Priority)">
                            <i class="fa-solid fa-flag" aria-hidden="true"></i>
                            {{ Parsed.Priority }}
                        </span>
                    }
                    @if (Parsed.HoursEstimated != null) {
                        <span class="mjt-pill mjt-pill--neutral">
                            <i class="fa-regular fa-clock" aria-hidden="true"></i>
                            {{ Parsed.HoursEstimated }}h
                        </span>
                    }
                    @for (tag of Parsed.TagNames; track tag) {
                        <span class="mjt-pill mjt-pill--neutral">
                            #{{ tag }}
                        </span>
                    }
                </div>
            }
        </div>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-qc {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 12px);
            padding: 8px 10px 8px 14px;
            box-shadow: var(--mj-shadow-sm, 0 1px 2px rgba(0, 0, 0, 0.04));
            transition: border-color 150ms ease, box-shadow 150ms ease;
        }
        .mjt-qc.is-compact {
            border-radius: var(--mj-radius-md, 8px);
            padding: 6px 8px 6px 12px;
        }
        .mjt-qc.is-focused {
            border-color: var(--mj-border-focus, var(--mj-brand-primary));
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 14%, transparent);
        }
        .mjt-qc-row {
            display: flex;
            align-items: center;
            gap: 8px;
            min-width: 0;
        }
        .mjt-qc-lead {
            color: var(--mj-brand-primary);
            font-size: 13px;
            flex-shrink: 0;
        }
        .mjt-qc-input {
            flex: 1;
            min-width: 0;
            border: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            padding: 6px 2px;
            outline: none;
        }
        .mjt-qc-input::placeholder {
            color: var(--mj-text-muted);
        }
        .mjt-qc-preview {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            padding-top: 8px;
            margin-top: 6px;
            border-top: 1px dashed var(--mj-border-subtle);
        }
        .mjt-chip-x {
            border: none;
            background: transparent;
            color: inherit;
            cursor: pointer;
            padding: 0 2px;
            font-size: 11px;
            opacity: 0.75;
        }
        .mjt-chip-x:hover {
            opacity: 1;
        }
        @media (max-width: 540px) {
            .mjt-qc-link-text {
                display: none;
            }
        }
        `,
    ],
})
export class TaskQuickCaptureComponent {
    @Input() Placeholder = 'Add a task... try "Call CFO tomorrow @Jordan #Finance !high"';
    @Input() SubmitLabel = 'Add';
    @Input() Compact = false;
    @Input() Busy = false;
    @Input() ShowLinkRecordButton = false;
    @Input() LinkedRecord: TaskWidgetLinkedRecord | null = null;
    @Input() LockedLinkedRecord = false;

    @Output() Submitted = new EventEmitter<TaskQuickCaptureSubmitEvent>();
    @Output() LinkRecordRequested = new EventEmitter<void>();
    @Output() ClearLinkedRecord = new EventEmitter<void>();

    public DraftText = '';
    public IsFocused = false;

    public get Parsed(): ParsedQuickTask {
        return ParseQuickTaskInput(this.DraftText);
    }

    public get HasPreviewChips(): boolean {
        const p = this.Parsed;
        return Boolean(
            this.LinkedRecord ||
            p.DueLabel ||
            p.AssigneeQuery ||
            p.Priority ||
            p.HoursEstimated != null ||
            p.TagNames.length > 0,
        );
    }

    public priorityPillClass(priority: string): string {
        switch (priority) {
            case 'Critical': return 'mjt-pill--error';
            case 'High': return 'mjt-pill--warning';
            case 'Medium': return 'mjt-pill--info';
            default: return 'mjt-pill--neutral';
        }
    }

    public submit(): void {
        if (this.Busy) return;
        const parsed = this.Parsed;
        if (!parsed.Title) return;
        const raw = this.DraftText.trim();
        this.DraftText = '';
        this.Submitted.emit({
            RawText: raw,
            Title: parsed.Title,
            Priority: parsed.Priority,
            DueAt: parsed.DueAt,
            AssigneeQuery: parsed.AssigneeQuery,
            TagNames: parsed.TagNames,
            HoursEstimated: parsed.HoursEstimated,
            LinkedRecord: this.LinkedRecord,
        });
    }
}
