/**
 * task-chief-of-staff — the Tasks app's extension of MJ core's Chief of Staff.
 *
 * Core's Chief of Staff knows nothing about Tasks. This app adds two things to it: a skill
 * (granted to the Chief of Staff agent) that teaches it People, objectives and to-dos, and a
 * `NavItem.*` application setting that adds the "Priorities & To-dos" page to the Chief of Staff
 * application. CS1/CS2 check that both are installed and well-formed; CS3 checks the task-scope
 * filter the page and skill rely on against the real Tasks view (RootParentID and the polymorphic
 * assignee pair are what unit tests cannot see).
 */
import { Assert, AssertEqual, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { TaskEntity, mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { ResolvePersonTaskScope } from '@mj-biz-apps/tasks-core';
import { PERSON_ENTITY, TASK_ASSIGNMENT_ENTITY, TASK_ENTITY } from '../entity-names.js';
import { DeleteTask, FindRows, Quote, RequireSave, SameID, View } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const SKILL_NAME = 'Chief of Staff Tasks & Priorities';
const AGENT_NAME = 'Chief of Staff';
const APP_NAME = 'Chief of Staff';
const NAV_ITEM_SETTING = 'NavItem.bizapps-tasks.chief-of-staff';
const PAGE_DRIVER_CLASS = 'BizAppsTasksChiefOfStaffPriorities';

const checks: NamedCheck[] = [
    {
        Id: 'task-chief-of-staff.CS1',
        Name: 'CS1 — the Tasks skill is installed, active and granted to the Chief of Staff agent',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const skills = await FindRows<{ ID: string; Status: string; ActivationMode: string; Instructions: string | null }>(
                ctx, 'MJ: AI Skills', `Name = '${Quote(SKILL_NAME)}'`, ['ID', 'Status', 'ActivationMode', 'Instructions'],
            );
            AssertEqual(skills.length, 1, `exactly one '${SKILL_NAME}' skill`);
            const skill = skills[0];
            AssertEqual(skill.Status, 'Active', 'skill status');
            AssertEqual(skill.ActivationMode, 'Auto', 'skill activation mode');
            Assert((skill.Instructions ?? '').includes('MJ_BizApps_Tasks: Tasks'), 'instructions name the Tasks entity');

            const agents = await FindRows<{ ID: string; AcceptsSkills: string }>(ctx, 'MJ: AI Agents', `Name = '${Quote(AGENT_NAME)}'`, ['ID', 'AcceptsSkills']);
            AssertEqual(agents.length, 1, `the '${AGENT_NAME}' agent exists (this app needs an MJ release that ships it)`);
            Assert(agents[0].AcceptsSkills !== 'None', 'the Chief of Staff accepts skills');

            const grants = await FindRows<{ ID: string; Status: string }>(
                ctx, 'MJ: AI Agent Skills', `AgentID = '${agents[0].ID}' AND SkillID = '${skill.ID}'`, ['ID', 'Status'],
            );
            AssertEqual(grants.length, 1, 'one grant of the skill to the Chief of Staff');
            AssertEqual(grants[0].Status, 'Active', 'grant status');
        },
    },
    {
        Id: 'task-chief-of-staff.CS2',
        Name: 'CS2 — the NavItem setting adds a well-formed Priorities page to the Chief of Staff application',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const apps = await FindRows<{ ID: string }>(ctx, 'MJ: Applications', `Name = '${Quote(APP_NAME)}'`, ['ID']);
            AssertEqual(apps.length, 1, `the '${APP_NAME}' application exists`);
            const settings = await FindRows<{ ApplicationID: string | null; Value: string }>(
                ctx, 'MJ: Application Settings', `Name = '${Quote(NAV_ITEM_SETTING)}'`, ['ApplicationID', 'Value'],
            );
            AssertEqual(settings.length, 1, `exactly one '${NAV_ITEM_SETTING}' setting`);
            Assert(SameID(settings[0].ApplicationID, apps[0].ID), 'the setting is scoped to the Chief of Staff application');

            const item = JSON.parse(settings[0].Value) as { Label?: unknown; ResourceType?: unknown; DriverClass?: unknown; Sequence?: unknown; isDefault?: unknown };
            AssertEqual(item.ResourceType, 'Custom', 'ResourceType');
            AssertEqual(item.DriverClass, PAGE_DRIVER_CLASS, 'DriverClass');
            Assert(typeof item.Label === 'string' && item.Label.length > 0, 'Label');
            Assert(typeof item.Sequence === 'number', 'Sequence places the page among the core pages');
            Assert(item.isDefault === undefined, 'an extension never claims the default page');

            const coreItems = await FindRows<{ DefaultNavItems: string | null }>(ctx, 'MJ: Applications', `ID = '${apps[0].ID}'`, ['DefaultNavItems']);
            const coreLabels = (JSON.parse(coreItems[0].DefaultNavItems ?? '[]') as Array<{ Label: string }>).map((i) => i.Label);
            Assert(!coreLabels.includes(item.Label as string), 'the label does not collide with a core page');
        },
    },
    {
        Id: 'task-chief-of-staff.CS3',
        Name: 'CS3 — a person\'s task scope covers what they own or hold, and the objective above it, and nothing else',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const people = Object.values(world.People);
            Assert(people.length >= 3, 'the task world has at least three people');
            const [owner, assignee, outsider] = people;
            const peopleEntity = ctx.Provider.EntityByName(PERSON_ENTITY);
            Assert(!!peopleEntity, 'People entity');
            const typeID = world.TaskTypes['General']?.ID ?? Object.values(world.TaskTypes)[0].ID;
            const stamp = Date.now();

            const created: TaskEntity[] = [];
            const assignment = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY, ctx.User);
            try {
                const objective = await newTask(ctx, `CS3 Objective ${stamp}`, typeID, null, owner.ID);
                created.push(objective);
                const assigned = await newTask(ctx, `CS3 Assigned milestone ${stamp}`, typeID, objective.ID, owner.ID);
                created.push(assigned);
                const other = await newTask(ctx, `CS3 Other milestone ${stamp}`, typeID, objective.ID, owner.ID);
                created.push(other);

                assignment.NewRecord();
                assignment.TaskID = assigned.ID;
                assignment.AssigneeEntityID = peopleEntity!.ID;
                assignment.AssigneeRecordID = assignee.ID;
                assignment.RoleID = Object.values(world.Roles)[0].ID;
                assignment.Status = 'InProgress';
                await RequireSave(assignment, 'CS3 assignment');

                const ids = new Set(created.map((t) => t.ID.toLowerCase()));
                const scopedIDs = async (personID: string): Promise<string[]> => {
                    const scope = await ResolvePersonTaskScope(View(ctx), personID, peopleEntity!.ID, ctx.User);
                    const rows = await FindRows<{ ID: string }>(ctx, TASK_ENTITY, `(${scope.Filter})`, ['ID']);
                    return rows.map((r) => r.ID.toLowerCase()).filter((id) => ids.has(id));
                };

                // The owner created the objective: its whole tree is in scope.
                AssertEqual((await scopedIDs(owner.ID)).length, 3, 'the owner sees the objective and both milestones');
                // The assignee holds one milestone: the objective above it comes with it (via RootParentID).
                const assigneeScope = await scopedIDs(assignee.ID);
                Assert(assigneeScope.includes(objective.ID.toLowerCase()), 'the assignee sees the objective above their milestone');
                Assert(assigneeScope.includes(assigned.ID.toLowerCase()), 'the assignee sees their milestone');
                // An unrelated person sees none of it.
                AssertEqual((await scopedIDs(outsider.ID)).length, 0, 'an unrelated person sees nothing');
            } finally {
                if (assignment.IsSaved) {
                    await assignment.Delete();
                }
                for (const task of created.reverse()) {
                    await DeleteTask(ctx, task);
                }
            }
        },
    },
];

async function newTask(
    ctx: Parameters<NamedCheck['Fn']>[0],
    name: string,
    typeID: string,
    parentID: string | null,
    createdByPersonID: string,
): Promise<TaskEntity> {
    const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
    task.NewRecord();
    task.Name = name;
    task.TypeID = typeID;
    task.ParentID = parentID;
    task.Status = 'Open';
    task.Priority = 'Medium';
    task.CreatedByPersonID = createdByPersonID;
    await RequireSave(task, name);
    return task;
}

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-chief-of-staff', { Setup: async () => {}, Teardown: async () => {} });
