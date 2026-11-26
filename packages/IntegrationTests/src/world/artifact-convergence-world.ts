/**
 * Rich multi-entity domain seed fixtures for Category A / B / C MJ Docs convergence
 * (`WorkReport.ArtifactID` + `MeetingNote.ArtifactID` dual-read, idempotent publishing,
 * RLS persona boundaries, and Category C lightweight relational non-regression).
 *
 * Idempotently layers >= 25 dedicated domain records across Organizations, People,
 * UI-role Users, hierarchical Tasks & TaskLinks, Category A WorkReports (Artifact-linked,
 * legacy Body-only, and zero-version Artifact fallback), Category B Meetings & MeetingNotes
 * (live scratchpad + ProposedTasks JSON and published Artifact-linked), and Category C
 * lightweight relational notes (TaskComment, TaskCheckIn, BlockedReason, TaskTimeEntry)
 * on top of the canonical Task World baseline.
 */
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import type {
    MJArtifactEntity,
    MJArtifactVersionEntity,
    MJUserEntity,
    MJUserRoleEntity,
} from '@memberjunction/core-entities';
import { UserInfo as CoreUserInfo } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import {
    DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID,
    DEFAULT_MJ_ENVIRONMENT_ID,
} from '@mj-biz-apps/tasks-core';
import {
    TaskEntity,
    mjBizAppsTasksMeetingAgendaItemEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ARTIFACT_ENTITY,
    ARTIFACT_TYPE_ENTITY,
    ARTIFACT_VERSION_ENTITY,
    ENVIRONMENT_ENTITY,
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    PERSON_ENTITY,
    ROLE_ENTITY,
    TASK_CHECK_IN_ENTITY,
    TASK_COMMENT_ENTITY,
    TASK_ENTITY,
    TASK_LINK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
    USER_ENTITY,
    USER_ROLE_ENTITY,
    WORK_REPORT_ENTITY,
    WORK_REPORT_ITEM_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, PersonaUser, Quote, RequireSave, VouchForSeed } from '../wire.js';
import { ACME_ORG_NAME, APEX_ORG_NAME, GetOrLoadWorld } from './load-world.js';
import type { WorldState } from './world.js';

export const ACV_ROOT_TASK_NAME = 'ACV Initiative — Q4 MJ Docs Convergence Rollout';
export const ACV_DELIVERABLE_TASK_NAME = 'ACV Deliverable — WorkReport Dual-Read Rollout';
export const ACV_BLOCKED_TASK_NAME = 'ACV Blocked Task — Pending External Security Sign-Off';
export const ACV_FOLLOWUP_TASK_NAME = 'ACV Follow-Up — Finalize Meeting Minutes Promotion Guide';
export const ACV_BLOCKED_REASON_TEXT = 'Awaiting third-party SOC2 penetration test attestation before production cutover.';

export const ACV_WORK_REPORT_LINKED_TITLE = 'ACV Executive Work Report — Artifact-Backed (Category A)';
export const ACV_WORK_REPORT_LEGACY_TITLE = 'ACV Historical Work Report — Legacy Body-Only (Category A)';
export const ACV_WORK_REPORT_ZERO_VER_TITLE = 'ACV Restricted Work Report — Zero-Version Artifact Fallback';

export const ACV_MEETING_NAME = 'ACV Architecture & Minutes Review';
export const ACV_NOTE_SCRATCHPAD_TITLE = 'ACV Live Scratchpad — Unlinked Notes & Proposed Tasks';
export const ACV_NOTE_PUBLISHED_TITLE = 'ACV Published Minutes — Linked MJ Doc';

export const ACV_LINKED_WORK_REPORT_V1_BODY = [
    '# Q4 Executive Work Report (Draft v1)',
    '',
    '- Initial dual-read rollout metrics collected across engineering teams.',
].join('\n');

export const ACV_LINKED_WORK_REPORT_V2_BODY = [
    '# Q4 Executive Work Report (Canonical v2)',
    '',
    '## Key Accomplishments',
    '- Deployed nullable ArtifactID foreign keys across SQL Server and PostgreSQL.',
    '- Verified batched dual-read resolution with zero N+1 query regressions.',
].join('\n');

export const ACV_LEGACY_WORK_REPORT_BODY = [
    '### Historical Summary',
    '- Completed baseline migration verification prior to MJ Docs backing.',
    '- Retained full legacy Markdown Body readability without breaking changes.',
].join('\n');

export const ACV_ZERO_VER_WORK_REPORT_BODY = [
    '### Fallback Executive Summary',
    '- Artifact metadata exists without a readable version; legacy Body remains authoritative.',
].join('\n');

export const ACV_SCRATCHPAD_NOTE_BODY = [
    '## Live Architecture Scratchpad',
    '- Reviewed Category A/B/C boundaries for BizApps Tasks.',
    '- Confirmed TaskComment, TaskCheckIn, BlockedReason, and TaskTimeEntry stay relational.',
].join('\n');

