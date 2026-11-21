import { describe, it, expect } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
    FilterGenericCreatableTaskTypes,
    HasTaskTypeExtensionEntity,
    IsGenericCreatableTaskType,
    IsLegacyOkrTaskType,
    IsPlanningExtensionEntity,
    IsPlanningOwnedTaskType,
    IsTaskTypeExtensionEntityAvailable,
    LEGACY_OKR_TASK_TYPE_CODES,
    NormalizeTaskTypeExtensionEntity,
    PLANNING_OWNED_TASK_TYPE_CODES,
    PRIORITY_EXTENSION_ENTITY,
    PRIORITY_TASK_TYPE_CODE,
    type EntityRegistryLike,
    type TaskTypeClassificationInput,
} from '../custom/TaskTypeHelpers.js';

interface EntityFieldMetadataEntry {
    primaryKey: { ID: string };
    fields: {
        Description?: string;
        AutoUpdateDescription?: boolean;
    };
}

interface EntityMetadataEntry {
    primaryKey: { ID: string };
    fields: {
        Description?: string;
        AutoUpdateDescription?: boolean;
        SubtypeSelector?: string;
    };
    relatedEntities?: {
        'MJ: Entity Fields'?: EntityFieldMetadataEntry[];
    };
}

interface TaskTypeMetadataEntry {
    primaryKey: { ID: string };
    fields: {
        Name: string;
        Code: string;
        Description?: string;
        IsActive?: boolean;
        ExtensionEntity?: string | null;
    };
}

const currentDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(currentDir, '../../../..');

const METRIC_AND_CHECKIN_TASK_FIELDS = [
    'BaselineValue',
    'TargetValue',
    'CurrentValue',
    'UnitOfMeasure',
    'MetricDirection',
    'PlanningPeriod',
    'HealthStatus',
    'ConfidenceScore',
    'RollupWeight',
    'CheckInCadence',
    'LastCheckInAt',
    'NextCheckInDueAt',
] as const;

const OKR_ONLY_PHRASE_PATTERN = /\bOKR\b|key result|priority objective|priority\/OKR/i;

