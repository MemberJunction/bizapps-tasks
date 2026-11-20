import { describe, it, expect, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

vi.mock('@memberjunction/global', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@memberjunction/global')>();
  return {
    ...actual,
    RegisterClass: () => () => {},
  };
});

vi.mock('@memberjunction/core', () => {
  class FakeBaseEntity {
    public declaredCollections: Array<Record<string, unknown>> = [];
    DeclareRelatedRecords(options: Record<string, unknown>) {
      this.declaredCollections.push(options);
      return { Options: options };
    }
  }
  return {
    BaseEntity: FakeBaseEntity,
    CompositeKey: class {},
    ValidationResult: class { Success = true; Errors: unknown[] = []; },
    ValidationErrorInfo: class {},
    ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
  };
});

import {
  mjBizAppsTasksTaskEntity,
  mjBizAppsTasksTaskTypeEntity,
  mjBizAppsTasksTaskTemplateEntity,
  mjBizAppsTasksTaskTemplateItemEntity,
  mjBizAppsTasksWorkReportEntity,
} from '../../generated/entities/__mj_BizAppsTasks.js';

interface EntityRelationshipRecord {
  fields: { RelatedRecordCollection: string };
  primaryKey: { ID: string };
}

interface CollectionBlob {
  Name: string;
  Source: string;
  Load: string;
  OnRemove: string;
  OrderBy?: string;
  Sequence?: { Field: string; From: number };
  RelatedEntity?: string;
  RelatedEntityJoinField?: string;
  EmbeddedRecord?: unknown;
}

const currentDir = dirname(fileURLToPath(import.meta.url));
const relDir = resolve(currentDir, '../../../../../metadata/entity-relationships');

describe('RelatedRecordCollection metadata and generated entity declarations', () => {
  it('defines all 15 valid RelatedRecordCollection metadata entries with database/explicit policy', () => {
    const raw = readFileSync(resolve(relDir, '.entity-relationships.json'), 'utf8');
    const entries = JSON.parse(raw) as EntityRelationshipRecord[];
    expect(entries).toHaveLength(15);

    for (const entry of entries) {
      expect(entry.primaryKey.ID).toMatch(
        /^@lookup:MJ: Entity Relationships\.Entity=MJ_BizApps_Tasks: .+?&RelatedEntity=MJ_BizApps_Tasks: .+?&RelatedEntityJoinField=\w+$/,
      );
      expect(entry.fields.RelatedRecordCollection).toMatch(/^@file:[a-z0-9-]+\.json$/);

      const fileName = entry.fields.RelatedRecordCollection.replace(/^@file:/, '');
      const blob = JSON.parse(readFileSync(resolve(relDir, fileName), 'utf8')) as CollectionBlob;

      expect(blob.Source).toBe('database');
      expect(blob.Load).toBe('explicit');
      expect(blob.RelatedEntity).toBeUndefined();
      expect(blob.RelatedEntityJoinField).toBeUndefined();
      expect(blob.EmbeddedRecord).toBeUndefined();
      expect(['delete', 'orphan', 'refuse']).toContain(blob.OnRemove);
    }
  });

  it('declares matching RelatedRecordCollections on all 5 parent generated entity classes', () => {
    const task = new mjBizAppsTasksTaskEntity() as unknown as {
      declaredCollections: Array<{ Name: string; RelatedEntity: string; RelatedEntityJoinField: string; OnRemove: string }>;
    };
    expect(task.declaredCollections.map(c => c.Name)).toEqual([
      'Assignments',
      'TagLinks',
      'Links',
      'Dependencies',
      'Decisions',
      'Comments',
      'CheckIns',
      'Activities',
      'NotificationLogs',
      'SubTasks',
    ]);
    expect(task.declaredCollections.find(c => c.Name === 'Decisions')?.OnRemove).toBe('refuse');
    expect(task.declaredCollections.find(c => c.Name === 'SubTasks')?.OnRemove).toBe('orphan');
    expect(task.declaredCollections.find(c => c.Name === 'SubTasks')?.RelatedEntityJoinField).toBe('ParentID');

    const taskType = new mjBizAppsTasksTaskTypeEntity() as unknown as {
      declaredCollections: Array<{ Name: string; Sequence?: { Field: string; From: number } }>;
    };
    expect(taskType.declaredCollections.map(c => c.Name)).toEqual(['Statuses']);
    expect(taskType.declaredCollections[0].Sequence).toEqual({ Field: 'Sequence', From: 1 });

    const template = new mjBizAppsTasksTaskTemplateEntity() as unknown as {
      declaredCollections: Array<{ Name: string; Sequence?: { Field: string; From: number } }>;
    };
    expect(template.declaredCollections.map(c => c.Name)).toEqual(['Items']);
    expect(template.declaredCollections[0].Sequence).toEqual({ Field: 'Sequence', From: 1 });

    const templateItem = new mjBizAppsTasksTaskTemplateItemEntity() as unknown as {
      declaredCollections: Array<{ Name: string }>;
    };
    expect(templateItem.declaredCollections.map(c => c.Name)).toEqual(['Roles', 'Dependencies']);

    const workReport = new mjBizAppsTasksWorkReportEntity() as unknown as {
      declaredCollections: Array<{ Name: string; Sequence?: { Field: string; From: number } }>;
    };
    expect(workReport.declaredCollections.map(c => c.Name)).toEqual(['Items']);
    expect(workReport.declaredCollections[0].Sequence).toEqual({ Field: 'Sequence', From: 1 });
  });
});
