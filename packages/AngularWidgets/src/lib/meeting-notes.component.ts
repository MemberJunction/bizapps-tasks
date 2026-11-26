import { ChangeDetectionStrategy, Component, EventEmitter, Input, OnChanges, Output, SimpleChanges } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MarkdownModule } from '@memberjunction/ng-markdown';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import { settleSubmittedDraft } from './meeting-live.component';
import type {
    AgendaItemModel,
    NoteDraft,
    NoteKind,
    NoteModel,
    PersonOption,
    ProposedTaskAction,
    ProposedTaskModel,
    TranscriptDraft,
} from './types';

interface MentionTokenPayload {
    _mode?: string;
    name?: string;
    Name?: string;
    displayName?: string;
    label?: string;
}

function parseMentionToken(jsonText: string): string | null {
    try {
        const parsed = JSON.parse(jsonText) as MentionTokenPayload | null;
        if (!parsed || typeof parsed !== 'object' || parsed._mode !== 'mention') {
            return null;
        }
        const candidate = parsed.name ?? parsed.displayName ?? parsed.Name ?? parsed.label;
        if (typeof candidate !== 'string') return null;
        const trimmed = candidate.trim();
        return trimmed.length > 0 ? trimmed : null;
    } catch {
        return null;
    }
}

/**
 * Replaces `@{"_mode":"mention",...}` JSON mention tokens with `@Name` using a
 * balanced-brace scan so escaped quotes and nested objects are handled cleanly.
 */
function replaceMentionTokens(input: string): string {
    if (!input.includes('@{')) return input;
    let out = '';
    let idx = 0;
    while (idx < input.length) {
        const start = input.indexOf('@{', idx);
        if (start === -1) {
            out += input.slice(idx);
            break;
        }
        out += input.slice(idx, start);
        const braceStart = start + 1;
        let depth = 0;
        let inString = false;
        let escaped = false;
        let end = -1;
        for (let i = braceStart; i < input.length; i++) {
            const ch = input[i];
            if (inString) {
                if (escaped) {
                    escaped = false;
                } else if (ch === '\\') {
                    escaped = true;
                } else if (ch === '"') {
                    inString = false;
                }
            } else if (ch === '"') {
                inString = true;
            } else if (ch === '{') {
                depth++;
            } else if (ch === '}') {
                depth--;
                if (depth === 0) {
                    end = i;
                    break;
                }
            }
        }
        if (end === -1) {
            out += input.slice(start);
            break;
        }
        const jsonSlice = input.slice(braceStart, end + 1);
        const mentionName = parseMentionToken(jsonSlice);
        if (mentionName) {
            out += `@${mentionName}`;
        } else {
            out += input.slice(start, end + 1);
        }
        idx = end + 1;
    }
    return out;
}

/**
 * Normalizes meeting note body text before Markdown rendering:
 * - Converts `[[EntityName|RecordID|DisplayName]]` tokens into `**DisplayName**`
 * - Converts `@{"_mode":"mention",...}` JSON tokens into `@Name`
 * - Normalizes CRLF line endings to LF
 */
export function FormatMeetingNoteMarkdown(raw: string): string {
    if (!raw) return '';
    const normalized = raw.replace(/\r\n?/g, '\n');
    const withRecords = normalized.replace(
        /\[\[[^|\]]+\|[^|\]]+\|([^\]]+)\]\]/g,
        (_match: string, displayName: string) => {
            const clean = displayName.trim();
            return clean ? `**${clean}**` : '';
        },
    );
    return replaceMentionTokens(withRecords);
}

export function canDraftNotesWithAI(canEditAll: boolean): boolean {
    return canEditAll;
}

export function canManageNoteProposals(canWrite: boolean, canEditAll: boolean, isMine: boolean): boolean {
    return canWrite && (canEditAll || isMine);
}

/**
 * The Notes section: notes by hand or drafted from a transcript (T3), on the meeting or on one agenda item, as Notes,
 * a Summary or a Decision, Draft or Final, with proposed action items that can be accepted into Tasks or dismissed.
 */
