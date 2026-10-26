import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import type { AgendaItemModel, NoteDraft, NoteKind, NoteModel } from './types';

/**
 * The Notes section: notes by hand, on the meeting or on one agenda item, as Notes, a Summary or a Decision, Draft or
 * Final. Drafting from a transcript and the proposed tasks come with T3; this leaves room for them.
 */
@Component({
    selector: 'bizapps-meeting-notes',
    standalone: true,
    imports: [FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow"><span class="mjt-strong">Notes</span> <span class="mjt-muted mjt-small">{{ Notes.length }}</span></div>
            @if (CanWrite && !draft) {
                <button mjButton Variant="primary" Size="sm" [disabled]="Busy" (click)="openDraft(null)"><i class="fa-solid fa-plus"></i>New note</button>
            }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (draft; as d) {
            <form class="editor" (ngSubmit)="submit()" aria-label="Note">
                <div class="mjt-row wrap">
                    <label class="mjt-grow"><span class="mjt-label">Title</span><input class="mjt-input" name="title" [(ngModel)]="d.title" maxlength="255" autocomplete="off" /></label>
                    <label><span class="mjt-label">Kind</span>
                        <select class="mjt-select" name="kind" [(ngModel)]="d.kind">
                            <option value="Notes">Notes</option><option value="Summary">Summary</option><option value="Decision">Decision</option>
                        </select>
                    </label>
                    <label><span class="mjt-label">About</span>
                        <select class="mjt-select" name="item" [(ngModel)]="d.agendaItemId">
                            <option [ngValue]="null">The meeting</option>
                            @for (item of AgendaItems; track item.id) { <option [ngValue]="item.id">{{ item.name }}</option> }
                        </select>
                    </label>
                </div>
                <label><span class="mjt-label">Note</span><textarea class="mjt-textarea" name="body" rows="6" [(ngModel)]="d.body" placeholder="What happened, what was agreed (Markdown is kept as text)" required></textarea></label>
                <div class="mjt-row">
                    <label class="check"><input type="checkbox" name="final" [checked]="d.status === 'Final'" (change)="d.status = d.status === 'Final' ? 'Draft' : 'Final'" /> Final</label>
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="draft = null">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || !d.body.trim()">{{ d.id ? 'Save' : 'Add note' }}</button>
                </div>
            </form>
        }
        @if (!Notes.length && !draft) { <div class="mjt-empty">No notes yet.</div> }
        @for (note of Notes; track note.id) {
            <article class="note" [attr.aria-label]="'Note: ' + (note.title || note.kind)">
                <div class="mjt-row wrap">
                    <span class="mjt-strong">{{ note.title || note.kind }}</span>
                    <span [class]="note.kind === 'Decision' ? 'mjt-chip mjt-chip--ok' : note.kind === 'Summary' ? 'mjt-chip mjt-chip--info' : 'mjt-chip'">{{ note.kind }}</span>
                    @if (note.status === 'Draft') { <span class="mjt-chip mjt-chip--warn">Draft</span> }
                    @if (note.source === 'AI') { <span class="mjt-chip" title="Drafted by AI from the transcript"><i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>AI</span> }
                    <span class="mjt-grow"></span>
                    @if (CanWrite && (note.isMine || CanEditAll)) {
                        <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Edit note" (click)="openDraft(note)"><i class="fa-solid fa-pen" aria-hidden="true"></i></button>
                        <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Delete note" (click)="DeleteRequested.emit(note)"><i class="fa-solid fa-trash" aria-hidden="true"></i></button>
                    }
                </div>
                <div class="mjt-small mjt-muted">@if (note.authorName) { {{ note.authorName }} · }{{ note.updatedLabel }}@if (note.agendaItemId) { · on {{ itemName(note.agendaItemId) }}}</div>
                <div class="body">{{ note.body }}</div>
            </article>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 8px; }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .editor { display: flex; flex-direction: column; gap: 10px; padding: 12px; border: 1px dashed var(--mjt-border-strong); border-radius: var(--mjt-radius-lg); margin-bottom: 10px; }
        .check { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; }
        .note { padding: 12px 14px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); margin-bottom: 8px; color: var(--mjt-text); }
        .body { margin-top: 8px; white-space: pre-wrap; font-size: 14px; line-height: 1.5; }
    `],
})
export class MeetingNotesComponent {
    @Input() Notes: NoteModel[] = [];
    @Input() AgendaItems: AgendaItemModel[] = [];
    @Input() CanWrite = false;
    @Input() CanEditAll = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Input() DefaultAgendaItemID: string | null = null;
    @Output() SaveRequested = new EventEmitter<NoteDraft>();
    @Output() DeleteRequested = new EventEmitter<NoteModel>();

    protected draft: NoteDraft | null = null;

    protected openDraft(note: NoteModel | null, kind: NoteKind = 'Notes'): void {
        this.draft = note
            ? { id: note.id, agendaItemId: note.agendaItemId, kind: note.kind, title: note.title ?? '', body: note.body, status: note.status }
            : { id: null, agendaItemId: this.DefaultAgendaItemID, kind, title: '', body: '', status: 'Draft' };
    }

    protected submit(): void {
        if (!this.draft?.body.trim()) return;
        this.SaveRequested.emit({ ...this.draft, title: this.draft.title.trim(), body: this.draft.body.trim() });
        this.draft = null;
    }

    protected itemName(id: string): string {
        return this.AgendaItems.find((item) => item.id.toLowerCase() === id.toLowerCase())?.name ?? 'an item';
    }
}
