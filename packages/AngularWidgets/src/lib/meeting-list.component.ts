import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { MJButtonDirective, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatDay, formatSpan, formatTime, locationLabel, viewerTimeZone, zoneAbbreviation } from './format';
import { MeetingStatusChipComponent, ResponseChipComponent } from './meeting-chips.component';
import { AttendeeResponseComponent } from './attendee-response.component';
import type { MeetingRow, ResponseStatus } from './types';

export interface MeetingResponseChange {
    meeting: MeetingRow;
    response: ResponseStatus;
}

export interface MeetingListGroup {
    key: string;
    label: string;
    meetings: MeetingRow[];
}

/** Meetings grouped by day in the viewer's zone, upcoming first. */
export function groupMeetingsByDay(meetings: readonly MeetingRow[], viewerZone: string, order: 'asc' | 'desc' = 'asc'): MeetingListGroup[] {
    const sorted = [...meetings].sort((a, b) => (order === 'asc' ? a.startsAt.getTime() - b.startsAt.getTime() : b.startsAt.getTime() - a.startsAt.getTime()));
    const groups = new Map<string, MeetingListGroup>();
    for (const meeting of sorted) {
        const key = new Intl.DateTimeFormat('en-CA', { timeZone: viewerZone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(meeting.startsAt);
        const group = groups.get(key) ?? { key, label: formatDay(meeting.startsAt, viewerZone), meetings: [] };
        group.meetings.push(meeting);
        groups.set(key, group);
    }
    return [...groups.values()];
}

/**
 * The meeting list: rows grouped by day, each with its time in the viewer's zone (and the meeting's own when that
 * differs), its type and status, where it is, and, when the viewer is invited, their answer. A row opens on click; the
 * answer control saves through the host.
 */
@Component({
    selector: 'bizapps-meeting-list',
    standalone: true,
    imports: [MJButtonDirective, MJEmptyStateComponent, MeetingStatusChipComponent, ResponseChipComponent, AttendeeResponseComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (IsLoading) {
            <div class="mjt-empty">Reading meetings…</div>
        } @else if (ErrorMessage) {
            <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div>
        } @else if (!Meetings.length) {
            <mj-empty-state Icon="fa-solid fa-calendar-check" [Title]="EmptyTitle" [Message]="EmptyMessage"></mj-empty-state>
        } @else {
            @for (group of Groups; track group.key) {
                <div class="day">{{ group.label }}</div>
                @for (meeting of group.meetings; track meeting.id) {
                    <div class="row" [class.selected]="SelectedID && SelectedID.toLowerCase() === meeting.id.toLowerCase()" [class.cancelled]="meeting.status === 'Cancelled'" role="button" tabindex="0"
                         [attr.aria-label]="'Meeting: ' + meeting.name" (click)="Selected.emit(meeting)" (keydown.enter)="Selected.emit(meeting)" (dblclick)="OpenRequested.emit(meeting)">
                        <div class="time">
                            <div class="mjt-strong">{{ timeOf(meeting) }}</div>
                            <div class="mjt-small mjt-muted">{{ spanOf(meeting) }}</div>
                            @if (zoneDiffers(meeting)) {
                                <div class="mjt-small mjt-muted" [title]="'The meeting is planned in ' + meeting.timeZone">{{ ownZoneTime(meeting) }}</div>
                            }
                        </div>
                        <div class="mjt-grow">
                            <div class="mjt-row name-row">
                                @if (meeting.typeIcon) { <i [class]="meeting.typeIcon" aria-hidden="true"></i> }
                                <span class="name">{{ meeting.name }}</span>
                                @if (meeting.seriesId) { <i class="fa-solid fa-repeat mjt-muted" title="Part of a series" aria-label="Part of a series"></i> }
                                <bizapps-meeting-status-chip [Status]="meeting.status" [Visibility]="meeting.visibility"></bizapps-meeting-status-chip>
                            </div>
                            <div class="mjt-small mjt-muted meta">
                                @if (meeting.typeName) { <span>{{ meeting.typeName }}</span> }
                                <span>{{ whereOf(meeting) }}</span>
                                @if (meeting.organizerName) { <span>Organized by {{ meeting.isMine ? 'you' : meeting.organizerName }}</span> }
                                @if (meeting.attendeeCount != null) { <span>{{ meeting.attendeeCount }} {{ meeting.attendeeCount === 1 ? 'person' : 'people' }}</span> }
                            </div>
                        </div>
                        <div class="actions" (click)="$event.stopPropagation()">
                            @if (meeting.joinUrl && meeting.status !== 'Cancelled' && meeting.status !== 'Completed') {
                                <a mjButton Variant="secondary" Size="sm" [href]="meeting.joinUrl" target="_blank" rel="noopener"><i class="fa-solid fa-video"></i>Join</a>
                            }
                            @if (ShowResponse && meeting.myResponse !== null && !meeting.isMine && meeting.status !== 'Cancelled' && meeting.status !== 'Completed') {
                                <bizapps-attendee-response [Value]="meeting.myResponse" [Disabled]="ResponseBusyID === meeting.id" (ValueChange)="ResponseChanged.emit({ meeting, response: $event })"></bizapps-attendee-response>
                            } @else if (ShowResponse && meeting.isMine) {
                                <span class="mjt-chip mjt-chip--brand"><i class="fa-solid fa-star" aria-hidden="true"></i>Organizer</span>
                            } @else if (ShowResponse && meeting.myResponse !== null) {
                                <bizapps-response-chip [Response]="meeting.myResponse"></bizapps-response-chip>
                            }
                        </div>
                    </div>
                }
            }
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .day { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: var(--mjt-text-muted); padding: 14px 4px 6px; }
        .row { display: flex; align-items: center; gap: 14px; padding: 12px 14px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); color: var(--mjt-text); cursor: pointer; margin-bottom: 8px; }
        .row:hover { border-color: var(--mjt-border-strong); }
        .row.selected { border-color: var(--mjt-brand); box-shadow: 0 0 0 1px var(--mjt-brand) inset; }
        .row.cancelled .name { text-decoration: line-through; color: var(--mjt-text-muted); }
        .row:focus-visible { outline: 2px solid var(--mjt-brand); outline-offset: 2px; }
        .time { min-width: 110px; }
        .name-row { flex-wrap: wrap; }
        .name { font-weight: 700; font-size: 14px; }
        .meta { display: flex; flex-wrap: wrap; gap: 4px 12px; margin-top: 4px; }
        .actions { display: flex; align-items: center; gap: 8px; }
        @media (max-width: 640px) { .row { flex-wrap: wrap; } .actions { width: 100%; justify-content: flex-end; } }
    `],
})
export class MeetingListComponent {
    @Input() Meetings: MeetingRow[] = [];
    @Input() IsLoading = false;
    @Input() ErrorMessage = '';
    @Input() EmptyTitle = 'No meetings';
    @Input() EmptyMessage = 'Nothing is scheduled here yet.';
    @Input() SelectedID: string | null = null;
    @Input() ShowResponse = true;
    /** The meeting whose answer is being saved: its control is held. */
    @Input() ResponseBusyID: string | null = null;
    @Input() Order: 'asc' | 'desc' = 'asc';
    @Input() ViewerZone: string = viewerTimeZone();
    @Output() Selected = new EventEmitter<MeetingRow>();
    @Output() OpenRequested = new EventEmitter<MeetingRow>();
    @Output() ResponseChanged = new EventEmitter<MeetingResponseChange>();

    public get Groups(): MeetingListGroup[] {
        return groupMeetingsByDay(this.Meetings, this.ViewerZone, this.Order);
    }

    public timeOf(meeting: MeetingRow): string {
        return formatTime(meeting.startsAt, this.ViewerZone);
    }

    public spanOf(meeting: MeetingRow): string {
        return formatSpan(meeting.startsAt, meeting.endsAt, this.ViewerZone);
    }

    public zoneDiffers(meeting: MeetingRow): boolean {
        return zoneAbbreviation(meeting.startsAt, meeting.timeZone) !== zoneAbbreviation(meeting.startsAt, this.ViewerZone);
    }

    public ownZoneTime(meeting: MeetingRow): string {
        return `${formatTime(meeting.startsAt, meeting.timeZone)} ${zoneAbbreviation(meeting.startsAt, meeting.timeZone)} there`;
    }

    public whereOf(meeting: MeetingRow): string {
        return locationLabel(meeting.locationType, meeting.location, meeting.joinUrl);
    }
}
