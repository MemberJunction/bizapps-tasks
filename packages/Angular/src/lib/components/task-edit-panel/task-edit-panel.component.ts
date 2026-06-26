import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';

/** @internal Represents one assignee row in the edit form. */
interface AssigneeRow {
    PersonID: string;
    PersonName: string;
    RoleID: string;
    IsNew: boolean;
    ExistingID?: string;
}

/** @internal Narrow shape for a person row read from MJ_BizApps_Common: People. */
interface PersonRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
}

/**
 * Cancellable event emitted before a task is saved from the edit panel.
 * Set `Cancel = true` to prevent the save from proceeding.
 */
export class BeforeTaskSaveEvent {
    /** Set to `true` to prevent the task from being saved. */
    Cancel = false;
    constructor(
        /** The task ID being edited, or `null` for a new task. */
        public TaskID: string | null,
        /** The form data about to be saved. */
        public FormData: Record<string, any>
    ) {}
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
                        <div class="add-row">
                            <button type="button" class="btn-add-assignee" (click)="addAssignee()">
                                <i class="fa-solid fa-plus"></i> Add Assignee
                            </button>
                            <div class="new-role-row">
                                <input type="text" [(ngModel)]="newRoleName" name="newRole"
                                       placeholder="New role..." class="form-input new-role-input"
                                       (keydown.enter)="createRole(); $event.preventDefault()" />
                                <button type="button" class="btn-create-tag" (click)="createRole()"
                                        [disabled]="!newRoleName.trim() || creatingRole">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                        </div>
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

