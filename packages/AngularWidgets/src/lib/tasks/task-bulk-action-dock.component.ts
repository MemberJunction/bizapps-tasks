import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import type {
    TaskBulkAssigneeMode,
    TaskBulkDateMode,
    TaskBulkNullableRefMode,
    TaskBulkStartDateMode,
} from '@mj-biz-apps/tasks-core';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type {
    TaskBulkActionRequest,
    TaskBulkLookupOption,
    TaskBulkPatch,
    TaskPriorityValue,
    TaskStatusValue,
} from './task-models';

type DockPopoverKind = 'none' | 'reassign' | 'redate' | 'org' | 'more';

/**
 * Asana-grade Floating Bottom Bulk Action Dock (L1 presentational widget).
 *
 * Summoned cleanly at the bottom edge (`safe-area-inset-bottom` aware) whenever
 * the user checks >= 1 task in a list or tree. Supports 1-click macro statuses
 * plus crisp upward popovers for **Reassign** (Person or MJ Role; replace/add/clear),
 * **Redate** (exact date, shift ±N days, or clear), **Organization**, and
 * **More Fields** (Priority, Category, Start Date, Task Type, Workflow Stage, Tag).
 * Emits typed `TaskBulkPatch` payloads executed server-side via `BizAppsTasks.BulkUpdateTasks`.
 */
