import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJDialogComponent } from '@memberjunction/ng-ui-components';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskCommandPaletteItem } from './task-models';

/**
 * Keyboard-first `⌘K` Command Palette built on MJ's `<mj-dialog>` (L1 presentational widget).
 *
 * Filters commands and tasks in real time with `↑` / `↓` / `Enter` / `Esc` navigation.
 */
@Component({
    selector: 'mjt-command-palette',
    standalone: true,
    imports: [FormsModule, MJDialogComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-dialog
            [Visible]="Visible"
            Title="Command Palette"
            [Width]="560"
            (Close)="onClose()">
            <div class="mjt-cmdk">
                <div class="mjt-cmdk-search">
                    <i class="fa-solid fa-magnifying-glass mjt-cmdk-ic" aria-hidden="true"></i>
                    <input
                        type="text"
                        class="mjt-cmdk-input"
                        [(ngModel)]="Query"
                        (ngModelChange)="ActiveIndex = 0"
                        placeholder="Jump to a task, switch view, or run an action..."
                        aria-label="Search tasks and commands"
                        (keydown)="onKeyDown($event)" />
                    <kbd class="mjt-kbd">Esc</kbd>
                </div>

                <div class="mjt-cmdk-results" role="listbox">
                    @if (FilteredItems.length === 0) {
                        <div class="mjt-cmdk-empty">No matching commands or tasks.</div>
                    } @else {
                        @for (item of FilteredItems; track item.ID; let i = $index) {
                            <button
                                type="button"
                                role="option"
                                class="mjt-cmdk-row"
                                [class.is-active]="i === ActiveIndex"
                                [attr.aria-selected]="i === ActiveIndex"
                                (mouseenter)="ActiveIndex = i"
                                (click)="select(item)">
                                @if (item.Group === 'Tasks' && item.Status) {
                                    <span
                                        class="mjt-cmdk-ring"
                                        [class.is-progress]="item.Status === 'InProgress'"
                                        [class.is-done]="item.Status === 'Completed'"
                                        [class.is-blocked]="item.Status === 'Blocked'"
                                        [attr.aria-label]="formatStatusText(item.Status)">
                                        @if (item.Status === 'Completed') {
                                            <i class="fa-solid fa-check" aria-hidden="true"></i>
                                        } @else if (item.Status === 'Blocked') {
                                            <i class="fa-solid fa-exclamation" aria-hidden="true"></i>
                                        } @else if (item.Status === 'InProgress') {
                                            <span class="mjt-cmdk-ring-dot" aria-hidden="true"></span>
                                        }
                                    </span>
                                } @else {
                                    <i [class]="item.IconClass + ' mjt-cmdk-row-ic'" aria-hidden="true"></i>
                                }
                                <div class="mjt-cmdk-row-copy">
                                    <span class="mjt-cmdk-row-label">{{ item.Label }}</span>
                                    @if (item.Subtitle) {
                                        <span class="mjt-cmdk-row-sub">{{ formatSubtitle(item.Subtitle) }}</span>
                                    }
                                </div>
                                <span class="mjt-pill mjt-pill--neutral">{{ item.Group }}</span>
                                @if (item.Shortcut) {
                                    <kbd class="mjt-kbd">{{ item.Shortcut }}</kbd>
                                }
                            </button>
                        }
                    }
                </div>

                <div class="mjt-cmdk-footer" aria-hidden="true">
                    <span class="mjt-cmdk-hints">
                        <kbd class="mjt-kbd">↑↓</kbd> Navigate
                        <kbd class="mjt-kbd">↵</kbd> Open
                    </span>
                    <span class="mjt-cmdk-count mjt-mono">{{ FilteredItems.length }} of {{ Items.length }} items</span>
                </div>
            </div>
        </mj-dialog>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-cmdk {
            display: flex;
            flex-direction: column;
            gap: 10px;
            min-width: 0;
        }
        .mjt-cmdk-search {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-cmdk-ic {
            color: var(--mj-text-muted);
            font-size: 13px;
        }
        .mjt-cmdk-input {
            flex: 1;
            min-width: 0;
            border: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            outline: none;
        }
        .mjt-kbd {
            padding: 2px 6px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-muted);
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
        }
        .mjt-cmdk-results {
            display: flex;
            flex-direction: column;
            gap: 4px;
            max-height: 360px;
            overflow-y: auto;
        }
        .mjt-cmdk-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 10px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid transparent;
            background: transparent;
            color: var(--mj-text-primary);
            text-align: left;
            font-family: inherit;
            cursor: pointer;
            width: 100%;
        }
        .mjt-cmdk-row.is-active,
        .mjt-cmdk-row:hover {
            background: var(--mj-bg-surface-hover);
            border-color: var(--mj-border-default);
        }
        .mjt-cmdk-row-ic {
            width: 18px;
            text-align: center;
            color: var(--mj-brand-primary);
            font-size: 13px;
            flex-shrink: 0;
        }
        .mjt-cmdk-ring {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 2px solid var(--mj-border-strong);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 9px;
            color: var(--mj-text-inverse);
        }
        .mjt-cmdk-ring.is-progress {
            border-color: var(--mj-brand-primary);
        }
        .mjt-cmdk-ring-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--mj-brand-primary);
        }
        .mjt-cmdk-ring.is-done {
            background: var(--mj-status-success);
            border-color: var(--mj-status-success);
        }
        .mjt-cmdk-ring.is-blocked {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
        }
        .mjt-cmdk-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            padding-top: 8px;
            border-top: 1px solid var(--mj-border-default);
            font-size: 11.5px;
            color: var(--mj-text-muted);
        }
        .mjt-cmdk-hints {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-cmdk-count {
            font-size: 11px;
        }
        .mjt-cmdk-row-copy {
            flex: 1;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }
        .mjt-cmdk-row-label {
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .mjt-cmdk-row-sub {
            font-size: 11.5px;
            color: var(--mj-text-muted);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .mjt-cmdk-empty {
            padding: 24px;
            text-align: center;
            font-size: var(--mj-text-sm, 14px);
            color: var(--mj-text-muted);
        }
        `,
    ],
})
export class TaskCommandPaletteComponent {
    @Input() Visible = false;
    @Input() Items: readonly TaskCommandPaletteItem[] = [];

    @Output() ItemSelected = new EventEmitter<TaskCommandPaletteItem>();
    @Output() Closed = new EventEmitter<void>();

    public Query = '';
    public ActiveIndex = 0;

    public get FilteredItems(): TaskCommandPaletteItem[] {
        const q = this.Query.trim().toLowerCase();
        if (!q) return [...this.Items].slice(0, 14);
        return this.Items.filter(
            (i) =>
                i.Label.toLowerCase().includes(q) ||
                (i.Subtitle?.toLowerCase().includes(q) ?? false) ||
                i.Group.toLowerCase().includes(q),
        ).slice(0, 14);
    }

    public onKeyDown(event: KeyboardEvent): void {
        const list = this.FilteredItems;
        if (event.key === 'ArrowDown') {
            event.preventDefault();
            this.ActiveIndex = list.length > 0 ? (this.ActiveIndex + 1) % list.length : 0;
        } else if (event.key === 'ArrowUp') {
            event.preventDefault();
            this.ActiveIndex = list.length > 0 ? (this.ActiveIndex - 1 + list.length) % list.length : 0;
        } else if (event.key === 'Enter' && list[this.ActiveIndex]) {
            event.preventDefault();
            this.select(list[this.ActiveIndex]);
        }
    }

    public select(item: TaskCommandPaletteItem): void {
        this.Query = '';
        this.ActiveIndex = 0;
        this.ItemSelected.emit(item);
    }

    public formatStatusText(status: string): string {
        return status.replace(/([a-z])([A-Z])/g, '$1 $2');
    }

    public formatSubtitle(subtitle: string): string {
        return subtitle
            .replace(/\bInProgress\b/g, 'In Progress')
            .replace(/\bNotStarted\b/g, 'Not Started')
            .replace(/\bStatusChange\b/g, 'Status Change');
    }

    public onClose(): void {
        this.Query = '';
        this.ActiveIndex = 0;
        this.Closed.emit();
    }
}
