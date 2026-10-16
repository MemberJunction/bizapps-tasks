import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LogError } from '@memberjunction/core';
import { MJButtonDirective, MJDialogComponent } from '@memberjunction/ng-ui-components';
import {
    MeetingListComponent,
    NewMeetingFormComponent,
    emptyMeetingDraft,
    viewerTimeZone,
    type MeetingResponseChange,
    type MeetingRow,
    type MeetingTypeOption,
    type NewMeetingDraft,
    type PersonOption,
    type VideoProviderOption,
} from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingData } from '../meetings/meeting-data';
import { MEETINGS_PAGE_CSS, OpenMeetingRecord } from './meetings-shared';
import { NO_PERSON_MESSAGE } from '../current-person';

/**
 * My meetings (the meetings plan, § 5): what the viewer organizes or is invited to, upcoming first, with their answer on
 * each row and a New meeting button.
 */
@Component({
    selector: 'bizapps-my-meetings-page',
    standalone: true,
    imports: [CommonModule, MJButtonDirective, MJDialogComponent, MeetingListComponent, NewMeetingFormComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar"><i class="fa-solid fa-user-clock" aria-hidden="true"></i></div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">My meetings</h1>
                            <p class="mjt-subtitle">Meetings you organize or are invited to. Answer here; the organizer sees it.</p>
                        </div>
                    </div>
                    <div class="mjt-actions">
                        <div class="mjt-seg" role="group" aria-label="Which meetings">
                            <button type="button" [class.on]="range === 'upcoming'" (click)="setRange('upcoming')">Upcoming</button>
                            <button type="button" [class.on]="range === 'past'" (click)="setRange('past')">Past</button>
                        </div>
                        <button mjButton Variant="primary" Size="md" (click)="openNew()"><i class="fa-solid fa-plus"></i>New meeting</button>
                    </div>
                </div>
            </div>
            <div class="mjt-body-card">
                @if (NoPerson) { <p class="mjt-empty">{{ NoPersonMessage }}</p> }
                <bizapps-meeting-list [Meetings]="meetings" [IsLoading]="loading" [ErrorMessage]="error" [Order]="range === 'past' ? 'desc' : 'asc'" [ResponseBusyID]="busyId"
                    EmptyTitle="Nothing on your calendar" [EmptyMessage]="range === 'past' ? 'No past meetings yet.' : 'No upcoming meetings. Schedule one, or wait for an invitation.'"
                    (Selected)="open($event)" (OpenRequested)="open($event)" (ResponseChanged)="respond($event)"></bizapps-meeting-list>
            </div>
        </div>
        <mj-dialog [Visible]="newOpen" Title="New meeting" Size="lg" (Close)="newOpen = false">
            <div class="mjt-dialog-body">
                <bizapps-new-meeting-form [Value]="draft" [Types]="types" [People]="people" [VideoProviders]="providers" [TypesWithTemplate]="typesWithTemplate" [Busy]="saving" [ErrorMessage]="saveError" (SubmitRequested)="create($event)" (CancelRequested)="newOpen = false"></bizapps-new-meeting-form>
            </div>
        </mj-dialog>
    `,
    styles: [MEETINGS_PAGE_CSS],
})
export class MyMeetingsPageComponent implements OnInit {
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly data = new MeetingData();
    public meetings: MeetingRow[] = [];
    public loading = true;
    public error = '';
    public busyId: string | null = null;
    public range: 'upcoming' | 'past' = 'upcoming';
    public NoPerson = false;
    public readonly NoPersonMessage = NO_PERSON_MESSAGE;
    public newOpen = false;
    public saving = false;
    public saveError = '';
    public draft: NewMeetingDraft = emptyMeetingDraft(viewerTimeZone());
    public types: MeetingTypeOption[] = [];
    public people: PersonOption[] = [];
    public providers: VideoProviderOption[] = [];
    public typesWithTemplate: string[] = [];

    async ngOnInit(): Promise<void> {
        this.NoPerson = (await this.data.currentPersonId()) === null;
        await this.load();
    }

    async load(): Promise<void> {
        this.loading = true;
        this.error = '';
        this.cdr.markForCheck();
        try {
            const now = new Date();
            this.meetings = await this.data.loadMeetingRows(this.range === 'upcoming' ? { mine: true, from: now } : { mine: true, through: now });
        } catch (e) {
            this.error = `Your meetings could not be read: ${MeetingData.message(e)}`;
            LogError(this.error);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    setRange(range: 'upcoming' | 'past'): void {
        if (this.range === range) return;
        this.range = range;
        void this.load();
    }

    open(meeting: MeetingRow): void {
        OpenMeetingRecord(meeting.id);
    }

    async respond(change: MeetingResponseChange): Promise<void> {
        this.busyId = change.meeting.id;
        this.cdr.markForCheck();
        try {
            await this.data.respondToMeeting(change.meeting.id, change.response);
            this.meetings = this.meetings.map((m) => (m.id === change.meeting.id ? { ...m, myResponse: change.response } : m));
        } catch (e) {
            this.error = `Your answer was not saved: ${MeetingData.message(e)}`;
        } finally {
            this.busyId = null;
            this.cdr.markForCheck();
        }
    }

    async openNew(): Promise<void> {
        this.saveError = '';
        this.draft = emptyMeetingDraft(viewerTimeZone());
        this.newOpen = true;
        this.cdr.markForCheck();
        try {
            [this.types, this.people, this.providers] = await Promise.all([this.data.loadTypes(), this.data.loadPeople(), this.data.loadVideoProviders()]);
            this.typesWithTemplate = this.data.typesWithTemplate();
        } catch (e) {
            this.saveError = `The form's choices could not be read: ${MeetingData.message(e)}`;
        }
        this.cdr.markForCheck();
    }

    async create(draft: NewMeetingDraft): Promise<void> {
        this.saving = true;
        this.saveError = '';
        this.cdr.markForCheck();
        try {
            const meeting = await this.data.createMeeting(draft);
            this.newOpen = false;
            await this.load();
            OpenMeetingRecord(meeting.ID);
        } catch (e) {
            this.saveError = MeetingData.message(e);
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }
}
