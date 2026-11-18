import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatDayLong, formatSpan, formatTime, locationLabel, viewerTimeZone, zoneAbbreviation } from './format';
import { MeetingStatusChipComponent } from './meeting-chips.component';
import { AttendeeResponseComponent } from './attendee-response.component';
import type { MeetingPermissions, MeetingRow, ResponseStatus } from './types';

/**
 * The meeting page's header (the meetings plan, § 5): title, time in the viewer's zone and the meeting's own, type,
 * status, place or Join, the viewer's answer, and the organizer's actions: start, run, end, cancel, the `.ics`.
 */
@Component({
    selector: 'bizapps-meeting-header',
    standalone: true,
    imports: [MJButtonDirective, MeetingStatusChipComponent, AttendeeResponseComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="hero">
            <div class="icon"><i [class]="Meeting.typeIcon || 'fa-solid fa-calendar-check'" aria-hidden="true"></i></div>
            <div class="mjt-grow">
                <div class="mjt-row title-row">
                    <h1 class="title">{{ Meeting.name }}</h1>
                    <bizapps-meeting-status-chip [Status]="Meeting.status" [Visibility]="Meeting.visibility"></bizapps-meeting-status-chip>
                    @if (Meeting.typeName) { <span class="mjt-chip">{{ Meeting.typeName }}</span> }
                    @if (Meeting.seriesId) {
                        <button type="button" class="link" (click)="SeriesRequested.emit(Meeting.seriesId!)"><i class="fa-solid fa-repeat" aria-hidden="true"></i> Part of a series</button>
                    }
                </div>
                <div class="when">
                    <i class="fa-regular fa-clock" aria-hidden="true"></i>
                    <span class="mjt-strong">{{ DayLabel }}</span>
                    <span>{{ SpanLabel }}</span>
                    @if (ZoneDiffers) { <span class="mjt-muted mjt-small">({{ OwnZoneLabel }} where it is planned)</span> }
                </div>
                <div class="mjt-row meta mjt-small mjt-muted">
                    <span><i class="fa-solid fa-location-dot" aria-hidden="true"></i> {{ Where }}</span>
                    @if (Meeting.organizerName) { <span><i class="fa-solid fa-user" aria-hidden="true"></i> Organized by {{ Meeting.isMine ? 'you' : Meeting.organizerName }}</span> }
                    @if (Meeting.attendeeCount != null) { <span><i class="fa-solid fa-users" aria-hidden="true"></i> {{ Meeting.attendeeCount }} invited</span> }
                </div>
                @if (CancellationReason) { <div class="mjt-callout mjt-callout--error">Cancelled: {{ CancellationReason }}</div> }
            </div>
            <div class="actions">
                @if (Meeting.joinUrl && IsOpen) {
                    <a mjButton Variant="primary" Size="md" [href]="Meeting.joinUrl" target="_blank" rel="noopener"><i class="fa-solid fa-video"></i>Join</a>
                }
                @if (Permissions.canRun && Meeting.status === 'Scheduled') {
                    <button mjButton Variant="primary" Size="md" [disabled]="Busy" (click)="StartRequested.emit()"><i class="fa-solid fa-play"></i>Start meeting</button>
                }
                @if (Permissions.canRun && Meeting.status === 'InProgress') {
                    <button mjButton Variant="primary" Size="md" [disabled]="Busy" (click)="RunRequested.emit()"><i class="fa-solid fa-gauge-high"></i>Run meeting</button>
                    <button mjButton Variant="secondary" Size="md" [disabled]="Busy" (click)="EndRequested.emit()"><i class="fa-solid fa-stop"></i>End</button>
                }
                @if (Permissions.canRun && IsOpen) {
                    <button mjButton Variant="secondary" Size="md" [disabled]="Busy" (click)="CancelRequested.emit()"><i class="fa-solid fa-ban"></i>Cancel</button>
                }
                <button mjButton Variant="secondary" Size="md" [disabled]="Busy" (click)="CalendarFileRequested.emit()" title="Download the meeting as a calendar file"><i class="fa-solid fa-calendar-plus"></i>Add to calendar</button>
                @if (Meeting.myResponse !== null && !Meeting.isMine && IsOpen) {
                    <bizapps-attendee-response [Value]="Meeting.myResponse" [Disabled]="Busy" (ValueChange)="ResponseChanged.emit($event)"></bizapps-attendee-response>
                }
            </div>
        </div>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .hero { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-start; padding: 16px 20px; background: var(--mjt-surface); border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); color: var(--mjt-text); }
        .icon { width: 48px; height: 48px; border-radius: var(--mjt-radius); display: grid; place-items: center; background: var(--mjt-brand); color: var(--mjt-on-brand); font-size: 20px; flex: none; }
        /* the title keeps room to read; the actions drop below it when the row is too narrow for both */
        .hero > .mjt-grow { flex: 1 1 380px; }
        .title-row { flex-wrap: wrap; }
        .title { margin: 0; font-size: 20px; font-weight: 700; }
        .when { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; margin-top: 6px; font-size: 14px; }
        .meta { flex-wrap: wrap; gap: 6px 16px; margin-top: 6px; }
        .actions { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; justify-content: flex-end; }
        .link { border: 0; background: transparent; color: var(--mjt-brand); font: inherit; font-size: 12px; cursor: pointer; padding: 0; }
        .mjt-callout { margin-top: 8px; }
        @media (max-width: 760px) { .hero { flex-wrap: wrap; } .actions { width: 100%; justify-content: flex-start; } }
    `],
})
export class MeetingHeaderComponent {
    @Input({ required: true }) Meeting!: MeetingRow;
    @Input() Permissions: MeetingPermissions = { canEdit: false, canRun: false, canInvite: false, canWriteNotes: false, canAddFollowUps: false };
    @Input() CancellationReason: string | null = null;
    @Input() Busy = false;
    @Input() ViewerZone: string = viewerTimeZone();
    @Output() StartRequested = new EventEmitter<void>();
    @Output() RunRequested = new EventEmitter<void>();
    @Output() EndRequested = new EventEmitter<void>();
    @Output() CancelRequested = new EventEmitter<void>();
    @Output() CalendarFileRequested = new EventEmitter<void>();
    @Output() ResponseChanged = new EventEmitter<ResponseStatus>();
    @Output() SeriesRequested = new EventEmitter<string>();

    public get IsOpen(): boolean {
        return this.Meeting.status !== 'Cancelled' && this.Meeting.status !== 'Completed';
    }

    public get DayLabel(): string {
        return formatDayLong(this.Meeting.startsAt, this.ViewerZone);
    }

    public get SpanLabel(): string {
        return formatSpan(this.Meeting.startsAt, this.Meeting.endsAt, this.ViewerZone);
    }

    public get ZoneDiffers(): boolean {
        return zoneAbbreviation(this.Meeting.startsAt, this.Meeting.timeZone) !== zoneAbbreviation(this.Meeting.startsAt, this.ViewerZone);
    }

    public get OwnZoneLabel(): string {
        return `${formatTime(this.Meeting.startsAt, this.Meeting.timeZone)} ${zoneAbbreviation(this.Meeting.startsAt, this.Meeting.timeZone)}`;
    }

    public get Where(): string {
        return locationLabel(this.Meeting.locationType, this.Meeting.location, this.Meeting.joinUrl);
    }
}
