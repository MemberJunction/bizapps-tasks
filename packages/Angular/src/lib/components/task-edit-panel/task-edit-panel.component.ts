import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';

interface AssigneeRow {
    PersonID: string;
    PersonName: string;
    RoleID: string;
    IsNew: boolean;
    ExistingID?: string;
}

@Component({
    selector: 'bizapps-task-edit-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, FormsModule],
    template: `
        <div class="edit-panel">
            <div class="panel-header">
                <h2>{{ isNew ? 'New Task' : 'Edit Task' }}</h2>
                <button class="btn-close" (click)="Cancel.emit()"><i class="fa-solid fa-xmark"></i></button>
            </div>

            @if (loading) {
                <div class="panel-loading">Loading...</div>
            } @else {
                <form (ngSubmit)="save()">
                    <div class="form-group">
                        <label>Name *</label>
                        <input type="text" [(ngModel)]="form.Name" name="name" required class="form-input" />
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea [(ngModel)]="form.Description" name="desc" rows="3" class="form-input"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label>Status</label>
                            <select [(ngModel)]="form.Status" name="status" class="form-input">
                                <option value="Open">Open</option>
                                <option value="InProgress">In Progress</option>
                                <option value="Blocked">Blocked</option>
                                <option value="Completed">Completed</option>
                                <option value="Cancelled">Cancelled</option>
                            </select>
                        </div>
                        <div class="form-group half">
                            <label>Priority</label>
                            <select [(ngModel)]="form.Priority" name="priority" class="form-input">
                                <option value="Low">Low</option>
                                <option value="Medium">Medium</option>
                                <option value="High">High</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label>Due Date</label>
                            <input type="date" [(ngModel)]="form.DueAt" name="dueAt" class="form-input" />
                        </div>
                        <div class="form-group half">
                            <label>% Complete</label>
                            <input type="number" [(ngModel)]="form.PercentComplete" name="pct"
                                   min="0" max="100" class="form-input" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label>Hours Estimated</label>
                            <input type="number" [(ngModel)]="form.HoursEstimated" name="hoursEst"
                                   step="0.25" min="0" class="form-input" />
                        </div>
                        <div class="form-group half">
                            <label>Hours Actual</label>
                            <input type="number" [(ngModel)]="form.HoursActual" name="hoursAct"
                                   step="0.25" min="0" class="form-input" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label>Task Type</label>
                            <select [(ngModel)]="form.TypeID" name="taskType" class="form-input">
                                @for (tt of taskTypes; track tt.ID) {
                                    <option [value]="tt.ID">{{ tt.Name }}</option>
                                }
                            </select>
                        </div>
                        <div class="form-group half">
                            <label>Category</label>
                            <select [(ngModel)]="form.CategoryID" name="category" class="form-input">
                                <option [ngValue]="null">None</option>
                                @for (cat of categories; track cat.ID) {
                                    <option [value]="cat.ID">{{ cat.Name }}</option>
                                }
                            </select>
                        </div>
                    </div>

                    <!-- Parent Task -->
                    <div class="form-group">
                        <label>Parent Task</label>
                        <select [(ngModel)]="form.ParentID" name="parentTask" class="form-input">
                            <option [ngValue]="null">None (top-level)</option>
                            @for (t of availableTasks; track t.ID) {
                                <option [value]="t.ID">{{ t.Name }}</option>
                            }
                        </select>
                    </div>

                    @if (form.Status === 'Blocked') {
                        <div class="form-group">
                            <label>Blocked Reason</label>
                            <textarea [(ngModel)]="form.BlockedReason" name="blocked" rows="2" class="form-input"></textarea>
                        </div>
                    }

                    @if (form.Status === 'Completed') {
                        <div class="form-group">
                            <label>Completion Notes</label>
                            <textarea [(ngModel)]="form.CompletionNotes" name="completionNotes"
                                      rows="2" class="form-input"></textarea>
                        </div>
                    }

                    <!-- Assignees -->
                    <div class="form-group">
                        <label>Assignees</label>
                        @for (a of assignees; track a; let i = $index) {
                            <div class="assignee-edit-row">
                                <select [(ngModel)]="a.PersonID" [name]="'person' + i" class="form-input assignee-select"
                                        (ngModelChange)="onAssigneePersonChanged(a)">
                                    <option value="">Select person...</option>
                                    @for (p of people; track p.ID) {
                                        <option [value]="p.ID">{{ p.FirstName }} {{ p.LastName }}</option>
                                    }
                                </select>
                                <select [(ngModel)]="a.RoleID" [name]="'role' + i" class="form-input role-select">
                                    @for (r of roles; track r.ID) {
                                        <option [value]="r.ID">{{ r.Name }}</option>
                                    }
                                </select>
                                <button type="button" class="btn-remove" (click)="removeAssignee(i)">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                            </div>
                        }
                        <button type="button" class="btn-add-assignee" (click)="addAssignee()">
                            <i class="fa-solid fa-plus"></i> Add Assignee
                        </button>
                    </div>

                    <!-- Tags -->
                    <div class="form-group">
                        <label>Tags</label>
                        <div class="tags-row">
                            @for (t of selectedTags; track t.ID) {
                                <span class="tag-chip" [style.background]="(t.ColorCode ?? '#6366f1') + '18'"
                                      [style.color]="t.ColorCode ?? '#6366f1'">
                                    {{ t.Name }}
                                    <button type="button" class="tag-remove" (click)="removeTag(t.ID)">&times;</button>
                                </span>
                            }
                        </div>
                        <div class="tag-input-row">
                            <select class="form-input tag-select" (change)="onTagSelected($event)">
                                <option value="">Add existing tag...</option>
                                @for (t of availableTagsFiltered; track t.ID) {
                                    <option [value]="t.ID">{{ t.Name }}</option>
                                }
                            </select>
                            <span class="tag-or">or</span>
                            <input type="text" [(ngModel)]="newTagName" name="newTag"
                                   placeholder="New tag name" class="form-input tag-new-input"
                                   (keydown.enter)="createAndAddTag(); $event.preventDefault()" />
                            <button type="button" class="btn-create-tag" (click)="createAndAddTag()"
                                    [disabled]="!newTagName.trim() || creatingTag">
                                <i class="fa-solid fa-plus"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn-secondary" (click)="Cancel.emit()">Cancel</button>
                        <button type="submit" class="btn-primary" [disabled]="saving || !form.Name?.trim()">
                            {{ saving ? 'Saving...' : (isNew ? 'Create' : 'Save') }}
                        </button>
                    </div>
                </form>
            }
        </div>
    `,
    styles: [`
        :host {
            display: block;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            -webkit-font-smoothing: antialiased;
        }
        .edit-panel { padding: 28px 24px; }
        .panel-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;
        }
        .panel-header h2 { margin: 0; font-size: 20px; font-weight: 700; color: #0f172a; letter-spacing: -0.3px; }
        .btn-close {
            padding: 7px 10px; border: 1px solid #e2e8f0; border-radius: 8px;
            background: #fff; color: #94a3b8; font-size: 14px; cursor: pointer;
        }
        .btn-close:hover { background: #f8fafc; color: #64748b; }
        .panel-loading { padding: 64px; text-align: center; color: #94a3b8; }

        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block; font-size: 11px; font-weight: 700; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .form-input {
            width: 100%; padding: 8px 12px; border: 1px solid #e2e8f0; border-radius: 10px;
            font-size: 14px; box-sizing: border-box; font-family: inherit;
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .form-input:focus {
            outline: none; border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }
        textarea.form-input { resize: vertical; }
        .form-row { display: flex; gap: 12px; }
        .half { flex: 1; }

        /* Assignees */
        .assignee-edit-row {
            display: flex; gap: 6px; margin-bottom: 6px; align-items: center;
        }
        .assignee-select { flex: 2; }
        .role-select { flex: 1; }
        .btn-remove {
            padding: 6px 8px; border: 1px solid #e2e8f0; border-radius: 8px;
            background: #fff; color: #94a3b8; cursor: pointer; font-size: 12px;
            flex-shrink: 0;
        }
        .btn-remove:hover { background: #fef2f2; color: #ef4444; border-color: #fecaca; }
        .btn-add-assignee {
            padding: 6px 12px; border: 1px dashed #cbd5e1; border-radius: 8px;
            background: transparent; color: #64748b; font-size: 13px; cursor: pointer;
            font-family: inherit; display: flex; align-items: center; gap: 5px;
            width: 100%; justify-content: center; margin-top: 4px;
        }
        .btn-add-assignee:hover { background: #f8fafc; border-color: #6366f1; color: #6366f1; }

        /* Tags */
        .tags-row {
            display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 6px;
        }
        .tag-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 10px; border-radius: 6px; font-size: 12px; font-weight: 600;
        }
        .tag-remove {
            background: none; border: none; cursor: pointer; font-size: 14px;
            color: inherit; opacity: 0.6; padding: 0 2px;
        }
        .tag-remove:hover { opacity: 1; }
        .tag-input-row { display: flex; gap: 6px; align-items: center; }
        .tag-select { flex: 1; }
        .tag-or { font-size: 12px; color: #94a3b8; flex-shrink: 0; }
        .tag-new-input { flex: 1; }
        .btn-create-tag {
            padding: 8px 10px; border: 1px solid #e2e8f0; border-radius: 10px;
            background: #fff; color: #6366f1; cursor: pointer; font-size: 13px;
            flex-shrink: 0;
        }
        .btn-create-tag:hover { background: #eef2ff; border-color: #6366f1; }
        .btn-create-tag:disabled { opacity: 0.4; cursor: not-allowed; }

        /* Actions */
        .form-actions {
            display: flex; gap: 8px; justify-content: flex-end;
            margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9;
        }
        .btn-primary {
            padding: 9px 22px; border: none; border-radius: 10px;
            background: #6366f1; color: #fff; font-size: 14px; font-weight: 600;
            cursor: pointer; font-family: inherit;
            box-shadow: 0 1px 3px rgba(99, 102, 241, 0.3);
        }
        .btn-primary:hover { background: #4f46e5; }
        .btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }
        .btn-secondary {
            padding: 9px 22px; border: 1px solid #e2e8f0; border-radius: 10px;
            background: #fff; font-size: 14px; cursor: pointer; font-family: inherit;
        }
    `]
})
export class TaskEditPanelComponent implements OnChanges {
    @Input() TaskID: string | null = null;
    @Input() DefaultCategoryID: string | null = null;
    @Input() DefaultTypeID: string | null = null;
    /** Narrow the assignee picker. Pass an ExtraFilter string or an array of Person IDs. */
    @Input() AssigneeScope: string | string[] | null = null;

