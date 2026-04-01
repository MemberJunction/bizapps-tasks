import { Component, EventEmitter, Input, Output, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BaseEntity, Metadata, RunView } from '@memberjunction/core';
import { TaskTemplateService } from '@mj-biz-apps/tasks-core';
import { TaskPriorityBadgeComponent } from '../task-priority-badge/task-priority-badge.component';

interface TemplateOption {
    ID: string;
    Name: string;
    Description: string | null;
}

interface PreviewItem {
    Name: string;
    Priority: string;
    DueAt: Date | null;
    DaysFromStart: number | null;
    ParentItemID: string | null;
    Depth: number;
}

interface RolePlaceholder {
    RoleID: string;
    RoleName: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
}

/**
 * Multi-step wizard for creating tasks from a template:
 *   Step 1: Pick template
 *   Step 2: Set start date + category
 *   Step 3: Preview generated timeline
 *   Step 4: Assign people to role placeholders
 *   Step 5: Create
 */
@Component({
    selector: 'bizapps-task-template-wizard',
    standalone: true,
    imports: [CommonModule, FormsModule, TaskPriorityBadgeComponent],
    template: `
        <div class="wizard">
            <!-- Step indicator -->
            <div class="steps-bar">
                @for (s of steps; track s; let i = $index) {
                    <div class="step-dot" [class.active]="step === i" [class.done]="step > i">
                        {{ i + 1 }}
                    </div>
                }
            </div>

            <!-- Step 1: Pick template -->
            @if (step === 0) {
                <div class="step-content">
                    <h3>Select a Template</h3>
                    @if (templates.length === 0) {
                        <p class="empty">No templates available.</p>
                    }
                    @for (t of templates; track t.ID) {
                        <div class="template-card" [class.selected]="selectedTemplateID === t.ID"
                             (click)="selectedTemplateID = t.ID">
                            <div class="template-name">{{ t.Name }}</div>
                            @if (t.Description) {
                                <div class="template-desc">{{ t.Description }}</div>
                            }
                        </div>
                    }
                </div>
            }

            <!-- Step 2: Start date + category -->
            @if (step === 1) {
                <div class="step-content">
                    <h3>Configure</h3>
                    <div class="form-group">
                        <label>Start Date</label>
                        <input type="date" [(ngModel)]="startDateStr" class="form-input" />
                    </div>
                    <div class="form-group">
                        <label>Category (optional)</label>
                        <select [(ngModel)]="categoryID" class="form-input">
                            <option [ngValue]="null">None</option>
                            @for (cat of categories; track cat.ID) {
                                <option [value]="cat.ID">{{ cat.Name }}</option>
                            }
                        </select>
                    </div>
                </div>
            }

            <!-- Step 3: Preview -->
            @if (step === 2) {
                <div class="step-content">
                    <h3>Preview Timeline</h3>
                    @for (item of previewItems; track item.Name) {
                        <div class="preview-item" [style.padding-left.px]="12 + item.Depth * 20">
                            <span class="preview-name">{{ item.Name }}</span>
                            <bizapps-task-priority-badge [Priority]="item.Priority"></bizapps-task-priority-badge>
                            @if (item.DueAt) {
                                <span class="preview-due">{{ item.DueAt | date:'MMM d, y' }}</span>
                            }
                        </div>
                    }
                    @if (previewItems.length === 0) {
                        <p class="empty">No items in this template.</p>
                    }
                </div>
            }

            <!-- Step 4: Assign roles -->
            @if (step === 3) {
                <div class="step-content">
                    <h3>Assign Roles</h3>
                    @if (rolePlaceholders.length === 0) {
                        <p class="empty">No role placeholders in this template. You can assign people after creation.</p>
                    }
                    @for (rp of rolePlaceholders; track rp.RoleID) {
                        <div class="role-row">
                            <label>{{ rp.RoleName }}</label>
                            <input type="text" [(ngModel)]="rp.AssigneeRecordID"
                                   placeholder="Person ID" class="form-input" />
                        </div>
                    }
                </div>
            }

            <!-- Navigation -->
            <div class="wizard-nav">
                <button class="btn-secondary" (click)="onBack()" [disabled]="step === 0">Back</button>
                @if (step < steps.length - 1) {
                    <button class="btn-primary" (click)="onNext()" [disabled]="!canAdvance">Next</button>
                } @else {
                    <button class="btn-primary" (click)="onCreate()" [disabled]="creating">
                        {{ creating ? 'Creating...' : 'Create Tasks' }}
                    </button>
                }
                <button class="btn-cancel" (click)="Cancelled.emit()">Cancel</button>
            </div>
        </div>
    `,
    styles: [`
        .wizard { max-width: 560px; }
        .steps-bar { display: flex; gap: 8px; margin-bottom: 20px; justify-content: center; }
        .step-dot {
            width: 28px; height: 28px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; font-weight: 600;
            background: #e5e7eb; color: #6b7280;
        }
        .step-dot.active { background: #4f46e5; color: #fff; }
        .step-dot.done { background: #22c55e; color: #fff; }
        .step-content { margin-bottom: 20px; }
        .step-content h3 { margin: 0 0 12px; font-size: 1rem; }
        .template-card {
            padding: 10px 12px; border: 1px solid #e5e7eb; border-radius: 6px;
            margin-bottom: 6px; cursor: pointer; transition: border-color 0.15s;
        }
        .template-card:hover { border-color: #a5b4fc; }
        .template-card.selected { border-color: #4f46e5; background: #eef2ff; }
        .template-name { font-weight: 500; font-size: 0.9rem; }
        .template-desc { font-size: 0.8rem; color: #6b7280; margin-top: 2px; }
        .form-group { margin-bottom: 12px; }
        .form-group label { display: block; font-size: 0.8rem; color: #374151; margin-bottom: 3px; font-weight: 500; }
        .form-input {
            width: 100%; padding: 6px 10px; border: 1px solid #d1d5db; border-radius: 6px;
            font-size: 0.875rem; box-sizing: border-box;
        }
        .preview-item {
            display: flex; align-items: center; gap: 8px; padding: 6px 0;
            border-bottom: 1px solid #f3f4f6; font-size: 0.85rem;
        }
        .preview-name { flex: 1; }
        .preview-due { color: #6b7280; font-size: 0.8rem; }
        .role-row { margin-bottom: 10px; }
        .role-row label { display: block; font-size: 0.8rem; font-weight: 500; margin-bottom: 3px; }
        .empty { color: #9ca3af; font-style: italic; }
        .wizard-nav { display: flex; gap: 8px; }
        .btn-primary {
            padding: 8px 20px; border: none; border-radius: 6px;
            background: #4f46e5; color: #fff; font-size: 0.875rem; cursor: pointer; font-weight: 500;
        }
        .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-secondary {
            padding: 8px 20px; border: 1px solid #d1d5db; border-radius: 6px;
            background: #fff; font-size: 0.875rem; cursor: pointer;
        }
        .btn-secondary:disabled { opacity: 0.4; }
        .btn-cancel { padding: 8px 20px; border: none; background: none; color: #6b7280; cursor: pointer; font-size: 0.875rem; margin-left: auto; }
    `]
})
export class TaskTemplateWizardComponent implements OnInit {
    @Input() DefaultCategoryID: string | null = null;
    @Input() PersonEntityID: string | null = null;

