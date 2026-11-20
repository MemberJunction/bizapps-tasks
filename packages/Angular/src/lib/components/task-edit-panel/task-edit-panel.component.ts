import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    HostListener,
    Input,
    OnChanges,
    Output,
    SimpleChanges,
    inject,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { ResolveTaskUiArchetype, TasksSettings, type TaskUiArchetype } from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskRoleEntity,
    mjBizAppsTasksTaskTagEntity,
} from '@mj-biz-apps/tasks-entities';
import type {
    TaskCheckInCadenceValue,
    TaskMetricDirectionValue,
    TaskPriorityValue,
    TaskStatusValue,
    TaskWidgetLinkedRecord,
    TaskWidgetTypeStatus,
} from '@mj-biz-apps/tasks-ng-widgets';
import { RecordLinkPickerDialogComponent } from '../record-link-picker/record-link-picker-dialog.component';
import { ROLES_ENTITY } from '../../role-assignees';

interface AssigneeRow {
    AssigneeKind?: 'person' | 'role';
    AssigneeRecordID?: string;
    DisplayName?: string;
    PersonID?: string;
    PersonName?: string;
    RoleID: string;
    IsNew: boolean;
    ExistingID?: string;
}

interface PersonRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
}

interface TaskTypeOption {
    ID: string;
    Name: string;
    Code: string;
    IconClass: string | null;
    DefaultPriority: TaskPriorityValue;
    IsApproval: boolean;
    OnCompleteAction: string | null;
    OnRejectAction: string | null;
    OnCancelAction: string | null;
}

interface TagOption {
    ID: string;
    Name: string;
    ColorCode: string | null;
}

export interface TaskEditFormData {
    Name: string;
    Description: string;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    StartedAt: string | null;
    DueAt: string | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    HoursActual: number | null;
    BlockedReason: string;
    CompletionNotes: string;
    TypeID: string;
    TaskTypeStatusID: string | null;
    CategoryID: string | null;
    ParentID: string | null;
    BaselineValue: number | null;
    TargetValue: number | null;
    CurrentValue: number | null;
    UnitOfMeasure: string;
    MetricDirection: TaskMetricDirectionValue;
    PlanningPeriod: string;
    CheckInCadence: TaskCheckInCadenceValue;
}

/**
 * Cancellable event emitted before a task is saved from the edit panel.
 * Set `Cancel = true` to prevent the save from proceeding.
 */
export class BeforeTaskSaveEvent {
    Cancel = false;
    constructor(
        public TaskID: string | null,
        public FormData: TaskEditFormData,
    ) {}
}

/**
 * TaskType-Adaptive Express Create & Edit Drawer (L3 Explorer component).
 *
 * Progressive disclosure by default:
 * - General tasks surface 4 calm controls (`Title`, `Description`, inline `Who / When / Priority / Category / Linked Record` strip) + `<details>` "More fields".
 * - Switching the top TaskType pill strip morphs the drawer cleanly for `Deliverable` (Start→Due, `TaskTypeStatus`, Effort, quick inline sub-tasks), `Approval Request` (Person/MJ Role Approver + Lifecycle Hook preview), and `Key Result` (Baseline/Target/Unit/Direction/Cadence/Period).
 * - Sticky MJ-ordered footer: Primary Confirm LEFT (`Cmd+Enter`), Cancel RIGHT.
 */
