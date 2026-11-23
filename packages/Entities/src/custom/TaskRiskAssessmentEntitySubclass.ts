import { BaseEntity, ValidationErrorInfo, ValidationErrorType, ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { z } from 'zod';
import { mjBizAppsTasksTaskRiskAssessmentEntity } from '../generated/entity_subclasses.js';

/**
 * Canonical entity name for Task Risk Assessments.
 */
export const TASK_RISK_ASSESSMENT_ENTITY = 'MJ_BizApps_Tasks: Task Risk Assessments' as const;

/**
 * Health status union derived directly from the generated Task Risk Assessment entity type.
 */
export type TaskRiskHealthStatus = mjBizAppsTasksTaskRiskAssessmentEntity['HealthStatus'];

/**
 * Allowed severity levels for an individual risk item inside {@link TaskRiskAssessmentEntity.Risks}.
 */
export const TASK_RISK_SEVERITIES = ['low', 'medium', 'high', 'critical'] as const;
export type TaskRiskSeverity = (typeof TASK_RISK_SEVERITIES)[number];

/**
 * Strongly-typed risk entry stored inside the `Risks` JSON array column.
 */
export interface TaskRiskItem {
    kind: string;
    severity: TaskRiskSeverity;
    evidenceLinks: string[];
    suggestedMitigation: string;
}

/**
 * Zod schema validating a single {@link TaskRiskItem}.
 */
export const TaskRiskItemSchema = z.object({
    kind: z.string().trim().min(1, 'Risk kind must be a non-empty string.'),
    severity: z.enum(TASK_RISK_SEVERITIES),
    evidenceLinks: z.array(z.string()),
    suggestedMitigation: z.string(),
});

/**
 * Zod schema validating the JSON array stored in `TaskRiskAssessment.Risks`.
 */
export const TaskRiskItemsSchema = z.array(TaskRiskItemSchema);

export interface ParseTaskRiskItemsResult {
    valid: boolean;
    items: TaskRiskItem[];
    error?: string;
}

/**
 * Parses and validates a raw `Risks` JSON string into strongly typed {@link TaskRiskItem} entries,
 * returning structured validation status without throwing.
 */
export function TryParseTaskRiskItems(raw: string | null | undefined): ParseTaskRiskItemsResult {
    if (raw == null) {
        return { valid: true, items: [] };
    }
    const trimmed = raw.trim();
    if (!trimmed) {
        return { valid: true, items: [] };
    }
    let parsedJson: ReturnType<typeof JSON.parse>;
    try {
        parsedJson = JSON.parse(trimmed);
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        return { valid: false, items: [], error: `Risks must be valid JSON: ${msg}` };
    }

    const result = TaskRiskItemsSchema.safeParse(parsedJson);
    if (!result.success) {
        const issueMsg = result.error.issues.map((i) => `${i.path.join('.') || 'root'}: ${i.message}`).join('; ');
        return { valid: false, items: [], error: `Risks JSON does not match TaskRiskItem[]: ${issueMsg}` };
    }
    const items: TaskRiskItem[] = result.data.map((item) => ({
        kind: item.kind ?? '',
        severity: item.severity ?? 'low',
        evidenceLinks: item.evidenceLinks ?? [],
        suggestedMitigation: item.suggestedMitigation ?? '',
    }));
    return { valid: true, items };
}

/**
 * Parses a raw `Risks` JSON string into strongly typed {@link TaskRiskItem} entries.
 * Returns an empty array when null, empty, or invalid.
 */
export function ParseTaskRiskItems(raw: string | null | undefined): TaskRiskItem[] {
    return TryParseTaskRiskItems(raw).items;
}

/**
 * Validates and serializes strongly typed {@link TaskRiskItem} entries for storage in `TaskRiskAssessment.Risks`.
 */
export function SerializeTaskRiskItems(items: ReadonlyArray<TaskRiskItem>): string {
    const validated = TaskRiskItemsSchema.parse(items);
    return JSON.stringify(validated);
}

/**
 * Client-safe entity subclass for `MJ_BizApps_Tasks: Task Risk Assessments`.
 *
 * Provides strongly-typed `Risks` JSON array helpers and client-safe validation
 * with zero Node-only imports. Server-only root task synchronization lives in
 * `TaskRiskAssessmentEntityServer` (`@mj-biz-apps/tasks-entities-server`).
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Risk Assessments')
export class TaskRiskAssessmentEntity extends mjBizAppsTasksTaskRiskAssessmentEntity {
    /**
     * Returns the parsed strongly-typed risk items from `this.Risks`.
     */
    public GetParsedRisks(): TaskRiskItem[] {
        return ParseTaskRiskItems(this.Risks);
    }

    /**
     * Validates and serializes strongly-typed risk items into `this.Risks`.
     */
    public SetParsedRisks(items: ReadonlyArray<TaskRiskItem>): void {
        this.Risks = SerializeTaskRiskItems(items);
    }

    public override Validate(): ValidationResult {
        const result = super.Validate();

        if (!this.TaskID || !this.TaskID.trim()) {
            result.Errors.push(
                new ValidationErrorInfo(
                    'TaskID',
                    'TaskID is required for a Task Risk Assessment.',
                    this.TaskID,
                    ValidationErrorType.Failure,
                ),
            );
        }

        const parsedRisks = TryParseTaskRiskItems(this.Risks);
        if (!parsedRisks.valid) {
            result.Errors.push(
                new ValidationErrorInfo(
                    'Risks',
                    parsedRisks.error ?? 'Risks must be a valid JSON array of TaskRiskItem objects.',
                    this.Risks,
                    ValidationErrorType.Failure,
                ),
            );
        }

        if (this.PromptTokens != null && this.PromptTokens < 0) {
            result.Errors.push(
                new ValidationErrorInfo(
                    'PromptTokens',
                    'Prompt tokens must be zero or greater.',
                    this.PromptTokens,
                    ValidationErrorType.Failure,
                ),
            );
        }

        if (this.CompletionTokens != null && this.CompletionTokens < 0) {
            result.Errors.push(
                new ValidationErrorInfo(
                    'CompletionTokens',
                    'Completion tokens must be zero or greater.',
                    this.CompletionTokens,
                    ValidationErrorType.Failure,
                ),
            );
        }

        if (this.TotalCostUSD != null && this.TotalCostUSD < 0) {
            result.Errors.push(
                new ValidationErrorInfo(
                    'TotalCostUSD',
                    'Total cost USD must be zero or greater.',
                    this.TotalCostUSD,
                    ValidationErrorType.Failure,
                ),
            );
        }

        result.Success = result.Success && result.Errors.length === 0;
        return result;
    }
}
