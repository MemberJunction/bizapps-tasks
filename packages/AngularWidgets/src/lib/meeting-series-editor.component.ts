import { ChangeDetectionStrategy, Component, EventEmitter, Input, OnChanges, Output, SimpleChanges } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { expandOccurrences, isValidTimeZone } from '@mj-biz-apps/tasks-core';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatDay, formatTime, fromLocalInputValue, toLocalInputValue, viewerTimeZone, zoneAbbreviation } from './format';
import { WEEKDAYS, buildRecurrenceRule, describeRecurrenceRule, emptySeriesRule, parseRecurrenceRuleDraft } from './series-rule';
import type { MeetingLocationType, MeetingTypeOption, MeetingVisibility, SeriesRuleDraft, VideoProviderOption } from './types';

export interface SeriesDraft {
    id: string | null;
    name: string;
    description: string;
    typeId: string | null;
    organizerPersonId: string | null;
    timeZone: string;
    firstStartsAt: Date;
    durationMinutes: number;
    locationType: MeetingLocationType;
    location: string;
    videoProviderId: string | null;
    visibility: MeetingVisibility;
    recurrenceRule: string;
}

export function emptySeriesDraft(timeZone: string, organizerPersonId: string | null): SeriesDraft {
    const first = new Date();
    first.setDate(first.getDate() + 7);
    first.setMinutes(0, 0, 0);
    return { id: null, name: '', description: '', typeId: null, organizerPersonId, timeZone, firstStartsAt: first, durationMinutes: 60, locationType: 'Virtual', location: '', videoProviderId: null, visibility: 'Standard', recurrenceRule: buildRecurrenceRule(emptySeriesRule()) };
}

/**
 * The series editor (the meetings plan, § 5): name, type, when the first one is and how long, the rule (every day,
 * week on days, or month; an interval; ending never, by date or after a count), where, and a preview of the next
 * occurrences in the series' zone. Emits the draft with its RRULE; the host saves it.
 */
