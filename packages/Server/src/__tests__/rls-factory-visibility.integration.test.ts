import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
    EntityInfo,
    EntityPermissionType,
    Metadata,
    RowLevelSecurityFilterInfo,
    UserInfo,
    type IMetadataProvider,
} from '@memberjunction/core';
import { mjBizAppsTasksTaskSchema } from '@mj-biz-apps/tasks-entities';

interface SqliteStatement {
    all(...params: Array<string | number | null>): Array<{ ID: string }>;
}

interface SqliteDatabase {
    exec(sql: string): void;
    prepare(sql: string): SqliteStatement;
    function(name: string, fn: (...args: Array<string | number | null>) => string | number | null): void;
    close(): void;
}

interface SqliteModule {
    DatabaseSync: new (path: string) => SqliteDatabase;
}

const require = createRequire(import.meta.url);
const { DatabaseSync } = require('node:sqlite') as SqliteModule;

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

type SqlDialect = 'sqlserver' | 'postgresql';

interface GovernedEntityDescriptor {
    EntityName: string;
    EntityID: string;
    TableName: string;
    ExpectedReadFilter: string;
}

const currentDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(currentDir, '../../../..');

const UI_ROLE_ID = 'e0afccec-6a37-ef11-86d4-000d3a4e707e';
const FACTORY_ROLE_ID = '8f4e29b1-5301-4b8e-9d1a-7c64e8a31001';
const FACTORY_ADMIN_ROLE_ID = '8f4e29b1-5301-4b8e-9d1a-7c64e8a31099';
const LOOKUP_PREFIX = '@lookup:MJ: Row Level Security Filters.Name=';
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Entity IDs
const ENTITY_PEOPLE_ID = '00000000-0000-4000-8000-000000000201';
const ENTITY_USERS_ID = '00000000-0000-4000-8000-000000000202';
const ENTITY_ROLES_ID = '00000000-0000-4000-8000-000000000203';
const ENTITY_TASKS_ID = '00000000-0000-4000-8000-000000000204';

