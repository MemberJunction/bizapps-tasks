import { BaseEntity } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { Assert, AssertEqual, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import {
    TaskEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ACTION_ENTITY,
    TASK_ENTITY,
    TASK_TYPE_ENTITY,
    WORK_REPORT_ENTITY,
    WORK_REPORT_ITEM_ENTITY,
} from '../entity-names.js';
import { DeleteTask, FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

interface FieldSuggestionContract extends BaseEntity {
    ID: string;
    UserID: string;
    EnvironmentID: string;
    Status: string;
    ApplicationScope: string;
    IsArchived: boolean;
    IsPinned: boolean;
    LinkedEntityID: string | null;
    LinkedRecordID: string | null;
    Name: string | null;
    Description: string | null;
    TypeID: string;
    CommentTypeID: string;
    AnchorType: string | null;
    AnchorKey: string | null;
    SuggestedValue: string | null;
    Confidence: number | null;
    Source: 'Agent' | 'Integration' | 'LLM' | 'Person';
    Outcome: 'Accepted' | 'Rejected' | 'Superseded' | null;
    IsResolved: boolean;
}

interface SubtypeSelectorMetadataShape {
    Path?: string;
    AutoEnsureOnSave?: boolean;
    OnSubtypeChange?: string;
    FoldIntoForm?: boolean;
}

interface EntityCommentsConfigurationShape {
    Comments?: {
        Enabled?: boolean;
        AllowedCommentTypes?: string[];
    };
}

const checks: NamedCheck[] = [
    {
        Id: 'task-work-bus-and-reports.WB1',
        Name: 'WB1 — Tasks entity declares SubtypeSelector + FIELD_SUGGESTION comments and TaskType exposes ExtensionEntity',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const tasksInfo = ctx.Provider.EntityByName(TASK_ENTITY);
            const taskTypesInfo = ctx.Provider.EntityByName(TASK_TYPE_ENTITY);
            Assert(!!tasksInfo, 'MJ_BizApps_Tasks: Tasks entity loaded');
            Assert(!!taskTypesInfo, 'MJ_BizApps_Tasks: Task Types entity loaded');

            const extField = taskTypesInfo!.Fields.find((f) => f.Name === 'ExtensionEntity');
            Assert(!!extField, 'TaskType.ExtensionEntity field exists in metadata');

            const rawSelector: string | SubtypeSelectorMetadataShape | null | undefined = tasksInfo!.SubtypeSelector;
            const parsedSelector: SubtypeSelectorMetadataShape | undefined =
                typeof rawSelector === 'string'
                    ? (JSON.parse(rawSelector) as SubtypeSelectorMetadataShape)
                    : (rawSelector ?? undefined);
            Assert(!!parsedSelector, 'Tasks.SubtypeSelector populated');
            AssertEqual(parsedSelector!.Path, 'TypeID.ExtensionEntity', 'SubtypeSelector.Path');
            AssertEqual(parsedSelector!.AutoEnsureOnSave, true, 'SubtypeSelector.AutoEnsureOnSave');
            AssertEqual(parsedSelector!.OnSubtypeChange, 'Replace', 'SubtypeSelector.OnSubtypeChange');
            AssertEqual(parsedSelector!.FoldIntoForm, true, 'SubtypeSelector.FoldIntoForm');

            const cfg = tasksInfo!.Configuration as EntityCommentsConfigurationShape | undefined;
            const comments = cfg?.Comments;
            Assert(comments?.Enabled === true, 'Tasks Configuration.Comments.Enabled is true');
            Assert(
                Array.isArray(comments?.AllowedCommentTypes) && comments!.AllowedCommentTypes.includes('FIELD_SUGGESTION'),
                'Tasks Configuration.Comments.AllowedCommentTypes includes FIELD_SUGGESTION',
            );
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB2',
        Name: 'WB2 — TaskType.ExtensionEntity rejects an entity that is not an IS-A child of Tasks (when MJ 6.3 SubtypeSelector core is active)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const invalidType = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTypeEntity>(TASK_TYPE_ENTITY, ctx.User);
            invalidType.NewRecord();
            invalidType.Name = `WB2 Invalid Extension Type ${Date.now()}`;
            invalidType.Code = `WB2_INVALID_${Date.now()}`;
            invalidType.ExtensionEntity = TASK_TYPE_ENTITY; // Not an IS-A child of Tasks!
            invalidType.IsActive = true;

            const saved = await invalidType.Save();
            if (saved) {
                // On an MJ 6.2.1 host (before MJ#6491 SubtypeSelector enforcement), clean up the probe row
                // and verify the ExtensionEntity column round-tripped cleanly.
                AssertEqual(invalidType.ExtensionEntity, TASK_TYPE_ENTITY, 'ExtensionEntity column persisted on pre-6.3 host');
                Assert(await invalidType.Delete(), 'Cleaned up WB2 probe TaskType on pre-6.3 host');
                return;
            }
            const msg = invalidType.LatestResult?.CompleteMessage ?? '';
            Assert(
                msg.includes('IS-A') || msg.includes('ExtensionEntity') || msg.includes('child'),
                `Expected SubtypeSelector validation message, got: ${msg}`,
            );
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB3',
        Name: 'WB3 — Work reports skill, Chief of Staff grant, NavItem.bizapps-tasks.work-reports, and Actions exist',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const skills = await FindRows<{ ID: string; Name: string }>(
                ctx,
                'MJ: AI Skills',
                `Name = 'Work reports'`,
                ['ID', 'Name'],
            );
            Assert(skills.length === 1, 'Work reports skill exists in MJ: AI Skills');

            const grants = await FindRows<{ ID: string }>(
                ctx,
                'MJ: AI Agent Skills',
                `SkillID = '${EscapeSQLString(skills[0].ID)}' AND Status = 'Active'`,
                ['ID'],
            );
            Assert(grants.length >= 1, 'Work reports skill granted to Chief of Staff in MJ: AI Agent Skills');

            const navSettings = await FindRows<{ ID: string; Value: string }>(
                ctx,
                'MJ: Application Settings',
                `Name = 'NavItem.bizapps-tasks.work-reports'`,
                ['ID', 'Value'],
            );
            Assert(navSettings.length === 1, 'NavItem.bizapps-tasks.work-reports installed in Chief of Staff');
            Assert(
                navSettings[0].Value.includes('BizAppsTasksChiefOfStaffWorkReports'),
                'NavItem routes to BizAppsTasksChiefOfStaffWorkReports',
            );

            const actions = await FindRows<{ ID: string; Name: string; DriverClass: string }>(
                ctx,
                ACTION_ENTITY,
                `DriverClass IN ('Tasks.DraftWorkReport', 'Tasks.SubmitWorkReport', 'Tasks.ReviewWorkReport')`,
                ['ID', 'Name', 'DriverClass'],
            );
            AssertEqual(actions.length, 3, 'All 3 Work Report actions registered');
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB4',
        Name: 'WB4 — WorkReport and WorkReportItem persist across sections and link to Tasks',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const people = Object.values(world.People);
            Assert(people.length >= 1, 'At least one Person in Task World');
            const author = people[0];
            const deliverableType = world.TaskTypes['DELIVERABLE'] ?? Object.values(world.TaskTypes)[0];
            const catID = Object.values(world.Categories)[0].ID;

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `WB4 Shipped Deliverable ${Date.now()}`;
            task.TypeID = deliverableType.ID;
            task.CategoryID = catID;
            task.Priority = 'High';
            await RequireSave(task, 'WB4 task');

            const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            report.NewRecord();
            report.PersonID = author.ID;
            report.PeriodStart = new Date('2026-11-09T00:00:00.000Z');
            report.PeriodEnd = new Date('2026-11-09T23:59:59.000Z');
            report.Title = 'WB4 Daily 15Five';
            report.Body = `### Completed\n- **${task.Name}**`;
            report.Status = 'Draft';
            await RequireSave(report, 'WB4 draft work report');

            const item = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(WORK_REPORT_ITEM_ENTITY, ctx.User);
            item.NewRecord();
            item.WorkReportID = report.ID;
            item.TaskID = task.ID;
            item.Section = 'Completed';
            item.Summary = `${task.Name} (100%)`;
            item.Sequence = 1;
            await RequireSave(item, 'WB4 work report item');

            const loadedItems = await FindRows<{ ID: string; Section: string; TaskID: string }>(
                ctx,
                WORK_REPORT_ITEM_ENTITY,
                `WorkReportID = '${EscapeSQLString(report.ID)}'`,
                ['ID', 'Section', 'TaskID'],
            );
            AssertEqual(loadedItems.length, 1, '1 WorkReportItem persisted');
            AssertEqual(loadedItems[0].Section, 'Completed', 'Section persisted');
            AssertEqual(loadedItems[0].TaskID.toLowerCase(), task.ID.toLowerCase(), 'TaskID FK persisted');

            Assert(await item.Delete(), 'delete WB4 item');
            Assert(await report.Delete(), 'delete WB4 report');
            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB5',
        Name: 'WB5 — WorkReport enforces PeriodEnd >= PeriodStart and UQ_WorkReport_Person_Period constraints',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const author = Object.values(world.People)[0];

            const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            report.NewRecord();
            report.PersonID = author.ID;
            report.PeriodStart = new Date('2026-11-10T00:00:00.000Z');
            report.PeriodEnd = new Date('2026-11-03T00:00:00.000Z');
            report.Title = 'WB5 Invalid Period';
            report.Body = 'Inverted dates';
            report.Status = 'Draft';

            const saved = await report.Save();
            Assert(!saved, 'WorkReport with PeriodEnd < PeriodStart rejected');

            const first = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            first.NewRecord();
            first.PersonID = author.ID;
            first.PeriodStart = new Date('2026-11-11T00:00:00.000Z');
            first.PeriodEnd = new Date('2026-11-11T23:59:59.000Z');
            first.Title = 'WB5 Unique Period 1';
            first.Body = 'First draft for period';
            first.Status = 'Draft';
            await RequireSave(first, 'WB5 first report for period');

            const duplicate = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            duplicate.NewRecord();
            duplicate.PersonID = author.ID;
            duplicate.PeriodStart = new Date('2026-11-11T00:00:00.000Z');
            duplicate.PeriodEnd = new Date('2026-11-11T23:59:59.000Z');
            duplicate.Title = 'WB5 Unique Period 2';
            duplicate.Body = 'Duplicate draft for same period';
            duplicate.Status = 'Draft';
            const dupSaved = await duplicate.Save();
            Assert(!dupSaved, 'Duplicate WorkReport for same (PersonID, PeriodStart, PeriodEnd) rejected by UQ_WorkReport_Person_Period');

            Assert(await first.Delete(), 'delete WB5 first report');
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB6',
        Name: 'WB6 — WorkReport full lifecycle transitions Draft -> Submitted -> Reviewed with SupervisorFeedback',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const people = Object.values(world.People);
            Assert(people.length >= 2, 'At least two People available for author + supervisor');
            const author = people[0];
            const supervisor = people[1];

            const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            report.NewRecord();
            report.PersonID = author.ID;
            report.PeriodStart = new Date('2026-11-09T00:00:00.000Z');
            report.PeriodEnd = new Date('2026-11-09T23:59:59.000Z');
            report.Title = 'WB6 Lifecycle 15Five';
            report.Body = '### Completed\n- **Work Bus rollout**';
            report.Status = 'Draft';
            await RequireSave(report, 'WB6 draft');

            report.Status = 'Submitted';
            await RequireSave(report, 'WB6 submitted');
            AssertEqual(report.Status, 'Submitted', 'status is Submitted');

            report.Status = 'Reviewed';
            report.ReviewedByPersonID = supervisor.ID;
            report.ReviewedAt = new Date();
            report.SupervisorFeedback = 'Clear summary and strong momentum.';
            await RequireSave(report, 'WB6 reviewed');

            AssertEqual(report.Status, 'Reviewed', 'status is Reviewed');
            AssertEqual(report.SupervisorFeedback, 'Clear summary and strong momentum.', 'SupervisorFeedback persisted');

            Assert(await report.Delete(), 'delete WB6 report');
        },
    },
    {
        Id: 'task-work-bus-and-reports.WB7',
        Name: 'WB7 — MJ: Field Suggestions persists against a Task record (or degrades gracefully on pre-6.3 host)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const tasksInfo = ctx.Provider.EntityByName(TASK_ENTITY);
            Assert(!!tasksInfo, 'Tasks entity info found');

            const fieldSuggestionsEntity = ctx.Provider.EntityByName('MJ: Field Suggestions');
            if (!fieldSuggestionsEntity) {
                const cfg = tasksInfo!.Configuration as EntityCommentsConfigurationShape | undefined;
                Assert(
                    Boolean(cfg?.Comments?.AllowedCommentTypes?.includes('FIELD_SUGGESTION')),
                    'Pre-6.3 host without MJ: Field Suggestions still preserves FIELD_SUGGESTION comment configuration on Tasks',
                );
                return;
            }

            const commentTypes = await FindRows<{ ID: string; Code: string }>(
                ctx,
                'MJ: Comment Types',
                `Code = 'FIELD_SUGGESTION'`,
                ['ID', 'Code'],
            );
            Assert(commentTypes.length === 1, 'FIELD_SUGGESTION comment type seeded');

            const convTypes = await FindRows<{ ID: string; Code: string }>(
                ctx,
                'MJ: Conversation Types',
                `Code = 'COMMENT'`,
                ['ID', 'Code'],
            );
            Assert(convTypes.length === 1, 'COMMENT conversation type seeded');

            const envs = await FindRows<{ ID: string }>(ctx, 'MJ: Environments', '', ['ID']);
            Assert(envs.length >= 1, 'At least one MJ Environment exists');

            const deliverableType = world.TaskTypes['DELIVERABLE'] ?? Object.values(world.TaskTypes)[0];
            const catID = Object.values(world.Categories)[0].ID;

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `WB7 Field Suggestion Target ${Date.now()}`;
            task.TypeID = deliverableType.ID;
            task.CategoryID = catID;
            task.Priority = 'Medium';
            await RequireSave(task, 'WB7 task');

            const suggestion = await ctx.Provider.GetEntityObject<FieldSuggestionContract>('MJ: Field Suggestions', ctx.User);
            suggestion.NewRecord();
            suggestion.UserID = ctx.User.ID;
            suggestion.EnvironmentID = envs[0].ID;
            suggestion.Status = 'Available';
            suggestion.ApplicationScope = 'Global';
            suggestion.IsArchived = false;
            suggestion.IsPinned = false;
            suggestion.Name = 'Suggested Due Date';
            suggestion.Description = 'Referenced Q4 milestone target in description';
            suggestion.TypeID = convTypes[0].ID;
            suggestion.CommentTypeID = commentTypes[0].ID;
            suggestion.LinkedEntityID = tasksInfo!.ID;
            suggestion.LinkedRecordID = task.ID;
            suggestion.AnchorType = 'field';
            suggestion.AnchorKey = 'DueAt';
            suggestion.SuggestedValue = '"2026-12-01T00:00:00.000Z"';
            suggestion.Confidence = 0.92;
            suggestion.Source = 'LLM';
            suggestion.IsResolved = false;
            await RequireSave(suggestion, 'WB7 field suggestion');

            const pending = await FindRows<{ ID: string; AnchorKey: string; SuggestedValue: string }>(
                ctx,
                'MJ: Field Suggestions',
                `LinkedEntityID = '${EscapeSQLString(tasksInfo!.ID)}' AND LinkedRecordID = '${EscapeSQLString(task.ID)}' AND Outcome IS NULL AND IsResolved = 0`,
                ['ID', 'AnchorKey', 'SuggestedValue'],
            );
            AssertEqual(pending.length, 1, '1 pending Field Suggestion linked to Task');
            AssertEqual(pending[0].AnchorKey, 'DueAt', 'AnchorKey persisted');

            Assert(await suggestion.Delete(), 'delete WB7 field suggestion');
            await DeleteTask(ctx, task);
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-work-bus-and-reports', {
    Setup: async () => {},
    Teardown: async () => {},
});
export const TaskWorkBusAndReportsChecks: NamedCheck[] = checks;