@Component({
    selector: 'bizapps-meeting-series-editor',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <form class="editor" (ngSubmit)="submit()" aria-label="Meeting series">
            <div class="mjt-row wrap">
                <label class="mjt-grow"><span class="mjt-label">Name</span><input class="mjt-input" name="name" [(ngModel)]="draft.name" required maxlength="255" autocomplete="off" /></label>
                <label><span class="mjt-label">Type</span>
                    <select class="mjt-select" name="type" [(ngModel)]="draft.typeId" (ngModelChange)="typeChosen()">
                        <option [ngValue]="null">—</option>
                        @for (type of Types; track type.id) { <option [ngValue]="type.id">{{ type.name }}</option> }
                    </select>
                </label>
            </div>
            <label><span class="mjt-label">Purpose</span><textarea class="mjt-textarea" name="description" rows="2" [(ngModel)]="draft.description"></textarea></label>
            <div class="mjt-row wrap">
                <label><span class="mjt-label">First meeting</span><input class="mjt-input" name="first" type="datetime-local" [ngModel]="firstValue" (ngModelChange)="setFirst($event)" required /></label>
                <label class="minutes"><span class="mjt-label">Minutes</span><input class="mjt-input" name="minutes" type="number" min="5" step="5" [(ngModel)]="draft.durationMinutes" required /></label>
                <label class="mjt-grow"><span class="mjt-label">Time zone</span><input class="mjt-input" name="zone" [(ngModel)]="draft.timeZone" list="mjt-zones" placeholder="America/Chicago" required /></label>
                <datalist id="mjt-zones">@for (zone of Zones; track zone) { <option [value]="zone"></option> }</datalist>
            </div>
            @if (!ZoneOk) { <div class="mjt-callout mjt-callout--error">"{{ draft.timeZone }}" is not a time zone. Use an IANA name such as America/Chicago.</div> }
            <fieldset class="rule">
                <legend class="mjt-label">Repeats</legend>
                <div class="mjt-row wrap">
                    <span>Every</span>
                    <input class="mjt-input interval" name="interval" type="number" min="1" [(ngModel)]="rule.interval" (ngModelChange)="ruleChanged()" />
                    <select class="mjt-select unit" name="frequency" [(ngModel)]="rule.frequency" (ngModelChange)="ruleChanged()">
                        <option value="DAILY">{{ rule.interval > 1 ? 'days' : 'day' }}</option>
                        <option value="WEEKLY">{{ rule.interval > 1 ? 'weeks' : 'week' }}</option>
                        <option value="MONTHLY">{{ rule.interval > 1 ? 'months' : 'month' }}</option>
                    </select>
                </div>
                @if (rule.frequency === 'WEEKLY') {
                    <div class="days" role="group" aria-label="On these days">
                        @for (day of Weekdays; track day.code) {
                            <button type="button" class="day" [class.on]="rule.byDay.includes(day.code)" [attr.aria-pressed]="rule.byDay.includes(day.code)" (click)="toggleDay(day.code)">{{ day.short }}</button>
                        }
                    </div>
                }
                <div class="mjt-row wrap">
                    <span>Ends</span>
                    <select class="mjt-select unit" name="ends" [(ngModel)]="rule.ends" (ngModelChange)="ruleChanged()">
                        <option value="never">never</option><option value="until">on a date</option><option value="count">after a number of meetings</option>
                    </select>
                    @if (rule.ends === 'until') { <input class="mjt-input" name="until" type="date" [ngModel]="untilValue" (ngModelChange)="setUntil($event)" /> }
                    @if (rule.ends === 'count') { <input class="mjt-input interval" name="count" type="number" min="1" [(ngModel)]="rule.count" (ngModelChange)="ruleChanged()" /> }
                </div>
                <div class="mjt-small">{{ RuleText }}@if (CustomRule) { <span class="mjt-muted"> (as written: {{ draft.recurrenceRule }})</span> }</div>
            </fieldset>
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
                            <option [ngValue]="null">A link typed on each meeting</option>
                            @for (provider of VideoProviders; track provider.id) { <option [ngValue]="provider.id">{{ provider.name }}</option> }
                        </select>
                    </label>
                }
                <label><span class="mjt-label">Who sees it</span>
                    <select class="mjt-select" name="visibility" [(ngModel)]="draft.visibility">
                        <option value="Standard">Anyone who reads meetings</option><option value="Private">Its attendees only</option>
                    </select>
                </label>
            </div>
            @if (Preview.length) {
                <div class="preview">
                    <div class="mjt-label">Next meetings</div>
                    <ul>@for (when of Preview; track when.getTime()) { <li>{{ previewLabel(when) }}</li> }</ul>
                </div>
            }
            @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
            <div class="mjt-row">
                <span class="mjt-grow"></span>
                <button mjButton type="button" Variant="secondary" Size="md" [disabled]="Busy" (click)="CancelRequested.emit()">Cancel</button>
                <button mjButton type="submit" Variant="primary" Size="md" [disabled]="Busy || !CanSubmit">{{ draft.id ? 'Save series' : 'Create series' }}</button>
            </div>
        </form>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .editor { display: flex; flex-direction: column; gap: 12px; color: var(--mjt-text); }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .minutes { width: 90px; }
        .interval { width: 70px; }
        .unit { width: auto; }
        .rule { display: flex; flex-direction: column; gap: 8px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); padding: 10px 12px; }
        .days { display: flex; flex-wrap: wrap; gap: 6px; }
        .day { padding: 4px 10px; border: 1px solid var(--mjt-border-strong); border-radius: 999px; background: var(--mjt-surface); color: var(--mjt-text-muted); font: inherit; font-size: 12px; cursor: pointer; }
        .day.on { background: var(--mjt-brand); color: var(--mjt-on-brand); border-color: var(--mjt-brand); }
        .preview ul { margin: 4px 0 0; padding-left: 18px; font-size: 13px; }
    `],
})
export class MeetingSeriesEditorComponent implements OnChanges {
    @Input() Value: SeriesDraft = emptySeriesDraft(viewerTimeZone(), null);
    @Input() Types: MeetingTypeOption[] = [];
    @Input() VideoProviders: VideoProviderOption[] = [];
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Output() SaveRequested = new EventEmitter<SeriesDraft>();
    @Output() CancelRequested = new EventEmitter<void>();

    protected draft: SeriesDraft = emptySeriesDraft(viewerTimeZone(), null);
    protected rule: SeriesRuleDraft = emptySeriesRule();
    /** The rule says something the editor does not express; it is kept as written. */
    public CustomRule = false;
    public readonly Weekdays = WEEKDAYS;
    public readonly Zones: string[] = typeof Intl.supportedValuesOf === 'function' ? Intl.supportedValuesOf('timeZone') : [];

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['Value']) {
            this.draft = { ...this.Value };
            const parsed = parseRecurrenceRuleDraft(this.draft.recurrenceRule);
            this.CustomRule = !parsed;
            this.rule = parsed ?? emptySeriesRule();
        }
    }

    protected get firstValue(): string {
        return toLocalInputValue(this.draft.firstStartsAt, this.ZoneOk ? this.draft.timeZone : 'UTC');
    }

    protected setFirst(value: string): void {
        const instant = fromLocalInputValue(value, this.ZoneOk ? this.draft.timeZone : 'UTC');
        if (instant) this.draft.firstStartsAt = instant;
    }

    protected get untilValue(): string {
        return this.rule.until ? this.rule.until.toISOString().slice(0, 10) : '';
    }

    protected setUntil(value: string): void {
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value ?? '');
        this.rule.until = match ? new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]), 23, 59, 59)) : null;
        this.ruleChanged();
    }

    public get ZoneOk(): boolean {
        return isValidTimeZone(this.draft.timeZone);
    }

    protected typeChosen(): void {
        const type = this.Types.find((t) => t.id === this.draft.typeId);
        if (type?.defaultDurationMinutes) this.draft.durationMinutes = type.defaultDurationMinutes;
        if (type?.defaultLocationType) this.draft.locationType = type.defaultLocationType;
        if (type?.defaultVisibility) this.draft.visibility = type.defaultVisibility;
    }

    protected toggleDay(code: string): void {
        this.rule.byDay = this.rule.byDay.includes(code) ? this.rule.byDay.filter((d) => d !== code) : [...this.rule.byDay, code];
        this.ruleChanged();
    }

    protected ruleChanged(): void {
        this.CustomRule = false;
        this.draft.recurrenceRule = buildRecurrenceRule(this.rule);
    }

    public get RuleText(): string {
        return describeRecurrenceRule(this.rule);
    }

    public get Preview(): Date[] {
        if (!this.ZoneOk || !(this.draft.durationMinutes > 0)) return [];
        try {
            const from = this.draft.firstStartsAt;
            const through = new Date(from.getTime() + 120 * 86400000);
            return expandOccurrences({ rule: this.draft.recurrenceRule, timeZone: this.draft.timeZone, firstStartsAt: from, durationMinutes: this.draft.durationMinutes }, { from, through }, 5).map((o) => o.startsAt);
        } catch {
            return [];
        }
    }

    protected previewLabel(when: Date): string {
        return `${formatDay(when, this.draft.timeZone)}, ${formatTime(when, this.draft.timeZone)} ${zoneAbbreviation(when, this.draft.timeZone)}`;
    }

    public get CanSubmit(): boolean {
        return !!this.draft.name.trim() && this.ZoneOk && this.draft.durationMinutes > 0 && !!this.draft.recurrenceRule;
    }

    protected submit(): void {
        if (!this.CanSubmit) return;
        this.SaveRequested.emit({ ...this.draft, name: this.draft.name.trim(), location: this.draft.location.trim() });
    }
}
