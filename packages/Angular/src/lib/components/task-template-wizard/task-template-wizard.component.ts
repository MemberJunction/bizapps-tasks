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
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BaseEntity, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { MJButtonDirective, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import { TaskTemplateService } from '@mj-biz-apps/tasks-core';
import { TaskPriorityBadgeComponent } from '../task-priority-badge/task-priority-badge.component';
import { ROLES_ENTITY } from '../../role-assignees';

interface TemplateOption {
    ID: string;
    Name: string;
    Description: string | null;
    CategoryID: string | null;
}

interface PreviewItem {
    Name: string;
    Priority: string;
    DueAt: Date | null;
    DaysFromStart: number | null;
    HoursEstimated: number | null;
    Depth: number;
}

interface TaskTemplateItemRow {
    ID: string;
    Name: string;
    ParentItemID: string | null;
    DaysFromStart: number | null;
    HoursEstimated: number | null;
    Priority: string;
}

interface RolePlaceholder {
    RoleID: string;
    RoleName: string;
    AssigneeChoice: string; // "person:<id>" | "role:<id>" | ""
}

interface PersonOption {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
}

/**
 * 1-Screen Playbook & Template Launcher (L3 Explorer component).
 *
 * Replaces the old 4-step wizard (which asked business users to paste raw Person GUIDs)
 * with a single live screen: pick template, set Start Date & Category, map role
 * placeholders using real People & MJ Role dropdowns, see calculated relative-offset
 * schedule preview live, and launch with MJ-ordered actions (`[Launch Playbook]` LEFT · `[Cancel]` RIGHT).
 */
@Component({
    selector: 'bizapps-task-template-wizard',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [DatePipe, FormsModule, MJButtonDirective, MJEmptyStateComponent, TaskPriorityBadgeComponent],
    template: `
        <div class="mjt-tpl-launcher">
            <div class="mjt-tpl-scroll">
                <div class="mjt-tpl-field">
                    <label>Playbook Template *</label>
                    @if (templates.length === 0 && !loadingTemplates) {
                        <mj-empty-state
                            Icon="fa-solid fa-copy"
                            Title="No active templates"
                            Message="Create a Task Template first to launch reusable workflows."
                            Size="compact">
                        </mj-empty-state>
                    } @else {
                        <select class="mjt-tpl-input" [(ngModel)]="selectedTemplateID" (ngModelChange)="onTemplateChanged()">
                            <option [ngValue]="null">Choose a template...</option>
                            @for (t of templates; track t.ID) {
                                <option [value]="t.ID">{{ t.Name }}</option>
                            }
                        </select>
                        @if (activeTemplate?.Description) {
                            <p class="mjt-tpl-desc">{{ activeTemplate?.Description }}</p>
                        }
                    }
                </div>

                @if (selectedTemplateID) {
                    <div class="mjt-tpl-grid">
                        <div class="mjt-tpl-field">
                            <label>Kickoff Start Date</label>
                            <input
                                type="date"
                                class="mjt-tpl-input"
                                [(ngModel)]="startDateStr"
                                (ngModelChange)="recomputePreviewDates()" />
                        </div>
                        <div class="mjt-tpl-field">
                            <label>Category</label>
                            <select class="mjt-tpl-input" [(ngModel)]="categoryID">
                                <option [ngValue]="null">None</option>
                                @for (cat of categories; track cat.ID) {
                                    <option [value]="cat.ID">{{ cat.Name }}</option>
                                }
                            </select>
                        </div>
                    </div>

                    @if (rolePlaceholders.length > 0) {
                        <div class="mjt-tpl-section">
                            <span class="mjt-tpl-section-label">Role Assignments</span>
                            @for (rp of rolePlaceholders; track rp.RoleID) {
                                <div class="mjt-role-row">
                                    <span class="mjt-role-name">{{ rp.RoleName }}</span>
                                    <select class="mjt-tpl-input" [(ngModel)]="rp.AssigneeChoice">
                                        <option value="">Unassigned (assign later)</option>
                                        <optgroup label="People">
                                            @for (p of people; track p.ID) {
                                                <option [value]="'person:' + p.ID">{{ p.FirstName }} {{ p.LastName }}</option>
                                            }
                                        </optgroup>
                                        @if (mjRoles.length > 0) {
                                            <optgroup label="MJ Roles">
                                                @for (r of mjRoles; track r.ID) {
                                                    <option [value]="'role:' + r.ID">{{ r.Name }} (Role)</option>
                                                }
                                            </optgroup>
                                        }
                                    </select>
                                </div>
                            }
                        </div>
                    }

                    <div class="mjt-tpl-section">
                        <div class="mjt-tpl-section-head">
                            <span class="mjt-tpl-section-label">Live Schedule Preview ({{ previewItems.length }} tasks)</span>
                            @if (totalHours > 0) {
                                <span class="mjt-tpl-hours">{{ totalHours }}h total</span>
                            }
                        </div>

                        @if (loadingPreview) {
                            <div class="mjt-tpl-muted">Loading schedule...</div>
                        } @else if (previewItems.length === 0) {
                            <div class="mjt-tpl-muted">This template has no task items yet.</div>
                        } @else {
                            <div class="mjt-preview-list">
                                @for (item of previewItems; track item.Name + $index) {
                                    <div class="mjt-preview-row" [style.paddingLeft.px]="10 + item.Depth * 18">
                                        <span class="mjt-offset-badge">
                                            {{ item.DaysFromStart != null ? '+' + item.DaysFromStart + 'd' : 'Day 0' }}
                                        </span>
                                        <span class="mjt-preview-name">{{ item.Name }}</span>
                                        <bizapps-task-priority-badge [Priority]="item.Priority"></bizapps-task-priority-badge>
                                        @if (item.DueAt) {
                                            <span class="mjt-preview-due">{{ item.DueAt | date:'MMM d' }}</span>
                                        }
                                    </div>
                                }
                            </div>
                        }
                    </div>
                }

                @if (errorMessage) {
                    <div class="mjt-tpl-error" role="alert">{{ errorMessage }}</div>
                }
            </div>

            <!-- Sticky MJ-Ordered Footer (Confirm LEFT · Cancel RIGHT) -->
            <div class="mjt-tpl-footer">
                <button
                    type="button"
                    mjButton
                    variant="primary"
                    size="sm"
                    [disabled]="!selectedTemplateID || creating || previewItems.length === 0"
                    (click)="onCreate()">
                    @if (creating) {
                        <i class="fa-solid fa-spinner fa-spin" aria-hidden="true"></i>
                    } @else {
                        <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                    }
                    <span>{{ creating ? 'Launching...' : ('Create ' + previewItems.length + ' Tasks') }}</span>
                </button>
                <button type="button" mjButton variant="outline" size="sm" [disabled]="creating" (click)="Cancelled.emit()">
                    Cancel
                </button>
            </div>
        </div>
    `,
    styles: [`
        :host {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 0;
            font-family: var(--mj-font-family);
            color: var(--mj-text-primary);
        }
        .mjt-tpl-launcher {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 0;
        }
        .mjt-tpl-scroll {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            padding: 16px 20px 24px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .mjt-tpl-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }
        .mjt-tpl-field {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .mjt-tpl-field label,
        .mjt-tpl-section-label {
            font-size: 11.5px;
            font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--mj-text-secondary);
        }
        .mjt-tpl-input {
            width: 100%;
            padding: 7px 10px;
            min-height: 36px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            box-sizing: border-box;
        }
        .mjt-tpl-desc {
            margin: 2px 0 0;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
            line-height: 1.45;
        }
        .mjt-tpl-section {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding-top: 10px;
            border-top: 1px solid var(--mj-border-subtle);
        }
        .mjt-tpl-section-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .mjt-tpl-hours {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-brand-primary);
        }
        .mjt-role-row {
            display: grid;
            grid-template-columns: 130px minmax(0, 1fr);
            align-items: center;
            gap: 10px;
        }
        .mjt-role-name {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
        }
        .mjt-preview-list {
            display: flex;
            flex-direction: column;
            gap: 4px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 8px;
        }
        .mjt-preview-row {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 8px;
            border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-subtle);
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-offset-badge {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm, 4px);
            background: color-mix(in srgb, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            flex-shrink: 0;
        }
        .mjt-preview-name {
            flex: 1;
            min-width: 0;
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary);
        }
        .mjt-preview-due {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
            color: var(--mj-text-muted);
            flex-shrink: 0;
        }
        .mjt-tpl-muted {
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
            font-style: italic;
        }
        .mjt-tpl-error {
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-tpl-footer {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px max(12px, env(safe-area-inset-bottom, 0px));
            border-top: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            flex-shrink: 0;
        }
        @media (max-width: 540px) {
            .mjt-tpl-grid,
            .mjt-role-row {
                grid-template-columns: minmax(0, 1fr);
            }
        }
    `],
})
export class TaskTemplateWizardComponent implements OnInit, OnChanges {
    @Input() DefaultCategoryID: string | null = null;
    @Input() PersonEntityID: string | null = null;
    @Input() SelectedTemplateID: string | null = null;

    @Output() Created = new EventEmitter<BaseEntity[]>();
    @Output() Cancelled = new EventEmitter<void>();

    public templates: TemplateOption[] = [];
    public categories: { ID: string; Name: string }[] = [];
    public people: PersonOption[] = [];
    public mjRoles: { ID: string; Name: string }[] = [];
    public selectedTemplateID: string | null = null;
    public startDateStr = new Date().toISOString().split('T')[0];
    public categoryID: string | null = null;
    public previewItems: PreviewItem[] = [];
    public rolePlaceholders: RolePlaceholder[] = [];
    public loadingTemplates = false;
    public loadingPreview = false;
    public creating = false;
    public errorMessage = '';

    private rawItems: TaskTemplateItemRow[] = [];
    private templateService = new TaskTemplateService();
    private cdr = inject(ChangeDetectorRef);

    public get activeTemplate(): TemplateOption | undefined {
        return this.templates.find((t) => t.ID === this.selectedTemplateID);
    }

    public get totalHours(): number {
        return this.previewItems.reduce((sum, item) => sum + (item.HoursEstimated ?? 0), 0);
    }

    public ngOnInit(): void {
        this.categoryID = this.DefaultCategoryID;
        this.selectedTemplateID = this.SelectedTemplateID;
        void this.loadInitialData();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['SelectedTemplateID'] && this.SelectedTemplateID && this.SelectedTemplateID !== this.selectedTemplateID) {
            this.selectedTemplateID = this.SelectedTemplateID;
            void this.onTemplateChanged();
        }
    }

    private async loadInitialData(): Promise<void> {
        this.loadingTemplates = true;
        this.cdr.markForCheck();
        try {
            const [tpls, cats, ppl] = await Promise.all([
                new RunView().RunView<TemplateOption>({
                    EntityName: 'MJ_BizApps_Tasks: Task Templates',
                    ExtraFilter: 'IsActive = 1',
                    OrderBy: 'Name ASC',
                    ResultType: 'simple',
                }),
                new RunView().RunView<{ ID: string; Name: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Categories',
                    ExtraFilter: 'IsActive = 1',
                    OrderBy: 'Sequence ASC',
                    ResultType: 'simple',
                }),
                new RunView().RunView<PersonOption>({
                    EntityName: 'MJ_BizApps_Common: People',
                    OrderBy: 'FirstName ASC, LastName ASC',
                    ResultType: 'simple',
                }),
            ]);
            this.templates = tpls?.Results ?? [];
            this.categories = cats?.Results ?? [];
            this.people = ppl?.Results ?? [];
            this.mjRoles = (Metadata.Provider.Roles ?? []).map((r) => ({ ID: r.ID, Name: r.Name }));

            if (!this.selectedTemplateID && this.templates.length > 0) {
                this.selectedTemplateID = this.templates[0].ID;
            }
            if (this.selectedTemplateID) {
                await this.onTemplateChanged();
            }
        } finally {
            this.loadingTemplates = false;
            this.cdr.markForCheck();
        }
    }

    public async onTemplateChanged(): Promise<void> {
        if (!this.selectedTemplateID) {
            this.previewItems = [];
            this.rolePlaceholders = [];
            this.cdr.markForCheck();
            return;
        }
        const tpl = this.activeTemplate;
        if (tpl?.CategoryID && !this.DefaultCategoryID) {
            this.categoryID = tpl.CategoryID;
        }

        this.loadingPreview = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const itemsRes = await new RunView().RunView<TaskTemplateItemRow>({
                EntityName: 'MJ_BizApps_Tasks: Task Template Items',
                ExtraFilter: `TemplateID = '${EscapeSQLString(this.selectedTemplateID)}'`,
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            });
            this.rawItems = itemsRes?.Results ?? [];
            this.recomputePreviewDates();

            const itemIDs = this.rawItems.map((i) => `'${EscapeSQLString(i.ID)}'`).join(',');
            if (!itemIDs) {
                this.rolePlaceholders = [];
                return;
            }
            const itemRolesRes = await new RunView().RunView<{ RoleID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Template Item Roles',
                ExtraFilter: `ItemID IN (${itemIDs})`,
                ResultType: 'simple',
            });
            const uniqueRoleIDs = [...new Set((itemRolesRes?.Results ?? []).map((r) => r.RoleID))];
            if (uniqueRoleIDs.length === 0) {
                this.rolePlaceholders = [];
                return;
            }
            const rolesRes = await new RunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Roles',
                ExtraFilter: `ID IN (${uniqueRoleIDs.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`,
                ResultType: 'simple',
            });
            const nameMap = new Map<string, string>();
            for (const r of rolesRes?.Results ?? []) {
                nameMap.set(r.ID.toLowerCase(), r.Name);
            }
            this.rolePlaceholders = uniqueRoleIDs.map((roleID) => ({
                RoleID: roleID,
                RoleName: nameMap.get(roleID.toLowerCase()) ?? roleID,
                AssigneeChoice: '',
            }));
        } finally {
            this.loadingPreview = false;
            this.cdr.markForCheck();
        }
    }

    public recomputePreviewDates(): void {
        const base = new Date(`${this.startDateStr}T17:00:00`);
        const depthMap = new Map<string, number>();
        for (const item of this.rawItems) {
            const parentDepth = item.ParentItemID ? (depthMap.get(item.ParentItemID) ?? 0) : -1;
            depthMap.set(item.ID, parentDepth + 1);
        }
        this.previewItems = this.rawItems.map((item) => {
            let dueAt: Date | null = null;
            if (!Number.isNaN(base.getTime()) && item.DaysFromStart != null) {
                dueAt = new Date(base.getTime());
                dueAt.setDate(dueAt.getDate() + item.DaysFromStart);
            }
            return {
                Name: item.Name,
                Priority: item.Priority ?? 'Medium',
                DueAt: dueAt,
                DaysFromStart: item.DaysFromStart,
                HoursEstimated: item.HoursEstimated,
                Depth: depthMap.get(item.ID) ?? 0,
            };
        });
        this.cdr.markForCheck();
    }

    public async onCreate(): Promise<void> {
        if (!this.selectedTemplateID || this.creating) return;
        this.creating = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const personEntityID = this.PersonEntityID || Metadata.Provider.EntityByName('MJ_BizApps_Common: People')?.ID || '';
            const roleEntityID = Metadata.Provider.EntityByName(ROLES_ENTITY)?.ID || '';
            const assigneeMap = new Map<string, { entityID: string; recordID: string }>();

            for (const rp of this.rolePlaceholders) {
                if (!rp.AssigneeChoice) continue;
                if (rp.AssigneeChoice.startsWith('person:') && personEntityID) {
                    assigneeMap.set(rp.RoleID, { entityID: personEntityID, recordID: rp.AssigneeChoice.slice(7) });
                } else if (rp.AssigneeChoice.startsWith('role:') && roleEntityID) {
                    assigneeMap.set(rp.RoleID, { entityID: roleEntityID, recordID: rp.AssigneeChoice.slice(5) });
                }
            }

            const tasks = await this.templateService.instantiateTemplate({
                templateID: this.selectedTemplateID,
                startDate: new Date(`${this.startDateStr}T09:00:00`),
                categoryID: this.categoryID ?? undefined,
                assigneeMap: assigneeMap.size > 0 ? assigneeMap : undefined,
            });
            this.Created.emit(tasks);
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Failed to instantiate template.';
        } finally {
            this.creating = false;
            this.cdr.markForCheck();
        }
    }
}
