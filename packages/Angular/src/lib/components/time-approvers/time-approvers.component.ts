import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    inject,
    Input,
    OnInit,
    Output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { UUIDsEqual } from '@memberjunction/global';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import {
    TasksSettings,
    UserCanManageTimesheets,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTimeApproverEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Display row representing a direct or inherited time approver.
 */
export interface TimeApproverDisplayRow {
    ID: string;
    ApproverPersonID: string;
    ApproverPerson: string;
    EffectiveFrom: string | null;
    EffectiveTo: string | null;
    Notes: string | null;
    IsActiveToday: boolean;
}

/**
 * Inherited approver summary when a task has no direct `TimeApprover` rows of its own.
 */
export interface InheritedApproverSource {
    SourceLabel: string;
    ApproverNames: string[];
}

interface PersonLookupRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
}

function isApproverActiveOn(
    row: { IsActive?: boolean | null; EffectiveFrom: string | null; EffectiveTo: string | null },
    todayIso: string,
): boolean {
    if (row.IsActive === false) {
        return false;
    }
    if (row.EffectiveFrom && row.EffectiveFrom > todayIso) {
        return false;
    }
    if (row.EffectiveTo && row.EffectiveTo < todayIso) {
        return false;
    }
    return true;
}

/**
 * Component for viewing and managing `TimeApprover` rows on any scope record
 * (a task, a person, a space, or another application record).
 *
 * Holders of the `Manage Timesheets` authorization can add or remove approvers.
 * On a task with no direct approvers, displays the inherited approvers and the
 * ancestor or fallback source they come from.
 */
