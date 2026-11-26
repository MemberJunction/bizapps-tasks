import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    ContentChild,
    EventEmitter,
    Input,
    Output,
    TemplateRef,
    inject,
} from '@angular/core';
import { DatePipe, NgTemplateOutlet } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import {
    BuildWbsTree,
    ComputeWbsSummary,
    FilterWbsTreePreservingAncestors,
    FlattenVisibleWbsNodes,
    type TaskBadgeDescriptor,
    type TaskWbsFlatRow,
    type TaskWbsNode,
    type TaskWbsSummaryMetrics,
} from '@mj-biz-apps/tasks-core';
import { TaskCompletionRingComponent } from './task-completion-ring.component';
import type {
    TaskStatusValue,
    TaskWbsFilterDef,
    TaskWbsGroup,
    TaskWbsGroupTemplateContext,
    TaskWbsRowTemplateContext,
    TaskWbsRowTone,
    TaskWidgetItem,
} from './task-models';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';

interface BuiltInFilterOption {
    Key: string;
    Label: string;
    Icon?: string;
}

export interface RenderedWbsGroup {
    Group: TaskWbsGroup;
    Tree: TaskWbsNode<TaskWidgetItem>[];
    FilteredTree: TaskWbsNode<TaskWidgetItem>[];
    Rows: TaskWbsFlatRow<TaskWidgetItem>[];
    Summary: TaskWbsSummaryMetrics;
    Expanded: boolean;
}

const BUILTIN_FILTERS: readonly BuiltInFilterOption[] = [
    { Key: 'all', Label: 'All' },
    { Key: 'in-progress', Label: 'In Progress' },
    { Key: 'blocked', Label: 'Blocked' },
    { Key: 'completed', Label: 'Completed' },
];

/**
 * Reusable Hierarchical Work Breakdown Structure (WBS) Tree & Portfolio Accordion (L1/L2 widget).
 *
 * Zero Explorer, Router, or RunView dependencies — styled 100% with `--mj-*` tokens.
 * Supports:
 * - Single-tree mode (`[Tasks]`) and multi-group portfolio accordion mode (`[Groups]`)
 * - Deterministic `1.1.1` WBS numbering, CSS depth tree connectors, and child % rollups
 * - Ancestor-preserving search & filter (built-in status chips + `[CustomFilters]`)
 * - Collapsing ANY ancestor hides ALL descendants (zero orphaned grandchildren)
 * - `Expand All` / `Collapse All`, clickable rows, inline `BlockedReason` callouts
 * - Declarative `[RowBadgeResolver]` / `[RowToneResolver]` AND `@ContentChild` template slots:
 *   `#rowBadges`, `#rowMeta`, `#groupHeaderMeta`, `#groupHeaderActions`, `#groupFooter`
 */