export const ACV_SCRATCHPAD_PROPOSED_TASKS = JSON.stringify([
    {
        id: 'acv-prop-1',
        title: 'Verify PostgreSQL split-bake provenance header in CI',
        priority: 'High',
        status: 'Pending',
        taskId: null,
    },
    {
        id: 'acv-prop-2',
        title: 'Document MJ Docs vs MJ Comments rubric in CLAUDE.md and AGENTS.md',
        priority: 'Medium',
        status: 'Pending',
        taskId: null,
    },
]);

export const ACV_PUBLISHED_NOTE_BODY = [
    '## Published Architecture Minutes',
    '- Approved dual-read batching via ArtifactDualReadResolver.',
    '- Approved idempotent Publish Meeting Note as MJ Doc action.',
].join('\n');

export const ACV_PUBLISHED_NOTE_PROPOSED_TASKS = JSON.stringify([
    {
        id: 'acv-pub-prop-1',
        title: 'Roll out WorkReportArtifactPanel and MeetingNoteArtifactPanel',
        priority: 'High',
        status: 'Accepted',
        taskId: null,
    },
]);

export interface ArtifactConvergencePersona {
    PersonID: string;
    UserID: string;
    Email: string;
    FirstName: string;
    LastName: string;
    UserInfo: UserInfo;
}

export interface ArtifactConvergenceWorldState {
    BaseWorld: WorldState;
    EnvironmentID: string;
    MarkdownArtifactTypeID: string;
    Organizations: {
        ApexID: string;
        AcmeID: string;
    };
    Personas: {
        Sarah: ArtifactConvergencePersona;
        Alex: ArtifactConvergencePersona;
        Elena: ArtifactConvergencePersona;
        MarcusPersonID: string;
    };
    Tasks: {
        RootTaskID: string;
        DeliverableTaskID: string;
        BlockedTaskID: string;
        FollowUpTaskID: string;
    };
    TaskLinkIDs: string[];
    WorkReports: {
        ArtifactLinkedID: string;
        ArtifactLinkedArtifactID: string;
        ArtifactLinkedV1ID: string;
        ArtifactLinkedV2ID: string;
        LegacyBodyOnlyID: string;
        ZeroVersionArtifactReportID: string;
        ZeroVersionArtifactID: string;
        ItemIDs: string[];
    };
    Meeting: {
        MeetingID: string;
        AttendeeIDs: string[];
        AgendaItemID: string;
        LiveScratchpadNoteID: string;
        PublishedNoteID: string;
        PublishedNoteArtifactID: string;
        PublishedNoteV1ID: string;
    };
    CategoryC: {
        ParentCommentID: string;
        ReplyCommentID: string;
        CheckInID: string;
        TimeEntryID: string | null;
    };
}

export interface ArtifactConvergenceSeedSummary {
    Organizations: number;
    People: number;
    UsersWithRoles: number;
    Tasks: number;
    TaskLinks: number;
    WorkReports: number;
    WorkReportItems: number;
    Meetings: number;
    MeetingAttendees: number;
    MeetingAgendaItems: number;
    MeetingNotes: number;
    Artifacts: number;
    ArtifactVersions: number;
    TaskComments: number;
    TaskCheckIns: number;
    TaskTimeEntries: number;
    TotalDomainRecords: number;
}

let cachedWorld: ArtifactConvergenceWorldState | null = null;

export function GetArtifactConvergenceWorld(): ArtifactConvergenceWorldState | null {
    return cachedWorld;
}

export function ResetArtifactConvergenceWorldCache(): void {
    cachedWorld = null;
}

export function ComputeArtifactConvergenceSeedSummary(
    world: ArtifactConvergenceWorldState,
): ArtifactConvergenceSeedSummary {
    const counts = {
        Organizations: 2,
        People: 4,
        UsersWithRoles: 3,
        Tasks: 4,
        TaskLinks: world.TaskLinkIDs.length,
        WorkReports: 3,
        WorkReportItems: world.WorkReports.ItemIDs.length,
        Meetings: 1,
        MeetingAttendees: world.Meeting.AttendeeIDs.length,
        MeetingAgendaItems: 1,
        MeetingNotes: 2,
        Artifacts: 3,
        ArtifactVersions: 3,
        TaskComments: 2,
        TaskCheckIns: 1,
        TaskTimeEntries: world.CategoryC.TimeEntryID ? 1 : 0,
    };
    const total =
        counts.Organizations +
        counts.People +
        counts.UsersWithRoles +
        counts.Tasks +
        counts.TaskLinks +
        counts.WorkReports +
        counts.WorkReportItems +
        counts.Meetings +
        counts.MeetingAttendees +
        counts.MeetingAgendaItems +
        counts.MeetingNotes +
        counts.Artifacts +
        counts.ArtifactVersions +
        counts.TaskComments +
        counts.TaskCheckIns +
        counts.TaskTimeEntries;

    return {
        ...counts,
        TotalDomainRecords: total,
    };
}

async function resolveEnvironmentId(ctx: IntegrationCheckContext): Promise<string> {
    const envs = await FindRows<{ ID: string }>(ctx, ENVIRONMENT_ENTITY, '', ['ID']);
    return envs[0]?.ID ?? DEFAULT_MJ_ENVIRONMENT_ID;
}

