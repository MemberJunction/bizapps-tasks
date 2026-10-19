import { ChangeDetectorRef, Component, Directive, OnInit, inject } from '@angular/core';
import { RegisterClassEx } from '@memberjunction/global';
import { LogError } from '@memberjunction/core';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingSeriesEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_AGENDA_ITEM_ENTITY, MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, MEETING_LINK_ENTITY, MEETING_NOTE_ENTITY, MEETING_SERIES_ENTITY } from '@mj-biz-apps/tasks-core';
import {
    describeRecurrenceRule,
    parseRecurrenceRuleDraft,
    type AgendaItemDraft,
    type AgendaItemModel,
    type AgendaItemTypeOption,
    type AgendaMove,
    type AgendaReorder,
    type AttendanceChange,
    type FollowUpDraft,
    type FollowUpModel,
    type InviteRequest,
    type LinkModel,
    type MeetingRow,
    type NoteDraft,
    type NoteModel,
    type PersonOption,
} from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingData, type MeetingDetail } from '../meetings/meeting-data';
import { OpenTaskRecord } from '../open-task-record';
import { OpenMeetingRecord } from '../pages/meetings-shared';
import { CompositeKey } from '@memberjunction/core';
import { SharedService } from '@memberjunction/ng-shared';

/**
 * The sections of the meeting page that stand in for the generated related-entity grids (the meetings plan, § 5):
 * Agenda, People, Notes, Follow-ups and Belongs to. Each reads what it shows through MeetingData, asks for changes through
 * the widget's outputs, and reads again after.
 */
@Directive()
abstract class MeetingSectionPanel extends BaseFormPanel<mjBizAppsTasksMeetingEntity> implements OnInit {
    protected readonly cdr = inject(ChangeDetectorRef);
    protected readonly data = new MeetingData();
    public detail: MeetingDetail | null = null;
    public people: PersonOption[] = [];
    public busy = false;
    public error = '';

    async ngOnInit(): Promise<void> {
        await this.reload();
    }

    protected get meetingId(): string {
        return this.Record?.ID ?? '';
    }

    async reload(): Promise<void> {
        if (!this.meetingId) return;
        try {
            this.detail = await this.data.LoadMeeting(this.meetingId);
            if (!this.people.length && this.wantsPeople) this.people = await this.data.LoadPeople();
        } catch (e) {
            this.error = `This section could not be read: ${MeetingData.Message(e)}`;
            LogError(this.error);
        }
        this.cdr.markForCheck();
    }

    protected get wantsPeople(): boolean {
        return false;
    }

    protected async run(work: () => Promise<void>): Promise<void> {
        this.busy = true;
        this.error = '';
        this.cdr.markForCheck();
        try {
            await work();
            await this.reload();
        } catch (e) {
            this.error = MeetingData.Message(e);
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:agenda',
    metadata: { entity: MEETING_ENTITY, slot: 'after-fields', sortKey: 90, relatedEntity: MEETING_AGENDA_ITEM_ENTITY, relatedJoinField: 'MeetingID', contributionKey: 'agenda' },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-agenda-panel',
    template: `
        <mj-collapsible-panel SectionKey="agenda" SectionName="Agenda" Icon="fa-solid fa-list-ol">
            @if (detail; as d) {
                <bizapps-meeting-agenda [Items]="d.agenda" [ItemTypes]="itemTypes" [People]="people" [MeetingMinutes]="minutes(d.row)" [HasTemplate]="d.typeHasTemplate" [CanEdit]="d.permissions.canEdit && d.row.status !== 'Cancelled' && d.row.status !== 'Completed'" [Busy]="busy" [ErrorMessage]="error"
                    (SaveRequested)="save($event)" (RemoveRequested)="remove($event)" (ReorderRequested)="reorder($event)" (MoveRequested)="move($event)" (TemplateRequested)="template()"></bizapps-meeting-agenda>
            } @else if (error) { <div class="mjt-error">{{ error }}</div> }
        </mj-collapsible-panel>
    `,
    styleUrls: ['./task-form.css'],
})
export class MeetingAgendaPanel extends MeetingSectionPanel {
    protected itemTypes: AgendaItemTypeOption[] = [];

    protected override get wantsPeople(): boolean {
        return true;
    }

    override async ngOnInit(): Promise<void> {
        await super.ngOnInit();
        try {
            this.itemTypes = await this.data.LoadAgendaItemTypes();
        } catch (e) {
            LogError(`Meetings: the agenda item types could not be read: ${MeetingData.Message(e)}`);
        }
        this.cdr.markForCheck();
    }

