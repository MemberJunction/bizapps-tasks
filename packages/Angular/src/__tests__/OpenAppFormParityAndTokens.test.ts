import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it, vi } from 'vitest';
import { MJGlobal } from '@memberjunction/global';
import { BaseFormComponent, BaseFormPanel } from '@memberjunction/ng-base-forms';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import { MEETING_NOTE_ENTITY, WORK_REPORTS_ENTITY_NAME } from '@mj-biz-apps/tasks-core';

vi.mock('@memberjunction/ng-artifacts', () => ({
    ArtifactsModule: class {},
}));

import {
    LoadBizAppsTasksClient,
    MeetingNoteArtifactPanel,
    WorkReportArtifactPanel,
    mjBizAppsTasksMeetingNoteFormComponent,
    mjBizAppsTasksWorkReportFormComponent,
} from '../public-api';

interface AppManifestNavItem {
    Label: string;
    ResourceType: string;
    DriverClass?: string;
}

interface AppMetadataEntry {
    fields?: {
        Name?: string;
        DefaultNavItems?: AppManifestNavItem[];
    };
}

interface EntityMetadataEntry {
    primaryKey?: { ID?: string };
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = resolve(__dirname, '../../../..');
const ANGULAR_LIB_DIR = join(__dirname, '../lib');

const RAW_COLOR_LITERAL_RE = /#[0-9a-fA-F]{3,8}\b|\b(?:rgb|rgba|hsl|hsla)\s*\(/i;

describe('OpenApp v3 Readiness: Dual Form Registration Parity, Nav Parity & --mj-* Token Hygiene', () => {
    it('preserves Dual Form Registration Parity for every entity in metadata/entities/.entities.json and retains WorkReport & MeetingNote forms + panels from startupExport', () => {
        LoadBizAppsTasksClient();

        // Explicit assertions on WorkReport and MeetingNote Dual Form Registration Parity
        expect(mjBizAppsTasksWorkReportFormComponent).toBeDefined();
        expect(mjBizAppsTasksMeetingNoteFormComponent).toBeDefined();
        expect(WorkReportArtifactPanel).toBeDefined();
        expect(MeetingNoteArtifactPanel).toBeDefined();

        const wrFormReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormComponent,
            WORK_REPORTS_ENTITY_NAME,
        );
        expect(wrFormReg).toBeDefined();
        expect(wrFormReg?.SubClass).toBe(mjBizAppsTasksWorkReportFormComponent);

        const mnFormReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormComponent,
            MEETING_NOTE_ENTITY,
        );
        expect(mnFormReg).toBeDefined();
        expect(mnFormReg?.SubClass).toBe(mjBizAppsTasksMeetingNoteFormComponent);

        const wrPanelReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormPanel,
            'form-panel:WorkReports:artifact',
        );
        expect(wrPanelReg).toBeDefined();
        expect(wrPanelReg?.SubClass).toBe(WorkReportArtifactPanel);

        const mnPanelReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormPanel,
            'form-panel:MeetingNotes:artifact',
        );
        expect(mnPanelReg).toBeDefined();
        expect(mnPanelReg?.SubClass).toBe(MeetingNoteArtifactPanel);

        // Verify EVERY entity listed in metadata/entities/.entities.json has an active BaseFormComponent registration
        const entitiesMeta = JSON.parse(
            readFileSync(join(REPO_ROOT, 'metadata/entities/.entities.json'), 'utf8'),
        ) as EntityMetadataEntry[];
        const entityNames = entitiesMeta
            .map((e) => e.primaryKey?.ID ?? '')
            .map((id) => {
                const match = /@lookup:MJ: Entities\.Name=(.+)$/.exec(id);
                return match ? match[1].trim() : '';
            })
            .filter(Boolean);

