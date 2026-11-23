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
const LOOKUP_PREFIX = '@lookup:MJ: Row Level Security Filters.Name=';
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// ---------------------------------------------------------------------------
// Entity IDs
// ---------------------------------------------------------------------------
const ENTITY_PEOPLE_ID = '00000000-0000-4000-8000-000000000101';
const ENTITY_USERS_ID = '00000000-0000-4000-8000-000000000102';
const ENTITY_ROLES_ID = '00000000-0000-4000-8000-000000000103';
const ENTITY_TASKS_ID = '00000000-0000-4000-8000-000000000104';

const GOVERNED_ENTITIES: ReadonlyArray<GovernedEntityDescriptor> = [
    {
        EntityName: 'MJ_BizApps_Tasks: Tasks',
        EntityID: ENTITY_TASKS_ID,
        TableName: 'vwTasks',
        ExpectedReadFilter: 'Tasks: Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Assignments',
        EntityID: '00000000-0000-4000-8000-000000000105',
        TableName: 'TaskAssignment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
        EntityID: '00000000-0000-4000-8000-000000000106',
        TableName: 'TaskDependency',
        ExpectedReadFilter: 'Tasks: Visible Task Dependencies',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Check Ins',
        EntityID: '00000000-0000-4000-8000-000000000107',
        TableName: 'TaskCheckIn',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Comments',
        EntityID: '00000000-0000-4000-8000-000000000108',
        TableName: 'TaskComment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Links',
        EntityID: '00000000-0000-4000-8000-000000000109',
        TableName: 'TaskLink',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Activities',
        EntityID: '00000000-0000-4000-8000-000000000110',
        TableName: 'TaskActivity',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
        EntityID: '00000000-0000-4000-8000-000000000111',
        TableName: 'TaskTimeEntry',
        ExpectedReadFilter: 'Tasks: Visible Task Time Entries',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Meetings',
        EntityID: '00000000-0000-4000-8000-000000000112',
        TableName: 'Meeting',
        ExpectedReadFilter: 'Tasks: Visible Meetings',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Work Reports',
        EntityID: '00000000-0000-4000-8000-000000000113',
        TableName: 'WorkReport',
        ExpectedReadFilter: 'UI: Work Reports - Author or Supervisor Chain',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Task Risk Assessments',
        EntityID: '00000000-0000-4000-8000-000000000114',
        TableName: 'TaskRiskAssessment',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Tasks',
    },
];

const SUPPLEMENTAL_ENTITIES: ReadonlyArray<GovernedEntityDescriptor> = [
    {
        EntityName: 'MJ_BizApps_Tasks: Work Report Items',
        EntityID: '00000000-0000-4000-8000-000000000115',
        TableName: 'WorkReportItem',
        ExpectedReadFilter: 'UI: Work Report Items - Author or Supervisor Chain',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Meeting Series',
        EntityID: '00000000-0000-4000-8000-000000000116',
        TableName: 'MeetingSeries',
        ExpectedReadFilter: 'Tasks: Visible Meeting Series',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Meeting Series Attendees',
        EntityID: '00000000-0000-4000-8000-000000000117',
        TableName: 'MeetingSeriesAttendee',
        ExpectedReadFilter: 'Tasks: Visible Meeting Series Attendees',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Meeting Attendees',
        EntityID: '00000000-0000-4000-8000-000000000118',
        TableName: 'MeetingAttendee',
        ExpectedReadFilter: 'Tasks: Rows Of Visible Meetings',
    },
    {
        EntityName: 'MJ_BizApps_Tasks: Meeting Links',
        EntityID: '00000000-0000-4000-8000-000000000119',
        TableName: 'MeetingLink',
        ExpectedReadFilter: 'Tasks: Visible Meeting Links',
    },
];

// ---------------------------------------------------------------------------
// Fixture IDs — Multi-Chain, Multi-Organization Graph
// ---------------------------------------------------------------------------
const COMPANY_1_ID = '10000000-0000-4000-8000-000000000001';
const COMPANY_2_ID = '10000000-0000-4000-8000-000000000002';
const ORG_1_ID = '11000000-0000-4000-8000-000000000001';
const ORG_2_ID = '11000000-0000-4000-8000-000000000002';
const REL_TYPE_P2O_ID = '12000000-0000-4000-8000-000000000001';

// Organization 1 — Chain A (3 levels deep: User A -> Manager M1 -> Director D1)
const PERSON_D1_ID = '20000000-0000-4000-8000-000000000001';
const USER_D1_ID = '30000000-0000-4000-8000-000000000001';

const PERSON_M1_ID = '20000000-0000-4000-8000-000000000002';
const USER_M1_ID = '30000000-0000-4000-8000-000000000002';

const PERSON_A_ID = '20000000-0000-4000-8000-000000000003';
const USER_A_ID = '30000000-0000-4000-8000-000000000003';

// Organization 1 — Chain B (disjoint: User B -> Manager M2)
const PERSON_M2_ID = '20000000-0000-4000-8000-000000000004';
const USER_M2_ID = '30000000-0000-4000-8000-000000000004';

const PERSON_B_ID = '20000000-0000-4000-8000-000000000005';
const USER_B_ID = '30000000-0000-4000-8000-000000000005';

// Organization 1 — Root-Task Owner Chain (RootOwner R1 -> RootDirector RD1)
const PERSON_RD1_ID = '20000000-0000-4000-8000-000000000006';
const USER_RD1_ID = '30000000-0000-4000-8000-000000000006';

const PERSON_R1_ID = '20000000-0000-4000-8000-000000000007';
const USER_R1_ID = '30000000-0000-4000-8000-000000000007';

// Organization 2 — External User C (cross-org isolation)
const PERSON_C_ID = '20000000-0000-4000-8000-000000000008';
const USER_C_ID = '30000000-0000-4000-8000-000000000008';

// Tasks
const TASK_A_TEAM_ID = '40000000-0000-4000-8000-000000000001';
const TASK_A_TEAM_2_ID = '40000000-0000-4000-8000-000000000002';
const TASK_A_PRIVATE_ID = '40000000-0000-4000-8000-000000000003';
const TASK_A_PRIVATE_ASSIGNED_B_ID = '40000000-0000-4000-8000-000000000004';
const TASK_A_ORG_ID = '40000000-0000-4000-8000-000000000005';
const TASK_B_TEAM_ID = '40000000-0000-4000-8000-000000000006';
const TASK_ROOT_R1_ID = '40000000-0000-4000-8000-000000000007';
const TASK_SUB_UNDER_R1_ID = '40000000-0000-4000-8000-000000000008';
const TASK_C_ORG_ID = '40000000-0000-4000-8000-000000000009';

// Child Records (Assignments, Dependencies, CheckIns, Comments, Links, Activities, RiskAssessments)
const ASSIGN_A_TEAM_ID = '50000000-0000-4000-8000-000000000001';
const ASSIGN_A_PRIVATE_ID = '50000000-0000-4000-8000-000000000002';
const ASSIGN_A_PRIVATE_TO_B_ID = '50000000-0000-4000-8000-000000000003';
const ASSIGN_A_ORG_ID = '50000000-0000-4000-8000-000000000004';
const ASSIGN_SUB_R1_TO_A_ID = '50000000-0000-4000-8000-000000000005';
const ASSIGN_B_TEAM_ID = '50000000-0000-4000-8000-000000000006';