async function resolveMarkdownArtifactTypeId(ctx: IntegrationCheckContext): Promise<string> {
    const types = await FindRows<{ ID: string; Name: string; ContentType?: string | null; IsEnabled?: boolean | number | null }>(
        ctx,
        ARTIFACT_TYPE_ENTITY,
        '',
        ['ID', 'Name', 'ContentType', 'IsEnabled'],
    );
    const enabled = types.filter((t) => t.IsEnabled !== false && t.IsEnabled !== 0);
    const exact = enabled.find((t) => t.Name.trim().toLowerCase() === 'markdown document');
    if (exact) return exact.ID;
    const byContentType = enabled.find((t) => (t.ContentType ?? '').trim().toLowerCase() === 'text/markdown');
    if (byContentType) return byContentType.ID;
    return enabled[0]?.ID ?? DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID;
}

async function ensureUIPersona(
    ctx: IntegrationCheckContext,
    person: { ID: string; Email: string; FirstName: string; LastName: string },
): Promise<ArtifactConvergencePersona> {
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.Entities.find((e) => e.Name === PERSON_ENTITY);
    Assert(!!peopleEntity, `${PERSON_ENTITY} metadata must be loaded`);
    const uiRoleId = await FindId(ctx, ROLE_ENTITY, `Name = 'UI'`);
    Assert(!!uiRoleId, 'UI role must exist in MJ: Roles');

    const existingUserId = await FindId(ctx, USER_ENTITY, `LOWER(Email) = LOWER('${Quote(person.Email)}')`);
    const userEntity = await ctx.Provider.GetEntityObject<MJUserEntity>(USER_ENTITY, ctx.User);
    if (existingUserId) {
        await userEntity.Load(existingUserId);
    } else {
        userEntity.NewRecord();
        userEntity.Type = 'User';
    }
    userEntity.Name = `${person.FirstName} ${person.LastName}`;
    userEntity.FirstName = person.FirstName;
    userEntity.LastName = person.LastName;
    userEntity.Email = person.Email;
    userEntity.IsActive = true;
    userEntity.LinkedEntityID = peopleEntity!.ID;
    userEntity.LinkedEntityRecordID = person.ID;
    await RequireSave(userEntity, `ACV UI user ${person.Email}`);

    const existingRoleGrant = await FindId(
        ctx,
        USER_ROLE_ENTITY,
        `UserID = '${EscapeSQLString(userEntity.ID)}' AND RoleID = '${EscapeSQLString(uiRoleId!)}'`,
    );
    if (!existingRoleGrant) {
        const link = await ctx.Provider.GetEntityObject<MJUserRoleEntity>(USER_ROLE_ENTITY, ctx.User);
        link.NewRecord();
        link.UserID = userEntity.ID;
        link.RoleID = uiRoleId!;
        await RequireSave(link, `ACV UI role link for ${person.Email}`);
    }

    const userInfo = new CoreUserInfo(provider, {
        ID: userEntity.ID,
        Name: userEntity.Name,
        FirstName: userEntity.FirstName,
        LastName: userEntity.LastName,
        Email: userEntity.Email,
        Type: 'User',
        IsActive: true,
        LinkedEntityID: peopleEntity!.ID,
        LinkedEntityRecordID: person.ID,
        UserRoles: [{ UserID: userEntity.ID, RoleID: uiRoleId!, Role: 'UI' }],
    });

    return {
        PersonID: person.ID,
        UserID: userEntity.ID,
        Email: person.Email,
        FirstName: person.FirstName,
        LastName: person.LastName,
        UserInfo: userInfo,
    };
}

async function upsertArtifact(
    ctx: IntegrationCheckContext,
    def: {
        Name: string;
        Description: string;
        EnvironmentID: string;
        TypeID: string;
        UserID: string;
    },
): Promise<string> {
    const existing = await FindId(ctx, ARTIFACT_ENTITY, `Name = '${Quote(def.Name)}'`);
    const artifact = await ctx.Provider.GetEntityObject<MJArtifactEntity>(ARTIFACT_ENTITY, ctx.User);
    if (existing) {
        await artifact.Load(existing);
    } else {
        artifact.NewRecord();
    }
    artifact.Name = def.Name;
    artifact.Description = def.Description;
    artifact.EnvironmentID = def.EnvironmentID;
    artifact.TypeID = def.TypeID;
    artifact.UserID = def.UserID;
    artifact.Visibility = 'Always';
    await RequireSave(artifact, `ACV artifact ${def.Name}`);
    return artifact.ID;
}

async function upsertArtifactVersion(
    ctx: IntegrationCheckContext,
    def: {
        ArtifactID: string;
        VersionNumber: number;
        Name: string;
        Content: string;
        UserID: string;
    },
): Promise<string> {
    const existing = await FindId(
        ctx,
        ARTIFACT_VERSION_ENTITY,
        `ArtifactID = '${EscapeSQLString(def.ArtifactID)}' AND VersionNumber = ${def.VersionNumber}`,
    );
    const version = await ctx.Provider.GetEntityObject<MJArtifactVersionEntity>(ARTIFACT_VERSION_ENTITY, ctx.User);
    if (existing) {
        await version.Load(existing);
    } else {
        version.NewRecord();
        version.ArtifactID = def.ArtifactID;
        version.VersionNumber = def.VersionNumber;
    }
    version.Name = def.Name;
    version.Content = def.Content;
    version.UserID = def.UserID;
    version.ContentMode = 'Text';
    version.MimeType = 'text/markdown';
    version.ContentSizeBytes = new TextEncoder().encode(def.Content).byteLength;
    await RequireSave(version, `ACV artifact version ${def.Name} v${def.VersionNumber}`);
    return version.ID;
}

