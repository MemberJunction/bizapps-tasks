import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { MEETING_TOKENS_CSS } from './tokens';
import type { ResponseStatus } from './types';

/**
 * The answer control: Going, Maybe, Not going, as a segmented group, with the current answer pressed. The host saves
 * the attendee's ResponseStatus when it changes.
 */
@Component({
    selector: 'bizapps-attendee-response',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="seg" role="group" [attr.aria-label]="AriaLabel">
            <button type="button" class="opt ok" [class.on]="Value === 'Accepted'" [disabled]="Disabled" [attr.aria-pressed]="Value === 'Accepted'" (click)="choose('Accepted')">
                <i class="fa-solid fa-check" aria-hidden="true"></i>Going
            </button>
            <button type="button" class="opt maybe" [class.on]="Value === 'Tentative'" [disabled]="Disabled" [attr.aria-pressed]="Value === 'Tentative'" (click)="choose('Tentative')">
                <i class="fa-solid fa-question" aria-hidden="true"></i>Maybe
            </button>
            <button type="button" class="opt no" [class.on]="Value === 'Declined'" [disabled]="Disabled" [attr.aria-pressed]="Value === 'Declined'" (click)="choose('Declined')">
                <i class="fa-solid fa-xmark" aria-hidden="true"></i>Not going
            </button>
        </div>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: inline-block; }
        .seg { display: inline-flex; border: 1px solid var(--mjt-border-strong); border-radius: 999px; overflow: hidden; background: var(--mjt-surface); }
        .opt { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border: 0; background: transparent; color: var(--mjt-text-muted); font: inherit; font-size: 12px; font-weight: 600; cursor: pointer; }
        .opt + .opt { border-left: 1px solid var(--mjt-border); }
        .opt:hover:not(:disabled) { background: var(--mjt-surface-sunken); color: var(--mjt-text); }
        .opt:disabled { cursor: default; opacity: 0.6; }
        .opt.on.ok { background: var(--mjt-ok-bg); color: var(--mjt-ok-text); }
        .opt.on.maybe { background: var(--mjt-warn-bg); color: var(--mjt-warn-text); }
        .opt.on.no { background: var(--mjt-error-bg); color: var(--mjt-error-text); }
        .opt:focus-visible { outline: 2px solid var(--mjt-brand); outline-offset: -2px; }
    `],
})
export class AttendeeResponseComponent {
    @Input() Value: ResponseStatus | null = 'None';
    @Input() Disabled = false;
    @Input() AriaLabel = 'Your answer';
    @Output() ValueChange = new EventEmitter<ResponseStatus>();

    public choose(next: ResponseStatus): void {
        if (this.Disabled || next === this.Value) return;
        this.ValueChange.emit(next);
    }
}
