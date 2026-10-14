import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LogError } from '@memberjunction/core';
import { MJButtonDirective, MJDialogComponent, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import {
    MeetingSeriesEditorComponent,
    describeRecurrenceRule,
    emptySeriesDraft,
    formatDay,
    formatMinutes,
    formatTime,
    parseRecurrenceRuleDraft,
    viewerTimeZone,
    zoneAbbreviation,
    type MeetingTypeOption,
    type SeriesDraft,
    type SeriesModel,
    type VideoProviderOption,
} from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingData } from '../meetings/meeting-data';
import { MEETINGS_PAGE_CSS, OpenSeriesRecord } from './meetings-shared';

/** Recurring meetings: each series with its rule in words, how many occurrences exist and the next one; a new series through the editor. */
@Component({
    selector: 'bizapps-meeting-series-page',
    standalone: true,
    imports: [CommonModule, MJButtonDirective, MJDialogComponent, MJEmptyStateComponent, MeetingSeriesEditorComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar"><i class="fa-solid fa-repeat" aria-hidden="true"></i></div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">Series</h1>
                            <p class="mjt-subtitle">Recurring meetings. Each occurrence is a meeting of its own, made ahead of time; change the series and the ones not yet held follow.</p>
                        </div>
                    </div>
                    <div class="mjt-actions">
                        <div class="mjt-seg" role="group" aria-label="Which series">
                            <button type="button" [class.on]="status === 'Active'" (click)="setStatus('Active')">Active</button>
                            <button type="button" [class.on]="status === 'all'" (click)="setStatus('all')">All</button>
                        </div>
                        <button mjButton Variant="primary" Size="md" (click)="openNew()"><i class="fa-solid fa-plus"></i>New series</button>
                    </div>
                </div>
            </div>
            <div class="mjt-body-card">
                @if (error) { <div class="mjt-error" role="alert">{{ error }}</div> }
                @if (loading) { <p class="mjt-empty">Reading series…</p> }
                @else if (!series.length) { <mj-empty-state Icon="fa-solid fa-repeat" Title="No series yet" Message="A series makes its meetings for you, week after week."></mj-empty-state> }
                @for (s of series; track s.id) {
                    <button type="button" class="series" (click)="open(s)" [attr.aria-label]="'Open series ' + s.name">
                        <div class="grow">
                            <div class="row"><span class="name">{{ s.name }}</span>@if (s.typeName) { <span class="chip">{{ s.typeName }}</span> }<span [class]="'chip ' + (s.status === 'Active' ? 'ok' : 'muted')">{{ s.status }}</span></div>
                            <div class="meta">{{ ruleText(s) }} · {{ formatMinutes(s.durationMinutes) }} · {{ timeText(s) }}@if (s.organizerName) { · {{ s.organizerName }}}</div>
                            <div class="meta">{{ s.occurrenceCount }} meeting{{ s.occurrenceCount === 1 ? '' : 's' }} made@if (s.nextOccurrenceAt) { · next {{ nextText(s) }}}@if (s.materializedThrough) { · planned through {{ throughText(s) }}}</div>
                        </div>
                        <i class="fa-solid fa-chevron-right muted" aria-hidden="true"></i>
                    </button>
                }
            </div>
        </div>
        <mj-dialog [Visible]="newOpen" Title="New series" Size="lg" (Close)="newOpen = false">
            <div class="mjt-dialog-body">
                <bizapps-meeting-series-editor [Value]="draft" [Types]="types" [VideoProviders]="providers" [Busy]="saving" [ErrorMessage]="saveError" (SaveRequested)="create($event)" (CancelRequested)="newOpen = false"></bizapps-meeting-series-editor>
            </div>
        </mj-dialog>
    `,
    styles: [MEETINGS_PAGE_CSS, `
        .series { display: flex; align-items: center; gap: 12px; width: 100%; text-align: left; padding: 12px 14px; border: 1px solid var(--mj-border-default, #e2e8f0); border-radius: var(--mj-radius-lg, 12px); background: var(--mj-bg-surface-card, #fff); color: var(--mj-text-primary, #0f172a); font: inherit; cursor: pointer; margin-bottom: 8px; }
        .series:hover { border-color: var(--mj-border-strong, #cbd5e1); }
        .grow { flex: 1; min-width: 0; }
        .row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .name { font-weight: 700; font-size: 14px; }
        .meta { font-size: 12px; color: var(--mj-text-muted, #64748b); margin-top: 3px; }
        .muted { color: var(--mj-text-muted, #64748b); }
        .chip { display: inline-flex; padding: 2px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; background: var(--mj-bg-surface-sunken, #f8fafc); color: var(--mj-text-muted, #64748b); border: 1px solid var(--mj-border-default, #e2e8f0); }
        .chip.ok { background: var(--mj-status-success-bg, #ecfdf5); color: var(--mj-status-success-text, #047857); border-color: transparent; }
    `],
})
export class MeetingSeriesPageComponent implements OnInit {
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly data = new MeetingData();
    public series: SeriesModel[] = [];
    public loading = true;
    public error = '';
    public status: 'Active' | 'all' = 'Active';
    public newOpen = false;
    public saving = false;
    public saveError = '';
    public draft: SeriesDraft = emptySeriesDraft(viewerTimeZone(), null);
    public types: MeetingTypeOption[] = [];
    public providers: VideoProviderOption[] = [];
    public readonly formatMinutes = formatMinutes;

    async ngOnInit(): Promise<void> {
        await this.load();
    }

    async load(): Promise<void> {
        this.loading = true;
        this.error = '';
        this.cdr.markForCheck();
        try {
            this.series = await this.data.loadSeries(this.status === 'Active' ? "Status = 'Active'" : '');
        } catch (e) {
            this.error = `The series could not be read: ${MeetingData.message(e)}`;
            LogError(this.error);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    setStatus(status: 'Active' | 'all'): void {
        if (this.status === status) return;
        this.status = status;
        void this.load();
    }

    ruleText(s: SeriesModel): string {
        const parsed = parseRecurrenceRuleDraft(s.recurrenceRule);
        return parsed ? describeRecurrenceRule(parsed) : s.recurrenceRule;
    }

    timeText(s: SeriesModel): string {
        return `${formatTime(s.firstStartsAt, s.timeZone)} ${zoneAbbreviation(s.firstStartsAt, s.timeZone)}`;
    }

    nextText(s: SeriesModel): string {
        return s.nextOccurrenceAt ? `${formatDay(s.nextOccurrenceAt, viewerTimeZone())}, ${formatTime(s.nextOccurrenceAt, viewerTimeZone())}` : '';
    }

    throughText(s: SeriesModel): string {
        return s.materializedThrough ? formatDay(s.materializedThrough, viewerTimeZone()) : '';
    }

    open(s: SeriesModel): void {
        OpenSeriesRecord(s.id);
    }

    async openNew(): Promise<void> {
        this.saveError = '';
        this.draft = emptySeriesDraft(viewerTimeZone(), await this.data.currentPersonId());
        this.newOpen = true;
        this.cdr.markForCheck();
        try {
            [this.types, this.providers] = await Promise.all([this.data.loadTypes(), this.data.loadVideoProviders()]);
        } catch (e) {
            this.saveError = `The form's choices could not be read: ${MeetingData.message(e)}`;
        }
        this.cdr.markForCheck();
    }

    async create(draft: SeriesDraft): Promise<void> {
        this.saving = true;
        this.saveError = '';
        this.cdr.markForCheck();
        try {
            const series = await this.data.saveSeries(draft);
            this.newOpen = false;
            await this.load();
            OpenSeriesRecord(series.ID);
        } catch (e) {
            this.saveError = MeetingData.message(e);
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }
}