async function upsertAcvTask(
    ctx: IntegrationCheckContext,
    def: {
        Name: string;
        ParentID?: string | null;
        TypeID: string;
        CategoryID: string;
        OrganizationID: string;
        CreatedByPersonID: string;
        Status: TaskEntity['Status'];
        Priority: TaskEntity['Priority'];
        PercentComplete: number;
        BlockedReason?: string | null;
        Description: string;
    },
): Promise<string> {
    const existing = await FindId(ctx, TASK_ENTITY, `Name = '${Quote(def.Name)}'`);
    const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
    if (existing) {
        await task.Load(existing);
    } else {
        task.NewRecord();
    }
    task.Name = def.Name;
    task.TypeID = def.TypeID;
    task.CategoryID = def.CategoryID;
    task.OrganizationID = def.OrganizationID;
    task.CreatedByPersonID = def.CreatedByPersonID;
    if (def.ParentID !== undefined) task.ParentID = def.ParentID;
    task.Status = def.Status;
    task.Priority = def.Priority;
    task.PercentComplete = def.PercentComplete;
    task.Description = def.Description;
    if (def.BlockedReason !== undefined) {
        task.BlockedReason = def.BlockedReason;
    }
    VouchForSeed(task, 'AuthorizeCreatorOnBehalf');
    await RequireSave(task, `ACV task ${def.Name}`);
    return task.ID;
}

async function ensureTaskLink(
    ctx: IntegrationCheckContext,
    taskID: string,
    targetEntityName: string,
    recordID: string,
    description: string,
): Promise<string> {
    const provider = ctx.Provider as IMetadataProvider;
    const entityInfo = provider.Entities.find((e) => e.Name === targetEntityName);
    Assert(!!entityInfo, `Target entity metadata '${targetEntityName}' must exist for TaskLink`);
    const existing = await FindId(
        ctx,
        TASK_LINK_ENTITY,
        `TaskID = '${EscapeSQLString(taskID)}' AND EntityID = '${EscapeSQLString(entityInfo!.ID)}' AND RecordID = '${EscapeSQLString(recordID)}'`,
    );
    if (existing) return existing;

    const link = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINK_ENTITY, ctx.User);
    link.NewRecord();
    link.TaskID = taskID;
    link.EntityID = entityInfo!.ID;
    link.RecordID = recordID;
    link.Description = description;
    await RequireSave(link, `ACV TaskLink ${description}`);
    return link.ID;
}

async function upsertWorkReport(
    ctx: IntegrationCheckContext,
    def: {
        PersonID: string;
        PeriodStartIso: string;
        PeriodEndIso: string;
        Title: string;
        Body: string;
        ArtifactID: string | null;
        Status: mjBizAppsTasksWorkReportEntity['Status'];
    },
): Promise<string> {
    const existing = await FindId(
        ctx,
        WORK_REPORT_ENTITY,
        `PersonID = '${EscapeSQLString(def.PersonID)}' AND Title = '${Quote(def.Title)}'`,
    );
    const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
    if (existing) {
        await report.Load(existing);
        report.Title = def.Title;
        report.Body = def.Body;
        report.ArtifactID = def.ArtifactID;
        report.Status = def.Status;
        await RequireSave(report, `ACV work report ${def.Title}`);
    } else {
        report.NewRecord();
        report.PersonID = def.PersonID;
        report.PeriodStart = new Date(`${def.PeriodStartIso}T00:00:00.000Z`);
        report.PeriodEnd = new Date(`${def.PeriodEndIso}T00:00:00.000Z`);
        report.Title = def.Title;
        report.Body = def.Body;
        report.ArtifactID = def.ArtifactID;
        report.Status = 'Draft';
        await RequireSave(report, `ACV work report ${def.Title} (initial Draft)`);
        if (def.Status !== 'Draft') {
            report.Status = def.Status;
            await RequireSave(report, `ACV work report ${def.Title} (transition to ${def.Status})`);
        }
    }
    return report.ID;
}

async function ensureWorkReportItem(
    ctx: IntegrationCheckContext,
    def: {
        WorkReportID: string;
        TaskID: string;
        Section: mjBizAppsTasksWorkReportItemEntity['Section'];
        Summary: string;
        Sequence: number;
    },
): Promise<string> {
    const existing = await FindId(
        ctx,
        WORK_REPORT_ITEM_ENTITY,
        `WorkReportID = '${EscapeSQLString(def.WorkReportID)}' AND Sequence = ${def.Sequence}`,
    );
    if (existing) return existing;
    const item = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(
        WORK_REPORT_ITEM_ENTITY,
        ctx.User,
    );
    item.NewRecord();
    item.WorkReportID = def.WorkReportID;
    item.TaskID = def.TaskID;
    item.Section = def.Section;
    item.Summary = def.Summary;
    item.Sequence = def.Sequence;
    await RequireSave(item, `ACV work report item seq=${def.Sequence}`);
    return item.ID;
}

