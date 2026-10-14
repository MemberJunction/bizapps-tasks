import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatDay, viewerTimeZone } from './format';
import type { AgendaItemModel, FollowUpDraft, FollowUpModel, PersonOption } from './types';

/**
 * Follow-ups: the tasks linked to the meeting and its agenda items, and a quick form that files a new one (a Task of the
 * ACTION_ITEM type, linked to the meeting or the item). A task opens through the host.
 */
@Component({
    selector: 'bizapps-meeting-followups',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow"><span class="mjt-strong">Follow-ups</span> <span class="mjt-muted mjt-small">{{ FollowUps.length }} task{{ FollowUps.length === 1 ? '' : 's' }}</span></div>
            @if (CanAdd && !draft) {
                <button mjButton Variant="primary" Size="sm" [disabled]="Busy" (click)="openDraft()"><i class="fa-solid fa-plus"></i>Add follow-up</button>
            }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (draft; as d) {
            <form class="editor" (ngSubmit)="submit()" aria-label="New follow-up">
                <label><span class="mjt-label">What needs doing</span><input class="mjt-input" name="name" [(ngModel)]="d.name" required maxlength="255" autocomplete="off" /></label>
                <div class="mjt-row wrap">
                    <label class="mjt-grow"><span class="mjt-label">Who</span>
                        <select class="mjt-select" name="assignee" [(ngModel)]="d.assigneePersonId">
                            <option [ngValue]="null">Unassigned</option>
                            @for (person of People; track person.id) { <option [ngValue]="person.id">{{ person.name }}</option> }
                        </select>
                    </label>
                    <label><span class="mjt-label">By</span><input class="mjt-input" name="due" type="date" [ngModel]="dueValue" (ngModelChange)="setDue($event)" /></label>
                    <label class="mjt-grow"><span class="mjt-label">From the item</span>
                        <select class="mjt-select" name="item" [(ngModel)]="d.agendaItemId">
                            <option [ngValue]="null">The meeting</option>
                            @for (item of AgendaItems; track item.id) { <option [ngValue]="item.id">{{ item.name }}</option> }
                        </select>
                    </label>
                </div>
                <div class="mjt-row">
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="draft = null">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || !d.name.trim()">File the task</button>
                </div>
            </form>
        }
        @if (!FollowUps.length && !draft) { <div class="mjt-empty">No follow-ups yet.</div> }
        @for (task of FollowUps; track task.id) {
            <button type="button" class="task" (click)="OpenRequested.emit(task)" [attr.aria-label]="'Open task ' + task.name">
                <i class="fa-solid fa-list-check" aria-hidden="true"></i>
                <div class="mjt-grow">
                    <div class="mjt-row wrap"><span class="mjt-strong">{{ task.name }}</span><span [class]="statusClass(task.status)">{{ task.status }}</span>@if (task.priority === 'High' || task.priority === 'Critical') { <span class="mjt-chip mjt-chip--warn">{{ task.priority }}</span> }</div>
                    <div class="mjt-small mjt-muted">@if (task.assigneeNames.length) { {{ task.assigneeNames.join(', ') }} } @else { Unassigned }@if (task.dueAt) { · due {{ dueLabel(task) }}}@if (task.agendaItemId) { · from {{ itemName(task.agendaItemId) }}}</div>
                </div>
                <i class="fa-solid fa-chevron-right mjt-muted" aria-hidden="true"></i>
            </button>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 8px; }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .editor { display: flex; flex-direction: column; gap: 10px; padding: 12px; border: 1px dashed var(--mjt-border-strong); border-radius: var(--mjt-radius-lg); margin-bottom: 10px; }
        .task { display: flex; align-items: center; gap: 12px; width: 100%; text-align: left; padding: 10px 12px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); color: var(--mjt-text); font: inherit; cursor: pointer; margin-bottom: 6px; }
        .task:hover { border-color: var(--mjt-border-strong); }
        .task:focus-visible { outline: 2px solid var(--mjt-brand); outline-offset: 2px; }
    `],
})
export class MeetingFollowUpsComponent {
    @Input() FollowUps: FollowUpModel[] = [];
    @Input() AgendaItems: AgendaItemModel[] = [];
    @Input() People: PersonOption[] = [];
    @Input() CanAdd = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Input() DefaultAgendaItemID: string | null = null;
    @Input() ViewerZone: string = viewerTimeZone();
    @Output() AddRequested = new EventEmitter<FollowUpDraft>();
    @Output() OpenRequested = new EventEmitter<FollowUpModel>();

    public draft: FollowUpDraft | null = null;
    public dueValue = '';

    public openDraft(agendaItemId: string | null = this.DefaultAgendaItemID): void {
        this.draft = { name: '', agendaItemId, assigneePersonId: null, dueAt: null };
        this.dueValue = '';
    }

    public setDue(value: string): void {
        this.dueValue = value;
        if (!this.draft) return;
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value ?? '');
        this.draft.dueAt = match ? new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]), 17, 0, 0)) : null;
    }

    public submit(): void {
        if (!this.draft?.name.trim()) return;
        this.AddRequested.emit({ ...this.draft, name: this.draft.name.trim() });
        this.draft = null;
    }

    public statusClass(status: string): string {
        switch (status) {
            case 'Completed':
                return 'mjt-chip mjt-chip--ok';
            case 'InProgress':
                return 'mjt-chip mjt-chip--info';
            case 'Blocked':
                return 'mjt-chip mjt-chip--error';
            case 'Cancelled':
                return 'mjt-chip mjt-chip--warn';
            default:
                return 'mjt-chip';
        }
    }

    public dueLabel(task: FollowUpModel): string {
        return task.dueAt ? formatDay(task.dueAt, this.ViewerZone) : '';
    }

    public itemName(id: string): string {
        return this.AgendaItems.find((item) => item.id.toLowerCase() === id.toLowerCase())?.name ?? 'an item';
    }
}
