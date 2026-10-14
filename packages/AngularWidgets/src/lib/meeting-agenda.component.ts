import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { formatMinutes } from './format';
import type { AgendaItemDraft, AgendaItemModel, AgendaItemTypeOption, PersonOption } from './types';

export interface AgendaReorder {
    /** The item ids of one parent, in their new order. */
    parentId: string | null;
    orderedIds: string[];
}

export interface AgendaMove {
    item: AgendaItemModel;
    parentId: string | null;
}

/** The agenda's items in reading order with their depth, built from the flat list. */
export function agendaTree(items: readonly AgendaItemModel[]): Array<{ item: AgendaItemModel; depth: number }> {
    const ids = new Set(items.map((i) => i.id.toLowerCase()));
    const children = new Map<string, AgendaItemModel[]>();
    const roots: AgendaItemModel[] = [];
    for (const item of items) {
        const parent = item.parentId?.toLowerCase();
        if (parent && ids.has(parent) && parent !== item.id.toLowerCase()) {
            const list = children.get(parent) ?? [];
            list.push(item);
            children.set(parent, list);
        } else roots.push(item);
    }
    const bySequence = (a: AgendaItemModel, b: AgendaItemModel): number => a.sequence - b.sequence || a.name.localeCompare(b.name);
    const out: Array<{ item: AgendaItemModel; depth: number }> = [];
    const seen = new Set<string>();
    const walk = (list: AgendaItemModel[], depth: number): void => {
        for (const item of list.sort(bySequence)) {
            if (seen.has(item.id.toLowerCase())) continue;
            seen.add(item.id.toLowerCase());
            out.push({ item, depth });
            walk(children.get(item.id.toLowerCase()) ?? [], depth + 1);
        }
    };
    walk(roots, 0);
    return out;
}

/** The agenda's length: top-level durations, or the sub-items' where the parent has none. */
export function agendaMinutes(items: readonly AgendaItemModel[]): number {
    const children = new Map<string, AgendaItemModel[]>();
    for (const item of items) {
        if (!item.parentId) continue;
        const list = children.get(item.parentId.toLowerCase()) ?? [];
        list.push(item);
        children.set(item.parentId.toLowerCase(), list);
    }
    const minutesOf = (item: AgendaItemModel): number =>
        item.durationMinutes != null ? item.durationMinutes : (children.get(item.id.toLowerCase()) ?? []).reduce((sum, child) => sum + minutesOf(child), 0);
    return items.filter((item) => !item.parentId).reduce((sum, item) => sum + minutesOf(item), 0);
}

const STATUS_CLASS: Record<AgendaItemModel['status'], string> = {
    Planned: 'mjt-chip',
    InProgress: 'mjt-chip mjt-chip--info',
    Done: 'mjt-chip mjt-chip--ok',
    Deferred: 'mjt-chip mjt-chip--warn',
    Skipped: 'mjt-chip mjt-chip--error',
};

/**
 * The agenda builder (the meetings plan, § 5): items in order with nesting, a type, a presenter and a duration; move up,
 * down, in and out; add, edit, remove; durations added up against the meeting's length; the type's template on request.
 * The host saves what is asked.
 */
