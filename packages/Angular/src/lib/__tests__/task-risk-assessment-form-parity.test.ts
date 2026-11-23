import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { MJGlobal } from '@memberjunction/global';
import { BaseFormComponent, BaseFormPanel } from '@memberjunction/ng-base-forms';
import {
    SerializeTaskRiskItems,
    TASK_RISK_ASSESSMENT_ENTITY,
    type TaskRiskAssessmentEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    LoadBizAppsTasksClient,
    TaskRiskAssessmentRisksPanel,
    mjBizAppsTasksTaskRiskAssessmentFormComponent,
} from '../../public-api';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ANGULAR_LIB_DIR = join(__dirname, '..');

describe('TaskRiskAssessment Dual Form Registration Parity & OpenApp v3 Compliance', () => {
    it('retains both BaseFormComponent and BaseFormPanel registrations in ClassFactory and startupExport', () => {
        LoadBizAppsTasksClient();

        expect(mjBizAppsTasksTaskRiskAssessmentFormComponent).toBeDefined();
        expect(TaskRiskAssessmentRisksPanel).toBeDefined();

        const formReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormComponent,
            TASK_RISK_ASSESSMENT_ENTITY,
        );
        expect(formReg).toBeDefined();
        expect(formReg?.SubClass).toBe(mjBizAppsTasksTaskRiskAssessmentFormComponent);

        const panelReg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormPanel,
            'form-panel:TaskRiskAssessments:risks',
        );
        expect(panelReg).toBeDefined();
        expect(panelReg?.SubClass).toBe(TaskRiskAssessmentRisksPanel);

        const entityPanels = MJGlobal.Instance.ClassFactory.GetAllRegistrationsByMetadata(
            BaseFormPanel,
            (meta) => meta?.['entity'] === TASK_RISK_ASSESSMENT_ENTITY,
        );
        expect(entityPanels.some((r) => r.SubClass === TaskRiskAssessmentRisksPanel)).toBe(true);
    });

    it('renders strongly typed TaskRiskAssessment fields and parsed Risks in TaskRiskAssessmentRisksPanel', () => {
        const panel = new TaskRiskAssessmentRisksPanel();
        const recordStub: Pick<
            TaskRiskAssessmentEntity,
            | 'HealthStatus'
            | 'ForecastConfidence'
            | 'ForecastCompletionDate'
            | 'MLBreachProbability'
            | 'PromptTokens'
            | 'CompletionTokens'
            | 'TotalCostUSD'
            | 'Risks'
        > = {
            HealthStatus: 'AtRisk',
            ForecastConfidence: 68,
            ForecastCompletionDate: new Date('2026-12-18T00:00:00.000Z'),
            MLBreachProbability: 0.342,
            PromptTokens: 1500,
            CompletionTokens: 420,
            TotalCostUSD: 0.0234,
            Risks: SerializeTaskRiskItems([
                {
                    kind: 'blocked_dependency',
                    severity: 'high',
                    evidenceLinks: ['task://dep-1'],
                    suggestedMitigation: 'Resolve upstream schema approval.',
                },
            ]),
        };

        panel.Record = recordStub as TaskRiskAssessmentEntity;

        expect(panel.HealthStatus).toBe('AtRisk');
        expect(panel.HealthStatusLabel).toBe('At Risk');
        expect(panel.ForecastDateLabel).toBe('2026-12-18');
        expect(panel.ConfidenceLabel).toBe('68%');
        expect(panel.BreachProbabilityLabel).toBe('34.2%');
        expect(panel.CostLabel).toBe('$0.0234');
        expect(panel.TokensLabel).toBe('1500 in / 420 out tokens');
        expect(panel.ParsedRisks).toHaveLength(1);
        expect(panel.ParsedRisks[0].kind).toBe('blocked_dependency');
        expect(panel.SeverityLabel(panel.ParsedRisks[0].severity)).toBe('HIGH');
    });

    it('uses semantic --mj-* CSS custom properties with OnPush and zero raw color literals or forbidden calls', () => {
        const panelSource = readFileSync(join(ANGULAR_LIB_DIR, 'form-panels/task-risk-assessment.panel.ts'), 'utf8');
        expect(panelSource).toContain('ChangeDetectionStrategy.OnPush');
        expect(panelSource).not.toMatch(/\bwindow\.print\s*\(/);
        expect(panelSource).not.toMatch(/\blocalStorage\s*[.\[]/);
        expect(panelSource).not.toMatch(/\.Get\s*\(\s*['"]/);
        expect(panelSource).not.toMatch(/\.Set\s*\(\s*['"]/);

        const stylesMatch = panelSource.match(/styles:\s*\[`([\s\S]*?)`\]/);
        expect(stylesMatch).not.toBeNull();
        const css = stylesMatch![1];
        expect(css).toContain('--mj-');
        expect(css).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
        expect(css).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);

        const templateMatch = panelSource.match(/template:\s*`([\s\S]*?)`/);
        expect(templateMatch).not.toBeNull();
        const html = templateMatch![1];
        expect(html).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
        expect(html).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);
    });
});
