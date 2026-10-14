import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatDay, formatSpan, locationLabel, viewerTimeZone } from './format';
import { MeetingStatusChipComponent, ResponseChipComponent } from './meeting-chips.component';
import type { MeetingRow } from './types';

/** A meeting as a small card: for "Coming up" strips, a space's Overview, a dashboard. Click opens it. */
@Component({
    selector: 'bizapps-meeting-card',
    standalone: true,
    imports: [MeetingStatusChipComponent, ResponseChipComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <button type="button" class="card" [attr.aria-label]="'Open meeting ' + Meeting.name" (click)="OpenRequested.emit(Meeting)">
            <div class="when">
                <span class="day">{{ Day }}</span>
                <span class="mjt-small mjt-muted">{{ Span }}</span>
            </div>
            <div class="mjt-row name-row">
                @if (Meeting.typeIcon) { <i [class]="Meeting.typeIcon" aria-hidden="true"></i> }
                <span class="name">{{ Meeting.name }}</span>
            </div>
            <div class="mjt-small mjt-muted">{{ Where }}@if (Meeting.organizerName) { · {{ Meeting.isMine ? 'You organize' : Meeting.organizerName }}}</div>
            <div class="mjt-row chips">
                <bizapps-meeting-status-chip [Status]="Meeting.status" [Visibility]="Meeting.visibility"></bizapps-meeting-status-chip>
                @if (Meeting.myResponse !== null && !Meeting.isMine) { <bizapps-response-chip [Response]="Meeting.myResponse"></bizapps-response-chip> }
            </div>
        </button>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .card { display: flex; flex-direction: column; gap: 6px; width: 100%; text-align: left; padding: 12px 14px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); color: var(--mjt-text); font: inherit; cursor: pointer; }
        .card:hover { border-color: var(--mjt-border-strong); }
        .card:focus-visible { outline: 2px solid var(--mjt-brand); outline-offset: 2px; }
        .when { display: flex; justify-content: space-between; gap: 8px; }
        .day { font-size: 12px; font-weight: 700; color: var(--mjt-brand); }
        .name { font-weight: 700; font-size: 14px; }
        .chips { flex-wrap: wrap; }
    `],
})
export class MeetingCardComponent {
    @Input({ required: true }) Meeting!: MeetingRow;
    @Input() ViewerZone: string = viewerTimeZone();
    @Output() OpenRequested = new EventEmitter<MeetingRow>();

    public get Day(): string {
        return formatDay(this.Meeting.startsAt, this.ViewerZone);
    }

    public get Span(): string {
        return formatSpan(this.Meeting.startsAt, this.Meeting.endsAt, this.ViewerZone);
    }

    public get Where(): string {
        return locationLabel(this.Meeting.locationType, this.Meeting.location, this.Meeting.joinUrl);
    }
}