@Component({
    selector: 'bizapps-meeting-agenda',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow">
                <span class="mjt-strong">Agenda</span>
                <span class="mjt-small" [class.over]="IsOver" [class.mjt-muted]="!IsOver"> {{ TotalLabel }}@if (MeetingMinutes) { of {{ MeetingLabel }}}@if (IsOver) { · over by {{ OverLabel }}}</span>
            </div>
            @if (CanEdit && !draft) {
                @if (HasTemplate && !Items.length) {
                    <button mjButton Variant="secondary" Size="sm" [disabled]="Busy" (click)="TemplateRequested.emit()"><i class="fa-solid fa-wand-magic-sparkles"></i>Use the type's template</button>
                }
                <button mjButton Variant="primary" Size="sm" [disabled]="Busy" (click)="openDraft(null, null)"><i class="fa-solid fa-plus"></i>Add item</button>
            }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (draft; as d) {
            <form class="editor" (ngSubmit)="submit()" aria-label="Agenda item">
                <div class="mjt-row wrap">
                    <label class="mjt-grow"><span class="mjt-label">Title</span><input class="mjt-input" name="name" [(ngModel)]="d.name" required maxlength="500" autocomplete="off" /></label>
                    <label><span class="mjt-label">Type</span>
                        <select class="mjt-select" name="type" [(ngModel)]="d.typeId" (ngModelChange)="typeChosen(d)">
                            <option [ngValue]="null">—</option>
                            @for (type of ItemTypes; track type.id) { <option [ngValue]="type.id">{{ type.name }}</option> }
                        </select>
                    </label>
                    <label><span class="mjt-label">Presenter</span>
                        <select class="mjt-select" name="presenter" [(ngModel)]="d.presenterPersonId">
                            <option [ngValue]="null">—</option>
                            @for (person of People; track person.id) { <option [ngValue]="person.id">{{ person.name }}</option> }
                        </select>
                    </label>
                    <label class="minutes"><span class="mjt-label">Minutes</span><input class="mjt-input" name="minutes" type="number" min="0" step="5" [(ngModel)]="d.durationMinutes" /></label>
                </div>
                <label><span class="mjt-label">Notes for the item</span><textarea class="mjt-textarea" name="description" rows="2" [(ngModel)]="d.description"></textarea></label>
                <div class="mjt-row">
                    @if (d.parentId) { <span class="mjt-small mjt-muted">Under: {{ nameOf(d.parentId) }}</span> }
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="draft = null">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || !d.name.trim()">{{ d.id ? 'Save' : 'Add' }}</button>
                </div>
            </form>
        }
        @if (!Items.length && !draft) {
            <div class="mjt-empty">No agenda yet.@if (CanEdit) { Add an item, or start from the type's template.}</div>
        }
        <ol class="items" aria-label="Agenda">
            @for (entry of Tree; track entry.item.id; let index = $index) {
                <li class="item" [class.active]="ActiveItemID && ActiveItemID.toLowerCase() === entry.item.id.toLowerCase()" [style.margin-left.px]="entry.depth * 24">
                    <div class="order mjt-muted mjt-small">{{ numberOf(entry.item) }}</div>
                    <div class="mjt-grow">
                        <div class="mjt-row wrap">
                            <span class="name">{{ entry.item.name }}</span>
                            @if (entry.item.typeName) { <span class="mjt-chip">{{ entry.item.typeName }}</span> }
                            @if (entry.item.status !== 'Planned') { <span [class]="StatusClass[entry.item.status]">{{ entry.item.status === 'InProgress' ? 'In progress' : entry.item.status }}</span> }
                        </div>
                        <div class="mjt-small mjt-muted">
                            @if (entry.item.presenterName) { {{ entry.item.presenterName }} · }{{ durationOf(entry.item) }}
                        </div>
                        @if (entry.item.outcome) { <div class="outcome"><i class="fa-solid fa-flag-checkered" aria-hidden="true"></i> {{ entry.item.outcome }}</div> }
                    </div>
                    @if (CanEdit && !draft) {
                        <div class="tools">
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy || !canMoveUp(entry.item)" aria-label="Move up" title="Move up" (click)="move(entry.item, -1)"><i class="fa-solid fa-arrow-up" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy || !canMoveDown(entry.item)" aria-label="Move down" title="Move down" (click)="move(entry.item, 1)"><i class="fa-solid fa-arrow-down" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy || !canIndent(entry.item)" aria-label="Make a sub-item" title="Make a sub-item of the one above" (click)="indent(entry.item)"><i class="fa-solid fa-indent" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy || !entry.item.parentId" aria-label="Move out" title="Move out one level" (click)="outdent(entry.item)"><i class="fa-solid fa-outdent" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Add a sub-item" title="Add a sub-item" (click)="openDraft(null, entry.item.id)"><i class="fa-solid fa-plus" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Edit" title="Edit" (click)="openDraft(entry.item, entry.item.parentId)"><i class="fa-solid fa-pen" aria-hidden="true"></i></button>
                            <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Remove" title="Remove" (click)="RemoveRequested.emit(entry.item)"><i class="fa-solid fa-trash" aria-hidden="true"></i></button>
                        </div>
                    }
                </li>
            }
        </ol>
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 8px; flex-wrap: wrap; }
        .over { color: var(--mjt-error-text); font-weight: 600; }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .editor { display: flex; flex-direction: column; gap: 10px; padding: 12px; border: 1px dashed var(--mjt-border-strong); border-radius: var(--mjt-radius-lg); margin-bottom: 10px; }
        .minutes { width: 90px; }
        .items { list-style: none; margin: 0; padding: 0; }
        .item { display: flex; align-items: flex-start; gap: 10px; padding: 10px 12px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); margin-bottom: 6px; color: var(--mjt-text); }
        .item.active { border-color: var(--mjt-brand); box-shadow: 0 0 0 1px var(--mjt-brand) inset; }
        .order { min-width: 28px; padding-top: 2px; }
        .name { font-weight: 600; }
        .outcome { margin-top: 4px; font-size: 13px; padding: 6px 10px; background: var(--mjt-ok-bg); color: var(--mjt-ok-text); border-radius: var(--mjt-radius); }
        .tools { display: flex; flex-wrap: wrap; gap: 2px; }
    `],
})
export class MeetingAgendaComponent {
    @Input() Items: AgendaItemModel[] = [];
    @Input() ItemTypes: AgendaItemTypeOption[] = [];
    @Input() People: PersonOption[] = [];
    @Input() MeetingMinutes: number | null = null;
    @Input() HasTemplate = false;
    @Input() CanEdit = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Input() ActiveItemID: string | null = null;
    @Output() SaveRequested = new EventEmitter<AgendaItemDraft>();
    @Output() RemoveRequested = new EventEmitter<AgendaItemModel>();
    @Output() ReorderRequested = new EventEmitter<AgendaReorder>();
    @Output() MoveRequested = new EventEmitter<AgendaMove>();
    @Output() TemplateRequested = new EventEmitter<void>();

    public draft: AgendaItemDraft | null = null;
    public readonly StatusClass = STATUS_CLASS;

    public get Tree(): Array<{ item: AgendaItemModel; depth: number }> {
        return agendaTree(this.Items);
    }

    public get TotalMinutes(): number {
        return agendaMinutes(this.Items);
    }

    public get TotalLabel(): string {
        return formatMinutes(this.TotalMinutes);
    }

    public get MeetingLabel(): string {
        return formatMinutes(this.MeetingMinutes);
    }

    public get IsOver(): boolean {
        return !!this.MeetingMinutes && this.TotalMinutes > this.MeetingMinutes;
    }

    public get OverLabel(): string {
        return formatMinutes(this.TotalMinutes - (this.MeetingMinutes ?? 0));
    }

    public openDraft(item: AgendaItemModel | null, parentId: string | null): void {
        this.draft = item
            ? { id: item.id, parentId: item.parentId, name: item.name, description: item.description ?? '', typeId: item.typeId, presenterPersonId: item.presenterPersonId, durationMinutes: item.durationMinutes }
            : { id: null, parentId, name: '', description: '', typeId: null, presenterPersonId: null, durationMinutes: null };
    }

    public typeChosen(draft: AgendaItemDraft): void {
        if (draft.durationMinutes != null) return;
        const type = this.ItemTypes.find((t) => t.id === draft.typeId);
        if (type?.defaultDurationMinutes) draft.durationMinutes = type.defaultDurationMinutes;
    }

    public submit(): void {
        if (!this.draft || !this.draft.name.trim()) return;
        this.SaveRequested.emit({ ...this.draft, name: this.draft.name.trim() });
        this.draft = null;
    }

    public nameOf(id: string): string {
        return this.Items.find((item) => item.id.toLowerCase() === id.toLowerCase())?.name ?? '';
    }

    public durationOf(item: AgendaItemModel): string {
        if (item.durationMinutes != null) return formatMinutes(item.durationMinutes);
        const children = this.Items.filter((i) => i.parentId?.toLowerCase() === item.id.toLowerCase());
        return children.length ? `${formatMinutes(agendaMinutes(children.map((c) => ({ ...c, parentId: null }))))} in sub-items` : 'no length';
    }

    /** "2.1" style numbering from the tree. */
    public numberOf(item: AgendaItemModel): string {
        const path: number[] = [];
        let current: AgendaItemModel | undefined = item;
        while (current) {
            const siblings = this.siblingsOf(current.parentId);
            path.unshift(siblings.findIndex((s) => s.id === current!.id) + 1);
            current = current.parentId ? this.Items.find((i) => i.id.toLowerCase() === current!.parentId!.toLowerCase()) : undefined;
        }
        return path.join('.');
    }

    private siblingsOf(parentId: string | null): AgendaItemModel[] {
        return this.Items.filter((i) => (i.parentId ?? '').toLowerCase() === (parentId ?? '').toLowerCase()).sort((a, b) => a.sequence - b.sequence || a.name.localeCompare(b.name));
    }

    public canMoveUp(item: AgendaItemModel): boolean {
        const siblings = this.siblingsOf(item.parentId);
        return siblings.findIndex((s) => s.id === item.id) > 0;
    }

    public canMoveDown(item: AgendaItemModel): boolean {
        const siblings = this.siblingsOf(item.parentId);
        const index = siblings.findIndex((s) => s.id === item.id);
        return index >= 0 && index < siblings.length - 1;
    }

    public canIndent(item: AgendaItemModel): boolean {
        return this.canMoveUp(item);
    }

    public move(item: AgendaItemModel, delta: -1 | 1): void {
        const siblings = this.siblingsOf(item.parentId);
        const index = siblings.findIndex((s) => s.id === item.id);
        const target = index + delta;
        if (index < 0 || target < 0 || target >= siblings.length) return;
        const ordered = siblings.map((s) => s.id);
        [ordered[index], ordered[target]] = [ordered[target], ordered[index]];
        this.ReorderRequested.emit({ parentId: item.parentId, orderedIds: ordered });
    }

    /** Under the sibling above it. */
    public indent(item: AgendaItemModel): void {
        const siblings = this.siblingsOf(item.parentId);
        const index = siblings.findIndex((s) => s.id === item.id);
        if (index <= 0) return;
        this.MoveRequested.emit({ item, parentId: siblings[index - 1].id });
    }

    /** Up to its parent's level, after the parent. */
    public outdent(item: AgendaItemModel): void {
        if (!item.parentId) return;
        const parent = this.Items.find((i) => i.id.toLowerCase() === item.parentId!.toLowerCase());
        this.MoveRequested.emit({ item, parentId: parent?.parentId ?? null });
    }
}
