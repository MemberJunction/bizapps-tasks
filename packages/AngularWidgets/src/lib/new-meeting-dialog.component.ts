import { ChangeDetectionStrategy, Component, EventEmitter, Input, OnChanges, Output, SimpleChanges } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { isValidTimeZone } from '@mj-biz-apps/tasks-core';
import { MEETING_TOKENS_CSS } from './tokens';
import { fromLocalInputValue, toLocalInputValue, viewerTimeZone } from './format';
import type { MeetingTypeOption, NewMeetingDraft, PersonOption, VideoProviderOption } from './types';

export function emptyMeetingDraft(timeZone: string): NewMeetingDraft {
    const starts = new Date();
    starts.setDate(starts.getDate() + 1);
    starts.setMinutes(0, 0, 0);
    return { name: '', typeId: null, startsAt: starts, durationMinutes: 60, timeZone, locationType: 'Virtual', location: '', videoProviderId: null, joinUrl: '', visibility: 'Standard', description: '', attendeePersonIds: [], guestEmails: [], applyTemplate: true };
}

/**
 * The new-meeting form: a title, a type (which sets the length, place and visibility), when and in which zone, where,
 * who, and whether the type's agenda template is applied. Emits the draft; the host makes the meeting through
 * MeetingService.
 */
@Component({
    selector: 'bizapps-new-meeting-form',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <form class="editor" (ngSubmit)="submit()" aria-label="New meeting">
            <div class="mjt-row wrap">
                <label class="mjt-grow"><span class="mjt-label">Title</span><input class="mjt-input" name="name" [(ngModel)]="draft.name" required maxlength="255" autocomplete="off" /></label>
                <label><span class="mjt-label">Type</span>
                    <select class="mjt-select" name="type" [(ngModel)]="draft.typeId" (ngModelChange)="typeChosen()">
                        <option [ngValue]="null">—</option>
                        @for (type of Types; track type.id) { <option [ngValue]="type.id">{{ type.name }}</option> }
                    </select>
                </label>
            </div>
            <div class="mjt-row wrap">
                <label><span class="mjt-label">Starts</span><input class="mjt-input" name="starts" type="datetime-local" [ngModel]="startsValue" (ngModelChange)="setStarts($event)" required /></label>
                <label class="minutes"><span class="mjt-label">Minutes</span><input class="mjt-input" name="minutes" type="number" min="5" step="5" [(ngModel)]="draft.durationMinutes" required /></label>
                <label class="mjt-grow"><span class="mjt-label">Time zone</span><input class="mjt-input" name="zone" [(ngModel)]="draft.timeZone" list="mjt-zones-new" placeholder="America/Chicago" required /></label>
                <datalist id="mjt-zones-new">@for (zone of Zones; track zone) { <option [value]="zone"></option> }</datalist>
            </div>
            @if (!ZoneOk) { <div class="mjt-callout mjt-callout--error">"{{ draft.timeZone }}" is not a time zone. Use an IANA name such as America/Chicago.</div> }
            <div class="mjt-row wrap">
                <label><span class="mjt-label">Where</span>
                    <select class="mjt-select" name="locationType" [(ngModel)]="draft.locationType">
                        <option value="Virtual">Online</option><option value="InPerson">In person</option><option value="Hybrid">In person and online</option><option value="Phone">By phone</option>
                    </select>
                </label>
                @if (draft.locationType !== 'Virtual') { <label class="mjt-grow"><span class="mjt-label">Room or address</span><input class="mjt-input" name="location" [(ngModel)]="draft.location" /></label> }
                @if (draft.locationType === 'Virtual' || draft.locationType === 'Hybrid') {
                    <label><span class="mjt-label">Video</span>
                        <select class="mjt-select" name="provider" [(ngModel)]="draft.videoProviderId">
                            <option [ngValue]="null">A link I type</option>
                            @for (provider of VideoProviders; track provider.id) { <option [ngValue]="provider.id">{{ provider.name }}</option> }
                        </select>
                    </label>
                    @if (!draft.videoProviderId) { <label class="mjt-grow"><span class="mjt-label">Join link</span><input class="mjt-input" name="joinUrl" type="url" [(ngModel)]="draft.joinUrl" placeholder="https://" /></label> }
                }
                <label><span class="mjt-label">Who sees it</span>
                    <select class="mjt-select" name="visibility" [(ngModel)]="draft.visibility">
                        <option value="Standard">Anyone who reads meetings</option><option value="Private">Its attendees only</option>
                    </select>
                </label>
            </div>
            <label><span class="mjt-label">Purpose</span><textarea class="mjt-textarea" name="description" rows="2" [(ngModel)]="draft.description"></textarea></label>
            <div class="people">
                <span class="mjt-label">Invite</span>
                <div class="chips">
                    @for (id of draft.attendeePersonIds; track id) { <span class="mjt-chip mjt-chip--brand">{{ personName(id) }} <button type="button" class="x" (click)="removePerson(id)" [attr.aria-label]="'Remove ' + personName(id)">×</button></span> }
                    @for (email of draft.guestEmails; track email) { <span class="mjt-chip">{{ email }} <button type="button" class="x" (click)="removeGuest(email)" [attr.aria-label]="'Remove ' + email">×</button></span> }
                </div>
                <div class="mjt-row wrap">
                    <select class="mjt-select mjt-grow" name="person" [ngModel]="null" (ngModelChange)="addPerson($event)" aria-label="Add a person">
                        <option [ngValue]="null">Add a person…</option>
                        @for (person of People; track person.id) { @if (!draft.attendeePersonIds.includes(person.id)) { <option [ngValue]="person.id">{{ person.name }}</option> } }
                    </select>
                    <input class="mjt-input mjt-grow" name="guest" type="email" [(ngModel)]="guest" placeholder="Or a guest's email" (keydown.enter)="addGuest(); $event.preventDefault()" aria-label="A guest's email" />
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="!guest.trim()" (click)="addGuest()">Add guest</button>
                </div>
            </div>
            @if (TypeHasTemplate) {
                <label class="check"><input type="checkbox" name="template" [(ngModel)]="draft.applyTemplate" /> Start the agenda from the type's template</label>
            }
            @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
            <div class="mjt-row">
                <span class="mjt-grow"></span>
                <button mjButton type="button" Variant="secondary" Size="md" [disabled]="Busy" (click)="CancelRequested.emit()">Cancel</button>
                <button mjButton type="submit" Variant="primary" Size="md" [disabled]="Busy || !CanSubmit">{{ Busy ? 'Scheduling…' : 'Schedule meeting' }}</button>
            </div>
        </form>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .editor { display: flex; flex-direction: column; gap: 12px; color: var(--mjt-text); }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .minutes { width: 90px; }
        .people { display: flex; flex-direction: column; gap: 6px; }
        .chips { display: flex; flex-wrap: wrap; gap: 6px; }
        .x { border: 0; background: transparent; color: inherit; font: inherit; cursor: pointer; padding: 0 2px; }
        .check { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; }
    `],
})
export class NewMeetingFormComponent implements OnChanges {
    @Input() Value: NewMeetingDraft = emptyMeetingDraft(viewerTimeZone());
    @Input() Types: MeetingTypeOption[] = [];
    @Input() People: PersonOption[] = [];
    @Input() VideoProviders: VideoProviderOption[] = [];
    /** The type ids that carry an agenda template, so the checkbox is offered. */
    @Input() TypesWithTemplate: string[] = [];
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Output() SubmitRequested = new EventEmitter<NewMeetingDraft>();
    @Output() CancelRequested = new EventEmitter<void>();

    public draft: NewMeetingDraft = emptyMeetingDraft(viewerTimeZone());
    public guest = '';
    public readonly Zones: string[] = typeof Intl.supportedValuesOf === 'function' ? Intl.supportedValuesOf('timeZone') : [];

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['Value']) this.draft = { ...this.Value, attendeePersonIds: [...this.Value.attendeePersonIds], guestEmails: [...this.Value.guestEmails] };
    }

    public get ZoneOk(): boolean {
        return isValidTimeZone(this.draft.timeZone);
    }

    public get startsValue(): string {
        return toLocalInputValue(this.draft.startsAt, this.ZoneOk ? this.draft.timeZone : 'UTC');
    }

    public setStarts(value: string): void {
        const instant = fromLocalInputValue(value, this.ZoneOk ? this.draft.timeZone : 'UTC');
        if (instant) this.draft.startsAt = instant;
    }

    public get TypeHasTemplate(): boolean {
        return !!this.draft.typeId && this.TypesWithTemplate.some((id) => id.toLowerCase() === this.draft.typeId!.toLowerCase());
    }

    public typeChosen(): void {
        const type = this.Types.find((t) => t.id === this.draft.typeId);
        if (type?.defaultDurationMinutes) this.draft.durationMinutes = type.defaultDurationMinutes;
        if (type?.defaultLocationType) this.draft.locationType = type.defaultLocationType;
        if (type?.defaultVisibility) this.draft.visibility = type.defaultVisibility;
    }

    public personName(id: string): string {
        return this.People.find((p) => p.id === id)?.name ?? id;
    }

    public addPerson(id: string | null): void {
        if (id && !this.draft.attendeePersonIds.includes(id)) this.draft.attendeePersonIds = [...this.draft.attendeePersonIds, id];
    }

    public removePerson(id: string): void {
        this.draft.attendeePersonIds = this.draft.attendeePersonIds.filter((p) => p !== id);
    }

    public addGuest(): void {
        const email = this.guest.trim().toLowerCase();
        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return;
        if (!this.draft.guestEmails.includes(email)) this.draft.guestEmails = [...this.draft.guestEmails, email];
        this.guest = '';
    }

    public removeGuest(email: string): void {
        this.draft.guestEmails = this.draft.guestEmails.filter((g) => g !== email);
    }

    public get CanSubmit(): boolean {
        return !!this.draft.name.trim() && this.ZoneOk && this.draft.durationMinutes > 0;
    }

    public submit(): void {
        if (!this.CanSubmit) return;
        this.SubmitRequested.emit({ ...this.draft, name: this.draft.name.trim(), location: this.draft.location.trim(), joinUrl: this.draft.joinUrl.trim() });
    }
}
