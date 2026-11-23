import { describe, expect, it } from 'vitest';
import { BaseEntity } from '@memberjunction/core';
import { MJGlobal } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskRiskAssessmentEntity,
} from '../generated/entity_subclasses.js';
import {
    ParseTaskRiskItems,
    SerializeTaskRiskItems,
    TASK_RISK_ASSESSMENT_ENTITY,
    TaskRiskAssessmentEntity,
    TryParseTaskRiskItems,
    type TaskRiskHealthStatus,
    type TaskRiskItem,
} from '../custom/TaskRiskAssessmentEntitySubclass.js';

describe('TaskRiskAssessmentEntity & typed Risks JSON helpers', () => {
    it('serializes and parses strongly typed TaskRiskItem arrays cleanly', () => {
        const items: TaskRiskItem[] = [
            {
                kind: 'blocked_dependency',
                severity: 'high',
                evidenceLinks: ['task://22222222-2222-4222-8222-222222222222'],
                suggestedMitigation: 'Escalate API contract sign-off to unblock downstream integration.',
            },
            {
                kind: 'capacity_gap',
                severity: 'medium',
                evidenceLinks: ['calendar://free-busy/person-1'],
                suggestedMitigation: 'Rebalance Q4 deliverables across secondary engineers.',
            },
        ];

        const json = SerializeTaskRiskItems(items);
        const parsed = ParseTaskRiskItems(json);
        expect(parsed).toEqual(items);

        const validation = TryParseTaskRiskItems(json);
        expect(validation.valid).toBe(true);
        expect(validation.items).toHaveLength(2);
    });

    it('handles null, empty, and malformed Risks JSON gracefully while surfacing validation errors', () => {
        expect(ParseTaskRiskItems(null)).toEqual([]);
        expect(ParseTaskRiskItems('')).toEqual([]);
        expect(ParseTaskRiskItems('{not-json')).toEqual([]);

        const malformed = TryParseTaskRiskItems('{not-json');
        expect(malformed.valid).toBe(false);
        expect(malformed.error).toContain('valid JSON');

        const badShape = TryParseTaskRiskItems(
            JSON.stringify([{ kind: 'velocity', severity: 'extreme', evidenceLinks: [], suggestedMitigation: 'x' }]),
        );
        expect(badShape.valid).toBe(false);
        expect(badShape.error).toContain('TaskRiskItem[]');

        expect(() =>
            SerializeTaskRiskItems([
                {
                    kind: '',
                    severity: 'low',
                    evidenceLinks: [],
                    suggestedMitigation: 'n/a',
                },
            ]),
        ).toThrow();
    });

    it('registers TaskRiskAssessmentEntity above mjBizAppsTasksTaskRiskAssessmentEntity in ClassFactory', () => {
        const factory = MJGlobal.Instance.ClassFactory;
        const winning = factory.GetRegistration(BaseEntity, TASK_RISK_ASSESSMENT_ENTITY);
        expect(winning?.SubClass).toBe(TaskRiskAssessmentEntity);
        expect(TaskRiskAssessmentEntity.prototype).toBeInstanceOf(mjBizAppsTasksTaskRiskAssessmentEntity);

        const all = factory.GetAllRegistrations(BaseEntity, TASK_RISK_ASSESSMENT_ENTITY);
        const generatedReg = all.find((r) => r.SubClass === mjBizAppsTasksTaskRiskAssessmentEntity);
        const customReg = all.find((r) => r.SubClass === TaskRiskAssessmentEntity);
        expect(generatedReg).toBeDefined();
        expect(customReg).toBeDefined();
        expect(customReg!.Priority).toBeGreaterThan(generatedReg!.Priority);
    });

    it('derives TaskRiskHealthStatus cleanly from generated entity types and validates fields without .Get()/.Set()', () => {
        const statusSample: TaskRiskHealthStatus = 'AtRisk';
        const taskStatusCompat: NonNullable<mjBizAppsTasksTaskEntity['HealthStatus']> = statusSample;
        expect(taskStatusCompat).toBe('AtRisk');

        const validResult = TryParseTaskRiskItems(
            SerializeTaskRiskItems([
                {
                    kind: 'overdue_milestone',
                    severity: 'critical',
                    evidenceLinks: ['task://root'],
                    suggestedMitigation: 'Trigger daily review cadence.',
                },
            ]),
        );
        expect(validResult.valid).toBe(true);
    });
});