const FACTORY_GOVERNED_ENTITIES: ReadonlyArray<GovernedEntityDescriptor> = [
    {
        EntityName: 'MJ_BizApps_Tasks: Tasks',
        EntityID: ENTITY_TASKS_ID,
        TableName: 'vwTasks',
        ExpectedReadFilter: 'Tasks: Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Assignments',
        EntityID: '00000000-0000-4000-8000-000000000205',
        TableName: 'TaskAssignment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
        EntityID: '00000000-0000-4000-8000-000000000206',
        TableName: 'TaskDependency',
        ExpectedReadFilter: 'Tasks: Visible Task Dependencies',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Check Ins',
        EntityID: '00000000-0000-4000-8000-000000000207',
        TableName: 'TaskCheckIn',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Comments',
        EntityID: '00000000-0000-4000-8000-000000000208',
        TableName: 'TaskComment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Links',
        EntityID: '00000000-0000-4000-8000-000000000209',
        TableName: 'TaskLink',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Activities',
        EntityID: '00000000-0000-4000-8000-000000000210',
        TableName: 'TaskActivity',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Risk Assessments',
        EntityID: '00000000-0000-4000-8000-000000000211',
        TableName: 'TaskRiskAssessment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
];

// Organizations & People / Users
const ORG_ENGINEERING_ID = '11000000-0000-4000-8000-000000000101';
const ORG_EXTERNAL_ID = '11000000-0000-4000-8000-000000000102';
const REL_TYPE_P2O_ID = '12000000-0000-4000-8000-000000000101';

// Factory run-as users across all 4 operational configurations:
// 1) Factory run-as user linked to a Person via Person.LinkedUserID (creates Epics/Slices directly)
const PERSON_FACTORY_RUNAS_ID = '20000000-0000-4000-8000-000000000101';
const USER_FACTORY_RUNAS_ID = '30000000-0000-4000-8000-000000000101';

// 2) Headless Factory service account (NO linked Person row) assigned via MJ: Users on root Epic
const USER_FACTORY_SERVICE_ID = '30000000-0000-4000-8000-000000000102';

// 3) Role-scoped Factory run-as user (NO linked Person row) holding FACTORY_ROLE_ID
const USER_FACTORY_ROLE_RUNNER_ID = '30000000-0000-4000-8000-000000000103';

// 4) Unfiltered Governance/Owner Factory run-as user (exempt from UI Read RLS)
const USER_FACTORY_OWNER_ID = '30000000-0000-4000-8000-000000000104';

// Human stakeholders:
// - Planner Human (creates epics assigned to factory service user / role)
const PERSON_PLANNER_ID = '20000000-0000-4000-8000-000000000105';
const USER_PLANNER_ID = '30000000-0000-4000-8000-000000000105';

// - Unrelated Human in another team/chain in same org (must NOT see factory Team items)
const PERSON_UNRELATED_ID = '20000000-0000-4000-8000-000000000106';
const USER_UNRELATED_ID = '30000000-0000-4000-8000-000000000106';

// - External Human in separate org (must NOT see factory Team items)
const PERSON_EXTERNAL_ID = '20000000-0000-4000-8000-000000000107';
const USER_EXTERNAL_ID = '30000000-0000-4000-8000-000000000107';

// Software Factory Work Item Tasks (all default Visibility = 'Team')
// Tree 1: Factory-created Epic + Factory-created Slice + Human-created Sub-Slice under Factory Epic
const TASK_SF_OWNED_EPIC_ID = '41000000-0000-4000-8000-000000000001';
const TASK_SF_OWNED_SLICE_1_ID = '41000000-0000-4000-8000-000000000002';
const TASK_SF_OWNED_SLICE_BY_HUMAN_ID = '41000000-0000-4000-8000-000000000003';

// Tree 2: Human-created Epic assigned to headless Factory service user via MJ: Users + unassigned child Slice
const TASK_SF_USER_ASSIGNED_EPIC_ID = '41000000-0000-4000-8000-000000000004';
const TASK_SF_USER_ASSIGNED_SLICE_ID = '41000000-0000-4000-8000-000000000005';

// Tree 3: Human-created Epic assigned to Software Factory role via MJ: Roles + unassigned child Slice
const TASK_SF_ROLE_ASSIGNED_EPIC_ID = '41000000-0000-4000-8000-000000000006';
const TASK_SF_ROLE_ASSIGNED_SLICE_ID = '41000000-0000-4000-8000-000000000007';

// Non-factory tasks for negative isolation assertions
const TASK_PLANNER_PRIVATE_ID = '41000000-0000-4000-8000-000000000008';
const TASK_UNRELATED_TEAM_ID = '41000000-0000-4000-8000-000000000009';

// Child records for verifying child-entity RLS inheritance
const ASSIGN_SF_USER_EPIC_ID = '51000000-0000-4000-8000-000000000101';
const ASSIGN_SF_ROLE_EPIC_ID = '51000000-0000-4000-8000-000000000102';
const ASSIGN_UNRELATED_ID = '51000000-0000-4000-8000-000000000103';

const DEP_SF_SLICE_TO_SLICE_ID = '52000000-0000-4000-8000-000000000101';
const DEP_SF_SLICE_TO_PRIVATE_ID = '52000000-0000-4000-8000-000000000102';

const CHECKIN_SF_OWNED_SLICE_ID = '53000000-0000-4000-8000-000000000101';
const CHECKIN_SF_USER_SLICE_ID = '53000000-0000-4000-8000-000000000102';
const CHECKIN_SF_ROLE_SLICE_ID = '53000000-0000-4000-8000-000000000103';
const CHECKIN_UNRELATED_ID = '53000000-0000-4000-8000-000000000104';

const COMMENT_SF_OWNED_SLICE_ID = '54000000-0000-4000-8000-000000000101';
const COMMENT_SF_USER_SLICE_ID = '54000000-0000-4000-8000-000000000102';
const COMMENT_SF_ROLE_SLICE_ID = '54000000-0000-4000-8000-000000000103';

const LINK_SF_OWNED_SLICE_ID = '55000000-0000-4000-8000-000000000101';
const LINK_SF_USER_SLICE_ID = '55000000-0000-4000-8000-000000000102';
const LINK_SF_ROLE_SLICE_ID = '55000000-0000-4000-8000-000000000103';

const ACT_SF_OWNED_SLICE_ID = '56000000-0000-4000-8000-000000000101';
const ACT_SF_USER_SLICE_ID = '56000000-0000-4000-8000-000000000102';
const ACT_SF_ROLE_SLICE_ID = '56000000-0000-4000-8000-000000000103';

const RISK_SF_OWNED_SLICE_ID = '57000000-0000-4000-8000-000000000101';
const RISK_SF_USER_SLICE_ID = '57000000-0000-4000-8000-000000000102';
const RISK_SF_ROLE_SLICE_ID = '57000000-0000-4000-8000-000000000103';

function loadRlsMetadata(): {
    filters: RowLevelSecurityFilterRecord[];
    rolePermissions: RolePermissionEntityRecord[];
} {
    const taskFilters = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/row-level-security-filters/.row-level-security-filters.json'), 'utf8'),
    ) as RowLevelSecurityFilterRecord[];
    const rolePermissions = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/entities/.ui-role-permissions.json'), 'utf8'),
    ) as RolePermissionEntityRecord[];
    return { filters: taskFilters, rolePermissions };
}

function replaceBalancedFunctionCall(
    sql: string,
    fnPrefixRegex: RegExp,
    transformInner: (inner: string) => string,
): string {
    let out = '';
    let cursor = 0;

    while (cursor < sql.length) {
        const slice = sql.slice(cursor);
        const match = fnPrefixRegex.exec(slice);
        if (!match) {
            out += slice;
            break;
        }
        const matchStart = cursor + match.index;
        const openParenIdx = matchStart + match[0].length - 1;
        out += sql.slice(cursor, matchStart);

        let depth = 1;
        let inString = false;
        let pos = openParenIdx + 1;
        while (pos < sql.length && depth > 0) {
            const ch = sql[pos];
            if (ch === "'") {
                if (inString && sql[pos + 1] === "'") {
                    pos += 2;
                    continue;
                }
                inString = !inString;
            } else if (!inString) {
                if (ch === '(') depth++;
                else if (ch === ')') depth--;
            }
            pos++;
        }

        const inner = sql.slice(openParenIdx + 1, pos - 1);
        out += transformInner(replaceBalancedFunctionCall(inner, fnPrefixRegex, transformInner));
        cursor = pos;
    }

    return out;
}

