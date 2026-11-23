import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
    EntityInfo,
    EntityPermissionType,
    RowLevelSecurityFilterInfo,
    UserInfo,
    type RowFilterParameterBinder,
} from '@memberjunction/core';

interface RowLevelSecurityFilterRecord {
    primaryKey: { ID: string };
    fields: {
        Name: string;
        Description: string;
        FilterText: string;
        PlatformVariants?: string;
    };
}

interface EntityPermissionRecord {
    primaryKey: { ID: string };
    fields: {
        CanRead?: number | boolean;
        CanCreate?: number | boolean;
        CanUpdate?: number | boolean;
        CanDelete?: number | boolean;
        ReadRLSFilterID?: string;
        CreateRLSFilterID?: string;
        UpdateRLSFilterID?: string;
        DeleteRLSFilterID?: string;
    };
}

interface RolePermissionEntityRecord {
    primaryKey: { ID: string };
    fields: {
        Name: string;
    };
    relatedEntities?: {
        'MJ: Entity Permissions'?: EntityPermissionRecord[];
    };
}

interface PlatformVariantsPayload {
    FilterText?: {
        postgresql?: string;
    };
    _meta?: {
        translatedBy?: string;
        sourceDialect?: string;
        verified?: boolean;
    };
}

const currentDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(currentDir, '../../../..');

const REQUIRED_GOVERNED_ENTITIES: ReadonlyArray<{
    EntityName: string;
    ExpectedReadFilter: string;
}> = [
    { EntityName: 'MJ_BizApps_Tasks: Tasks', ExpectedReadFilter: 'Tasks: Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Assignments', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Dependencies', ExpectedReadFilter: 'Tasks: Visible Task Dependencies' },
    { EntityName: 'MJ_BizApps_Tasks: Task Check Ins', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Comments', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Links', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Activities', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
    { EntityName: 'MJ_BizApps_Tasks: Task Time Entries', ExpectedReadFilter: 'Tasks: Visible Task Time Entries' },
    { EntityName: 'MJ_BizApps_Tasks: Meetings', ExpectedReadFilter: 'Tasks: Visible Meetings' },
    { EntityName: 'MJ_BizApps_Tasks: Work Reports', ExpectedReadFilter: 'UI: Work Reports - Author or Supervisor Chain' },
    { EntityName: 'MJ_BizApps_Tasks: Task Risk Assessments', ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks' },
];

const LOOKUP_PREFIX = '@lookup:MJ: Row Level Security Filters.Name=';
const TEST_USER_ID = '11111111-2222-4333-8444-555555555555';
const UI_ROLE_ID = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';

function loadRlsFilters(): RowLevelSecurityFilterRecord[] {
    const taskFilters = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/row-level-security-filters/.row-level-security-filters.json'), 'utf8'),
    ) as RowLevelSecurityFilterRecord[];
    const workReportFilters = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/row-level-security-filters/.work-report-rls-filters.json'), 'utf8'),
    ) as RowLevelSecurityFilterRecord[];
    return [...taskFilters, ...workReportFilters];
}

function loadRolePermissions(): RolePermissionEntityRecord[] {
    return JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/entities/.ui-role-permissions.json'), 'utf8'),
    ) as RolePermissionEntityRecord[];
}

function assertParenthesesBalanced(sql: string, label: string): void {
    let depth = 0;
    let inString = false;
    for (let i = 0; i < sql.length; i++) {
        const ch = sql[i];
        if (ch === "'") {
            if (inString && sql[i + 1] === "'") {
                i++;
                continue;
            }
            inString = !inString;
            continue;
        }
        if (inString) continue;
        if (ch === '(') depth++;
        else if (ch === ')') {
            depth--;
            expect(depth, `${label}: negative parenthesis depth at offset ${i}`).toBeGreaterThanOrEqual(0);
        }
    }
    expect(inString, `${label}: unclosed string literal`).toBe(false);
    expect(depth, `${label}: unbalanced parentheses`).toBe(0);
}

function createTypedBinder(): { binder: RowFilterParameterBinder; values: string[] } {
    const values: string[] = [];
    const binder: RowFilterParameterBinder = {
        Bind: (_token: string, value: string): string => {
            const idx = values.length;
            values.push(value);
            return `@rls_p${idx}`;
        },
    };
    return { binder, values };
}