@Component({
    selector: 'bizapps-task-edit-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule, MJButtonDirective, RecordLinkPickerDialogComponent],
    template: `
        <div class="mjt-ep">
            @if (loading) {
                <div class="mjt-ep-loading">Loading task form...</div>
            } @else {
                <form class="mjt-ep-form" (ngSubmit)="save()">
                    <div class="mjt-ep-scroll">
                        <!-- 1. TaskType Pill Strip -->
                        @if (taskTypes.length > 0) {
                            <div class="mjt-type-strip" role="radiogroup" aria-label="Task type">
                                @for (tt of taskTypes; track tt.ID) {
                                    <button
                                        type="button"
                                        role="radio"
                                        class="mjt-type-pill"
                                        [class.is-active]="form.TypeID === tt.ID"
                                        [attr.aria-checked]="form.TypeID === tt.ID"
                                        [disabled]="ReadOnly"
                                        (click)="selectTaskType(tt)">
                                        <i [class]="tt.IconClass || 'fa-solid fa-circle-check'" aria-hidden="true"></i>
                                        <span>{{ tt.Name }}</span>
                                    </button>
                                }
                            </div>
                        }

                        <!-- 2. Primary Title & 1-line Description -->
                        <div class="mjt-ep-hero-fields">
                            <input
                                type="text"
                                name="name"
                                class="mjt-ep-title-input"
                                [(ngModel)]="form.Name"
                                [disabled]="ReadOnly"
                                required
                                placeholder="What needs to get done?"
                                aria-label="Task title" />
                            <textarea
                                name="desc"
                                rows="2"
                                class="mjt-ep-desc-input"
                                [(ngModel)]="form.Description"
                                [disabled]="ReadOnly"
                                placeholder="Add context, links, or acceptance criteria (optional)..."></textarea>
                        </div>

                        <!-- 3. Quick Metadata Strip (When / Priority / Category / Status) -->
                        <div class="mjt-ep-quick-grid">
                            <div class="mjt-ep-field">
                                <label>Due Date</label>
                                <input type="date" name="dueAt" class="mjt-ep-input" [(ngModel)]="form.DueAt" [disabled]="ReadOnly" />
                            </div>
                            <div class="mjt-ep-field">
                                <label>Priority</label>
                                <select name="priority" class="mjt-ep-input" [(ngModel)]="form.Priority" [disabled]="ReadOnly">
                                    <option value="Low">Low</option>
                                    <option value="Medium">Medium</option>
                                    <option value="High">High</option>
                                    <option value="Critical">Critical</option>
                                </select>
                            </div>
                            <div class="mjt-ep-field">
                                <label>Category</label>
                                <select name="category" class="mjt-ep-input" [(ngModel)]="form.CategoryID" [disabled]="ReadOnly">
                                    <option [ngValue]="null">None</option>
                                    @for (cat of categories; track cat.ID) {
                                        <option [value]="cat.ID">{{ cat.Name }}</option>
                                    }
                                </select>
                            </div>
                            <div class="mjt-ep-field">
                                <label>Status</label>
                                <select name="status" class="mjt-ep-input" [(ngModel)]="form.Status" [disabled]="ReadOnly">
                                    <option value="Open">Open</option>
                                    <option value="InProgress">In Progress</option>
                                    <option value="Blocked">Blocked</option>
                                    <option value="Completed">Completed</option>
                                    <option value="Cancelled">Cancelled</option>
                                </select>
                            </div>
                        </div>

                        <!-- 4. Connected Business Records (Task Links) -->
                        <div class="mjt-ep-section">
                            <div class="mjt-ep-section-head">
                                <span class="mjt-ep-label">Connected Business Records</span>
                                @if (!ReadOnly) {
                                    <button type="button" mjButton variant="flat" size="sm" (click)="showLinkPicker = true">
                                        <i class="fa-solid fa-link" aria-hidden="true"></i> Link Record
                                    </button>
                                }
                            </div>
                            @if (linkedRecords.length > 0) {
                                <div class="mjt-chip-row">
                                    @for (rec of linkedRecords; track rec.EntityName + ':' + rec.RecordID; let i = $index) {
                                        <span class="mjt-link-pill">
                                            <i [class]="rec.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                                            <span>{{ rec.DisplayName }}</span>
                                            @if (!ReadOnly) {
                                                <button type="button" class="mjt-chip-x" aria-label="Remove linked record" (click)="removeLinkedRecord(i)">
                                                    <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                                                </button>
                                            }
                                        </span>
                                    }
                                </div>
                            }
                        </div>

                        <!-- 5. Assignees (Supports BOTH People AND MJ Roles) -->
                        <div class="mjt-ep-section">
                            <div class="mjt-ep-section-head">
                                <span class="mjt-ep-label">
                                    {{ ActiveArchetype === 'approval' ? 'Approvers (Person or MJ Role)' : 'Assignees' }}
                                </span>
                                @if (!ReadOnly) {
                                    <div class="mjt-ep-btn-pair">
                                        <button type="button" mjButton variant="flat" size="sm" (click)="addAssignee('person')">
                                            <i class="fa-solid fa-user-plus" aria-hidden="true"></i> Person
                                        </button>
                                        @if (mjRoles.length > 0) {
                                            <button type="button" mjButton variant="flat" size="sm" (click)="addAssignee('role')">
                                                <i class="fa-solid fa-users" aria-hidden="true"></i> MJ Role
                                            </button>
                                        }
                                    </div>
                                }
                            </div>
                            @for (a of assignees; track a; let i = $index) {
                                <div class="mjt-assignee-row">
                                    @if (a.AssigneeKind === 'role') {
                                        <select class="mjt-ep-input mjt-grow" [(ngModel)]="a.AssigneeRecordID" [name]="'roleAssignee' + i" [disabled]="ReadOnly">
                                            <option value="">Select MJ Role...</option>
                                            @for (mr of mjRoles; track mr.ID) {
                                                <option [value]="mr.ID">{{ mr.Name }} (Role)</option>
                                            }
                                        </select>
                                    } @else {
                                        <select
                                            class="mjt-ep-input mjt-grow"
                                            [(ngModel)]="a.AssigneeRecordID"
                                            [name]="'person' + i"
                                            [disabled]="ReadOnly"
                                            (ngModelChange)="onAssigneePersonChanged(a)">
                                            <option value="">Select person...</option>
                                            @for (p of people; track p.ID) {
                                                <option [value]="p.ID">{{ p.FirstName }} {{ p.LastName }}</option>
                                            }
                                        </select>
                                    }
                                    <select class="mjt-ep-input mjt-role-sel" [(ngModel)]="a.RoleID" [name]="'taskRole' + i" [disabled]="ReadOnly">
                                        @for (r of roles; track r.ID) {
                                            <option [value]="r.ID">{{ r.Name }}</option>
                                        }
                                    </select>
                                    @if (!ReadOnly) {
                                        <button type="button" class="mjt-icon-btn" aria-label="Remove assignee" (click)="removeAssignee(i)">
                                            <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                                        </button>
                                    }
                                </div>
                            }
                        </div>

                        <!-- 6. Type-Adaptive Section: Deliverable -->
                        @if (ActiveArchetype === 'deliverable') {
                            <div class="mjt-ep-adaptive">
                                <div class="mjt-ep-adaptive-title">
                                    <i class="fa-solid fa-file-export" aria-hidden="true"></i> Deliverable Schedule &amp; Workflow
                                </div>
                                <div class="mjt-ep-quick-grid">
                                    <div class="mjt-ep-field">
                                        <label>Start Date</label>
                                        <input type="date" name="startedAt" class="mjt-ep-input" [(ngModel)]="form.StartedAt" [disabled]="ReadOnly" />
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Estimated Hours</label>
                                        <input type="number" name="hoursEstDeliv" step="0.5" min="0" class="mjt-ep-input" [(ngModel)]="form.HoursEstimated" [disabled]="ReadOnly" />
                                    </div>
                                    @if (activeTypeStatuses.length > 0) {
                                        <div class="mjt-ep-field mjt-span-2">
                                            <label>Workflow Stage (TaskTypeStatus)</label>
                                            <select name="typeStatus" class="mjt-ep-input" [(ngModel)]="form.TaskTypeStatusID" [disabled]="ReadOnly" (ngModelChange)="onTypeStatusSelected($event)">
                                                <option [ngValue]="null">Default</option>
                                                @for (st of activeTypeStatuses; track st.ID) {
                                                    <option [value]="st.ID">{{ st.Name }} ({{ st.MacroStatus }})</option>
                                                }
                                            </select>
                                        </div>
                                    }
                                </div>

                                @if (isNew && !ReadOnly) {
                                    <div class="mjt-ep-subtasks">
                                        <label class="mjt-ep-label">Quick Sub-tasks (created with deliverable)</label>
                                        @for (st of draftSubtasks; track $index; let idx = $index) {
                                            <div class="mjt-sub-draft">
                                                <i class="fa-regular fa-circle" aria-hidden="true"></i>
                                                <span class="mjt-grow">{{ st }}</span>
                                                <button type="button" class="mjt-icon-btn" (click)="removeDraftSubtask(idx)">
                                                    <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                                                </button>
                                            </div>
                                        }
                                        <div class="mjt-sub-add-row">
                                            <input
                                                type="text"
                                                name="newSubtask"
                                                class="mjt-ep-input"
                                                [(ngModel)]="newSubtaskDraft"
                                                placeholder="Add a sub-task title and press Enter..."
                                                (keydown.enter)="addDraftSubtask(); $event.preventDefault()" />
                                            <button type="button" mjButton variant="outline" size="sm" [disabled]="!newSubtaskDraft.trim()" (click)="addDraftSubtask()">
                                                Add
                                            </button>
                                        </div>
                                    </div>
                                }
                            </div>
                        }

                        <!-- 7. Type-Adaptive Section: Approval Request -->
                        @if (ActiveArchetype === 'approval') {
                            <div class="mjt-ep-adaptive mjt-ep-adaptive--violet">
                                <div class="mjt-ep-adaptive-title">
                                    <i class="fa-solid fa-stamp" aria-hidden="true"></i> Approval Governance &amp; Lifecycle Hooks
                                </div>
                                <p class="mjt-ep-hint">
                                    Assign a Person or MJ Role above to route this decision to their Approvals inbox.
                                </p>
                                @if (activeTaskType?.OnCompleteAction || activeTaskType?.OnRejectAction || activeTaskType?.OnCancelAction) {
                                    <div class="mjt-hook-row">
                                        @if (activeTaskType?.OnCompleteAction) {
                                            <span class="mjt-hook-badge">OnApprove: {{ activeTaskType?.OnCompleteAction }}</span>
                                        }
                                        @if (activeTaskType?.OnRejectAction) {
                                            <span class="mjt-hook-badge">OnReject: {{ activeTaskType?.OnRejectAction }}</span>
                                        }
                                        @if (activeTaskType?.OnCancelAction) {
                                            <span class="mjt-hook-badge">OnCancel: {{ activeTaskType?.OnCancelAction }}</span>
                                        }
                                    </div>
                                }
                            </div>
                        }

                        <!-- 8. Type-Adaptive Section: Key Result / OKR -->
                        @if (ActiveArchetype === 'key-result') {
                            <div class="mjt-ep-adaptive mjt-ep-adaptive--brand">
                                <div class="mjt-ep-adaptive-title">
                                    <i class="fa-solid fa-bullseye" aria-hidden="true"></i> Key Result Metric &amp; Cadence
                                </div>
                                <div class="mjt-ep-okr-grid">
                                    <div class="mjt-ep-field">
                                        <label>Baseline</label>
                                        <input type="number" name="baseline" step="any" class="mjt-ep-input" [(ngModel)]="form.BaselineValue" [disabled]="ReadOnly" />
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Current</label>
                                        <input type="number" name="currentVal" step="any" class="mjt-ep-input" [(ngModel)]="form.CurrentValue" [disabled]="ReadOnly" />
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Target</label>
                                        <input type="number" name="targetVal" step="any" class="mjt-ep-input" [(ngModel)]="form.TargetValue" [disabled]="ReadOnly" />
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Unit</label>
                                        <input type="text" name="unit" class="mjt-ep-input" [(ngModel)]="form.UnitOfMeasure" [disabled]="ReadOnly" placeholder="%, $, deals..." />
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Direction</label>
                                        <select name="direction" class="mjt-ep-input" [(ngModel)]="form.MetricDirection" [disabled]="ReadOnly">
                                            <option [ngValue]="'Increase'">Increase</option>
                                            <option [ngValue]="'Decrease'">Decrease</option>
                                            <option [ngValue]="'Maintain'">Maintain</option>
                                        </select>
                                    </div>
                                    <div class="mjt-ep-field">
                                        <label>Check-In Cadence</label>
                                        <select name="cadence" class="mjt-ep-input" [(ngModel)]="form.CheckInCadence" [disabled]="ReadOnly">
                                            <option [ngValue]="'Weekly'">Weekly</option>
                                            <option [ngValue]="'BiWeekly'">Bi-Weekly</option>
                                            <option [ngValue]="'Monthly'">Monthly</option>
                                            <option [ngValue]="'Quarterly'">Quarterly</option>
                                            <option [ngValue]="'Daily'">Daily</option>
                                            <option [ngValue]="'None'">None</option>
                                        </select>
                                    </div>
                                    <div class="mjt-ep-field mjt-span-2">
                                        <label>Planning Period</label>
                                        <input type="text" name="period" class="mjt-ep-input" [(ngModel)]="form.PlanningPeriod" [disabled]="ReadOnly" placeholder="e.g. Q4 2026" />
                                    </div>
                                </div>
                            </div>
                        }

                        <!-- 9. Conditional Status Notes -->
                        @if (form.Status === 'Blocked') {
                            <div class="mjt-ep-field">
                                <label>Blocked Reason</label>
                                <textarea name="blocked" rows="2" class="mjt-ep-input" [(ngModel)]="form.BlockedReason" [disabled]="ReadOnly"></textarea>
                            </div>
                        }
                        @if (form.Status === 'Completed') {
                            <div class="mjt-ep-field">
                                <label>Completion Notes</label>
                                <textarea name="completionNotes" rows="2" class="mjt-ep-input" [(ngModel)]="form.CompletionNotes" [disabled]="ReadOnly"></textarea>
                            </div>
                        }

                        <!-- 10. Progressive Disclosure: Advanced Fields inside native <details> -->
                        <details class="mjt-ep-details" [open]="!isNew">
                            <summary class="mjt-ep-details-sum">
                                <i class="fa-solid fa-sliders" aria-hidden="true"></i>
                                <span>More details (Parent task, Schedule, Effort, Tags)</span>
                            </summary>

                            <div class="mjt-ep-details-body">
                                <div class="mjt-ep-field">
                                    <label>Parent Task</label>
                                    <select name="parentTask" class="mjt-ep-input" [(ngModel)]="form.ParentID" [disabled]="ReadOnly">
                                        <option [ngValue]="null">None (top-level)</option>
                                        @for (t of availableTasks; track t.ID) {
                                            <option [value]="t.ID">{{ t.Name }}</option>
                                        }
                                    </select>
                                </div>

                                <div class="mjt-ep-quick-grid">
                                    @if (ActiveArchetype !== 'deliverable') {
                                        <div class="mjt-ep-field">
                                            <label>Start Date</label>
                                            <input type="date" name="startedAtAdv" class="mjt-ep-input" [(ngModel)]="form.StartedAt" [disabled]="ReadOnly" />
                                        </div>
                                        <div class="mjt-ep-field">
                                            <label>Hours Estimated</label>
                                            <input type="number" name="hoursEst" step="0.25" min="0" class="mjt-ep-input" [(ngModel)]="form.HoursEstimated" [disabled]="ReadOnly" />
                                        </div>
                                    }
                                    @if (!timeTrackingEnabled) {
                                        <div class="mjt-ep-field">
                                            <label>Hours Actual</label>
                                            <input type="number" name="hoursAct" step="0.25" min="0" class="mjt-ep-input" [(ngModel)]="form.HoursActual" [disabled]="ReadOnly" />
                                        </div>
                                    }
                                    <div class="mjt-ep-field">
                                        <label>% Complete</label>
                                        <input type="number" name="pct" min="0" max="100" class="mjt-ep-input" [(ngModel)]="form.PercentComplete" [disabled]="ReadOnly" />
                                    </div>
                                </div>

                                <!-- Tags -->
                                <div class="mjt-ep-field">
                                    <label>Tags</label>
                                    @if (selectedTags.length > 0) {
                                        <div class="mjt-chip-row">
                                            @for (t of selectedTags; track t.ID) {
                                                <span class="mjt-tag-chip" [style.borderColor]="t.ColorCode || 'var(--mj-brand-primary)'">
                                                    <span>{{ t.Name }}</span>
                                                    @if (!ReadOnly) {
                                                        <button type="button" class="mjt-chip-x" (click)="removeTag(t.ID)">&times;</button>
                                                    }
                                                </span>
                                            }
                                        </div>
                                    }
                                    @if (!ReadOnly) {
                                        <div class="mjt-tag-add-row">
                                            <select class="mjt-ep-input" (change)="onTagSelected($event)">
                                                <option value="">Add existing tag...</option>
                                                @for (t of availableTagsFiltered; track t.ID) {
                                                    <option [value]="t.ID">{{ t.Name }}</option>
                                                }
                                            </select>
                                            <input
                                                type="text"
                                                name="newTag"
                                                class="mjt-ep-input"
                                                [(ngModel)]="newTagName"
                                                placeholder="Or create tag..."
                                                (keydown.enter)="createAndAddTag(); $event.preventDefault()" />
                                            <button type="button" mjButton variant="outline" size="sm" [disabled]="!newTagName.trim() || creatingTag" (click)="createAndAddTag()">
                                                <i class="fa-solid fa-plus" aria-hidden="true"></i>
                                            </button>
                                        </div>
                                    }
                                </div>
                            </div>
                        </details>

                        @if (saveError) {
                            <div class="mjt-ep-error" role="alert">{{ saveError }}</div>
                        }
                    </div>

                    <!-- Sticky MJ-Ordered Footer (Confirm LEFT · Cancel RIGHT) -->
                    <div class="mjt-ep-footer">
                        <button
                            type="submit"
                            mjButton
                            variant="primary"
                            size="sm"
                            [disabled]="ReadOnly || saving || !form.Name.trim()">
                            @if (saving) {
                                <i class="fa-solid fa-spinner fa-spin" aria-hidden="true"></i>
                            } @else {
                                <i class="fa-solid fa-check" aria-hidden="true"></i>
                            }
                            <span>{{ saving ? 'Saving...' : (isNew ? 'Create Task' : 'Save Changes') }}</span>
                            <kbd class="mjt-kbd">⌘↵</kbd>
                        </button>
                        <button type="button" mjButton variant="outline" size="sm" (click)="Cancel.emit()">
                            Cancel
                        </button>
                    </div>
                </form>
            }

            <bizapps-record-link-picker-dialog
                [Visible]="showLinkPicker"
                (RecordSelected)="onLinkedRecordAdded($event)"
                (Cancelled)="showLinkPicker = false">
            </bizapps-record-link-picker-dialog>
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
        .mjt-ep {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 0;
        }
        .mjt-ep-loading {
            padding: 48px 24px;
            text-align: center;
            color: var(--mj-text-muted);
            font-size: var(--mj-text-sm, 14px);
        }
        .mjt-ep-form {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 0;
        }
        .mjt-ep-scroll {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            padding: 16px 20px 24px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .mjt-type-strip {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-type-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 11px;
            min-height: 30px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            transition: all 140ms ease;
        }
        .mjt-type-pill:hover:not(:disabled) {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
        }
        .mjt-type-pill.is-active {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-on-primary, #ffffff);
        }
        .mjt-ep-hero-fields {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-ep-title-input {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-base, 16px);
            font-weight: var(--mj-font-semibold, 600);
            box-sizing: border-box;
        }
        .mjt-ep-title-input:focus,
        .mjt-ep-desc-input:focus,
        .mjt-ep-input:focus {
            outline: none;
            border-color: var(--mj-border-focus, var(--mj-brand-primary));
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 15%, transparent);
        }
        .mjt-ep-desc-input {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            resize: vertical;
            box-sizing: border-box;
        }
        .mjt-ep-quick-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }
        .mjt-ep-okr-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
        }
        .mjt-span-2 {
            grid-column: span 2;
        }
        .mjt-ep-field {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
        }
        .mjt-ep-field label,
        .mjt-ep-label {
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-ep-input {
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
        .mjt-ep-section {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-ep-section-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
        }
        .mjt-ep-btn-pair {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .mjt-assignee-row {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-grow { flex: 1; min-width: 0; }
        .mjt-role-sel { width: 120px; flex-shrink: 0; }
        .mjt-icon-btn {
            width: 32px;
            height: 32px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-muted);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .mjt-icon-btn:hover {
            border-color: var(--mj-status-error);
            color: var(--mj-status-error-text);
            background: var(--mj-status-error-bg);
        }
        .mjt-ep-adaptive {
            padding: 12px 14px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            border-left: 3px solid var(--mj-brand-primary);
            background: var(--mj-bg-surface-sunken);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mjt-ep-adaptive--violet {
            border-left-color: var(--mj-text-violet, #7c3aed);
        }
        .mjt-ep-adaptive-title {
            display: flex;
            align-items: center;
            gap: 7px;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-ep-hint {
            margin: 0;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-secondary);
        }
        .mjt-hook-row,
        .mjt-chip-row {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-hook-badge,
        .mjt-link-pill,
        .mjt-tag-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 3px 9px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-medium, 500);
        }
        .mjt-link-pill {
            color: var(--mj-text-link);
        }
        .mjt-chip-x {
            border: none;
            background: transparent;
            color: var(--mj-text-muted);
            cursor: pointer;
            padding: 0 2px;
            font-size: 12px;
        }
        .mjt-ep-subtasks {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-sub-draft {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm, 4px);
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-sub-add-row,
        .mjt-tag-add-row {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-ep-details {
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
        }
        .mjt-ep-details-sum {
            padding: 10px 12px;
            cursor: pointer;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
            list-style: none;
        }
        .mjt-ep-details-sum::-webkit-details-marker { display: none; }
        .mjt-ep-details-body {
            padding: 0 12px 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            border-top: 1px solid var(--mj-border-subtle);
            padding-top: 12px;
        }
        .mjt-ep-error {
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border);
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-ep-footer {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px max(12px, env(safe-area-inset-bottom, 0px));
            border-top: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            flex-shrink: 0;
        }
        .mjt-kbd {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 10.5px;
            padding: 1px 5px;
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.2);
            color: inherit;
            margin-left: 4px;
        }
        @media (max-width: 540px) {
            .mjt-ep-quick-grid,
            .mjt-ep-okr-grid {
                grid-template-columns: minmax(0, 1fr);
            }
            .mjt-span-2 {
                grid-column: span 1;
            }
        }
    `],
})
export class TaskEditPanelComponent implements OnChanges {
    @Input() TaskID: string | null = null;
    @Input() DefaultCategoryID: string | null = null;
    @Input() DefaultTypeID: string | null = null;
    @Input() DefaultParentID: string | null = null;
    @Input() AssigneeScope: string | string[] | null = null;
    @Input() ParentTaskFilter: string | null = null;
    @Input() ReadOnly = false;