function adaptPredicateForSqlite(whereClause: string, dialect: SqlDialect): string {
    if (dialect === 'sqlserver') {
        const withoutNationalPrefix = whereClause.replace(/\bN'/g, "'");
        return replaceBalancedFunctionCall(withoutNationalPrefix, /\bTRY_CAST\s*\(/i, (inner) => {
            const asIdx = inner.search(/\s+AS\s+UNIQUEIDENTIFIER\b/i);
            if (asIdx < 0) {
                throw new Error(`Unexpected TRY_CAST target in SQL Server predicate: ${inner}`);
            }
            const expr = inner.slice(0, asIdx).trim();
            return `mj_try_uuid(${expr})`;
        });
    }

    let pgSql = whereClause.replace(
        /([A-Za-z_][A-Za-z0-9_]*\."[A-Za-z0-9_]+"|"[A-Za-z0-9_]+")\s*~\*\s*'((?:''|[^'])*)'/g,
        "mj_regex_imatch($1, '$2')",
    );
    pgSql = pgSql.replace(
        /NULLIF\s*\(\s*'([^']*)'\s*,\s*''\s*\)::uuid/gi,
        "mj_try_uuid(NULLIF('$1', ''))",
    );
    pgSql = pgSql.replace(
        /([A-Za-z_][A-Za-z0-9_]*\."[A-Za-z0-9_]+"|"[A-Za-z0-9_]+")::uuid\b/gi,
        'mj_try_uuid($1)',
    );
    return pgSql;
}

function createSqliteDb(): SqliteDatabase {
    const db = new DatabaseSync(':memory:');
    db.exec("ATTACH DATABASE ':memory:' AS __mj");
    db.exec("ATTACH DATABASE ':memory:' AS __mj_BizAppsCommon");
    db.exec("ATTACH DATABASE ':memory:' AS __mj_BizAppsTasks");

    db.function('mj_try_uuid', (val) => {
        if (typeof val !== 'string') return null;
        const trimmed = val.trim();
        return UUID_PATTERN.test(trimmed) ? trimmed.toLowerCase() : null;
    });

    db.function('mj_regex_imatch', (val, pattern) => {
        if (typeof val !== 'string' || typeof pattern !== 'string') return 0;
        return new RegExp(pattern, 'i').test(val) ? 1 : 0;
    });

    db.exec(`
        CREATE TABLE __mj."User" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL,
            "Email" TEXT,
            "Type" TEXT NOT NULL,
            "IsActive" INTEGER NOT NULL,
            "EmployeeID" TEXT,
            "LinkedEntityID" TEXT,
            "LinkedEntityRecordID" TEXT
        );

        CREATE TABLE __mj."Employee" (
            "ID" TEXT PRIMARY KEY,
            "CompanyID" TEXT NOT NULL,
            "Email" TEXT,
            "SupervisorID" TEXT,
            "Active" INTEGER NOT NULL
        );

        CREATE TABLE __mj."Entity" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL
        );

        CREATE TABLE __mj."Role" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL
        );

        CREATE TABLE __mj."UserRole" (
            "ID" TEXT PRIMARY KEY,
            "UserID" TEXT NOT NULL,
            "RoleID" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsCommon."Organization" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL,
            "LinkedCompanyID" TEXT
        );

        CREATE TABLE __mj_BizAppsCommon."Person" (
            "ID" TEXT PRIMARY KEY,
            "FirstName" TEXT NOT NULL,
            "LastName" TEXT NOT NULL,
            "Email" TEXT,
            "LinkedUserID" TEXT,
            "SupervisorPersonID" TEXT,
            "Status" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsCommon."RelationshipType" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL,
            "Category" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsCommon."Relationship" (
            "ID" TEXT PRIMARY KEY,
            "RelationshipTypeID" TEXT NOT NULL,
            "FromPersonID" TEXT,
            "ToPersonID" TEXT,
            "FromOrganizationID" TEXT,
            "ToOrganizationID" TEXT,
            "Status" TEXT NOT NULL
        );

        CREATE VIEW __mj_BizAppsCommon."vwPersonReportingChain" AS
        WITH RECURSIVE "ReportingChain"("PersonID", "SupervisorPersonID", "Depth", "VisitedPath") AS (
            SELECT
                p."ID",
                p."SupervisorPersonID",
                1,
                '/' || lower(p."ID") || '/' || lower(p."SupervisorPersonID") || '/'
            FROM __mj_BizAppsCommon."Person" p
            WHERE p."SupervisorPersonID" IS NOT NULL
              AND p."SupervisorPersonID" <> p."ID"
            UNION ALL
            SELECT
                rc."PersonID",
                sup."SupervisorPersonID",
                rc."Depth" + 1,
                rc."VisitedPath" || lower(sup."SupervisorPersonID") || '/'
            FROM "ReportingChain" rc
            INNER JOIN __mj_BizAppsCommon."Person" sup
                ON sup."ID" = rc."SupervisorPersonID"
            WHERE sup."SupervisorPersonID" IS NOT NULL
              AND instr(rc."VisitedPath", '/' || lower(sup."SupervisorPersonID") || '/') = 0
              AND rc."Depth" < 100
        )
        SELECT "PersonID", "SupervisorPersonID", "Depth"
        FROM "ReportingChain";

        CREATE TABLE __mj_BizAppsTasks."Task" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL,
            "ParentID" TEXT,
            "RootParentID" TEXT,
            "Visibility" TEXT NOT NULL,
            "CreatedByPersonID" TEXT,
            "OrganizationID" TEXT
        );

        CREATE VIEW __mj_BizAppsTasks."vwTasks" AS
        SELECT * FROM __mj_BizAppsTasks."Task";

        CREATE TABLE __mj_BizAppsTasks."TaskAssignment" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "AssigneeEntityID" TEXT NOT NULL,
            "AssigneeRecordID" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskDependency" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "DependsOnTaskID" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskCheckIn" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "Summary" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskComment" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "Body" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskLink" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "EntityID" TEXT NOT NULL,
            "RecordID" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskActivity" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "Description" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."TaskRiskAssessment" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT NOT NULL,
            "HealthStatus" TEXT NOT NULL
        );
    `);

    return db;
}

