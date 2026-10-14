import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { MEETING_TOKENS_CSS } from './tokens';
import type { LinkModel } from './types';

/** What the meeting belongs to: the records it is linked to, each opening through the host; a link can be removed. */
@Component({
    selector: 'bizapps-meeting-links',
    standalone: true,
    imports: [MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="head mjt-row">
            <div class="mjt-grow"><span class="mjt-strong">Belongs to</span> <span class="mjt-muted mjt-small">{{ Links.length }}</span></div>
            @if (CanEdit) { <button mjButton Variant="secondary" Size="sm" [disabled]="Busy" (click)="AddRequested.emit()"><i class="fa-solid fa-link"></i>Link a record</button> }
        </div>
        @if (ErrorMessage) { <div class="mjt-callout mjt-callout--error" role="alert">{{ ErrorMessage }}</div> }
        @if (!Links.length) { <div class="mjt-empty">This meeting belongs to nothing yet.</div> }
        @for (link of Links; track link.id) {
            <div class="link">
                <button type="button" class="open" (click)="OpenRequested.emit(link)" [attr.aria-label]="'Open ' + (link.recordName || link.entityName)">
                    <i class="fa-solid fa-link" aria-hidden="true"></i>
                    <span class="mjt-grow"><span class="mjt-strong">{{ link.recordName || link.recordId }}</span> <span class="mjt-small mjt-muted">{{ entityLabel(link.entityName) }}</span>@if (link.description) { <div class="mjt-small mjt-muted">{{ link.description }}</div> }</span>
                </button>
                @if (CanEdit) { <button mjButton Variant="icon" Size="sm" [disabled]="Busy" aria-label="Remove link" (click)="RemoveRequested.emit(link)"><i class="fa-solid fa-xmark" aria-hidden="true"></i></button> }
            </div>
        }
    `,
    styles: [MEETING_TOKENS_CSS, `
        :host { display: block; }
        .head { margin-bottom: 8px; }
        .link { display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }
        .open { display: flex; align-items: center; gap: 10px; flex: 1; text-align: left; padding: 10px 12px; border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); background: var(--mjt-surface); color: var(--mjt-text); font: inherit; cursor: pointer; }
        .open:hover { border-color: var(--mjt-border-strong); }
        .open:focus-visible { outline: 2px solid var(--mjt-brand); outline-offset: 2px; }
    `],
})
export class MeetingLinksComponent {
    @Input() Links: LinkModel[] = [];
    @Input() CanEdit = false;
    @Input() Busy = false;
    @Input() ErrorMessage = '';
    @Output() OpenRequested = new EventEmitter<LinkModel>();
    @Output() RemoveRequested = new EventEmitter<LinkModel>();
    @Output() AddRequested = new EventEmitter<void>();

    /** "MJ_BizApps_Collaboration: Spaces" → "Spaces". */
    public entityLabel(entityName: string): string {
        const index = entityName.indexOf(':');
        return index >= 0 ? entityName.slice(index + 1).trim() : entityName;
    }
}