@Component({
    selector: 'bizapps-meeting-notes',
    standalone: true,
    imports: [FormsModule, MJButtonDirective, MarkdownModule],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow"><span class="mjt-strong">Notes</span> <span class="mjt-muted mjt-small">{{ Notes.length }}</span></div>
            @if (CanWrite && !draft && !transcriptDraft) {
                @if (canDraftWithAI()) {
                    <button mjButton Variant="secondary" Size="sm" [disabled]="Busy" (click)="openTranscriptDraft()"><i class="fa-solid fa-wand-magic-sparkles"></i>Draft from transcript</button>
                }
                <button mjButton Variant="primary" Size="sm" [disabled]="Busy" (click)="openDraft(null)"><i class="fa-solid fa-plus"></i>New note</button>
            }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (transcriptDraft; as td) {
            <form class="editor" (ngSubmit)="submitTranscript()" aria-label="Draft notes from transcript">
                <div class="mjt-row wrap">
                    <label class="mjt-grow"><span class="mjt-label">Title (optional)</span><input class="mjt-input" name="tdTitle" [(ngModel)]="td.title" maxlength="255" placeholder="AI will suggest a title if left blank" autocomplete="off" /></label>
                    <label><span class="mjt-label">Kind</span>
                        <select class="mjt-select" name="tdKind" [(ngModel)]="td.kind">
                            <option value="Summary">Summary</option><option value="Notes">Notes</option><option value="Decision">Decision</option>
                        </select>
                    </label>
                    <label><span class="mjt-label">About</span>
                        <select class="mjt-select" name="tdItem" [(ngModel)]="td.agendaItemId">
                            <option [ngValue]="null">The meeting</option>
                            @for (item of AgendaItems; track item.id) { <option [ngValue]="item.id">{{ item.name }}</option> }
                        </select>
                    </label>
                </div>
                @if (TranscriptFileID) {
                    <div class="mjt-small mjt-muted"><i class="fa-solid fa-file-lines" aria-hidden="true"></i> Attached transcript file: <span class="mjt-strong">{{ TranscriptFileName || TranscriptFileID }}</span> (used automatically if the box below is left blank)</div>
                }
                <label><span class="mjt-label">Transcript{{ TranscriptFileID ? ' (optional override)' : '' }}</span><textarea class="mjt-textarea" name="transcript" rows="6" [(ngModel)]="td.transcript" [placeholder]="TranscriptFileID ? 'Leave blank to draft from the attached transcript file, or paste transcript text here.' : 'Paste the meeting transcript or rough notes here; AI will summarize and propose action items.'" [required]="!TranscriptFileID"></textarea></label>
                <div class="mjt-row">
                    <span class="mjt-small mjt-muted">Creates a Draft note with proposed action items for review.</span>
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="transcriptDraft = null">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || (!td.transcript.trim() && !TranscriptFileID)"><i class="fa-solid fa-wand-magic-sparkles"></i>Draft with AI</button>
                </div>
            </form>
        }
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
                <label><span class="mjt-label">Note</span><textarea class="mjt-textarea" name="body" rows="6" [(ngModel)]="d.body" placeholder="Capture decisions, takeaways, and action items (Markdown supported)…" required></textarea></label>
                <div class="mjt-row">
                    <label class="check"><input type="checkbox" name="final" [checked]="d.status === 'Final'" (change)="d.status = d.status === 'Final' ? 'Draft' : 'Final'" /> Final</label>
                    <span class="mjt-grow"></span>
                    <button mjButton type="button" Variant="secondary" Size="sm" [disabled]="Busy" (click)="draft = null">Cancel</button>
                    <button mjButton type="submit" Variant="primary" Size="sm" [disabled]="Busy || !d.body.trim()">{{ d.id ? 'Save' : 'Add note' }}</button>
                </div>
            </form>
        }
        @if (!Notes.length && !draft && !transcriptDraft) { <div class="mjt-empty">No notes yet.</div> }
        @for (note of Notes; track note.id) {
            <article class="note" [attr.aria-label]="'Note: ' + (note.title || note.kind)">
                <div class="note-header mjt-row wrap">
                    <span class="note-title mjt-strong">{{ note.title || note.kind }}</span>
                    <span [class]="note.kind === 'Decision' ? 'mjt-chip mjt-chip--ok' : note.kind === 'Summary' ? 'mjt-chip mjt-chip--info' : 'mjt-chip'">{{ note.kind }}</span>
                    @if (note.status === 'Draft') { <span class="mjt-chip mjt-chip--warn">Draft</span> }
                    @if (note.source === 'AI') { <span class="mjt-chip" title="Drafted by AI from the transcript"><i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>AI</span> }
                    <span class="mjt-grow"></span>
                    @if (CanWrite && (note.isMine || CanEditAll)) {
                        <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Edit note" (click)="openDraft(note)"><i class="fa-solid fa-pen" aria-hidden="true"></i></button>
                        <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Delete note" (click)="DeleteRequested.emit(note)"><i class="fa-solid fa-trash" aria-hidden="true"></i></button>
                    }
                </div>
                <div class="note-meta mjt-small mjt-muted">@if (note.authorName) { {{ note.authorName }} · }{{ note.updatedLabel }}@if (note.agendaItemId) { · on {{ itemName(note.agendaItemId) }}}</div>
                <div class="body">
                    <mj-markdown [data]="FormatMeetingNoteMarkdown(note.body)"></mj-markdown>
                </div>
                @if (note.proposedTasks?.length) {
                    <div class="proposals" aria-label="Proposed action items">
                        <div class="proposals-head mjt-small mjt-strong"><i class="fa-solid fa-list-check" aria-hidden="true"></i> Proposed action items ({{ note.proposedTasks!.length }})</div>
                        @for (prop of note.proposedTasks!; track prop.id) {
                            <div class="proposal mjt-row wrap">
                                <div class="mjt-grow">
                                    <span class="prop-title" [class.dismissed]="prop.status === 'Dismissed'">{{ prop.title }}</span>
                                    @if (prop.assigneeName) { <span class="mjt-small mjt-muted"> · {{ prop.assigneeName }}</span> }
                                    @if (prop.dueAt) { <span class="mjt-small mjt-muted"> · due {{ prop.dueAt.slice(0, 10) }}</span> }
                                </div>
                                @if (prop.status === 'Pending' && canManageProposals(note)) {
                                    <button mjButton Variant="primary" Size="sm" [disabled]="Busy" (click)="acceptProposal(note.id, prop)"><i class="fa-solid fa-check"></i>Accept</button>
                                    <button mjButton Variant="secondary" Size="sm" [disabled]="Busy" (click)="dismissProposal(note.id, prop)">Dismiss</button>
                                } @else if (prop.status === 'Accepted') {
                                    <span class="mjt-chip mjt-chip--ok">Accepted</span>
                                    @if (prop.taskId) {
                                        <button mjButton Variant="secondary" Size="sm" (click)="OpenTaskRequested.emit(prop.taskId!)">Open task</button>
                                    }
                                } @else if (prop.status === 'Dismissed') {
                                    <span class="mjt-chip">Dismissed</span>
                                }
                            </div>
                        }
                    </div>
                }
            </article>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 10px; }
        .wrap { flex-wrap: wrap; align-items: flex-end; }
        .editor {
            display: flex; flex-direction: column; gap: 10px;
            padding: 14px 16px;
            border: 1px dashed var(--mj-border-strong, var(--mjt-border-strong));
            border-radius: var(--mj-radius-lg, var(--mjt-radius-lg));
            background: var(--mj-bg-surface-card, var(--mjt-surface));
            margin-bottom: 12px;
        }
        .check { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; }
        .note {
            padding: 16px 18px;
            border: 1px solid var(--mj-border-default, var(--mjt-border));
            border-radius: var(--mj-radius-lg, var(--mjt-radius-lg));
            background: var(--mj-bg-surface-card, var(--mjt-surface));
            margin-bottom: 12px;
            color: var(--mj-text-primary, var(--mjt-text));
        }
        .note-header { align-items: center; gap: 8px; }
        .note-title { font-size: var(--mj-text-base, 15px); color: var(--mj-text-primary, var(--mjt-text)); }
        .note-meta { margin-top: 4px; color: var(--mj-text-muted, var(--mjt-text-muted)); }
        .body {
            margin-top: 12px;
            padding-top: 10px;
            border-top: 1px solid var(--mj-border-subtle, var(--mjt-border));
            font-size: var(--mj-text-sm, 14px);
            line-height: 1.6;
            color: var(--mj-text-primary, var(--mjt-text));
            overflow-wrap: anywhere;
            word-break: break-word;
        }
        :host ::ng-deep .body .mj-markdown-container {
            color: var(--mj-text-primary, var(--mjt-text));
            font-size: var(--mj-text-sm, 14px);
            line-height: 1.6;
            overflow-wrap: anywhere;
            word-break: break-word;
        }
        :host ::ng-deep .body .mj-markdown-container > :first-child { margin-top: 0; }
        :host ::ng-deep .body .mj-markdown-container > :last-child { margin-bottom: 0; }
        :host ::ng-deep .body .mj-markdown-container h1,
        :host ::ng-deep .body .mj-markdown-container h2,
        :host ::ng-deep .body .mj-markdown-container h3,
        :host ::ng-deep .body .mj-markdown-container h4 {
            color: var(--mj-text-primary, var(--mjt-text));
            font-weight: var(--mj-font-semibold, 600);
            line-height: 1.35;
            margin: 14px 0 6px;
        }
        :host ::ng-deep .body .mj-markdown-container h1 {
            font-size: var(--mj-text-lg, 17px);
            padding-bottom: 4px;
            border-bottom: 1px solid var(--mj-border-subtle, var(--mjt-border));
        }
        :host ::ng-deep .body .mj-markdown-container h2 {
            font-size: var(--mj-text-base, 15px);
            padding-bottom: 3px;
            border-bottom: 1px solid var(--mj-border-subtle, var(--mjt-border));
        }
        :host ::ng-deep .body .mj-markdown-container h3 { font-size: var(--mj-text-sm, 14px); }
        :host ::ng-deep .body .mj-markdown-container h4 {
            font-size: var(--mj-text-xs, 13px);
            text-transform: uppercase;
            letter-spacing: 0.03em;
            color: var(--mj-text-secondary, var(--mjt-text-muted));
        }
        :host ::ng-deep .body .mj-markdown-container p {
            margin: 0 0 10px;
            color: var(--mj-text-primary, var(--mjt-text));
        }
        :host ::ng-deep .body .mj-markdown-container ul,
        :host ::ng-deep .body .mj-markdown-container ol {
            margin: 0 0 10px;
            padding-left: 20px;
        }
        :host ::ng-deep .body .mj-markdown-container li {
            margin: 4px 0;
            line-height: 1.55;
        }
        :host ::ng-deep .body .mj-markdown-container li > ul,
        :host ::ng-deep .body .mj-markdown-container li > ol {
            margin: 4px 0 2px;
        }
        :host ::ng-deep .body .mj-markdown-container strong {
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary, var(--mjt-text));
        }
        :host ::ng-deep .body .mj-markdown-container blockquote {
            margin: 10px 0;
            padding: 8px 12px;
            border-left: 3px solid var(--mj-brand-primary, var(--mjt-brand));
            background: var(--mj-bg-surface-sunken, var(--mjt-surface-sunken));
            border-radius: 0 var(--mj-radius-sm, 6px) var(--mj-radius-sm, 6px) 0;
            color: var(--mj-text-secondary, var(--mjt-text-muted));
        }
        :host ::ng-deep .body .mj-markdown-container code {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 0.875em;
            padding: 1px 5px;
            border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface-sunken, var(--mjt-surface-sunken));
            border: 1px solid var(--mj-border-subtle, var(--mjt-border));
            color: var(--mj-text-primary, var(--mjt-text));
        }
        :host ::ng-deep .body .mj-markdown-container pre {
            margin: 10px 0;
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, var(--mjt-radius));
            background: var(--mj-bg-surface-sunken, var(--mjt-surface-sunken));
            border: 1px solid var(--mj-border-default, var(--mjt-border));
            overflow-x: auto;
        }
        :host ::ng-deep .body .mj-markdown-container pre code {
            padding: 0;
            border: none;
            background: transparent;
        }
        :host ::ng-deep .body .mj-markdown-container a {
            color: var(--mj-text-link, var(--mjt-brand));
            text-decoration: underline;
        }
        .proposals {
            margin-top: 12px;
            padding: 10px 12px;
            border: 1px solid var(--mj-border-subtle, var(--mjt-border));
            background: var(--mj-bg-surface-sunken, var(--mjt-surface-sunken));
            border-radius: var(--mj-radius-md, var(--mjt-radius));
            display: flex; flex-direction: column; gap: 6px;
        }
        .proposals-head { display: flex; align-items: center; gap: 6px; margin-bottom: 2px; }
        .proposal {
            padding: 6px 8px;
            border: 1px solid var(--mj-border-default, var(--mjt-border));
            border-radius: var(--mj-radius-md, var(--mjt-radius));
            background: var(--mj-bg-surface-card, var(--mjt-surface));
        }
        .prop-title { font-size: 13px; font-weight: 500; }
        .prop-title.dismissed { text-decoration: line-through; opacity: 0.65; }
    `],
})
export class MeetingNotesComponent implements OnChanges {
    @Input() Notes: NoteModel[] = [];
    @Input() AgendaItems: AgendaItemModel[] = [];
    @Input() People: PersonOption[] = [];
    @Input() CanWrite = false;
    @Input() CanEditAll = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Input() DefaultAgendaItemID: string | null = null;
    @Input() TranscriptFileID: string | null = null;
    @Input() TranscriptFileName: string | null = null;
    @Output() SaveRequested = new EventEmitter<NoteDraft>();
    @Output() DeleteRequested = new EventEmitter<NoteModel>();
    @Output() TranscriptDraftRequested = new EventEmitter<TranscriptDraft>();
    @Output() AcceptProposalRequested = new EventEmitter<ProposedTaskAction>();
    @Output() DismissProposalRequested = new EventEmitter<ProposedTaskAction>();
    @Output() OpenTaskRequested = new EventEmitter<string>();

    protected readonly FormatMeetingNoteMarkdown = FormatMeetingNoteMarkdown;
    protected draft: NoteDraft | null = null;
    protected transcriptDraft: TranscriptDraft | null = null;
    private pendingSave = false;
    private pendingTranscript = false;

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['Busy'] || changes['Notes'] || changes['ErrorMessage']) {
            const saveAction = settleSubmittedDraft(this.pendingSave, this.Busy, this.ErrorMessage);
            if (saveAction === 'clear') {
                this.draft = null;
                this.pendingSave = false;
            } else if (saveAction === 'reset-pending') {
                this.pendingSave = false;
            }
            const transcriptAction = settleSubmittedDraft(this.pendingTranscript, this.Busy, this.ErrorMessage);
            if (transcriptAction === 'clear') {
                this.transcriptDraft = null;
                this.pendingTranscript = false;
            } else if (transcriptAction === 'reset-pending') {
                this.pendingTranscript = false;
            }
        }
    }

    protected canDraftWithAI(): boolean {
        return canDraftNotesWithAI(this.CanEditAll);
    }

    protected canManageProposals(note: NoteModel): boolean {
        return canManageNoteProposals(this.CanWrite, this.CanEditAll, note.isMine);
    }

    protected openDraft(note: NoteModel | null, kind: NoteKind = 'Notes'): void {
        this.transcriptDraft = null;
        this.pendingSave = false;
        this.draft = note
            ? { id: note.id, agendaItemId: note.agendaItemId, kind: note.kind, title: note.title ?? '', body: note.body, status: note.status }
            : { id: null, agendaItemId: this.DefaultAgendaItemID, kind, title: '', body: '', status: 'Draft' };
    }

    protected openTranscriptDraft(): void {
        this.draft = null;
        this.pendingTranscript = false;
        this.transcriptDraft = { transcript: '', title: '', kind: 'Summary', agendaItemId: this.DefaultAgendaItemID };
    }

    protected submit(): void {
        if (!this.draft?.body.trim()) return;
        this.pendingSave = true;
        this.SaveRequested.emit({ ...this.draft, title: this.draft.title.trim(), body: this.draft.body.trim() });
    }

    protected submitTranscript(): void {
        if (!this.transcriptDraft) return;
        if (!this.transcriptDraft.transcript.trim() && !this.TranscriptFileID) return;
        this.pendingTranscript = true;
        this.TranscriptDraftRequested.emit({
            ...this.transcriptDraft,
            title: this.transcriptDraft.title.trim(),
            transcript: this.transcriptDraft.transcript.trim(),
        });
    }

    protected acceptProposal(noteId: string, proposal: ProposedTaskModel): void {
        this.AcceptProposalRequested.emit({ noteId, proposal });
    }

    protected dismissProposal(noteId: string, proposal: ProposedTaskModel): void {
        this.DismissProposalRequested.emit({ noteId, proposal });
    }

    protected itemName(id: string): string {
        return this.AgendaItems.find((item) => item.id.toLowerCase() === id.toLowerCase())?.name ?? 'an item';
    }
}
