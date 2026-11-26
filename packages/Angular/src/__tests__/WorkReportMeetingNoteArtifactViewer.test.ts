import '@angular/compiler';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ResolvedArtifactContent } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksMeetingNoteEntity, mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';

import { UserInfoEngine } from '@memberjunction/core-entities';

const {
    resolveSingleMock,
    resolveBatchMock,
} = vi.hoisted(() => ({
    resolveSingleMock: vi.fn(),
    resolveBatchMock: vi.fn(),
}));

vi.mock('@memberjunction/ng-artifacts', () => ({
    ArtifactsModule: class {},
}));

vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        ArtifactDualReadResolver: {
            Instance: {
                ResolveSingle: resolveSingleMock,
                ResolveBatch: resolveBatchMock,
            },
        },
    };
});

import {
    WorkReportArtifactPanel,
    WORK_REPORT_VIEW_MODE_SETTING_KEY,
} from '../lib/form-panels/work-report-artifact.panel';
import {
    MeetingNoteArtifactPanel,
    MEETING_NOTE_VIEW_MODE_SETTING_KEY,
    type MeetingNotePublishResult,
} from '../lib/form-panels/meeting-note-artifact.panel';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const LIB_DIR = join(__dirname, '../lib');

const WORK_REPORT_ID = '11111111-1111-4111-8111-111111111111';
const MEETING_NOTE_ID = '22222222-2222-4222-8222-222222222222';
const ARTIFACT_ID = '33333333-3333-4333-8333-333333333333';
const VERSION_1_ID = '44444444-4444-4444-8444-444444444444';
const VERSION_2_ID = '55555555-5555-4555-8555-555555555555';

function createInInjector<T>(factory: () => T): T {
    const cdr: ChangeDetectorRef = {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: cdr }],
    });
    return runInInjectionContext(injector, factory);
}

