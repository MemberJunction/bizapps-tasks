/**
 * TASK-WORLD over the GraphQL wire.
 * Types / roles / decision outcomes are LOOKED UP from shipped metadata.
 * Extended categories, people, custom task types, task type statuses,
 * and 3 divergent top-level projects (Software, HQ Construction, Documentary Film)
 * are upserted through BaseEntity subclasses.
 */
import type { IMetadataProvider } from '@memberjunction/core';
import type { MJCompanyEntity, MJEmployeeEntity } from '@memberjunction/core-entities';
import { UUIDsEqual } from '@memberjunction/global';
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import {
    TaskEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCategoryEntity,
    mjBizAppsTasksTaskTemplateEntity,
    mjBizAppsTasksTaskTemplateItemEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    mjBizAppsCommonOrganizationEntity,
    mjBizAppsCommonPersonEntity,
} from '@mj-biz-apps/common-entities';
import {
    ACTION_ENTITY,
    COMPANY_ENTITY,
    EMPLOYEE_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    ORGANIZATION_ENTITY,
    PERSON_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_CATEGORY_ENTITY,
    TASK_DECISION_OUTCOME_ENTITY,
    TASK_ENTITY,
    TASK_ROLE_ENTITY,
    TASK_TEMPLATE_ENTITY,
    TASK_TEMPLATE_ITEM_ENTITY,
    TASK_TYPE_ENTITY,
    TASK_TYPE_STATUS_ENTITY,
    WORK_REPORT_ENTITY,
    WORK_REPORT_ITEM_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave } from '../wire.js';
import { GetWorld, SetWorld, type WorldState } from './world.js';

const WORLD_DOMAIN = 'task-world.test';
export const APEX_ORG_NAME = 'Apex Cloud Systems';
export const ACME_ORG_NAME = 'Acme Enterprise Corp';
export const CLOSE_TEMPLATE_NAME = 'Monthly Financial Close';
export const SEEDED_WORK_REPORT_TITLE = 'Weekly 15Five — Platform & Client Delivery';
export const SEEDED_MEETING_NAME = 'Q4 Executive Alignment Sync';

