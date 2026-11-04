import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, Input, OnChanges, OnDestroy, Output, SimpleChanges, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatElapsed, formatMinutes } from './format';
import { agendaTree } from './meeting-agenda.component';
import type { AgendaItemModel, AgendaItemStatus, AttendanceStatus, AttendeeModel, MeetingRow } from './types';

export interface LiveItemChange {
    item: AgendaItemModel;
    status: AgendaItemStatus;
    outcome?: string | null;
}

export interface LiveAttendanceChange {
    attendee: AttendeeModel;
    attendance: AttendanceStatus;
}

export interface LiveQuickNote {
    item: AgendaItemModel | null;
    body: string;
}

export interface LiveFollowUp {
    item: AgendaItemModel | null;
    name: string;
}

/** Seconds since an instant, or since `now` when there is none. */
export function elapsedSince(startedAt: Date | null, now: Date): number {
    return startedAt ? Math.max(0, Math.floor((now.getTime() - startedAt.getTime()) / 1000)) : 0;
}

/**
 * The live meeting (the meetings plan, § 5): the current item and its timer against its planned length, next and
 * previous, attendance check-in, a quick note on the item, a follow-up filed as it comes up, and End. The host saves
 * each change; this keeps the clock.
 */
@Component({
    selector: 'bizapps-meeting-live',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="live">
            <div class="top mjt-row">
                <div class="mjt-grow">
                    <div class="mjt-small mjt-muted">Live</div>
                    <div class="title">{{ Meeting.name }}</div>
                </div>
                <div class="clock" aria-live="off"><span class="mjt-small mjt-muted">Meeting</span><span class="digits">{{ MeetingElapsed }}</span></div>
                @if (CanRun) { <button mjButton Variant="primary" Size="md" [disabled]="Busy" (click)="EndRequested.emit()"><i class="fa-solid fa-stop"></i>End meeting</button> }
                <button mjButton Variant="secondary" Size="md" (click)="CloseRequested.emit()">Close</button>
            </div>
            @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
            <div class="columns">
                <section class="now mjt-card" aria-label="Current item">
                    @if (Current; as item) {
                        <div class="mjt-small mjt-muted">Item {{ Position }} of {{ Tree.length }}</div>
                        <div class="now-title">{{ item.name }}</div>
                        @if (item.description) { <div class="mjt-small">{{ item.description }}</div> }
                        <div class="mjt-row wrap meta mjt-small mjt-muted">
                            @if (item.typeName) { <span>{{ item.typeName }}</span> }
                            @if (item.presenterName) { <span>{{ item.presenterName }}</span> }
                            <span>Planned {{ plannedLabel(item) }}</span>
                        </div>
                        <div class="item-clock" [class.over]="isOver(item)">
                            <span class="digits">{{ ItemElapsed }}</span>
                            @if (item.durationMinutes != null) { <span class="mjt-small">of {{ formatMinutes(item.durationMinutes) }}</span> }
                        </div>
                        <div class="mjt-row wrap">
                            @if (item.status !== 'InProgress') {
                                <button mjButton Variant="primary" Size="sm" [disabled]="Busy || !CanRun" (click)="ItemChanged.emit({ item, status: 'InProgress' })"><i class="fa-solid fa-play"></i>Start item</button>
                            } @else {
                                <button mjButton Variant="primary" Size="sm" [disabled]="Busy || !CanRun" (click)="finish(item)"><i class="fa-solid fa-check"></i>Done</button>
                                <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !CanRun" (click)="ItemChanged.emit({ item, status: 'Deferred' })">Defer</button>
                                <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !CanRun" (click)="ItemChanged.emit({ item, status: 'Skipped' })">Skip</button>
                            }
                            <span class="mjt-grow"></span>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="index <= 0" (click)="go(-1)"><i class="fa-solid fa-chevron-left"></i>Previous</button>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="index >= Tree.length - 1" (click)="go(1)">Next<i class="fa-solid fa-chevron-right"></i></button>
                        </div>
                        <label><span class="mjt-label">Outcome</span><textarea class="mjt-textarea" rows="2" [(ngModel)]="outcome" name="outcome" placeholder="What was agreed, in a sentence or two"></textarea></label>
                        <div class="mjt-row">
                            <label class="mjt-grow"><span class="mjt-label">Quick note</span><input class="mjt-input" [(ngModel)]="quickNote" name="quickNote" placeholder="A note on this item" (keydown.enter)="sendNote(item)" /></label>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !quickNote.trim()" (click)="sendNote(item)"><i class="fa-solid fa-note-sticky"></i>Note</button>
                        </div>
                        <div class="mjt-row">
                            <label class="mjt-grow"><span class="mjt-label">Follow-up</span><input class="mjt-input" [(ngModel)]="followUp" name="followUp" placeholder="A task to file from this item" (keydown.enter)="sendFollowUp(item)" /></label>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !followUp.trim()" (click)="sendFollowUp(item)"><i class="fa-solid fa-list-check"></i>Add follow-up</button>
                        </div>
                    } @else {
                        <div class="mjt-empty">This meeting has no agenda. Notes and follow-ups go on the meeting itself.</div>
                        <div class="mjt-row">
                            <label class="mjt-grow"><span class="mjt-label">Quick note</span><input class="mjt-input" [(ngModel)]="quickNote" name="quickNote2" (keydown.enter)="sendNote(null)" /></label>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !quickNote.trim()" (click)="sendNote(null)">Note</button>
                        </div>
                        <div class="mjt-row">
                            <label class="mjt-grow"><span class="mjt-label">Follow-up</span><input class="mjt-input" [(ngModel)]="followUp" name="followUp2" (keydown.enter)="sendFollowUp(null)" /></label>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="Busy || !followUp.trim()" (click)="sendFollowUp(null)">Add follow-up</button>
                        </div>
                    }
                </section>
                <aside class="side">
                    <section class="mjt-card" aria-label="Agenda">
                        <div class="mjt-strong">Agenda</div>
                        <ol class="agenda">
                            @for (entry of Tree; track entry.item.id; let i = $index) {
                                <li [class.current]="i === index" [class.done]="entry.item.status === 'Done'" [style.padding-left.px]="8 + entry.depth * 16">
                                    <button type="button" class="agenda-btn" (click)="index = i; resetItemClock()">
                                        <i [class]="iconFor(entry.item.status)" aria-hidden="true"></i>
                                        <span class="mjt-grow">{{ entry.item.name }}</span>
                                        <span class="mjt-small mjt-muted">{{ entry.item.durationMinutes != null ? formatMinutes(entry.item.durationMinutes) : '' }}</span>
                                    </button>
                                </li>
                            }
                        </ol>
                    </section>
                    <section class="mjt-card" aria-label="Who is here">
                        <div class="mjt-strong">Who is here</div>
                        @for (attendee of Attendees; track attendee.id) {
                            <div class="mjt-row att">
                                <span class="mjt-grow">{{ attendee.name }}@if (attendee.role === 'Organizer') { <span class="mjt-small mjt-muted">(organizer)</span> }</span>
                                <div class="seg" role="group" [attr.aria-label]="'Attendance of ' + attendee.name">
                                    <button type="button" [class.on]="attendee.attendanceStatus === 'Present'" [disabled]="Busy || !CanRun" (click)="AttendanceChanged.emit({ attendee, attendance: 'Present' })">Here</button>
                                    <button type="button" [class.on]="attendee.attendanceStatus === 'Late'" [disabled]="Busy || !CanRun" (click)="AttendanceChanged.emit({ attendee, attendance: 'Late' })">Late</button>
                                    <button type="button" [class.on]="attendee.attendanceStatus === 'Absent'" [disabled]="Busy || !CanRun" (click)="AttendanceChanged.emit({ attendee, attendance: 'Absent' })">Away</button>
                                </div>
                            </div>
                        }
                    </section>
                </aside>
            </div>
        </div>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; height: 100%; }
        .live { display: flex; flex-direction: column; gap: 12px; padding: 16px; color: var(--mjt-text); height: 100%; box-sizing: border-box; }
        .top { flex-wrap: wrap; }
        .title { font-size: 18px; font-weight: 700; }
        .clock { display: flex; flex-direction: column; align-items: flex-end; }
        .digits { font-variant-numeric: tabular-nums; font-size: 22px; font-weight: 700; }
        .columns { display: grid; grid-template-columns: minmax(0, 2fr) minmax(260px, 1fr); gap: 12px; align-items: start; }
        .now { display: flex; flex-direction: column; gap: 10px; }
        .now-title { font-size: 22px; font-weight: 700; }
        .meta { gap: 4px 12px; }
        .item-clock { display: flex; align-items: baseline; gap: 8px; padding: 10px 14px; border-radius: var(--mjt-radius-lg); background: var(--mjt-surface-sunken); }
        .item-clock .digits { font-size: 36px; }
        .item-clock.over { background: var(--mjt-error-bg); color: var(--mjt-error-text); }
        .wrap { flex-wrap: wrap; }
        .side { display: flex; flex-direction: column; gap: 12px; }
        .agenda { list-style: none; margin: 8px 0 0; padding: 0; }
        .agenda li { border-radius: var(--mjt-radius); }
        .agenda li.current { background: var(--mjt-brand-subtle); }
        .agenda li.done { opacity: 0.7; }
        .agenda-btn { display: flex; align-items: center; gap: 8px; width: 100%; padding: 6px 8px; border: 0; background: transparent; color: inherit; font: inherit; text-align: left; cursor: pointer; }
        .att { padding: 6px 0; border-top: 1px solid var(--mjt-border); }
        .seg { display: inline-flex; border: 1px solid var(--mjt-border-strong); border-radius: 999px; overflow: hidden; }
        .seg button { padding: 3px 9px; border: 0; background: transparent; color: var(--mjt-text-muted); font: inherit; font-size: 12px; cursor: pointer; }
        .seg button + button { border-left: 1px solid var(--mjt-border); }
        .seg button.on { background: var(--mjt-ok-bg); color: var(--mjt-ok-text); }
        @media (max-width: 860px) { .columns { grid-template-columns: 1fr; } }
    `],
})
export class MeetingLiveComponent implements OnChanges, OnDestroy {
    private readonly cdr = inject(ChangeDetectorRef);
    @Input({ required: true }) Meeting!: MeetingRow;
    @Input() Items: AgendaItemModel[] = [];
    @Input() Attendees: AttendeeModel[] = [];
    @Input() StartedAt: Date | null = null;
    @Input() CanRun = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Output() ItemChanged = new EventEmitter<LiveItemChange>();
    @Output() AttendanceChanged = new EventEmitter<LiveAttendanceChange>();
    @Output() NoteRequested = new EventEmitter<LiveQuickNote>();
    @Output() FollowUpRequested = new EventEmitter<LiveFollowUp>();
    @Output() EndRequested = new EventEmitter<void>();
    @Output() CloseRequested = new EventEmitter<void>();

    protected index = 0;
    protected outcome = '';
    protected quickNote = '';
    protected followUp = '';
    protected now = new Date();
    private itemClockFrom = new Date();
    private ticker: ReturnType<typeof setInterval> | null = null;
    public readonly formatMinutes = formatMinutes;

    public get Tree(): Array<{ item: AgendaItemModel; depth: number }> {
        return agendaTree(this.Items);
    }

    public get Current(): AgendaItemModel | null {
        return this.Tree[this.index]?.item ?? null;
    }

    public get Position(): number {
        return this.index + 1;
    }

    public get MeetingElapsed(): string {
        return formatElapsed(elapsedSince(this.StartedAt, this.now));
    }

    public get ItemElapsed(): string {
        const item = this.Current;
        return formatElapsed(elapsedSince(item?.startedAt ?? (item?.status === 'InProgress' ? this.itemClockFrom : null), this.now));
    }

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['Items']) {
            // Land on the item in progress, else the first not done
            const tree = this.Tree;
            const running = tree.findIndex((entry) => entry.item.status === 'InProgress');
            const open = tree.findIndex((entry) => entry.item.status === 'Planned');
            if (running >= 0) this.index = running;
            else if (open >= 0 && (this.index >= tree.length || tree[this.index]?.item.status === 'Done')) this.index = open;
            this.outcome = this.Current?.outcome ?? '';
        }
        if (!this.ticker) this.ticker = setInterval(() => this.tick(), 1000);
    }

    ngOnDestroy(): void {
        if (this.ticker) clearInterval(this.ticker);
    }

    private tick(): void {
        this.now = new Date();
        this.cdr.markForCheck();
    }

    protected resetItemClock(): void {
        this.itemClockFrom = new Date();
        this.outcome = this.Current?.outcome ?? '';
    }

    protected go(delta: -1 | 1): void {
        const next = this.index + delta;
        if (next < 0 || next >= this.Tree.length) return;
        this.index = next;
        this.resetItemClock();
    }

    protected isOver(item: AgendaItemModel): boolean {
        return item.durationMinutes != null && elapsedSince(item.startedAt ?? (item.status === 'InProgress' ? this.itemClockFrom : null), this.now) > item.durationMinutes * 60;
    }

    protected plannedLabel(item: AgendaItemModel): string {
        return formatMinutes(item.durationMinutes);
    }

    protected finish(item: AgendaItemModel): void {
        this.ItemChanged.emit({ item, status: 'Done', outcome: this.outcome.trim() || null });
        if (this.index < this.Tree.length - 1) this.go(1);
    }

    protected sendNote(item: AgendaItemModel | null): void {
        const body = this.quickNote.trim();
        if (!body) return;
        this.NoteRequested.emit({ item, body });
        this.quickNote = '';
    }

    protected sendFollowUp(item: AgendaItemModel | null): void {
        const name = this.followUp.trim();
        if (!name) return;
        this.FollowUpRequested.emit({ item, name });
        this.followUp = '';
    }

    protected iconFor(status: AgendaItemStatus): string {
        switch (status) {
            case 'Done':
                return 'fa-solid fa-circle-check';
            case 'InProgress':
                return 'fa-solid fa-circle-play';
            case 'Deferred':
                return 'fa-solid fa-circle-arrow-right';
            case 'Skipped':
                return 'fa-solid fa-circle-minus';
            default:
                return 'fa-regular fa-circle';
        }
    }
}