    protected minutes(row: MeetingRow): number {
        return Math.round((row.endsAt.getTime() - row.startsAt.getTime()) / 60000);
    }

    protected save(draft: AgendaItemDraft): Promise<void> {
        return this.run(() => this.data.SaveAgendaItem(this.meetingId, draft, this.detail?.agenda ?? []));
    }

    protected remove(item: AgendaItemModel): Promise<void> {
        return this.run(() => this.data.RemoveAgendaItem(item.id));
    }

    protected reorder(change: AgendaReorder): Promise<void> {
        return this.run(() => this.data.ReorderAgenda(this.meetingId, change.orderedIds));
    }

    protected move(change: AgendaMove): Promise<void> {
        return this.run(() => this.data.MoveAgendaItem(change.item.id, change.parentId, this.detail?.agenda ?? []));
    }

    template(): Promise<void> {
        return this.run(async () => {
            if (!this.detail?.typeId) throw new Error('The meeting has no type, so there is no template.');
            await this.data.ApplyTemplate(this.meetingId, this.detail.typeId);
        });
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:people',
    metadata: { entity: MEETING_ENTITY, slot: 'after-fields', sortKey: 80, relatedEntity: MEETING_ATTENDEE_ENTITY, relatedJoinField: 'MeetingID', contributionKey: 'people' },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-people-panel',
    template: `
        <mj-collapsible-panel SectionKey="people" SectionName="People" Icon="fa-solid fa-users">
            @if (detail; as d) {
                <bizapps-meeting-people [Attendees]="d.attendees" [People]="people" [CanInvite]="d.permissions.canInvite && d.row.status !== 'Cancelled'" [CanMarkAttendance]="d.permissions.canRun" [ShowAttendance]="d.row.status === 'InProgress' || d.row.status === 'Completed'" [Busy]="busy" [ErrorMessage]="error"
                    (InviteRequested)="invite($event)" (RemoveRequested)="remove($event)" (AttendanceChanged)="attendance($event)"></bizapps-meeting-people>
            } @else if (error) { <div class="mjt-error">{{ error }}</div> }
        </mj-collapsible-panel>
    `,
    styleUrls: ['./task-form.css'],
})
export class MeetingPeoplePanel extends MeetingSectionPanel {
    protected override get wantsPeople(): boolean {
        return true;
    }

    protected invite(request: InviteRequest): Promise<void> {
        return this.run(() => this.data.Invite(this.meetingId, request));
    }

    protected remove(attendee: { id: string }): Promise<void> {
        return this.run(() => this.data.RemoveAttendee(attendee.id));
    }

    protected attendance(change: AttendanceChange): Promise<void> {
        return this.run(() => this.data.MarkAttendance(change.attendee.id, change.attendance));
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:notes',
    metadata: { entity: MEETING_ENTITY, slot: 'after-fields', sortKey: 70, relatedEntity: MEETING_NOTE_ENTITY, relatedJoinField: 'MeetingID', contributionKey: 'notes' },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-notes-panel',
    template: `
        <mj-collapsible-panel SectionKey="notes" SectionName="Notes" Icon="fa-solid fa-note-sticky">
            @if (detail; as d) {
                <bizapps-meeting-notes [Notes]="d.notes" [AgendaItems]="d.agenda" [CanWrite]="d.permissions.canWriteNotes" [CanEditAll]="d.permissions.canEdit" [Busy]="busy" [ErrorMessage]="error"
                    (SaveRequested)="save($event)" (DeleteRequested)="remove($event)"></bizapps-meeting-notes>
            } @else if (error) { <div class="mjt-error">{{ error }}</div> }
        </mj-collapsible-panel>
    `,
    styleUrls: ['./task-form.css'],
})
export class MeetingNotesPanel extends MeetingSectionPanel {
    protected save(draft: NoteDraft): Promise<void> {
        return this.run(() => this.data.SaveNote(this.meetingId, draft));
    }