export async function LoadWorld(ctx: IntegrationCheckContext): Promise<WorldState> {
    // 1. Look up shipped task types, roles, decision outcomes
    const typeRows = await FindRows<{
        ID: string;
        Name: string;
        Code: string;
        OnCreateActionID?: string | null;
        OnStatusChangeActionID?: string | null;
    }>(ctx, TASK_TYPE_ENTITY, '', ['ID', 'Name', 'Code', 'OnCreateActionID', 'OnStatusChangeActionID']);
    const roleRows = await FindRows<{ ID: string; Name: string }>(ctx, TASK_ROLE_ENTITY, '', ['ID', 'Name']);
    const outcomeRows = await FindRows<{ ID: string; Name: string }>(ctx, TASK_DECISION_OUTCOME_ENTITY, '', ['ID', 'Name']);

    Assert(typeRows.length > 0, 'no Task Types — push metadata/task-types');
    Assert(roleRows.length > 0, 'no Task Roles — push metadata/task-roles');
    Assert(outcomeRows.length > 0, 'no Decision Outcomes — push metadata/task-decision-outcomes');

    // 2. Discover Candidate Actions (Calculate Expression, Color Converter, etc.)
    const Actions: WorldState['Actions'] = {};
    const actionRows = await FindRows<{ ID: string; Name: string; Type?: string; DriverClass?: string | null }>(
        ctx,
        ACTION_ENTITY,
        "Name IN ('Calculate Expression', 'Color Converter')",
        ['ID', 'Name', 'Type', 'DriverClass']
    );
    for (const a of actionRows) {
        Actions[a.Name] = a;
    }

    const calcAction = Actions['Calculate Expression'];
    const colorAction = Actions['Color Converter'];

    // 3. Populate TaskTypes dictionary
    const TaskTypes: WorldState['TaskTypes'] = {};
    for (const row of typeRows) {
        TaskTypes[row.Name] = row;
        if (row.Code) {
            TaskTypes[row.Code] = row;
        }
    }

    // Ensure custom domain-specific Task Types exist with Action hooks wired
    const customTypeDefs: Array<{
        name: string;
        code: string;
        description: string;
        onCreateActionID?: string | null;
        onStatusChangeActionID?: string | null;
    }> = [
        {
            name: 'Construction Milestone',
            code: 'CONSTRUCTION_MILESTONE',
            description: 'Civil, structural, architectural, and municipal construction phases with permitting and inspection gates.',
            onCreateActionID: calcAction?.ID ?? null,
            onStatusChangeActionID: calcAction?.ID ?? null,
        },
        {
            name: 'Media Production Stage',
            code: 'MEDIA_PRODUCTION',
            description: 'Film, audio, cinematography, and post-production creative workflow stages.',
            onCreateActionID: colorAction?.ID ?? null,
            onStatusChangeActionID: colorAction?.ID ?? null,
        },
    ];

    for (const def of customTypeDefs) {
        const existingID = await FindId(ctx, TASK_TYPE_ENTITY, `Code = '${Quote(def.code)}' OR Name = '${Quote(def.name)}'`);
        const typeEntity = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTypeEntity>(TASK_TYPE_ENTITY, ctx.User);
        if (existingID) {
            await typeEntity.Load(existingID);
        } else {
            typeEntity.NewRecord();
        }
        typeEntity.Name = def.name;
        typeEntity.Code = def.code;
        typeEntity.Description = def.description;
        if (def.onCreateActionID) typeEntity.OnCreateActionID = def.onCreateActionID;
        if (def.onStatusChangeActionID) typeEntity.OnStatusChangeActionID = def.onStatusChangeActionID;
        await RequireSave(typeEntity, `task type ${def.name}`);

        const typeInfo = {
            ID: typeEntity.ID,
            Name: typeEntity.Name,
            Code: typeEntity.Code,
            OnCreateActionID: typeEntity.OnCreateActionID,
            OnStatusChangeActionID: typeEntity.OnStatusChangeActionID,
        };
        TaskTypes[def.name] = typeInfo;
        TaskTypes[def.code] = typeInfo;
    }

    const Roles: WorldState['Roles'] = {};
    for (const row of roleRows) Roles[row.Name] = row;
    const DecisionOutcomes: WorldState['DecisionOutcomes'] = {};
    for (const row of outcomeRows) DecisionOutcomes[row.Name] = row;

    // 4. Seed Dynamic TaskTypeStatus Records across all relevant Task Types
    const TaskTypeStatuses: WorldState['TaskTypeStatuses'] = {};
    const statusDefs: Array<{
        taskTypeCode: string;
        name: string;
        code: string;
        description: string;
        macroStatus: mjBizAppsTasksTaskTypeStatusEntity['MacroStatus'];
        sequence: number;
        isDefault: boolean;
        isTerminal: boolean;
        color?: string;
        iconClass?: string;
        onEnterActionID?: string | null;
        onExitActionID?: string | null;
    }> = [
        // DELIVERABLE
        { taskTypeCode: 'DELIVERABLE', name: 'Draft', code: 'DRAFT', description: 'Initial draft in progress', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#6c757d', iconClass: 'fa fa-pencil' },
        { taskTypeCode: 'DELIVERABLE', name: 'In Review', code: 'IN_REVIEW', description: 'Under formal stakeholder review', macroStatus: 'InProgress', sequence: 200, isDefault: false, isTerminal: false, color: '#0d6efd', iconClass: 'fa fa-eye', onEnterActionID: calcAction?.ID ?? null },
        { taskTypeCode: 'DELIVERABLE', name: 'Approved', code: 'APPROVED', description: 'Deliverable approved and finalized', macroStatus: 'Completed', sequence: 300, isDefault: false, isTerminal: true, color: '#198754', iconClass: 'fa fa-check-circle', onEnterActionID: calcAction?.ID ?? null },

        // APPROVAL_REQUEST
        { taskTypeCode: 'APPROVAL_REQUEST', name: 'Submitted', code: 'SUBMITTED', description: 'Awaiting initial triage', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#ffc107', iconClass: 'fa fa-paper-plane' },
        { taskTypeCode: 'APPROVAL_REQUEST', name: 'Under Review', code: 'UNDER_REVIEW', description: 'Being evaluated by designated approvers', macroStatus: 'InProgress', sequence: 200, isDefault: false, isTerminal: false, color: '#0dcaf0', iconClass: 'fa fa-search' },
        { taskTypeCode: 'APPROVAL_REQUEST', name: 'Approved', code: 'APPROVED', description: 'All sign-offs completed', macroStatus: 'Completed', sequence: 300, isDefault: false, isTerminal: true, color: '#198754', iconClass: 'fa fa-check', onEnterActionID: calcAction?.ID ?? null },
        { taskTypeCode: 'APPROVAL_REQUEST', name: 'Rejected', code: 'REJECTED', description: 'Request declined or returned for rework', macroStatus: 'Cancelled', sequence: 400, isDefault: false, isTerminal: true, color: '#dc3545', iconClass: 'fa fa-times' },

        // ACTION_ITEM
        { taskTypeCode: 'ACTION_ITEM', name: 'To Do', code: 'TODO', description: 'Queued action item', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#6c757d' },
        { taskTypeCode: 'ACTION_ITEM', name: 'In Progress', code: 'IN_PROGRESS', description: 'Active work in progress', macroStatus: 'InProgress', sequence: 200, isDefault: false, isTerminal: false, color: '#0d6efd' },
        { taskTypeCode: 'ACTION_ITEM', name: 'Done', code: 'DONE', description: 'Action item completed', macroStatus: 'Completed', sequence: 300, isDefault: false, isTerminal: true, color: '#198754', onEnterActionID: calcAction?.ID ?? null },

        // GENERAL
        { taskTypeCode: 'GENERAL', name: 'Open', code: 'OPEN', description: 'Standard open task', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#6c757d' },
        { taskTypeCode: 'GENERAL', name: 'In Progress', code: 'IN_PROGRESS', description: 'Active general task', macroStatus: 'InProgress', sequence: 200, isDefault: false, isTerminal: false, color: '#0d6efd' },
        { taskTypeCode: 'GENERAL', name: 'Blocked', code: 'BLOCKED', description: 'Blocked by external dependency', macroStatus: 'Blocked', sequence: 300, isDefault: false, isTerminal: false, color: '#dc3545' },
        { taskTypeCode: 'GENERAL', name: 'Completed', code: 'COMPLETED', description: 'Task finished successfully', macroStatus: 'Completed', sequence: 400, isDefault: false, isTerminal: true, color: '#198754' },
        { taskTypeCode: 'GENERAL', name: 'Cancelled', code: 'CANCELLED', description: 'Task aborted', macroStatus: 'Cancelled', sequence: 500, isDefault: false, isTerminal: true, color: '#6c757d' },

        // CONSTRUCTION_MILESTONE
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Planning & Engineering', code: 'PLANNING', description: 'Civil blueprints and structural calculations', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#6c757d' },
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Permit Filed', code: 'PERMITTING', description: 'Submitted for city/county municipal permits', macroStatus: 'Open', sequence: 200, isDefault: false, isTerminal: false, color: '#fd7e14' },
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Active Construction', code: 'UNDER_CONSTRUCTION', description: 'Trade contractors actively executing on-site', macroStatus: 'InProgress', sequence: 300, isDefault: false, isTerminal: false, color: '#0d6efd' },
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Inspection Pending', code: 'INSPECTION_PENDING', description: 'Site ready for building inspector sign-off', macroStatus: 'InProgress', sequence: 400, isDefault: false, isTerminal: false, color: '#ffc107' },
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Inspection Passed', code: 'INSPECTION_PASSED', description: 'Inspector signed off; work accepted', macroStatus: 'Completed', sequence: 500, isDefault: false, isTerminal: true, color: '#198754', onEnterActionID: calcAction?.ID ?? null },
        { taskTypeCode: 'CONSTRUCTION_MILESTONE', name: 'Inspection Failed', code: 'FAILED_INSPECTION', description: 'Deficiencies found; remediation required', macroStatus: 'Blocked', sequence: 600, isDefault: false, isTerminal: false, color: '#dc3545' },

        // MEDIA_PRODUCTION
        { taskTypeCode: 'MEDIA_PRODUCTION', name: 'Pre-Production & Scripting', code: 'PRE_PRODUCTION', description: 'Story treatment, archival research, and shooting script', macroStatus: 'Open', sequence: 100, isDefault: true, isTerminal: false, color: '#6f42c1' },
        { taskTypeCode: 'MEDIA_PRODUCTION', name: 'Principal Photography', code: 'PRINCIPAL_PHOTOGRAPHY', description: 'Shooting interviews, b-roll, and historical artifacts', macroStatus: 'InProgress', sequence: 200, isDefault: false, isTerminal: false, color: '#0d6efd' },
        { taskTypeCode: 'MEDIA_PRODUCTION', name: 'Rough Cut Assembly', code: 'ROUGH_CUT', description: 'Initial timeline assembly and director cut', macroStatus: 'InProgress', sequence: 300, isDefault: false, isTerminal: false, color: '#fd7e14' },
        { taskTypeCode: 'MEDIA_PRODUCTION', name: 'Color & Sound Mastering', code: 'COLOR_AND_SOUND', description: 'Color grading, Dolby Atmos audio mix, and sound design', macroStatus: 'InProgress', sequence: 400, isDefault: false, isTerminal: false, color: '#20c997', onEnterActionID: colorAction?.ID ?? null },
        { taskTypeCode: 'MEDIA_PRODUCTION', name: 'Released & Broadcast', code: 'RELEASED', description: 'Final master distributed and publicly screened', macroStatus: 'Completed', sequence: 500, isDefault: false, isTerminal: true, color: '#198754', onEnterActionID: colorAction?.ID ?? null },
    ];

    for (const def of statusDefs) {
        const typeInfo = TaskTypes[def.taskTypeCode];
        if (!typeInfo) continue;

        const existingID = await FindId(
            ctx,
            TASK_TYPE_STATUS_ENTITY,
            `TaskTypeID = '${typeInfo.ID}' AND Code = '${Quote(def.code)}'`
        );
        const statusEntity = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTypeStatusEntity>(
            TASK_TYPE_STATUS_ENTITY,
            ctx.User
        );
        if (existingID) {
            await statusEntity.Load(existingID);
        } else {
            statusEntity.NewRecord();
        }
        statusEntity.TaskTypeID = typeInfo.ID;
        statusEntity.Name = def.name;
        statusEntity.Code = def.code;
        statusEntity.Description = def.description;
        statusEntity.MacroStatus = def.macroStatus;
        statusEntity.Sequence = def.sequence;
        statusEntity.IsDefault = def.isDefault;
        statusEntity.IsTerminal = def.isTerminal;
        statusEntity.Color = def.color ?? null;
        statusEntity.IconClass = def.iconClass ?? null;
        statusEntity.OnEnterActionID = def.onEnterActionID ?? null;
        statusEntity.OnExitActionID = def.onExitActionID ?? null;
        statusEntity.IsActive = true;
        await RequireSave(statusEntity, `status ${def.taskTypeCode}.${def.code}`);

        const key = `${def.taskTypeCode}.${def.code}`;
        TaskTypeStatuses[key] = {
            ID: statusEntity.ID,
            TaskTypeID: typeInfo.ID,
            Name: statusEntity.Name,
            Code: statusEntity.Code,
            MacroStatus: statusEntity.MacroStatus,
            Sequence: statusEntity.Sequence,
            IsDefault: statusEntity.IsDefault,
            IsTerminal: statusEntity.IsTerminal,
            OnEnterActionID: statusEntity.OnEnterActionID,
            OnExitActionID: statusEntity.OnExitActionID,
        };
    }

    // 4b. Seed 2 Canonical Organizations (Apex Cloud Systems internal mirrored company + Acme Enterprise Corp external client)
    const Organizations: WorldState['Organizations'] = {};
    const apexCompanyID = await upsertCompany(ctx, APEX_ORG_NAME, 'Internal operating company for Task World & CoS scenarios');
    const apexOrg = await upsertOrganization(ctx, {
        Name: APEX_ORG_NAME,
        Description: 'Internal operating company (Apex Cloud Systems) mirrored from MJ: Companies.',
        LinkedCompanyID: apexCompanyID,
    });
    const acmeOrg = await upsertOrganization(ctx, {
        Name: ACME_ORG_NAME,
        Description: 'External strategic enterprise client organization.',
        LinkedCompanyID: null,
    });
    Organizations[APEX_ORG_NAME] = apexOrg;
    Organizations[ACME_ORG_NAME] = acmeOrg;

    // 5. Build Rich Multi-Domain Category Hierarchy
    const Categories: WorldState['Categories'] = {};
    const categoryTreeDefs: Array<{
        name: string;
        description?: string;
        parentName?: string;
        organizationID?: string | null;
    }> = [
        // --- Domain 1: Software & Product Development ---
        { name: 'Engineering & Development', description: 'Core software engineering and technical product development', organizationID: apexOrg.ID },
        { name: 'Product & Design', description: 'Product strategy, UX/UI design, and product specifications', organizationID: apexOrg.ID },
        { name: 'Operations & Legal', description: 'Business operations, legal compliance, and facilities', organizationID: apexOrg.ID },

        { name: 'Core Platform & API', description: 'Platform infrastructure, database schemas, and API services', parentName: 'Engineering & Development', organizationID: apexOrg.ID },
        { name: 'Frontend Applications', description: 'Web UI apps, design systems, and client libraries', parentName: 'Engineering & Development', organizationID: apexOrg.ID },
        { name: 'DevOps & Quality Engineering', description: 'CI/CD pipelines, automated testing, and cloud infrastructure', parentName: 'Engineering & Development', organizationID: apexOrg.ID },
        { name: 'User Experience & Research', description: 'User interviews, usability testing, and wireframes', parentName: 'Product & Design', organizationID: apexOrg.ID },
        { name: 'Design Systems & Tokens', description: 'Color palettes, typography, and UI iconography', parentName: 'Product & Design', organizationID: apexOrg.ID },
        { name: 'Information Security & Compliance', description: 'SOC2 audits, penetration testing, and security policy reviews', parentName: 'Operations & Legal', organizationID: apexOrg.ID },
        { name: 'Finance & Accounting Operations', description: 'Budget tracking, invoicing, and contract reviews', parentName: 'Operations & Legal', organizationID: apexOrg.ID },
        { name: 'Client Delivery — Acme Enterprise', description: 'Dedicated enterprise client delivery workstreams for Acme Enterprise Corp', organizationID: acmeOrg.ID },

        { name: 'Database & Migrations', description: 'SQL DDL migrations, views, and data seeding', parentName: 'Core Platform & API' },
        { name: 'GraphQL Services', description: 'Resolvers, schema generation, and query pipeline', parentName: 'Core Platform & API' },
        { name: 'Explorer Shell', description: 'Resource tabs, navigation rails, and core layouts', parentName: 'Frontend Applications' },
        { name: 'Shared Component Library', description: 'Angular UI components, directives, and forms', parentName: 'Frontend Applications' },

        // --- Domain 2: Corporate Real Estate & Construction ---
        { name: 'Corporate Real Estate & Facilities', description: 'Corporate facilities planning, architecture, construction, and lease acquisitions' },
        { name: 'Architecture & Civil Engineering', description: 'Structural designs, blueprints, and seismic/civil calculations', parentName: 'Corporate Real Estate & Facilities' },
        { name: 'General Contracting & Construction', description: 'Site prep, earthwork, structural steel, and MEP building trades', parentName: 'Corporate Real Estate & Facilities' },
        { name: 'Permitting & Municipal Inspections', description: 'Zoning approvals, environmental reviews, and code compliance certifications', parentName: 'Corporate Real Estate & Facilities' },
        { name: 'Interior Architecture & Workplace Design', description: 'Office space planning, acoustics, lighting, and employee ergonomic layout', parentName: 'Corporate Real Estate & Facilities' },

        // --- Domain 3: Media, Film & Creative Production ---
        { name: 'Media & Creative Production', description: 'Film, cinematography, sound design, and brand storytelling' },
        { name: 'Historical Archives & Rights Research', description: 'Oral histories, company archive curation, and IP rights licensing', parentName: 'Media & Creative Production' },
        { name: 'Principal Photography & Sound', description: '4K cinematography, multi-camera interviews, on-location audio recording', parentName: 'Media & Creative Production' },
        { name: 'Post-Production, VFX & Color', description: 'Film editing, visual effects, Dolby Vision color mastering, and scoring', parentName: 'Media & Creative Production' },
        { name: 'Distribution & Premiere Broadcast', description: 'Festival submissions, company-wide screening townhalls, and PR media rollout', parentName: 'Media & Creative Production' },
    ];

    for (const def of categoryTreeDefs) {
        const existing = await FindId(ctx, TASK_CATEGORY_ENTITY, `Name = '${Quote(def.name)}'`);
        const cat = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCategoryEntity>(TASK_CATEGORY_ENTITY, ctx.User);
        if (existing) {
            await cat.Load(existing);
        } else {
            cat.NewRecord();
        }
        cat.Name = def.name;
        cat.Description = def.description ?? null;
        cat.ParentID = def.parentName && Categories[def.parentName] ? Categories[def.parentName].ID : null;
        if (def.organizationID !== undefined) {
            cat.OrganizationID = def.organizationID;
        }
        cat.IsActive = true;
        await RequireSave(cat, `category ${def.name}`);
        Categories[def.name] = { ID: cat.ID, Name: def.name };
    }

    // 6. People Across Multiple Operational Roles
    const People: WorldState['People'] = {};
    const peopleDefs = [
        { Email: `sarah.connor@${WORLD_DOMAIN}`, First: 'Sarah', Last: 'Connor' },
        { Email: `alex.chen@${WORLD_DOMAIN}`, First: 'Alex', Last: 'Chen' },
        { Email: `marcus.vance@${WORLD_DOMAIN}`, First: 'Marcus', Last: 'Vance' },
        { Email: `elena.rostova@${WORLD_DOMAIN}`, First: 'Elena', Last: 'Rostova' },
        { Email: `david.miller@${WORLD_DOMAIN}`, First: 'David', Last: 'Miller' },
        { Email: `robert.hayes@${WORLD_DOMAIN}`, First: 'Robert', Last: 'Hayes' },
        { Email: `maya.lin@${WORLD_DOMAIN}`, First: 'Maya', Last: 'Lin' },
        { Email: `claire.bennett@${WORLD_DOMAIN}`, First: 'Claire', Last: 'Bennett' },
    ];
    for (const def of peopleDefs) {
        const existing = await FindId(ctx, PERSON_ENTITY, `Email = '${Quote(def.Email)}'`);
        const person = await ctx.Provider.GetEntityObject<mjBizAppsCommonPersonEntity>(PERSON_ENTITY, ctx.User);
        if (existing) {
            await person.Load(existing);
        } else {
            person.NewRecord();
        }
        person.FirstName = def.First;
        person.LastName = def.Last;
        person.Email = def.Email;
        person.Status = 'Active';
        await RequireSave(person, `person ${def.Email}`);
        People[def.Email] = { ID: person.ID, Email: def.Email, FirstName: def.First, LastName: def.Last };
    }

    // 7. Seed 3 Divergent Real-World Projects with Comprehensive Hierarchies & Statuses
    const generalType = TaskTypes['GENERAL'] ?? TaskTypes['General'];
    const deliverableType = TaskTypes['DELIVERABLE'] ?? TaskTypes['Deliverable'] ?? generalType;
    const approvalType = TaskTypes['APPROVAL_REQUEST'] ?? TaskTypes['Approval Request'] ?? generalType;
    const actionItemType = TaskTypes['ACTION_ITEM'] ?? TaskTypes['Action Item'] ?? generalType;
    const constructionType = TaskTypes['CONSTRUCTION_MILESTONE'] ?? TaskTypes['Construction Milestone'] ?? generalType;
    const mediaType = TaskTypes['MEDIA_PRODUCTION'] ?? TaskTypes['Media Production Stage'] ?? generalType;

    const SeedTaskIDs: Record<string, string> = {};

    // -------------------------------------------------------------------------
    // Project 1: Software & Platform Launch
    // -------------------------------------------------------------------------
    const engCategory = Categories['Engineering & Development'];
    const p1RootID = await upsertTask(ctx, {
        Name: 'Website Redesign & Portal Launch',
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.IN_REVIEW']?.ID,
        CategoryID: engCategory.ID,
        OrganizationID: apexOrg.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 40,
    });
    SeedTaskIDs['Website Redesign & Portal Launch'] = p1RootID;

    SeedTaskIDs['GraphQL API Resolvers'] = await upsertTask(ctx, {
        Name: 'GraphQL API Resolvers',
        ParentID: p1RootID,
        TypeID: generalType.ID,
        TaskTypeStatusID: TaskTypeStatuses['GENERAL.IN_PROGRESS']?.ID,
        CategoryID: Categories['GraphQL Services']?.ID ?? engCategory.ID,
        OrganizationID: apexOrg.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 70,
    });

    SeedTaskIDs['Angular Explorer Shell Dashboard'] = await upsertTask(ctx, {
        Name: 'Angular Explorer Shell Dashboard',
        ParentID: p1RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.IN_REVIEW']?.ID,
        CategoryID: Categories['Explorer Shell']?.ID ?? engCategory.ID,
        OrganizationID: apexOrg.ID,
        Status: 'InProgress',
        Priority: 'Medium',
        PercentComplete: 40,
    });

    SeedTaskIDs['Security Review'] = await upsertTask(ctx, {
        Name: 'Security Review',
        ParentID: p1RootID,
        TypeID: approvalType.ID,
        TaskTypeStatusID: TaskTypeStatuses['APPROVAL_REQUEST.SUBMITTED']?.ID,
        CategoryID: Categories['Information Security & Compliance']?.ID ?? Categories['Operations & Legal'].ID,
        OrganizationID: apexOrg.ID,
        Status: 'Open',
        Priority: 'Critical',
        PercentComplete: 0,
    });

    SeedTaskIDs['Production CI/CD Deploy'] = await upsertTask(ctx, {
        Name: 'Production CI/CD Deploy',
        ParentID: p1RootID,
        TypeID: actionItemType.ID,
        TaskTypeStatusID: TaskTypeStatuses['ACTION_ITEM.TODO']?.ID,
        CategoryID: Categories['DevOps & Quality Engineering']?.ID ?? engCategory.ID,
        OrganizationID: apexOrg.ID,
        Status: 'Open',
        Priority: 'High',
        PercentComplete: 0,
    });

    // -------------------------------------------------------------------------
    // Project 2: Corporate Headquarters Construction & Relocation
    // -------------------------------------------------------------------------
    const realEstateCat = Categories['Corporate Real Estate & Facilities'];
    const p2RootID = await upsertTask(ctx, {
        Name: 'Corporate HQ Campus Construction & Relocation',
        TypeID: constructionType.ID,
        TaskTypeStatusID: TaskTypeStatuses['CONSTRUCTION_MILESTONE.UNDER_CONSTRUCTION']?.ID,
        CategoryID: realEstateCat.ID,
        OrganizationID: apexOrg.ID,
        Status: 'InProgress',
        Priority: 'Critical',
        PercentComplete: 45,
    });
    SeedTaskIDs['Corporate HQ Campus Construction & Relocation'] = p2RootID;

    SeedTaskIDs['Architectural Blueprints & Structural Engineering'] = await upsertTask(ctx, {
        Name: 'Architectural Blueprints & Structural Engineering',
        ParentID: p2RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.APPROVED']?.ID,
        CategoryID: Categories['Architecture & Civil Engineering']?.ID ?? realEstateCat.ID,
        Status: 'Completed',
        Priority: 'High',
        PercentComplete: 100,
    });

    SeedTaskIDs['Municipal Zoning Variance & Building Permits'] = await upsertTask(ctx, {
        Name: 'Municipal Zoning Variance & Building Permits',
        ParentID: p2RootID,
        TypeID: approvalType.ID,
        TaskTypeStatusID: TaskTypeStatuses['APPROVAL_REQUEST.APPROVED']?.ID,
        CategoryID: Categories['Permitting & Municipal Inspections']?.ID ?? realEstateCat.ID,
        Status: 'Completed',
        Priority: 'Critical',
        PercentComplete: 100,
    });

    SeedTaskIDs['Site Excavation & Deep Foundation Concrete Pour'] = await upsertTask(ctx, {
        Name: 'Site Excavation & Deep Foundation Concrete Pour',
        ParentID: p2RootID,
        TypeID: constructionType.ID,
        TaskTypeStatusID: TaskTypeStatuses['CONSTRUCTION_MILESTONE.INSPECTION_PASSED']?.ID,
        CategoryID: Categories['General Contracting & Construction']?.ID ?? realEstateCat.ID,
        Status: 'Completed',
        Priority: 'High',
        PercentComplete: 100,
    });

    SeedTaskIDs['Structural Steel Erection & Building Envelope'] = await upsertTask(ctx, {
        Name: 'Structural Steel Erection & Building Envelope',
        ParentID: p2RootID,
        TypeID: constructionType.ID,
        TaskTypeStatusID: TaskTypeStatuses['CONSTRUCTION_MILESTONE.UNDER_CONSTRUCTION']?.ID,
        CategoryID: Categories['General Contracting & Construction']?.ID ?? realEstateCat.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 60,
    });

    SeedTaskIDs['MEP Rough-in (Mechanical, Electrical, Plumbing)'] = await upsertTask(ctx, {
        Name: 'MEP Rough-in (Mechanical, Electrical, Plumbing)',
        ParentID: p2RootID,
        TypeID: constructionType.ID,
        TaskTypeStatusID: TaskTypeStatuses['CONSTRUCTION_MILESTONE.UNDER_CONSTRUCTION']?.ID,
        CategoryID: Categories['General Contracting & Construction']?.ID ?? realEstateCat.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 20,
    });

    SeedTaskIDs['Workplace Smart-Office Interior Fit-out'] = await upsertTask(ctx, {
        Name: 'Workplace Smart-Office Interior Fit-out',
        ParentID: p2RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.DRAFT']?.ID,
        CategoryID: Categories['Interior Architecture & Workplace Design']?.ID ?? realEstateCat.ID,
        Status: 'Open',
        Priority: 'Medium',
        PercentComplete: 0,
    });

    SeedTaskIDs['Final Fire, Life Safety & Certificate of Occupancy'] = await upsertTask(ctx, {
        Name: 'Final Fire, Life Safety & Certificate of Occupancy',
        ParentID: p2RootID,
        TypeID: approvalType.ID,
        TaskTypeStatusID: TaskTypeStatuses['APPROVAL_REQUEST.SUBMITTED']?.ID,
        CategoryID: Categories['Permitting & Municipal Inspections']?.ID ?? realEstateCat.ID,
        Status: 'Open',
        Priority: 'Critical',
        PercentComplete: 0,
    });

    // -------------------------------------------------------------------------
    // Project 3: 50-Year Company Heritage Documentary Film
    // -------------------------------------------------------------------------
    const mediaCat = Categories['Media & Creative Production'];
    const p3RootID = await upsertTask(ctx, {
        Name: '50-Year Company Heritage Documentary Film',
        TypeID: mediaType.ID,
        TaskTypeStatusID: TaskTypeStatuses['MEDIA_PRODUCTION.ROUGH_CUT']?.ID,
        CategoryID: mediaCat.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 50,
    });
    SeedTaskIDs['50-Year Company Heritage Documentary Film'] = p3RootID;

    SeedTaskIDs['Historical Archival Research & Rights Clearances'] = await upsertTask(ctx, {
        Name: 'Historical Archival Research & Rights Clearances',
        ParentID: p3RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.APPROVED']?.ID,
        CategoryID: Categories['Historical Archives & Rights Research']?.ID ?? mediaCat.ID,
        Status: 'Completed',
        Priority: 'Medium',
        PercentComplete: 100,
    });

    SeedTaskIDs['Founder & Early Pioneer 4K On-Camera Interviews'] = await upsertTask(ctx, {
        Name: 'Founder & Early Pioneer 4K On-Camera Interviews',
        ParentID: p3RootID,
        TypeID: mediaType.ID,
        TaskTypeStatusID: TaskTypeStatuses['MEDIA_PRODUCTION.PRINCIPAL_PHOTOGRAPHY']?.ID,
        CategoryID: Categories['Principal Photography & Sound']?.ID ?? mediaCat.ID,
        Status: 'Completed',
        Priority: 'High',
        PercentComplete: 100,
    });

    SeedTaskIDs['Assembly Edit & Storyline Rough Cut'] = await upsertTask(ctx, {
        Name: 'Assembly Edit & Storyline Rough Cut',
        ParentID: p3RootID,
        TypeID: mediaType.ID,
        TaskTypeStatusID: TaskTypeStatuses['MEDIA_PRODUCTION.ROUGH_CUT']?.ID,
        CategoryID: Categories['Post-Production, VFX & Color']?.ID ?? mediaCat.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 75,
    });

    SeedTaskIDs['Original Cinematic Score Recording & Sound Mix'] = await upsertTask(ctx, {
        Name: 'Original Cinematic Score Recording & Sound Mix',
        ParentID: p3RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.IN_REVIEW']?.ID,
        CategoryID: Categories['Principal Photography & Sound']?.ID ?? mediaCat.ID,
        Status: 'InProgress',
        Priority: 'Medium',
        PercentComplete: 30,
    });

    SeedTaskIDs['Master Color Grading & Dolby Vision 4K HDR Export'] = await upsertTask(ctx, {
        Name: 'Master Color Grading & Dolby Vision 4K HDR Export',
        ParentID: p3RootID,
        TypeID: mediaType.ID,
        TaskTypeStatusID: TaskTypeStatuses['MEDIA_PRODUCTION.PRE_PRODUCTION']?.ID,
        CategoryID: Categories['Post-Production, VFX & Color']?.ID ?? mediaCat.ID,
        Status: 'Open',
        Priority: 'High',
        PercentComplete: 0,
    });

    SeedTaskIDs['Global Employee Townhall Premiere & Stream Broadcast'] = await upsertTask(ctx, {
        Name: 'Global Employee Townhall Premiere & Stream Broadcast',
        ParentID: p3RootID,
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.DRAFT']?.ID,
        CategoryID: Categories['Distribution & Premiere Broadcast']?.ID ?? mediaCat.ID,
        OrganizationID: apexOrg.ID,
        Status: 'Open',
        Priority: 'High',
        PercentComplete: 0,
    });

    // -------------------------------------------------------------------------
    // 8. Persistent CoS Sample Data: Acme Enterprise Client Tasks, Monthly Close
    //    Playbook Template, Submitted 15Five Work Report, Completed Meeting w/ WebVTT
    // -------------------------------------------------------------------------
    const sarah = People[`sarah.connor@${WORLD_DOMAIN}`];
    const alex = People[`alex.chen@${WORLD_DOMAIN}`];
    const acmeCat = Categories['Client Delivery — Acme Enterprise'];
    const financeCat = Categories['Finance & Accounting Operations'];
    const primaryRole = Roles['Primary'] ?? Object.values(Roles)[0];

    const nowMs = Date.now();
    const inOneDay = new Date(nowMs + 1 * 24 * 60 * 60 * 1000);
    const inThreeDays = new Date(nowMs + 3 * 24 * 60 * 60 * 1000);

    SeedTaskIDs['Acme Q4 Enterprise Renewal Review'] = await upsertTask(ctx, {
        Name: 'Acme Q4 Enterprise Renewal Review',
        TypeID: deliverableType.ID,
        TaskTypeStatusID: TaskTypeStatuses['DELIVERABLE.IN_REVIEW']?.ID,
        CategoryID: acmeCat.ID,
        OrganizationID: acmeOrg.ID,
        CreatedByPersonID: sarah.ID,
        DueAt: inThreeDays,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 35,
        Description: 'Review Q4 enterprise renewal terms, usage metrics, and SLA addendum with Acme Enterprise Corp.',
    });

    SeedTaskIDs['Acme Security Compliance Sign-Off'] = await upsertTask(ctx, {
        Name: 'Acme Security Compliance Sign-Off',
        TypeID: approvalType.ID,
        TaskTypeStatusID: TaskTypeStatuses['APPROVAL_REQUEST.SUBMITTED']?.ID,
        CategoryID: acmeCat.ID,
        OrganizationID: acmeOrg.ID,
        CreatedByPersonID: sarah.ID,
        DueAt: inOneDay,
        Status: 'Open',
        Priority: 'Critical',
        PercentComplete: 0,
        Description: 'Complete SOC2 Type II questionnaire and executive security sign-off for Acme Enterprise Corp.',
    });

    await ensurePersonTaskAssignment(ctx, SeedTaskIDs['Acme Q4 Enterprise Renewal Review'], sarah.ID, primaryRole?.ID ?? null);
    await ensurePersonTaskAssignment(ctx, SeedTaskIDs['Acme Security Compliance Sign-Off'], sarah.ID, primaryRole?.ID ?? null);

    // 8b. Seed Monthly Financial Close TaskTemplate + 3 relative-due Template Items
    const closeTemplateID = await upsertCloseTemplate(ctx, {
        OrganizationID: apexOrg.ID,
        CategoryID: financeCat.ID,
        TypeID: deliverableType.ID,
    });

    // 8c. Ensure Sarah -> Alex employee reporting line and seed submitted 15Five Weekly Work Report
    await ensureEmployeeHierarchy(ctx, apexCompanyID, alex, sarah);
    const workReportID = await upsertSeededWorkReport(ctx, {
        AuthorPersonID: sarah.ID,
        WinTaskID: SeedTaskIDs['GraphQL API Resolvers'],
        ChallengeTaskID: SeedTaskIDs['Security Review'],
        NextTaskID: SeedTaskIDs['Production CI/CD Deploy'],
    });

    // 8d. Seed completed Meeting ('Q4 Executive Alignment Sync') with WebVTT transcript + notes
    const transcriptMeetingID = await upsertTranscriptMeeting(ctx, {
        OrganizerPersonID: alex.ID,
        AttendeePersonID: sarah.ID,
        AttendeeEmail: sarah.Email,
        AttendeeName: `${sarah.FirstName} ${sarah.LastName}`,
    });

    const world: WorldState = {
        Categories,
        Organizations,
        Roles,
        DecisionOutcomes,
        TaskTypes,
        TaskTypeStatuses,
        Actions,
        People,
        SeedTaskIDs,
        CloseTemplateID: closeTemplateID,
        WorkReportID: workReportID,
        TranscriptMeetingID: transcriptMeetingID,
    };
    SetWorld(world);
    return world;
}

export async function GetOrLoadWorld(ctx: IntegrationCheckContext): Promise<WorldState> {
    return GetWorld() ?? LoadWorld(ctx);
}

async function upsertCompany(
    ctx: IntegrationCheckContext,
    name: string,
    description: string,
): Promise<string | null> {
    const provider = ctx.Provider as IMetadataProvider;
    if (!provider.EntityByName(COMPANY_ENTITY)) {
        return null;
    }
    const existing = await FindId(ctx, COMPANY_ENTITY, `Name = '${Quote(name)}'`);
    if (existing) return existing;
    const company = await ctx.Provider.GetEntityObject<MJCompanyEntity>(COMPANY_ENTITY, ctx.User);
    company.NewRecord();
    company.Name = name;
    company.Description = description;
    await RequireSave(company, `company ${name}`);
    return company.ID;
}

async function upsertOrganization(
    ctx: IntegrationCheckContext,
    def: { Name: string; Description: string; LinkedCompanyID: string | null },
): Promise<{ ID: string; Name: string }> {
    const filter = def.LinkedCompanyID
        ? `Name = '${Quote(def.Name)}' OR LinkedCompanyID = '${Quote(def.LinkedCompanyID)}'`
        : `Name = '${Quote(def.Name)}'`;
    const existing = await FindId(ctx, ORGANIZATION_ENTITY, filter);
    const org = await ctx.Provider.GetEntityObject<mjBizAppsCommonOrganizationEntity>(ORGANIZATION_ENTITY, ctx.User);
    if (existing) {
        await org.Load(existing);
    } else {
        org.NewRecord();
    }
    org.Name = def.Name;
    org.Description = def.Description;
    org.Status = 'Active';
    if (def.LinkedCompanyID && !org.LinkedCompanyID) {
        org.LinkedCompanyID = def.LinkedCompanyID;
    }
    await RequireSave(org, `organization ${def.Name}`);
    return { ID: org.ID, Name: org.Name };
}

async function ensurePersonTaskAssignment(
    ctx: IntegrationCheckContext,
    taskID: string,
    personID: string,
    roleID: string | null,
): Promise<void> {
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.EntityByName(PERSON_ENTITY);
    if (!peopleEntity) return;
    const existing = await FindId(
        ctx,
        TASK_ASSIGNMENT_ENTITY,
        `TaskID = '${Quote(taskID)}' AND AssigneeEntityID = '${Quote(peopleEntity.ID)}' AND AssigneeRecordID = '${Quote(personID)}'`,
    );
    if (existing) return;
    const assign = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY, ctx.User);
    assign.NewRecord();
    assign.TaskID = taskID;
    assign.AssigneeEntityID = peopleEntity.ID;
    assign.AssigneeRecordID = personID;
    if (roleID) assign.RoleID = roleID;
    await RequireSave(assign, `assign ${personID} to task ${taskID}`);
}

async function upsertCloseTemplate(
    ctx: IntegrationCheckContext,
    def: { OrganizationID: string; CategoryID: string; TypeID: string },
): Promise<string> {
    const existing = await FindId(ctx, TASK_TEMPLATE_ENTITY, `Name = '${Quote(CLOSE_TEMPLATE_NAME)}'`);
    const tpl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
    if (existing) {
        await tpl.Load(existing);
    } else {
        tpl.NewRecord();
    }
    tpl.Name = CLOSE_TEMPLATE_NAME;
    tpl.Description = 'Reusable multi-step month-end close playbook covering sub-ledger reconciliation, accruals, and executive close package.';
    tpl.OrganizationID = def.OrganizationID;
    tpl.CategoryID = def.CategoryID;
    tpl.TypeID = def.TypeID;
    tpl.IsActive = true;
    await RequireSave(tpl, `task template ${CLOSE_TEMPLATE_NAME}`);

    const itemDefs: Array<{
        Name: string;
        Description: string;
        Priority: mjBizAppsTasksTaskTemplateItemEntity['Priority'];
        DaysFromStart: number;
        HoursEstimated: number;
        Sequence: number;
    }> = [
        {
            Name: 'Close Sub-Ledger & Reconcile Bank Accounts',
            Description: 'Reconcile cash, AR, AP, and credit card clearing accounts to bank statements.',
            Priority: 'High',
            DaysFromStart: 1,
            HoursEstimated: 4,
            Sequence: 10,
        },
        {
            Name: 'Review Accruals, Deferred Revenue & Intercompany Eliminations',
            Description: 'Post monthly accrual entries, deferred revenue schedules, and intercompany eliminations.',
            Priority: 'High',
            DaysFromStart: 3,
            HoursEstimated: 3,
            Sequence: 20,
        },
        {
            Name: 'Publish Monthly Financial Close Package to Executive Leadership',
            Description: 'Deliver final P&L, balance sheet, variance notes, and cash forecast to leadership.',
            Priority: 'Critical',
            DaysFromStart: 5,
            HoursEstimated: 2,
            Sequence: 30,
        },
    ];

    for (const itemDef of itemDefs) {
        const existingItem = await FindId(
            ctx,
            TASK_TEMPLATE_ITEM_ENTITY,
            `TemplateID = '${Quote(tpl.ID)}' AND Name = '${Quote(itemDef.Name)}'`,
        );
        const item = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(
            TASK_TEMPLATE_ITEM_ENTITY,
            ctx.User,
        );
        if (existingItem) {
            await item.Load(existingItem);
        } else {
            item.NewRecord();
            item.TemplateID = tpl.ID;
        }
        item.Name = itemDef.Name;
        item.Description = itemDef.Description;
        item.Priority = itemDef.Priority;
        item.DaysFromStart = itemDef.DaysFromStart;
        item.HoursEstimated = itemDef.HoursEstimated;
        item.Sequence = itemDef.Sequence;
        await RequireSave(item, `template item ${itemDef.Name}`);
    }

    return tpl.ID;
}

async function ensureEmployeeHierarchy(
    ctx: IntegrationCheckContext,
    companyID: string | null,
    supervisor: { Email: string; FirstName: string; LastName: string },
    report: { Email: string; FirstName: string; LastName: string },
): Promise<void> {
    const provider = ctx.Provider as IMetadataProvider;
    if (!companyID || !provider.EntityByName(EMPLOYEE_ENTITY)) return;

    const supID = await upsertEmployee(ctx, {
        CompanyID: companyID,
        Email: supervisor.Email,
        FirstName: supervisor.FirstName,
        LastName: supervisor.LastName,
        Title: 'VP Engineering',
        SupervisorID: null,
    });
    await upsertEmployee(ctx, {
        CompanyID: companyID,
        Email: report.Email,
        FirstName: report.FirstName,
        LastName: report.LastName,
        Title: 'Principal Engineer',
        SupervisorID: supID,
    });
}

async function upsertEmployee(
    ctx: IntegrationCheckContext,
    def: {
        CompanyID: string;
        Email: string;
        FirstName: string;
        LastName: string;
        Title: string;
        SupervisorID: string | null;
    },
): Promise<string> {
    const existing = await FindId(ctx, EMPLOYEE_ENTITY, `Email = '${Quote(def.Email)}'`);
    const emp = await ctx.Provider.GetEntityObject<MJEmployeeEntity>(EMPLOYEE_ENTITY, ctx.User);
    if (existing) {
        await emp.Load(existing);
    } else {
        emp.NewRecord();
    }
    emp.FirstName = def.FirstName;
    emp.LastName = def.LastName;
    emp.Email = def.Email;
    emp.CompanyID = def.CompanyID;
    emp.Title = def.Title;
    emp.Active = true;
    if (def.SupervisorID && !UUIDsEqual(emp.SupervisorID, def.SupervisorID)) {
        emp.SupervisorID = def.SupervisorID;
    }
    await RequireSave(emp, `employee ${def.Email}`);
    return emp.ID;
}

async function upsertSeededWorkReport(
    ctx: IntegrationCheckContext,
    def: {
        AuthorPersonID: string;
        WinTaskID: string;
        ChallengeTaskID: string;
        NextTaskID: string;
    },
): Promise<string> {
    const periodStart = new Date('2026-11-02T00:00:00.000Z');
    const periodEnd = new Date('2026-11-06T00:00:00.000Z');

    const existing = await FindId(
        ctx,
        WORK_REPORT_ENTITY,
        `PersonID = '${Quote(def.AuthorPersonID)}' AND PeriodStart = '2026-11-02' AND PeriodEnd = '2026-11-06'`,
    );
    if (existing) {
        return existing;
    }

    const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
    report.NewRecord();
    report.PersonID = def.AuthorPersonID;
    report.PeriodStart = periodStart;
    report.PeriodEnd = periodEnd;
    report.Title = SEEDED_WORK_REPORT_TITLE;
    report.Body = [
        '### Wins',
        '- Shipped GraphQL API resolver optimizations reducing p95 latency by 35%.',
        '',
        '### Challenges & Blockers',
        '- Waiting on final SOC2 compliance sign-off for Acme Enterprise Corp.',
        '',
        '### Next Week Priorities',
        '- Complete Production CI/CD Deploy checklist and finalize Acme Q4 Enterprise Renewal Review.',
    ].join('\n');
    report.Status = 'Draft';
    await RequireSave(report, `work report draft ${SEEDED_WORK_REPORT_TITLE}`);

    const items: Array<{
        Section: mjBizAppsTasksWorkReportItemEntity['Section'];
        TaskID: string;
        Summary: string;
        Sequence: number;
    }> = [
        {
            Section: 'Completed',
            TaskID: def.WinTaskID,
            Summary: 'Win: Optimized GraphQL API resolvers and cut p95 query latency by 35%.',
            Sequence: 1,
        },
        {
            Section: 'Blockers',
            TaskID: def.ChallengeTaskID,
            Summary: 'Challenge: Awaiting Acme Enterprise Corp security compliance sign-off.',
            Sequence: 2,
        },
        {
            Section: 'Next',
            TaskID: def.NextTaskID,
            Summary: 'Next Week Priority: Finalize Production CI/CD Deploy and Acme Q4 renewal package.',
            Sequence: 3,
        },
    ];

    for (const itemDef of items) {
        const item = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(
            WORK_REPORT_ITEM_ENTITY,
            ctx.User,
        );
        item.NewRecord();
        item.WorkReportID = report.ID;
        item.TaskID = itemDef.TaskID;
        item.Section = itemDef.Section;
        item.Summary = itemDef.Summary;
        item.Sequence = itemDef.Sequence;
        await RequireSave(item, `work report item ${itemDef.Sequence}`);
    }

    report.Status = 'Submitted';
    await RequireSave(report, `submit work report ${SEEDED_WORK_REPORT_TITLE}`);
    return report.ID;
}

async function upsertTranscriptMeeting(
    ctx: IntegrationCheckContext,
    def: {
        OrganizerPersonID: string;
        AttendeePersonID: string;
        AttendeeEmail: string;
        AttendeeName: string;
    },
): Promise<string> {
    const existing = await FindId(ctx, MEETING_ENTITY, `Name = '${Quote(SEEDED_MEETING_NAME)}'`);
    let meetingID: string;

    if (existing) {
        meetingID = existing;
    } else {
        const startsAt = new Date(Date.now() - 2 * 60 * 60 * 1000);
        const endsAt = new Date(Date.now() - 1 * 60 * 60 * 1000);
        const vttTranscript = [
            'WEBVTT',
            '',
            '00:00:05.000 --> 00:00:18.000',
            '<v Alex Chen>Welcome everyone to the Q4 Executive Alignment Sync. Let us review Acme Enterprise Corp and our November close readiness.</v>',
            '',
            '00:00:19.000 --> 00:00:35.000',
            '<v Sarah Connor>DECISION: We will prioritize Acme Security Compliance Sign-Off ahead of the Q4 renewal signature deadline.</v>',
            '',
            '00:00:36.000 --> 00:00:52.000',
            '<v Alex Chen>ACTION: Sarah Connor will finalize the Acme Q4 Enterprise Renewal Review pricing addendum by Friday.</v>',
            '',
            '00:00:53.000 --> 00:01:08.000',
            '<v Sarah Connor>ACTION: Alex Chen will schedule the Monthly Financial Close dry-run review with Finance leadership.</v>',
        ].join('\n');

        const meeting = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
        meeting.NewRecord();
        meeting.Name = SEEDED_MEETING_NAME;
        meeting.Description = vttTranscript;
        meeting.OrganizerPersonID = def.OrganizerPersonID;
        meeting.StartsAt = startsAt;
        meeting.EndsAt = endsAt;
        meeting.TimeZone = 'America/Chicago';
        meeting.LocationType = 'Virtual';
        meeting.Visibility = 'Standard';
        meeting.Status = 'Scheduled';
        await RequireSave(meeting, `schedule meeting ${SEEDED_MEETING_NAME}`);

        // Add Sarah Connor as attendee
        const existingAttendee = await FindId(
            ctx,
            MEETING_ATTENDEE_ENTITY,
            `MeetingID = '${Quote(meeting.ID)}' AND PersonID = '${Quote(def.AttendeePersonID)}'`,
        );
        if (!existingAttendee) {
            const attendee = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(
                MEETING_ATTENDEE_ENTITY,
                ctx.User,
            );
            attendee.NewRecord();
            attendee.MeetingID = meeting.ID;
            attendee.PersonID = def.AttendeePersonID;
            attendee.Email = def.AttendeeEmail;
            attendee.DisplayName = def.AttendeeName;
            attendee.Role = 'Required';
            attendee.ResponseStatus = 'Accepted';
            attendee.AttendanceStatus = 'Present';
            await RequireSave(attendee, `attendee ${def.AttendeeEmail}`);
        }

        meeting.Status = 'InProgress';
        await RequireSave(meeting, `start meeting ${SEEDED_MEETING_NAME}`);
        meeting.Status = 'Completed';
        await RequireSave(meeting, `complete meeting ${SEEDED_MEETING_NAME}`);
        meetingID = meeting.ID;
    }

    // Ensure baseline summary MeetingNote exists idempotently
    const noteTitle = `${SEEDED_MEETING_NAME} — Executive Notes`;
    const existingNote = await FindId(
        ctx,
        MEETING_NOTE_ENTITY,
        `MeetingID = '${Quote(meetingID)}' AND Title = '${Quote(noteTitle)}'`,
    );
    if (!existingNote) {
        const note = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(
            MEETING_NOTE_ENTITY,
            ctx.User,
        );
        note.NewRecord();
        note.MeetingID = meetingID;
        note.Kind = 'Summary';
        note.Title = noteTitle;
        note.Source = 'Manual';
        note.Status = 'Final';
        note.Body = [
            '## Decisions',
            '- DECISION: Prioritize Acme Security Compliance Sign-Off ahead of Q4 renewal signature deadline.',
            '',
            '## Action Items',
            '- ACTION: Sarah Connor to finalize Acme Q4 Enterprise Renewal Review pricing addendum by Friday.',
            '- ACTION: Alex Chen to schedule Monthly Financial Close dry-run review with Finance leadership.',
        ].join('\n');
        await RequireSave(note, `meeting note ${noteTitle}`);
    }

    return meetingID;
}

async function upsertTask(
    ctx: IntegrationCheckContext,
    fields: {
        Name: string;
        ParentID?: string;
        TypeID: string;
        TaskTypeStatusID?: string;
        CategoryID: string;
        OrganizationID?: string | null;
        CreatedByPersonID?: string | null;
        DueAt?: Date | null;
        Description?: string | null;
        Status: TaskEntity['Status'];
        Priority: TaskEntity['Priority'];
        PercentComplete: number;
    },
): Promise<string> {
    const existing = await FindId(ctx, TASK_ENTITY, `Name = '${Quote(fields.Name)}'`);
    const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
    if (existing) {
        await task.Load(existing);
    } else {
        task.NewRecord();
    }
    task.Name = fields.Name;
    task.TypeID = fields.TypeID;
    if (fields.TaskTypeStatusID) task.TaskTypeStatusID = fields.TaskTypeStatusID;
    task.CategoryID = fields.CategoryID;
    if (fields.OrganizationID !== undefined) task.OrganizationID = fields.OrganizationID;
    if (fields.CreatedByPersonID !== undefined) task.CreatedByPersonID = fields.CreatedByPersonID;
    if (fields.DueAt !== undefined) task.DueAt = fields.DueAt;
    if (fields.Description !== undefined) task.Description = fields.Description;
    if (fields.ParentID) task.ParentID = fields.ParentID;
    task.Status = fields.Status;
    task.Priority = fields.Priority;
    task.PercentComplete = fields.PercentComplete;
    await RequireSave(task, `task ${fields.Name}`);
    return task.ID;
}