    @Output() BeforeSave = new EventEmitter<BeforeTaskSaveEvent>();
    @Output() Saved = new EventEmitter<string>();
    @Output() Cancel = new EventEmitter<void>();

    public form: TaskEditFormData = this.defaultForm();
    public loading = false;
    public saving = false;
    public saveError: string | null = null;
    public showLinkPicker = false;

    public taskTypes: TaskTypeOption[] = [];
    public allTypeStatuses: TaskWidgetTypeStatus[] = [];
    public categories: { ID: string; Name: string }[] = [];
    public people: PersonRow[] = [];
    public mjRoles: { ID: string; Name: string }[] = [];
    public roles: { ID: string; Name: string }[] = [];
    public availableTasks: { ID: string; Name: string }[] = [];
    public assignees: AssigneeRow[] = [];
    public allTags: TagOption[] = [];
    public selectedTags: TagOption[] = [];
    public linkedRecords: TaskWidgetLinkedRecord[] = [];
    public draftSubtasks: string[] = [];
    public newSubtaskDraft = '';
    public newTagName = '';
    public creatingTag = false;
    public isNew = true;
    public timeTrackingEnabled = false;

    private peopleEntityID: string | null = null;
    private rolesEntityID: string | null = null;
    private cdr = inject(ChangeDetectorRef);

