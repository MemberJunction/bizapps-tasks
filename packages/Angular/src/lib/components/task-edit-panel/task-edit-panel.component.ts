import { Component, EventEmitter, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
/**
 * Slide-in panel for creating or editing a task.
 * Handles all task fields, inline tag management, and assignment.
 *
 * Inputs:
 *   TaskID — set to edit an existing task; null/empty for new task creation.
 *   DefaultCategoryID — pre-fills CategoryID for new tasks.
 *   DefaultTypeID — pre-fills TypeID for new tasks.
 */
@Component({
    selector: 'bizapps-task-edit-panel',
    standalone: true,
    imports: [CommonModule, FormsModule],
    template: `
        <div class="edit-panel">
            <div class="panel-header">
                <h2>{{ isNew ? 'New Task' : 'Edit Task' }}</h2>
                <button class="close-btn" (click)="Cancel.emit()">&times;</button>
            </div>

            @if (loading) {
                <div class="loading">Loading...</div>
            } @else {
                <form (ngSubmit)="save()">
                    <div class="form-group">
                        <label for="name">Name *</label>
                        <input id="name" type="text" [(ngModel)]="form.Name" name="name" required class="form-input" />
                    </div>

                    <div class="form-group">
                        <label for="desc">Description</label>
                        <textarea id="desc" [(ngModel)]="form.Description" name="desc" rows="3" class="form-input"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label for="status">Status</label>
                            <select id="status" [(ngModel)]="form.Status" name="status" class="form-input">
                                <option value="Open">Open</option>
                                <option value="InProgress">In Progress</option>
                                <option value="Blocked">Blocked</option>
                                <option value="Completed">Completed</option>
                                <option value="Cancelled">Cancelled</option>
                            </select>
                        </div>
                        <div class="form-group half">
                            <label for="priority">Priority</label>
                            <select id="priority" [(ngModel)]="form.Priority" name="priority" class="form-input">
                                <option value="Low">Low</option>
                                <option value="Medium">Medium</option>
                                <option value="High">High</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label for="dueAt">Due Date</label>
                            <input id="dueAt" type="date" [(ngModel)]="form.DueAt" name="dueAt" class="form-input" />
                        </div>
                        <div class="form-group half">
                            <label for="pct">% Complete</label>
                            <input id="pct" type="number" [(ngModel)]="form.PercentComplete" name="pct"
                                   min="0" max="100" class="form-input" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group half">
                            <label for="hoursEst">Hours Estimated</label>
                            <input id="hoursEst" type="number" [(ngModel)]="form.HoursEstimated" name="hoursEst"
                                   step="0.25" min="0" class="form-input" />
                        </div>
                        <div class="form-group half">
                            <label for="hoursAct">Hours Actual</label>
                            <input id="hoursAct" type="number" [(ngModel)]="form.HoursActual" name="hoursAct"
                                   step="0.25" min="0" class="form-input" />
                        </div>
                    </div>

                    @if (form.Status === 'Blocked') {
                        <div class="form-group">
                            <label for="blocked">Blocked Reason</label>
                            <textarea id="blocked" [(ngModel)]="form.BlockedReason" name="blocked" rows="2" class="form-input"></textarea>
                        </div>
                    }

                    <div class="form-group">
                        <label for="taskType">Task Type</label>
                        <select id="taskType" [(ngModel)]="form.TypeID" name="taskType" class="form-input">
                            @for (tt of taskTypes; track tt.ID) {
                                <option [value]="tt.ID">{{ tt.Name }}</option>
                            }
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="category">Category</label>
                        <select id="category" [(ngModel)]="form.CategoryID" name="category" class="form-input">
                            <option [ngValue]="null">None</option>
                            @for (cat of categories; track cat.ID) {
                                <option [value]="cat.ID">{{ cat.Name }}</option>
                            }
                        </select>
                    </div>

                    @if (form.Status === 'Completed') {
                        <div class="form-group">
                            <label for="completionNotes">Completion Notes</label>
                            <textarea id="completionNotes" [(ngModel)]="form.CompletionNotes" name="completionNotes"
                                      rows="2" class="form-input"></textarea>
                        </div>
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
        .edit-panel { padding: 16px; max-width: 480px; }
        .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .panel-header h2 { margin: 0; font-size: 1.1rem; }
        .close-btn { background: none; border: none; font-size: 1.4rem; cursor: pointer; color: #9ca3af; }
        .form-group { margin-bottom: 12px; }
        .form-group label { display: block; font-size: 0.8rem; color: #374151; margin-bottom: 3px; font-weight: 500; }
        .form-input {
            width: 100%; padding: 6px 10px; border: 1px solid #d1d5db; border-radius: 6px;
            font-size: 0.875rem; box-sizing: border-box;
        }
        textarea.form-input { resize: vertical; }
        .form-row { display: flex; gap: 12px; }
        .half { flex: 1; }
        .form-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 16px; }
        .btn-primary {
            padding: 8px 20px; border: none; border-radius: 6px;
            background: #4f46e5; color: #fff; font-size: 0.875rem; cursor: pointer; font-weight: 500;
        }
        .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-secondary {
            padding: 8px 20px; border: 1px solid #d1d5db; border-radius: 6px;
            background: #fff; font-size: 0.875rem; cursor: pointer;
        }
        .loading { padding: 32px; text-align: center; color: #9ca3af; }
    `]
})
export class TaskEditPanelComponent implements OnChanges {
    @Input() TaskID: string | null = null;
    @Input() DefaultCategoryID: string | null = null;
    @Input() DefaultTypeID: string | null = null;