const DEP_TEAM_TO_TEAM_ID = '51000000-0000-4000-8000-000000000001';
const DEP_TEAM_TO_PRIVATE_ID = '51000000-0000-4000-8000-000000000002';
const DEP_PRIVATE_TO_TEAM_ID = '51000000-0000-4000-8000-000000000003';
const DEP_B_TEAM_TO_ORG_ID = '51000000-0000-4000-8000-000000000004';

const CHECKIN_A_TEAM_ID = '52000000-0000-4000-8000-000000000001';
const CHECKIN_A_PRIVATE_ID = '52000000-0000-4000-8000-000000000002';
const CHECKIN_A_ORG_ID = '52000000-0000-4000-8000-000000000003';
const CHECKIN_SUB_R1_ID = '52000000-0000-4000-8000-000000000004';
const CHECKIN_B_TEAM_ID = '52000000-0000-4000-8000-000000000005';

const COMMENT_A_TEAM_ID = '53000000-0000-4000-8000-000000000001';
const COMMENT_A_PRIVATE_ID = '53000000-0000-4000-8000-000000000002';
const COMMENT_A_ORG_ID = '53000000-0000-4000-8000-000000000003';
const COMMENT_SUB_R1_ID = '53000000-0000-4000-8000-000000000004';
const COMMENT_B_TEAM_ID = '53000000-0000-4000-8000-000000000005';

const LINK_A_TEAM_ID = '54000000-0000-4000-8000-000000000001';
const LINK_A_PRIVATE_ID = '54000000-0000-4000-8000-000000000002';
const LINK_A_ORG_ID = '54000000-0000-4000-8000-000000000003';
const LINK_SUB_R1_ID = '54000000-0000-4000-8000-000000000004';
const LINK_B_TEAM_ID = '54000000-0000-4000-8000-000000000005';

const ACT_A_TEAM_ID = '55000000-0000-4000-8000-000000000001';
const ACT_A_PRIVATE_ID = '55000000-0000-4000-8000-000000000002';
const ACT_A_ORG_ID = '55000000-0000-4000-8000-000000000003';
const ACT_SUB_R1_ID = '55000000-0000-4000-8000-000000000004';
const ACT_B_TEAM_ID = '55000000-0000-4000-8000-000000000005';

const RISK_A_TEAM_ID = '56000000-0000-4000-8000-000000000001';
const RISK_A_PRIVATE_ID = '56000000-0000-4000-8000-000000000002';
const RISK_A_ORG_ID = '56000000-0000-4000-8000-000000000003';
const RISK_SUB_R1_ID = '56000000-0000-4000-8000-000000000004';
const RISK_B_TEAM_ID = '56000000-0000-4000-8000-000000000005';

// Time Entries (task-linked + standalone)
const TE_A_TEAM_ID = '57000000-0000-4000-8000-000000000001';
const TE_A_PRIVATE_ID = '57000000-0000-4000-8000-000000000002';
const TE_A_STANDALONE_ID = '57000000-0000-4000-8000-000000000003';
const TE_B_STANDALONE_ID = '57000000-0000-4000-8000-000000000004';
const TE_C_STANDALONE_ID = '57000000-0000-4000-8000-000000000005';

// Meetings (+ MeetingLink)
const MTG_A_STANDARD_ID = '58000000-0000-4000-8000-000000000001';
const MTG_A_PRIVATE_ID = '58000000-0000-4000-8000-000000000002';
const MTG_B_STANDARD_ID = '58000000-0000-4000-8000-000000000003';
const MTG_LINKED_TEAM_ID = '58000000-0000-4000-8000-000000000004';
const MTG_R1_LINKED_PRIVATE_A_ID = '58000000-0000-4000-8000-000000000005';

// Work Reports (+ Work Report Items)
const WR_A_DRAFT_ID = '59000000-0000-4000-8000-000000000001';
const WR_A_SUBMITTED_ID = '59000000-0000-4000-8000-000000000002';
const WR_B_SUBMITTED_ID = '59000000-0000-4000-8000-000000000003';
const WR_C_SUBMITTED_ID = '59000000-0000-4000-8000-000000000004';

const WRI_A_DRAFT_ID = '5a000000-0000-4000-8000-000000000001';
const WRI_A_SUBMITTED_ID = '5a000000-0000-4000-8000-000000000002';
const WRI_B_SUBMITTED_ID = '5a000000-0000-4000-8000-000000000003';

function loadRlsMetadata(): {
    filters: RowLevelSecurityFilterRecord[];
    rolePermissions: RolePermissionEntityRecord[];
} {
    const taskFilters = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/row-level-security-filters/.row-level-security-filters.json'), 'utf8'),
    ) as RowLevelSecurityFilterRecord[];
    const workReportFilters = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/row-level-security-filters/.work-report-rls-filters.json'), 'utf8'),
    ) as RowLevelSecurityFilterRecord[];
    const rolePermissions = JSON.parse(
        readFileSync(resolve(repoRoot, 'metadata/entities/.ui-role-permissions.json'), 'utf8'),
    ) as RolePermissionEntityRecord[];

    return {
        filters: [...taskFilters, ...workReportFilters],
        rolePermissions,
    };
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

/**
 * Normalizes SQL Server or PostgreSQL dialect expressions from the real metadata RLS predicate
 * into SQLite-executable SQL while preserving 100% of boolean structure, joins, and subqueries.
 */
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

    // PostgreSQL dialect normalization:
    // 1) Replace `<expr> ~* '<pattern>'` with `mj_regex_imatch(<expr>, '<pattern>')`
    // 2) Replace `NULLIF('...', '')::uuid` and `<expr>::uuid` with `mj_try_uuid(...)`
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