describe('WorkReport & MeetingNote <mj-artifact-viewer-panel> UI Integration', () => {
    const setSettingDebouncedMock = vi.fn();

    beforeEach(() => {
        vi.clearAllMocks();
        vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
        vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation((key: string, value: string) => {
            setSettingDebouncedMock(key, value);
        });
    });

    it('WorkReportArtifactPanel renders <mj-artifact-viewer-panel> when ArtifactID resolves and persists view mode via UserInfoEngine', async () => {
        const resolved: ResolvedArtifactContent = {
            RecordID: WORK_REPORT_ID,
            Source: 'artifact',
            FallbackReason: null,
            Content: '# Executive Summary\nMilestone delivered.',
            LegacyBody: 'Legacy body text',
            ArtifactID: ARTIFACT_ID,
            ArtifactName: 'Q4 Executive Work Report',
            ArtifactDescription: 'Weekly digest',
            ArtifactTypeID: '5E5883C2-0185-4E1E-8A1C-F514DBF52DB7',
            ArtifactTypeName: 'Markdown Document',
            VersionID: VERSION_1_ID,
            VersionNumber: 3,
            VersionName: 'Q4 Executive Work Report',
            MimeType: 'text/markdown',
            ContentMode: 'Text',
            UpdatedAt: '2026-11-26T12:00:00.000Z',
        };
        resolveSingleMock.mockResolvedValue(resolved);

        const panel = createInInjector(() => new WorkReportArtifactPanel());
        panel.Record = {
            ID: WORK_REPORT_ID,
            Title: 'Weekly Work Report',
            Body: 'Legacy body text',
            ArtifactID: ARTIFACT_ID,
        } as Partial<mjBizAppsTasksWorkReportEntity> as mjBizAppsTasksWorkReportEntity;

        await panel.ngOnInit();

        expect(panel.HasLinkedArtifactId).toBe(true);
        expect(panel.HasAccessibleArtifact).toBe(true);
        expect(panel.ShowArtifactViewer).toBe(true);
        expect(panel.VersionNumber).toBe(3);
        expect(panel.DisplayTitle).toBe('Q4 Executive Work Report');

        panel.SetViewMode('body');
        expect(panel.ShowArtifactViewer).toBe(false);
        expect(setSettingDebouncedMock).toHaveBeenCalledWith(WORK_REPORT_VIEW_MODE_SETTING_KEY, 'body');
    });

    it('WorkReportArtifactPanel falls back cleanly to legacy Body when ArtifactID is null or inaccessible', async () => {
        // Case 1: null ArtifactID — never calls resolver
        const legacyPanel = createInInjector(() => new WorkReportArtifactPanel());
        legacyPanel.Record = {
            ID: WORK_REPORT_ID,
            Title: 'Historical Work Report',
            Body: '### Completed\n- Delivered schema migration.',
            ArtifactID: null,
        } as Partial<mjBizAppsTasksWorkReportEntity> as mjBizAppsTasksWorkReportEntity;

        await legacyPanel.ngOnInit();
        expect(resolveSingleMock).not.toHaveBeenCalled();
        expect(legacyPanel.HasLinkedArtifactId).toBe(false);
        expect(legacyPanel.HasAccessibleArtifact).toBe(false);
        expect(legacyPanel.ShowArtifactViewer).toBe(false);
        expect(legacyPanel.LegacyBody).toContain('Delivered schema migration.');

        // Case 2: populated ArtifactID with zero accessible versions -> graceful fallback
        resolveSingleMock.mockResolvedValue({
            RecordID: WORK_REPORT_ID,
            Source: 'body',
            FallbackReason: 'version_not_accessible',
            Content: 'Legacy fallback summary',
            LegacyBody: 'Legacy fallback summary',
            ArtifactID: ARTIFACT_ID,
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
        } satisfies ResolvedArtifactContent);

        const inaccessiblePanel = createInInjector(() => new WorkReportArtifactPanel());
        inaccessiblePanel.Record = {
            ID: WORK_REPORT_ID,
            Title: 'Restricted Report',
            Body: 'Legacy fallback summary',
            ArtifactID: ARTIFACT_ID,
        } as Partial<mjBizAppsTasksWorkReportEntity> as mjBizAppsTasksWorkReportEntity;

        await inaccessiblePanel.ngOnInit();
        expect(inaccessiblePanel.HasLinkedArtifactId).toBe(true);
        expect(inaccessiblePanel.HasAccessibleArtifact).toBe(false);
        expect(inaccessiblePanel.ShowArtifactViewer).toBe(false);
        expect(inaccessiblePanel.LegacyBody).toBe('Legacy fallback summary');
    });

    it('MeetingNoteArtifactPanel guards blank Body, prevents concurrent double-clicks, transitions to Published MJ Doc, and retains Live Scratchpad toggle + ProposedTasks', async () => {
        const panel = createInInjector(() => new MeetingNoteArtifactPanel());
        const proposedTasksJson = JSON.stringify([
            { id: 'proposal-1', title: 'Review API contract', status: 'Pending', taskId: null },
        ]);

        // Blank body disables Publish CTA and surfaces validation banner
        panel.Record = {
            ID: MEETING_NOTE_ID,
            Title: 'Weekly Standup',
            Body: '   ',
            ProposedTasks: proposedTasksJson,
            ArtifactID: null,
        } as Partial<mjBizAppsTasksMeetingNoteEntity> as mjBizAppsTasksMeetingNoteEntity;

        await panel.ngOnInit();
        expect(panel.CanPublish).toBe(false);
        expect(panel.PublishButtonLabel).toBe('Publish as MJ Doc');
        expect(panel.ActiveView).toBe('scratchpad');

        const blocked = await panel.PublishAsMJDoc();
        expect(blocked).toBeNull();
        expect(panel.StatusBanner?.Type).toBe('error');

        // Populate Body and test concurrent double-click guard
        panel.Record.Body = '## Standup Minutes\n- Confirmed milestone timeline.';
        expect(panel.CanPublish).toBe(true);

        let resolvePublish!: (value: MeetingNotePublishResult) => void;
        const publishSpy = vi.fn(
            () =>
                new Promise<MeetingNotePublishResult>((res) => {
                    resolvePublish = res;
                }),
        );
        panel.PublishHandler = publishSpy;

        const firstClick = panel.PublishAsMJDoc();
        expect(panel.IsPublishing).toBe(true);
        expect(panel.CanPublish).toBe(false);
        expect(panel.PublishButtonLabel).toBe('Publishing…');

        // Second concurrent click is ignored while first is in-flight
        const secondClick = await panel.PublishAsMJDoc();
        expect(secondClick).toBeNull();
        expect(publishSpy).toHaveBeenCalledTimes(1);

        resolvePublish({
            ArtifactID: ARTIFACT_ID,
            ArtifactVersionID: VERSION_1_ID,
            VersionNumber: 1,
            CreatedNewArtifact: true,
        });
        const firstResult = await firstClick;

        expect(firstResult?.ArtifactID).toBe(ARTIFACT_ID);
        expect(panel.IsPublishing).toBe(false);
        expect(panel.ArtifactID).toBe(ARTIFACT_ID);
        expect(panel.ShowPublishedDocView).toBe(true);
        expect(panel.PublishButtonLabel).toBe('Publish New Version');
        expect(panel.ProposedTasks).toHaveLength(1);
        expect(panel.ProposedTasks[0].title).toBe('Review API contract');
        expect(setSettingDebouncedMock).toHaveBeenCalledWith(MEETING_NOTE_VIEW_MODE_SETTING_KEY, 'published');

        // Switch back to Live Scratchpad, edit Body -> Unpublished edits indicator appears, then publish v2
        panel.SetView('scratchpad');
        expect(panel.ActiveView).toBe('scratchpad');
        expect(panel.ShowPublishedDocView).toBe(false);
        panel.Record.Body = '## Standup Minutes (Updated)\n- Added Q4 launch readiness checklist.';
        expect(panel.HasUnpublishedEdits).toBe(true);

        panel.PublishHandler = vi.fn(async () => ({
            ArtifactID: ARTIFACT_ID,
            ArtifactVersionID: VERSION_2_ID,
            VersionNumber: 2,
            CreatedNewArtifact: false,
        }));

        const secondVersion = await panel.PublishAsMJDoc();
        expect(secondVersion?.VersionNumber).toBe(2);
        expect(secondVersion?.CreatedNewArtifact).toBe(false);
        expect(panel.VersionNumber).toBe(2);
        expect(panel.HasUnpublishedEdits).toBe(false);
        expect(panel.ShowPublishedDocView).toBe(true);
    });

    it('integrates <mj-artifact-viewer-panel> and formatted <mj-markdown> fallback across ChiefOfStaffWorkReports, WorkReportArtifactPanel, MeetingNoteArtifactPanel, and MeetingNotesPanel', () => {
        const cosHtml = readFileSync(join(LIB_DIR, 'chief-of-staff/chief-of-staff-work-reports.component.html'), 'utf8');
        const wrPanelTs = readFileSync(join(LIB_DIR, 'form-panels/work-report-artifact.panel.ts'), 'utf8');
        const mnPanelTs = readFileSync(join(LIB_DIR, 'form-panels/meeting-note-artifact.panel.ts'), 'utf8');
        const meetingSectionsTs = readFileSync(join(LIB_DIR, 'form-panels/meeting-sections.panels.ts'), 'utf8');

        expect(cosHtml).toContain('<mj-artifact-viewer-panel');
        expect(cosHtml).toContain('<mj-markdown [data]="sel.Body"></mj-markdown>');
        expect(cosHtml).not.toContain('<pre class="cos-markdown-preview">{{ sel.Body }}</pre>');

        expect(wrPanelTs).toContain('<mj-artifact-viewer-panel');
        expect(wrPanelTs).toContain('<mj-markdown [data]="LegacyBody"></mj-markdown>');

        expect(mnPanelTs).toContain('<mj-artifact-viewer-panel');
        expect(mnPanelTs).toContain('Publish as MJ Doc');
        expect(mnPanelTs).toContain('Publish New Version');
        expect(mnPanelTs).toContain('Published MJ Doc');
        expect(mnPanelTs).toContain('Live Scratchpad');

        expect(meetingSectionsTs).toContain('<mj-artifact-viewer-panel');
        expect(meetingSectionsTs).toContain('PublishAsMJDocRequested');
    });
});
