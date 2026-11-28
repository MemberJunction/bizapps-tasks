import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    Input,
    OnChanges,
    OnInit,
    Output,
    SimpleChanges,
    inject,
} from '@angular/core';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { SharedService } from '@memberjunction/ng-shared';
import { TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ConnectedTasksWidgetComponent,
    type TaskApprovalActionEvent,
    type TaskQuickCaptureSubmitEvent,
    type TaskStatusValue,
    type TaskWidgetItem,
    type TaskWidgetLinkedRecord,
} from '@mj-biz-apps/tasks-ng-widgets';
import { OpenTaskRecord } from '../../open-task-record';

interface LinkedTaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    DueAt: string | null;
    StartedAt: string | null;
    PercentComplete: number;
    ParentID: string | null;
    TypeID: string;
    Type: string | null;
    TaskTypeStatusID: string | null;
    TaskTypeStatus: string | null;
    PredictedSLARiskBand: mjBizAppsTasksTaskEntity['PredictedSLARiskBand'];
}

/**
 * Drop-in MJ data-connected host around `<mjt-connected-tasks>` (L2/L3).
 *
 * Place `<bizapps-connected-tasks [EntityName]="'...'" [RecordID]="record.ID">`
 * on ANY MJ entity form (Deal, Account, Contact, Order, Committee, Meeting) to
 * render record-scoped tasks with native `@container` reflow, quick-add that
 * automatically creates `Task` + `TaskLink`, 1-click completion, and inline approvals.
 */