                    @if (saveError) {
                        <div class="form-save-error" role="alert">{{ saveError }}</div>
                    }
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
            font-family: var(--mj-font-family);
            -webkit-font-smoothing: antialiased;
        }
        .edit-panel { padding: 28px 24px; }
        .panel-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;
        }
        .panel-header h2 { margin: 0; font-size: 20px; font-weight: var(--mj-font-bold); color: var(--mj-text-primary); letter-spacing: -0.3px; }
        .btn-close {
            padding: 7px 10px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface); color: var(--mj-text-disabled); font-size: 14px; cursor: pointer;
        }
        .btn-close:hover { background: var(--mj-bg-page); color: var(--mj-text-muted); }
        .panel-loading { padding: 64px; text-align: center; color: var(--mj-text-disabled); }

        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block; font-size: 11px; font-weight: var(--mj-font-bold); color: var(--mj-text-disabled);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .form-input {
            width: 100%; padding: 8px 12px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md);
            font-size: 14px; box-sizing: border-box; font-family: inherit;
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .form-input:focus {
            outline: none; border-color: var(--mj-brand-primary);
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 15%, transparent);
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
            padding: 6px 8px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface); color: var(--mj-text-disabled); cursor: pointer; font-size: 12px;
            flex-shrink: 0;
        }
        .btn-remove:hover { background: var(--mj-status-error-bg); color: var(--mj-status-error); border-color: var(--mj-status-error-border); }
        .btn-add-assignee {
            padding: 6px 12px; border: 1px dashed var(--mj-border-strong); border-radius: var(--mj-radius-md);
            background: transparent; color: var(--mj-text-muted); font-size: 13px; cursor: pointer;
            font-family: inherit; display: flex; align-items: center; gap: 5px;
            width: 100%; justify-content: center; margin-top: 4px;
        }
        .btn-add-assignee:hover { background: var(--mj-bg-page); border-color: var(--mj-brand-primary); color: var(--mj-brand-primary); }
        .add-row { display: flex; gap: 8px; align-items: center; margin-top: 4px; }
        .new-role-row { display: flex; gap: 4px; align-items: center; }
        .new-role-input { width: 120px; font-size: 13px; padding: 6px 10px; }

        /* Tags */
        .tags-row {
            display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 6px;
        }
        .tag-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 10px; border-radius: var(--mj-radius-md); font-size: 12px; font-weight: var(--mj-font-semibold);
        }
        .tag-remove {
            background: none; border: none; cursor: pointer; font-size: 14px;
            color: inherit; opacity: 0.6; padding: 0 2px;
        }
        .tag-remove:hover { opacity: 1; }
        .tag-input-row { display: flex; gap: 6px; align-items: center; }
        .tag-select { flex: 1; }
        .tag-or { font-size: 12px; color: var(--mj-text-disabled); flex-shrink: 0; }
        .tag-new-input { flex: 1; }
        .btn-create-tag {
            padding: 8px 10px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface); color: var(--mj-brand-primary); cursor: pointer; font-size: 13px;
            flex-shrink: 0;
        }
        .btn-create-tag:hover { background: color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface)); border-color: var(--mj-brand-primary); }
        .btn-create-tag:disabled { opacity: 0.4; cursor: not-allowed; }

        /* Actions */
        .form-save-error {
            margin-top: 16px; padding: 10px 12px; border-radius: var(--mj-radius-md);
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border); font-size: 13px;
        }
        .form-actions {
            display: flex; gap: 8px; justify-content: flex-end;
            margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--mj-border-subtle);
        }
        .btn-primary {
            padding: 9px 22px; border: none; border-radius: var(--mj-radius-md);
            background: var(--mj-brand-primary); color: var(--mj-text-inverse); font-size: 14px; font-weight: var(--mj-font-semibold);
            cursor: pointer; font-family: inherit;
            box-shadow: var(--mj-shadow-sm);
        }
        .btn-primary:hover { background: var(--mj-brand-primary-hover); }
        .btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }
        .btn-secondary {
            padding: 9px 22px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface); font-size: 14px; cursor: pointer; font-family: inherit;
        }
    `]
})
/**
 * Slide-in panel for creating or editing a task.
 *
 * Provides a full form with all task fields: name, description, status, priority,
 * dates, hours, percent complete, parent task, task type, category, blocked reason,
 * and completion notes. Also supports:
 *
 * - **Multi-person assignment** with role selection and inline role creation
 * - **Tag management** with existing tag picker and inline tag creation
 * - **Parent task selection** to build sub-task hierarchies
 * - **Scoped assignee picker** via the {@link AssigneeScope} input
 *
 * On save, creates/updates the task entity plus any new assignments and tag links.
 *
 * @example
 * ```html
 * <bizapps-task-edit-panel
 *     [TaskID]="selectedTaskID"
 *     [DefaultCategoryID]="committeeCategoryId"
 *     [AssigneeScope]="committeeMemberIDs"
 *     (BeforeSave)="onBeforeSave($event)"
 *     (Saved)="onTaskSaved($event)"
 *     (Cancel)="closePanel()">
 * </bizapps-task-edit-panel>
 * ```
 */
export class TaskEditPanelComponent implements OnChanges {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Task ID to edit. Pass `null` or omit to create a new task.
     * When changed, the form reloads the task data from the server.
     */
    @Input() TaskID: string | null = null;

    /**
     * Default category ID pre-selected for new tasks. Ignored when editing
     * an existing task (the task's current category is used instead).
     */
    @Input() DefaultCategoryID: string | null = null;

    /**
     * Default task type ID pre-selected for new tasks. Ignored when editing.
     */
    @Input() DefaultTypeID: string | null = null;

    /**
     * Narrows the assignee person picker. Accepts either:
     * - A SQL `ExtraFilter` string (e.g. `"ID IN (SELECT PersonID FROM ...)"`)
     * - An array of Person ID strings to include
     *
     * When `null`, all people in BizAppsCommon are shown.
     */
    @Input() AssigneeScope: string | string[] | null = null;

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted **before** the task is saved. Cancellable — set `event.Cancel = true`
     * to prevent the save. The event payload includes the form data.
     */
    @Output() BeforeSave = new EventEmitter<BeforeTaskSaveEvent>();

    /**
     * Emitted **after** the task has been successfully saved. Payload is the
     * saved task's ID (useful for new tasks where the ID wasn't known beforehand).
     */
    @Output() Saved = new EventEmitter<string>();

    /**
     * Emitted when the user clicks "Cancel" or the close button.
     */
    @Output() Cancel = new EventEmitter<void>();

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    form: any = {};
    /** @internal */
    isNew = true;
    /** @internal */
    loading = false;
    /** @internal */
    saving = false;
    /** @internal */
    taskTypes: any[] = [];
    /** @internal Error surfaced when a save fails so the panel doesn't close silently. */
    saveError: string | null = null;
    /** @internal */
    categories: any[] = [];
    /** @internal */
    people: any[] = [];
    /** @internal */
    roles: any[] = [];
    /** @internal */
    availableTasks: any[] = [];
    /** @internal */
    allTags: any[] = [];
    /** @internal */
    selectedTags: any[] = [];
    /** @internal */
    assignees: AssigneeRow[] = [];
    /** @internal */
    newTagName = '';
    /** @internal */
    creatingTag = false;
    /** @internal */
    newRoleName = '';
    /** @internal */
    creatingRole = false;
    /** @internal */
    private peopleEntityID: string | null = null;
    /** @internal */
    private cdr = inject(ChangeDetectorRef);

    /** @internal Returns tags not already selected. */
    get availableTagsFiltered(): any[] {
        const selectedIDs = new Set(this.selectedTags.map((t: any) => t.ID));
        return this.allTags.filter(t => !selectedIDs.has(t.ID));
    }

    // ── Lifecycle ───────────────────────────────────────────

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
        const result = await rv.RunView<{
            Name: string;
            Description: string | null;
            Status: string;
            Priority: string;
            DueAt: Date | null;
            PercentComplete: number | null;
            HoursEstimated: number | null;
            HoursActual: number | null;
            BlockedReason: string | null;
            CompletionNotes: string | null;
            TypeID: string;
            CategoryID: string | null;
            ParentID: string | null;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
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
        const result = await rv.RunView<{ ID: string; AssigneeRecordID: string; RoleID: string | null }>({
            EntityName: 'MJ_BizApps_Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        this.assignees = (result?.Results ?? []).map(a => ({
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
        const result = await rv.RunView<{ TagID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Tag Links',
            ExtraFilter: `TaskID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        const tagIDs = (result?.Results ?? []).map(l => l.TagID);
        this.selectedTags = this.allTags.filter(t => tagIDs.includes(t.ID));
    }

    private async loadLookups(): Promise<void> {
        const rv = new RunView();
        const [types, cats, ppl, rls, tasks, tags, entity] = await Promise.all([
            rv.RunView<{ ID: string; Name: string }>({ EntityName: 'MJ_BizApps_Tasks: Task Types', ExtraFilter: 'IsActive = 1', ResultType: 'simple' }),
            new RunView().RunView<{ ID: string; Name: string }>({ EntityName: 'MJ_BizApps_Tasks: Task Categories', ExtraFilter: 'IsActive = 1', OrderBy: 'Sequence ASC', ResultType: 'simple' }),
            new RunView().RunView<PersonRow>({ EntityName: 'MJ_BizApps_Common: People', ExtraFilter: this.buildAssigneeScopeFilter(), ResultType: 'simple' }),
            new RunView().RunView<{ ID: string; Name: string }>({ EntityName: 'MJ_BizApps_Tasks: Task Roles', OrderBy: 'Sequence ASC', ResultType: 'simple' }),
            new RunView().RunView<{ ID: string; Name: string }>({ EntityName: 'MJ_BizApps_Tasks: Tasks', ResultType: 'simple' }),
            new RunView().RunView<{ ID: string; Name: string; ColorCode: string | null }>({ EntityName: 'MJ_BizApps_Tasks: Task Tags', ResultType: 'simple' }),
            new RunView().RunView<{ ID: string }>({ EntityName: 'MJ: Entities', ExtraFilter: `Name = 'MJ_BizApps_Common: People'`, ResultType: 'simple', MaxRows: 1 }),
        ]);
        this.taskTypes = types?.Results ?? [];
        // TypeID is a required FK on Tasks. For a new task with no type chosen yet,
        // default to the first active type so a save can't silently fail on the FK.
        if (!this.TaskID && !this.form.TypeID && this.taskTypes.length > 0) {
            this.form.TypeID = this.taskTypes[0].ID;
        }
        this.categories = cats?.Results ?? [];
        this.people = ppl?.Results ?? [];
        this.roles = rls?.Results ?? [];
        this.availableTasks = (tasks?.Results ?? []).filter(t => t.ID !== this.TaskID);
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

    async createRole(): Promise<void> {
        const name = this.newRoleName.trim();
        if (!name || this.creatingRole) return;

        const existing = this.roles.find((r: any) => r.Name.toLowerCase() === name.toLowerCase());
        if (existing) {
            this.newRoleName = '';
            this.cdr.markForCheck();
            return;
        }

        this.creatingRole = true;
        this.cdr.markForCheck();

        const role = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Roles');
        role.NewRecord();
        role.Set('Name', name);
        await role.Save();

        this.roles.push({ ID: role.Get('ID'), Name: name });
        this.newRoleName = '';
        this.creatingRole = false;
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

        const tag = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Tags');
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

        const before = new BeforeTaskSaveEvent(this.TaskID, { ...this.form });
        this.BeforeSave.emit(before);
        if (before.Cancel) return;

        this.saving = true;
        this.cdr.markForCheck();

        // Save the task
        const entity = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Tasks');
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

        const taskSaved = await entity.Save();
        if (!taskSaved) {
            this.saveError = entity.LatestResult?.CompleteMessage ?? 'Failed to save task.';
            console.error('Task Save() returned false:', this.saveError);
            this.saving = false;
            this.cdr.markForCheck();
            return;
        }
        this.saveError = null;
        const savedID = entity.Get('ID') as string;

        // Save assignees — create new, update existing, delete removed
        if (this.peopleEntityID) {
            // Load current assignments from DB to diff against
            const rv2 = new RunView();
            const currentAssignments = this.TaskID ? await rv2.RunView<{ ID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                ExtraFilter: `TaskID = '${savedID}'`,
                ResultType: 'simple',
            }) : null;
            const existingIDs = new Set(this.assignees.filter(a => !a.IsNew && a.ExistingID).map(a => a.ExistingID!));

            // Delete removed assignments (ones in DB but no longer in form)
            for (const dbRow of currentAssignments?.Results ?? []) {
                if (!existingIDs.has(dbRow.ID)) {
                    const del = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Assignments');
                    const pk = new CompositeKey([{ FieldName: 'ID', Value: dbRow.ID }]);
                    await del.InnerLoad(pk);
                    await del.Delete();
                }
            }

            for (const a of this.assignees) {
                if (!a.PersonID) continue;
                if (a.IsNew) {
                    // Create new assignment
                    const assignment = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Assignments');
                    assignment.NewRecord();
                    assignment.Set('TaskID', savedID);
                    assignment.Set('AssigneeEntityID', this.peopleEntityID);
                    assignment.Set('AssigneeRecordID', a.PersonID);
                    if (a.RoleID) assignment.Set('RoleID', a.RoleID);
                    await assignment.Save();
                } else if (a.ExistingID) {
                    // Update existing assignment (person or role may have changed)
                    const assignment = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Assignments');
                    const pk = new CompositeKey([{ FieldName: 'ID', Value: a.ExistingID }]);
                    await assignment.InnerLoad(pk);
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
            const existing = await rv.RunView<{ ID: string; TagID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Tag Links',
                ExtraFilter: `TaskID = '${savedID}'`,
                ResultType: 'simple',
            });
            const existingLinks = existing?.Results ?? [];
            const existingTagIDs = new Set(existingLinks.map(l => l.TagID));
            const selectedTagIDs = new Set(this.selectedTags.map((t: any) => t.ID));

            // Add new
            for (const tagID of selectedTagIDs) {
                if (!existingTagIDs.has(tagID)) {
                    const link = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Tag Links');
                    link.NewRecord();
                    link.Set('TaskID', savedID);
                    link.Set('TagID', tagID);
                    await link.Save();
                }
            }

            // Remove deselected — delete links whose tag is no longer selected
            for (const existingLink of existingLinks) {
                if (!selectedTagIDs.has(existingLink.TagID)) {
                    const link = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Tag Links');
                    const pk = new CompositeKey([{ FieldName: 'ID', Value: existingLink.ID }]);
                    await link.InnerLoad(pk);
                    await link.Delete();
                }
            }
        } else {
            // New task — just create all tag links
            for (const tag of this.selectedTags) {
                const link = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Tag Links');
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
