import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    Input,
    OnChanges,
    Output,
    SimpleChanges,
    inject,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Metadata, RunView } from '@memberjunction/core';
import { BuildLikeClause } from '@mj-biz-apps/tasks-core';
import {
    MJButtonDirective,
    MJDialogComponent,
    MJDropdownComponent,
    MJEmptyStateComponent,
} from '@memberjunction/ng-ui-components';
import type { TaskWidgetLinkedRecord } from '@mj-biz-apps/tasks-ng-widgets';

interface EntityOption {
    ID: string;
    Name: string;
    DisplayName: string;
    NameField: string;
    Icon: string;
}

interface SearchRecordRow {
    ID: string;
    DisplayName: string;
}

/**
 * Generic MJ Record Link Picker Dialog built on `<mj-dialog>` + `<mj-dropdown>`.
 * Allows users to attach any business record in MemberJunction to a task via `TaskLink`.
 */
@Component({
    selector: 'bizapps-record-link-picker-dialog',
    standalone: true,
    imports: [FormsModule, MJButtonDirective, MJDialogComponent, MJDropdownComponent, MJEmptyStateComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-dialog
            [Visible]="Visible"
            Title="Link Business Record"
            [Width]="560"
            (Close)="Cancelled.emit()">
            <div class="mjt-rlp">
                <div class="mjt-rlp-controls">
                    <div class="mjt-rlp-field">
                        <label class="mjt-rlp-label">Record Type (Entity)</label>
                        <mj-dropdown
                            [Data]="EntityOptions"
                            TextField="DisplayName"
                            ValueField="Name"
                            [ValuePrimitive]="true"
                            [Filterable]="true"
                            Placeholder="Choose an entity..."
                            AriaLabel="Record entity"
                            [ngModel]="SelectedEntityName"
                            (ngModelChange)="onEntityChanged($event)">
                        </mj-dropdown>
                    </div>

                    <div class="mjt-rlp-field">
                        <label class="mjt-rlp-label">Search Records</label>
                        <div class="mjt-rlp-search-row">
                            <input
                                type="text"
                                class="mjt-rlp-input"
                                [(ngModel)]="SearchTerm"
                                placeholder="Type to search records..."
                                (keydown.enter)="SearchRecords()" />
                            <button
                                type="button"
                                mjButton
                                variant="outline"
                                size="sm"
                                [disabled]="Loading || !SelectedEntityName"
                                (click)="SearchRecords()">
                                <i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i>
                                Search
                            </button>
                        </div>
                    </div>
                </div>

                @if (Loading) {
                    <div class="mjt-rlp-status">Searching records...</div>
                } @else if (Results.length === 0) {
                    <mj-empty-state
                        Icon="fa-solid fa-link"
                        Title="No records found"
                        Message="Select a record type and search to connect it to this task."
                        Size="compact">
                    </mj-empty-state>
                } @else {
                    <div class="mjt-rlp-list" role="listbox">
                        @for (row of Results; track row.ID) {
                            <button
                                type="button"
                                role="option"
                                class="mjt-rlp-row"
                                [class.is-selected]="SelectedRecordID === row.ID"
                                [attr.aria-selected]="SelectedRecordID === row.ID"
                                (click)="SelectedRecordID = row.ID">
                                <i [class]="ActiveEntityIcon" aria-hidden="true"></i>
                                <span class="mjt-rlp-row-name">{{ row.DisplayName }}</span>
                            </button>
                        }
                    </div>
                }

                <div class="mjt-rlp-footer">
                    <button
                        type="button"
                        mjButton
                        variant="primary"
                        size="sm"
                        [disabled]="!SelectedRecordID || !SelectedEntityName"
                        (click)="Confirm()">
                        <i class="fa-solid fa-link" aria-hidden="true"></i>
                        Link Record
                    </button>
                    <button
                        type="button"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="Cancelled.emit()">
                        Cancel
                    </button>
                </div>
            </div>
        </mj-dialog>
    `,
    styles: [`
        .mjt-rlp {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .mjt-rlp-controls {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mjt-rlp-field {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mjt-rlp-label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-rlp-search-row {
            display: flex;
            gap: 8px;
        }
        .mjt-rlp-input {
            flex: 1;
            min-width: 0;
            padding: 7px 10px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
        }
        .mjt-rlp-status {
            padding: 20px;
            text-align: center;
            font-size: var(--mj-text-sm, 14px);
            color: var(--mj-text-muted);
        }
        .mjt-rlp-list {
            display: flex;
            flex-direction: column;
            gap: 4px;
            max-height: 260px;
            overflow-y: auto;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 6px;
            background: var(--mj-bg-surface-sunken);
        }
        .mjt-rlp-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 10px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid transparent;
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            text-align: left;
            cursor: pointer;
        }
        .mjt-rlp-row:hover {
            border-color: var(--mj-border-strong);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-rlp-row.is-selected {
            border-color: var(--mj-brand-primary);
            background: color-mix(in srgb, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-rlp-row i {
            color: var(--mj-brand-primary);
            font-size: 13px;
        }
        .mjt-rlp-row-name {
            flex: 1;
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .mjt-rlp-footer {
            display: flex;
            align-items: center;
            gap: 8px;
            padding-top: 8px;
            border-top: 1px solid var(--mj-border-default);
        }
    `],
})
export class RecordLinkPickerDialogComponent implements OnChanges {
    @Input() Visible = false;
    @Input() DefaultEntityName: string | null = null;

    @Output() RecordSelected = new EventEmitter<TaskWidgetLinkedRecord>();
    @Output() Cancelled = new EventEmitter<void>();

    public EntityOptions: EntityOption[] = [];
    public SelectedEntityName = '';
    public SearchTerm = '';
    public Results: SearchRecordRow[] = [];
    public SelectedRecordID: string | null = null;
    public Loading = false;

    private cdr = inject(ChangeDetectorRef);

    public get ActiveEntityIcon(): string {
        return this.EntityOptions.find((e) => e.Name === this.SelectedEntityName)?.Icon || 'fa-solid fa-link';
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['Visible'] && this.Visible) {
            this.loadEntityOptions();
            this.SelectedRecordID = null;
            this.SearchTerm = '';
            if (this.SelectedEntityName) {
                void this.SearchRecords();
            }
        }
    }

    private loadEntityOptions(): void {
        const entities = Metadata.Provider.Entities ?? [];
        const preferred = [
            'MJ_BizApps_Common: Organizations',
            'MJ_BizApps_Common: People',
            'MJ_BizApps_Tasks: Tasks',
            'MJ_BizApps_Tasks: Meetings',
            'MJ_BizApps_Tasks: Task Categories',
        ];
        const mapped: EntityOption[] = entities
            .filter((e) => e.IncludeInAPI && e.Status === 'Active' && e.FirstPrimaryKey?.Name === 'ID')
            .map((e) => ({
                ID: e.ID,
                Name: e.Name,
                DisplayName: e.DisplayNameOrName,
                NameField: e.NameField?.Name || 'Name',
                Icon: e.Icon || 'fa-solid fa-cube',
            }))
            .sort((a, b) => {
                const ia = preferred.indexOf(a.Name);
                const ib = preferred.indexOf(b.Name);
                if (ia >= 0 && ib >= 0) return ia - ib;
                if (ia >= 0) return -1;
                if (ib >= 0) return 1;
                return a.DisplayName.localeCompare(b.DisplayName);
            });

        this.EntityOptions = mapped;
        if (this.DefaultEntityName && mapped.some((e) => e.Name === this.DefaultEntityName)) {
            this.SelectedEntityName = this.DefaultEntityName;
        } else if (!this.SelectedEntityName && mapped.length > 0) {
            this.SelectedEntityName = mapped[0].Name;
        }
        this.cdr.markForCheck();
    }

    public onEntityChanged(entityName: string): void {
        this.SelectedEntityName = entityName;
        this.SelectedRecordID = null;
        void this.SearchRecords();
    }

    public async SearchRecords(): Promise<void> {
        if (!this.SelectedEntityName) return;
        const opt = this.EntityOptions.find((e) => e.Name === this.SelectedEntityName);
        if (!opt) return;

        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
            const q = this.SearchTerm.trim();
            const hasFirstLast =
                opt.Name === 'MJ_BizApps_Common: People' &&
                !Metadata.Provider.EntityByName(opt.Name)?.Fields.some((f) => f.Name === 'FullName');

            const fields = hasFirstLast ? ['ID', 'FirstName', 'LastName'] : ['ID', opt.NameField];
            const extraFilter = q
                ? hasFirstLast
                    ? `(${BuildLikeClause('FirstName', q, { provider: Metadata.Provider })} OR ${BuildLikeClause('LastName', q, { provider: Metadata.Provider })})`
                    : BuildLikeClause(opt.NameField, q, { provider: Metadata.Provider })
                : undefined;

            const res = await rv.RunView<Record<string, string | null>>({
                EntityName: opt.Name,
                Fields: fields,
                ExtraFilter: extraFilter,
                OrderBy: hasFirstLast ? 'FirstName ASC, LastName ASC' : `${opt.NameField} ASC`,
                MaxRows: 25,
                ResultType: 'simple',
            });

            this.Results = (res.Results ?? []).map((row) => {
                const name = hasFirstLast
                    ? `${row['FirstName'] ?? ''} ${row['LastName'] ?? ''}`.trim() || String(row['ID'] ?? '')
                    : String(row[opt.NameField] ?? row['ID'] ?? '');
                return { ID: String(row['ID'] ?? ''), DisplayName: name };
            });
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public Confirm(): void {
        const row = this.Results.find((r) => r.ID === this.SelectedRecordID);
        if (!row || !this.SelectedEntityName) return;
        this.RecordSelected.emit({
            EntityName: this.SelectedEntityName,
            RecordID: row.ID,
            DisplayName: row.DisplayName,
            IconClass: this.ActiveEntityIcon,
        });
    }
}