@Component({
    selector: 'mjt-wbs-tree',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [DatePipe, FormsModule, NgTemplateOutlet, MJEmptyStateComponent, TaskCompletionRingComponent],
    template: `
        <div class="mjt-wbs-host">
            @if (ShowToolbar) {
                <div class="mjt-wbs-toolbar">
                    <div class="mjt-wbs-search">
                        <i class="fa-solid fa-magnifying-glass mjt-wbs-search-ic" aria-hidden="true"></i>
                        <input
                            type="text"
                            class="mjt-wbs-search-inp"
                            [(ngModel)]="SearchText"
                            (ngModelChange)="onSearchChange()"
                            placeholder="Filter tasks..."
                            aria-label="Filter WBS tasks" />
                        @if (SearchText) {
                            <button
                                type="button"
                                class="mjt-wbs-clear-btn"
                                aria-label="Clear search"
                                (click)="SearchText = ''; onSearchChange()">
                                <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                            </button>
                        }
                    </div>

                    <div class="mjt-wbs-filters" role="group" aria-label="Task status filters">
                        @for (f of BuiltInFilters; track f.Key) {
                            <button
                                type="button"
                                class="mjt-wbs-chip"
                                [class.is-active]="ActiveFilterKey === f.Key"
                                (click)="SetFilter(f.Key)">
                                {{ f.Label }}
                            </button>
                        }
                        @for (cf of CustomFilters; track cf.Key) {
                            <button
                                type="button"
                                class="mjt-wbs-chip"
                                [class.is-active]="ActiveFilterKey === cf.Key"
                                (click)="SetFilter(cf.Key)">
                                @if (cf.Icon) {
                                    <i [class]="cf.Icon" aria-hidden="true"></i>
                                }
                                {{ cf.Label }}
                            </button>
                        }
                    </div>

                    <div class="mjt-wbs-tree-actions">
                        <button type="button" class="mjt-wbs-act-btn" (click)="ExpandAll()" title="Expand all levels">
                            <i class="fa-solid fa-angles-down" aria-hidden="true"></i>
                            <span>Expand All</span>
                        </button>
                        <button type="button" class="mjt-wbs-act-btn" (click)="CollapseAll()" title="Collapse all levels">
                            <i class="fa-solid fa-angles-up" aria-hidden="true"></i>
                            <span>Collapse All</span>
                        </button>
                    </div>
                </div>
            }

            @if (IsGroupMode) {
                @if (Groups && Groups.length > 1) {
                    <div class="mjt-wbs-group-chips" role="group" aria-label="Filter sections">
                        <button
                            type="button"
                            class="mjt-wbs-chip"
                            [class.is-active]="SelectedGroupID === null"
                            (click)="SetSelectedGroup(null)">
                            All Sections ({{ Groups.length }})
                        </button>
                        @for (g of Groups; track g.ID) {
                            <button
                                type="button"
                                class="mjt-wbs-chip"
                                [class.is-active]="SelectedGroupID === g.ID"
                                [class.is-nested-chip]="g.IsNested"
                                (click)="SetSelectedGroup(g.ID)">
                                {{ g.Title }}
                            </button>
                        }
                    </div>
                }

                @if (RenderedGroups.length === 0) {
                    <mj-empty-state
                        Icon="fa-solid fa-diagram-project"
                        [Title]="EmptyTitle"
                        [Message]="EmptyMessage"
                        Size="compact">
                    </mj-empty-state>
                } @else {
                    <div class="mjt-wbs-groups">
                        @for (rg of RenderedGroups; track rg.Group.ID) {
                            <section class="mjt-wbs-group" [class.is-nested]="rg.Group.IsNested">
                                <header
                                    class="mjt-wbs-group-head"
                                    role="button"
                                    tabindex="0"
                                    [attr.aria-expanded]="rg.Expanded"
                                    (click)="ToggleGroup(rg.Group.ID)"
                                    (keydown.enter)="ToggleGroup(rg.Group.ID)"
                                    (keydown.space)="$event.preventDefault(); ToggleGroup(rg.Group.ID)">
                                    <div class="mjt-wbs-group-left">
                                        <span class="mjt-wbs-group-chev" aria-hidden="true">
                                            <i class="fa-solid" [class.fa-chevron-down]="rg.Expanded" [class.fa-chevron-right]="!rg.Expanded"></i>
                                        </span>
                                        <div class="mjt-wbs-group-titles">
                                            <div class="mjt-wbs-group-title-row">
                                                <h3 class="mjt-wbs-group-title">{{ rg.Group.Title }}</h3>
                                                @if (rg.Group.TagLabel) {
                                                    <span class="mjt-pill mjt-pill--neutral">{{ rg.Group.TagLabel }}</span>
                                                }
                                                <span class="mjt-wbs-group-pct mjt-mono">
                                                    {{ rg.Summary.CompletedCount }}/{{ rg.Summary.TotalCount }} · {{ rg.Summary.OverallCompletionPercent }}%
                                                </span>
                                            </div>
                                            @if (rg.Group.Subtitle) {
                                                <p class="mjt-wbs-group-sub">{{ rg.Group.Subtitle }}</p>
                                            }
                                            @if (EffectiveGroupHeaderMetaTemplate) {
                                                <div class="mjt-wbs-group-meta" (click)="$event.stopPropagation()">
                                                    <ng-container
                                                        *ngTemplateOutlet="
                                                            EffectiveGroupHeaderMetaTemplate;
                                                            context: { $implicit: rg.Group, summary: rg.Summary, expanded: rg.Expanded }
                                                        ">
                                                    </ng-container>
                                                </div>
                                            }
                                        </div>
                                    </div>

                                    @if (EffectiveGroupHeaderActionsTemplate) {
                                        <div class="mjt-wbs-group-actions" (click)="$event.stopPropagation()">
                                            <ng-container
                                                *ngTemplateOutlet="
                                                    EffectiveGroupHeaderActionsTemplate;
                                                    context: { $implicit: rg.Group, summary: rg.Summary, expanded: rg.Expanded }
                                                ">
                                            </ng-container>
                                        </div>
                                    }
                                </header>

                                @if (rg.Expanded) {
                                    <div class="mjt-wbs-group-body">
                                        @if (rg.Rows.length === 0) {
                                            <div class="mjt-wbs-group-empty">No matching tasks in this section.</div>
                                        } @else {
                                            <div class="mjt-wbs-rows" role="tree">
                                                @for (row of rg.Rows; track row.Item.ID) {
                                                    <ng-container *ngTemplateOutlet="rowTemplate; context: { $implicit: row }"></ng-container>
                                                }
                                            </div>
                                        }

                                        @if (EffectiveGroupFooterTemplate) {
                                            <div class="mjt-wbs-group-footer">
                                                <ng-container
                                                    *ngTemplateOutlet="
                                                        EffectiveGroupFooterTemplate;
                                                        context: { $implicit: rg.Group, summary: rg.Summary, expanded: rg.Expanded }
                                                    ">
                                                </ng-container>
                                            </div>
                                        }
                                    </div>
                                }
                            </section>
                        }
                    </div>
                }
            } @else {
                @if (VisibleRows.length === 0) {
                    <mj-empty-state
                        Icon="fa-solid fa-diagram-project"
                        [Title]="EmptyTitle"
                        [Message]="EmptyMessage"
                        Size="compact">
                    </mj-empty-state>
                } @else {
                    @if (EnableBulkSelect && !ReadOnly) {
                        <div class="mjt-wbs-select-strip">
                            <label class="mjt-wbs-select-all">
                                <input
                                    type="checkbox"
                                    [checked]="AllVisibleSelected"
                                    [indeterminate]="SelectedIDs.length > 0 && !AllVisibleSelected"
                                    (change)="ToggleSelectAllVisible()" />
                                <span>{{ SelectedIDs.length > 0 ? SelectedIDs.length + ' of ' + VisibleRows.length + ' selected' : 'Select tasks for bulk actions (Shift+click for range)' }}</span>
                            </label>
                        </div>
                    }
                    <div class="mjt-wbs-rows" role="tree" [class.has-selection]="EnableBulkSelect && SelectedIDs.length > 0">
                        @for (row of VisibleRows; track row.Item.ID) {
                            <ng-container *ngTemplateOutlet="rowTemplate; context: { $implicit: row }"></ng-container>
                        }
                    </div>
                }
            }
        </div>

        <ng-template #rowTemplate let-row>
            @let task = row.Item;
            @let rowTone = resolveRowTone(task);
            @let resolvedBadges = resolveRowBadges(task);
            @let dueDate = resolveDueDate(task);
            @let assigneeList = resolveAssigneeNames(task);
            <div
                class="mjt-wbs-row"
                role="treeitem"
                [attr.aria-level]="row.Depth + 1"
                [attr.aria-expanded]="row.HasChildren ? row.Expanded : null"
                [attr.data-row-tone]="rowTone"
                [class.is-selected]="EnableBulkSelect && IsTaskSelected(task.ID)"
                [class.is-done]="task.Status === 'Completed'"
                [class.is-blocked]="task.Status === 'Blocked'"
                [class.is-parent]="row.HasChildren"
                [style.--mjt-depth]="row.Depth"
                (click)="onRowClick(task)"
                (dblclick)="onRowDoubleClick(task)">
                <div class="mjt-wbs-row-left">
                    @if (EnableBulkSelect && !ReadOnly) {
                        <input
                            type="checkbox"
                            class="mjt-wbs-bulk-chk"
                            [checked]="IsTaskSelected(task.ID)"
                            [attr.aria-label]="'Select ' + task.Name"
                            (click)="OnSelectionCheckboxClick($event, task.ID)" />
                    }

                    @if (ShowTreeConnectors && row.Depth > 0) {
                        <span class="mjt-wbs-guides" aria-hidden="true">
                            @for (lvl of depthGuides(row.Depth); track lvl) {
                                <span class="mjt-wbs-guide-seg"></span>
                            }
                        </span>
                    } @else if (row.Depth > 0) {
                        <span class="mjt-wbs-indent" [style.width.px]="row.Depth * 20" aria-hidden="true"></span>
                    }

                    @if (row.HasChildren) {
                        <button
                            type="button"
                            class="mjt-wbs-exp"
                            [attr.aria-expanded]="row.Expanded"
                            [attr.aria-label]="'Toggle children for ' + task.Name"
                            (click)="$event.stopPropagation(); ToggleNode(task.ID)">
                            <i
                                class="fa-solid"
                                [class.fa-chevron-down]="row.Expanded"
                                [class.fa-chevron-right]="!row.Expanded"
                                aria-hidden="true"></i>
                        </button>
                    } @else {
                        <span class="mjt-wbs-exp-spacer" aria-hidden="true"></span>
                    }

                    @if (!ReadOnly) {
                        <mjt-completion-ring
                            [Status]="asStatus(task.Status)"
                            [TaskName]="task.Name"
                            Size="md"
                            (Toggled)="onRingToggle(task, $event)">
                        </mjt-completion-ring>
                    }

                    @if (ShowWbsCodes) {
                        <span class="mjt-wbs-code mjt-mono">{{ row.WbsCode }}</span>
                    }

                    <div class="mjt-wbs-copy">
                        <div class="mjt-wbs-title-line">
                            @if (ShowTypeBadge && resolveKindLabel(task)) {
                                <span class="mjt-wbs-kind">{{ resolveKindLabel(task) }}</span>
                            }
                            <span class="mjt-wbs-title">{{ task.Name }}</span>

                            @if (EffectiveRowBadgesTemplate) {
                                <span class="mjt-wbs-slot-badges" (click)="$event.stopPropagation()">
                                    <ng-container
                                        *ngTemplateOutlet="
                                            EffectiveRowBadgesTemplate;
                                            context: { $implicit: task, node: row.Node, wbsCode: row.WbsCode, depth: row.Depth }
                                        ">
                                    </ng-container>
                                </span>
                            }

                            @for (badge of resolvedBadges; track badge.Label) {
                                <span
                                    class="mjt-pill"
                                    [class]="'mjt-pill mjt-pill--' + badge.Tone"
                                    [attr.title]="badge.Tooltip || badge.Label">
                                    @if (badge.Icon) {
                                        <i [class]="badge.Icon" aria-hidden="true"></i>
                                    }
                                    <span>{{ badge.Label }}</span>
                                </span>
                            }
                        </div>

                        @if (ShowBlockedReason && task.BlockedReason) {
                            <div class="mjt-wbs-blocked-note" role="note">
                                <i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>
                                <span>{{ task.BlockedReason }}</span>
                            </div>
                        }
                    </div>
                </div>

                <div class="mjt-wbs-row-right">
                    @if (assigneeList.length > 0) {
                        <span class="mjt-wbs-assignee" [title]="assigneeList.join(', ')">
                            <span class="mjt-wbs-avatar">{{ initials(assigneeList[0]) }}</span>
                            <span class="mjt-wbs-assignee-name">{{ shortName(assigneeList[0]) }}</span>
                            @if (assigneeList.length > 1) {
                                <span class="mjt-wbs-assignee-more">+{{ assigneeList.length - 1 }}</span>
                            }
                        </span>
                    }

                    @if (ShowProgressBars) {
                        <div class="mjt-wbs-prog" [title]="row.Node.EffectivePercentComplete + '% complete'">
                            <div class="mjt-wbs-prog-track">
                                <div
                                    class="mjt-wbs-prog-fill"
                                    [class.is-complete]="row.Node.EffectivePercentComplete >= 100"
                                    [style.width.%]="row.Node.EffectivePercentComplete"></div>
                            </div>
                            <span class="mjt-wbs-prog-pct mjt-mono">{{ row.Node.EffectivePercentComplete }}%</span>
                        </div>
                    }

                    @if (dueDate) {
                        <span class="mjt-wbs-due" [class.is-overdue]="isOverdue(dueDate, task.Status)">
                            <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                            <span>{{ dueDate | date:'MMM d' }}</span>
                        </span>
                    }

                    @if (ShowStatusPill) {
                        <span class="mjt-pill" [class]="statusPillClass(task.Status)">
                            {{ statusLabel(task.Status) }}
                        </span>
                    }

                    @if (ShowAddSubtaskAction && !ReadOnly) {
                        <button
                            type="button"
                            class="mjt-wbs-add-sub"
                            [attr.title]="'Add subtask under ' + task.Name"
                            [attr.aria-label]="'Add subtask under ' + task.Name"
                            (click)="$event.stopPropagation(); onAddSubtaskClick(task)">
                            <i class="fa-solid fa-plus" aria-hidden="true"></i>
                        </button>
                    }

                    @if (EffectiveRowMetaTemplate) {
                        <span class="mjt-wbs-slot-meta" (click)="$event.stopPropagation()">
                            <ng-container
                                *ngTemplateOutlet="
                                    EffectiveRowMetaTemplate;
                                    context: { $implicit: task, node: row.Node, wbsCode: row.WbsCode, depth: row.Depth }
                                ">
                            </ng-container>
                        </span>
                    }
                </div>
            </div>
        </ng-template>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-wbs-host {
            display: flex;
            flex-direction: column;
            gap: 10px;
            width: 100%;
            min-width: 0;
        }
        .mjt-wbs-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
        }
        .mjt-wbs-search {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1 1 200px;
            max-width: 300px;
            padding: 6px 10px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
        }
        .mjt-wbs-search:focus-within {
            border-color: var(--mj-border-focus, var(--mj-brand-primary));
            box-shadow: 0 0 0 3px color-mix(in oklab, var(--mj-brand-primary) 16%, transparent);
        }
        .mjt-wbs-search-ic {
            color: var(--mj-text-muted);
            font-size: 12px;
            flex-shrink: 0;
        }
        .mjt-wbs-search-inp {
            border: none;
            outline: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 13.5px);
            width: 100%;
            min-width: 0;
        }
        .mjt-wbs-clear-btn {
            border: none;
            background: transparent;
            color: var(--mj-text-muted);
            cursor: pointer;
            padding: 0 2px;
            font-size: 12px;
        }
        .mjt-wbs-filters,
        .mjt-wbs-group-chips {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-wbs-chip {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease, color 140ms ease;
        }
        .mjt-wbs-chip:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
        }
        .mjt-wbs-chip.is-active {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-inverse);
        }
        .mjt-wbs-chip.is-nested-chip {
            border-style: dashed;
        }
        .mjt-wbs-tree-actions {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-left: auto;
        }
        .mjt-wbs-act-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 9px;
            min-height: 28px;
            border-radius: var(--mj-radius-sm, 6px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: 11.5px;
            font-weight: var(--mj-font-medium, 500);
            cursor: pointer;
        }
        .mjt-wbs-act-btn:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-wbs-groups {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .mjt-wbs-group {
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 10px);
            background: var(--mj-bg-surface);
            overflow: hidden;
        }
        .mjt-wbs-group.is-nested {
            margin-left: 22px;
            border-left: 3px solid var(--mj-brand-primary);
        }
        .mjt-wbs-group-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 12px 14px;
            background: var(--mj-bg-surface-sunken);
            border-bottom: 1px solid var(--mj-border-subtle);
            cursor: pointer;
            flex-wrap: wrap;
        }
        .mjt-wbs-group-head:hover {
            background: var(--mj-bg-surface-hover);
        }
        .mjt-wbs-group-left {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            flex: 1 1 240px;
            min-width: 0;
        }
        .mjt-wbs-group-chev {
            width: 22px;
            height: 22px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: var(--mj-text-muted);
            font-size: 11px;
            flex-shrink: 0;
            margin-top: 2px;
        }
        .mjt-wbs-group-titles {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
            flex: 1;
        }
        .mjt-wbs-group-title-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-wbs-group-title {
            margin: 0;
            font-size: 14.5px;
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-wbs-group-pct {
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            padding: 1px 7px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-wbs-group-sub {
            margin: 0;
            font-size: 12px;
            color: var(--mj-text-secondary);
        }
        .mjt-wbs-group-meta {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 2px;
        }
        .mjt-wbs-group-actions {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-shrink: 0;
        }
        .mjt-wbs-group-body {
            padding: 10px 12px 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mjt-wbs-group-empty {
            padding: 14px;
            text-align: center;
            font-size: 12.5px;
            color: var(--mj-text-muted);
            font-style: italic;
        }
        .mjt-wbs-group-footer {
            padding-top: 8px;
            border-top: 1px solid var(--mj-border-subtle);
        }
        .mjt-wbs-select-strip {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 2px 12px;
        }
        .mjt-wbs-select-all {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 11.5px;
            color: var(--mj-text-muted);
            cursor: pointer;
            user-select: none;
        }
        .mjt-wbs-select-all input {
            accent-color: var(--mj-brand-primary);
            cursor: pointer;
        }
        .mjt-wbs-bulk-chk {
            width: 15px;
            height: 15px;
            accent-color: var(--mj-brand-primary);
            cursor: pointer;
            flex-shrink: 0;
            opacity: 0;
            transition: opacity 140ms ease;
        }
        .mjt-wbs-row:hover .mjt-wbs-bulk-chk,
        .mjt-wbs-row:focus-within .mjt-wbs-bulk-chk,
        .mjt-wbs-rows.has-selection .mjt-wbs-bulk-chk,
        .mjt-wbs-bulk-chk:checked {
            opacity: 1;
        }
        .mjt-wbs-row.is-selected {
            border-color: var(--mj-brand-primary);
            background: var(--mj-surface-base-bg-selected, color-mix(in oklab, var(--mj-brand-primary) 8%, var(--mj-bg-surface)));
        }
        .mjt-wbs-add-sub {
            width: 24px;
            height: 24px;
            border-radius: var(--mj-radius-sm, 6px);
            border: 1px solid transparent;
            background: transparent;
            color: var(--mj-text-muted);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 11px;
            opacity: 0;
            transition: opacity 140ms ease, border-color 140ms ease, background 140ms ease, color 140ms ease;
            flex-shrink: 0;
        }
        .mjt-wbs-row:hover .mjt-wbs-add-sub,
        .mjt-wbs-row:focus-within .mjt-wbs-add-sub,
        .mjt-wbs-add-sub:focus-visible {
            opacity: 1;
        }
        .mjt-wbs-add-sub:hover {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
        }
        .mjt-wbs-rows {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mjt-wbs-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 9px 12px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-wbs-row:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-wbs-row.is-parent {
            background: color-mix(in oklab, var(--mj-bg-surface-sunken) 55%, var(--mj-bg-surface));
        }
        .mjt-wbs-row.is-blocked {
            border-color: var(--mj-status-error-border, color-mix(in oklab, var(--mj-status-error) 36%, var(--mj-border-default)));
        }
        .mjt-wbs-row.is-done .mjt-wbs-title {
            text-decoration: line-through;
            color: var(--mj-text-muted);
        }
        .mjt-wbs-row[data-row-tone="muted"] {
            background: var(--mj-bg-surface-sunken);
        }
        .mjt-wbs-row[data-row-tone="info"] {
            background: color-mix(in oklab, var(--mj-status-info-bg) 55%, var(--mj-bg-surface));
            border-color: color-mix(in oklab, var(--mj-brand-primary) 26%, var(--mj-border-default));
        }
        .mjt-wbs-row[data-row-tone="warning"] {
            background: color-mix(in oklab, var(--mj-status-warning-bg) 55%, var(--mj-bg-surface));
            border-color: color-mix(in oklab, var(--mj-status-warning) 35%, var(--mj-border-default));
        }
        .mjt-wbs-row[data-row-tone="error"] {
            background: color-mix(in oklab, var(--mj-status-error-bg) 55%, var(--mj-bg-surface));
            border-color: color-mix(in oklab, var(--mj-status-error) 35%, var(--mj-border-default));
        }
        .mjt-wbs-row-left {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1 1 260px;
            min-width: 0;
        }
        .mjt-wbs-guides {
            display: inline-flex;
            align-items: stretch;
            align-self: stretch;
            flex-shrink: 0;
        }
        .mjt-wbs-guide-seg {
            width: 20px;
            border-left: 1.5px solid var(--mj-border-default);
            margin-left: 4px;
            position: relative;
        }
        .mjt-wbs-guide-seg:last-child::after {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            width: 10px;
            height: 1.5px;
            background: var(--mj-border-default);
        }
        .mjt-wbs-indent {
            display: inline-block;
            flex-shrink: 0;
        }
        .mjt-wbs-exp {
            width: 22px;
            height: 22px;
            border: none;
            background: transparent;
            color: var(--mj-text-muted);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--mj-radius-sm, 4px);
            flex-shrink: 0;
            font-size: 11px;
        }
        .mjt-wbs-exp:hover {
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
        }
        .mjt-wbs-exp-spacer {
            width: 22px;
            flex-shrink: 0;
        }
        .mjt-wbs-code {
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-muted);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-sm, 4px);
            padding: 1px 6px;
            flex-shrink: 0;
        }
        .mjt-wbs-copy {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
            flex: 1;
        }
        .mjt-wbs-title-line {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-wbs-kind {
            font-size: 10.5px;
            font-weight: var(--mj-font-semibold, 600);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm, 4px);
            background: color-mix(in oklab, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            border: 1px solid color-mix(in oklab, var(--mj-brand-primary) 24%, transparent);
            flex-shrink: 0;
        }
        .mjt-wbs-title {
            font-size: var(--mj-text-sm, 13.5px);
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary);
            line-height: 1.35;
        }
        .mjt-wbs-row.is-parent .mjt-wbs-title {
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-wbs-slot-badges,
        .mjt-wbs-slot-meta {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            flex-wrap: wrap;
        }
        .mjt-wbs-blocked-note {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 3px 8px;
            border-radius: var(--mj-radius-sm, 5px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            font-size: 11.5px;
            line-height: 1.35;
            width: fit-content;
            max-width: 100%;
        }
        .mjt-wbs-row-right {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            flex-wrap: wrap;
            flex-shrink: 0;
        }
        .mjt-wbs-assignee {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 2px 8px 2px 3px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            font-size: 11.5px;
            color: var(--mj-text-secondary);
            white-space: nowrap;
        }
        .mjt-wbs-avatar {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: color-mix(in oklab, var(--mj-brand-primary) 16%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            font-size: 9.5px;
            font-weight: var(--mj-font-bold, 700);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .mjt-wbs-assignee-name {
            max-width: 112px;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .mjt-wbs-assignee-more {
            font-size: 10.5px;
            color: var(--mj-text-muted);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-wbs-prog {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            min-width: 84px;
        }
        .mjt-wbs-prog-track {
            width: 48px;
            height: 5px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken);
            overflow: hidden;
            flex-shrink: 0;
        }
        .mjt-wbs-prog-fill {
            height: 100%;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-brand-primary);
        }
        .mjt-wbs-prog-fill.is-complete {
            background: var(--mj-status-success);
        }
        .mjt-wbs-prog-pct {
            font-size: 11px;
            color: var(--mj-text-secondary);
            min-width: 30px;
            text-align: right;
        }
        .mjt-wbs-due {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11.5px;
            color: var(--mj-text-muted);
            white-space: nowrap;
        }
        .mjt-wbs-due.is-overdue {
            color: var(--mj-status-error-text);
            font-weight: var(--mj-font-semibold, 600);
        }
        @media (max-width: 720px) {
            .mjt-wbs-select-strip,
            .mjt-wbs-bulk-chk {
                display: none;
            }
            .mjt-wbs-add-sub {
                opacity: 1;
            }
            .mjt-wbs-row {
                flex-direction: column;
                align-items: stretch;
                gap: 8px;
            }
            .mjt-wbs-row-right {
                justify-content: flex-start;
                padding-left: 28px;
            }
            .mjt-wbs-group.is-nested {
                margin-left: 10px;
            }
        }
        `,
    ],
})
export class TaskWbsTreeComponent {
    @Input() Tasks: readonly TaskWidgetItem[] = [];
    @Input() Groups: readonly TaskWbsGroup[] | null = null;
    @Input() ShowWbsCodes = true;
    @Input() ShowTreeConnectors = true;
    @Input() ShowProgressBars = true;
    @Input() ShowStatusPill = true;
    @Input() ShowTypeBadge = true;
    @Input() ShowBlockedReason = true;
    @Input() ShowToolbar = true;
    @Input() CustomFilters: readonly TaskWbsFilterDef[] = [];
    @Input() ReadOnly = false;
    @Input() EnableBulkSelect = false;
    @Input() SelectedIDs: readonly string[] = [];
    @Input() ShowAddSubtaskAction = false;
    @Input() RowBadgeResolver: ((task: TaskWidgetItem) => readonly TaskBadgeDescriptor[]) | null = null;
    @Input() RowToneResolver: ((task: TaskWidgetItem) => TaskWbsRowTone) | null = null;
    @Input() EmptyTitle = 'No tasks match your filter';
    @Input() EmptyMessage = 'Clear filters or add a task to get started.';

