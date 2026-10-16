import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { ResponseChipComponent } from './meeting-chips.component';
import type { AttendanceStatus, AttendeeModel, PersonOption } from './types';

export interface InviteRequest {
    personId: string | null;
    email: string | null;
    displayName: string | null;
    role: 'Required' | 'Optional';
}

export interface AttendanceChange {
    attendee: AttendeeModel;
    attendance: AttendanceStatus;
}

const ATTENDANCE: ReadonlyArray<{ value: AttendanceStatus; label: string }> = [
    { value: 'Unknown', label: '—' },
    { value: 'Present', label: 'Present' },
    { value: 'Late', label: 'Late' },
    { value: 'LeftEarly', label: 'Left early' },
    { value: 'Absent', label: 'Absent' },
    { value: 'Excused', label: 'Excused' },
];

/**
 * The People section: who is invited, their answer, and whether they came; an invite form for a person (from the host's
 * list) or a guest by email; removal. The organizer's row is marked and never removed here.
 */
@Component({
    selector: 'bizapps-meeting-people',
    standalone: true,
    imports: [FormsModule, MJButtonDirective, ResponseChipComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow"><span class="mjt-strong">People</span> <span class="mjt-muted mjt-small">{{ Attendees.length }} invited</span></div>
            @if (CanInvite && !inviting) {
                <button mjButton Variant="secondary" Size="sm" (click)="inviting = true"><i class="fa-solid fa-user-plus"></i>Invite</button>
            }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (inviting) {
            <form class="invite" (ngSubmit)="submitInvite()" aria-label="Invite someone">
                <div class="mjt-row wrap">
                    <label class="mjt-grow">
                        <span class="mjt-label">A person</span>
                        <select class="mjt-select" name="person" [(ngModel)]="invitePersonId">
                            <option [ngValue]="null">Choose…</option>
                            @for (person of People; track person.id) { <option [ngValue]="person.id">{{ person.name }}@if (person.email) { ({{ person.email }})}</option> }
                        </select>
                    </label>
                    <span class="mjt-muted mjt-small">or</span>
                    <label class="mjt-grow">
                        <span class="mjt-label">A guest, by email</span>
                        <input class="mjt-input" name="email" type="email" [(ngModel)]="inviteEmail" placeholder="name@example.org" autocomplete="off" />
                    </label>
                    <label>
                        <span class="mjt-label">Role</span>
                        <select class="mjt-select" name="role" [(ngModel)]="inviteRole">
                            <option value="Required">Required</option>
                            <option value="Optional">Optional</option>
                        </select>
                    </label>
                </div>
                <div class="mjt-row">
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="inviting = false">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || (!invitePersonId && !inviteEmail.trim())">Send invitation</button>
                </div>
            </form>
        }
        @if (!Attendees.length) {
            <div class="mjt-empty">Nobody is invited yet.</div>
        }
        @for (attendee of Attendees; track attendee.id) {
            <div class="person" [class.me]="attendee.isMe">
                <div class="avatar" aria-hidden="true">{{ initials(attendee) }}</div>
                <div class="mjt-grow">
                    <div class="mjt-row wrap">
                        <span class="mjt-strong">{{ attendee.name }}</span>
                        @if (attendee.isMe) { <span class="mjt-small mjt-muted">(you)</span> }
                        @if (attendee.role === 'Organizer') { <span class="mjt-chip mjt-chip--brand"><i class="fa-solid fa-star" aria-hidden="true"></i>Organizer</span> }
                        @else if (attendee.role === 'Optional') { <span class="mjt-chip">Optional</span> }
                        @if (!attendee.personId) { <span class="mjt-chip" title="Invited by email">Guest</span> }
                    </div>
                    @if (attendee.email) { <div class="mjt-small mjt-muted">{{ attendee.email }}</div> }
                </div>
                <bizapps-response-chip [Response]="attendee.responseStatus"></bizapps-response-chip>
                @if (ShowAttendance) {
                    <label class="attendance">
                        <span class="visually-hidden">Attendance of {{ attendee.name }}</span>
                        <select class="mjt-select" [ngModel]="attendee.attendanceStatus" [disabled]="!CanMarkAttendance || Busy" (ngModelChange)="AttendanceChanged.emit({ attendee, attendance: $event })" [name]="'attendance-' + attendee.id">
                            @for (option of AttendanceOptions; track option.value) { <option [value]="option.value">{{ option.label }}</option> }
                        </select>
                    </label>
                }
                @if (CanInvite && attendee.role !== 'Organizer') {
                    <button mjButton Variant="icon" Size="sm" [disabled]="Busy" [attr.aria-label]="'Remove ' + attendee.name" (click)="RemoveRequested.emit(attendee)"><i class="fa-solid fa-xmark" aria-hidden="true"></i></button>
                }
            </div>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 8px; }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .invite { display: flex; flex-direction: column; gap: 10px; padding: 12px; border: 1px dashed var(--mjt-border-strong); border-radius: var(--mjt-radius-lg); margin-bottom: 10px; }
        .person { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); margin-bottom: 6px; color: var(--mjt-text); }
        .person.me { border-color: var(--mjt-brand); }
        .avatar { width: 34px; height: 34px; border-radius: 50%; display: grid; place-items: center; background: var(--mjt-brand-subtle); color: var(--mjt-brand); font-size: 12px; font-weight: 700; flex: none; }
        .attendance .mjt-select { width: auto; min-width: 110px; padding: 4px 8px; font-size: 12px; }
        .visually-hidden { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); }
    `],
})
export class MeetingPeopleComponent {
    @Input() Attendees: AttendeeModel[] = [];
    @Input() People: PersonOption[] = [];
    @Input() CanInvite = false;
    @Input() CanMarkAttendance = false;
    @Input() ShowAttendance = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Output() InviteRequested = new EventEmitter<InviteRequest>();
    @Output() RemoveRequested = new EventEmitter<AttendeeModel>();
    @Output() AttendanceChanged = new EventEmitter<AttendanceChange>();

    public inviting = false;
    public invitePersonId: string | null = null;
    public inviteEmail = '';
    public inviteRole: 'Required' | 'Optional' = 'Required';
    public readonly AttendanceOptions = ATTENDANCE;

    public submitInvite(): void {
        const email = this.inviteEmail.trim().toLowerCase();
        if (!this.invitePersonId && !email) return;
        this.InviteRequested.emit({ personId: this.invitePersonId, email: this.invitePersonId ? null : email, displayName: null, role: this.inviteRole });
        this.inviting = false;
        this.invitePersonId = null;
        this.inviteEmail = '';
        this.inviteRole = 'Required';
    }

    public initials(attendee: AttendeeModel): string {
        const source = attendee.name || attendee.email || '?';
        const parts = source.split(/[\s@.]+/).filter(Boolean);
        return (parts.length > 1 ? parts[0][0] + parts[1][0] : source.slice(0, 2)).toUpperCase();
    }
}