function createSqliteRlsDatabase(): SqliteDatabase {
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
        const re = new RegExp(pattern, 'i');
        return re.test(val) ? 1 : 0;
    });

    db.function('BTRIM', (val) => (typeof val === 'string' ? val.trim() : val));

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

        CREATE TABLE __mj_BizAppsTasks."TaskTimeEntry" (
            "ID" TEXT PRIMARY KEY,
            "TaskID" TEXT,
            "PersonID" TEXT NOT NULL,
            "Hours" REAL NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."MeetingSeries" (
            "ID" TEXT PRIMARY KEY,
            "Name" TEXT NOT NULL,
            "Visibility" TEXT NOT NULL,
            "OrganizerPersonID" TEXT NOT NULL,
            "CreatedByPersonID" TEXT
        );

        CREATE TABLE __mj_BizAppsTasks."Meeting" (
            "ID" TEXT PRIMARY KEY,
            "Title" TEXT NOT NULL,
            "Visibility" TEXT NOT NULL,
            "OrganizerPersonID" TEXT NOT NULL,
            "CreatedByPersonID" TEXT,
            "SeriesID" TEXT
        );

        CREATE TABLE __mj_BizAppsTasks."MeetingAttendee" (
            "ID" TEXT PRIMARY KEY,
            "MeetingID" TEXT NOT NULL,
            "PersonID" TEXT,
            "UserID" TEXT
        );

        CREATE TABLE __mj_BizAppsTasks."MeetingSeriesAttendee" (
            "ID" TEXT PRIMARY KEY,
            "SeriesID" TEXT NOT NULL,
            "PersonID" TEXT,
            "UserID" TEXT
        );

        CREATE TABLE __mj_BizAppsTasks."MeetingLink" (
            "ID" TEXT PRIMARY KEY,
            "MeetingID" TEXT,
            "SeriesID" TEXT,
            "EntityID" TEXT NOT NULL,
            "RecordID" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."WorkReport" (
            "ID" TEXT PRIMARY KEY,
            "PersonID" TEXT NOT NULL,
            "Title" TEXT NOT NULL,
            "Status" TEXT NOT NULL
        );

        CREATE TABLE __mj_BizAppsTasks."WorkReportItem" (
            "ID" TEXT PRIMARY KEY,
            "WorkReportID" TEXT NOT NULL,
            "TaskID" TEXT,
            "Summary" TEXT NOT NULL
        );
    `);

    return db;
}

function seedMultiChainFixture(db: SqliteDatabase): void {
    db.exec(`
        -- Entities & UI Role
        INSERT INTO __mj."Entity" ("ID", "Name") VALUES
            ('${ENTITY_PEOPLE_ID}', 'MJ_BizApps_Common: People'),
            ('${ENTITY_USERS_ID}', 'MJ: Users'),
            ('${ENTITY_ROLES_ID}', 'MJ: Roles'),
            ('${ENTITY_TASKS_ID}', 'MJ_BizApps_Tasks: Tasks');

        INSERT INTO __mj."Role" ("ID", "Name") VALUES
            ('${UI_ROLE_ID}', 'UI');

        -- Organizations & Relationship Type
        INSERT INTO __mj_BizAppsCommon."Organization" ("ID", "Name", "LinkedCompanyID") VALUES
            ('${ORG_1_ID}', 'Acme Corp (Org 1)', '${COMPANY_1_ID}'),
            ('${ORG_2_ID}', 'External Partners (Org 2)', '${COMPANY_2_ID}');

        INSERT INTO __mj_BizAppsCommon."RelationshipType" ("ID", "Name", "Category") VALUES
            ('${REL_TYPE_P2O_ID}', 'Works At', 'PersonToOrganization');

        -- Employees (Company 1 vs Company 2)
        INSERT INTO __mj."Employee" ("ID", "CompanyID", "Email", "SupervisorID", "Active") VALUES
            ('60000000-0000-4000-8000-000000000001', '${COMPANY_1_ID}', 'd1@acme.test', NULL, 1),
            ('60000000-0000-4000-8000-000000000002', '${COMPANY_1_ID}', 'm1@acme.test', '60000000-0000-4000-8000-000000000001', 1),
            ('60000000-0000-4000-8000-000000000003', '${COMPANY_1_ID}', 'a@acme.test', '60000000-0000-4000-8000-000000000002', 1),
            ('60000000-0000-4000-8000-000000000004', '${COMPANY_1_ID}', 'm2@acme.test', NULL, 1),
            ('60000000-0000-4000-8000-000000000005', '${COMPANY_1_ID}', 'b@acme.test', '60000000-0000-4000-8000-000000000004', 1),
            ('60000000-0000-4000-8000-000000000006', '${COMPANY_1_ID}', 'rd1@acme.test', NULL, 1),
            ('60000000-0000-4000-8000-000000000007', '${COMPANY_1_ID}', 'r1@acme.test', '60000000-0000-4000-8000-000000000006', 1),
            ('60000000-0000-4000-8000-000000000008', '${COMPANY_2_ID}', 'c@external.test', NULL, 1);

        -- Users (mix of Person.LinkedUserID and User.LinkedEntityRecordID identity resolution)
        INSERT INTO __mj."User" ("ID", "Name", "Email", "Type", "IsActive", "EmployeeID", "LinkedEntityID", "LinkedEntityRecordID") VALUES
            ('${USER_D1_ID}', 'Director D1', 'd1@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000001', NULL, NULL),
            ('${USER_M1_ID}', 'Manager M1', 'm1@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000002', '${ENTITY_PEOPLE_ID}', '${PERSON_M1_ID}'),
            ('${USER_A_ID}', 'IC User A', 'a@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000003', NULL, NULL),
            ('${USER_M2_ID}', 'Manager M2', 'm2@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000004', NULL, NULL),
            ('${USER_B_ID}', 'IC User B', 'b@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000005', NULL, NULL),
            ('${USER_RD1_ID}', 'Root Director RD1', 'rd1@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000006', NULL, NULL),
            ('${USER_R1_ID}', 'Root Owner R1', 'r1@acme.test', 'User', 1, '60000000-0000-4000-8000-000000000007', NULL, NULL),
            ('${USER_C_ID}', 'External User C', 'c@external.test', 'User', 1, '60000000-0000-4000-8000-000000000008', NULL, NULL);

        INSERT INTO __mj."UserRole" ("ID", "UserID", "RoleID") VALUES
            ('61000000-0000-4000-8000-000000000001', '${USER_D1_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000002', '${USER_M1_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000003', '${USER_A_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000004', '${USER_M2_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000005', '${USER_B_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000006', '${USER_RD1_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000007', '${USER_R1_ID}', '${UI_ROLE_ID}'),
            ('61000000-0000-4000-8000-000000000008', '${USER_C_ID}', '${UI_ROLE_ID}');

        -- People & SupervisorPersonID hierarchy
        -- Note: M1 has LinkedUserID = NULL to explicitly verify User.LinkedEntityRecordID fallback path
        INSERT INTO __mj_BizAppsCommon."Person" ("ID", "FirstName", "LastName", "Email", "LinkedUserID", "SupervisorPersonID", "Status") VALUES
            ('${PERSON_D1_ID}', 'Director', 'D1', 'd1@acme.test', '${USER_D1_ID}', NULL, 'Active'),
            ('${PERSON_M1_ID}', 'Manager', 'M1', 'm1@acme.test', NULL, '${PERSON_D1_ID}', 'Active'),
            ('${PERSON_A_ID}', 'User', 'A', 'a@acme.test', '${USER_A_ID}', '${PERSON_M1_ID}', 'Active'),
            ('${PERSON_M2_ID}', 'Manager', 'M2', 'm2@acme.test', '${USER_M2_ID}', NULL, 'Active'),
            ('${PERSON_B_ID}', 'User', 'B', 'b@acme.test', '${USER_B_ID}', '${PERSON_M2_ID}', 'Active'),
            ('${PERSON_RD1_ID}', 'RootDirector', 'RD1', 'rd1@acme.test', '${USER_RD1_ID}', NULL, 'Active'),
            ('${PERSON_R1_ID}', 'RootOwner', 'R1', 'r1@acme.test', '${USER_R1_ID}', '${PERSON_RD1_ID}', 'Active'),
            ('${PERSON_C_ID}', 'External', 'C', 'c@external.test', '${USER_C_ID}', NULL, 'Active');

        -- PersonToOrganization Relationships (Org 1 vs Org 2)
        INSERT INTO __mj_BizAppsCommon."Relationship" ("ID", "RelationshipTypeID", "FromPersonID", "ToPersonID", "FromOrganizationID", "ToOrganizationID", "Status") VALUES
            ('62000000-0000-4000-8000-000000000001', '${REL_TYPE_P2O_ID}', '${PERSON_D1_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000002', '${REL_TYPE_P2O_ID}', '${PERSON_M1_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000003', '${REL_TYPE_P2O_ID}', '${PERSON_A_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000004', '${REL_TYPE_P2O_ID}', '${PERSON_M2_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000005', '${REL_TYPE_P2O_ID}', '${PERSON_B_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000006', '${REL_TYPE_P2O_ID}', '${PERSON_RD1_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000007', '${REL_TYPE_P2O_ID}', '${PERSON_R1_ID}', NULL, NULL, '${ORG_1_ID}', 'Active'),
            ('62000000-0000-4000-8000-000000000008', '${REL_TYPE_P2O_ID}', '${PERSON_C_ID}', NULL, NULL, '${ORG_2_ID}', 'Active');

        -- Tasks across Private, Team, Organization, RootParentID inheritance, and Org 2
        INSERT INTO __mj_BizAppsTasks."Task" ("ID", "Name", "ParentID", "RootParentID", "Visibility", "CreatedByPersonID", "OrganizationID") VALUES
            ('${TASK_A_TEAM_ID}', 'Chain A Team Task 1', NULL, NULL, 'Team', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_A_TEAM_2_ID}', 'Chain A Team Task 2', NULL, NULL, 'Team', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_A_PRIVATE_ID}', 'Chain A Private Task', NULL, NULL, 'Private', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_A_PRIVATE_ASSIGNED_B_ID}', 'Private Task Shared With B', NULL, NULL, 'Private', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_A_ORG_ID}', 'Org 1 Wide Task', NULL, NULL, 'Organization', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_B_TEAM_ID}', 'Chain B Team Task', NULL, NULL, 'Team', '${PERSON_B_ID}', '${ORG_1_ID}'),
            ('${TASK_ROOT_R1_ID}', 'Root Task Owned by R1', NULL, NULL, 'Team', '${PERSON_R1_ID}', '${ORG_1_ID}'),
            ('${TASK_SUB_UNDER_R1_ID}', 'Subtask Under R1 Created by A', '${TASK_ROOT_R1_ID}', '${TASK_ROOT_R1_ID}', 'Team', '${PERSON_A_ID}', '${ORG_1_ID}'),
            ('${TASK_C_ORG_ID}', 'Org 2 Wide Task', NULL, NULL, 'Organization', '${PERSON_C_ID}', '${ORG_2_ID}');

        -- Task Assignments
        INSERT INTO __mj_BizAppsTasks."TaskAssignment" ("ID", "TaskID", "AssigneeEntityID", "AssigneeRecordID") VALUES
            ('${ASSIGN_A_TEAM_ID}', '${TASK_A_TEAM_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_A_ID}'),
            ('${ASSIGN_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_A_ID}'),
            ('${ASSIGN_A_PRIVATE_TO_B_ID}', '${TASK_A_PRIVATE_ASSIGNED_B_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_B_ID}'),
            ('${ASSIGN_A_ORG_ID}', '${TASK_A_ORG_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_A_ID}'),
            ('${ASSIGN_SUB_R1_TO_A_ID}', '${TASK_SUB_UNDER_R1_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_A_ID}'),
            ('${ASSIGN_B_TEAM_ID}', '${TASK_B_TEAM_ID}', '${ENTITY_PEOPLE_ID}', '${PERSON_B_ID}');

        -- Task Dependencies (including cross-visibility Team -> Private edge)
        INSERT INTO __mj_BizAppsTasks."TaskDependency" ("ID", "TaskID", "DependsOnTaskID") VALUES
            ('${DEP_TEAM_TO_TEAM_ID}', '${TASK_A_TEAM_ID}', '${TASK_A_TEAM_2_ID}'),
            ('${DEP_TEAM_TO_PRIVATE_ID}', '${TASK_A_TEAM_ID}', '${TASK_A_PRIVATE_ID}'),
            ('${DEP_PRIVATE_TO_TEAM_ID}', '${TASK_A_PRIVATE_ID}', '${TASK_A_TEAM_ID}'),
            ('${DEP_B_TEAM_TO_ORG_ID}', '${TASK_B_TEAM_ID}', '${TASK_A_ORG_ID}');

        -- Task Check Ins
        INSERT INTO __mj_BizAppsTasks."TaskCheckIn" ("ID", "TaskID", "Summary") VALUES
            ('${CHECKIN_A_TEAM_ID}', '${TASK_A_TEAM_ID}', 'Team check-in A'),
            ('${CHECKIN_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', 'Private check-in A'),
            ('${CHECKIN_A_ORG_ID}', '${TASK_A_ORG_ID}', 'Org 1 check-in A'),
            ('${CHECKIN_SUB_R1_ID}', '${TASK_SUB_UNDER_R1_ID}', 'Subtask check-in under R1'),
            ('${CHECKIN_B_TEAM_ID}', '${TASK_B_TEAM_ID}', 'Team check-in B');

        -- Task Comments
        INSERT INTO __mj_BizAppsTasks."TaskComment" ("ID", "TaskID", "Body") VALUES
            ('${COMMENT_A_TEAM_ID}', '${TASK_A_TEAM_ID}', 'Team comment A'),
            ('${COMMENT_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', 'Private comment A'),
            ('${COMMENT_A_ORG_ID}', '${TASK_A_ORG_ID}', 'Org 1 comment A'),
            ('${COMMENT_SUB_R1_ID}', '${TASK_SUB_UNDER_R1_ID}', 'Subtask comment under R1'),
            ('${COMMENT_B_TEAM_ID}', '${TASK_B_TEAM_ID}', 'Team comment B');

        -- Task Links
        INSERT INTO __mj_BizAppsTasks."TaskLink" ("ID", "TaskID", "EntityID", "RecordID") VALUES
            ('${LINK_A_TEAM_ID}', '${TASK_A_TEAM_ID}', '${ENTITY_TASKS_ID}', 'REC-TEAM-A'),
            ('${LINK_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', '${ENTITY_TASKS_ID}', 'REC-PRIV-A'),
            ('${LINK_A_ORG_ID}', '${TASK_A_ORG_ID}', '${ENTITY_TASKS_ID}', 'REC-ORG-A'),
            ('${LINK_SUB_R1_ID}', '${TASK_SUB_UNDER_R1_ID}', '${ENTITY_TASKS_ID}', 'REC-SUB-R1'),
            ('${LINK_B_TEAM_ID}', '${TASK_B_TEAM_ID}', '${ENTITY_TASKS_ID}', 'REC-TEAM-B');

        -- Task Activities
        INSERT INTO __mj_BizAppsTasks."TaskActivity" ("ID", "TaskID", "Description") VALUES
            ('${ACT_A_TEAM_ID}', '${TASK_A_TEAM_ID}', 'Team activity A'),
            ('${ACT_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', 'Private activity A'),
            ('${ACT_A_ORG_ID}', '${TASK_A_ORG_ID}', 'Org 1 activity A'),
            ('${ACT_SUB_R1_ID}', '${TASK_SUB_UNDER_R1_ID}', 'Subtask activity under R1'),
            ('${ACT_B_TEAM_ID}', '${TASK_B_TEAM_ID}', 'Team activity B');

        -- Task Risk Assessments
        INSERT INTO __mj_BizAppsTasks."TaskRiskAssessment" ("ID", "TaskID", "HealthStatus") VALUES
            ('${RISK_A_TEAM_ID}', '${TASK_A_TEAM_ID}', 'OnTrack'),
            ('${RISK_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', 'AtRisk'),
            ('${RISK_A_ORG_ID}', '${TASK_A_ORG_ID}', 'OnTrack'),
            ('${RISK_SUB_R1_ID}', '${TASK_SUB_UNDER_R1_ID}', 'OnTrack'),
            ('${RISK_B_TEAM_ID}', '${TASK_B_TEAM_ID}', 'OffTrack');

        -- Time Entries (task-linked + standalone NULL TaskID)
        INSERT INTO __mj_BizAppsTasks."TaskTimeEntry" ("ID", "TaskID", "PersonID", "Hours") VALUES
            ('${TE_A_TEAM_ID}', '${TASK_A_TEAM_ID}', '${PERSON_A_ID}', 2.5),
            ('${TE_A_PRIVATE_ID}', '${TASK_A_PRIVATE_ID}', '${PERSON_A_ID}', 1.0),
            ('${TE_A_STANDALONE_ID}', NULL, '${PERSON_A_ID}', 3.0),
            ('${TE_B_STANDALONE_ID}', NULL, '${PERSON_B_ID}', 4.0),
            ('${TE_C_STANDALONE_ID}', NULL, '${PERSON_C_ID}', 5.0);

        INSERT INTO __mj_BizAppsTasks."MeetingSeries" ("ID", "Name", "Visibility", "OrganizerPersonID", "CreatedByPersonID") VALUES
            ('58100000-0000-4000-8000-000000000001', 'Chain A Weekly Series', 'Standard', '${PERSON_A_ID}', '${PERSON_A_ID}'),
            ('58100000-0000-4000-8000-000000000002', 'Chain A Private Series', 'Private', '${PERSON_A_ID}', '${PERSON_A_ID}');

        INSERT INTO __mj_BizAppsTasks."MeetingSeriesAttendee" ("ID", "SeriesID", "PersonID", "UserID") VALUES
            ('58200000-0000-4000-8000-000000000001', '58100000-0000-4000-8000-000000000001', '${PERSON_A_ID}', '${USER_A_ID}'),
            ('58200000-0000-4000-8000-000000000002', '58100000-0000-4000-8000-000000000002', '${PERSON_A_ID}', '${USER_A_ID}');

        -- Meetings & Meeting Links
        INSERT INTO __mj_BizAppsTasks."Meeting" ("ID", "Title", "Visibility", "OrganizerPersonID", "CreatedByPersonID", "SeriesID") VALUES
            ('${MTG_A_STANDARD_ID}', 'Chain A Standard Sync', 'Standard', '${PERSON_A_ID}', '${PERSON_A_ID}', '58100000-0000-4000-8000-000000000001'),
            ('${MTG_A_PRIVATE_ID}', 'User A Private 1:1', 'Private', '${PERSON_A_ID}', '${PERSON_A_ID}', NULL),
            ('${MTG_B_STANDARD_ID}', 'Chain B Standard Sync', 'Standard', '${PERSON_B_ID}', '${PERSON_B_ID}', NULL),
            ('${MTG_LINKED_TEAM_ID}', 'R1 Sync Linked to A Team Task', 'Standard', '${PERSON_R1_ID}', '${PERSON_R1_ID}', NULL),
            ('${MTG_R1_LINKED_PRIVATE_A_ID}', 'R1 Sync Linked to A Private Task', 'Standard', '${PERSON_R1_ID}', '${PERSON_R1_ID}', NULL);

        INSERT INTO __mj_BizAppsTasks."MeetingAttendee" ("ID", "MeetingID", "PersonID", "UserID") VALUES
            ('58300000-0000-4000-8000-000000000001', '${MTG_A_STANDARD_ID}', '${PERSON_A_ID}', '${USER_A_ID}'),
            ('58300000-0000-4000-8000-000000000002', '${MTG_A_PRIVATE_ID}', '${PERSON_A_ID}', '${USER_A_ID}'),
            ('58300000-0000-4000-8000-000000000003', '${MTG_B_STANDARD_ID}', '${PERSON_B_ID}', '${USER_B_ID}');

        INSERT INTO __mj_BizAppsTasks."MeetingLink" ("ID", "MeetingID", "SeriesID", "EntityID", "RecordID") VALUES
            ('63000000-0000-4000-8000-000000000001', '${MTG_LINKED_TEAM_ID}', NULL, '${ENTITY_TASKS_ID}', '${TASK_A_TEAM_ID}'),
            ('63000000-0000-4000-8000-000000000002', '${MTG_R1_LINKED_PRIVATE_A_ID}', NULL, '${ENTITY_TASKS_ID}', '${TASK_A_PRIVATE_ID}');

        -- Work Reports & Work Report Items
        INSERT INTO __mj_BizAppsTasks."WorkReport" ("ID", "PersonID", "Title", "Status") VALUES
            ('${WR_A_DRAFT_ID}', '${PERSON_A_ID}', 'User A Draft Report', 'Draft'),
            ('${WR_A_SUBMITTED_ID}', '${PERSON_A_ID}', 'User A Submitted Report', 'Submitted'),
            ('${WR_B_SUBMITTED_ID}', '${PERSON_B_ID}', 'User B Submitted Report', 'Submitted'),
            ('${WR_C_SUBMITTED_ID}', '${PERSON_C_ID}', 'User C Submitted Report', 'Submitted');

        INSERT INTO __mj_BizAppsTasks."WorkReportItem" ("ID", "WorkReportID", "TaskID", "Summary") VALUES
            ('${WRI_A_DRAFT_ID}', '${WR_A_DRAFT_ID}', '${TASK_A_TEAM_ID}', 'User A draft work item'),
            ('${WRI_A_SUBMITTED_ID}', '${WR_A_SUBMITTED_ID}', '${TASK_A_TEAM_ID}', 'User A submitted work item'),
            ('${WRI_B_SUBMITTED_ID}', '${WR_B_SUBMITTED_ID}', '${TASK_B_TEAM_ID}', 'User B submitted work item');
    `);
}

function makeUiUser(id: string, name: string, email: string): UserInfo {
    return new UserInfo(null, {
        ID: id,
        Name: name,
        Email: email,
        Type: 'User',
        IsActive: true,
        UserRoles: [{ UserID: id, RoleID: UI_ROLE_ID, Role: 'UI' }],
    });
}

describe('Slice 3: Multi-Chain & Manager Hierarchy Relational RLS Integration Suite', () => {
    const metadata = loadRlsMetadata();
    const filterByName = new Map<string, RowLevelSecurityFilterInfo>();
    const entityInfoByName = new Map<string, EntityInfo>();

    let db: SqliteDatabase;
    let savedProvider: IMetadataProvider | undefined;

    const userA = makeUiUser(USER_A_ID, 'IC User A', 'a@acme.test');
    const managerM1 = makeUiUser(USER_M1_ID, 'Manager M1', 'm1@acme.test');
    const directorD1 = makeUiUser(USER_D1_ID, 'Director D1', 'd1@acme.test');
    const userB = makeUiUser(USER_B_ID, 'IC User B', 'b@acme.test');
    const managerM2 = makeUiUser(USER_M2_ID, 'Manager M2', 'm2@acme.test');
    const rootOwnerR1 = makeUiUser(USER_R1_ID, 'Root Owner R1', 'r1@acme.test');
    const rootDirectorRD1 = makeUiUser(USER_RD1_ID, 'Root Director RD1', 'rd1@acme.test');
    const externalUserC = makeUiUser(USER_C_ID, 'External User C', 'c@external.test');

    function queryVisibleIds(
        entityName: string,
        tableName: string,
        user: UserInfo,
        dialect: SqlDialect,
        permissionType: EntityPermissionType = EntityPermissionType.Read,
    ): string[] {
        const entityInfo = entityInfoByName.get(entityName);
        if (!entityInfo) {
            throw new Error(`Missing EntityInfo for ${entityName}`);
        }
        const whereClause = entityInfo.GetEffectiveRowFilterWhereClause(
            user,
            permissionType,
            '',
            undefined,
            dialect,
        );
        expect(whereClause.trim().length, `${entityName} (${dialect}): empty RLS clause`).toBeGreaterThan(0);

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

        const descriptors = [...GOVERNED_ENTITIES, ...SUPPLEMENTAL_ENTITIES];
        for (const desc of descriptors) {
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

            const resolveFilterId = (lookupVal: string | undefined): string | null => {
                if (!lookupVal) return null;
                const name = lookupVal.startsWith(LOOKUP_PREFIX) ? lookupVal.slice(LOOKUP_PREFIX.length) : lookupVal;
                const matched = filterByName.get(name);
                expect(matched, `Filter '${name}' referenced by ${desc.EntityName} not found`).toBeDefined();
                return matched!.ID;
            };

            const entityInfo = new EntityInfo({
                ID: desc.EntityID,
                Name: desc.EntityName,
                SchemaName: '__mj_BizAppsTasks',
                BaseTable: desc.TableName,
                BaseView: desc.TableName,
                Permissions: [
                    {
                        ID: `perm-${desc.EntityID}`,
                        EntityID: desc.EntityID,
                        RoleID: UI_ROLE_ID,
                        CanRead: Boolean(uiPerm?.fields.CanRead),
                        CanCreate: Boolean(uiPerm?.fields.CanCreate),
                        CanUpdate: Boolean(uiPerm?.fields.CanUpdate),
                        CanDelete: Boolean(uiPerm?.fields.CanDelete),
                        ReadRLSFilterID: resolveFilterId(uiPerm?.fields.ReadRLSFilterID),
                        CreateRLSFilterID: resolveFilterId(uiPerm?.fields.CreateRLSFilterID),
                        UpdateRLSFilterID: resolveFilterId(uiPerm?.fields.UpdateRLSFilterID),
                        DeleteRLSFilterID: resolveFilterId(uiPerm?.fields.DeleteRLSFilterID),
                        Type: 'Allow',
                    },
                ],
                Fields: [],
            });
            entityInfoByName.set(desc.EntityName, entityInfo);
        }

        db = createSqliteRlsDatabase();
        seedMultiChainFixture(db);
    });

    afterAll(() => {
        if (db) {
            db.close();
        }
        if (savedProvider) {
            Metadata.Provider = savedProvider;
        }
    });

    it('populates vwPersonReportingChain recursively at depth 1 (M1) and depth 2 (D1) with zero cross-chain edges', () => {
        const rows = db
            .prepare(
                `SELECT "PersonID" || ':' || "SupervisorPersonID" || ':' || CAST("Depth" AS TEXT) AS "ID"
                 FROM __mj_BizAppsCommon."vwPersonReportingChain"
                 ORDER BY "PersonID", "Depth"`,
            )
            .all()
            .map((r) => r.ID);

        expect(rows).toContain(`${PERSON_A_ID}:${PERSON_M1_ID}:1`);
        expect(rows).toContain(`${PERSON_A_ID}:${PERSON_D1_ID}:2`);
        expect(rows).toContain(`${PERSON_B_ID}:${PERSON_M2_ID}:1`);
        expect(rows).toContain(`${PERSON_R1_ID}:${PERSON_RD1_ID}:1`);
        expect(rows.some((r) => r.startsWith(`${PERSON_A_ID}:${PERSON_M2_ID}:`))).toBe(false);
        expect(rows.some((r) => r.startsWith(`${PERSON_B_ID}:${PERSON_M1_ID}:`))).toBe(false);
    });

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces Private, Team, Organization, RootParentID inheritance, and cross-org isolation on Tasks',
        (dialect) => {
            const visibleA = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', userA, dialect);
            const visibleM1 = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', managerM1, dialect);
            const visibleD1 = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', directorD1, dialect);
            const visibleB = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', userB, dialect);
            const visibleM2 = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', managerM2, dialect);
            const visibleR1 = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', rootOwnerR1, dialect);
            const visibleRD1 = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', rootDirectorRD1, dialect);
            const visibleC = queryVisibleIds('MJ_BizApps_Tasks: Tasks', 'vwTasks', externalUserC, dialect);

            // User A sees own Team, own Private (both), Org 1, and subtask created by A under R1
            expect(visibleA).toEqual(
                [
                    TASK_A_TEAM_ID,
                    TASK_A_TEAM_2_ID,
                    TASK_A_PRIVATE_ID,
                    TASK_A_PRIVATE_ASSIGNED_B_ID,
                    TASK_A_ORG_ID,
                    TASK_SUB_UNDER_R1_ID,
                ].sort(),
            );

            // Direct Manager M1 (depth 1, via LinkedEntityRecordID) and Skip-Level Director D1 (depth 2, via LinkedUserID)
            // inherit A's Team tasks, Org 1 tasks, and subtask under R1 — NEVER A's Private tasks
            const expectedChainA = [
                TASK_A_TEAM_ID,
                TASK_A_TEAM_2_ID,
                TASK_A_ORG_ID,
                TASK_SUB_UNDER_R1_ID,
            ].sort();
            expect(visibleM1).toEqual(expectedChainA);
            expect(visibleD1).toEqual(expectedChainA);

            // User B (Chain B in Org 1) sees ZERO of User A's Team or Private tasks (except the Private task explicitly assigned to B),
            // sees B's own Team task and Org 1 Organization task, and sees ZERO Org 2 tasks
            expect(visibleB).toEqual([TASK_A_PRIVATE_ASSIGNED_B_ID, TASK_A_ORG_ID, TASK_B_TEAM_ID].sort());
            expect(visibleB).not.toContain(TASK_A_TEAM_ID);
            expect(visibleB).not.toContain(TASK_A_PRIVATE_ID);
            expect(visibleB).not.toContain(TASK_SUB_UNDER_R1_ID);

            // Manager M2 (Chain B) sees B's Team task and Org 1 task, NEVER Private task assigned to B, NEVER Chain A Team tasks
            expect(visibleM2).toEqual([TASK_A_ORG_ID, TASK_B_TEAM_ID].sort());

            // RootOwner R1 & RootDirector RD1 inherit visibility to TASK_SUB_UNDER_R1 via RootParentID + vwPersonReportingChain,
            // plus Org 1 task, without seeing User A's unrelated Team or Private tasks
            expect(visibleR1).toEqual([TASK_A_ORG_ID, TASK_ROOT_R1_ID, TASK_SUB_UNDER_R1_ID].sort());
            expect(visibleRD1).toEqual([TASK_A_ORG_ID, TASK_ROOT_R1_ID, TASK_SUB_UNDER_R1_ID].sort());

            // External User C (Org 2) sees ONLY Org 2's task — zero Org 1 Private, Team, or Organization tasks
            expect(visibleC).toEqual([TASK_C_ORG_ID]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces chain-of-command, Private exclusion, and RootParentID across all 6 Task child entities',
        (dialect) => {
            const childEntities: ReadonlyArray<{
                entityName: string;
                tableName: string;
                aTeamId: string;
                aPrivateId: string;
                aOrgId: string;
                subR1Id: string;
                bTeamId: string;
            }> = [
                {
                    entityName: 'MJ_BizApps_Tasks: Task Assignments',
                    tableName: 'TaskAssignment',
                    aTeamId: ASSIGN_A_TEAM_ID,
                    aPrivateId: ASSIGN_A_PRIVATE_ID,
                    aOrgId: ASSIGN_A_ORG_ID,
                    subR1Id: ASSIGN_SUB_R1_TO_A_ID,
                    bTeamId: ASSIGN_B_TEAM_ID,
                },
                {
                    entityName: 'MJ_BizApps_Tasks: Task Check Ins',
                    tableName: 'TaskCheckIn',
                    aTeamId: CHECKIN_A_TEAM_ID,
                    aPrivateId: CHECKIN_A_PRIVATE_ID,
                    aOrgId: CHECKIN_A_ORG_ID,
                    subR1Id: CHECKIN_SUB_R1_ID,
                    bTeamId: CHECKIN_B_TEAM_ID,
                },
                {
                    entityName: 'MJ_BizApps_Tasks: Task Comments',
                    tableName: 'TaskComment',
                    aTeamId: COMMENT_A_TEAM_ID,
                    aPrivateId: COMMENT_A_PRIVATE_ID,
                    aOrgId: COMMENT_A_ORG_ID,
                    subR1Id: COMMENT_SUB_R1_ID,
                    bTeamId: COMMENT_B_TEAM_ID,
                },
                {
                    entityName: 'MJ_BizApps_Tasks: Task Links',
                    tableName: 'TaskLink',
                    aTeamId: LINK_A_TEAM_ID,
                    aPrivateId: LINK_A_PRIVATE_ID,
                    aOrgId: LINK_A_ORG_ID,
                    subR1Id: LINK_SUB_R1_ID,
                    bTeamId: LINK_B_TEAM_ID,
                },
                {
                    entityName: 'MJ_BizApps_Tasks: Task Activities',
                    tableName: 'TaskActivity',
                    aTeamId: ACT_A_TEAM_ID,
                    aPrivateId: ACT_A_PRIVATE_ID,
                    aOrgId: ACT_A_ORG_ID,
                    subR1Id: ACT_SUB_R1_ID,
                    bTeamId: ACT_B_TEAM_ID,
                },
                {
                    entityName: 'MJ_BizApps_Tasks: Task Risk Assessments',
                    tableName: 'TaskRiskAssessment',
                    aTeamId: RISK_A_TEAM_ID,
                    aPrivateId: RISK_A_PRIVATE_ID,
                    aOrgId: RISK_A_ORG_ID,
                    subR1Id: RISK_SUB_R1_ID,
                    bTeamId: RISK_B_TEAM_ID,
                },
            ];

            for (const child of childEntities) {
                const visA = queryVisibleIds(child.entityName, child.tableName, userA, dialect);
                const visM1 = queryVisibleIds(child.entityName, child.tableName, managerM1, dialect);
                const visD1 = queryVisibleIds(child.entityName, child.tableName, directorD1, dialect);
                const visB = queryVisibleIds(child.entityName, child.tableName, userB, dialect);
                const visR1 = queryVisibleIds(child.entityName, child.tableName, rootOwnerR1, dialect);
                const visRD1 = queryVisibleIds(child.entityName, child.tableName, rootDirectorRD1, dialect);
                const visC = queryVisibleIds(child.entityName, child.tableName, externalUserC, dialect);

                expect(visA, `${child.entityName} User A`).toEqual(
                    expect.arrayContaining([child.aTeamId, child.aPrivateId, child.aOrgId, child.subR1Id]),
                );
                expect(visA, `${child.entityName} User A excludes B`).not.toContain(child.bTeamId);

                for (const [label, vis] of [
                    ['M1', visM1],
                    ['D1', visD1],
                ] as const) {
                    expect(vis, `${child.entityName} ${label}`).toEqual(
                        [child.aTeamId, child.aOrgId, child.subR1Id].sort(),
                    );
                    expect(vis, `${child.entityName} ${label} excludes Private`).not.toContain(child.aPrivateId);
                    expect(vis, `${child.entityName} ${label} excludes Chain B`).not.toContain(child.bTeamId);
                }

                // User B sees own Team child + Org 1 child (+ explicit Private assignment if TaskAssignment), ZERO A Team/Private
                expect(visB, `${child.entityName} User B excludes A Team`).not.toContain(child.aTeamId);
                expect(visB, `${child.entityName} User B excludes A Private`).not.toContain(child.aPrivateId);
                expect(visB, `${child.entityName} User B includes B Team & Org`).toEqual(
                    expect.arrayContaining([child.bTeamId, child.aOrgId]),
                );

                // RootOwner R1 & RootDirector RD1 inherit subtask child rows
                expect(visR1, `${child.entityName} R1`).toEqual([child.aOrgId, child.subR1Id].sort());
                expect(visRD1, `${child.entityName} RD1`).toEqual([child.aOrgId, child.subR1Id].sort());

                // External User C (Org 2) sees ZERO Org 1 child records
                expect(visC, `${child.entityName} External User C`).toEqual([]);
            }
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces dual-endpoint visibility on Task Dependencies so Team->Private never leaks',
        (dialect) => {
            const visA = queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', userA, dialect);
            const visM1 = queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', managerM1, dialect);
            const visD1 = queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', directorD1, dialect);
            const visB = queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', userB, dialect);
            const visC = queryVisibleIds('MJ_BizApps_Tasks: Task Dependencies', 'TaskDependency', externalUserC, dialect);

            // User A sees all 3 dependencies involving A's tasks (Team->Team, Team->Private, Private->Team)
            expect(visA).toEqual([DEP_TEAM_TO_TEAM_ID, DEP_TEAM_TO_PRIVATE_ID, DEP_PRIVATE_TO_TEAM_ID].sort());

            // M1 & D1 see Team->Team, MUST NOT see Team->Private or Private->Team
            expect(visM1).toEqual([DEP_TEAM_TO_TEAM_ID]);
            expect(visD1).toEqual([DEP_TEAM_TO_TEAM_ID]);

            // User B sees B_Team -> Org_1 dependency ONLY; zero Chain A dependencies
            expect(visB).toEqual([DEP_B_TEAM_TO_ORG_ID]);
            expect(visB).not.toContain(DEP_TEAM_TO_TEAM_ID);
            expect(visB).not.toContain(DEP_TEAM_TO_PRIVATE_ID);

            // External User C sees ZERO Org 1 dependencies
            expect(visC).toEqual([]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces task-linked and standalone (TaskID IS NULL) visibility on Task Time Entries',
        (dialect) => {
            const visA = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', userA, dialect);
            const visM1 = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', managerM1, dialect);
            const visD1 = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', directorD1, dialect);
            const visB = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', userB, dialect);
            const visM2 = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', managerM2, dialect);
            const visC = queryVisibleIds('MJ_BizApps_Tasks: Task Time Entries', 'TaskTimeEntry', externalUserC, dialect);

            // User A sees own Team, Private, and Standalone time entries
            expect(visA).toEqual([TE_A_TEAM_ID, TE_A_PRIVATE_ID, TE_A_STANDALONE_ID].sort());

            // M1 & D1 inherit Team + Standalone entries for A, NEVER Private task time entries or Chain B entries
            expect(visM1).toEqual([TE_A_TEAM_ID, TE_A_STANDALONE_ID].sort());
            expect(visD1).toEqual([TE_A_TEAM_ID, TE_A_STANDALONE_ID].sort());

            // Chain B sees ONLY Chain B standalone entry
            expect(visB).toEqual([TE_B_STANDALONE_ID]);
            expect(visM2).toEqual([TE_B_STANDALONE_ID]);

            // External User C sees ONLY Org 2 standalone entry
            expect(visC).toEqual([TE_C_STANDALONE_ID]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces Standard vs Private, organizer/linked-task chain, and cross-chain isolation on Meetings',
        (dialect) => {
            const visA = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', userA, dialect);
            const visM1 = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', managerM1, dialect);
            const visD1 = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', directorD1, dialect);
            const visB = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', userB, dialect);
            const visM2 = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', managerM2, dialect);
            const visR1 = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', rootOwnerR1, dialect);
            const visRD1 = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', rootDirectorRD1, dialect);
            const visC = queryVisibleIds('MJ_BizApps_Tasks: Meetings', 'Meeting', externalUserC, dialect);

            // User A sees A's Standard, A's Private, R1's meeting linked to A's Team task, and R1's meeting linked to A's Private task
            expect(visA).toEqual(
                [MTG_A_STANDARD_ID, MTG_A_PRIVATE_ID, MTG_LINKED_TEAM_ID, MTG_R1_LINKED_PRIVATE_A_ID].sort(),
            );

            // M1 & D1 inherit A's Standard meeting and R1's meeting linked to A's Team task,
            // NEVER A's Private meeting and NEVER R1's meeting linked only to A's Private task
            expect(visM1).toEqual([MTG_A_STANDARD_ID, MTG_LINKED_TEAM_ID].sort());
            expect(visD1).toEqual([MTG_A_STANDARD_ID, MTG_LINKED_TEAM_ID].sort());

            // Chain B sees ONLY Chain B meetings
            expect(visB).toEqual([MTG_B_STANDARD_ID]);
            expect(visM2).toEqual([MTG_B_STANDARD_ID]);

            // R1 & RD1 see meetings organized by R1
            expect(visR1).toEqual([MTG_LINKED_TEAM_ID, MTG_R1_LINKED_PRIVATE_A_ID].sort());
            expect(visRD1).toEqual([MTG_LINKED_TEAM_ID, MTG_R1_LINKED_PRIVATE_A_ID].sort());

            // External User C sees ZERO meetings
            expect(visC).toEqual([]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces arbitrary-depth vwPersonReportingChain visibility and Draft-author write bounds on Work Reports & Items',
        (dialect) => {
            const wrA = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', userA, dialect);
            const wrM1 = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', managerM1, dialect);
            const wrD1 = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', directorD1, dialect);
            const wrB = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', userB, dialect);
            const wrM2 = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', managerM2, dialect);
            const wrC = queryVisibleIds('MJ_BizApps_Tasks: Work Reports', 'WorkReport', externalUserC, dialect);

            expect(wrA).toEqual([WR_A_DRAFT_ID, WR_A_SUBMITTED_ID].sort());
            expect(wrM1).toEqual([WR_A_DRAFT_ID, WR_A_SUBMITTED_ID].sort());
            expect(wrD1).toEqual([WR_A_DRAFT_ID, WR_A_SUBMITTED_ID].sort());
            expect(wrB).toEqual([WR_B_SUBMITTED_ID]);
            expect(wrM2).toEqual([WR_B_SUBMITTED_ID]);
            expect(wrC).toEqual([WR_C_SUBMITTED_ID]);

            // Work Report Items Read RLS (author + reporting chain)
            const wriReadA = queryVisibleIds('MJ_BizApps_Tasks: Work Report Items', 'WorkReportItem', userA, dialect);
            const wriReadM1 = queryVisibleIds('MJ_BizApps_Tasks: Work Report Items', 'WorkReportItem', managerM1, dialect);
            const wriReadD1 = queryVisibleIds('MJ_BizApps_Tasks: Work Report Items', 'WorkReportItem', directorD1, dialect);
            const wriReadB = queryVisibleIds('MJ_BizApps_Tasks: Work Report Items', 'WorkReportItem', userB, dialect);
            const wriReadC = queryVisibleIds('MJ_BizApps_Tasks: Work Report Items', 'WorkReportItem', externalUserC, dialect);

            expect(wriReadA).toEqual([WRI_A_DRAFT_ID, WRI_A_SUBMITTED_ID].sort());
            expect(wriReadM1).toEqual([WRI_A_DRAFT_ID, WRI_A_SUBMITTED_ID].sort());
            expect(wriReadD1).toEqual([WRI_A_DRAFT_ID, WRI_A_SUBMITTED_ID].sort());
            expect(wriReadB).toEqual([WRI_B_SUBMITTED_ID]);
            expect(wriReadC).toEqual([]);

            // Work Report Items Update RLS (Draft Author Only) — managers M1/D1 cannot mutate A's items,
            // and even User A cannot mutate Submitted report items
            const wriWriteA = queryVisibleIds(
                'MJ_BizApps_Tasks: Work Report Items',
                'WorkReportItem',
                userA,
                dialect,
                EntityPermissionType.Update,
            );
            const wriWriteM1 = queryVisibleIds(
                'MJ_BizApps_Tasks: Work Report Items',
                'WorkReportItem',
                managerM1,
                dialect,
                EntityPermissionType.Update,
            );
            const wriWriteD1 = queryVisibleIds(
                'MJ_BizApps_Tasks: Work Report Items',
                'WorkReportItem',
                directorD1,
                dialect,
                EntityPermissionType.Update,
            );

            expect(wriWriteA).toEqual([WRI_A_DRAFT_ID]);
            expect(wriWriteM1).toEqual([]);
            expect(wriWriteD1).toEqual([]);
        },
    );

    it.each<SqlDialect>(['sqlserver', 'postgresql'])(
        '[%s] enforces Meeting Series, Series Attendees, Meeting Attendees, and Meeting Links RLS parity',
        (dialect) => {
            const msA = queryVisibleIds('MJ_BizApps_Tasks: Meeting Series', 'MeetingSeries', userA, dialect);
            const msM1 = queryVisibleIds('MJ_BizApps_Tasks: Meeting Series', 'MeetingSeries', managerM1, dialect);
            const msD1 = queryVisibleIds('MJ_BizApps_Tasks: Meeting Series', 'MeetingSeries', directorD1, dialect);
            const msB = queryVisibleIds('MJ_BizApps_Tasks: Meeting Series', 'MeetingSeries', userB, dialect);

            expect(msA).toEqual([
                '58100000-0000-4000-8000-000000000001',
                '58100000-0000-4000-8000-000000000002',
            ]);
            expect(msM1).toEqual(['58100000-0000-4000-8000-000000000001']);
            expect(msD1).toEqual(['58100000-0000-4000-8000-000000000001']);
            expect(msB).toEqual([]);

            const msaM1 = queryVisibleIds(
                'MJ_BizApps_Tasks: Meeting Series Attendees',
                'MeetingSeriesAttendee',
                managerM1,
                dialect,
            );
            const msaB = queryVisibleIds(
                'MJ_BizApps_Tasks: Meeting Series Attendees',
                'MeetingSeriesAttendee',
                userB,
                dialect,
            );
            expect(msaM1).toEqual(['58200000-0000-4000-8000-000000000001']);
            expect(msaB).toEqual([]);

            const maM1 = queryVisibleIds(
                'MJ_BizApps_Tasks: Meeting Attendees',
                'MeetingAttendee',
                managerM1,
                dialect,
            );
            const maB = queryVisibleIds(
                'MJ_BizApps_Tasks: Meeting Attendees',
                'MeetingAttendee',
                userB,
                dialect,
            );
            expect(maM1).toEqual(['58300000-0000-4000-8000-000000000001']);
            expect(maB).toEqual(['58300000-0000-4000-8000-000000000003']);

            const mlM1 = queryVisibleIds('MJ_BizApps_Tasks: Meeting Links', 'MeetingLink', managerM1, dialect);
            const mlA = queryVisibleIds('MJ_BizApps_Tasks: Meeting Links', 'MeetingLink', userA, dialect);
            const mlB = queryVisibleIds('MJ_BizApps_Tasks: Meeting Links', 'MeetingLink', userB, dialect);
            expect(mlA).toEqual([
                '63000000-0000-4000-8000-000000000001',
                '63000000-0000-4000-8000-000000000002',
            ]);
            expect(mlM1).toEqual(['63000000-0000-4000-8000-000000000001']);
            expect(mlB).toEqual([]);
        },
    );
});