describe('Task metadata & generic measurable field descriptions (AC-1)', () => {
    it('documents all 12 metric/check-in Task fields and Task Check Ins generically in metadata/entities/.entities.json', () => {
        const entitiesRaw = readFileSync(resolve(repoRoot, 'metadata/entities/.entities.json'), 'utf8');
        const entities = JSON.parse(entitiesRaw) as EntityMetadataEntry[];

        const tasksEntity = entities.find(
            (e) => e.primaryKey.ID === '@lookup:MJ: Entities.Name=MJ_BizApps_Tasks: Tasks',
        );
        expect(tasksEntity).toBeDefined();
        expect(tasksEntity?.fields.SubtypeSelector).toContain('TypeID.ExtensionEntity');

        const taskFields = tasksEntity?.relatedEntities?.['MJ: Entity Fields'] ?? [];
        for (const fieldName of METRIC_AND_CHECKIN_TASK_FIELDS) {
            const entry = taskFields.find(
                (f) => f.primaryKey.ID === `@lookup:MJ: Entity Fields.Name=${fieldName}&EntityID=@parent:ID`,
            );
            expect(entry, `Expected metadata entry for Task.${fieldName}`).toBeDefined();
            expect(entry?.fields.AutoUpdateDescription).toBe(false);
            expect(entry?.fields.Description?.trim().length).toBeGreaterThan(10);
            expect(entry?.fields.Description).not.toMatch(OKR_ONLY_PHRASE_PATTERN);
        }

        const checkInsEntity = entities.find(
            (e) => e.primaryKey.ID === '@lookup:MJ: Entities.Name=MJ_BizApps_Tasks: Task Check Ins',
        );
        expect(checkInsEntity).toBeDefined();
        expect(checkInsEntity?.fields.AutoUpdateDescription).toBe(false);
        expect(checkInsEntity?.fields.Description).not.toMatch(OKR_ONLY_PHRASE_PATTERN);

        const checkInTaskId = checkInsEntity?.relatedEntities?.['MJ: Entity Fields']?.find(
            (f) => f.primaryKey.ID === '@lookup:MJ: Entity Fields.Name=TaskID&EntityID=@parent:ID',
        );
        expect(checkInTaskId).toBeDefined();
        expect(checkInTaskId?.fields.AutoUpdateDescription).toBe(false);
        expect(checkInTaskId?.fields.Description).not.toMatch(OKR_ONLY_PHRASE_PATTERN);
    });

    it('keeps Tasks -> Task Check Ins relationship intact in metadata/entity-relationships/.entity-relationships.json', () => {
        const relRaw = readFileSync(
            resolve(repoRoot, 'metadata/entity-relationships/.entity-relationships.json'),
            'utf8',
        );
        expect(relRaw).toContain(
            '@lookup:MJ: Entity Relationships.Entity=MJ_BizApps_Tasks: Tasks&RelatedEntity=MJ_BizApps_Tasks: Task Check Ins&RelatedEntityJoinField=TaskID',
        );
    });

    it('updates TypeScript JSDoc and Zod descriptions in generated entities & schemas for all 13 items without OKR-only phrasing', () => {
        const entitySource = readFileSync(
            resolve(repoRoot, 'packages/Entities/src/generated/entities/__mj_BizAppsTasks.ts'),
            'utf8',
        );
        const schemaSource = readFileSync(
            resolve(repoRoot, 'packages/Entities/src/generated/schemas/__mj_BizAppsTasks.ts'),
            'utf8',
        );

        const taskClassStart = entitySource.indexOf('export class mjBizAppsTasksTaskEntity');
        expect(taskClassStart).toBeGreaterThan(-1);
        const taskEntitySection = entitySource.slice(taskClassStart);

        const taskSchemaStart = schemaSource.indexOf('export const mjBizAppsTasksTaskSchema');
        expect(taskSchemaStart).toBeGreaterThan(-1);
        const taskSchemaSection = schemaSource.slice(taskSchemaStart);

        for (const fieldName of METRIC_AND_CHECKIN_TASK_FIELDS) {
            const entityFieldMatch = new RegExp(
                `\\* Field Name: ${fieldName}[\\s\\S]*?get ${fieldName}\\(`,
            ).exec(taskEntitySection);
            expect(entityFieldMatch, `Expected generated getter for ${fieldName}`).not.toBeNull();
            expect(entityFieldMatch?.[0]).not.toMatch(OKR_ONLY_PHRASE_PATTERN);

            const schemaFieldMatch = new RegExp(
                `${fieldName}: z\\.[\\s\\S]*?\\* Field Name: ${fieldName}[\\s\\S]*?\\\`\\),`,
            ).exec(taskSchemaSection);
            expect(schemaFieldMatch, `Expected Zod schema field for ${fieldName}`).not.toBeNull();
            expect(schemaFieldMatch?.[0]).not.toMatch(OKR_ONLY_PHRASE_PATTERN);
        }

        // CheckIns RelatedRecordCollection + TaskCheckIn entity & TaskID descriptions
        const checkInsRelMatch = /Related records: MJ_BizApps_Tasks: Task Check Ins[\s\S]*?public readonly CheckIns/.exec(
            entitySource,
        );
        expect(checkInsRelMatch).not.toBeNull();
        expect(checkInsRelMatch?.[0]).not.toMatch(OKR_ONLY_PHRASE_PATTERN);

        const checkInClassMatch = /MJ_BizApps_Tasks: Task Check Ins - strongly typed[\s\S]*?export class mjBizAppsTasksTaskCheckInEntity/.exec(
            entitySource,
        );
        expect(checkInClassMatch).not.toBeNull();
        expect(checkInClassMatch?.[0]).not.toMatch(OKR_ONLY_PHRASE_PATTERN);

        const checkInTaskIdSchemaMatch = /mjBizAppsTasksTaskCheckInSchema = z\.object\(\{[\s\S]*?Field Name: TaskID[\s\S]*?Description:[^\n]+/.exec(
            schemaSource,
        );
        expect(checkInTaskIdSchemaMatch).not.toBeNull();
        expect(checkInTaskIdSchemaMatch?.[0]).not.toMatch(OKR_ONLY_PHRASE_PATTERN);
    });
});

describe('PRIORITY TaskType ExtensionEntity metadata & standalone/Planning resilience (AC-2)', () => {
    it('leaves PRIORITY task-type ownership to Planning and keeps metadata/.mj-sync.json free of task-types-planning', () => {
        const rootSync = JSON.parse(
            readFileSync(resolve(repoRoot, 'metadata/.mj-sync.json'), 'utf8'),
        ) as { directoryOrder: string[] };
        expect(rootSync.directoryOrder).toContain('task-types');
        expect(rootSync.directoryOrder).not.toContain('task-types-planning');
        expect(existsSync(resolve(repoRoot, 'metadata/task-types-planning'))).toBe(false);
    });

    it('marks legacy OKR task types inactive and keeps standalone metadata free of Planning dependencies', () => {
        const coreTaskTypes = JSON.parse(
            readFileSync(resolve(repoRoot, 'metadata/task-types/.task-types.json'), 'utf8'),
        ) as TaskTypeMetadataEntry[];

        const priorityObjective = coreTaskTypes.find((t) => t.fields.Code === 'PRIORITY_OBJECTIVE');
        const keyResult = coreTaskTypes.find((t) => t.fields.Code === 'KEY_RESULT');
        expect(priorityObjective?.fields.IsActive).toBe(false);
        expect(keyResult?.fields.IsActive).toBe(false);

        const planningRefs = coreTaskTypes.filter((t) =>
            IsPlanningExtensionEntity(t.fields.ExtensionEntity),
        );
        expect(planningRefs).toEqual([]);
    });

    it('detects Planning IS-A ExtensionEntity availability in Planning-present and Planning-absent registries', () => {
        const priorityTaskType: TaskTypeClassificationInput = {
            Code: PRIORITY_TASK_TYPE_CODE,
            Name: 'Priority',
            ExtensionEntity: PRIORITY_EXTENSION_ENTITY,
            IsActive: true,
        };

        const planningPresentRegistry: EntityRegistryLike = {
            Entities: [
                { ID: 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee', Name: 'MJ_BizApps_Tasks: Tasks', ParentID: null },
                { ID: '11111111-2222-4333-8444-555555555555', Name: PRIORITY_EXTENSION_ENTITY, ParentID: 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee' },
            ],
        };
        const differentlyCasedUuidRegistry: EntityRegistryLike = {
            Entities: [
                { ID: 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee', Name: 'MJ_BizApps_Tasks: Tasks', ParentID: null },
                { ID: '11111111-2222-4333-8444-555555555555', Name: PRIORITY_EXTENSION_ENTITY, ParentID: 'AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE' },
            ],
        };
        const planningAbsentRegistry: EntityRegistryLike = {
            Entities: [
                { ID: 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee', Name: 'MJ_BizApps_Tasks: Tasks', ParentID: null },
            ],
        };
        const nonChildRegistry: EntityRegistryLike = {
            Entities: [
                { ID: 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee', Name: 'MJ_BizApps_Tasks: Tasks', ParentID: null },
                { ID: '11111111-2222-4333-8444-555555555555', Name: PRIORITY_EXTENSION_ENTITY, ParentID: null },
            ],
        };

        expect(IsTaskTypeExtensionEntityAvailable(priorityTaskType, planningPresentRegistry)).toBe(true);
        expect(IsTaskTypeExtensionEntityAvailable(priorityTaskType, differentlyCasedUuidRegistry)).toBe(true);
        expect(IsTaskTypeExtensionEntityAvailable(priorityTaskType, planningAbsentRegistry)).toBe(false);
        expect(IsTaskTypeExtensionEntityAvailable(priorityTaskType, nonChildRegistry)).toBe(false);
        expect(IsTaskTypeExtensionEntityAvailable(priorityTaskType, null)).toBe(false);
    });
});

describe('Generic creatable TaskType filter predicates', () => {
    const sampleTaskTypes: Array<TaskTypeClassificationInput & { ID: string }> = [
        { ID: '1', Code: 'GENERAL', Name: 'General', ExtensionEntity: null, IsActive: true },
        { ID: '2', Code: 'ACTION_ITEM', Name: 'Action Item', ExtensionEntity: null, IsActive: true },
        { ID: '3', Code: 'FOLLOW_UP', Name: 'Follow-up', ExtensionEntity: null, IsActive: true },
        { ID: '4', Code: 'DELIVERABLE', Name: 'Deliverable', ExtensionEntity: null, IsActive: true },
        { ID: '5', Code: 'APPROVAL_REQUEST', Name: 'Approval Request', ExtensionEntity: null, IsActive: true },
        { ID: '6', Code: 'AGENT_TASK', Name: 'Agent Task', ExtensionEntity: null, IsActive: true },
        { ID: '7', Code: 'PRIORITY', Name: 'Priority', ExtensionEntity: PRIORITY_EXTENSION_ENTITY, IsActive: true },
        { ID: '8', Code: 'PRIORITY_OBJECTIVE', Name: 'Priority Objective', ExtensionEntity: null, IsActive: false },
        { ID: '9', Code: 'KEY_RESULT', Name: 'Key Result', ExtensionEntity: null, IsActive: false },
        { ID: '10', Code: 'CUSTOM_INACTIVE', Name: 'Retired Custom', ExtensionEntity: null, IsActive: false },
        { ID: '11', Code: 'GITHUB_ISSUE', Name: 'GitHub Issue', ExtensionEntity: 'MJ_BizApps_Tasks_GitHub: Git Hub Issue Tasks', IsActive: true },
    ];

    it('identifies ExtensionEntity, Planning ownership, and legacy OKR codes accurately', () => {
        expect(NormalizeTaskTypeExtensionEntity('  MJ_BizApps_Planning: Priority Tasks  ')).toBe(
            PRIORITY_EXTENSION_ENTITY,
        );
        expect(NormalizeTaskTypeExtensionEntity('   ')).toBeNull();
        expect(HasTaskTypeExtensionEntity({ ExtensionEntity: PRIORITY_EXTENSION_ENTITY })).toBe(true);
        expect(HasTaskTypeExtensionEntity({ ExtensionEntity: '' })).toBe(false);

        expect(IsPlanningExtensionEntity(PRIORITY_EXTENSION_ENTITY)).toBe(true);
        expect(IsPlanningExtensionEntity('MJ_BizApps_Tasks_GitHub: Git Hub Issue Tasks')).toBe(false);

        for (const code of PLANNING_OWNED_TASK_TYPE_CODES) {
            expect(IsPlanningOwnedTaskType({ Code: code })).toBe(true);
        }
        for (const code of LEGACY_OKR_TASK_TYPE_CODES) {
            expect(IsLegacyOkrTaskType({ Code: code })).toBe(true);
        }

        expect(IsPlanningOwnedTaskType({ Code: 'CUSTOM_PLANNING', ExtensionEntity: 'MJ_BizApps_Planning: Custom' })).toBe(true);
        expect(IsPlanningOwnedTaskType({ Code: 'GENERAL', Name: 'General', ExtensionEntity: null })).toBe(false);
    });

    it('filters out PRIORITY, external Planning ExtensionEntity types, and inactive OKR/other types', () => {
        const generic = FilterGenericCreatableTaskTypes(sampleTaskTypes);
        expect(generic.map((t) => t.Code)).toEqual([
            'GENERAL',
            'ACTION_ITEM',
            'FOLLOW_UP',
            'DELIVERABLE',
            'APPROVAL_REQUEST',
            'AGENT_TASK',
            'GITHUB_ISSUE',
        ]);

        // Even if legacy OKR types were active in an older DB, they are excluded as Planning-owned.
        expect(IsGenericCreatableTaskType({ Code: 'PRIORITY_OBJECTIVE', IsActive: true })).toBe(false);
        expect(IsGenericCreatableTaskType({ Code: 'KEY_RESULT', IsActive: true })).toBe(false);
        expect(IsGenericCreatableTaskType({ Code: 'PRIORITY', IsActive: true })).toBe(false);
        expect(IsGenericCreatableTaskType({ Code: 'CUSTOM', ExtensionEntity: PRIORITY_EXTENSION_ENTITY, IsActive: true })).toBe(false);
        expect(IsGenericCreatableTaskType(null)).toBe(false);
        expect(IsGenericCreatableTaskType(undefined)).toBe(false);
    });

    it('optionally excludes all ExtensionEntity types when excludeAnyExtensionEntity is true', () => {
        const strictlyBase = FilterGenericCreatableTaskTypes(sampleTaskTypes, {
            excludeAnyExtensionEntity: true,
        });
        expect(strictlyBase.map((t) => t.Code)).toEqual([
            'GENERAL',
            'ACTION_ITEM',
            'FOLLOW_UP',
            'DELIVERABLE',
            'APPROVAL_REQUEST',
            'AGENT_TASK',
        ]);
    });
});