@Component({
    selector: 'mjt-bulk-action-dock',
    standalone: true,
    imports: [FormsModule],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (SelectedCount > 0) {
            <div class="mjt-bulk-shell" role="region" aria-label="Bulk task actions">
                <!-- Upward Popover Surface -->
                @if (activePopover !== 'none') {
                    <div class="mjt-dock-popover" role="dialog" [attr.aria-label]="popoverTitle">
                        <div class="mjt-pop-head">
                            <span class="mjt-pop-title">{{ popoverTitle }}</span>
                            <button type="button" class="mjt-pop-close" aria-label="Close bulk editor" (click)="closePopover()">
                                <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                            </button>
                        </div>

                        <!-- 1. Reassign Popover -->
                        @if (activePopover === 'reassign') {
                            <div class="mjt-pop-body">
                                <div class="mjt-seg" role="radiogroup" aria-label="Assignment mode">
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="assigneeMode === 'replace'" (click)="assigneeMode = 'replace'">Replace</button>
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="assigneeMode === 'add'" (click)="assigneeMode = 'add'">Add</button>
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="assigneeMode === 'clear'" (click)="assigneeMode = 'clear'">Clear all</button>
                                </div>

                                @if (assigneeMode !== 'clear') {
                                    <div class="mjt-pop-field">
                                        <label>Assignee (Person or MJ Role)</label>
                                        <select class="mjt-pop-input" [(ngModel)]="assigneeChoice">
                                            <option value="">Select person or role...</option>
                                            @if (PeopleOptions.length > 0) {
                                                <optgroup label="People">
                                                    @for (p of PeopleOptions; track p.ID) {
                                                        <option [value]="'person:' + p.ID">{{ p.Label }}</option>
                                                    }
                                                </optgroup>
                                            }
                                            @if (RoleOptions.length > 0) {
                                                <optgroup label="MJ Roles">
                                                    @for (r of RoleOptions; track r.ID) {
                                                        <option [value]="'role:' + r.ID">{{ r.Label }} (Role)</option>
                                                    }
                                                </optgroup>
                                            }
                                        </select>
                                    </div>
                                    @if (TaskRoleOptions.length > 0) {
                                        <div class="mjt-pop-field">
                                            <label>Task Role</label>
                                            <select class="mjt-pop-input" [(ngModel)]="assigneeRoleID">
                                                <option value="">Default (Primary)</option>
                                                @for (tr of TaskRoleOptions; track tr.ID) {
                                                    <option [value]="tr.ID">{{ tr.Label }}</option>
                                                }
                                            </select>
                                        </div>
                                    }
                                }

                                <div class="mjt-pop-actions">
                                    <button
                                        type="button"
                                        class="mjt-pop-primary"
                                        [disabled]="Busy || (assigneeMode !== 'clear' && !assigneeChoice)"
                                        (click)="applyReassign()">
                                        Apply to {{ SelectedCount }}
                                    </button>
                                    <button type="button" class="mjt-pop-secondary" (click)="closePopover()">Cancel</button>
                                </div>
                            </div>
                        }

                        <!-- 2. Redate Popover -->
                        @if (activePopover === 'redate') {
                            <div class="mjt-pop-body">
                                <div class="mjt-seg" role="radiogroup" aria-label="Due date mode">
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="dueDateMode === 'set'" (click)="dueDateMode = 'set'">Set Date</button>
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="dueDateMode === 'shift'" (click)="dueDateMode = 'shift'">Shift ± Days</button>
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="dueDateMode === 'clear'" (click)="dueDateMode = 'clear'">Clear Due</button>
                                </div>

                                @if (dueDateMode === 'set') {
                                    <div class="mjt-pop-field">
                                        <label>New Due Date</label>
                                        <input type="date" class="mjt-pop-input" [(ngModel)]="dueDateStr" />
                                    </div>
                                }

                                @if (dueDateMode === 'shift') {
                                    <div class="mjt-pop-field">
                                        <label>Shift Due &amp; Start Dates by Days</label>
                                        <div class="mjt-preset-row">
                                            @for (d of shiftPresets; track d) {
                                                <button
                                                    type="button"
                                                    class="mjt-preset-pill"
                                                    [class.is-active]="shiftDays === d"
                                                    (click)="shiftDays = d">
                                                    {{ d > 0 ? '+' + d + 'd' : d + 'd' }}
                                                </button>
                                            }
                                        </div>
                                        <input
                                            type="number"
                                            step="1"
                                            class="mjt-pop-input"
                                            [(ngModel)]="shiftDays"
                                            placeholder="Signed days, e.g. +3 or -2" />
                                    </div>
                                }

                                <div class="mjt-pop-actions">
                                    <button
                                        type="button"
                                        class="mjt-pop-primary"
                                        [disabled]="Busy || (dueDateMode === 'set' && !dueDateStr) || (dueDateMode === 'shift' && !shiftDays)"
                                        (click)="applyRedate()">
                                        Apply to {{ SelectedCount }}
                                    </button>
                                    <button type="button" class="mjt-pop-secondary" (click)="closePopover()">Cancel</button>
                                </div>
                            </div>
                        }

                        <!-- 3. Organization Popover -->
                        @if (activePopover === 'org') {
                            <div class="mjt-pop-body">
                                <div class="mjt-seg" role="radiogroup" aria-label="Organization mode">
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="orgMode === 'set'" (click)="orgMode = 'set'">Set Organization</button>
                                    <button type="button" class="mjt-seg-btn" [class.is-active]="orgMode === 'clear'" (click)="orgMode = 'clear'">Clear</button>
                                </div>

                                @if (orgMode === 'set') {
                                    <div class="mjt-pop-field">
                                        <label>Organization / Company</label>
                                        <select class="mjt-pop-input" [(ngModel)]="orgID">
                                            <option value="">Select organization...</option>
                                            @for (org of OrganizationOptions; track org.ID) {
                                                <option [value]="org.ID">{{ org.Label }}{{ org.Sublabel ? ' · ' + org.Sublabel : '' }}</option>
                                            }
                                        </select>
                                    </div>
                                }

                                <div class="mjt-pop-actions">
                                    <button
                                        type="button"
                                        class="mjt-pop-primary"
                                        [disabled]="Busy || (orgMode === 'set' && !orgID)"
                                        (click)="applyOrganization()">
                                        Apply to {{ SelectedCount }}
                                    </button>
                                    <button type="button" class="mjt-pop-secondary" (click)="closePopover()">Cancel</button>
                                </div>
                            </div>
                        }

                        <!-- 4. More Fields Popover -->
                        @if (activePopover === 'more') {
                            <div class="mjt-pop-body mjt-pop-grid">
                                <div class="mjt-pop-field">
                                    <label>Priority</label>
                                    <select class="mjt-pop-input" [(ngModel)]="morePriority">
                                        <option value="">No change</option>
                                        <option value="Critical">Critical</option>
                                        <option value="High">High</option>
                                        <option value="Medium">Medium</option>
                                        <option value="Low">Low</option>
                                    </select>
                                </div>

                                @if (CategoryOptions.length > 0) {
                                    <div class="mjt-pop-field">
                                        <label>Category</label>
                                        <select class="mjt-pop-input" [(ngModel)]="moreCategoryChoice">
                                            <option value="">No change</option>
                                            <option value="__clear__">Clear category</option>
                                            @for (cat of CategoryOptions; track cat.ID) {
                                                <option [value]="cat.ID">{{ cat.Label }}</option>
                                            }
                                        </select>
                                    </div>
                                }

                                <div class="mjt-pop-field">
                                    <label>Start Date</label>
                                    <div class="mjt-inline-pair">
                                        <input type="date" class="mjt-pop-input" [(ngModel)]="moreStartDate" [disabled]="moreClearStartDate" />
                                        <label class="mjt-chk-inline">
                                            <input type="checkbox" [(ngModel)]="moreClearStartDate" /> Clear
                                        </label>
                                    </div>
                                </div>

                                @if (TaskTypeOptions.length > 0) {
                                    <div class="mjt-pop-field">
                                        <label>Task Type</label>
                                        <select class="mjt-pop-input" [(ngModel)]="moreTypeID">
                                            <option value="">No change</option>
                                            @for (tt of TaskTypeOptions; track tt.ID) {
                                                <option [value]="tt.ID">{{ tt.Label }}</option>
                                            }
                                        </select>
                                    </div>
                                }

                                @if (WorkflowStageOptions.length > 0) {
                                    <div class="mjt-pop-field">
                                        <label>Workflow Stage</label>
                                        <select class="mjt-pop-input" [(ngModel)]="moreWorkflowStageID">
                                            <option value="">No change</option>
                                            @for (st of WorkflowStageOptions; track st.ID) {
                                                <option [value]="st.ID">{{ st.Label }}</option>
                                            }
                                        </select>
                                    </div>
                                }

                                @if (TagOptions.length > 0) {
                                    <div class="mjt-pop-field">
                                        <label>Add Tag</label>
                                        <select class="mjt-pop-input" [(ngModel)]="moreAddTagID">
                                            <option value="">No change</option>
                                            @for (tag of TagOptions; track tag.ID) {
                                                <option [value]="tag.ID">{{ tag.Label }}</option>
                                            }
                                        </select>
                                    </div>
                                }

                                <div class="mjt-pop-actions mjt-pop-span-2">
                                    <button
                                        type="button"
                                        class="mjt-pop-primary"
                                        [disabled]="Busy || !hasMoreChanges"
                                        (click)="applyMoreFields()">
                                        Apply Fields to {{ SelectedCount }}
                                    </button>
                                    <button type="button" class="mjt-pop-secondary" (click)="closePopover()">Cancel</button>
                                </div>
                            </div>
                        }
                    </div>
                }

                <!-- Floating Navy Action Bar -->
                <div class="mjt-bulk-dock">
                    <span class="mjt-dock-count mjt-mono">{{ SelectedCount }} selected</span>
                    @if (TotalCount > SelectedCount) {
                        <button
                            type="button"
                            class="mjt-dock-link"
                            [disabled]="Busy"
                            (click)="ActionRequested.emit({ Kind: 'select-all' })">
                            Select all ({{ TotalCount }})
                        </button>
                    }
                    <span class="mjt-dock-sep" aria-hidden="true"></span>

                    <!-- Top 3 Asana Operations: Reassign · Redate · Status -->
                    <button
                        type="button"
                        class="mjt-dock-btn"
                        [class.is-open]="activePopover === 'reassign'"
                        [disabled]="Busy"
                        (click)="togglePopover('reassign')">
                        <i class="fa-solid fa-user-pen" aria-hidden="true"></i> Reassign
                    </button>

                    <button
                        type="button"
                        class="mjt-dock-btn"
                        [class.is-open]="activePopover === 'redate'"
                        [disabled]="Busy"
                        (click)="togglePopover('redate')">
                        <i class="fa-regular fa-calendar" aria-hidden="true"></i> Redate
                    </button>

                    <button type="button" class="mjt-dock-btn" [disabled]="Busy" (click)="emitStatus('InProgress')">
                        <i class="fa-solid fa-play" aria-hidden="true"></i> In Progress
                    </button>
                    <button type="button" class="mjt-dock-btn mjt-dock-btn--success" [disabled]="Busy" (click)="emitStatus('Completed')">
                        <i class="fa-solid fa-check" aria-hidden="true"></i> Complete
                    </button>
                    <button type="button" class="mjt-dock-btn" [disabled]="Busy" (click)="emitStatus('Blocked')">
                        <i class="fa-solid fa-ban" aria-hidden="true"></i> Blocked
                    </button>

                    @if (OrganizationOptions.length > 0) {
                        <button
                            type="button"
                            class="mjt-dock-btn"
                            [class.is-open]="activePopover === 'org'"
                            [disabled]="Busy"
                            (click)="togglePopover('org')">
                            <i class="fa-solid fa-building" aria-hidden="true"></i> Org
                        </button>
                    }

                    <button
                        type="button"
                        class="mjt-dock-btn"
                        [class.is-open]="activePopover === 'more'"
                        [disabled]="Busy"
                        (click)="togglePopover('more')">
                        <i class="fa-solid fa-sliders" aria-hidden="true"></i> More
                    </button>

                    <button
                        type="button"
                        class="mjt-dock-btn mjt-dock-btn--ghost"
                        [disabled]="Busy"
                        aria-label="Clear selection"
                        (click)="closePopover(); ActionRequested.emit({ Kind: 'clear' })">
                        <i class="fa-solid fa-xmark" aria-hidden="true"></i> Clear
                    </button>
                </div>
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-bulk-shell {
            position: fixed;
            bottom: max(16px, env(safe-area-inset-bottom, 0px));
            left: 50%;
            transform: translateX(-50%);
            z-index: 80;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            max-width: calc(100vw - 24px);
        }
        .mjt-dock-popover {
            width: min(460px, calc(100vw - 24px));
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-lg, 12px);
            box-shadow: var(--mj-shadow-xl, 0 20px 30px -8px rgba(0, 0, 0, 0.3));
            overflow: hidden;
        }
        .mjt-pop-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            background: var(--mj-bg-surface-sunken);
            border-bottom: 1px solid var(--mj-border-default);
        }
        .mjt-pop-title {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .mjt-pop-close {
            width: 24px;
            height: 24px;
            border: none;
            border-radius: var(--mj-radius-sm, 4px);
            background: transparent;
            color: var(--mj-text-muted);
            cursor: pointer;
        }
        .mjt-pop-close:hover {
            background: var(--mj-bg-surface-hover);
            color: var(--mj-text-primary);
        }
        .mjt-pop-body {
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mjt-pop-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }
        .mjt-pop-span-2 {
            grid-column: span 2;
        }
        .mjt-seg {
            display: inline-flex;
            gap: 4px;
            padding: 3px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-seg-btn {
            flex: 1;
            padding: 5px 8px;
            border: none;
            border-radius: var(--mj-radius-sm, 6px);
            background: transparent;
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: 12px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-seg-btn.is-active {
            background: var(--mj-brand-primary);
            color: var(--mj-brand-on-primary, #ffffff);
        }
        .mjt-pop-field {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
        }
        .mjt-pop-field label {
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-pop-input {
            width: 100%;
            min-height: 34px;
            padding: 6px 9px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 12.5px;
            box-sizing: border-box;
        }
        .mjt-preset-row {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
            margin-bottom: 4px;
        }
        .mjt-preset-pill {
            padding: 3px 8px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-preset-pill.is-active {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-on-primary, #ffffff);
        }
        .mjt-inline-pair {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .mjt-chk-inline {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11.5px;
            white-space: nowrap;
            cursor: pointer;
        }
        .mjt-pop-actions {
            display: flex;
            align-items: center;
            gap: 8px;
            padding-top: 4px;
        }
        .mjt-pop-primary {
            padding: 6px 14px;
            min-height: 32px;
            border: none;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-brand-primary);
            color: var(--mj-brand-on-primary, #ffffff);
            font-family: inherit;
            font-size: 12px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-pop-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .mjt-pop-secondary {
            padding: 6px 12px;
            min-height: 32px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-md, 8px);
            background: transparent;
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: 12px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-bulk-dock {
            background: var(--mj-brand-secondary, #092340);
            color: var(--mj-brand-on-secondary, #ffffff);
            padding: 7px 14px;
            border-radius: var(--mj-radius-full, 9999px);
            box-shadow: var(--mj-shadow-xl, 0 20px 25px -5px rgba(0, 0, 0, 0.25));
            display: inline-flex;
            align-items: center;
            gap: 5px;
            flex-wrap: nowrap;
            white-space: nowrap;
            justify-content: center;
        }
        @media (max-width: 960px) {
            .mjt-bulk-dock {
                flex-wrap: wrap;
                border-radius: var(--mj-radius-lg, 12px);
            }
        }
        .mjt-dock-count {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            padding: 0 4px;
            white-space: nowrap;
        }
        .mjt-dock-link {
            border: none;
            background: transparent;
            color: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 80%, var(--mj-brand-primary, #38bdf8));
            font-family: inherit;
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            text-decoration: underline;
            cursor: pointer;
            padding: 2px 4px;
            white-space: nowrap;
        }
        .mjt-dock-sep {
            width: 1px;
            height: 16px;
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 25%, transparent);
        }
        .mjt-dock-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 22%, transparent);
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 12%, transparent);
            color: var(--mj-brand-on-secondary, #ffffff);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            transition: background 140ms ease;
            white-space: nowrap;
        }
        .mjt-dock-btn:hover:not(:disabled),
        .mjt-dock-btn.is-open {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
        }
        .mjt-dock-btn--success {
            background: var(--mj-status-success);
            border-color: var(--mj-status-success);
        }
        .mjt-dock-btn--ghost {
            background: transparent;
            border-color: transparent;
            opacity: 0.85;
        }
        .mjt-dock-btn--ghost:hover:not(:disabled) {
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 15%, transparent);
            border-color: transparent;
            opacity: 1;
        }
        @media (max-width: 560px) {
            .mjt-bulk-dock {
                border-radius: var(--mj-radius-lg, 12px);
                padding: 8px 10px;
            }
            .mjt-pop-grid {
                grid-template-columns: minmax(0, 1fr);
            }
            .mjt-pop-span-2 {
                grid-column: span 1;
            }
        }
        `,
    ],
})
export class TaskBulkActionDockComponent {
    @Input() SelectedCount = 0;
    @Input() TotalCount = 0;
    @Input() Busy = false;
    @Input() PeopleOptions: TaskBulkLookupOption[] = [];
    @Input() RoleOptions: TaskBulkLookupOption[] = [];
    @Input() TaskRoleOptions: TaskBulkLookupOption[] = [];
    @Input() OrganizationOptions: TaskBulkLookupOption[] = [];
    @Input() CategoryOptions: TaskBulkLookupOption[] = [];
    @Input() TaskTypeOptions: TaskBulkLookupOption[] = [];
    @Input() WorkflowStageOptions: TaskBulkLookupOption[] = [];
    @Input() TagOptions: TaskBulkLookupOption[] = [];

    @Output() ActionRequested = new EventEmitter<TaskBulkActionRequest>();

    public activePopover: DockPopoverKind = 'none';

    // Reassign state
    public assigneeMode: Exclude<TaskBulkAssigneeMode, 'unchanged'> = 'replace';
    public assigneeChoice = '';
    public assigneeRoleID = '';

    // Redate state
    public dueDateMode: Exclude<TaskBulkDateMode, 'unchanged'> = 'set';
    public dueDateStr = '';
    public shiftDays: number | null = 1;
    public readonly shiftPresets = [-7, -1, 1, 2, 3, 7, 14];

    // Organization state
    public orgMode: Exclude<TaskBulkNullableRefMode, 'unchanged'> = 'set';
    public orgID = '';

    // More fields state
    public morePriority: TaskPriorityValue | '' = '';
    public moreCategoryChoice = '';
    public moreStartDate = '';
    public moreClearStartDate = false;
    public moreTypeID = '';
    public moreWorkflowStageID = '';
    public moreAddTagID = '';

    public get popoverTitle(): string {
        switch (this.activePopover) {
            case 'reassign': return 'Bulk Reassign';
            case 'redate': return 'Bulk Redate';
            case 'org': return 'Bulk Set Organization';
            case 'more': return 'Bulk Update Fields';
            default: return '';
        }
    }

    public get hasMoreChanges(): boolean {
        return Boolean(
            this.morePriority ||
            this.moreCategoryChoice ||
            this.moreStartDate ||
            this.moreClearStartDate ||
            this.moreTypeID ||
            this.moreWorkflowStageID ||
            this.moreAddTagID,
        );
    }

    public togglePopover(kind: Exclude<DockPopoverKind, 'none'>): void {
        this.activePopover = this.activePopover === kind ? 'none' : kind;
    }

    public closePopover(): void {
        this.activePopover = 'none';
    }

    public emitStatus(status: TaskStatusValue): void {
        this.closePopover();
        this.ActionRequested.emit({ Kind: 'status', Status: status });
    }

    public onPriorityChange(event: Event): void {
        const select = event.target as HTMLSelectElement;
        const val = select.value as TaskPriorityValue | '';
        if (!val) return;
        this.ActionRequested.emit({ Kind: 'priority', Priority: val });
        select.value = '';
    }

    public applyReassign(): void {
        if (this.assigneeMode === 'clear') {
            this.ActionRequested.emit({ Kind: 'apply', Patch: { AssigneeMode: 'clear' } });
            this.closePopover();
            return;
        }
        if (!this.assigneeChoice) return;
        const isRole = this.assigneeChoice.startsWith('role:');
        const recordID = this.assigneeChoice.slice(isRole ? 5 : 7);
        const entityName = isRole ? 'MJ: Roles' : 'MJ_BizApps_Common: People';
        const patch: TaskBulkPatch = {
            AssigneeMode: this.assigneeMode,
            AssigneeEntityName: entityName,
            AssigneeRecordID: recordID,
            AssigneeRoleID: this.assigneeRoleID || null,
        };
        this.ActionRequested.emit({ Kind: 'apply', Patch: patch });
        this.assigneeChoice = '';
        this.closePopover();
    }

    public applyRedate(): void {
        if (this.dueDateMode === 'clear') {
            this.ActionRequested.emit({ Kind: 'apply', Patch: { DueDateMode: 'clear' } });
            this.closePopover();
            return;
        }
        if (this.dueDateMode === 'set') {
            if (!this.dueDateStr) return;
            this.ActionRequested.emit({
                Kind: 'apply',
                Patch: { DueDateMode: 'set', DueAt: this.dueDateStr },
            });
            this.dueDateStr = '';
            this.closePopover();
            return;
        }
        if (this.dueDateMode === 'shift' && this.shiftDays && Number.isInteger(this.shiftDays)) {
            this.ActionRequested.emit({
                Kind: 'apply',
                Patch: { DueDateMode: 'shift', ShiftDays: this.shiftDays },
            });
            this.closePopover();
        }
    }

    public applyOrganization(): void {
        if (this.orgMode === 'clear') {
            this.ActionRequested.emit({ Kind: 'apply', Patch: { OrganizationMode: 'clear' } });
            this.closePopover();
            return;
        }
        if (!this.orgID) return;
        this.ActionRequested.emit({
            Kind: 'apply',
            Patch: { OrganizationMode: 'set', OrganizationID: this.orgID },
        });
        this.orgID = '';
        this.closePopover();
    }

    public applyMoreFields(): void {
        if (!this.hasMoreChanges) return;
        const patch: TaskBulkPatch = {};
        if (this.morePriority) patch.Priority = this.morePriority;
        if (this.moreCategoryChoice === '__clear__') {
            patch.CategoryMode = 'clear';
        } else if (this.moreCategoryChoice) {
            patch.CategoryMode = 'set';
            patch.CategoryID = this.moreCategoryChoice;
        }
        if (this.moreClearStartDate) {
            patch.StartDateMode = 'clear' as TaskBulkStartDateMode;
        } else if (this.moreStartDate) {
            patch.StartDateMode = 'set' as TaskBulkStartDateMode;
            patch.StartedAt = this.moreStartDate;
        }
        if (this.moreTypeID) patch.TypeID = this.moreTypeID;
        if (this.moreWorkflowStageID) patch.TaskTypeStatusID = this.moreWorkflowStageID;
        if (this.moreAddTagID) patch.AddTagID = this.moreAddTagID;

        this.ActionRequested.emit({ Kind: 'apply', Patch: patch });
        this.morePriority = '';
        this.moreCategoryChoice = '';
        this.moreStartDate = '';
        this.moreClearStartDate = false;
        this.moreTypeID = '';
        this.moreWorkflowStageID = '';
        this.moreAddTagID = '';
        this.closePopover();
    }
}