@Component({
    selector: 'bizapps-connected-tasks',
    standalone: true,
    imports: [ConnectedTasksWidgetComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mjt-connected-tasks
            [Title]="Title"
            [Tasks]="Tasks"
            [ContextRecord]="ContextRecord"
            [Loading]="Loading"
            [Busy]="Busy"
            [ReadOnly]="ReadOnly"
            [ShowHeader]="ShowHeader"
            [ShowQuickAdd]="ShowQuickAdd"
            [ShowLinkedRecords]="false"
            (TaskClicked)="onTaskClick($event)"
            (TaskDoubleClicked)="onTaskDoubleClick($event)"
            (StatusToggled)="onStatusToggle($event)"
            (QuickAddSubmitted)="onQuickAdd($event)"
            (ApprovalActionRequested)="onApprovalAction($event)"
            (LinkedRecordClicked)="onLinkedRecordClick($event)">
        </mjt-connected-tasks>
    `,
    styles: [`:host { display: block; width: 100%; min-width: 0; }`],
})
export class ConnectedTasksHostComponent implements OnInit, OnChanges {
    @Input({ required: true }) EntityName!: string;
    @Input({ required: true }) RecordID!: string;
    @Input() RecordDisplayName: string | null = null;
    @Input() Title = 'Connected Tasks';
    @Input() PersonID: string | null = null;
    @Input() ShowHeader = true;
    @Input() ShowQuickAdd = true;
    @Input() ReadOnly = false;

    @Output() TaskSelected = new EventEmitter<string>();
    @Output() TasksChanged = new EventEmitter<void>();

    public Tasks: TaskWidgetItem[] = [];
    public Loading = false;
    public Busy = false;

    private cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();

    public get ContextRecord(): TaskWidgetLinkedRecord | null {
        if (!this.EntityName || !this.RecordID) return null;
        const entity = Metadata.Provider.EntityByName(this.EntityName);
        return {
            EntityName: this.EntityName,
            RecordID: this.RecordID,
            DisplayName: this.RecordDisplayName || entity?.DisplayNameOrName || this.EntityName,
            IconClass: entity?.Icon || 'fa-solid fa-link',
        };
    }

    public ngOnInit(): void {
        void this.Refresh();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if ((changes['EntityName'] || changes['RecordID']) && !changes['EntityName']?.firstChange) {
            void this.Refresh();
        }
    }

    public async Refresh(bypassCache = false): Promise<void> {
        if (!this.EntityName || !this.RecordID) return;
        const entity = Metadata.Provider.EntityByName(this.EntityName);
        if (!entity) return;

        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
            const linkRes = await rv.RunView<{ TaskID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Links',
                ExtraFilter: `EntityID = '${EscapeSQLString(entity.ID)}' AND RecordID = '${EscapeSQLString(this.RecordID)}'`,
                Fields: ['TaskID'],
                ResultType: 'simple',
                BypassCache: bypassCache,
            });
            const taskIds = [...new Set((linkRes.Results ?? []).map((r) => r.TaskID))];
            if (taskIds.length === 0) {
                this.Tasks = [];
                return;
            }

            const [tasksRes, typesRes] = await Promise.all([
                rv.RunView<LinkedTaskRow>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID IN (${taskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')}) AND Status <> 'Cancelled'`,
                    OrderBy: 'DueAt ASC, Sequence ASC',
                    ResultType: 'simple',
                    BypassCache: bypassCache,
                }),
                rv.RunView<{ ID: string; Code: string; IsApproval: boolean }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Types',
                    Fields: ['ID', 'Code', 'IsApproval'],
                    ResultType: 'simple',
                }),
            ]);

            const typeMap = new Map<string, { Code: string; IsApproval: boolean }>();
            for (const tt of typesRes.Results ?? []) {
                typeMap.set(tt.ID.toLowerCase(), { Code: tt.Code, IsApproval: tt.IsApproval });
            }

            this.Tasks = (tasksRes.Results ?? []).map((r) => {
                const tt = typeMap.get(r.TypeID.toLowerCase());
                return {
                    ID: r.ID,
                    Name: r.Name,
                    Description: r.Description,
                    ParentID: r.ParentID,
                    Status: r.Status,
                    Priority: r.Priority,
                    DueAt: r.DueAt,
                    StartedAt: r.StartedAt,
                    PercentComplete: r.PercentComplete ?? 0,
                    TypeID: r.TypeID,
                    TypeName: r.Type,
                    TypeCode: tt?.Code ?? null,
                    IsApproval: tt?.IsApproval ?? false,
                    TaskTypeStatusID: r.TaskTypeStatusID,
                    TaskTypeStatusName: r.TaskTypeStatus,
                    PredictedSLARiskBand: r.PredictedSLARiskBand,
                };
            });
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public onTaskClick(taskID: string): void {
        if (this.TaskSelected.observed) {
            this.TaskSelected.emit(taskID);
        } else {
            OpenTaskRecord(taskID);
        }
    }

    public onTaskDoubleClick(taskID: string): void {
        OpenTaskRecord(taskID);
    }

    public async onStatusToggle(event: { TaskID: string; NewStatus: TaskStatusValue }): Promise<void> {
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(event.TaskID));
            entity.Status = event.NewStatus;
            entity.PercentComplete = event.NewStatus === 'Completed' ? 100 : 0;
            await entity.Save();
            await this.Refresh(true);
            this.TasksChanged.emit();
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onQuickAdd(event: TaskQuickCaptureSubmitEvent): Promise<void> {
        const targetEntity = Metadata.Provider.EntityByName(this.EntityName);
        if (!targetEntity) return;

        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
            const typeRes = await rv.RunView<{ ID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Types',
                ExtraFilter: `Code = 'GENERAL'`,
                Fields: ['ID'],
                MaxRows: 1,
                ResultType: 'simple',
            });
            const defaultTypeId = typeRes.Results?.[0]?.ID;
            if (!defaultTypeId) return;

            const task = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            task.NewRecord();
            task.Name = event.Title;
            task.TypeID = defaultTypeId;
            task.Status = 'Open';
            task.Priority = event.Priority ?? 'Medium';
            if (event.DueAt) task.DueAt = event.DueAt;
            if (event.HoursEstimated != null) task.HoursEstimated = event.HoursEstimated;
            if (this.PersonID) task.CreatedByPersonID = this.PersonID;

            if (await task.Save()) {
                const link = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>('MJ_BizApps_Tasks: Task Links');
                link.NewRecord();
                link.TaskID = task.ID;
                link.EntityID = targetEntity.ID;
                link.RecordID = this.RecordID;
                link.Description = this.RecordDisplayName || targetEntity.DisplayNameOrName;
                await link.Save();
                await this.Refresh(true);
                this.TasksChanged.emit();
            }
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onApprovalAction(event: TaskApprovalActionEvent): Promise<void> {
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            await this.orchestration.RecordDecision({
                TaskID: event.TaskID,
                OutcomeCode: event.OutcomeCode,
                DecidedByPersonID: this.PersonID ?? undefined,
                Notes: event.Notes ?? undefined,
            });
            await this.Refresh(true);
            this.TasksChanged.emit();
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public onLinkedRecordClick(rec: TaskWidgetLinkedRecord): void {
        SharedService.Instance.OpenEntityRecord(rec.EntityName, CompositeKey.FromID(rec.RecordID));
    }
}