    @Output() Saved = new EventEmitter<string>();
    @Output() Cancel = new EventEmitter<void>();

    form: any = {};
    isNew = true;
    loading = false;
    saving = false;
    taskTypes: any[] = [];
    categories: any[] = [];
    people: any[] = [];
    roles: any[] = [];
    availableTasks: any[] = [];
    allTags: any[] = [];
    selectedTags: any[] = [];
    assignees: AssigneeRow[] = [];
    newTagName = '';
    creatingTag = false;
    private peopleEntityID: string | null = null;
    private cdr = inject(ChangeDetectorRef);

    get availableTagsFiltered(): any[] {
        const selectedIDs = new Set(this.selectedTags.map((t: any) => t.ID));
        return this.allTags.filter(t => !selectedIDs.has(t.ID));
    }

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['TaskID']) {
            this.isNew = !this.TaskID;
            if (this.TaskID) {
                this.loadTask();
            } else {
                this.resetForm();
            }
        }
        this.loadLookups();
    }

    private resetForm(): void {
        this.form = {
            Name: '', Description: '', Status: 'Open', Priority: 'Medium',
            DueAt: null, PercentComplete: 0, HoursEstimated: null, HoursActual: null,
            BlockedReason: '', CompletionNotes: '',
            TypeID: this.DefaultTypeID, CategoryID: this.DefaultCategoryID,
            ParentID: null,
        };
        this.assignees = [];
        this.selectedTags = [];
    }

    private async loadTask(): Promise<void> {
        this.loading = true;
        this.cdr.markForCheck();
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        const t = result?.Results?.[0];
        if (t) {
            this.form = {
                Name: t.Name, Description: t.Description ?? '',
                Status: t.Status, Priority: t.Priority,
                DueAt: t.DueAt ? new Date(t.DueAt).toISOString().split('T')[0] : null,
                PercentComplete: t.PercentComplete ?? 0,
                HoursEstimated: t.HoursEstimated, HoursActual: t.HoursActual,
                BlockedReason: t.BlockedReason ?? '', CompletionNotes: t.CompletionNotes ?? '',
                TypeID: t.TypeID, CategoryID: t.CategoryID, ParentID: t.ParentID,
            };
        }
        await Promise.all([this.loadExistingAssignees(), this.loadExistingTags()]);
        this.loading = false;
        this.cdr.markForCheck();
    }

    private async loadExistingAssignees(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        this.assignees = (result?.Results ?? []).map((a: any) => ({
            PersonID: a.AssigneeRecordID,
            PersonName: '',
            RoleID: a.RoleID ?? '',
            IsNew: false,
            ExistingID: a.ID,
        }));
    }

    private async loadExistingTags(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Tag Links',
            ExtraFilter: `TaskID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        const tagIDs = (result?.Results ?? []).map((l: any) => l.TagID);
        this.selectedTags = this.allTags.filter(t => tagIDs.includes(t.ID));
    }

    private async loadLookups(): Promise<void> {
        const rv = new RunView();
        const [types, cats, ppl, rls, tasks, tags, entity] = await Promise.all([
            rv.RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Types', ExtraFilter: 'IsActive = 1', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Categories', ExtraFilter: 'IsActive = 1', OrderBy: 'Sequence ASC', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Common: People', ExtraFilter: this.buildAssigneeScopeFilter(), ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Roles', OrderBy: 'Sequence ASC', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Tasks', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Tags', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ: Entities', ExtraFilter: `Name = 'MJ.BizApps.Common: People'`, ResultType: 'simple', MaxRows: 1 }),
        ]);
        this.taskTypes = types?.Results ?? [];
        this.categories = cats?.Results ?? [];
        this.people = ppl?.Results ?? [];
        this.roles = rls?.Results ?? [];
        this.availableTasks = (tasks?.Results ?? []).filter((t: any) => t.ID !== this.TaskID);
        this.allTags = tags?.Results ?? [];
        this.peopleEntityID = entity?.Results?.[0]?.ID ?? null;

        if (this.TaskID && this.selectedTags.length === 0) {
            await this.loadExistingTags();
        }
        this.cdr.markForCheck();
    }

    private buildAssigneeScopeFilter(): string | undefined {
        if (!this.AssigneeScope) return undefined;
        if (Array.isArray(this.AssigneeScope)) {
            if (this.AssigneeScope.length === 0) return undefined;
            return `ID IN (${this.AssigneeScope.map(id => `'${id}'`).join(',')})`;
        }
        return this.AssigneeScope; // ExtraFilter string
    }

    addAssignee(): void {
        this.assignees.push({
            PersonID: '', PersonName: '', RoleID: this.roles[0]?.ID ?? '', IsNew: true,
        });
        this.cdr.markForCheck();
    }

    removeAssignee(index: number): void {
        this.assignees.splice(index, 1);
        this.cdr.markForCheck();
    }

    onAssigneePersonChanged(a: AssigneeRow): void {
        const person = this.people.find((p: any) => p.ID === a.PersonID);
        a.PersonName = person ? `${person.FirstName} ${person.LastName}` : '';
    }

    onTagSelected(event: Event): void {
        const select = event.target as HTMLSelectElement;
        const tagID = select.value;
        if (!tagID) return;
        const tag = this.allTags.find((t: any) => t.ID === tagID);
        if (tag && !this.selectedTags.find((t: any) => t.ID === tagID)) {
            this.selectedTags.push(tag);
        }
        select.value = '';
        this.cdr.markForCheck();
    }

    async createAndAddTag(): Promise<void> {
        const name = this.newTagName.trim();
        if (!name || this.creatingTag) return;

        // Check if tag already exists
        const existing = this.allTags.find((t: any) => t.Name.toLowerCase() === name.toLowerCase());
        if (existing) {
            if (!this.selectedTags.find((t: any) => t.ID === existing.ID)) {
                this.selectedTags.push(existing);
            }
            this.newTagName = '';
            this.cdr.markForCheck();
            return;
        }

        // Pick a random color from a palette
        const colors = ['#6366f1', '#8b5cf6', '#ec4899', '#ef4444', '#f59e0b', '#10b981', '#0ea5e9', '#06b6d4'];
        const color = colors[Math.floor(Math.random() * colors.length)];

        this.creatingTag = true;
        this.cdr.markForCheck();

        const tag = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Tags');
        tag.NewRecord();
        tag.Set('Name', name);
        tag.Set('ColorCode', color);
        await tag.Save();

        const newTag = { ID: tag.Get('ID'), Name: name, ColorCode: color };
        this.allTags.push(newTag);
        this.selectedTags.push(newTag);
        this.newTagName = '';
        this.creatingTag = false;
        this.cdr.markForCheck();
    }

    removeTag(tagID: string): void {
        this.selectedTags = this.selectedTags.filter((t: any) => t.ID !== tagID);
        this.cdr.markForCheck();
    }

    async save(): Promise<void> {
        if (!this.form.Name?.trim()) return;
        this.saving = true;
        this.cdr.markForCheck();

        // Save the task
        const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
        if (this.TaskID) {
            const pk = new CompositeKey([{ FieldName: 'ID', Value: this.TaskID }]);
            await entity.InnerLoad(pk);
        } else {
            entity.NewRecord();
        }

        entity.Set('Name', this.form.Name.trim());
        entity.Set('Description', this.form.Description || null);
        entity.Set('Status', this.form.Status);
        entity.Set('Priority', this.form.Priority);
        entity.Set('DueAt', this.form.DueAt || null);
        entity.Set('PercentComplete', this.form.PercentComplete ?? 0);
        entity.Set('HoursEstimated', this.form.HoursEstimated || null);
        entity.Set('HoursActual', this.form.HoursActual || null);
        entity.Set('BlockedReason', this.form.BlockedReason || null);
        entity.Set('CompletionNotes', this.form.CompletionNotes || null);
        entity.Set('ParentID', this.form.ParentID || null);
        if (this.form.TypeID) entity.Set('TypeID', this.form.TypeID);
        entity.Set('CategoryID', this.form.CategoryID || null);

        await entity.Save();
        const savedID = entity.Get('ID') as string;

        // Save assignees (new ones only for now)
        if (this.peopleEntityID) {
            for (const a of this.assignees) {
                if (a.IsNew && a.PersonID) {
                    const assignment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Assignments');
                    assignment.NewRecord();
                    assignment.Set('TaskID', savedID);
                    assignment.Set('AssigneeEntityID', this.peopleEntityID);
                    assignment.Set('AssigneeRecordID', a.PersonID);
                    if (a.RoleID) assignment.Set('RoleID', a.RoleID);
                    await assignment.Save();
                }
            }
        }

        // Save tags (add new links, remove old)
        if (this.TaskID) {
            // Load existing tag links
            const rv = new RunView();
            const existing = await rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Tag Links',
                ExtraFilter: `TaskID = '${savedID}'`,
                ResultType: 'simple',
            });
            const existingTagIDs = new Set((existing?.Results ?? []).map((l: any) => l.TagID));
            const selectedTagIDs = new Set(this.selectedTags.map((t: any) => t.ID));

            // Add new
            for (const tagID of selectedTagIDs) {
                if (!existingTagIDs.has(tagID)) {
                    const link = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Tag Links');
                    link.NewRecord();
                    link.Set('TaskID', savedID);
                    link.Set('TagID', tagID);
                    await link.Save();
                }
            }
        } else {
            // New task — just create all tag links
            for (const tag of this.selectedTags) {
                const link = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Tag Links');
                link.NewRecord();
                link.Set('TaskID', savedID);
                link.Set('TagID', tag.ID);
                await link.Save();
            }
        }

        this.saving = false;
        this.Saved.emit(savedID);
    }
}