@Component({
    selector: 'bizapps-time-approvers',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule, SharedGenericModule],
    template: `
        @if (enabled && ScopeRecordID) {
            <div class="time-approvers-section">
                <div class="section-header">
                    <span class="section-title">
                        <i class="fa-solid fa-user-check"></i> Time Approvers
                    </span>
                    @if (canEdit && !addingApprover) {
                        <button type="button" class="btn-link" (click)="openAddApprover()">
                            <i class="fa-solid fa-plus"></i> Add approver
                        </button>
                    }
                </div>

                @if (loading) {
                    <mj-loading text="Loading time approvers..." size="small"></mj-loading>
                } @else {
                    @if (directApprovers.length > 0) {
                        <div class="approver-list">
                            @for (row of directApprovers; track row.ID) {
                                <div class="approver-item" [class.approver-item--inactive]="!row.IsActiveToday">
                                    <div class="approver-info">
                                        <span class="approver-name">{{ row.ApproverPerson }}</span>
                                        @if (row.EffectiveFrom || row.EffectiveTo) {
                                            <span class="approver-dates">
                                                {{ row.EffectiveFrom || '…' }} – {{ row.EffectiveTo || '…' }}
                                            </span>
                                        }
                                        @if (!row.IsActiveToday) {
                                            <span class="inactive-badge">Inactive today</span>
                                        }
                                        @if (row.Notes) {
                                            <span class="approver-notes">{{ row.Notes }}</span>
                                        }
                                    </div>
                                    @if (canEdit) {
                                        @if (confirmingRemoveID === row.ID) {
                                            <div class="remove-confirm">
                                                <button
                                                    type="button"
                                                    class="btn-sm btn-danger"
                                                    [disabled]="saving"
                                                    (click)="confirmRemove(row.ID)">
                                                    Remove
                                                </button>
                                                <button
                                                    type="button"
                                                    class="btn-sm btn-secondary"
                                                    [disabled]="saving"
                                                    (click)="confirmingRemoveID = null">
                                                    Cancel
                                                </button>
                                            </div>
                                        } @else {
                                            <button
                                                type="button"
                                                class="btn-icon"
                                                title="Remove approver"
                                                (click)="confirmingRemoveID = row.ID">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        }
                                    }
                                </div>
                            }
                        </div>
                    } @else if (inheritedSource) {
                        <div class="inherited-notice">
                            <i class="fa-solid fa-sitemap"></i>
                            <span>
                                Inherited from <strong>{{ inheritedSource.SourceLabel }}</strong>:
                                {{ inheritedSource.ApproverNames.join(', ') }}
                            </span>
                        </div>
                    } @else {
                        <p class="empty-note">No time approvers configured on this record.</p>
                    }

                    @if (addingApprover && canEdit) {
                        <div class="add-approver-form">
                            <div class="form-row">
                                <div class="form-field flex-2">
                                    <label>Approver *</label>
                                    <select [(ngModel)]="newPersonID" class="form-input">
                                        <option value="">Select person...</option>
                                        @for (person of availablePeople; track person.ID) {
                                            <option [value]="person.ID">
                                                {{ person.FirstName }} {{ person.LastName }}
                                            </option>
                                        }
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label>Effective From</label>
                                    <input type="date" [(ngModel)]="newEffectiveFrom" class="form-input" />
                                </div>
                                <div class="form-field">
                                    <label>Effective To</label>
                                    <input type="date" [(ngModel)]="newEffectiveTo" class="form-input" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label>Notes</label>
                                <input
                                    type="text"
                                    [(ngModel)]="newNotes"
                                    placeholder="Optional notes..."
                                    class="form-input" />
                            </div>
                            <div class="form-actions">
                                <button
                                    type="button"
                                    class="btn-sm btn-primary"
                                    [disabled]="saving || !newPersonID"
                                    (click)="saveNewApprover()">
                                    {{ saving ? 'Saving...' : 'Add Approver' }}
                                </button>
                                <button
                                    type="button"
                                    class="btn-sm btn-secondary"
                                    [disabled]="saving"
                                    (click)="cancelAddApprover()">
                                    Cancel
                                </button>
                            </div>
                        </div>
                    }

                    @if (errorMessage) {
                        <div class="error-banner" role="alert">{{ errorMessage }}</div>
                    }
                }
            </div>
        }
    `,
    styles: [`
        :host {
            display: block;
            font-family: var(--mj-font-family);
        }
        .time-approvers-section {
            margin-top: 16px;
            padding-top: 14px;
            border-top: 1px solid var(--mj-border-subtle);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        .section-title {
            font-size: 12px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.4px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-link {
            border: none;
            background: transparent;
            color: var(--mj-brand-primary);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 2px 6px;
        }
        .btn-link:hover {
            text-decoration: underline;
        }
        .approver-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .approver-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 10px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
            font-size: 13px;
        }
        .approver-item--inactive {
            opacity: 0.65;
        }
        .approver-info {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
        }
        .approver-name {
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }
        .approver-dates {
            font-size: 11px;
            color: var(--mj-text-muted);
        }
        .inactive-badge {
            font-size: 10px;
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            font-weight: var(--mj-font-semibold);
        }
        .approver-notes {
            font-size: 12px;
            color: var(--mj-text-muted);
        }
        .inherited-notice {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            font-size: 12px;
        }
        .empty-note {
            margin: 0;
            font-size: 12px;
            color: var(--mj-text-disabled);
        }
        .add-approver-form {
            margin-top: 10px;
            padding: 12px;
            border-radius: var(--mj-radius-md);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .form-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .form-field {
            flex: 1;
            min-width: 120px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .form-field.flex-2 {
            flex: 2;
            min-width: 180px;
        }
        .form-field label {
            font-size: 11px;
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-muted);
        }
        .form-input {
            padding: 6px 8px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-size: 13px;
            font-family: inherit;
        }
        .form-actions {
            display: flex;
            gap: 8px;
            margin-top: 4px;
        }
        .remove-confirm {
            display: inline-flex;
            gap: 4px;
        }
        .btn-sm {
            padding: 5px 10px;
            border-radius: var(--mj-radius-sm);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            border: 1px solid var(--mj-border-default);
        }
        .btn-primary {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-inverse);
        }
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .btn-secondary {
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
        .btn-danger {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .btn-icon {
            border: none;
            background: transparent;
            color: var(--mj-text-disabled);
            cursor: pointer;
            padding: 4px;
        }
        .btn-icon:hover {
            color: var(--mj-status-error);
        }
        .error-banner {
            margin-top: 8px;
            padding: 8px 10px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border);
            font-size: 12px;
        }
    `],
})
export class TimeApproversComponent implements OnInit {
    private _scopeEntityName = 'MJ_BizApps_Tasks: Tasks';
    private _scopeEntityID: string | null = null;
    private _scopeRecordID: string | null = null;
    private _readOnly = false;

