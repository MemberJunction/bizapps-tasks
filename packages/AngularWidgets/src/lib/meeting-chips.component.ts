import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { MEETING_TOKENS_CSS } from './tokens';
import { responseLabel, statusChipClass, statusLabel } from './format';
import type { MeetingStatus, MeetingVisibility, ResponseStatus } from './types';

/** A meeting's status as a chip, with Private marked beside it when it is. */
@Component({
    selector: 'bizapps-meeting-status-chip',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <span [class]="StatusClass" [attr.aria-label]="'Status: ' + Label">{{ Label }}</span>
        @if (Visibility === 'Private') {
            <span class="mjt-chip" title="Only its attendees see this meeting"><i class="fa-solid fa-lock" aria-hidden="true"></i>Private</span>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `:host { display: inline-flex; gap: 6px; align-items: center; }`],
})
export class MeetingStatusChipComponent {
    @Input() Status: MeetingStatus = 'Scheduled';
    @Input() Visibility: MeetingVisibility = 'Standard';

    public get Label(): string {
        return statusLabel(this.Status);
    }

    public get StatusClass(): string {
        return statusChipClass(this.Status);
    }
}

/** The viewer's answer to an invitation as a chip. */
@Component({
    selector: 'bizapps-response-chip',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<span [class]="Class"><i [class]="Icon" aria-hidden="true"></i>{{ Label }}</span>`,
    styles: [MEETING_TOKENS_CSS, `:host { display: inline-flex; }`],
})
export class ResponseChipComponent {
    @Input() Response: ResponseStatus | null = null;

    public get Label(): string {
        return responseLabel(this.Response);
    }

    public get Class(): string {
        switch (this.Response) {
            case 'Accepted':
                return 'mjt-chip mjt-chip--ok';
            case 'Tentative':
                return 'mjt-chip mjt-chip--warn';
            case 'Declined':
                return 'mjt-chip mjt-chip--error';
            default:
                return 'mjt-chip';
        }
    }

    public get Icon(): string {
        switch (this.Response) {
            case 'Accepted':
                return 'fa-solid fa-check';
            case 'Tentative':
                return 'fa-solid fa-question';
            case 'Declined':
                return 'fa-solid fa-xmark';
            default:
                return 'fa-regular fa-circle';
        }
    }
}