    protected remove(note: NoteModel): Promise<void> {
        return this.run(() => this.data.DeleteNote(note.id));
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:followups',
    metadata: { entity: MEETING_ENTITY, slot: 'after-fields', sortKey: 60, contributionKey: 'followups' },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-followups-panel',
    template: `
        <mj-collapsible-panel SectionKey="followups" SectionName="Follow-ups" Icon="fa-solid fa-list-check">
            @if (detail; as d) {
                <bizapps-meeting-followups [FollowUps]="d.followUps" [AgendaItems]="d.agenda" [People]="people" [CanAdd]="d.permissions.canAddFollowUps" [Busy]="busy" [ErrorMessage]="error"
                    (AddRequested)="add($event)" (OpenRequested)="open($event)"></bizapps-meeting-followups>
            } @else if (error) { <div class="mjt-error">{{ error }}</div> }
        </mj-collapsible-panel>
    `,
    styleUrls: ['./task-form.css'],
})
export class MeetingFollowUpsPanel extends MeetingSectionPanel {
    protected override get wantsPeople(): boolean {
        return true;
    }

    protected add(draft: FollowUpDraft): Promise<void> {
        return this.run(async () => {
            await this.data.AddFollowUp(this.meetingId, draft);
        });
    }

    protected open(task: FollowUpModel): void {
        OpenTaskRecord(task.id);
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Meetings:links',
    metadata: { entity: MEETING_ENTITY, slot: 'after-fields', sortKey: 50, relatedEntity: MEETING_LINK_ENTITY, relatedJoinField: 'MeetingID', contributionKey: 'links' },
})
@Component({
    standalone: false,
    selector: 'mjt-meeting-links-panel',
    template: `
        <mj-collapsible-panel SectionKey="links" SectionName="Belongs to" Icon="fa-solid fa-link">
            @if (detail; as d) {
                <bizapps-meeting-links [Links]="d.links" [CanEdit]="d.permissions.canEdit" [Busy]="busy" [ErrorMessage]="error" (OpenRequested)="open($event)" (RemoveRequested)="remove($event)" (AddRequested)="add()"></bizapps-meeting-links>
            } @else if (error) { <div class="mjt-error">{{ error }}</div> }
        </mj-collapsible-panel>
    `,
    styleUrls: ['./task-form.css'],
})
export class MeetingLinksPanel extends MeetingSectionPanel {
    protected open(link: LinkModel): void {
        SharedService.Instance.OpenEntityRecord(link.entityName, CompositeKey.FromID(link.recordId));
    }

    protected remove(link: LinkModel): Promise<void> {
        return this.run(() => this.data.RemoveLink(link.id));
    }

    /** A new link is a Meeting Links record: the generated form for it, with the meeting filled in. */
    protected add(): void {
        SharedService.Instance.OpenEntityRecord(MEETING_LINK_ENTITY, new CompositeKey());
    }
}

/** The series page: the rule in words and the occurrences made so far, each opening its meeting. */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:MeetingSeries:occurrences',
    metadata: { entity: MEETING_SERIES_ENTITY, slot: 'after-fields', sortKey: 90, relatedEntity: MEETING_ENTITY, relatedJoinField: 'SeriesID', contributionKey: 'occurrences' },
})
@Component({
    standalone: false,
    selector: 'mjt-series-occurrences-panel',
    template: `
        <mj-collapsible-panel SectionKey="occurrences" SectionName="Meetings in this series" Icon="fa-solid fa-repeat">
            <div class="rule">{{ RuleText }}</div>
            <bizapps-meeting-list [Meetings]="occurrences" [IsLoading]="loading" [ErrorMessage]="error" [ShowResponse]="false" EmptyTitle="No meetings yet" EmptyMessage="The series makes them once it is saved and active." (Selected)="open($event)" (OpenRequested)="open($event)"></bizapps-meeting-list>
        </mj-collapsible-panel>
    `,
    styles: [`.rule { font-size: 13px; color: var(--mj-text-muted, #64748b); margin: 4px 0 10px; }`],
})
export class SeriesOccurrencesPanel extends BaseFormPanel<mjBizAppsTasksMeetingSeriesEntity> implements OnInit {
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly data = new MeetingData();
    protected occurrences: MeetingRow[] = [];
    protected loading = true;
    protected error = '';

    async ngOnInit(): Promise<void> {
        if (!this.Record?.ID) return;
        try {
            this.occurrences = await this.data.LoadMeetingRows({ mine: false, extraFilter: `SeriesID = '${this.Record.ID}'` });
        } catch (e) {
            this.error = `The occurrences could not be read: ${MeetingData.Message(e)}`;
            LogError(this.error);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    get RuleText(): string {
        const parsed = parseRecurrenceRuleDraft(this.Record?.RecurrenceRule);
        return parsed ? describeRecurrenceRule(parsed) : (this.Record?.RecurrenceRule ?? '');
    }

    protected open(meeting: MeetingRow): void {
        OpenMeetingRecord(meeting.id);
    }
}