    @Input()
    public get ScopeEntityName(): string {
        return this._scopeEntityName;
    }
    public set ScopeEntityName(value: string) {
        const changed = value !== this._scopeEntityName;
        this._scopeEntityName = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    @Input()
    public get ScopeEntityID(): string | null {
        return this._scopeEntityID;
    }
    public set ScopeEntityID(value: string | null) {
        const changed = value !== this._scopeEntityID;
        this._scopeEntityID = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    @Input()
    public get ScopeRecordID(): string | null {
        return this._scopeRecordID;
    }
    public set ScopeRecordID(value: string | null) {
        const changed = value !== this._scopeRecordID;
        this._scopeRecordID = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    @Input()
    public get ReadOnly(): boolean {
        return this._readOnly;
    }
    public set ReadOnly(value: boolean) {
        this._readOnly = value;
        this.cdr.markForCheck();
    }

    @Output() public ApproversChanged = new EventEmitter<void>();

    public enabled = false;
    public loading = false;
    public saving = false;
    public canManageTimesheets = false;
    public directApprovers: TimeApproverDisplayRow[] = [];
    public inheritedSource: InheritedApproverSource | null = null;
    public addingApprover = false;
    public confirmingRemoveID: string | null = null;
    public availablePeople: PersonLookupRow[] = [];
    public newPersonID = '';
    public newEffectiveFrom = '';
    public newEffectiveTo = '';
    public newNotes = '';
    public errorMessage = '';

    private resolvedEntityID: string | null = null;
    private initialized = false;
    private cdr = inject(ChangeDetectorRef);

    public get canEdit(): boolean {
        return !this._readOnly && this.canManageTimesheets;
    }

    public ngOnInit(): void {
        this.initialized = true;
        void this.Refresh();
    }

    public async Refresh(): Promise<void> {
        this.errorMessage = '';
        this.confirmingRemoveID = null;
        if (!this._scopeRecordID) {
            this.directApprovers = [];
            this.inheritedSource = null;
            this.cdr.markForCheck();
            return;
        }

        this.loading = true;
        this.cdr.markForCheck();

        try {
            const provider = Metadata.Provider;
            try {
                await TasksSettings.Load(provider);
            } catch {
                // Fall back to cached / default settings
            }
            const timeEnabled = TasksSettings.TimeTrackingEnabled(provider);
            const approvalEnabled = TasksSettings.TimesheetApprovalEnabled(provider);
            const hasAuth = UserCanManageTimesheets(provider.CurrentUser, provider);

            this.enabled = timeEnabled && approvalEnabled;
            this.canManageTimesheets = hasAuth;
            if (!this.enabled) {
                this.loading = false;
                this.cdr.markForCheck();
                return;
            }

            const md = new Metadata();
            this.resolvedEntityID =
                this._scopeEntityID ?? md.EntityByName(this._scopeEntityName)?.ID ?? null;
            if (!this.resolvedEntityID && this._scopeEntityName !== 'MJ_BizApps_Tasks: Tasks') {
                this.loading = false;
                this.cdr.markForCheck();
                return;
            }

            const rv = new RunView();
            const todayIso = new Date().toISOString().slice(0, 10);
            const isTaskScope = this._scopeEntityName === 'MJ_BizApps_Tasks: Tasks';
            const extraFilter = isTaskScope
                ? `(ScopeTaskID = '${this._scopeRecordID}'${this.resolvedEntityID ? ` OR (ScopeEntityID = '${this.resolvedEntityID}' AND ScopeRecordID = '${this._scopeRecordID}')` : ''})`
                : `ScopeEntityID = '${this.resolvedEntityID}' AND ScopeRecordID = '${this._scopeRecordID}'`;

            const result = await rv.RunView<{
                ID: string;
                ApproverPersonID: string;
                ApproverPerson: string | null;
                EffectiveFrom: string | Date | null;
                EffectiveTo: string | Date | null;
                IsActive: boolean | null;
                Notes: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Time Approvers',
                ExtraFilter: extraFilter,
                OrderBy: 'ApproverPerson ASC',
                ResultType: 'simple',
            });

            this.directApprovers = (result.Results ?? []).map((row) => {
                const effectiveFrom = this.normalizeIsoDate(row.EffectiveFrom);
                const effectiveTo = this.normalizeIsoDate(row.EffectiveTo);
                return {
                    ID: row.ID,
                    ApproverPersonID: row.ApproverPersonID,
                    ApproverPerson: row.ApproverPerson || row.ApproverPersonID,
                    EffectiveFrom: effectiveFrom,
                    EffectiveTo: effectiveTo,
                    Notes: row.Notes,
                    IsActiveToday: isApproverActiveOn(
                        { IsActive: row.IsActive, EffectiveFrom: effectiveFrom, EffectiveTo: effectiveTo },
                        todayIso,
                    ),
                };
            });

            if (this.directApprovers.length === 0 && isTaskScope) {
                this.inheritedSource = await this.resolveInheritedTaskApprovers(this._scopeRecordID, todayIso, rv);
            } else {
                this.inheritedSource = null;
            }
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Failed to load time approvers.';
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    public async openAddApprover(): Promise<void> {
        this.addingApprover = true;
        this.newPersonID = '';
        this.newEffectiveFrom = '';
        this.newEffectiveTo = '';
        this.newNotes = '';
        if (this.availablePeople.length === 0) {
            const rv = new RunView();
            const res = await rv.RunView<PersonLookupRow>({
                EntityName: 'MJ_BizApps_Common: People',
                ExtraFilter: `Status = 'Active'`,
                OrderBy: 'LastName ASC, FirstName ASC',
                ResultType: 'simple',
            });
            const existingIDs = new Set(this.directApprovers.map((d) => d.ApproverPersonID.toLowerCase()));
            this.availablePeople = (res.Results ?? []).filter(
                (p) => !existingIDs.has(p.ID.toLowerCase()),
            );
        }
        this.cdr.markForCheck();
    }

    public cancelAddApprover(): void {
        this.addingApprover = false;
        this.errorMessage = '';
        this.cdr.markForCheck();
    }

    public async saveNewApprover(): Promise<void> {
        if (!this.newPersonID || !this._scopeRecordID || this.saving) {
            return;
        }
        this.saving = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTimeApproverEntity>('MJ_BizApps_Tasks: Time Approvers');
            entity.NewRecord();
            if (this._scopeEntityName === 'MJ_BizApps_Tasks: Tasks') {
                entity.ScopeTaskID = this._scopeRecordID;
                entity.IncludeDescendants = true;
            } else {
                entity.ScopeEntityID = this.resolvedEntityID;
                entity.ScopeRecordID = this._scopeRecordID;
            }
            entity.ApproverPersonID = this.newPersonID;
            entity.EffectiveFrom = this.newEffectiveFrom ? new Date(`${this.newEffectiveFrom}T00:00:00.000Z`) : null;
            entity.EffectiveTo = this.newEffectiveTo ? new Date(`${this.newEffectiveTo}T00:00:00.000Z`) : null;
            entity.IsActive = true;
            entity.Notes = this.newNotes.trim() || null;

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not add time approver.');
            }
            this.addingApprover = false;
            this.availablePeople = [];
            this.ApproversChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not add time approver.';
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }

    public async confirmRemove(approverRowID: string): Promise<void> {
        if (this.saving) {
            return;
        }
        this.saving = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTimeApproverEntity>('MJ_BizApps_Tasks: Time Approvers');
            const loaded = await entity.InnerLoad(CompositeKey.FromID(approverRowID));
            if (loaded) {
                const deleted = await entity.Delete();
                if (!deleted) {
                    throw new Error(entity.LatestResult?.CompleteMessage || 'Could not remove time approver.');
                }
            }
            this.confirmingRemoveID = null;
            this.availablePeople = [];
            this.ApproversChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not remove time approver.';
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }

    private async resolveInheritedTaskApprovers(
        taskID: string,
        todayIso: string,
        rv: RunView,
    ): Promise<InheritedApproverSource | null> {
        // Walk up ParentID chain (up to 10 hops)
        let currentTaskID: string | null = taskID;
        let rootTaskID: string = taskID;
        const ancestorChain: Array<{ ID: string; Name: string }> = [];

        for (let depth = 0; depth < 10 && currentTaskID; depth++) {
            const taskFilter: string = `ID = '${currentTaskID}'`;
            const taskRes = await rv.RunView<{ ID: string; Name: string; ParentID: string | null }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: taskFilter,
                Fields: ['ID', 'Name', 'ParentID'],
                ResultType: 'simple',
                MaxRows: 1,
            });
            const row: { ID: string; Name: string; ParentID: string | null } | undefined = taskRes.Results?.[0];
            if (!row) {
                break;
            }
            rootTaskID = row.ID;
            if (!UUIDsEqual(row.ID, taskID)) {
                ancestorChain.push({ ID: row.ID, Name: row.Name });
            }
            currentTaskID = row.ParentID;
        }

        for (const ancestor of ancestorChain) {
            const approversRes = await rv.RunView<{
                ApproverPerson: string | null;
                ApproverPersonID: string;
                EffectiveFrom: string | Date | null;
                EffectiveTo: string | Date | null;
                IsActive: boolean | null;
                IncludeDescendants: boolean | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Time Approvers',
                ExtraFilter: `ScopeTaskID = '${ancestor.ID}'`,
                ResultType: 'simple',
            });
            const activeNames = (approversRes.Results ?? [])
                .filter(
                    (r) =>
                        r.IncludeDescendants !== false &&
                        isApproverActiveOn(
                            {
                                IsActive: r.IsActive,
                                EffectiveFrom: this.normalizeIsoDate(r.EffectiveFrom),
                                EffectiveTo: this.normalizeIsoDate(r.EffectiveTo),
                            },
                            todayIso,
                        ),
                )
                .map((r) => r.ApproverPerson || r.ApproverPersonID);
            if (activeNames.length > 0) {
                return { SourceLabel: ancestor.Name, ApproverNames: activeNames };
            }
        }

        // Check TaskLinks on the root task
        const linksRes = await rv.RunView<{
            LinkedEntityID: string;
            LinkedEntity: string | null;
            LinkedRecordID: string;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Task Links',
            ExtraFilter: `TaskID = '${rootTaskID}'`,
            ResultType: 'simple',
        });
        for (const link of linksRes.Results ?? []) {
            const approversRes = await rv.RunView<{
                ApproverPerson: string | null;
                ApproverPersonID: string;
                EffectiveFrom: string | Date | null;
                EffectiveTo: string | Date | null;
                IsActive: boolean | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Time Approvers',
                ExtraFilter: `ScopeEntityID = '${link.LinkedEntityID}' AND ScopeRecordID = '${link.LinkedRecordID}'`,
                ResultType: 'simple',
            });
            const activeNames = (approversRes.Results ?? [])
                .filter((r) =>
                    isApproverActiveOn(
                        {
                            IsActive: r.IsActive,
                            EffectiveFrom: this.normalizeIsoDate(r.EffectiveFrom),
                            EffectiveTo: this.normalizeIsoDate(r.EffectiveTo),
                        },
                        todayIso,
                    ),
                )
                .map((r) => r.ApproverPerson || r.ApproverPersonID);
            if (activeNames.length > 0) {
                return {
                    SourceLabel: `${link.LinkedEntity || 'Linked Record'} (${link.LinkedRecordID})`,
                    ApproverNames: activeNames,
                };
            }
        }

        // Check fallback settings
        const provider = Metadata.Provider;
        const relType = TasksSettings.TimesheetApproverRelationshipType(provider);
        const roleName = TasksSettings.TimesheetApproverRole(provider);
        if (relType) {
            return {
                SourceLabel: `Relationship fallback (${relType})`,
                ApproverNames: [`Submitter's ${relType}`],
            };
        }
        if (roleName) {
            return {
                SourceLabel: `Role fallback (${roleName})`,
                ApproverNames: [`Holders of ${roleName}`],
            };
        }

        return null;
    }

    private normalizeIsoDate(val: string | Date | null | undefined): string | null {
        if (!val) {
            return null;
        }
        if (val instanceof Date) {
            return val.toISOString().slice(0, 10);
        }
        const trimmed = String(val).trim();
        return trimmed.length >= 10 ? trimmed.slice(0, 10) : null;
    }
}