        expect(entityNames.length).toBeGreaterThanOrEqual(20);
        for (const entityName of entityNames) {
            const reg = MJGlobal.Instance.ClassFactory.GetRegistration(BaseFormComponent, entityName);
            expect(reg, `Missing BaseFormComponent registration for '${entityName}'`).toBeDefined();
        }
    });

    it('preserves BaseResourceComponent navigation parity for all DefaultNavItems in metadata/applications/*.json', () => {
        LoadBizAppsTasksClient();

        for (const file of ['metadata/applications/.tasks-application.json', 'metadata/applications/.meetings-application.json']) {
            const entries = JSON.parse(readFileSync(join(REPO_ROOT, file), 'utf8')) as AppMetadataEntry[];
            for (const entry of entries) {
                for (const nav of entry.fields?.DefaultNavItems ?? []) {
                    if (nav.ResourceType === 'Custom' && nav.DriverClass) {
                        const reg = MJGlobal.Instance.ClassFactory.GetRegistration(
                            BaseResourceComponent,
                            nav.DriverClass,
                        );
                        expect(reg, `Missing BaseResourceComponent registration for '${nav.DriverClass}' (${file})`).toBeDefined();
                    }
                }
            }
        }

        // Also confirm ChiefOfStaffWorkReportsResource is registered
        const cosReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseResourceComponent,
            'BizAppsTasksChiefOfStaffWorkReports',
        );
        expect(cosReg).toBeDefined();
    });

    it('enforces OnPush, --mj-* semantic tokens (zero raw hex/rgb/rgba/hsl), UserInfoEngine (zero localStorage), zero window.print(), and zero .Get()/.Set() across Slice 2 Angular files', () => {
        const componentTsFiles = [
            'form-panels/work-report-artifact.panel.ts',
            'form-panels/meeting-note-artifact.panel.ts',
            'chief-of-staff/chief-of-staff-work-reports.component.ts',
        ];

        for (const rel of componentTsFiles) {
            const src = readFileSync(join(ANGULAR_LIB_DIR, rel), 'utf8');
            expect(src, `${rel} must use ChangeDetectionStrategy.OnPush`).toContain('ChangeDetectionStrategy.OnPush');
            expect(src, `${rel} must not use localStorage`).not.toMatch(/\blocalStorage\s*[.\[]/);
            expect(src, `${rel} must not call window.print()`).not.toMatch(/\bwindow\.print\s*\(/);
            expect(src, `${rel} must not use BaseEntity.Get()/Set()`).not.toMatch(/\.\s*(?:Get|Set)\s*\(\s*['"]/);
            expect(src, `${rel} must not use ': any' or 'as any'`).not.toMatch(/\b(?:as\s+any|:\s*any)\b/);
            expect(src, `${rel} must not use lazy 'as unknown'`).not.toMatch(/\bas\s+unknown\b/);

            const inlineStylesMatch = src.match(/styles:\s*\[`([\s\S]*?)`\]/);
            if (inlineStylesMatch) {
                const css = inlineStylesMatch[1];
                expect(css, `${rel} styles must reference --mj-* design tokens`).toContain('--mj-');
                expect(css, `${rel} styles must not contain raw color literals`).not.toMatch(RAW_COLOR_LITERAL_RE);
            }

            const inlineTemplateMatch = src.match(/template:\s*`([\s\S]*?)`/);
            if (inlineTemplateMatch) {
                const html = inlineTemplateMatch[1];
                expect(html, `${rel} template must not contain raw color literals`).not.toMatch(RAW_COLOR_LITERAL_RE);
            }
        }

        const externalCssAndHtml = [
            'chief-of-staff/chief-of-staff-work-reports.component.css',
            'chief-of-staff/chief-of-staff-work-reports.component.html',
        ];
        for (const rel of externalCssAndHtml) {
            const content = readFileSync(join(ANGULAR_LIB_DIR, rel), 'utf8');
            if (rel.endsWith('.css')) {
                expect(content, `${rel} must use --mj-* tokens`).toContain('--mj-');
            }
            expect(content, `${rel} must not contain raw color literals`).not.toMatch(RAW_COLOR_LITERAL_RE);
        }
    });
});
