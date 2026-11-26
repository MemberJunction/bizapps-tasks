import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    OnChanges,
    OnInit,
    SimpleChanges,
    inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LogError, Metadata, type UserInfo } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { IsValidUUID, RegisterClassEx } from '@memberjunction/global';
import { GraphQLActionClient, GraphQLDataProvider } from '@memberjunction/graphql-dataprovider';
import { ArtifactsModule } from '@memberjunction/ng-artifacts';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import { MarkdownModule } from '@memberjunction/ng-markdown';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import {
    ArtifactDualReadResolver,
    MEETING_NOTE_ENTITY,
    PUBLISH_MEETING_NOTE_AS_MJ_DOC_ACTION_ID,
    parseProposedTasks,
    type ProposedTask,
    type ResolvedArtifactContent,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksMeetingNoteEntity } from '@mj-biz-apps/tasks-entities';

export type MeetingNoteViewMode = 'published' | 'scratchpad';

export const MEETING_NOTE_VIEW_MODE_SETTING_KEY = 'mj.tasks.meetingNote.viewMode.v1';

export interface MeetingNotePublishResult {
    ArtifactID: string;
    ArtifactVersionID: string;
    VersionNumber: number;
    CreatedNewArtifact: boolean;
}

export type MeetingNotePublishHandler = (noteId: string) => Promise<MeetingNotePublishResult>;

