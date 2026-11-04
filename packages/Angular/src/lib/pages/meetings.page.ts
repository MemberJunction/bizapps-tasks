import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LogError } from '@memberjunction/core';
import { MJButtonDirective, MJDialogComponent } from '@memberjunction/ng-ui-components';
import {
    MeetingListComponent,
    NewMeetingFormComponent,
    emptyMeetingDraft,
    viewerTimeZone,
    type MeetingRow,
    type MeetingStatus,
    type MeetingTypeOption,
    type NewMeetingDraft,
    type PersonOption,
    type VideoProviderOption,
} from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingData, quoteSql } from '../meetings/meeting-data';
import { MEETINGS_PAGE_CSS, OpenMeetingRecord } from './meetings-shared';

type StatusFilter = 'open' | MeetingStatus | 'all';

/** Every meeting the viewer may see, with filters by type, status, date and a search of the title. */
@Component({
    selector: 'bizapps-meetings-page',
    standalone: true,
    imports: [CommonModule, FormsModule, MJButtonDirective, MJDialogComponent, MeetingListComponent, NewMeetingFormComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar"><i class="fa-solid fa-calendar-check" aria-hidden="true"></i></div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">Meetings</h1>
                            <p class="mjt-subtitle">Every meeting you may see. Private meetings show only to their attendees.</p>
                        </div>
                    </div>
                    <div class="mjt-actions">
                        <button mjButton Variant="primary" Size="md" (click)="openNew()"><i class="fa-solid fa-plus"></i>New meeting</button>
                    </div>
                </div>
                <div class="filters">
                    <input class="filter-input" type="search" name="search" [(ngModel)]="search" (ngModelChange)="reload()" placeholder="Search by title" aria-label="Search by title" />
                    <select class="filter-input" name="type" [(ngModel)]="typeId" (ngModelChange)="reload()" aria-label="Type">
                        <option [ngValue]="null">Any type</option>
                        @for (type of types; track type.id) { <option [ngValue]="type.id">{{ type.name }}</option> }
                    </select>
                    <select class="filter-input" name="status" [(ngModel)]="status" (ngModelChange)="reload()" aria-label="Status">
                        <option value="open">Open (not cancelled or completed)</option>
                        <option value="Scheduled">Scheduled</option><option value="InProgress">In progress</option><option value="Postponed">Postponed</option>
                        <option value="Completed">Completed</option><option value="Cancelled">Cancelled</option><option value="Draft">Draft</option><option value="all">Any status</option>
                    </select>
                    <div class="mjt-seg" role="group" aria-label="When">
                        <button type="button" [class.on]="when === 'upcoming'" [attr.aria-pressed]="when === 'upcoming'" (click)="setWhen('upcoming')">Upcoming</button>
                        <button type="button" [class.on]="when === 'past'" [attr.aria-pressed]="when === 'past'" (click)="setWhen('past')">Past</button>
                        <button type="button" [class.on]="when === 'all'" [attr.aria-pressed]="when === 'all'" (click)="setWhen('all')">All</button>
                    </div>
                </div>
            </div>
            <div class="mjt-body-card">
                <bizapps-meeting-list [Meetings]="meetings" [IsLoading]="loading" [ErrorMessage]="error" [Order]="when === 'past' ? 'desc' : 'asc'" [ShowResponse]="false"
                    EmptyTitle="No meetings match" EmptyMessage="Change the filters, or schedule one."
                    (Selected)="open($event)" (OpenRequested)="open($event)"></bizapps-meeting-list>
            </div>
        </div>
        <mj-dialog [Visible]="newOpen" Title="New meeting" Size="lg" (Close)="newOpen = false">
            <div class="mjt-dialog-body">
                <bizapps-new-meeting-form [Value]="draft" [Types]="types" [People]="people" [VideoProviders]="providers" [TypesWithTemplate]="typesWithTemplate" [Busy]="saving" [ErrorMessage]="saveError" (SubmitRequested)="create($event)" (CancelRequested)="newOpen = false"></bizapps-new-meeting-form>
            </div>
        </mj-dialog>
    `,
    styles: [MEETINGS_PAGE_CSS, `
        .filters { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-top: 12px; }
        .filter-input { padding: 7px 10px; border: 1px solid var(--mj-border-strong, #cbd5e1); border-radius: var(--mj-radius-md, 8px); background: var(--mj-bg-surface-card, #fff); color: var(--mj-text-primary, #0f172a); font: inherit; font-size: 13px; min-width: 160px; }
    `],
})
export class MeetingsPageComponent implements OnInit, OnDestroy {
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly data = new MeetingData();
    protected meetings: MeetingRow[] = [];
    protected loading = true;
    protected error = '';
    protected search = '';
    protected typeId: string | null = null;
    protected status: StatusFilter = 'open';
    protected when: 'upcoming' | 'past' | 'all' = 'upcoming';
    protected newOpen = false;
    protected saving = false;
    protected saveError = '';
    protected draft: NewMeetingDraft = emptyMeetingDraft(viewerTimeZone());
    protected types: MeetingTypeOption[] = [];
    protected people: PersonOption[] = [];
    public providers: VideoProviderOption[] = [];
    protected typesWithTemplate: string[] = [];
    private reloadTimer: ReturnType<typeof setTimeout> | null = null;

    ngOnDestroy(): void {
        if (this.reloadTimer) clearTimeout(this.reloadTimer);
    }

    async ngOnInit(): Promise<void> {
        try {
            this.types = await this.data.LoadTypes();
            this.typesWithTemplate = this.data.TypesWithTemplate();
        } catch (e) {
            LogError(`Meetings: the types could not be read: ${MeetingData.Message(e)}`);
        }
        await this.load();
    }

    protected reload(): void {
        if (this.reloadTimer) clearTimeout(this.reloadTimer);
        this.reloadTimer = setTimeout(() => void this.load(), 250);
    }

    protected setWhen(when: 'upcoming' | 'past' | 'all'): void {
        if (this.when === when) return;
        this.when = when;
        void this.load();
    }

    protected async load(): Promise<void> {
        this.loading = true;
        this.error = '';
        this.cdr.markForCheck();
        try {
            const filters: string[] = [];
            if (this.search.trim()) filters.push(`Name LIKE '%${quoteSql(this.search.trim())}%'`);
            if (this.typeId) filters.push(`TypeID = '${this.typeId}'`);
            if (this.status === 'open') filters.push(`Status NOT IN ('Cancelled', 'Completed')`);
            else if (this.status !== 'all') filters.push(`Status = '${this.status}'`);
            const now = new Date();
            this.meetings = await this.data.LoadMeetingRows({ mine: false, from: this.when === 'upcoming' ? now : null, through: this.when === 'past' ? now : null, extraFilter: filters.join(' AND ') || undefined });
        } catch (e) {
            this.error = `The meetings could not be read: ${MeetingData.Message(e)}`;
            LogError(this.error);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    protected open(meeting: MeetingRow): void {
        OpenMeetingRecord(meeting.id);
    }

    protected async openNew(): Promise<void> {
        this.saveError = '';
        this.draft = emptyMeetingDraft(viewerTimeZone());
        this.newOpen = true;
        this.cdr.markForCheck();
        try {
            [this.people, this.providers] = await Promise.all([this.data.LoadPeople(), this.data.LoadVideoProviders()]);
        } catch (e) {
            this.saveError = `The form's choices could not be read: ${MeetingData.Message(e)}`;
        }
        this.cdr.markForCheck();
    }

    protected async create(draft: NewMeetingDraft): Promise<void> {
        this.saving = true;
        this.saveError = '';
        this.cdr.markForCheck();
        try {
            const meeting = await this.data.CreateMeeting(draft);
            this.newOpen = false;
            await this.load();
            OpenMeetingRecord(meeting.ID);
        } catch (e) {
            this.saveError = MeetingData.Message(e);
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }
}