    /** Optional forwarded templates for wrapper components (e.g. `<bizapps-task-panel>`). */
    @Input() RowBadgesTemplate: TemplateRef<TaskWbsRowTemplateContext> | null = null;
    @Input() RowMetaTemplate: TemplateRef<TaskWbsRowTemplateContext> | null = null;
    @Input() GroupHeaderMetaTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;
    @Input() GroupHeaderActionsTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;
    @Input() GroupFooterTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;

    @ContentChild('rowBadges') public contentRowBadges?: TemplateRef<TaskWbsRowTemplateContext>;
    @ContentChild('rowMeta') public contentRowMeta?: TemplateRef<TaskWbsRowTemplateContext>;
    @ContentChild('groupHeaderMeta') public contentGroupHeaderMeta?: TemplateRef<TaskWbsGroupTemplateContext>;
    @ContentChild('groupHeaderActions') public contentGroupHeaderActions?: TemplateRef<TaskWbsGroupTemplateContext>;
    @ContentChild('groupFooter') public contentGroupFooter?: TemplateRef<TaskWbsGroupTemplateContext>;

    @Output() TaskClicked = new EventEmitter<TaskWidgetItem>();
    @Output() TaskDoubleClicked = new EventEmitter<TaskWidgetItem>();
    @Output() StatusToggled = new EventEmitter<{ TaskID: string; NewStatus: TaskStatusValue }>();
    @Output() CreateTaskRequested = new EventEmitter<{ GroupID?: string; ParentTaskID?: string }>();
    @Output() SelectedIDsChange = new EventEmitter<string[]>();

