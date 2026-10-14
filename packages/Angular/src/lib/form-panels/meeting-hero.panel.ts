import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { RegisterClassEx } from '@memberjunction/global';
import { LogError } from '@memberjunction/core';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksMeetingEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ENTITY } from '@mj-biz-apps/tasks-core';
import type { LiveAttendanceChange, LiveFollowUp, LiveItemChange, LiveQuickNote, ResponseStatus } from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingData, downloadTextFile, type MeetingDetail } from '../meetings/meeting-data';
import { OpenSeriesRecord } from '../pages/meetings-shared';
import { OpenTaskRecord } from '../open-task-record';

/**
 * The meeting page's header, above the generated fields (the meetings plan, § 5): the meeting header widget with the
 * organizer's actions, and the live meeting in a panel over the page. Every change goes through MeetingData and the record
 * is read again, so the generated fields below show the same state.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:hero',
    metadata: {
        entity: MEETING_ENTITY,
        slot: 'before-fields',
        sortKey: 100,
        contributionKey: 'meetingHero',
    },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-hero-panel',
    template: `
        @if (detail; as d) {
            <div class="hero-wrap">
                <bizapps-meeting-header [Meeting]="d.row" [Permissions]="d.permissions" [CancellationReason]="d.cancellationReason" [Busy]="busy"
                    (StartRequested)="start()" (RunRequested)="liveOpen = true" (EndRequested)="end()" (CancelRequested)="askCancel = true" (CalendarFileRequested)="calendar()" (ResponseChanged)="respond($event)" (SeriesRequested)="openSeries($event)">
                </bizapps-meeting-header>
                @if (askCancel) {
                    <div class="cancel-box" role="dialog" aria-label="Cancel this meeting?">
                        <div class="strong">Cancel this meeting?</div>
                        <div class="small">Its attendees are told; the video meeting, if there is one, is removed. This is not undone.</div>
                        <input class="input" [(ngModel)]="cancelReason" name="cancelReason" placeholder="Why (optional)" maxlength="500" />
                        <div class="row">
                            <button mjButton Variant="primary" Size="sm" [disabled]="busy" (click)="cancel()">Cancel the meeting</button>
                            <button mjButton Variant="secondary" Size="sm" [disabled]="busy" (click)="askCancel = false">Keep it</button>
                        </div>
                    </div>
                }
                @if (error) { <div class="error" role="alert">{{ error }}</div> }
            </div>
            <mj-slide-panel [Visible]="liveOpen" Mode="dialog" Title="Live meeting" [Resizable]="false" (Closed)="liveOpen = false">
                @if (liveOpen) {
                    <bizapps-meeting-live [Meeting]="d.row" [Items]="d.agenda" [Attendees]="d.attendees" [StartedAt]="d.startedAt" [CanRun]="d.permissions.canRun" [Busy]="busy" [ErrorMessage]="error"
                        (ItemChanged)="liveItem($event)" (AttendanceChanged)="liveAttendance($event)" (NoteRequested)="liveNote($event)" (FollowUpRequested)="liveFollowUp($event)" (EndRequested)="end()" (CloseRequested)="liveOpen = false">
                    </bizapps-meeting-live>
                }
            </mj-slide-panel>
        } @else if (loadError) {
            <div class="error" role="alert">{{ loadError }}</div>
        }
    `,
    styles: [`
        :host { display: block; }
        .hero-wrap { display: flex; flex-direction: column; gap: 8px; margin-bottom: 16px; }
        .cancel-box { display: flex; flex-direction: column; gap: 8px; padding: 12px 14px; border: 1px solid var(--mj-status-error-text, #b91c1c); border-radius: var(--mj-radius-lg, 12px); background: var(--mj-status-error-bg, #fef2f2); color: var(--mj-text-primary, #0f172a); }
        .strong { font-weight: 700; }
        .small { font-size: 12px; }
        .input { padding: 8px 10px; border: 1px solid var(--mj-border-strong, #cbd5e1); border-radius: var(--mj-radius-md, 8px); background: var(--mj-bg-surface-card, #fff); color: var(--mj-text-primary, #0f172a); font: inherit; }
        .row { display: flex; gap: 8px; }
        .error { padding: 8px 12px; border-radius: var(--mj-radius-md, 8px); background: var(--mj-status-error-bg, #fef2f2); color: var(--mj-status-error-text, #b91c1c); font-size: 13px; }
    `],
})
export class MeetingHeroPanel extends BaseFormPanel<mjBizAppsTasksMeetingEntity> implements OnInit {
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly data = new MeetingData();
    public detail: MeetingDetail | null = null;
    public loadError = '';
    public error = '';
    public busy = false;
    public askCancel = false;
    public cancelReason = '';
    public liveOpen = false;

    async ngOnInit(): Promise<void> {
        await this.reload();
    }

    async reload(): Promise<void> {
        if (!this.Record?.ID) return;
        try {
            this.detail = await this.data.loadMeeting(this.Record.ID);
            this.loadError = '';
        } catch (e) {
            this.loadError = `The meeting could not be read: ${MeetingData.message(e)}`;
            LogError(this.loadError);
        }
        this.cdr.markForCheck();
    }

    /** After a change on the server, the record under the generated fields reads itself again. */
    private async refreshRecord(): Promise<void> {
        try {
            await this.Record.Load(this.Record.ID);
        } catch (e) {
            LogError(`Meetings: the form's record was not refreshed: ${MeetingData.message(e)}`);
        }
        await this.reload();
    }

    private async run(work: () => Promise<void>): Promise<void> {
        this.busy = true;
        this.error = '';
        this.cdr.markForCheck();
        try {
            await work();
        } catch (e) {
            this.error = MeetingData.message(e);
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    start(): Promise<void> {
        return this.run(async () => {
            const result = await this.data.startMeeting(this.Record.ID);
            if (!result.ok) throw new Error(result.message ?? 'The meeting was not started.');
            await this.refreshRecord();
            this.liveOpen = true;
        });
    }

    end(): Promise<void> {
        return this.run(async () => {
            const result = await this.data.endMeeting(this.Record.ID);
            if (!result.ok) throw new Error(result.message ?? 'The meeting was not ended.');
            this.liveOpen = false;
            await this.refreshRecord();
        });
    }

    cancel(): Promise<void> {
        return this.run(async () => {
            const result = await this.data.cancelMeeting(this.Record.ID, this.cancelReason.trim() || null);
            if (!result.ok) throw new Error(result.message ?? 'The meeting was not cancelled.');
            this.askCancel = false;
            await this.refreshRecord();
        });
    }

    calendar(): Promise<void> {
        return this.run(async () => {
            const file = await this.data.calendarFile(this.Record.ID, this.detail?.row.status === 'Cancelled' ? 'CANCEL' : 'REQUEST');
            downloadTextFile(file.fileName, file.content);
        });
    }

    respond(response: ResponseStatus): Promise<void> {
        return this.run(async () => {
            await this.data.respondToMeeting(this.Record.ID, response);
            await this.reload();
        });
    }

    openSeries(seriesId: string): void {
        OpenSeriesRecord(seriesId);
    }

    liveItem(change: LiveItemChange): Promise<void> {
        return this.run(async () => {
            await this.data.setAgendaItemStatus(change.item.id, change.status, change.outcome);
            await this.reload();
        });
    }

    liveAttendance(change: LiveAttendanceChange): Promise<void> {
        return this.run(async () => {
            await this.data.markAttendance(change.attendee.id, change.attendance);
            await this.reload();
        });
    }

    liveNote(note: LiveQuickNote): Promise<void> {
        return this.run(async () => {
            await this.data.saveNote(this.Record.ID, { id: null, agendaItemId: note.item?.id ?? null, kind: 'Notes', title: '', body: note.body, status: 'Draft' });
            await this.reload();
        });
    }

    liveFollowUp(followUp: LiveFollowUp): Promise<void> {
        return this.run(async () => {
            const taskId = await this.data.addFollowUp(this.Record.ID, { name: followUp.name, agendaItemId: followUp.item?.id ?? null, assigneePersonId: null, dueAt: null });
            await this.reload();
            if (!this.liveOpen) OpenTaskRecord(taskId);
        });
    }
}