function seedFactoryVisibilityFixture(db: SqliteDatabase): void {
    db.exec(`
        INSERT INTO __mj."Entity" ("ID", "Name") VALUES
            ('${ENTITY_PEOPLE_ID}', 'MJ_BizApps_Common: People'),
            ('${ENTITY_USERS_ID}', 'MJ: Users'),
            ('${ENTITY_ROLES_ID}', 'MJ: Roles'),
            ('${ENTITY_TASKS_ID}', 'MJ_BizApps_Tasks: Tasks');

        INSERT INTO __mj."Role" ("ID", "Name") VALUES
            ('${UI_ROLE_ID}', 'UI'),
            ('${FACTORY_ROLE_ID}', 'Software Factory Governance'),
            ('${FACTORY_ADMIN_ROLE_ID}', 'Software Factory System Owner');

        INSERT INTO __mj_BizAppsCommon."Organization" ("ID", "Name", "LinkedCompanyID") VALUES
            ('${ORG_ENGINEERING_ID}', 'Acme Engineering', NULL),
            ('${ORG_EXTERNAL_ID}', 'External Tenant', NULL);

        INSERT INTO __mj_BizAppsCommon."RelationshipType" ("ID", "Name", "Category") VALUES
            ('${REL_TYPE_P2O_ID}', 'Works At', 'PersonToOrganization');

        INSERT INTO __mj."User" ("ID", "Name", "Email", "Type", "IsActive", "EmployeeID", "LinkedEntityID", "LinkedEntityRecordID") VALUES
            ('${USER_FACTORY_RUNAS_ID}', 'Factory Run-As Bot', 'factory-runas@acme.test', 'User', 1, NULL, NULL, NULL),
            ('${USER_FACTORY_SERVICE_ID}', 'Factory Headless Service', 'factory-svc@acme.test', 'User', 1, NULL, NULL, NULL),
            ('${USER_FACTORY_ROLE_RUNNER_ID}', 'Factory Role Runner', 'factory-role@acme.test', 'User', 1, NULL, NULL, NULL),
            ('${USER_FACTORY_OWNER_ID}', 'Factory Owner Service', 'factory-owner@acme.test', 'Owner', 1, NULL, NULL, NULL),
            ('${USER_PLANNER_ID}', 'Human Planner', 'planner@acme.test', 'User', 1, NULL, NULL, NULL),
            ('${USER_UNRELATED_ID}', 'Unrelated IC', 'unrelated@acme.test', 'User', 1, NULL, NULL, NULL),
            ('${USER_EXTERNAL_ID}', 'External User', 'external@other.test', 'User', 1, NULL, NULL, NULL);

        INSERT INTO __mj."UserRole" ("ID", "UserID", "RoleID") VALUES
            ('61000000-0000-4000-8000-000000000101', '${USER_FACTORY_RUNAS_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000102', '${USER_FACTORY_SERVICE_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000103', '${USER_FACTORY_ROLE_RUNNER_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000104', '${USER_FACTORY_ROLE_RUNNER_ID}', '${FACTORY_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000105', '${USER_FACTORY_OWNER_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000106', '${USER_FACTORY_OWNER_ID}', '${FACTORY_ADMIN_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000107', '${USER_PLANNER_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000108', '${USER_UNRELATED_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000109', '${USER_EXTERNAL_ID}', '${UI_ROLE_ID}');

        -- Note: USER_FACTORY_SERVICE_ID and USER_FACTORY_ROLE_RUNNER_ID intentionally have NO Person rows
        INSERT INTO __mj_BizAppsCommon."Person" ("ID", "FirstName", "LastName", "Email", "LinkedUserID", "SupervisorPersonID", "Status") VALUES
            ('${PERSON_FACTORY_RUNAS_ID}', 'Software', 'Factory', 'factory-runas@acme.test', '${USER_FACTORY_RUNAS_ID}', NULL, 'Active'),
            ('${PERSON_PLANNER_ID}', 'Human', 'Planner', 'planner@acme.test', '${USER_PLANNER_ID}', NULL, 'Active'),
            ('${PERSON_UNRELATED_ID}', 'Unrelated', 'Engineer', 'unrelated@acme.test', '${USER_UNRELATED_ID}', NULL, 'Active'),
            ('${PERSON_EXTERNAL_ID}', 'External', 'User', 'external@other.test', '${USER_EXTERNAL_ID}', NULL, 'Active');

        INSERT INTO __mj_BizAppsCommon."Relationship" ("ID", "RelationshipTypeID", "FromPersonID", "ToPersonID", "FromOrganizationID", "ToOrganizationID", "Status") VALUES
            ('62000000-0000-4000-8000-000000000101', '${REL_TYPE_P2O_ID}', '${PERSON_FACTORY_RUNAS_ID}', NULL, NULL, '${ORG_ENGINEERING_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000102', '${REL_TYPE_P2O_ID}', '${PERSON_PLANNER_ID}', NULL, NULL, '${ORG_ENGINEERING_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000103', '${REL_TYPE_P2O_ID}', '${PERSON_UNRELATED_ID}', NULL, NULL, '${ORG_ENGINEERING_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000104', '${REL_TYPE_P2O_ID}', '${PERSON_EXTERNAL_ID}', NULL, NULL, '${ORG_EXTERNAL_ID}', 'Active');

        -- Software Factory work items using default Team visibility
        INSERT INTO __mj_BizAppsTasks."Task" ("ID", "Name", "ParentID", "RootParentID", "Visibility", "CreatedByPersonID", "OrganizationID") VALUES
            ('${TASK_SF_OWNED_EPIC_ID}', 'SF Epic Created By Factory Run-As', NULL, NULL, 'Team', '${PERSON_FACTORY_RUNAS_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_OWNED_SLICE_1_ID}', 'SF Slice 1 Created By Factory Run-As', '${TASK_SF_OWNED_EPIC_ID}', '${TASK_SF_OWNED_EPIC_ID}', 'Team', '${PERSON_FACTORY_RUNAS_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', 'SF Slice 2 Added By Human Under Factory Epic', '${TASK_SF_OWNED_EPIC_ID}', '${TASK_SF_OWNED_EPIC_ID}', 'Team', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_USER_ASSIGNED_EPIC_ID}', 'SF Epic Assigned To Headless Service User', NULL, NULL, 'Team', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_USER_ASSIGNED_SLICE_ID}', 'SF Slice Inheriting Service User Root Assignment', '${TASK_SF_USER_ASSIGNED_EPIC_ID}', '${TASK_SF_USER_ASSIGNED_EPIC_ID}', 'Team', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_ROLE_ASSIGNED_EPIC_ID}', 'SF Epic Assigned To Factory Role', NULL, NULL, 'Team', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', 'SF Slice Inheriting Factory Role Root Assignment', '${TASK_SF_ROLE_ASSIGNED_EPIC_ID}', '${TASK_SF_ROLE_ASSIGNED_EPIC_ID}', 'Team', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_PLANNER_PRIVATE_ID}', 'Planner Personal Private Task', NULL, NULL, 'Private', '${PERSON_PLANNER_ID}', '${ORG_ENGINEERING_ID}'),
            ('${TASK_UNRELATED_TEAM_ID}', 'Unrelated Team Task', NULL, NULL, 'Team', '${PERSON_UNRELATED_ID}', '${ORG_ENGINEERING_ID}');

        INSERT INTO __mj_BizAppsTasks."TaskAssignment" ("ID", "TaskID", "AssigneeEntityID", "AssigneeRecordID") VALUES
            ('${ASSIGN_SF_USER_EPIC_ID}', '${TASK_SF_USER_ASSIGNED_EPIC_ID}', '${ENTITY_USERS_ID}', '${USER_FACTORY_SERVICE_ID}'),
            ('${ASSIGN_SF_ROLE_EPIC_ID}', '${TASK_SF_ROLE_ASSIGNED_EPIC_ID}', '${ENTITY_ROLES_ID}', '${FACTORY_ROLE_ID}'),
            ('${ASSIGN_UNRELATED_ID}', '${TASK_UNRELATED_TEAM_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_UNRELATED_ID}');

        INSERT INTO __mj_BizAppsTasks."TaskDependency" ("ID", "TaskID", "DependsOnTaskID") VALUES
            ('${DEP_SF_SLICE_TO_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', '${TASK_SF_OWNED_SLICE_1_ID}'),
            ('${DEP_SF_SLICE_TO_PRIVATE_ID}', '${TASK_SF_OWNED_SLICE_1_ID}', '${TASK_PLANNER_PRIVATE_ID}');

        INSERT INTO __mj_BizAppsTasks."TaskCheckIn" ("ID", "TaskID", "Summary") VALUES
            ('${CHECKIN_SF_OWNED_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', 'Factory run-as checkpoint'),
            ('${CHECKIN_SF_USER_SLICE_ID}', '${TASK_SF_USER_ASSIGNED_SLICE_ID}', 'Service user checkpoint'),
            ('${CHECKIN_SF_ROLE_SLICE_ID}', '${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', 'Role runner checkpoint'),
            ('${CHECKIN_UNRELATED_ID}', '${TASK_UNRELATED_TEAM_ID}', 'Unrelated team checkpoint');

        INSERT INTO __mj_BizAppsTasks."TaskComment" ("ID", "TaskID", "Body") VALUES
            ('${COMMENT_SF_OWNED_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', 'Factory review note'),
            ('${COMMENT_SF_USER_SLICE_ID}', '${TASK_SF_USER_ASSIGNED_SLICE_ID}', 'Service review note'),
            ('${COMMENT_SF_ROLE_SLICE_ID}', '${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', 'Role review note');

        INSERT INTO __mj_BizAppsTasks."TaskLink" ("ID", "TaskID", "EntityID", "RecordID") VALUES
            ('${LINK_SF_OWNED_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', '${ENTITY_TASKS_ID}', 'PR-101'),
            ('${LINK_SF_USER_SLICE_ID}', '${TASK_SF_USER_ASSIGNED_SLICE_ID}', '${ENTITY_TASKS_ID}', 'PR-102'),
            ('${LINK_SF_ROLE_SLICE_ID}', '${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', '${ENTITY_TASKS_ID}', 'PR-103');

        INSERT INTO __mj_BizAppsTasks."TaskActivity" ("ID", "TaskID", "Description") VALUES
            ('${ACT_SF_OWNED_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', 'Slice dispatched'),
            ('${ACT_SF_USER_SLICE_ID}', '${TASK_SF_USER_ASSIGNED_SLICE_ID}', 'Slice verified'),
            ('${ACT_SF_ROLE_SLICE_ID}', '${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', 'Slice merged');

        INSERT INTO __mj_BizAppsTasks."TaskRiskAssessment" ("ID", "TaskID", "HealthStatus") VALUES
            ('${RISK_SF_OWNED_SLICE_ID}', '${TASK_SF_OWNED_SLICE_BY_HUMAN_ID}', 'OnTrack'),
            ('${RISK_SF_USER_SLICE_ID}', '${TASK_SF_USER_ASSIGNED_SLICE_ID}', 'OnTrack'),
            ('${RISK_SF_ROLE_SLICE_ID}', '${TASK_SF_ROLE_ASSIGNED_SLICE_ID}', 'OnTrack');
    `);
}