    @Output() Saved = new EventEmitter<string>();
    @Output() Cancel = new EventEmitter<void>();

    form: any = {};
    isNew = true;
    loading = false;
    saving = false;
    taskTypes: any[] = [];
    categories: any[] = [];

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
            Name: '',
            Description: '',
            Status: 'Open',
            Priority: 'Medium',
            DueAt: null,
            PercentComplete: 0,
            HoursEstimated: null,
            HoursActual: null,
            BlockedReason: '',
            CompletionNotes: '',
            TypeID: this.DefaultTypeID,
            CategoryID: this.DefaultCategoryID,
        };
    }

    private async loadTask(): Promise<void> {
        this.loading = true;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        const t = result?.Results?.[0];
        if (t) {
            this.form = {
                Name: t.Name,
                Description: t.Description ?? '',
                Status: t.Status,
                Priority: t.Priority,
                DueAt: t.DueAt ? new Date(t.DueAt).toISOString().split('T')[0] : null,
                PercentComplete: t.PercentComplete ?? 0,
                HoursEstimated: t.HoursEstimated,
                HoursActual: t.HoursActual,
                BlockedReason: t.BlockedReason ?? '',
                CompletionNotes: t.CompletionNotes ?? '',
                TypeID: t.TypeID,
                CategoryID: t.CategoryID,
            };
        }
        this.loading = false;
    }

    private async loadLookups(): Promise<void> {
        const rv = new RunView();
        const [types, cats] = await Promise.all([
            rv.RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Types', ExtraFilter: 'IsActive = 1', ResultType: 'simple' }),
            new RunView().RunView<any>({ EntityName: 'MJ.BizApps.Tasks: Task Categories', ExtraFilter: 'IsActive = 1', OrderBy: 'Sequence ASC', ResultType: 'simple' }),
        ]);
        this.taskTypes = types?.Results ?? [];
        this.categories = cats?.Results ?? [];
    }

    async save(): Promise<void> {
        if (!this.form.Name?.trim()) return;
        this.saving = true;

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
        if (this.form.TypeID) entity.Set('TypeID', this.form.TypeID);
        entity.Set('CategoryID', this.form.CategoryID || null);

        await entity.Save();
        const savedID = entity.Get('ID') as string;
        this.saving = false;
        this.Saved.emit(savedID);
    }
}