    public get activeTaskType(): TaskTypeOption | undefined {
        return this.taskTypes.find((t) => t.ID === this.form.TypeID);
    }

    public get ActiveArchetype(): TaskUiArchetype {
        const tt = this.activeTaskType;
        return ResolveTaskUiArchetype(
            tt ? { Code: tt.Code, Name: tt.Name, IsApproval: tt.IsApproval } : null,
            { TargetValue: this.form.TargetValue },
        );
    }

    public get activeTypeStatuses(): TaskWidgetTypeStatus[] {
        if (!this.form.TypeID) return [];
        const target = this.form.TypeID.toLowerCase();
        return this.allTypeStatuses
            .filter((s) => s.TaskTypeID.toLowerCase() === target)
            .sort((a, b) => a.Sequence - b.Sequence);
    }

    public get availableTagsFiltered(): TagOption[] {
        const selectedIds = new Set(this.selectedTags.map((t) => t.ID));
        return this.allTags.filter((t) => !selectedIds.has(t.ID));
    }

    @HostListener('keydown', ['$event'])
    public onHostKeydown(event: KeyboardEvent): void {
        if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
            event.preventDefault();
            void this.save();
        }
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['TaskID'] || changes['DefaultCategoryID'] || changes['DefaultTypeID'] || changes['DefaultParentID']) {
            void this.init();
        }
    }

    private defaultForm(): TaskEditFormData {
        return {
            Name: '',
            Description: '',
            Status: 'Open',
            Priority: 'Medium',
            StartedAt: null,
            DueAt: null,
            PercentComplete: 0,
            HoursEstimated: null,
            HoursActual: null,
            BlockedReason: '',
            CompletionNotes: '',
            TypeID: this.DefaultTypeID ?? '',
            TaskTypeStatusID: null,
            CategoryID: this.DefaultCategoryID ?? null,
            ParentID: this.DefaultParentID ?? null,
            BaselineValue: null,
            TargetValue: null,
            CurrentValue: null,
            UnitOfMeasure: '',
            MetricDirection: 'Increase',
            PlanningPeriod: '',
            CheckInCadence: 'Weekly',
        };
    }

    private async init(): Promise<void> {
        this.isNew = !this.TaskID;
        this.saveError = null;
        this.draftSubtasks = [];
        this.newSubtaskDraft = '';
        await this.loadLookups();
        if (this.TaskID) {
            await this.loadTask();
        } else {
            this.form = this.defaultForm();
            this.assignees = [];
            this.selectedTags = [];
            this.linkedRecords = [];
            if (!this.form.TypeID && this.taskTypes.length > 0) {
                const general = this.taskTypes.find((t) => t.Code === 'GENERAL') ?? this.taskTypes[0];
                this.form.TypeID = general.ID;
            }
            this.cdr.markForCheck();
        }
    }

    public selectTaskType(tt: TaskTypeOption): void {
        this.form.TypeID = tt.ID;
        if (this.isNew && tt.DefaultPriority) {
            this.form.Priority = tt.DefaultPriority;
        }
        const statuses = this.activeTypeStatuses;
        const defaultStage = statuses.find((s) => s.IsDefault) ?? statuses[0] ?? null;
        this.form.TaskTypeStatusID = defaultStage?.ID ?? null;
        this.cdr.markForCheck();
    }

    public onTypeStatusSelected(statusId: string | null): void {
        if (!statusId) return;
        const match = this.activeTypeStatuses.find((s) => s.ID === statusId);
        if (match) {
            this.form.Status = match.MacroStatus;
        }
    }

    public addDraftSubtask(): void {
        const title = this.newSubtaskDraft.trim();
        if (!title) return;
        this.draftSubtasks = [...this.draftSubtasks, title];
        this.newSubtaskDraft = '';
        this.cdr.markForCheck();
    }

    public removeDraftSubtask(index: number): void {
        this.draftSubtasks = this.draftSubtasks.filter((_, i) => i !== index);
        this.cdr.markForCheck();
    }

    public onLinkedRecordAdded(record: TaskWidgetLinkedRecord): void {
        this.showLinkPicker = false;
        const exists = this.linkedRecords.some(
            (r) => r.EntityName === record.EntityName && r.RecordID.toLowerCase() === record.RecordID.toLowerCase(),
        );
        if (!exists) {
            this.linkedRecords = [...this.linkedRecords, record];
        }
        this.cdr.markForCheck();
    }

    public removeLinkedRecord(index: number): void {
        this.linkedRecords = this.linkedRecords.filter((_, i) => i !== index);
        this.cdr.markForCheck();
    }

    private async loadLookups(): Promise<void> {
        const rv = new RunView();
        const [types, typeStatuses, cats, ppl, rls, tasks, tags] = await Promise.all([
            rv.RunView<TaskTypeOption>({
                EntityName: 'MJ_BizApps_Tasks: Task Types',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<TaskWidgetTypeStatus>({
                EntityName: 'MJ_BizApps_Tasks: Task Type Status',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Categories',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<PersonRow>({
                EntityName: 'MJ_BizApps_Common: People',
                ExtraFilter: this.buildAssigneeScopeFilter(),
                OrderBy: 'FirstName ASC, LastName ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Roles',
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: this.ParentTaskFilter || "Status <> 'Cancelled'",
                OrderBy: 'Name ASC',
                MaxRows: 250,
                ResultType: 'simple',
            }),
            new RunView().RunView<TagOption>({
                EntityName: 'MJ_BizApps_Tasks: Task Tags',
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            }),
        ]);

        const order = ['GENERAL', 'ACTION_ITEM', 'DELIVERABLE', 'APPROVAL_REQUEST', 'KEY_RESULT', 'FOLLOW_UP'];
        this.taskTypes = [...(types?.Results ?? [])].sort((a, b) => {
            const ia = order.indexOf(a.Code);
            const ib = order.indexOf(b.Code);
            if (ia >= 0 && ib >= 0) return ia - ib;
            if (ia >= 0) return -1;
            if (ib >= 0) return 1;
            return a.Name.localeCompare(b.Name);
        });
        this.allTypeStatuses = typeStatuses?.Results ?? [];
        this.categories = cats?.Results ?? [];
        this.people = ppl?.Results ?? [];
        this.roles = rls?.Results ?? [];
        this.mjRoles = (Metadata.Provider.Roles ?? []).map((r) => ({ ID: r.ID, Name: r.Name }));
        this.availableTasks = (tasks?.Results ?? []).filter((t) => t.ID !== this.TaskID);
        this.allTags = tags?.Results ?? [];
        this.peopleEntityID = Metadata.Provider.EntityByName('MJ_BizApps_Common: People')?.ID ?? null;
        this.rolesEntityID = Metadata.Provider.EntityByName(ROLES_ENTITY)?.ID ?? null;
        try {
            await TasksSettings.Load(Metadata.Provider);
            this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(Metadata.Provider);
        } catch {
            this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(Metadata.Provider);
        }
        this.cdr.markForCheck();
    }

    private async loadTask(): Promise<void> {
        if (!this.TaskID) return;
        this.loading = true;
        this.cdr.markForCheck();
        try {
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(this.TaskID));
            this.form = {
                Name: entity.Name ?? '',
                Description: entity.Description ?? '',
                Status: entity.Status,
                Priority: entity.Priority,
                StartedAt: entity.StartedAt ? new Date(entity.StartedAt).toISOString().split('T')[0] : null,
                DueAt: entity.DueAt ? new Date(entity.DueAt).toISOString().split('T')[0] : null,
                PercentComplete: entity.PercentComplete ?? 0,
                HoursEstimated: entity.HoursEstimated,
                HoursActual: entity.HoursActual,
                BlockedReason: entity.BlockedReason ?? '',
                CompletionNotes: entity.CompletionNotes ?? '',
                TypeID: entity.TypeID,
                TaskTypeStatusID: entity.TaskTypeStatusID,
                CategoryID: entity.CategoryID,
                ParentID: entity.ParentID,
                BaselineValue: entity.BaselineValue,
                TargetValue: entity.TargetValue,
                CurrentValue: entity.CurrentValue,
                UnitOfMeasure: entity.UnitOfMeasure ?? '',
                MetricDirection: entity.MetricDirection ?? 'Increase',
                PlanningPeriod: entity.PlanningPeriod ?? '',
                CheckInCadence: entity.CheckInCadence ?? 'Weekly',
            };
            await Promise.all([this.loadExistingAssignees(), this.loadExistingTags(), this.loadExistingLinks()]);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    private async loadExistingAssignees(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<{ ID: string; AssigneeEntityID: string; AssigneeRecordID: string; RoleID: string | null }>({
            EntityName: 'MJ_BizApps_Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
            ResultType: 'simple',
        });
        this.assignees = (result?.Results ?? []).map((a) => {
            const isRole = Boolean(this.rolesEntityID && a.AssigneeEntityID.toLowerCase() === this.rolesEntityID.toLowerCase());
            return {
                AssigneeKind: isRole ? 'role' : 'person',
                AssigneeRecordID: a.AssigneeRecordID,
                DisplayName: '',
                RoleID: a.RoleID ?? '',
                IsNew: false,
                ExistingID: a.ID,
            };
        });
    }

    private async loadExistingTags(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<{ TagID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Tag Links',
            ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
            ResultType: 'simple',
        });
        const tagIDs = new Set((result?.Results ?? []).map((l) => l.TagID.toLowerCase()));
        this.selectedTags = this.allTags.filter((t) => tagIDs.has(t.ID.toLowerCase()));
    }

    private async loadExistingLinks(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<{ EntityID: string; RecordID: string; Description: string | null }>({
            EntityName: 'MJ_BizApps_Tasks: Task Links',
            ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
            ResultType: 'simple',
        });
        this.linkedRecords = (result?.Results ?? []).flatMap((l) => {
            const entity = Metadata.Provider.EntityByID(l.EntityID);
            if (!entity) return [];
            return [
                {
                    EntityName: entity.Name,
                    RecordID: l.RecordID,
                    DisplayName: l.Description || entity.DisplayNameOrName,
                    IconClass: entity.Icon || 'fa-solid fa-link',
                },
            ];
        });
    }

    private buildAssigneeScopeFilter(): string | undefined {
        if (!this.AssigneeScope) return undefined;
        if (Array.isArray(this.AssigneeScope)) {
            const validIDs = this.AssigneeScope.filter((id) => IsValidUUID(id));
            if (validIDs.length === 0) return undefined;
            return `ID IN (${validIDs.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`;
        }
        return this.AssigneeScope;
    }

    public addAssignee(kind: 'person' | 'role' = 'person'): void {
        this.assignees = [
            ...this.assignees,
            {
                AssigneeKind: kind,
                AssigneeRecordID: '',
                DisplayName: '',
                RoleID: this.roles[0]?.ID ?? '',
                IsNew: true,
            },
        ];
        this.cdr.markForCheck();
    }

    public removeAssignee(index: number): void {
        this.assignees = this.assignees.filter((_, i) => i !== index);
        this.cdr.markForCheck();
    }

    public onAssigneePersonChanged(a: AssigneeRow): void {
        const person = this.people.find((p) => p.ID === a.AssigneeRecordID);
        a.DisplayName = person ? `${person.FirstName ?? ''} ${person.LastName ?? ''}`.trim() : '';
    }

    public onTagSelected(event: Event): void {
        const select = event.target as HTMLSelectElement;
        const tagID = select.value;
        if (!tagID) return;
        const tag = this.allTags.find((t) => t.ID === tagID);
        if (tag && !this.selectedTags.some((t) => t.ID === tagID)) {
            this.selectedTags = [...this.selectedTags, tag];
        }
        select.value = '';
        this.cdr.markForCheck();
    }

    public async createAndAddTag(): Promise<void> {
        const name = this.newTagName.trim();
        if (!name || this.creatingTag) return;

        const existing = this.allTags.find((t) => t.Name.toLowerCase() === name.toLowerCase());
        if (existing) {
            if (!this.selectedTags.some((t) => t.ID === existing.ID)) {
                this.selectedTags = [...this.selectedTags, existing];
            }
            this.newTagName = '';
            this.cdr.markForCheck();
            return;
        }

        const palette = ['#0076b6', '#7c3aed', '#16a34a', '#d97706', '#dc2626', '#0891b2'];
        const color = palette[this.allTags.length % palette.length];

        this.creatingTag = true;
        this.cdr.markForCheck();
        try {
            const tag = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskTagEntity>('MJ_BizApps_Tasks: Task Tags');
            tag.NewRecord();
            tag.Name = name;
            tag.ColorCode = color;
            const saved = await tag.Save();
            if (!saved) {
                this.saveError = tag.LatestResult?.CompleteMessage || 'The tag could not be saved.';
                return;
            }
            const created: TagOption = { ID: tag.ID, Name: tag.Name, ColorCode: tag.ColorCode };
            this.allTags = [...this.allTags, created];
            this.selectedTags = [...this.selectedTags, created];
            this.newTagName = '';
        } finally {
            this.creatingTag = false;
            this.cdr.markForCheck();
        }
    }

    public removeTag(tagID: string): void {
        this.selectedTags = this.selectedTags.filter((t) => t.ID !== tagID);
        this.cdr.markForCheck();
    }

    public async save(): Promise<void> {
        if (this.ReadOnly || this.saving || !this.form.Name.trim()) return;

        const before = new BeforeTaskSaveEvent(this.TaskID, { ...this.form });
        this.BeforeSave.emit(before);
        if (before.Cancel) return;

        const hasPersonAssignees = this.assignees.some(
            (row) => (row.AssigneeKind ?? 'person') === 'person' && Boolean(row.AssigneeRecordID || row.PersonID),
        );
        if (!this.peopleEntityID && hasPersonAssignees) {
            this.saveError = 'People is not installed, so assignees cannot be saved.';
            this.cdr.markForCheck();
            return;
        }

        this.saving = true;
        this.saveError = null;
        this.cdr.markForCheck();

        try {
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            if (this.TaskID) {
                const loaded = await entity.InnerLoad(new CompositeKey([{ FieldName: 'ID', Value: this.TaskID }]));
                if (!loaded) {
                    this.saveError = 'Could not load the task for editing.';
                    return;
                }
                await Promise.all([
                    entity.Assignments.Load(true),
                    entity.TagLinks.Load(true),
                    entity.Links.Load(true),
                ]);
            } else {
                entity.NewRecord();
            }

            entity.Name = this.form.Name.trim();
            entity.Description = this.form.Description.trim() || null;
            entity.Status = this.form.Status;
            entity.Priority = this.form.Priority;
            entity.StartedAt = this.form.StartedAt ? new Date(`${this.form.StartedAt}T09:00:00`) : null;
            entity.DueAt = this.form.DueAt ? new Date(`${this.form.DueAt}T17:00:00`) : null;
            entity.PercentComplete = this.form.PercentComplete ?? 0;
            entity.HoursEstimated = this.form.HoursEstimated;
            entity.HoursActual = this.form.HoursActual;
            entity.BlockedReason = this.form.BlockedReason.trim() || null;
            entity.CompletionNotes = this.form.CompletionNotes.trim() || null;
            entity.ParentID = this.form.ParentID;
            if (this.form.TypeID) entity.TypeID = this.form.TypeID;
            entity.TaskTypeStatusID = this.form.TaskTypeStatusID;
            entity.CategoryID = this.form.CategoryID;

            if (this.ActiveArchetype === 'key-result') {
                entity.BaselineValue = this.form.BaselineValue;
                entity.TargetValue = this.form.TargetValue;
                entity.CurrentValue = this.form.CurrentValue;
                entity.UnitOfMeasure = this.form.UnitOfMeasure.trim() || null;
                entity.MetricDirection = this.form.MetricDirection;
                entity.PlanningPeriod = this.form.PlanningPeriod.trim() || null;
                entity.CheckInCadence = this.form.CheckInCadence;
            }

            // Compose Assignments onto entity.Assignments (atomic graph save)
            const retainedExistingIDs = new Set(
                this.assignees
                    .filter((a) => !a.IsNew && a.ExistingID)
                    .map((a) => a.ExistingID!.toLowerCase()),
            );
            for (const existing of [...entity.Assignments.Items]) {
                if (!retainedExistingIDs.has(existing.ID.toLowerCase())) {
                    entity.Assignments.Remove(existing);
                }
            }
            for (const a of this.assignees) {
                const recordID = a.AssigneeRecordID || a.PersonID;
                if (!recordID) continue;
                const entityID = a.AssigneeKind === 'role' ? this.rolesEntityID : this.peopleEntityID;
                if (!entityID) continue;

                if (!a.IsNew && a.ExistingID) {
                    const existing = entity.Assignments.Items.find((item) => UUIDsEqual(item.ID, a.ExistingID));
                    if (existing) {
                        existing.AssigneeEntityID = entityID;
                        existing.AssigneeRecordID = recordID;
                        if (a.RoleID) existing.RoleID = a.RoleID;
                    }
                } else {
                    const assignment = await entity.Assignments.Create();
                    assignment.AssigneeEntityID = entityID;
                    assignment.AssigneeRecordID = recordID;
                    if (a.RoleID) assignment.RoleID = a.RoleID;
                }
            }

            // Compose TagLinks onto entity.TagLinks (atomic graph save)
            const selectedTagIDs = new Set(this.selectedTags.map((t) => t.ID.toLowerCase()));
            for (const existing of [...entity.TagLinks.Items]) {
                if (!selectedTagIDs.has(existing.TagID.toLowerCase())) {
                    entity.TagLinks.Remove(existing);
                }
            }
            for (const tag of this.selectedTags) {
                const alreadyLinked = entity.TagLinks.Items.some((item) => UUIDsEqual(item.TagID, tag.ID));
                if (!alreadyLinked) {
                    const link = await entity.TagLinks.Create();
                    link.TagID = tag.ID;
                }
            }

            // Compose Linked Records onto entity.Links (atomic graph save)
            const desiredLinkKeys = new Set<string>();
            for (const rec of this.linkedRecords) {
                const targetEntity = Metadata.Provider.EntityByName(rec.EntityName);
                if (!targetEntity) continue;
                const key = `${targetEntity.ID.toLowerCase()}|${rec.RecordID.toLowerCase()}`;
                desiredLinkKeys.add(key);
                const already = entity.Links.Items.some(
                    (e) => `${e.EntityID.toLowerCase()}|${e.RecordID.toLowerCase()}` === key,
                );
                if (!already) {
                    const link = await entity.Links.Create();
                    link.EntityID = targetEntity.ID;
                    link.RecordID = rec.RecordID;
                    link.Description = rec.DisplayName;
                }
            }
            for (const existing of [...entity.Links.Items]) {
                const key = `${existing.EntityID.toLowerCase()}|${existing.RecordID.toLowerCase()}`;
                if (!desiredLinkKeys.has(key)) {
                    entity.Links.Remove(existing);
                }
            }

            const taskSaved = await entity.Save();
            if (!taskSaved) {
                this.saveError = entity.LatestResult?.CompleteMessage ?? 'Failed to save task.';
                return;
            }
            const savedID = entity.ID;

            await this.persistDraftSubtasks(savedID);
            this.Saved.emit(savedID);
        } finally {
            this.saving = false;
            this.cdr.markForCheck();
        }
    }

    private async persistDraftSubtasks(parentTaskID: string): Promise<void> {
        if (!this.isNew || this.draftSubtasks.length === 0) return;
        const generalType = this.taskTypes.find((t) => t.Code === 'GENERAL')?.ID ?? this.form.TypeID;
        for (let i = 0; i < this.draftSubtasks.length; i++) {
            const child = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            child.NewRecord();
            child.Name = this.draftSubtasks[i];
            child.ParentID = parentTaskID;
            child.TypeID = generalType;
            child.CategoryID = this.form.CategoryID;
            child.Status = 'Open';
            child.Priority = this.form.Priority;
            child.Sequence = (i + 1) * 10;
            await child.Save();
        }
    }

    public async createRole(roleName: string): Promise<void> {
        const name = roleName.trim();
        if (!name) return;
        const role = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskRoleEntity>('MJ_BizApps_Tasks: Task Roles');
        role.NewRecord();
        role.Name = name;
        if (await role.Save()) {
            this.roles = [...this.roles, { ID: role.ID, Name: role.Name }];
            this.cdr.markForCheck();
        }
    }
}