function makeUser(
    id: string,
    name: string,
    email: string,
    roles: ReadonlyArray<{ RoleID: string; Role: string }>,
    type: 'User' | 'Owner' = 'User',
): UserInfo {
    return new UserInfo(null, {
        ID: id,
        Name: name,
        Email: email,
        Type: type,
        IsActive: true,
        UserRoles: roles.map((r) => ({ UserID: id, RoleID: r.RoleID, Role: r.Role })),
    });
}

describe('Software Factory Work Item Visibility Under Team Visibility RLS', () => {
    const metadata = loadRlsMetadata();
    const filterByName = new Map<string, RowLevelSecurityFilterInfo>();
    const entityInfoByName = new Map<string, EntityInfo>();

    let db: SqliteDatabase;
    let savedProvider: IMetadataProvider | undefined;

    const factoryRunAsUser = makeUser(USER_FACTORY_RUNAS_ID, 'Factory Run-As Bot', 'factory-runas@acme.test', [
        { RoleID: UI_ROLE_ID, Role: 'UI' },
    ]);
    const factoryServiceUser = makeUser(USER_FACTORY_SERVICE_ID, 'Factory Headless Service', 'factory-svc@acme.test', [
        { RoleID: UI_ROLE_ID, Role: 'UI' },
    ]);
    const factoryRoleRunnerUser = makeUser(
        USER_FACTORY_ROLE_RUNNER_ID,
        'Factory Role Runner',
        'factory-role@acme.test',
        [
            { RoleID: UI_ROLE_ID, Role: 'UI' },
            { RoleID: FACTORY_ROLE_ID, Role: 'Software Factory Governance' },
        ],
    );
    const factoryOwnerUser = makeUser(
        USER_FACTORY_OWNER_ID,
        'Factory Owner Service',
        'factory-owner@acme.test',
        [
            { RoleID: UI_ROLE_ID, Role: 'UI' },
            { RoleID: FACTORY_ADMIN_ROLE_ID, Role: 'Software Factory System Owner' },
        ],
        'Owner',
    );
    const unrelatedHumanUser = makeUser(USER_UNRELATED_ID, 'Unrelated IC', 'unrelated@acme.test', [
        { RoleID: UI_ROLE_ID, Role: 'UI' },
    ]);
    const externalHumanUser = makeUser(USER_EXTERNAL_ID, 'External User', 'external@other.test', [
        { RoleID: UI_ROLE_ID, Role: 'UI' },
    ]);

    function queryVisibleIds(
        entityName: string,
        tableName: string,
        user: UserInfo,
        dialect: SqlDialect,
    ): string[] {
        const entityInfo = entityInfoByName.get(entityName);
        if (!entityInfo) {
            throw new Error(`Missing EntityInfo for ${entityName}`);
        }
        const whereClause = entityInfo.GetEffectiveRowFilterWhereClause(
            user,
            EntityPermissionType.Read,
            '',
            undefined,
            dialect,
        );
        if (whereClause.trim().length === 0) {
            const rows = db.prepare(`SELECT "ID" FROM __mj_BizAppsTasks."${tableName}" ORDER BY "ID"`).all();
            return rows.map((r) => r.ID.toLowerCase());
        }

        const sqliteWhere = adaptPredicateForSqlite(whereClause, dialect);
        const rows = db
            .prepare(`SELECT "ID" FROM __mj_BizAppsTasks."${tableName}" WHERE (${sqliteWhere}) ORDER BY "ID"`)
            .all();
        return rows.map((r) => r.ID.toLowerCase());
    }

    beforeAll(() => {
        const allFilterInfos: RowLevelSecurityFilterInfo[] = [];
        for (const record of metadata.filters) {
            const info = new RowLevelSecurityFilterInfo({
                ID: record.primaryKey.ID,
                Name: record.fields.Name,
                Description: record.fields.Description,
                FilterText: record.fields.FilterText,
                PlatformVariants: record.fields.PlatformVariants ?? null,
            });
            allFilterInfos.push(info);
            filterByName.set(record.fields.Name, info);
        }

        try {
            savedProvider = Metadata.Provider;
        } catch {
            savedProvider = undefined;
        }

        const testProvider: Partial<IMetadataProvider> = {
            Entities: [],
            RowLevelSecurityFilters: allFilterInfos,
        };
        Metadata.Provider = testProvider as IMetadataProvider;

        for (const desc of FACTORY_GOVERNED_ENTITIES) {
            const permRecord = metadata.rolePermissions.find(
                (entry) =>
                    entry.fields?.Name === desc.EntityName ||
                    entry.primaryKey?.ID === `@lookup:MJ: Entities.Name=${desc.EntityName}`,
            );
            expect(permRecord, `Missing permission record for ${desc.EntityName}`).toBeDefined();

            const uiPerm = permRecord?.relatedEntities?.['MJ: Entity Permissions']?.find((p) =>
                p.primaryKey.ID.includes('RoleID=@lookup:MJ: Roles.Name=UI'),
            );
            expect(uiPerm, `Missing UI permission for ${desc.EntityName}`).toBeDefined();

            const lookupVal = uiPerm?.fields.ReadRLSFilterID;
            const filterName = lookupVal?.startsWith(LOOKUP_PREFIX)
                ? lookupVal.slice(LOOKUP_PREFIX.length)
                : (lookupVal ?? '');
            const matchedFilter = filterByName.get(filterName);
            expect(matchedFilter, `Missing RLS filter '${filterName}'`).toBeDefined();

            const entityInfo = new EntityInfo({
                ID: desc.EntityID,
                Name: desc.EntityName,
                SchemaName: '__mj_BizAppsTasks',
                BaseTable: desc.TableName,
                BaseView: desc.TableName,
                Permissions: [
                    {
                        ID: `perm-ui-${desc.EntityID}`,
                        EntityID: desc.EntityID,
                        RoleID: UI_ROLE_ID,
                        CanRead: Boolean(uiPerm?.fields.CanRead),
                        CanCreate: Boolean(uiPerm?.fields.CanCreate),
                        CanUpdate: Boolean(uiPerm?.fields.CanUpdate),
                        CanDelete: Boolean(uiPerm?.fields.CanDelete),
                        ReadRLSFilterID: matchedFilter!.ID,
                        Type: 'Allow',
                    },
                    {
                        ID: `perm-owner-${desc.EntityID}`,
                        EntityID: desc.EntityID,
                        RoleID: FACTORY_ADMIN_ROLE_ID,
                        CanRead: true,
                        CanCreate: true,
                        CanUpdate: true,
                        CanDelete: false,
                        ReadRLSFilterID: null,
                        Type: 'Allow',
                    },
                ],
                Fields: [],
            });
            entityInfoByName.set(desc.EntityName, entityInfo);
        }

        db = createSqliteDb();
        seedFactoryVisibilityFixture(db);
    });

    afterAll(() => {
        if (db) {
            db.close();
        }
        if (savedProvider) {
            Metadata.Provider = savedProvider;
        }
    });

    it('defaults newly created Software Factory work items to Team visibility', () => {
        expect(mjBizAppsTasksTaskSchema.shape.Visibility.parse(undefined)).toBe('Team');
    });

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] keeps Factory-created Team Epics, Slices, and human-added sub-slices visible to the Factory run-as user',
        (dialect) => {
            const visibleTasks = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', factoryRunAsUser, dialect);

            // Sees own root Epic, own child Slice, AND human-added child Slice via RootParentID ownership inheritance
            expect(visibleTasks).toEqual(
                [TASK_SF_OWNED_EPIC_ID, TASK_SF_OWNED_SLICE_1_ID, TASK_SF_OWNED_SLICE_BY_HUMAN_ID].sort(),
            );
            expect(visibleTasks).not.toContain(TASK_PLANNER_PRIVATE_ID);
            expect(visibleTasks).not.toContain(TASK_UNRELATED_TEAM_ID);

            // Sees child records across all governed child entities (even on the human-created sub-slice)
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Check Ins', 'TaskCheckIn', factoryRunAsUser, dialect)).toEqual([
                CHECKIN_SF_OWNED_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Comments', 'TaskComment', factoryRunAsUser, dialect)).toEqual([
                COMMENT_SF_OWNED_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Links', 'TaskLink', factoryRunAsUser, dialect)).toEqual([
                LINK_SF_OWNED_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Activities', 'TaskActivity', factoryRunAsUser, dialect)).toEqual([
                ACT_SF_OWNED_SLICE_ID,
            ]);
            expect(
                queryVisibleIds('MJ_BizApps_Tasks: Task Risk Assessments', 'TaskRiskAssessment', factoryRunAsUser, dialect),
            ).toEqual([RISK_SF_OWNED_SLICE_ID]);

            // Sees slice-to-slice dependency, MUST NOT leak dependency edge targeting Planner's Private task
            expect(
                queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', factoryRunAsUser, dialect),
            ).toEqual([DEP_SF_SLICE_TO_SLICE_ID]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] keeps human-created Team Epics and unassigned child Slices visible to a headless Factory run-as service user via MJ: Users root assignment',
        (dialect) => {
            const visibleTasks = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', factoryServiceUser, dialect);

            expect(visibleTasks).toEqual(
                [TASK_SF_USER_ASSIGNED_EPIC_ID, TASK_SF_USER_ASSIGNED_SLICE_ID].sort(),
            );
            expect(visibleTasks).not.toContain(TASK_PLANNER_PRIVATE_ID);
            expect(visibleTasks).not.toContain(TASK_UNRELATED_TEAM_ID);

            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Assignments', 'TaskAssignment', factoryServiceUser, dialect)).toEqual([
                ASSIGN_SF_USER_EPIC_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Check Ins', 'TaskCheckIn', factoryServiceUser, dialect)).toEqual([
                CHECKIN_SF_USER_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Comments', 'TaskComment', factoryServiceUser, dialect)).toEqual([
                COMMENT_SF_USER_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Links', 'TaskLink', factoryServiceUser, dialect)).toEqual([
                LINK_SF_USER_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Activities', 'TaskActivity', factoryServiceUser, dialect)).toEqual([
                ACT_SF_USER_SLICE_ID,
            ]);
            expect(
                queryVisibleIds('MJ_BizApps_Tasks: Task Risk Assessments', 'TaskRiskAssessment', factoryServiceUser, dialect),
            ).toEqual([RISK_SF_USER_SLICE_ID]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] keeps human-created Team Epics and unassigned child Slices visible to a role-assigned Factory run-as user via MJ: Roles root assignment',
        (dialect) => {
            const visibleTasks = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', factoryRoleRunnerUser, dialect);

            expect(visibleTasks).toEqual(
                [TASK_SF_ROLE_ASSIGNED_EPIC_ID, TASK_SF_ROLE_ASSIGNED_SLICE_ID].sort(),
            );
            expect(visibleTasks).not.toContain(TASK_PLANNER_PRIVATE_ID);
            expect(visibleTasks).not.toContain(TASK_UNRELATED_TEAM_ID);

            expect(
                queryVisibleIds('MJ_BizApps_Tasks: Task Assignments', 'TaskAssignment', factoryRoleRunnerUser, dialect),
            ).toEqual([ASSIGN_SF_ROLE_EPIC_ID]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Check Ins', 'TaskCheckIn', factoryRoleRunnerUser, dialect)).toEqual([
                CHECKIN_SF_ROLE_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Comments', 'TaskComment', factoryRoleRunnerUser, dialect)).toEqual([
                COMMENT_SF_ROLE_SLICE_ID,
            ]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Links', 'TaskLink', factoryRoleRunnerUser, dialect)).toEqual([
                LINK_SF_ROLE_SLICE_ID,
            ]);
            expect(
                queryVisibleIds('MJ_BizApps_Tasks: Task Activities', 'TaskActivity', factoryRoleRunnerUser, dialect),
            ).toEqual([ACT_SF_ROLE_SLICE_ID]);
            expect(
                queryVisibleIds(
                    'MJ_BizApps_Tasks: Task Risk Assessments',
                    'TaskRiskAssessment',
                    factoryRoleRunnerUser,
                    dialect,
                ),
            ).toEqual([RISK_SF_ROLE_SLICE_ID]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] grants unfiltered read visibility to an exempt Factory system-owner run-as user while blocking unrelated and external users',
        (dialect) => {
            const tasksEntity = entityInfoByName.get('MJ_BizApps_Tasks: Tasks')!;
            expect(
                tasksEntity.GetEffectiveRowFilterWhereClause(
                    factoryOwnerUser,
                    EntityPermissionType.Read,
                    '',
                    undefined,
                    dialect,
                ),
            ).toBe('');

            const ownerTasks = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', factoryOwnerUser, dialect);
            expect(ownerTasks).toEqual(
                expect.arrayContaining([
                    TASK_SF_OWNED_EPIC_ID,
                    TASK_SF_OWNED_SLICE_1_ID,
                    TASK_SF_OWNED_SLICE_BY_HUMAN_ID,
                    TASK_SF_USER_ASSIGNED_EPIC_ID,
                    TASK_SF_USER_ASSIGNED_SLICE_ID,
                    TASK_SF_ROLE_ASSIGNED_EPIC_ID,
                    TASK_SF_ROLE_ASSIGNED_SLICE_ID,
                ]),
            );

            // Unrelated human in the same org sees ONLY their own Team task — zero Factory work items
            const unrelatedTasks = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', unrelatedHumanUser, dialect);
            expect(unrelatedTasks).toEqual([TASK_UNRELATED_TEAM_ID]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Check Ins', 'TaskCheckIn', unrelatedHumanUser, dialect)).toEqual([
                CHECKIN_UNRELATED_ID,
            ]);

            // External user in another org sees ZERO Factory work items or child records
            expect(queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', externalHumanUser, dialect)).toEqual([]);
            expect(queryVisibleIds('MJ_BizApps_Tasks: Task Check Ins', 'TaskCheckIn', externalHumanUser, dialect)).toEqual([]);
        },
    );
});