/**
 * Form panel for Category B `MJ_BizApps_Tasks: Meeting Notes` (`slot: 'before-fields'`).
 *
 * Hybrid live-scratchpad + canonical MJ Doc UX:
 * - Exposes a `'Publish as MJ Doc'` CTA (and `'Publish New Version'` when already linked)
 *   strictly guarded against concurrent in-flight clicks and blank/whitespace `Body`.
 * - When `MeetingNote.ArtifactID` is populated, provides an accessible tab toggle between
 *   **Published MJ Doc** (`<mj-artifact-viewer-panel>`) and **Live Scratchpad**
 *   (formatted live `Body` + `ProposedTasks` JSON items) so facilitators can continue editing
 *   and re-publishing new versions without losing scratchpad responsiveness.
 * - Falls back gracefully to formatted legacy `Body` when `ArtifactID` is null or when
 *   artifact resolution returns zero accessible versions.
 * - Persists tab preference via `UserInfoEngine.Instance` (zero `localStorage`) and uses
 *   strictly semantic `--mj-*` CSS design tokens with `ChangeDetectionStrategy.OnPush`.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:MeetingNotes:artifact',
    metadata: {
        entity: MEETING_NOTE_ENTITY,
        slot: 'before-fields',
        sortKey: 95,
        contributionKey: 'artifact',
    },
})
@Component({
    selector: 'mjt-meeting-note-artifact-panel',
    standalone: true,
    imports: [CommonModule, FormsModule, ArtifactsModule, MarkdownModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <section class="mjt-note-doc-panel" aria-label="Meeting Note Document & Scratchpad">
            <header class="mjt-note-doc-panel__header">
                <div class="mjt-note-doc-panel__title-group">
                    <i class="fa-solid fa-note-sticky mjt-note-doc-panel__icon" aria-hidden="true"></i>
                    <div>
                        <h2 class="mjt-note-doc-panel__title">{{ DisplayTitle }}</h2>
                        <p class="mjt-note-doc-panel__subtitle">
                            @if (HasLinkedArtifactId) {
                                Linked MJ Doc
                                @if (VersionNumber !== null) {
                                    · v{{ VersionNumber }}
                                }
                                @if (HasUnpublishedEdits) {
                                    · Unpublished scratchpad edits
                                }
                            } @else {
                                Live Meeting Scratchpad · Not yet published as an MJ Doc
                            }
                        </p>
                    </div>
                </div>

                <div class="mjt-note-doc-panel__actions">
                    @if (HasLinkedArtifactId) {
                        <div class="mjt-note-tabs" role="tablist" aria-label="Meeting note view mode">
                            <button
                                id="mjt-note-tab-published"
                                type="button"
                                role="tab"
                                class="mjt-note-tab"
                                [class.mjt-note-tab--active]="ActiveView === 'published'"
                                [attr.aria-selected]="ActiveView === 'published'"
                                (click)="SetView('published')">
                                <i class="fa-solid fa-book-open" aria-hidden="true"></i>
                                Published MJ Doc
                            </button>
                            <button
                                id="mjt-note-tab-scratchpad"
                                type="button"
                                role="tab"
                                class="mjt-note-tab"
                                [class.mjt-note-tab--active]="ActiveView === 'scratchpad'"
                                [attr.aria-selected]="ActiveView === 'scratchpad'"
                                (click)="SetView('scratchpad')">
                                <i class="fa-solid fa-pen-to-square" aria-hidden="true"></i>
                                Live Scratchpad
                                @if (HasUnpublishedEdits) {
                                    <span class="mjt-note-dot" title="Unpublished edits in scratchpad"></span>
                                }
                            </button>
                        </div>
                    }

                    <button
                        mjButton
                        variant="primary"
                        size="sm"
                        type="button"
                        [disabled]="!CanPublish"
                        [attr.aria-busy]="IsPublishing ? 'true' : null"
                        (click)="PublishAsMJDoc()">
                        <i class="fa-solid fa-file-export" aria-hidden="true"></i>
                        {{ PublishButtonLabel }}
                    </button>
                </div>
            </header>

            @if (StatusBanner; as banner) {
                <div
                    class="mjt-note-banner"
                    [class.mjt-note-banner--error]="banner.Type === 'error'"
                    [class.mjt-note-banner--success]="banner.Type === 'success'"
                    [attr.role]="banner.Type === 'error' ? 'alert' : 'status'">
                    <span>{{ banner.Message }}</span>
                </div>
            }

            @if (!HasNonBlankBody) {
                <p class="mjt-note-hint">
                    Add content to the meeting note body to enable publishing as a canonical MJ Doc.
                </p>
            }

            <div class="mjt-note-doc-panel__body">
                @if (IsResolving) {
                    <p class="mjt-note-loading">Loading linked MJ Doc…</p>
                } @else if (ShowPublishedDocView && ArtifactID) {
                    @if (HasAccessibleArtifact) {
                        <div class="mjt-artifact-viewer-host">
                            <mj-artifact-viewer-panel
                                [artifactId]="ArtifactID"
                                [VersionNumber]="VersionNumber ?? undefined"
                                [CurrentUser]="CurrentUser"
                                [ShowHeader]="true"
                                [ShowTabs]="true"
                                [ShowCloseButton]="false"
                                [ShowSaveToCollection]="true"
                                [CanEdit]="false">
                            </mj-artifact-viewer-panel>
                        </div>
                    } @else {
                        <div class="mjt-note-fallback-notice" role="status">
                            <i class="fa-solid fa-circle-info" aria-hidden="true"></i>
                            <span>
                                Linked MJ Doc version is unavailable for your account — displaying legacy scratchpad body.
                            </span>
                        </div>
                        <div class="mjt-note-markdown">
                            <mj-markdown [data]="LegacyBody"></mj-markdown>
                        </div>
                    }
                } @else {
                    <div class="mjt-scratchpad">
                        <div class="mjt-scratchpad__section">
                            <h3 class="mjt-scratchpad__heading">Live Scratchpad Preview</h3>
                            @if (HasNonBlankBody) {
                                <div class="mjt-note-markdown">
                                    <mj-markdown [data]="LegacyBody"></mj-markdown>
                                </div>
                            } @else {
                                <p class="mjt-note-empty">No scratchpad notes captured yet.</p>
                            }
                        </div>

                        @if (ProposedTasks.length > 0) {
                            <div class="mjt-scratchpad__section" aria-label="Proposed tasks JSON summary">
                                <h3 class="mjt-scratchpad__heading">
                                    <i class="fa-solid fa-list-check" aria-hidden="true"></i>
                                    Proposed Tasks ({{ ProposedTasks.length }})
                                </h3>
                                <ul class="mjt-proposed-list">
                                    @for (task of ProposedTasks; track task.id) {
                                        <li class="mjt-proposed-item">
                                            <span class="mjt-proposed-item__title">{{ task.title }}</span>
                                            <span class="mjt-proposed-item__status">{{ task.status }}</span>
                                        </li>
                                    }
                                </ul>
                            </div>
                        }
                    </div>
                }
            </div>
        </section>
    `,
    styles: [`
        :host {
            display: block;
            margin-bottom: var(--mj-space-4);
        }

        .mjt-note-doc-panel {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg);
            padding: var(--mj-space-4);
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-3);
            color: var(--mj-text-primary);
            font-family: var(--mj-font-family);
        }

        .mjt-note-doc-panel__header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: var(--mj-space-3);
            padding-bottom: var(--mj-space-3);
            border-bottom: 1px solid var(--mj-border-subtle);
        }

        .mjt-note-doc-panel__title-group {
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
        }

        .mjt-note-doc-panel__icon {
            color: var(--mj-brand-primary);
            font-size: var(--mj-text-lg);
        }

        .mjt-note-doc-panel__title {
            margin: 0;
            font-size: var(--mj-text-base);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }

        .mjt-note-doc-panel__subtitle {
            margin: var(--mj-space-1) 0 0;
            font-size: var(--mj-text-xs);
            color: var(--mj-text-muted);
        }

        .mjt-note-doc-panel__actions {
            display: inline-flex;
            align-items: center;
            flex-wrap: wrap;
            gap: var(--mj-space-2);
        }

        .mjt-note-tabs {
            display: inline-flex;
            gap: var(--mj-space-1);
            padding: var(--mj-space-1);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
        }

        .mjt-note-tab {
            display: inline-flex;
            align-items: center;
            gap: var(--mj-space-1);
            border: none;
            background: transparent;
            color: var(--mj-text-secondary);
            padding: var(--mj-space-1) var(--mj-space-3);
            border-radius: var(--mj-radius-sm);
            font-family: inherit;
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
            cursor: pointer;
        }

        .mjt-note-tab--active {
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            box-shadow: var(--mj-shadow-sm);
        }

        .mjt-note-tab:focus-visible {
            outline: 2px solid var(--mj-brand-primary);
            outline-offset: 2px;
        }

        .mjt-note-dot {
            width: 6px;
            height: 6px;
            border-radius: var(--mj-radius-full);
            background: var(--mj-status-warning);
            display: inline-block;
        }

        .mjt-note-banner,
        .mjt-note-fallback-notice {
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
            padding: var(--mj-space-2) var(--mj-space-3);
            border-radius: var(--mj-radius-md);
            font-size: var(--mj-text-xs);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }

        .mjt-note-banner--error {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
        }

        .mjt-note-banner--success {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
        }

        .mjt-note-fallback-notice {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            margin-bottom: var(--mj-space-2);
        }

        .mjt-note-hint,
        .mjt-note-loading,
        .mjt-note-empty {
            margin: 0;
            font-size: var(--mj-text-xs);
            color: var(--mj-text-muted);
        }

        .mjt-artifact-viewer-host {
            min-height: 320px;
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-md);
            overflow: hidden;
            background: var(--mj-bg-surface-card);
        }

        .mjt-scratchpad {
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-3);
        }

        .mjt-scratchpad__heading {
            margin: 0 0 var(--mj-space-2);
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--mj-text-secondary);
        }

        .mjt-note-markdown {
            padding: var(--mj-space-3);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-size: var(--mj-text-sm);
            line-height: 1.6;
        }

        .mjt-proposed-list {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-2);
        }

        .mjt-proposed-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: var(--mj-space-2);
            padding: var(--mj-space-2) var(--mj-space-3);
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-card);
        }

        .mjt-proposed-item__title {
            font-size: var(--mj-text-sm);
            color: var(--mj-text-primary);
        }

        .mjt-proposed-item__status {
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
            padding: var(--mj-space-1) var(--mj-space-2);
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
        }
    `],
})
export class MeetingNoteArtifactPanel
    extends BaseFormPanel<mjBizAppsTasksMeetingNoteEntity>
    implements OnInit, OnChanges
{
    private readonly cdr = inject(ChangeDetectorRef, { optional: true });

    public ActiveView: MeetingNoteViewMode = 'published';
    public IsResolving = false;
    public IsPublishing = false;
    public Resolved: ResolvedArtifactContent | null = null;
    public StatusBanner: { Type: 'success' | 'error'; Message: string } | null = null;

    /** Optional injected publish handler (used by host overrides and unit tests). */
    public PublishHandler?: MeetingNotePublishHandler;

    public get ArtifactID(): string | null {
        const raw = this.Record?.ArtifactID;
        return typeof raw === 'string' && IsValidUUID(raw.trim()) ? raw.trim() : null;
    }

    public get HasLinkedArtifactId(): boolean {
        return this.ArtifactID !== null;
    }

    public get HasAccessibleArtifact(): boolean {
        return this.HasLinkedArtifactId && this.Resolved?.Source === 'artifact';
    }

    public get ShowPublishedDocView(): boolean {
        return this.HasLinkedArtifactId && this.ActiveView === 'published';
    }

    public get LegacyBody(): string {
        return typeof this.Record?.Body === 'string' ? this.Record.Body : '';
    }

    public get HasNonBlankBody(): boolean {
        return this.LegacyBody.trim().length > 0;
    }

    public get CanPublish(): boolean {
        const hasId = Boolean(this.Record?.ID && IsValidUUID(this.Record.ID));
        return hasId && this.HasNonBlankBody && !this.IsPublishing;
    }

    public get PublishButtonLabel(): string {
        if (this.IsPublishing) return 'Publishing…';
        return this.HasLinkedArtifactId ? 'Publish New Version' : 'Publish as MJ Doc';
    }

    public get VersionNumber(): number | null {
        return this.Resolved?.VersionNumber ?? null;
    }

    public get DisplayTitle(): string {
        return (
            this.Resolved?.ArtifactName?.trim() ||
            this.Record?.Title?.trim() ||
            'Meeting Note'
        );
    }

    public get HasUnpublishedEdits(): boolean {
        if (!this.HasAccessibleArtifact || !this.Resolved) return false;
        return this.Resolved.Content.trim() !== this.LegacyBody.trim();
    }

    public get ProposedTasks(): ProposedTask[] {
        return parseProposedTasks(this.Record?.ProposedTasks ?? null);
    }

    public get CurrentUser(): UserInfo {
        return Metadata.Provider?.CurrentUser as UserInfo;
    }

    public async ngOnInit(): Promise<void> {
        this.loadSavedViewMode();
        await this.ResolveDocument();
    }

    public async ngOnChanges(changes: SimpleChanges): Promise<void> {
        if (changes['Record']) {
            await this.ResolveDocument();
        }
    }

    public SetView(view: MeetingNoteViewMode): void {
        if (this.ActiveView === view) return;
        this.ActiveView = view;
        this.persistViewMode(view);
        this.cdr?.markForCheck();
    }

    public async ResolveDocument(): Promise<void> {
        const record = this.Record;
        if (!record) {
            this.Resolved = null;
            this.cdr?.markForCheck();
            return;
        }

        if (!this.ArtifactID) {
            this.ActiveView = 'scratchpad';
            this.Resolved = {
                RecordID: record.ID ?? '',
                Source: 'body',
                FallbackReason: 'no_artifact_id',
                Content: this.LegacyBody,
                LegacyBody: this.LegacyBody,
                ArtifactID: null,
                ArtifactName: null,
                ArtifactDescription: null,
                ArtifactTypeID: null,
                ArtifactTypeName: null,
                VersionID: null,
                VersionNumber: null,
                VersionName: null,
                MimeType: null,
                ContentMode: null,
                UpdatedAt: null,
            };
            this.cdr?.markForCheck();
            return;
        }

        this.IsResolving = true;
        this.cdr?.markForCheck();
        try {
            this.Resolved = await ArtifactDualReadResolver.Instance.ResolveSingle(
                {
                    ID: record.ID,
                    ArtifactID: record.ArtifactID,
                    Body: this.LegacyBody,
                    Title: record.Title,
                },
                {
                    ContextUser: this.CurrentUser,
                    IncludeContent: true,
                },
            );
        } catch (err) {
            LogError(
                `MeetingNoteArtifactPanel: failed to resolve artifact ${this.ArtifactID}: ${err instanceof Error ? err.message : String(err)}`,
            );
            this.Resolved = {
                RecordID: record.ID ?? '',
                Source: 'body',
                FallbackReason: 'artifact_not_accessible',
                Content: this.LegacyBody,
                LegacyBody: this.LegacyBody,
                ArtifactID: this.ArtifactID,
                ArtifactName: null,
                ArtifactDescription: null,
                ArtifactTypeID: null,
                ArtifactTypeName: null,
                VersionID: null,
                VersionNumber: null,
                VersionName: null,
                MimeType: null,
                ContentMode: null,
                UpdatedAt: null,
            };
        } finally {
            this.IsResolving = false;
            this.cdr?.markForCheck();
        }
    }

    /**
     * Publishes the current `MeetingNote` as an MJ Doc (or appends a new version idempotently),
     * guarded strictly against concurrent in-flight clicks and blank note bodies.
     */
    public async PublishAsMJDoc(): Promise<MeetingNotePublishResult | null> {
        if (!this.CanPublish || !this.Record) {
            if (!this.HasNonBlankBody) {
                this.StatusBanner = {
                    Type: 'error',
                    Message: 'Meeting note body cannot be empty when publishing as an MJ Doc.',
                };
                this.cdr?.markForCheck();
            }
            return null;
        }

        this.IsPublishing = true;
        this.StatusBanner = null;
        this.cdr?.markForCheck();

        try {
            const published = this.PublishHandler
                ? await this.PublishHandler(this.Record.ID)
                : await this.runPublishAction(this.Record.ID);

            this.Record.ArtifactID = published.ArtifactID;
            this.Resolved = {
                RecordID: this.Record.ID,
                Source: 'artifact',
                FallbackReason: null,
                Content: this.LegacyBody,
                LegacyBody: this.LegacyBody,
                ArtifactID: published.ArtifactID,
                ArtifactName: this.DisplayTitle,
                ArtifactDescription: null,
                ArtifactTypeID: null,
                ArtifactTypeName: 'Markdown Document',
                VersionID: published.ArtifactVersionID,
                VersionNumber: published.VersionNumber,
                VersionName: this.DisplayTitle,
                MimeType: 'text/markdown',
                ContentMode: 'Text',
                UpdatedAt: new Date().toISOString(),
            };
            this.ActiveView = 'published';
            this.persistViewMode('published');
            this.StatusBanner = {
                Type: 'success',
                Message: published.CreatedNewArtifact
                    ? `Published as MJ Doc (v${published.VersionNumber}). Switch to Live Scratchpad anytime to continue editing.`
                    : `Published MJ Doc v${published.VersionNumber}. Live scratchpad and proposed tasks remain preserved.`,
            };
            return published;
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`MeetingNoteArtifactPanel.PublishAsMJDoc failed: ${msg}`);
            this.StatusBanner = { Type: 'error', Message: msg };
            return null;
        } finally {
            this.IsPublishing = false;
            this.cdr?.markForCheck();
        }
    }

    private async runPublishAction(noteId: string): Promise<MeetingNotePublishResult> {
        const provider = Metadata.Provider;
        if (!provider || !('ExecuteGQL' in provider || provider instanceof GraphQLDataProvider)) {
            throw new Error('GraphQL provider is required to run Publish Meeting Note as MJ Doc.');
        }

        const client = new GraphQLActionClient(provider as GraphQLDataProvider);
        const res = await client.RunAction(PUBLISH_MEETING_NOTE_AS_MJ_DOC_ACTION_ID, [
            { Name: 'MeetingNoteID', Value: noteId, Type: 'Input' },
            { Name: 'ArtifactID', Value: null, Type: 'Output' },
            { Name: 'ArtifactVersionID', Value: null, Type: 'Output' },
            { Name: 'VersionNumber', Value: null, Type: 'Output' },
            { Name: 'CreatedNewArtifact', Value: null, Type: 'Output' },
        ]);
        if (!res.Success) {
            throw new Error(res.Message || 'Failed to publish meeting note as MJ Doc.');
        }

        const readOut = (name: string): string => {
            const p = res.Params?.find((param) => param.Name.toLowerCase() === name.toLowerCase());
            return p?.Value != null ? String(p.Value).trim() : '';
        };
        const artifactId = readOut('ArtifactID');
        const artifactVersionId = readOut('ArtifactVersionID');
        const versionNumber = Number(readOut('VersionNumber')) || 1;
        const createdNewArtifact = readOut('CreatedNewArtifact').toLowerCase() === 'true';

        if (!artifactId) {
            throw new Error('Publish action succeeded but did not return an ArtifactID.');
        }
        return {
            ArtifactID: artifactId,
            ArtifactVersionID: artifactVersionId,
            VersionNumber: versionNumber,
            CreatedNewArtifact: createdNewArtifact,
        };
    }

    private loadSavedViewMode(): void {
        try {
            const raw = UserInfoEngine.Instance.GetSetting(MEETING_NOTE_VIEW_MODE_SETTING_KEY);
            if (raw === 'published' || raw === 'scratchpad') {
                this.ActiveView = raw;
            }
        } catch {
            // UserInfoEngine may not be initialized in isolated unit tests
        }
    }

    private persistViewMode(view: MeetingNoteViewMode): void {
        try {
            UserInfoEngine.Instance.SetSettingDebounced(MEETING_NOTE_VIEW_MODE_SETTING_KEY, view);
        } catch {
            // UserInfoEngine may not be initialized in isolated unit tests
        }
    }
}
