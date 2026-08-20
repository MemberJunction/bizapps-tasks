/**
 * TASK-WORLD over the GraphQL wire.
 * Types / roles / decision outcomes are LOOKED UP from shipped metadata.
 * Extended categories, people, custom task types, task type statuses,
 * and 3 divergent top-level projects (Software, HQ Construction, Documentary Film)
 * are upserted through BaseEntity subclasses.
 */
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import {
    TaskEntity,
    mjBizAppsTasksTaskCategoryEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import { mjBizAppsCommonPersonEntity } from '@mj-biz-apps/common-entities';
import {
    ACTION_ENTITY,
    PERSON_ENTITY,
    TASK_CATEGORY_ENTITY,
    TASK_DECISION_OUTCOME_ENTITY,
    TASK_ENTITY,
    TASK_ROLE_ENTITY,
    TASK_TYPE_ENTITY,
    TASK_TYPE_STATUS_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave } from '../wire.js';
import { SetWorld, type WorldState } from './world.js';

const WORLD_DOMAIN = 'task-world.test';

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

    // 5. Build Rich Multi-Domain Category Hierarchy
    const Categories: WorldState['Categories'] = {};
    const categoryTreeDefs: Array<{
        name: string;
        description?: string;
        parentName?: string;
    }> = [
        // --- Domain 1: Software & Product Development ---
        { name: 'Engineering & Development', description: 'Core software engineering and technical product development' },
        { name: 'Product & Design', description: 'Product strategy, UX/UI design, and product specifications' },
        { name: 'Operations & Legal', description: 'Business operations, legal compliance, and facilities' },

        { name: 'Core Platform & API', description: 'Platform infrastructure, database schemas, and API services', parentName: 'Engineering & Development' },
        { name: 'Frontend Applications', description: 'Web UI apps, design systems, and client libraries', parentName: 'Engineering & Development' },
        { name: 'DevOps & Quality Engineering', description: 'CI/CD pipelines, automated testing, and cloud infrastructure', parentName: 'Engineering & Development' },
        { name: 'User Experience & Research', description: 'User interviews, usability testing, and wireframes', parentName: 'Product & Design' },
        { name: 'Design Systems & Tokens', description: 'Color palettes, typography, and UI iconography', parentName: 'Product & Design' },
        { name: 'Information Security & Compliance', description: 'SOC2 audits, penetration testing, and security policy reviews', parentName: 'Operations & Legal' },
        { name: 'Finance & Accounting Operations', description: 'Budget tracking, invoicing, and contract reviews', parentName: 'Operations & Legal' },

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
        Status: 'Open',
        Priority: 'High',
        PercentComplete: 0,
    });

    const world: WorldState = {
        Categories,
        Roles,
        DecisionOutcomes,
        TaskTypes,
        TaskTypeStatuses,
        Actions,
        People,
        SeedTaskIDs,
    };
    SetWorld(world);
    return world;
}

export async function GetOrLoadWorld(ctx: IntegrationCheckContext): Promise<WorldState> {
    const { GetWorld } = await import('./world.js');
    return GetWorld() ?? LoadWorld(ctx);
}

async function upsertTask(
    ctx: IntegrationCheckContext,
    fields: {
        Name: string;
        ParentID?: string;
        TypeID: string;
        TaskTypeStatusID?: string;
        CategoryID: string;
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
    if (fields.ParentID) task.ParentID = fields.ParentID;
    task.Status = fields.Status;
    task.Priority = fields.Priority;
    task.PercentComplete = fields.PercentComplete;
    await RequireSave(task, `task ${fields.Name}`);
    return task.ID;
}
