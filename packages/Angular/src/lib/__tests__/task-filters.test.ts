import { describe, expect, it } from 'vitest';
import { EntityInfo, IMetadataProvider } from '@memberjunction/core';
import {
    ApprovalTypePredicate,
    AssignedToFilter,
    EntityViewRef,
    IsTrue,
    PendingApprovalFilter,
} from '../task-filters';

const ROLES_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';
const FINANCE = 'D0000000-0000-0000-0000-00000000000A';

/** A provider whose metadata names the Tasks views as the given database stores them. */
function providerFor(schemaName: string): IMetadataProvider {
    const views: Record<string, string> = {
        'mj_bizapps_tasks: task types': 'vwTaskTypes',
        'mj_bizapps_tasks: task assignments': 'vwTaskAssignments',
        'mj_bizapps_tasks: task decisions': 'vwTaskDecisions',
        'mj_bizapps_tasks: task decision outcomes': 'vwTaskDecisionOutcomes',
    };
    const provider: Pick<IMetadataProvider, 'EntityByName'> = {
        EntityByName: (name: string) => {
            if (name === 'MJ: Roles') return { ID: ROLES_ENTITY_ID } as EntityInfo;
            const view = views[name.toLowerCase()];
            if (!view) return undefined;
            const entity: Pick<EntityInfo, 'SchemaName' | 'BaseView'> = { SchemaName: schemaName, BaseView: view };
            return entity as EntityInfo;
        },
    };
    return provider as IMetadataProvider;
}

const sqlServer = providerFor('__mj_BizAppsTasks');
const postgres = providerFor('__mj_bizappstasks');

describe('EntityViewRef', () => {
    it('uses the schema and view names from metadata', () => {
        expect(EntityViewRef('MJ_BizApps_Tasks: Task Types', sqlServer)).toBe('[__mj_BizAppsTasks].[vwTaskTypes]');
        expect(EntityViewRef('MJ_BizApps_Tasks: Task Types', postgres)).toBe('[__mj_bizappstasks].[vwTaskTypes]');
    });

    it('throws when the entity is not in metadata', () => {
        expect(() => EntityViewRef('MJ_BizApps_Tasks: Nope', sqlServer)).toThrow(/not in metadata/);
    });
});

describe('IsTrue', () => {
    it('compares through an integer cast, which both databases accept', () => {
        expect(IsTrue('[o].[IsTerminal]')).toBe('CAST([o].[IsTerminal] AS INT) = 1');
    });
});

describe('ApprovalTypePredicate', () => {
    it('selects every IsApproval type by default', () => {
        expect(ApprovalTypePredicate(null)).toBe('CAST([IsApproval] AS INT) = 1');
    });

    it('selects one named type when given, escaping quotes', () => {
        expect(ApprovalTypePredicate("Owner's Sign-off")).toBe("[Name] = 'Owner''s Sign-off'");
    });
});

describe('AssignedToFilter', () => {
    it('filters tasks through the assignments view', () => {
        expect(AssignedToFilter('person-1', [], postgres)).toBe(
            "[ID] IN (SELECT [TaskID] FROM [__mj_bizappstasks].[vwTaskAssignments] WHERE [AssigneeRecordID] = 'person-1')",
        );
    });

    it('escapes quotes in the person ID', () => {
        expect(AssignedToFilter("x' OR '1'='1", [], sqlServer)).toContain("[AssigneeRecordID] = 'x'' OR ''1''=''1'");
    });

    it('adds the roles, in both cases, scoped to the MJ: Roles entity', () => {
        expect(AssignedToFilter('person-1', [FINANCE], postgres)).toBe(
            "[ID] IN (SELECT [TaskID] FROM [__mj_bizappstasks].[vwTaskAssignments] WHERE [AssigneeRecordID] = 'person-1' OR " +
                `([AssigneeEntityID] = '${ROLES_ENTITY_ID}' AND [AssigneeRecordID] IN ('${FINANCE}','${FINANCE.toLowerCase()}')))`,
        );
    });

    it('drops role IDs that are not UUIDs', () => {
        const filter = AssignedToFilter("o'brien", ["x') OR 1=1 --"], sqlServer);
        expect(filter).toContain("[AssigneeRecordID] = 'o''brien'");
        expect(filter).not.toContain('OR 1=1');
        expect(filter).not.toContain('AssigneeEntityID');
    });

    it('matches only the person when MJ: Roles is not in metadata', () => {
        const noRoles = { EntityByName: (name: string) => (name === 'MJ: Roles' ? undefined : sqlServer.EntityByName(name)) } as IMetadataProvider;
        expect(AssignedToFilter('person-1', [FINANCE], noRoles)).not.toContain('AssigneeEntityID');
    });
});

describe('PendingApprovalFilter', () => {
    const filter = PendingApprovalFilter('person-1', null, [], postgres);

    it('reads every view from metadata', () => {
        expect(filter).toContain('FROM [__mj_bizappstasks].[vwTaskTypes]');
        expect(filter).toContain('FROM [__mj_bizappstasks].[vwTaskAssignments]');
        expect(filter).toContain('FROM [__mj_bizappstasks].[vwTaskDecisions] [d]');
        expect(filter).toContain('JOIN [__mj_bizappstasks].[vwTaskDecisionOutcomes] [o]');
        expect(filter).not.toContain('__mj_BizAppsTasks');
    });

    it('brackets every identifier and casts booleans', () => {
        expect(filter).toContain('[TypeID] IN (SELECT [ID] FROM');
        expect(filter).toContain('[d].[OutcomeID] = [o].[ID] WHERE CAST([o].[IsTerminal] AS INT) = 1');
        expect(filter).toContain('WHERE CAST([IsApproval] AS INT) = 1');
        expect(filter).not.toMatch(/(?<!AS INT\)) = 1/);
    });

    it('keeps open tasks assigned to the approver', () => {
        expect(filter).toContain("[Status] NOT IN ('Completed', 'Cancelled')");
        expect(filter).toContain("[AssigneeRecordID] = 'person-1'");
    });

    it('limits to the named approval type when given', () => {
        const named = PendingApprovalFilter('person-1', 'Concession Approval', [], sqlServer);
        expect(named).toContain("[__mj_BizAppsTasks].[vwTaskTypes] WHERE [Name] = 'Concession Approval'");
        expect(named).not.toContain('IsApproval');
    });

    it("matches the approver's roles too", () => {
        expect(PendingApprovalFilter('person-1', null, [FINANCE], postgres)).toContain(`[AssigneeRecordID] IN ('${FINANCE}'`);
    });
});