describe('Slice 2: Provider-level Dual-Dialect RLS Filters & 11-Entity Permission Bindings', () => {
    const filters = loadRlsFilters();
    const filtersByName = new Map<string, RowLevelSecurityFilterRecord>(
        filters.map((f) => [f.fields.Name, f]),
    );
    const rolePermissions = loadRolePermissions();

    it('binds active UI ReadRLSFilterID permissions across all 11 governed bizapps-tasks entities', () => {
        for (const req of REQUIRED_GOVERNED_ENTITIES) {
            const entityEntry = rolePermissions.find(
                (e) =>
                    e.fields?.Name === req.EntityName ||
                    e.primaryKey?.ID === `@lookup:MJ: Entities.Name=${req.EntityName}`,
            );
            expect(entityEntry, `Missing EntityPermissions entry for ${req.EntityName}`).toBeDefined();

            const uiPerm = entityEntry?.relatedEntities?.['MJ: Entity Permissions']?.find((p) =>
                p.primaryKey.ID.includes('RoleID=@lookup:MJ: Roles.Name=UI'),
            );
            expect(uiPerm, `Missing UI role permission for ${req.EntityName}`).toBeDefined();
            expect(Boolean(uiPerm?.fields.CanRead), `${req.EntityName} UI CanRead must be enabled`).toBe(true);
            expect(uiPerm?.fields.ReadRLSFilterID).toBe(`${LOOKUP_PREFIX}${req.ExpectedReadFilter}`);

            const filterRecord = filtersByName.get(req.ExpectedReadFilter);
            expect(filterRecord, `Referenced RLS filter '${req.ExpectedReadFilter}' not found`).toBeDefined();
        }
    });

    it('defines balanced SQL Server and PostgreSQL PlatformVariants with EXISTS semi-joins and vwPersonReportingChain', () => {
        const readFilterNames = new Set(REQUIRED_GOVERNED_ENTITIES.map((e) => e.ExpectedReadFilter));
        readFilterNames.add('UI: Work Report Items - Author or Supervisor Chain');

        for (const filter of filters) {
            const name = filter.fields.Name;
            const tsql = filter.fields.FilterText;
            expect(tsql.trim().length, `${name}: empty FilterText`).toBeGreaterThan(0);
            assertParenthesesBalanced(tsql, `${name} (tsql)`);

            expect(filter.fields.PlatformVariants, `${name}: missing PlatformVariants`).toBeDefined();
            const parsedVariants = JSON.parse(filter.fields.PlatformVariants ?? '{}') as PlatformVariantsPayload;
            const pg = parsedVariants.FilterText?.postgresql ?? '';
            expect(pg.trim().length, `${name}: empty postgresql PlatformVariant`).toBeGreaterThan(0);
            assertParenthesesBalanced(pg, `${name} (postgresql)`);

            // Indexed EXISTS semi-joins — never slow uncorrelated IN (SELECT ...) subqueries
            expect(tsql, `${name} (tsql): must use EXISTS semi-joins`).toMatch(/\bEXISTS\s*\(/i);
            expect(pg, `${name} (pg): must use EXISTS semi-joins`).toMatch(/\bEXISTS\s*\(/i);
            expect(tsql, `${name} (tsql): must not use IN (SELECT ...)`).not.toMatch(/\bIN\s*\(\s*SELECT\b/i);
            expect(pg, `${name} (pg): must not use IN (SELECT ...)`).not.toMatch(/\bIN\s*\(\s*SELECT\b/i);

            // Dialect-specific schema & token handling parity
            expect(tsql, `${name} (tsql): must use TRY_CAST for {{UserID}}`).toContain("TRY_CAST('{{UserID}}' AS UNIQUEIDENTIFIER)");
            expect(pg, `${name} (pg): must use NULLIF('{{UserID}}', '')::uuid`).toContain("NULLIF('{{UserID}}', '')::uuid");
            expect(tsql, `${name} (tsql): must not contain PG ::uuid cast`).not.toContain('::uuid');
            expect(pg, `${name} (pg): must not contain T-SQL TRY_CAST`).not.toMatch(/\bTRY_CAST\b/i);
            expect(pg, `${name} (pg): must not reference uppercase __mj_BizApps schemas`).not.toMatch(/__mj_BizApps/);

            if (readFilterNames.has(name)) {
                expect(tsql, `${name} (tsql): must reference [__mj_BizAppsCommon].[vwPersonReportingChain]`).toContain(
                    '[__mj_BizAppsCommon].[vwPersonReportingChain]',
                );
                expect(pg, `${name} (pg): must reference "__mj_bizappscommon"."vwPersonReportingChain"`).toContain(
                    '"__mj_bizappscommon"."vwPersonReportingChain"',
                );
            }
        }
    });

    it('enforces Private, Team, Organization tiers, root-task ownership, and chain of command on Tasks RLS', () => {
        const visibleTasks = filtersByName.get('Tasks: Visible Tasks');
        expect(visibleTasks).toBeDefined();

        const tsql = visibleTasks!.fields.FilterText;
        const pg = (JSON.parse(visibleTasks!.fields.PlatformVariants!) as PlatformVariantsPayload).FilterText!.postgresql!;

        for (const [label, sql] of [
            ['tsql', tsql],
            ['pg', pg],
        ] as const) {
            expect(sql, `${label}: Private branch`).toContain("'Private'");
            expect(sql, `${label}: Team branch`).toContain("'Team'");
            expect(sql, `${label}: Organization branch`).toContain("'Organization'");
            expect(sql, `${label}: CreatedByPersonID`).toContain('CreatedByPersonID');
            expect(sql, `${label}: RootParentID`).toContain('RootParentID');
            expect(sql, `${label}: OrganizationID`).toContain('OrganizationID');
            expect(sql, `${label}: TaskAssignment`).toContain('TaskAssignment');
            expect(sql, `${label}: PersonToOrganization`).toContain('PersonToOrganization');
            expect(sql, `${label}: LinkedCompanyID`).toContain('LinkedCompanyID');
            expect(sql, `${label}: vwPersonReportingChain`).toContain('vwPersonReportingChain');
        }

        // Verify Private branch precedes Team/Organization and does not reference vwPersonReportingChain inside Private branch
        const tsqlPrivateIdx = tsql.indexOf("= N'Private'");
        const tsqlTeamOrgIdx = tsql.indexOf("IN (N'Team', N'Organization')");
        expect(tsqlPrivateIdx).toBeGreaterThan(-1);
        expect(tsqlTeamOrgIdx).toBeGreaterThan(tsqlPrivateIdx);
        const tsqlPrivateSegment = tsql.slice(tsqlPrivateIdx, tsqlTeamOrgIdx);
        expect(tsqlPrivateSegment).not.toContain('vwPersonReportingChain');
        expect(tsqlPrivateSegment).not.toContain('RootParentID');
        expect(tsqlPrivateSegment).not.toContain('OrganizationID');

        const pgPrivateIdx = pg.indexOf("= 'Private'");
        const pgTeamOrgIdx = pg.indexOf("IN ('Team', 'Organization')");
        expect(pgPrivateIdx).toBeGreaterThan(-1);
        expect(pgTeamOrgIdx).toBeGreaterThan(pgPrivateIdx);
        const pgPrivateSegment = pg.slice(pgPrivateIdx, pgTeamOrgIdx);
        expect(pgPrivateSegment).not.toContain('vwPersonReportingChain');
        expect(pgPrivateSegment).not.toContain('RootParentID');
        expect(pgPrivateSegment).not.toContain('OrganizationID');
    });

    it('checks BOTH TaskID and DependsOnTaskID on Task Dependencies so Private linked tasks never leak', () => {
        const depFilter = filtersByName.get('Tasks: Visible Task Dependencies');
        expect(depFilter).toBeDefined();

        const tsql = depFilter!.fields.FilterText;
        const pg = (JSON.parse(depFilter!.fields.PlatformVariants!) as PlatformVariantsPayload).FilterText!.postgresql!;

        expect(tsql).toContain('t.[ID] = [TaskID]');
        expect(tsql).toContain('dt.[ID] = [DependsOnTaskID]');
        expect(tsql).toMatch(/EXISTS\s*\(\s*SELECT 1 FROM \[__mj_BizAppsTasks\]\.\[vwTasks\] t[\s\S]*\)\s*AND\s*EXISTS\s*\(\s*SELECT 1 FROM \[__mj_BizAppsTasks\]\.\[vwTasks\] dt/);

        expect(pg).toContain('t."ID" = "TaskID"');
        expect(pg).toContain('dt."ID" = "DependsOnTaskID"');
        expect(pg).toMatch(/EXISTS\s*\(\s*SELECT 1 FROM "__mj_bizappstasks"\."vwTasks" t[\s\S]*\)\s*AND\s*EXISTS\s*\(\s*SELECT 1 FROM "__mj_bizappstasks"\."vwTasks" dt/);
    });

    it('handles standalone (TaskID IS NULL) and task-linked Time Entries without leaking Private tasks', () => {
        const teFilter = filtersByName.get('Tasks: Visible Task Time Entries');
        expect(teFilter).toBeDefined();

        const tsql = teFilter!.fields.FilterText;
        const pg = (JSON.parse(teFilter!.fields.PlatformVariants!) as PlatformVariantsPayload).FilterText!.postgresql!;

        expect(tsql).toContain('[TaskID] IS NULL');
        expect(tsql).toContain('[TaskID] IS NOT NULL');
        expect(tsql).toContain("tp.[Visibility] <> N'Private'");
        expect(tsql).toContain('[__mj_BizAppsCommon].[vwPersonReportingChain]');

        expect(pg).toContain('"TaskID" IS NULL');
        expect(pg).toContain('"TaskID" IS NOT NULL');
        expect(pg).toContain('tp."Visibility" <> \'Private\'');
        expect(pg).toContain('"__mj_bizappscommon"."vwPersonReportingChain"');
    });

    it('scopes Meetings by Private vs Standard, organizer/creator, attendees, linked tasks, and vwPersonReportingChain', () => {
        const mFilter = filtersByName.get('Tasks: Visible Meetings');
        expect(mFilter).toBeDefined();

        const tsql = mFilter!.fields.FilterText;
        const pg = (JSON.parse(mFilter!.fields.PlatformVariants!) as PlatformVariantsPayload).FilterText!.postgresql!;

        for (const [label, sql] of [
            ['tsql', tsql],
            ['pg', pg],
        ] as const) {
            expect(sql, `${label}: Private`).toContain("'Private'");
            expect(sql, `${label}: Standard`).toContain("'Standard'");
            expect(sql, `${label}: OrganizerPersonID`).toContain('OrganizerPersonID');
            expect(sql, `${label}: CreatedByPersonID`).toContain('CreatedByPersonID');
            expect(sql, `${label}: MeetingAttendee`).toContain('MeetingAttendee');
            expect(sql, `${label}: MeetingLink`).toContain('MeetingLink');
            expect(sql, `${label}: vwPersonReportingChain`).toContain('vwPersonReportingChain');
        }

        // Standard meetings must NOT short-circuit to globally readable without ownership/attendee/chain/task check
        expect(tsql).not.toMatch(/^\(Visibility = N'Standard' OR/i);
        expect(pg).not.toMatch(/^\("Visibility" = 'Standard' OR/i);
    });

    it('rewrites Work Reports & Work Report Items RLS onto vwPersonReportingChain with zero Employee/SupervisorID/ManagerID fallbacks', () => {
        const wrFilter = filtersByName.get('UI: Work Reports - Author or Supervisor Chain');
        const wriFilter = filtersByName.get('UI: Work Report Items - Author or Supervisor Chain');
        const wriDraftFilter = filtersByName.get('UI: Work Report Items - Draft Author Only');
        expect(wrFilter).toBeDefined();
        expect(wriFilter).toBeDefined();
        expect(wriDraftFilter).toBeDefined();

        for (const filter of [wrFilter!, wriFilter!]) {
            const name = filter.fields.Name;
            const tsql = filter.fields.FilterText;
            const pg = (JSON.parse(filter.fields.PlatformVariants!) as PlatformVariantsPayload).FilterText!.postgresql!;

            expect(tsql, `${name} (tsql): must use vwPersonReportingChain`).toContain('[__mj_BizAppsCommon].[vwPersonReportingChain]');
            expect(pg, `${name} (pg): must use vwPersonReportingChain`).toContain('"__mj_bizappscommon"."vwPersonReportingChain"');

            // No legacy single-hop/3-hop Employee.SupervisorID or ManagerID patterns
            for (const [label, sql] of [
                ['tsql', tsql],
                ['pg', pg],
            ] as const) {
                expect(sql, `${name} (${label}): must not reference Employee table`).not.toMatch(/\bEmployee\b/);
                expect(sql, `${name} (${label}): must not reference SupervisorID`).not.toMatch(/\bSupervisorID\b/);
                expect(sql, `${name} (${label}): must not reference ManagerID`).not.toMatch(/\bManagerID\b/);
                expect(sql, `${name} (${label}): must not hardcode mgr1/mgr2`).not.toMatch(/\bmgr[12]\b/);
            }
        }
    });

    it('substitutes {{UserID}} cleanly across SQL Server and PostgreSQL via MJ Core RowLevelSecurityFilterInfo', () => {
        const user = new UserInfo(null, {
            ID: TEST_USER_ID,
            Name: 'Alice User',
            Email: 'alice@example.com',
            Type: 'User',
            IsActive: true,
            UserRoles: [{ UserID: TEST_USER_ID, RoleID: UI_ROLE_ID, Role: 'UI' }],
        });

        for (const filter of filters) {
            const info = new RowLevelSecurityFilterInfo({
                ID: filter.primaryKey.ID,
                Name: filter.fields.Name,
                Description: filter.fields.Description,
                FilterText: filter.fields.FilterText,
                PlatformVariants: filter.fields.PlatformVariants ?? null,
            });

            const tsqlRendered = info.MarkupFilterText(user, { platform: 'sqlserver' });
            const pgRendered = info.MarkupFilterText(user, { platform: 'postgresql' });

            expect(tsqlRendered).toContain(TEST_USER_ID);
            expect(tsqlRendered).not.toContain('{{UserID}}');
            expect(pgRendered).toContain(TEST_USER_ID);
            expect(pgRendered).not.toContain('{{UserID}}');

            const { binder, values } = createTypedBinder();
            const paramSql = info.MarkupFilterParameterized(user, binder, { platform: 'sqlserver' });
            expect(paramSql).toContain('@rls_p0');
            expect(paramSql).not.toContain('{{UserID}}');
            expect(values.length).toBeGreaterThan(0);
            expect(values.every((v) => v === TEST_USER_ID)).toBe(true);
        }

        // Verify EntityInfo.GetUserRowLevelSecurityWhereClause selects PlatformVariants cleanly
        const tasksFilterRecord = filtersByName.get('Tasks: Visible Tasks')!;
        const tasksFilterInfo = new RowLevelSecurityFilterInfo({
            ID: tasksFilterRecord.primaryKey.ID,
            Name: tasksFilterRecord.fields.Name,
            Description: tasksFilterRecord.fields.Description,
            FilterText: tasksFilterRecord.fields.FilterText,
            PlatformVariants: tasksFilterRecord.fields.PlatformVariants ?? null,
        });

        const entity = new EntityInfo({
            ID: 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            Name: 'MJ_BizApps_Tasks: Tasks',
            SchemaName: '__mj_BizAppsTasks',
            BaseTable: 'Task',
            BaseView: 'vwTasks',
            Permissions: [
                {
                    ID: 'perm-ui-tasks',
                    EntityID: 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
                    RoleID: UI_ROLE_ID,
                    CanRead: true,
                    CanCreate: true,
                    CanUpdate: true,
                    CanDelete: false,
                    ReadRLSFilterID: tasksFilterRecord.primaryKey.ID,
                    Type: 'Allow',
                },
            ],
            Fields: [],
        });

        const pgClause = entity.GetUserRowLevelSecurityWhereClause(user, EntityPermissionType.Read, '', 'postgresql');
        // Check platform resolution directly on the filter when Metadata.Provider is not overridden
        expect(tasksFilterInfo.GetPlatformFilterText('postgresql')).toContain('"__mj_bizappscommon"."vwPersonReportingChain"');
        expect(tasksFilterInfo.GetPlatformFilterText('sqlserver')).toContain('[__mj_BizAppsCommon].[vwPersonReportingChain]');
        expect(pgClause).toBeDefined();
    });
});