    @Output() Created = new EventEmitter<BaseEntity[]>();
    @Output() Cancelled = new EventEmitter<void>();

    steps = ['Template', 'Configure', 'Preview', 'Assign'];
    step = 0;
    templates: TemplateOption[] = [];
    categories: any[] = [];
    selectedTemplateID: string | null = null;
    startDateStr = new Date().toISOString().split('T')[0];
    categoryID: string | null = null;
    previewItems: PreviewItem[] = [];
    rolePlaceholders: RolePlaceholder[] = [];
    creating = false;

    private templateService = new TaskTemplateService();

    get canAdvance(): boolean {
        if (this.step === 0) return !!this.selectedTemplateID;
        if (this.step === 1) return !!this.startDateStr;
        return true;
    }

    ngOnInit(): void {
        this.categoryID = this.DefaultCategoryID;
        this.loadTemplates();
        this.loadCategories();
    }

    private async loadTemplates(): Promise<void> {
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Templates',
            ExtraFilter: 'IsActive = 1',
            ResultType: 'simple',
        });
        this.templates = (result?.Results ?? []).map((t: any) => ({
            ID: t.ID, Name: t.Name, Description: t.Description,
        }));
    }

    private async loadCategories(): Promise<void> {
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Categories',
            ExtraFilter: 'IsActive = 1',
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        });
        this.categories = result?.Results ?? [];
    }

    async onNext(): Promise<void> {
        if (!this.canAdvance) return;

        if (this.step === 1) {
            await this.buildPreview();
        }
        if (this.step === 2) {
            await this.loadRolePlaceholders();
        }
        this.step++;
    }

    onBack(): void {
        if (this.step > 0) this.step--;
    }

    private async buildPreview(): Promise<void> {
        if (!this.selectedTemplateID) return;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${this.selectedTemplateID}'`,
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        });
        const items = result?.Results ?? [];
        const startDate = new Date(this.startDateStr);

        // Calculate depth for indentation
        const depthMap = new Map<string, number>();
        for (const item of items) {
            const parentDepth = item.ParentItemID ? (depthMap.get(item.ParentItemID) ?? 0) : -1;
            depthMap.set(item.ID, parentDepth + 1);
        }

        this.previewItems = items.map((item: any) => {
            let dueAt: Date | null = null;
            if (item.DaysFromStart != null) {
                dueAt = new Date(startDate);
                dueAt.setDate(dueAt.getDate() + item.DaysFromStart);
            }
            return {
                Name: item.Name,
                Priority: item.Priority ?? 'Medium',
                DueAt: dueAt,
                DaysFromStart: item.DaysFromStart,
                ParentItemID: item.ParentItemID,
                Depth: depthMap.get(item.ID) ?? 0,
            };
        });
    }

    private async loadRolePlaceholders(): Promise<void> {
        if (!this.selectedTemplateID) return;
        const rv = new RunView();

        // Get all template items
        const itemsResult = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${this.selectedTemplateID}'`,
            ResultType: 'simple',
        });
        const itemIDs = (itemsResult?.Results ?? []).map((i: any) => `'${i.ID}'`).join(',');
        if (!itemIDs) { this.rolePlaceholders = []; return; }

        // Get unique roles across all template items
        const rolesResult = await new RunView().RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Item Roles',
            ExtraFilter: `ItemID IN (${itemIDs})`,
            ResultType: 'simple',
        });

        // Load role names
        const roleIDs = new Set<string>();
        for (const r of rolesResult?.Results ?? []) roleIDs.add(r.RoleID);

        const roleNames = new Map<string, string>();
        if (roleIDs.size > 0) {
            const rolesLookup = await new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Roles',
                ExtraFilter: `ID IN (${[...roleIDs].map(id => `'${id}'`).join(',')})`,
                ResultType: 'simple',
            });
            for (const r of rolesLookup?.Results ?? []) roleNames.set(r.ID, r.Name);
        }

        this.rolePlaceholders = [...roleIDs].map(roleID => ({
            RoleID: roleID,
            RoleName: roleNames.get(roleID) ?? roleID,
            AssigneeEntityID: this.PersonEntityID ?? '',
            AssigneeRecordID: '',
        }));
    }

    async onCreate(): Promise<void> {
        if (!this.selectedTemplateID || this.creating) return;
        this.creating = true;

        const assigneeMap = new Map<string, { entityID: string; recordID: string }>();
        for (const rp of this.rolePlaceholders) {
            if (rp.AssigneeRecordID?.trim()) {
                assigneeMap.set(rp.RoleID, {
                    entityID: rp.AssigneeEntityID,
                    recordID: rp.AssigneeRecordID.trim(),
                });
            }
        }

        const tasks = await this.templateService.instantiateTemplate({
            templateID: this.selectedTemplateID,
            startDate: new Date(this.startDateStr),
            categoryID: this.categoryID ?? undefined,
            assigneeMap: assigneeMap.size > 0 ? assigneeMap : undefined,
        });

        this.creating = false;
        this.Created.emit(tasks);
    }
}
