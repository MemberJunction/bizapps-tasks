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
import { LogError, Metadata, type UserInfo } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { IsValidUUID, RegisterClassEx } from '@memberjunction/global';
import { ArtifactsModule } from '@memberjunction/ng-artifacts';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import { MarkdownModule } from '@memberjunction/ng-markdown';
import {
    ArtifactDualReadResolver,
    WORK_REPORTS_ENTITY_NAME,
    type ResolvedArtifactContent,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';

export type WorkReportDocumentViewMode = 'artifact' | 'body';

export const WORK_REPORT_VIEW_MODE_SETTING_KEY = 'mj.tasks.workReport.documentViewMode.v1';

/**
 * Form panel contributing MJ Docs (`<mj-artifact-viewer-panel>`) dual-read viewing into
 * the `MJ_BizApps_Tasks: Work Reports` form (`slot: 'before-fields'`).
 *
 * - When `Record.ArtifactID` is populated and resolves to an accessible `MJ: Artifact Versions`
 *   record, renders `<mj-artifact-viewer-panel>` with a view toggle back to the legacy summary.
 * - When `Record.ArtifactID` is null or inaccessible, renders the formatted legacy `Body`
 *   cleanly via `<mj-markdown>` with zero raw Markdown leaks.
 * - Preserves Dual Form Registration Parity alongside `mjBizAppsTasksWorkReportFormComponent`.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:WorkReports:artifact',
    metadata: {
        entity: WORK_REPORTS_ENTITY_NAME,
        slot: 'before-fields',
        sortKey: 95,
        contributionKey: 'artifact',
    },
})
@Component({
    selector: 'mjt-work-report-artifact-panel',
    standalone: true,
    imports: [CommonModule, ArtifactsModule, MarkdownModule],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <section class="mjt-doc-panel" aria-label="Work Report Document">
            <header class="mjt-doc-panel__header">
                <div class="mjt-doc-panel__title-group">
                    <i class="fa-solid fa-file-lines mjt-doc-panel__icon" aria-hidden="true"></i>
                    <div>
                        <h2 class="mjt-doc-panel__title">{{ DisplayTitle }}</h2>
                        <p class="mjt-doc-panel__subtitle">
                            @if (HasAccessibleArtifact) {
                                Linked MJ Doc
                                @if (VersionNumber !== null) {
                                    · v{{ VersionNumber }}
                                }
                            } @else if (HasLinkedArtifactId) {
                                Legacy Summary Fallback (linked MJ Doc unavailable)
                            } @else {
                                Legacy Work Report Summary
                            }
                        </p>
                    </div>
                </div>

                <div class="mjt-doc-panel__controls">
                    @if (HasAccessibleArtifact) {
                        <span class="mjt-doc-badge mjt-doc-badge--artifact">
                            <i class="fa-solid fa-book-open" aria-hidden="true"></i>
                            MJ Doc@if (VersionNumber !== null) { v{{ VersionNumber }}}
                        </span>
                        <div class="mjt-doc-tabs" role="tablist" aria-label="Work report view mode">
                            <button
                                type="button"
                                role="tab"
                                class="mjt-doc-tab"
                                [class.mjt-doc-tab--active]="ViewMode === 'artifact'"
                                [attr.aria-selected]="ViewMode === 'artifact'"
                                (click)="SetViewMode('artifact')">
                                Published MJ Doc
                            </button>
                            <button
                                type="button"
                                role="tab"
                                class="mjt-doc-tab"
                                [class.mjt-doc-tab--active]="ViewMode === 'body'"
                                [attr.aria-selected]="ViewMode === 'body'"
                                (click)="SetViewMode('body')">
                                Legacy Summary
                            </button>
                        </div>
                    } @else {
                        <span class="mjt-doc-badge mjt-doc-badge--legacy">
                            <i class="fa-solid fa-align-left" aria-hidden="true"></i>
                            Legacy Body
                        </span>
                    }
                </div>
            </header>

            @if (HasLinkedArtifactId && !HasAccessibleArtifact && !IsResolving) {
                <div class="mjt-doc-notice" role="status">
                    <i class="fa-solid fa-circle-info" aria-hidden="true"></i>
                    <span>
                        Linked MJ Doc could not be loaded for this account; showing legacy report body instead.
                    </span>
                </div>
            }

            <div class="mjt-doc-panel__body">
                @if (IsResolving) {
                    <p class="mjt-doc-loading">Resolving document…</p>
                } @else if (ShowArtifactViewer && ArtifactID) {
                    <div class="mjt-artifact-viewer-host">
                        <mj-artifact-viewer-panel
                            [artifactId]="ArtifactID"
                            [CurrentUser]="CurrentUser"
                            [ShowHeader]="true"
                            [ShowTabs]="true"
                            [ShowCloseButton]="false"
                            [ShowSaveToCollection]="true"
                            [CanEdit]="false">
                        </mj-artifact-viewer-panel>
                    </div>
                } @else if (LegacyBody.trim().length > 0) {
                    <div class="mjt-doc-markdown">
                        <mj-markdown [data]="LegacyBody"></mj-markdown>
                    </div>
                } @else {
                    <p class="mjt-doc-empty">No report body recorded yet.</p>
                }
            </div>
        </section>
    `,
    styles: [`
        :host {
            display: block;
            margin-bottom: var(--mj-space-4);
        }

        .mjt-doc-panel {
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

        .mjt-doc-panel__header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: var(--mj-space-3);
            padding-bottom: var(--mj-space-3);
            border-bottom: 1px solid var(--mj-border-subtle);
        }

        .mjt-doc-panel__title-group {
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
        }

        .mjt-doc-panel__icon {
            color: var(--mj-brand-primary);
            font-size: var(--mj-text-lg);
        }

        .mjt-doc-panel__title {
            margin: 0;
            font-size: var(--mj-text-base);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }

        .mjt-doc-panel__subtitle {
            margin: var(--mj-space-1) 0 0;
            font-size: var(--mj-text-xs);
            color: var(--mj-text-muted);
        }

        .mjt-doc-panel__controls {
            display: inline-flex;
            align-items: center;
            flex-wrap: wrap;
            gap: var(--mj-space-2);
        }

        .mjt-doc-badge {
            display: inline-flex;
            align-items: center;
            gap: var(--mj-space-1);
            padding: var(--mj-space-1) var(--mj-space-2);
            border-radius: var(--mj-radius-sm);
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
        }

        .mjt-doc-badge--artifact {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }

        .mjt-doc-badge--legacy {
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
        }

        .mjt-doc-tabs {
            display: inline-flex;
            gap: var(--mj-space-1);
            padding: var(--mj-space-1);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
        }

        .mjt-doc-tab {
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

        .mjt-doc-tab--active {
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            box-shadow: var(--mj-shadow-sm);
        }

        .mjt-doc-tab:focus-visible {
            outline: 2px solid var(--mj-brand-primary);
            outline-offset: 2px;
        }

        .mjt-doc-notice {
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
            padding: var(--mj-space-2) var(--mj-space-3);
            border-radius: var(--mj-radius-md);
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            font-size: var(--mj-text-xs);
        }

        .mjt-artifact-viewer-host {
            min-height: 320px;
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-md);
            overflow: hidden;
            background: var(--mj-bg-surface-card);
        }

        .mjt-doc-markdown {
            padding: var(--mj-space-3);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-size: var(--mj-text-sm);
            line-height: 1.6;
        }

        .mjt-doc-loading,
        .mjt-doc-empty {
            margin: 0;
            font-size: var(--mj-text-sm);
            color: var(--mj-text-muted);
        }
    `],
})
export class WorkReportArtifactPanel
    extends BaseFormPanel<mjBizAppsTasksWorkReportEntity>
    implements OnInit, OnChanges
{
    private readonly cdr = inject(ChangeDetectorRef, { optional: true });

    public ViewMode: WorkReportDocumentViewMode = 'artifact';
    public IsResolving = false;
    public Resolved: ResolvedArtifactContent | null = null;

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

    public get ShowArtifactViewer(): boolean {
        return this.HasAccessibleArtifact && this.ViewMode === 'artifact';
    }

    public get VersionNumber(): number | null {
        return this.Resolved?.VersionNumber ?? null;
    }

    public get DisplayTitle(): string {
        return (
            this.Resolved?.ArtifactName?.trim() ||
            this.Record?.Title?.trim() ||
            'Work Report Document'
        );
    }

    public get LegacyBody(): string {
        return typeof this.Record?.Body === 'string' ? this.Record.Body : '';
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

    public SetViewMode(mode: WorkReportDocumentViewMode): void {
        if (this.ViewMode === mode) return;
        this.ViewMode = mode;
        this.persistViewMode(mode);
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
                    IncludeContent: false,
                },
            );
        } catch (err) {
            LogError(
                `WorkReportArtifactPanel: failed to resolve artifact ${this.ArtifactID}: ${err instanceof Error ? err.message : String(err)}`,
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

    private loadSavedViewMode(): void {
        try {
            const raw = UserInfoEngine.Instance.GetSetting(WORK_REPORT_VIEW_MODE_SETTING_KEY);
            if (raw === 'artifact' || raw === 'body') {
                this.ViewMode = raw;
            }
        } catch {
            // UserInfoEngine may not be initialized in isolated unit tests
        }
    }

    private persistViewMode(mode: WorkReportDocumentViewMode): void {
        try {
            UserInfoEngine.Instance.SetSettingDebounced(WORK_REPORT_VIEW_MODE_SETTING_KEY, mode);
        } catch {
            // UserInfoEngine may not be initialized in isolated unit tests
        }
    }
}