/**
 * Loads (or idempotently seeds) the full multi-entity Artifact Convergence domain world.
 */
export async function LoadArtifactConvergenceWorld(
    ctx: IntegrationCheckContext,
): Promise<ArtifactConvergenceWorldState> {
    if (cachedWorld) {
        return cachedWorld;
    }

    const baseWorld = await GetOrLoadWorld(ctx);
    const environmentID = await resolveEnvironmentId(ctx);
    const markdownArtifactTypeID = await resolveMarkdownArtifactTypeId(ctx);

    const apexOrg = baseWorld.Organizations[APEX_ORG_NAME];
    const acmeOrg = baseWorld.Organizations[ACME_ORG_NAME];
    Assert(!!apexOrg && !!acmeOrg, 'Baseline Apex and Acme organizations must exist');

    const sarahPerson = baseWorld.People['sarah.connor@task-world.test'];
    const alexPerson = baseWorld.People['alex.chen@task-world.test'];
    const marcusPerson = baseWorld.People['marcus.vance@task-world.test'];
    const elenaPerson = baseWorld.People['elena.rostova@task-world.test'];
    Assert(!!sarahPerson && !!alexPerson && !!marcusPerson && !!elenaPerson, 'Baseline Task World people must exist');

    const sarah = await ensureUIPersona(ctx, sarahPerson);
    const alex = await ensureUIPersona(ctx, alexPerson);
    const elena = await ensureUIPersona(ctx, elenaPerson);

    const engCat = baseWorld.Categories['Engineering & Development'];
    const deliverableType = baseWorld.TaskTypes['DELIVERABLE'] ?? baseWorld.TaskTypes['Deliverable'] ?? Object.values(baseWorld.TaskTypes)[0];
    const generalType = baseWorld.TaskTypes['GENERAL'] ?? baseWorld.TaskTypes['General'] ?? deliverableType;
    const actionItemType = baseWorld.TaskTypes['ACTION_ITEM'] ?? baseWorld.TaskTypes['Action Item'] ?? generalType;

    // 1. Hierarchical Tasks (including Category C BlockedReason on Blocked task)
    const rootTaskID = await upsertAcvTask(ctx, {
        Name: ACV_ROOT_TASK_NAME,
        TypeID: deliverableType.ID,
        CategoryID: engCat.ID,
        OrganizationID: apexOrg.ID,
        CreatedByPersonID: alex.PersonID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 55,
        Description: 'Roll out additive nullable ArtifactID FKs on WorkReport and MeetingNote across SQL Server and PostgreSQL.',
    });

    const deliverableTaskID = await upsertAcvTask(ctx, {
        Name: ACV_DELIVERABLE_TASK_NAME,
        ParentID: rootTaskID,
        TypeID: deliverableType.ID,
        CategoryID: engCat.ID,
        OrganizationID: apexOrg.ID,
        CreatedByPersonID: sarah.PersonID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 80,
        Description: 'Implement batched ArtifactDualReadResolver and WorkReportArtifactPanel.',
    });

    const blockedTaskID = await upsertAcvTask(ctx, {
        Name: ACV_BLOCKED_TASK_NAME,
        ParentID: rootTaskID,
        TypeID: generalType.ID,
        CategoryID: engCat.ID,
        OrganizationID: acmeOrg.ID,
        CreatedByPersonID: sarah.PersonID,
        Status: 'Blocked',
        Priority: 'Critical',
        PercentComplete: 20,
        BlockedReason: ACV_BLOCKED_REASON_TEXT,
        Description: 'Validate compliance sign-off before releasing customer-facing convergence pack.',
    });

    const followUpTaskID = await upsertAcvTask(ctx, {
        Name: ACV_FOLLOWUP_TASK_NAME,
        ParentID: rootTaskID,
        TypeID: actionItemType.ID,
        CategoryID: engCat.ID,
        OrganizationID: apexOrg.ID,
        CreatedByPersonID: alex.PersonID,
        Status: 'Open',
        Priority: 'Medium',
        PercentComplete: 10,
        Description: 'Finalize developer rubric comparing MJ Docs, MJ Comments, and Category C relational notes.',
    });

    // 2. Category A: WorkReports (Artifact-linked v1+v2, Legacy Body-only, Zero-Version Artifact fallback)
    const linkedWorkReportArtifactID = await upsertArtifact(ctx, {
        Name: 'ACV Executive Work Report MJ Doc',
        Description: 'Canonical MJ Doc backing for Category A executive work report',
        EnvironmentID: environmentID,
        TypeID: markdownArtifactTypeID,
        UserID: sarah.UserID,
    });
    const linkedWorkReportV1ID = await upsertArtifactVersion(ctx, {
        ArtifactID: linkedWorkReportArtifactID,
        VersionNumber: 1,
        Name: 'ACV Executive Work Report MJ Doc v1',
        Content: ACV_LINKED_WORK_REPORT_V1_BODY,
        UserID: sarah.UserID,
    });
    const linkedWorkReportV2ID = await upsertArtifactVersion(ctx, {
        ArtifactID: linkedWorkReportArtifactID,
        VersionNumber: 2,
        Name: 'ACV Executive Work Report MJ Doc v2',
        Content: ACV_LINKED_WORK_REPORT_V2_BODY,
        UserID: sarah.UserID,
    });

    const zeroVersionArtifactID = await upsertArtifact(ctx, {
        Name: 'ACV Zero-Version Artifact Stub',
        Description: 'Artifact header intentionally created without any MJ: Artifact Versions rows for fallback testing',
        EnvironmentID: environmentID,
        TypeID: markdownArtifactTypeID,
        UserID: sarah.UserID,
    });

    const artifactLinkedReportID = await upsertWorkReport(ctx, {
        PersonID: sarah.PersonID,
        PeriodStartIso: '2026-11-16',
        PeriodEndIso: '2026-11-20',
        Title: ACV_WORK_REPORT_LINKED_TITLE,
        Body: 'Legacy preview snapshot preserved alongside canonical MJ Doc.',
        ArtifactID: linkedWorkReportArtifactID,
        Status: 'Submitted',
    });

    const legacyBodyOnlyReportID = await upsertWorkReport(ctx, {
        PersonID: sarah.PersonID,
        PeriodStartIso: '2026-11-09',
        PeriodEndIso: '2026-11-13',
        Title: ACV_WORK_REPORT_LEGACY_TITLE,
        Body: ACV_LEGACY_WORK_REPORT_BODY,
        ArtifactID: null,
        Status: 'Submitted',
    });

    const zeroVersionArtifactReportID = await upsertWorkReport(ctx, {
        PersonID: sarah.PersonID,
        PeriodStartIso: '2026-11-23',
        PeriodEndIso: '2026-11-27',
        Title: ACV_WORK_REPORT_ZERO_VER_TITLE,
        Body: ACV_ZERO_VER_WORK_REPORT_BODY,
        ArtifactID: zeroVersionArtifactID,
        Status: 'Draft',
    });

    const reportItem1 = await ensureWorkReportItem(ctx, {
        WorkReportID: artifactLinkedReportID,
        TaskID: deliverableTaskID,
        Section: 'Completed',
        Summary: 'Delivered batched ArtifactDualReadResolver with SQL IN chunking.',
        Sequence: 1,
    });
    const reportItem2 = await ensureWorkReportItem(ctx, {
        WorkReportID: artifactLinkedReportID,
        TaskID: blockedTaskID,
        Section: 'Blockers',
        Summary: 'External SOC2 penetration test attestation still pending.',
        Sequence: 2,
    });
    const reportItem3 = await ensureWorkReportItem(ctx, {
        WorkReportID: legacyBodyOnlyReportID,
        TaskID: followUpTaskID,
        Section: 'Next',
        Summary: 'Publish MJ Docs vs MJ Comments rubric across developer guides.',
        Sequence: 1,
    });

    // 3. Category B: Meeting + Attendees + AgendaItem + 2 MeetingNotes (Live Scratchpad + Published MJ Doc)
    let meetingID = await FindId(ctx, MEETING_ENTITY, `Name = '${Quote(ACV_MEETING_NAME)}'`);
    if (!meetingID) {
        const startsAt = new Date(Date.now() - 3 * 60 * 60 * 1000);
        const endsAt = new Date(Date.now() - 2 * 60 * 60 * 1000);
        const meeting = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
        meeting.NewRecord();
        meeting.Name = ACV_MEETING_NAME;
        meeting.Description = 'Cross-stack review of WorkReport & MeetingNote ArtifactID convergence.';
        meeting.OrganizerPersonID = alex.PersonID;
        meeting.StartsAt = startsAt;
        meeting.EndsAt = endsAt;
        meeting.TimeZone = 'America/Chicago';
        meeting.LocationType = 'Virtual';
        meeting.Visibility = 'Standard';
        meeting.Status = 'Scheduled';
        await RequireSave(meeting, `ACV meeting ${ACV_MEETING_NAME}`);
        meetingID = meeting.ID;
    }

    const attendeeIDs: string[] = [];
    for (const attDef of [
        { person: alex, role: 'Organizer' as const },
        { person: sarah, role: 'Required' as const },
    ]) {
        const existingAtt = await FindId(
            ctx,
            MEETING_ATTENDEE_ENTITY,
            `MeetingID = '${EscapeSQLString(meetingID)}' AND PersonID = '${EscapeSQLString(attDef.person.PersonID)}'`,
        );
        if (existingAtt) {
            attendeeIDs.push(existingAtt);
        } else {
            const attendee = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(
                MEETING_ATTENDEE_ENTITY,
                ctx.User,
            );
            attendee.NewRecord();
            attendee.MeetingID = meetingID;
            attendee.PersonID = attDef.person.PersonID;
            attendee.Email = attDef.person.Email;
            attendee.DisplayName = `${attDef.person.FirstName} ${attDef.person.LastName}`;
            attendee.Role = attDef.role;
            attendee.ResponseStatus = 'Accepted';
            attendee.AttendanceStatus = 'Present';
            await RequireSave(attendee, `ACV meeting attendee ${attDef.person.Email}`);
            attendeeIDs.push(attendee.ID);
        }
    }

    let agendaItemID = await FindId(
        ctx,
        MEETING_AGENDA_ITEM_ENTITY,
        `MeetingID = '${EscapeSQLString(meetingID)}' AND Name = 'Category A/B MJ Docs Review'`,
    );
    if (!agendaItemID) {
        const agenda = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(
            MEETING_AGENDA_ITEM_ENTITY,
            ctx.User,
        );
        agenda.NewRecord();
        agenda.MeetingID = meetingID;
        agenda.Name = 'Category A/B MJ Docs Review';
        agenda.Description = 'Review WorkReport and MeetingNote ArtifactID schema and UI panel behavior.';
        agenda.Sequence = 10;
        agenda.DurationMinutes = 25;
        await RequireSave(agenda, 'ACV meeting agenda item');
        agendaItemID = agenda.ID;
    }

    // Category B.1: Live scratchpad MeetingNote (ArtifactID = null + ProposedTasks JSON)
    let liveScratchpadNoteID = await FindId(
        ctx,
        MEETING_NOTE_ENTITY,
        `MeetingID = '${EscapeSQLString(meetingID)}' AND Title = '${Quote(ACV_NOTE_SCRATCHPAD_TITLE)}'`,
    );
    {
        const note = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
        if (liveScratchpadNoteID) {
            await note.Load(liveScratchpadNoteID);
        } else {
            note.NewRecord();
            note.MeetingID = meetingID;
            note.AgendaItemID = agendaItemID;
        }
        note.Kind = 'Notes';
        note.Title = ACV_NOTE_SCRATCHPAD_TITLE;
        note.Body = ACV_SCRATCHPAD_NOTE_BODY;
        note.ProposedTasks = ACV_SCRATCHPAD_PROPOSED_TASKS;
        note.Source = 'Manual';
        note.Status = 'Draft';
        note.AuthorPersonID = sarah.PersonID;
        note.ArtifactID = null;
        await RequireSave(note, 'ACV live scratchpad meeting note');
        liveScratchpadNoteID = note.ID;
    }

    // Category B.2: Published MeetingNote (linked to MJ: Artifact + Version 1, preserving Body & ProposedTasks)
    const publishedNoteArtifactID = await upsertArtifact(ctx, {
        Name: 'ACV Published Architecture Minutes MJ Doc',
        Description: 'Published MJ Doc for ACV Architecture & Minutes Review',
        EnvironmentID: environmentID,
        TypeID: markdownArtifactTypeID,
        UserID: alex.UserID,
    });
    const publishedNoteV1ID = await upsertArtifactVersion(ctx, {
        ArtifactID: publishedNoteArtifactID,
        VersionNumber: 1,
        Name: 'ACV Published Architecture Minutes MJ Doc v1',
        Content: ACV_PUBLISHED_NOTE_BODY,
        UserID: alex.UserID,
    });

    let publishedNoteID = await FindId(
        ctx,
        MEETING_NOTE_ENTITY,
        `MeetingID = '${EscapeSQLString(meetingID)}' AND Title = '${Quote(ACV_NOTE_PUBLISHED_TITLE)}'`,
    );
    {
        const note = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
        if (publishedNoteID) {
            await note.Load(publishedNoteID);
        } else {
            note.NewRecord();
            note.MeetingID = meetingID;
            note.AgendaItemID = agendaItemID;
        }
        note.Kind = 'Summary';
        note.Title = ACV_NOTE_PUBLISHED_TITLE;
        note.Body = ACV_PUBLISHED_NOTE_BODY;
        note.ProposedTasks = ACV_PUBLISHED_NOTE_PROPOSED_TASKS;
        note.Source = 'Manual';
        note.Status = 'Final';
        note.AuthorPersonID = alex.PersonID;
        note.ArtifactID = publishedNoteArtifactID;
        await RequireSave(note, 'ACV published meeting note');
        publishedNoteID = note.ID;
    }

    // 4. Polymorphic TaskLinks connecting Tasks to WorkReport & Meeting
    const taskLink1 = await ensureTaskLink(
        ctx,
        deliverableTaskID,
        WORK_REPORT_ENTITY,
        artifactLinkedReportID,
        'Links deliverable task to Category A Artifact-backed WorkReport',
    );
    const taskLink2 = await ensureTaskLink(
        ctx,
        followUpTaskID,
        MEETING_ENTITY,
        meetingID,
        'Links follow-up action item to Category B Architecture Review Meeting',
    );

    // 5. Category C Lightweight Relational Notes (TaskComment x2, TaskCheckIn, TaskTimeEntry)
    let parentCommentID = await FindId(
        ctx,
        TASK_COMMENT_ENTITY,
        `TaskID = '${EscapeSQLString(deliverableTaskID)}' AND Content LIKE 'ACV Category C Comment:%'`,
    );
    if (!parentCommentID) {
        const comment = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
            TASK_COMMENT_ENTITY,
            ctx.User,
        );
        comment.NewRecord();
        comment.TaskID = deliverableTaskID;
        comment.PersonID = sarah.PersonID;
        comment.Content = 'ACV Category C Comment: Confirmed lightweight relational TaskComment needs no ArtifactID.';
        comment.IsEdited = false;
        await RequireSave(comment, 'ACV parent task comment');
        parentCommentID = comment.ID;
    }

    let replyCommentID = await FindId(
        ctx,
        TASK_COMMENT_ENTITY,
        `TaskID = '${EscapeSQLString(deliverableTaskID)}' AND ParentID = '${EscapeSQLString(parentCommentID)}'`,
    );
    if (!replyCommentID) {
        const reply = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
            TASK_COMMENT_ENTITY,
            ctx.User,
        );
        reply.NewRecord();
        reply.TaskID = deliverableTaskID;
        reply.ParentID = parentCommentID;
        reply.PersonID = alex.PersonID;
        reply.Content = 'ACV Category C Reply: Verified threaded reply stays fast and relational.';
        reply.IsEdited = false;
        await RequireSave(reply, 'ACV reply task comment');
        replyCommentID = reply.ID;
    }

    let checkInID = await FindId(
        ctx,
        TASK_CHECK_IN_ENTITY,
        `TaskID = '${EscapeSQLString(deliverableTaskID)}' AND Summary LIKE 'ACV Category C CheckIn:%'`,
    );
    if (!checkInID) {
        const checkIn = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCheckInEntity>(
            TASK_CHECK_IN_ENTITY,
            ctx.User,
        );
        checkIn.NewRecord();
        checkIn.TaskID = deliverableTaskID;
        checkIn.AuthorPersonID = sarah.PersonID;
        checkIn.AuthorUserID = sarah.UserID;
        checkIn.CheckInAt = new Date('2026-11-24T15:00:00.000Z');
        checkIn.HealthStatus = 'OnTrack';
        checkIn.ConfidenceScore = 4;
        checkIn.PercentComplete = 80;
        checkIn.Summary = 'ACV Category C CheckIn: Dual-read batch resolver green across SQL Server and PostgreSQL.';
        checkIn.Blockers = null;
        checkIn.NextSteps = 'Complete Slice 3 dual-DBMS integration verification.';
        await RequireSave(checkIn, 'ACV task check-in');
        checkInID = checkIn.ID;
    }

    let timeEntryID: string | null = null;
    const hasTimeEntryEntity = (ctx.Provider as IMetadataProvider).Entities.some(
        (e) => e.Name === TASK_TIME_ENTRY_ENTITY,
    );
    if (hasTimeEntryEntity) {
        timeEntryID = await FindId(
            ctx,
            TASK_TIME_ENTRY_ENTITY,
            `TaskID = '${EscapeSQLString(deliverableTaskID)}' AND Notes LIKE 'ACV Category C TimeEntry:%'`,
        );
        if (!timeEntryID) {
            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                PersonaUser(ctx, sarah.PersonID, { canManage: true }),
            );
            entry.NewRecord();
            entry.TaskID = deliverableTaskID;
            entry.PersonID = sarah.PersonID;
            entry.WorkDate = new Date('2026-11-24T00:00:00.000Z');
            entry.Minutes = 90;
            entry.Notes = 'ACV Category C TimeEntry: Implemented and tested batched ArtifactID dual-read resolver.';
            entry.Source = 'Manual';
            entry.IsBillable = true;
            await RequireSave(entry, 'ACV task time entry');
            timeEntryID = entry.ID;
        }
    }

    cachedWorld = {
        BaseWorld: baseWorld,
        EnvironmentID: environmentID,
        MarkdownArtifactTypeID: markdownArtifactTypeID,
        Organizations: {
            ApexID: apexOrg.ID,
            AcmeID: acmeOrg.ID,
        },
        Personas: {
            Sarah: sarah,
            Alex: alex,
            Elena: elena,
            MarcusPersonID: marcusPerson.ID,
        },
        Tasks: {
            RootTaskID: rootTaskID,
            DeliverableTaskID: deliverableTaskID,
            BlockedTaskID: blockedTaskID,
            FollowUpTaskID: followUpTaskID,
        },
        TaskLinkIDs: [taskLink1, taskLink2],
        WorkReports: {
            ArtifactLinkedID: artifactLinkedReportID,
            ArtifactLinkedArtifactID: linkedWorkReportArtifactID,
            ArtifactLinkedV1ID: linkedWorkReportV1ID,
            ArtifactLinkedV2ID: linkedWorkReportV2ID,
            LegacyBodyOnlyID: legacyBodyOnlyReportID,
            ZeroVersionArtifactReportID: zeroVersionArtifactReportID,
            ZeroVersionArtifactID: zeroVersionArtifactID,
            ItemIDs: [reportItem1, reportItem2, reportItem3],
        },
        Meeting: {
            MeetingID: meetingID,
            AttendeeIDs: attendeeIDs,
            AgendaItemID: agendaItemID,
            LiveScratchpadNoteID: liveScratchpadNoteID,
            PublishedNoteID: publishedNoteID,
            PublishedNoteArtifactID: publishedNoteArtifactID,
            PublishedNoteV1ID: publishedNoteV1ID,
        },
        CategoryC: {
            ParentCommentID: parentCommentID,
            ReplyCommentID: replyCommentID,
            CheckInID: checkInID,
            TimeEntryID: timeEntryID,
        },
    };

    return cachedWorld;
}