    public readonly BuiltInFilters = BUILTIN_FILTERS;
    public SearchText = '';
    public ActiveFilterKey = 'all';
    public SelectedGroupID: string | null = null;
    public CollapsedNodeIDs = new Set<string>();
    public CollapsedGroupIDs = new Set<string>();

    private lastCheckedTaskID: string | null = null;
    private cdr = inject(ChangeDetectorRef, { optional: true });

    public get IsGroupMode(): boolean {
        return this.Groups != null;
    }

    public get EffectiveRowBadgesTemplate(): TemplateRef<TaskWbsRowTemplateContext> | null {
        return this.contentRowBadges ?? this.RowBadgesTemplate ?? null;
    }

    public get EffectiveRowMetaTemplate(): TemplateRef<TaskWbsRowTemplateContext> | null {
        return this.contentRowMeta ?? this.RowMetaTemplate ?? null;
    }

    public get EffectiveGroupHeaderMetaTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupHeaderMeta ?? this.GroupHeaderMetaTemplate ?? null;
    }

    public get EffectiveGroupHeaderActionsTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupHeaderActions ?? this.GroupHeaderActionsTemplate ?? null;
    }

    public get EffectiveGroupFooterTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupFooter ?? this.GroupFooterTemplate ?? null;
    }

    public get IsFilteringActive(): boolean {
        return this.SearchText.trim().length > 0 || this.ActiveFilterKey !== 'all';
    }

    public get SingleTree(): TaskWbsNode<TaskWidgetItem>[] {
        return BuildWbsTree(this.Tasks ?? []);
    }

    public get VisibleRows(): TaskWbsFlatRow<TaskWidgetItem>[] {
        const tree = this.SingleTree;
        const filtered = this.IsFilteringActive
            ? FilterWbsTreePreservingAncestors(tree, (item) => this.matchesActiveFilter(item))
            : tree;
        return FlattenVisibleWbsNodes(filtered, this.CollapsedNodeIDs, this.IsFilteringActive);
    }

    public get RenderedGroups(): RenderedWbsGroup[] {
        const groups = this.Groups ?? [];
        const selected = this.SelectedGroupID;
        const scoped = selected ? groups.filter((g) => g.ID === selected) : groups;
        const filtering = this.IsFilteringActive;

        const out: RenderedWbsGroup[] = [];
        for (const group of scoped) {
            const tree = BuildWbsTree(group.Tasks ?? []);
            const summary = ComputeWbsSummary(tree);
            const filteredTree = filtering
                ? FilterWbsTreePreservingAncestors(tree, (item) => this.matchesActiveFilter(item))
                : tree;
            if (filtering && filteredTree.length === 0) {
                continue;
            }
            const expanded = filtering || !this.CollapsedGroupIDs.has(group.ID.toLowerCase());
            const rows = FlattenVisibleWbsNodes(filteredTree, this.CollapsedNodeIDs, filtering);
            out.push({
                Group: group,
                Tree: tree,
                FilteredTree: filteredTree,
                Rows: rows,
                Summary: summary,
                Expanded: expanded,
            });
        }
        return out;
    }

    public SetFilter(key: string): void {
        this.ActiveFilterKey = key || 'all';
        this.cdr?.markForCheck();
    }

    public SetSelectedGroup(groupId: string | null): void {
        this.SelectedGroupID = groupId;
        this.cdr?.markForCheck();
    }

    public onSearchChange(): void {
        this.cdr?.markForCheck();
    }

    public ToggleNode(taskId: string): void {
        const key = taskId.toLowerCase();
        if (this.CollapsedNodeIDs.has(key)) {
            this.CollapsedNodeIDs.delete(key);
        } else {
            this.CollapsedNodeIDs.add(key);
        }
        this.cdr?.markForCheck();
    }

    public ToggleGroup(groupId: string): void {
        const key = groupId.toLowerCase();
        if (this.CollapsedGroupIDs.has(key)) {
            this.CollapsedGroupIDs.delete(key);
        } else {
            this.CollapsedGroupIDs.add(key);
        }
        this.cdr?.markForCheck();
    }

    public ExpandAll(): void {
        this.CollapsedNodeIDs.clear();
        this.CollapsedGroupIDs.clear();
        this.cdr?.markForCheck();
    }

    public CollapseAll(): void {
        const collectParents = (nodes: readonly TaskWbsNode<TaskWidgetItem>[]): void => {
            for (const n of nodes) {
                if (n.Children.length > 0) {
                    this.CollapsedNodeIDs.add(n.Item.ID.toLowerCase());
                    collectParents(n.Children);
                }
            }
        };

        if (this.IsGroupMode) {
            for (const g of this.Groups ?? []) {
                this.CollapsedGroupIDs.add(g.ID.toLowerCase());
                collectParents(BuildWbsTree(g.Tasks ?? []));
            }
        } else {
            collectParents(this.SingleTree);
        }
        this.cdr?.markForCheck();
    }

    public matchesActiveFilter(task: TaskWidgetItem): boolean {
        const q = this.SearchText.trim().toLowerCase();
        if (q) {
            const haystacks = [
                task.Name,
                task.Description ?? '',
                task.BlockedReason ?? '',
                task.OrganizationName ?? '',
                task.KindLabel ?? '',
                task.TaskTypeName ?? task.TypeName ?? '',
                ...this.resolveAssigneeNames(task),
            ];
            const matchesQuery = haystacks.some((h) => h.toLowerCase().includes(q));
            if (!matchesQuery) return false;
        }

        if (this.ActiveFilterKey === 'all' || !this.ActiveFilterKey) {
            return true;
        }
        if (this.ActiveFilterKey === 'in-progress') {
            return task.Status === 'InProgress';
        }
        if (this.ActiveFilterKey === 'blocked') {
            return task.Status === 'Blocked';
        }
        if (this.ActiveFilterKey === 'completed') {
            return task.Status === 'Completed';
        }
        const custom = (this.CustomFilters ?? []).find((f) => f.Key === this.ActiveFilterKey);
        if (custom) {
            return custom.Predicate(task);
        }
        return true;
    }

    public depthGuides(depth: number): number[] {
        const out: number[] = [];
        for (let i = 0; i < depth; i++) {
            out.push(i);
        }
        return out;
    }

    public resolveRowBadges(task: TaskWidgetItem): readonly TaskBadgeDescriptor[] {
        return this.RowBadgeResolver ? this.RowBadgeResolver(task) : [];
    }

    public resolveRowTone(task: TaskWidgetItem): TaskWbsRowTone {
        return this.RowToneResolver ? this.RowToneResolver(task) : 'default';
    }

    public resolveKindLabel(task: TaskWidgetItem): string | null {
        return task.KindLabel || task.TaskTypeName || task.TypeName || null;
    }

    public resolveDueDate(task: TaskWidgetItem): Date | string | null {
        return task.DueAt ?? task.DueDate ?? null;
    }

    public resolveAssigneeNames(task: TaskWidgetItem): string[] {
        if (task.AssigneeNames && task.AssigneeNames.length > 0) {
            return [...task.AssigneeNames];
        }
        if (task.Assignees && task.Assignees.length > 0) {
            return task.Assignees.map((a) => a.DisplayName).filter(Boolean);
        }
        return [];
    }

    public isOverdue(due: Date | string | null, status: string): boolean {
        if (!due || status === 'Completed' || status === 'Cancelled') return false;
        const d = due instanceof Date ? due : new Date(due);
        return !Number.isNaN(d.getTime()) && d.getTime() < Date.now();
    }

    public asStatus(status: string): TaskStatusValue {
        if (status === 'Open' || status === 'InProgress' || status === 'Blocked' || status === 'Completed' || status === 'Cancelled') {
            return status;
        }
        return 'Open';
    }

    public statusLabel(status: string): string {
        switch (status) {
            case 'InProgress':
                return 'In Progress';
            case 'Blocked':
                return 'Blocked';
            case 'Completed':
                return 'Completed';
            case 'Cancelled':
                return 'Cancelled';
            default:
                return 'Open';
        }
    }

    public statusPillClass(status: string): string {
        switch (status) {
            case 'Completed':
                return 'mjt-pill mjt-pill--success';
            case 'InProgress':
                return 'mjt-pill mjt-pill--info';
            case 'Blocked':
                return 'mjt-pill mjt-pill--error';
            default:
                return 'mjt-pill mjt-pill--neutral';
        }
    }

    public initials(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length === 0) return '?';
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    public shortName(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length <= 1) return name.trim();
        return `${parts[0]} ${parts[parts.length - 1][0]}.`;
    }

    public get AllVisibleSelected(): boolean {
        const visibleIds = this.GetVisibleTaskIDs();
        return visibleIds.length > 0 && visibleIds.every((id) => this.IsTaskSelected(id));
    }

    public GetVisibleTaskIDs(): string[] {
        if (this.IsGroupMode) {
            const ids: string[] = [];
            const seen = new Set<string>();
            for (const rg of this.RenderedGroups) {
                for (const row of rg.Rows) {
                    const key = row.Item.ID.toLowerCase();
                    if (!seen.has(key)) {
                        seen.add(key);
                        ids.push(row.Item.ID);
                    }
                }
            }
            return ids;
        }
        return this.VisibleRows.map((row) => row.Item.ID);
    }

    public IsTaskSelected(taskId: string): boolean {
        const target = taskId.toLowerCase();
        return (this.SelectedIDs ?? []).some((id) => id.toLowerCase() === target);
    }

    public OnSelectionCheckboxClick(event: MouseEvent, taskId: string): void {
        event.stopPropagation();
        if (!this.EnableBulkSelect || this.ReadOnly) return;

        if (event.shiftKey && this.lastCheckedTaskID) {
            const visibleIds = this.GetVisibleTaskIDs();
            const fromIdx = visibleIds.findIndex((id) => id.toLowerCase() === this.lastCheckedTaskID?.toLowerCase());
            const toIdx = visibleIds.findIndex((id) => id.toLowerCase() === taskId.toLowerCase());
            if (fromIdx >= 0 && toIdx >= 0) {
                const start = Math.min(fromIdx, toIdx);
                const end = Math.max(fromIdx, toIdx);
                const existingSet = new Set((this.SelectedIDs ?? []).map((id) => id.toLowerCase()));
                const merged = [...(this.SelectedIDs ?? [])];
                for (let i = start; i <= end; i++) {
                    const id = visibleIds[i];
                    const norm = id.toLowerCase();
                    if (!existingSet.has(norm)) {
                        existingSet.add(norm);
                        merged.push(id);
                    }
                }
                this.SelectedIDs = merged;
                this.lastCheckedTaskID = taskId;
                this.SelectedIDsChange.emit([...merged]);
                this.cdr?.markForCheck();
                return;
            }
        }

        this.ToggleTaskSelection(taskId);
        this.lastCheckedTaskID = taskId;
    }

    public ToggleTaskSelection(taskId: string): void {
        if (!this.EnableBulkSelect || this.ReadOnly) return;
        const target = taskId.toLowerCase();
        const current = this.SelectedIDs ?? [];
        const next = this.IsTaskSelected(taskId)
            ? current.filter((id) => id.toLowerCase() !== target)
            : [...current, taskId];
        this.SelectedIDs = next;
        this.SelectedIDsChange.emit([...next]);
        this.cdr?.markForCheck();
    }

    public ToggleSelectAllVisible(): void {
        if (!this.EnableBulkSelect || this.ReadOnly) return;
        const next = this.AllVisibleSelected ? [] : this.GetVisibleTaskIDs();
        this.SelectedIDs = next;
        this.SelectedIDsChange.emit([...next]);
        this.cdr?.markForCheck();
    }

    public onAddSubtaskClick(task: TaskWidgetItem): void {
        if (this.ReadOnly) return;
        this.CreateTaskRequested.emit({ ParentTaskID: task.ID });
    }

    public onRowClick(task: TaskWidgetItem): void {
        this.TaskClicked.emit(task);
    }

    public onRowDoubleClick(task: TaskWidgetItem): void {
        this.TaskDoubleClicked.emit(task);
    }

    public onRingToggle(task: TaskWidgetItem, nextStatus: TaskStatusValue): void {
        if (this.ReadOnly) return;
        this.StatusToggled.emit({ TaskID: task.ID, NewStatus: nextStatus });
    }
}
