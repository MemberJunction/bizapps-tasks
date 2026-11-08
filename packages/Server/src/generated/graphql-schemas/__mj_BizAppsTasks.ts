/********************************************************************************
* ALL ENTITIES - TypeGraphQL Type Class Definition - AUTO GENERATED FILE
* Generated Entities and Resolvers for Server
*
*   >>> DO NOT MODIFY THIS FILE!!!!!!!!!!!!
*   >>> YOUR CHANGES WILL BE OVERWRITTEN
*   >>> THE NEXT TIME THIS FILE IS GENERATED
*
**********************************************************************************/
import { Arg, Ctx, Int, Query, Resolver, Field, Float, ObjectType, InputType, Mutation,
            PubSub, PubSubEngine, ResolverBase, RunViewByIDInput, RunViewByNameInput, RunDynamicViewInput,
            AppContext, KeyValuePairInput, DeleteOptionsInput, GraphQLTimestamp as Timestamp,
            GetReadOnlyProvider, GetReadWriteProvider, RestoreContextInput } from '@memberjunction/server';
import { Metadata, EntityPermissionType, CompositeKey, UserInfo } from '@memberjunction/core'

import { MaxLength } from 'class-validator';
import * as mj_core_schema_server_object_types from '@memberjunction/server'


import { mjBizAppsTasksTaskActivityEntity, mjBizAppsTasksTaskAgentRunEntity, mjBizAppsTasksTaskAssignmentEntity, mjBizAppsTasksTaskCategoryEntity, mjBizAppsTasksTaskCheckInEntity, mjBizAppsTasksTaskCommentEntity, mjBizAppsTasksTaskDecisionOutcomeEntity, mjBizAppsTasksTaskDecisionEntity, mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskLinkEntity, mjBizAppsTasksTaskNotificationConfigEntity, mjBizAppsTasksTaskNotificationLogEntity, mjBizAppsTasksTaskRoleEntity, mjBizAppsTasksTaskTagLinkEntity, mjBizAppsTasksTaskTagEntity, mjBizAppsTasksTaskTemplateItemDependencyEntity, mjBizAppsTasksTaskTemplateItemRoleEntity, mjBizAppsTasksTaskTemplateItemEntity, mjBizAppsTasksTaskTemplateEntity, mjBizAppsTasksTaskTimeEntryEntity, mjBizAppsTasksTaskTimeEntryLinkEntity, mjBizAppsTasksTaskTimerEntity, mjBizAppsTasksTaskTypeStatusEntity, mjBizAppsTasksTaskTypeEntity, mjBizAppsTasksTaskEntity, mjBizAppsTasksTimeApproverEntity, mjBizAppsTasksTimesheetApprovalEntity, mjBizAppsTasksTimesheetLinkEntity, mjBizAppsTasksTimesheetScheduleEntity, mjBizAppsTasksTimesheetEntity } from '@mj-biz-apps/tasks-entities';
    

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Activities
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskActivity_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    ActivityType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    PreviousValue?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    NewValue?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Activities
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskActivityInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID: string | null;

    @Field({ nullable: true })
    ActivityType?: string;

    @Field({ nullable: true })
    PreviousValue: string | null;

    @Field({ nullable: true })
    NewValue: string | null;

    @Field({ nullable: true })
    Description: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Activities
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskActivityInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID?: string | null;

    @Field({ nullable: true })
    ActivityType?: string;

    @Field({ nullable: true })
    PreviousValue?: string | null;

    @Field({ nullable: true })
    NewValue?: string | null;

    @Field({ nullable: true })
    Description?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Activities
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskActivityViewResult {
    @Field(() => [mjBizAppsTasksTaskActivity_])
    Results: mjBizAppsTasksTaskActivity_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskActivity_)
export class mjBizAppsTasksTaskActivityResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskActivityViewResult)
    async RunmjBizAppsTasksTaskActivityViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskActivityViewResult)
    async RunmjBizAppsTasksTaskActivityViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskActivityViewResult)
    async RunmjBizAppsTasksTaskActivityDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Activities';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskActivity_, { nullable: true })
    async mjBizAppsTasksTaskActivity(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskActivity_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Activities', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async CreatemjBizAppsTasksTaskActivity(
        @Arg('input', () => CreatemjBizAppsTasksTaskActivityInput) input: CreatemjBizAppsTasksTaskActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Activities', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async UpdatemjBizAppsTasksTaskActivity(
        @Arg('input', () => UpdatemjBizAppsTasksTaskActivityInput) input: UpdatemjBizAppsTasksTaskActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Activities', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async DeletemjBizAppsTasksTaskActivity(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Activities', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Agent Runs
//****************************************************************************
@ObjectType({ description: "Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time." })
export class mjBizAppsTasksTaskAgentRun_ {
    @Field({description: "Primary key for the task agent run link."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The task the AI agent run contributed to."}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true, description: "The MemberJunction AI Agent Run linked to the task."}) 
    @MaxLength(36)
    AIAgentRunID?: string;
        
    @Field({nullable: true, description: "How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged."}) 
    @MaxLength(30)
    Role?: string;
        
    @Field({nullable: true, description: "Optional notes describing what the agent run did for the task."}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    AIAgentRun?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Agent Runs
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskAgentRunInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AIAgentRunID?: string;

    @Field({ nullable: true })
    Role?: string;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Agent Runs
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskAgentRunInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AIAgentRunID?: string;

    @Field({ nullable: true })
    Role?: string;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Agent Runs
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskAgentRunViewResult {
    @Field(() => [mjBizAppsTasksTaskAgentRun_])
    Results: mjBizAppsTasksTaskAgentRun_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskAgentRun_)
export class mjBizAppsTasksTaskAgentRunResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskAgentRunViewResult)
    async RunmjBizAppsTasksTaskAgentRunViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskAgentRunViewResult)
    async RunmjBizAppsTasksTaskAgentRunViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskAgentRunViewResult)
    async RunmjBizAppsTasksTaskAgentRunDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Agent Runs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskAgentRun_, { nullable: true })
    async mjBizAppsTasksTaskAgentRun(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskAgentRun_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Agent Runs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAgentRuns')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Agent Runs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Agent Runs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskAgentRun_)
    async CreatemjBizAppsTasksTaskAgentRun(
        @Arg('input', () => CreatemjBizAppsTasksTaskAgentRunInput) input: CreatemjBizAppsTasksTaskAgentRunInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Agent Runs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskAgentRun_)
    async UpdatemjBizAppsTasksTaskAgentRun(
        @Arg('input', () => UpdatemjBizAppsTasksTaskAgentRunInput) input: UpdatemjBizAppsTasksTaskAgentRunInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Agent Runs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskAgentRun_)
    async DeletemjBizAppsTasksTaskAgentRun(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Agent Runs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Assignments
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskAssignment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    AssigneeEntityID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(450)
    AssigneeRecordID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RoleID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    RoleNotes?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    Status?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    AssignedByPersonID?: string;
        
    @Field({nullable: true}) 
    AssignedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    AssigneeEntity?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Role?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    AssignedByPerson?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Assignments
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskAssignmentInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AssigneeEntityID?: string;

    @Field({ nullable: true })
    AssigneeRecordID?: string;

    @Field({ nullable: true })
    RoleID: string | null;

    @Field({ nullable: true })
    RoleNotes: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AssignedByPersonID: string | null;

    @Field({ nullable: true })
    AssignedAt?: Date;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Assignments
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskAssignmentInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AssigneeEntityID?: string;

    @Field({ nullable: true })
    AssigneeRecordID?: string;

    @Field({ nullable: true })
    RoleID?: string | null;

    @Field({ nullable: true })
    RoleNotes?: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AssignedByPersonID?: string | null;

    @Field({ nullable: true })
    AssignedAt?: Date;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Assignments
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskAssignmentViewResult {
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    Results: mjBizAppsTasksTaskAssignment_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskAssignment_)
export class mjBizAppsTasksTaskAssignmentResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskAssignmentViewResult)
    async RunmjBizAppsTasksTaskAssignmentViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskAssignmentViewResult)
    async RunmjBizAppsTasksTaskAssignmentViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskAssignmentViewResult)
    async RunmjBizAppsTasksTaskAssignmentDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Assignments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskAssignment_, { nullable: true })
    async mjBizAppsTasksTaskAssignment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskAssignment_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Assignments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async CreatemjBizAppsTasksTaskAssignment(
        @Arg('input', () => CreatemjBizAppsTasksTaskAssignmentInput) input: CreatemjBizAppsTasksTaskAssignmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Assignments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async UpdatemjBizAppsTasksTaskAssignment(
        @Arg('input', () => UpdatemjBizAppsTasksTaskAssignmentInput) input: UpdatemjBizAppsTasksTaskAssignmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Assignments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async DeletemjBizAppsTasksTaskAssignment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Assignments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Categories
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskCategory_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ColorCode?: string;
        
    @Field(() => Int, {nullable: true}) 
    Sequence?: number;
        
    @Field(() => Boolean, {nullable: true}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Parent?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => Int, {nullable: true}) 
    ParentIDDepth?: number;
        
    @Field({nullable: true}) 
    ParentIDPath?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    ParentIDIsLeaf?: boolean;
        
    @Field(() => Int, {nullable: true}) 
    ParentIDChildCount?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Categories
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskCategoryInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    ParentID: string | null;

    @Field({ nullable: true })
    ColorCode: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Categories
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskCategoryInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    ParentID?: string | null;

    @Field({ nullable: true })
    ColorCode?: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Categories
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskCategoryViewResult {
    @Field(() => [mjBizAppsTasksTaskCategory_])
    Results: mjBizAppsTasksTaskCategory_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskCategory_)
export class mjBizAppsTasksTaskCategoryResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskCategoryViewResult)
    async RunmjBizAppsTasksTaskCategoryViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCategoryViewResult)
    async RunmjBizAppsTasksTaskCategoryViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCategoryViewResult)
    async RunmjBizAppsTasksTaskCategoryDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Categories';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskCategory_, { nullable: true })
    async mjBizAppsTasksTaskCategory(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskCategory_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Categories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCategories')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Categories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Categories', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async CreatemjBizAppsTasksTaskCategory(
        @Arg('input', () => CreatemjBizAppsTasksTaskCategoryInput) input: CreatemjBizAppsTasksTaskCategoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Categories', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async UpdatemjBizAppsTasksTaskCategory(
        @Arg('input', () => UpdatemjBizAppsTasksTaskCategoryInput) input: UpdatemjBizAppsTasksTaskCategoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Categories', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async DeletemjBizAppsTasksTaskCategory(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Categories', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Check Ins
//****************************************************************************
@ObjectType({ description: "Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff." })
export class mjBizAppsTasksTaskCheckIn_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The task, priority objective, or key result this check-in updates."}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true, description: "Optional Person record who authored or approved the check-in."}) 
    @MaxLength(36)
    AuthorPersonID?: string;
        
    @Field({nullable: true, description: "Optional MemberJunction User who authored or submitted the check-in."}) 
    @MaxLength(36)
    AuthorUserID?: string;
        
    @Field({nullable: true, description: "Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in."}) 
    @MaxLength(36)
    ReportedByAIAgentID?: string;
        
    @Field({nullable: true, description: "Timestamp when the check-in occurred."}) 
    CheckInAt?: Date;
        
    @Field({nullable: true, description: "Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused."}) 
    @MaxLength(20)
    HealthStatus?: string;
        
    @Field(() => Int, {nullable: true, description: "Confidence score (0-100) reported at the time of check-in."}) 
    ConfidenceScore?: number;
        
    @Field(() => Float, {nullable: true, description: "Metric value prior to this check-in."}) 
    PreviousValue?: number;
        
    @Field(() => Float, {nullable: true, description: "Updated metric value reported in this check-in."}) 
    NewValue?: number;
        
    @Field(() => Int, {nullable: true, description: "Percent complete (0-100) reported or computed in this check-in."}) 
    PercentComplete?: number;
        
    @Field({nullable: true, description: "Narrative summary of accomplishments and status since the last check-in."}) 
    Summary?: string;
        
    @Field({nullable: true, description: "Risks, impediments, or cross-team blockers surfaced during the check-in."}) 
    Blockers?: string;
        
    @Field({nullable: true, description: "Planned next steps and commitments before the next check-in."}) 
    NextSteps?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    AuthorPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    AuthorUser?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ReportedByAIAgent?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Check Ins
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskCheckInInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AuthorPersonID: string | null;

    @Field({ nullable: true })
    AuthorUserID: string | null;

    @Field({ nullable: true })
    ReportedByAIAgentID: string | null;

    @Field({ nullable: true })
    CheckInAt?: Date;

    @Field({ nullable: true })
    HealthStatus?: string;

    @Field(() => Int, { nullable: true })
    ConfidenceScore: number | null;

    @Field(() => Float, { nullable: true })
    PreviousValue: number | null;

    @Field(() => Float, { nullable: true })
    NewValue: number | null;

    @Field(() => Int, { nullable: true })
    PercentComplete: number | null;

    @Field({ nullable: true })
    Summary?: string;

    @Field({ nullable: true })
    Blockers: string | null;

    @Field({ nullable: true })
    NextSteps: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Check Ins
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskCheckInInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    AuthorPersonID?: string | null;

    @Field({ nullable: true })
    AuthorUserID?: string | null;

    @Field({ nullable: true })
    ReportedByAIAgentID?: string | null;

    @Field({ nullable: true })
    CheckInAt?: Date;

    @Field({ nullable: true })
    HealthStatus?: string;

    @Field(() => Int, { nullable: true })
    ConfidenceScore?: number | null;

    @Field(() => Float, { nullable: true })
    PreviousValue?: number | null;

    @Field(() => Float, { nullable: true })
    NewValue?: number | null;

    @Field(() => Int, { nullable: true })
    PercentComplete?: number | null;

    @Field({ nullable: true })
    Summary?: string;

    @Field({ nullable: true })
    Blockers?: string | null;

    @Field({ nullable: true })
    NextSteps?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Check Ins
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskCheckInViewResult {
    @Field(() => [mjBizAppsTasksTaskCheckIn_])
    Results: mjBizAppsTasksTaskCheckIn_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskCheckIn_)
export class mjBizAppsTasksTaskCheckInResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskCheckInViewResult)
    async RunmjBizAppsTasksTaskCheckInViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCheckInViewResult)
    async RunmjBizAppsTasksTaskCheckInViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCheckInViewResult)
    async RunmjBizAppsTasksTaskCheckInDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Check Ins';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskCheckIn_, { nullable: true })
    async mjBizAppsTasksTaskCheckIn(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskCheckIn_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Check Ins', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCheckIns')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Check Ins', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Check Ins', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskCheckIn_)
    async CreatemjBizAppsTasksTaskCheckIn(
        @Arg('input', () => CreatemjBizAppsTasksTaskCheckInInput) input: CreatemjBizAppsTasksTaskCheckInInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Check Ins', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskCheckIn_)
    async UpdatemjBizAppsTasksTaskCheckIn(
        @Arg('input', () => UpdatemjBizAppsTasksTaskCheckInInput) input: UpdatemjBizAppsTasksTaskCheckInInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Check Ins', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskCheckIn_)
    async DeletemjBizAppsTasksTaskCheckIn(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Check Ins', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Comments
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskComment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true}) 
    Content?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    IsEdited?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => Int, {nullable: true}) 
    ParentIDDepth?: number;
        
    @Field({nullable: true}) 
    ParentIDPath?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    ParentIDIsLeaf?: boolean;
        
    @Field(() => Int, {nullable: true}) 
    ParentIDChildCount?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Comments
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskCommentInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    ParentID: string | null;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    Content?: string;

    @Field(() => Boolean, { nullable: true })
    IsEdited?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Comments
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskCommentInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    ParentID?: string | null;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    Content?: string;

    @Field(() => Boolean, { nullable: true })
    IsEdited?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Comments
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskCommentViewResult {
    @Field(() => [mjBizAppsTasksTaskComment_])
    Results: mjBizAppsTasksTaskComment_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskComment_)
export class mjBizAppsTasksTaskCommentResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskCommentViewResult)
    async RunmjBizAppsTasksTaskCommentViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCommentViewResult)
    async RunmjBizAppsTasksTaskCommentViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskCommentViewResult)
    async RunmjBizAppsTasksTaskCommentDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Comments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskComment_, { nullable: true })
    async mjBizAppsTasksTaskComment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskComment_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Comments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async CreatemjBizAppsTasksTaskComment(
        @Arg('input', () => CreatemjBizAppsTasksTaskCommentInput) input: CreatemjBizAppsTasksTaskCommentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Comments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async UpdatemjBizAppsTasksTaskComment(
        @Arg('input', () => UpdatemjBizAppsTasksTaskCommentInput) input: UpdatemjBizAppsTasksTaskCommentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Comments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async DeletemjBizAppsTasksTaskComment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Comments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Decision Outcomes
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskDecisionOutcome_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions)."}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true, description: "Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions)."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field(() => Int, {nullable: true, description: "Display ordering for the outcome in decision pickers."}) 
    Sequence?: number;
        
    @Field(() => Boolean, {nullable: true, description: "When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open."}) 
    IsTerminal?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: "When 0, the outcome is hidden from new decision pickers but preserved on historical decisions."}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Decision Outcomes
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskDecisionOutcomeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsTerminal?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Decision Outcomes
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskDecisionOutcomeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsTerminal?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Decision Outcomes
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskDecisionOutcomeViewResult {
    @Field(() => [mjBizAppsTasksTaskDecisionOutcome_])
    Results: mjBizAppsTasksTaskDecisionOutcome_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskDecisionOutcome_)
export class mjBizAppsTasksTaskDecisionOutcomeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskDecisionOutcomeViewResult)
    async RunmjBizAppsTasksTaskDecisionOutcomeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDecisionOutcomeViewResult)
    async RunmjBizAppsTasksTaskDecisionOutcomeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDecisionOutcomeViewResult)
    async RunmjBizAppsTasksTaskDecisionOutcomeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Decision Outcomes';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskDecisionOutcome_, { nullable: true })
    async mjBizAppsTasksTaskDecisionOutcome(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskDecisionOutcome_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Decision Outcomes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDecisionOutcomes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Decision Outcomes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Decision Outcomes', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskDecisionOutcome_)
    async CreatemjBizAppsTasksTaskDecisionOutcome(
        @Arg('input', () => CreatemjBizAppsTasksTaskDecisionOutcomeInput) input: CreatemjBizAppsTasksTaskDecisionOutcomeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Decision Outcomes', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskDecisionOutcome_)
    async UpdatemjBizAppsTasksTaskDecisionOutcome(
        @Arg('input', () => UpdatemjBizAppsTasksTaskDecisionOutcomeInput) input: UpdatemjBizAppsTasksTaskDecisionOutcomeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Decision Outcomes', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskDecisionOutcome_)
    async DeletemjBizAppsTasksTaskDecisionOutcome(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Decision Outcomes', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Decisions
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskDecision_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The task this decision was recorded against."}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true, description: "The decision outcome (FK to TaskDecisionOutcome)."}) 
    @MaxLength(36)
    OutcomeID?: string;
        
    @Field({nullable: true, description: "The Person who made the decision."}) 
    @MaxLength(36)
    DecidedByPersonID?: string;
        
    @Field({nullable: true, description: "When the decision was recorded."}) 
    DecidedAt?: Date;
        
    @Field({nullable: true, description: "Free-text rationale or conditions attached to the decision."}) 
    DecisionNotes?: string;
        
    @Field({nullable: true, description: "Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision."}) 
    @MaxLength(36)
    TaskAssignmentID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Outcome?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    DecidedByPerson?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Decisions
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskDecisionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    OutcomeID?: string;

    @Field({ nullable: true })
    DecidedByPersonID: string | null;

    @Field({ nullable: true })
    DecidedAt?: Date;

    @Field({ nullable: true })
    DecisionNotes: string | null;

    @Field({ nullable: true })
    TaskAssignmentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Decisions
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskDecisionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    OutcomeID?: string;

    @Field({ nullable: true })
    DecidedByPersonID?: string | null;

    @Field({ nullable: true })
    DecidedAt?: Date;

    @Field({ nullable: true })
    DecisionNotes?: string | null;

    @Field({ nullable: true })
    TaskAssignmentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Decisions
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskDecisionViewResult {
    @Field(() => [mjBizAppsTasksTaskDecision_])
    Results: mjBizAppsTasksTaskDecision_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskDecision_)
export class mjBizAppsTasksTaskDecisionResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskDecisionViewResult)
    async RunmjBizAppsTasksTaskDecisionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDecisionViewResult)
    async RunmjBizAppsTasksTaskDecisionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDecisionViewResult)
    async RunmjBizAppsTasksTaskDecisionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Decisions';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskDecision_, { nullable: true })
    async mjBizAppsTasksTaskDecision(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskDecision_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Decisions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDecisions')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Decisions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Decisions', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskDecision_)
    async CreatemjBizAppsTasksTaskDecision(
        @Arg('input', () => CreatemjBizAppsTasksTaskDecisionInput) input: CreatemjBizAppsTasksTaskDecisionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Decisions', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskDecision_)
    async UpdatemjBizAppsTasksTaskDecision(
        @Arg('input', () => UpdatemjBizAppsTasksTaskDecisionInput) input: UpdatemjBizAppsTasksTaskDecisionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Decisions', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskDecision_)
    async DeletemjBizAppsTasksTaskDecision(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Decisions', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Dependencies
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskDependency_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    DependsOnTaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    DependencyType?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    DependsOnTask?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Dependencies
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskDependencyInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    DependsOnTaskID?: string;

    @Field({ nullable: true })
    DependencyType?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Dependencies
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskDependencyInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    DependsOnTaskID?: string;

    @Field({ nullable: true })
    DependencyType?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Dependencies
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskDependencyViewResult {
    @Field(() => [mjBizAppsTasksTaskDependency_])
    Results: mjBizAppsTasksTaskDependency_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskDependency_)
export class mjBizAppsTasksTaskDependencyResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskDependencyViewResult)
    async RunmjBizAppsTasksTaskDependencyViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDependencyViewResult)
    async RunmjBizAppsTasksTaskDependencyViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskDependencyViewResult)
    async RunmjBizAppsTasksTaskDependencyDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Dependencies';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskDependency_, { nullable: true })
    async mjBizAppsTasksTaskDependency(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskDependency_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Dependencies', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async CreatemjBizAppsTasksTaskDependency(
        @Arg('input', () => CreatemjBizAppsTasksTaskDependencyInput) input: CreatemjBizAppsTasksTaskDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Dependencies', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async UpdatemjBizAppsTasksTaskDependency(
        @Arg('input', () => UpdatemjBizAppsTasksTaskDependencyInput) input: UpdatemjBizAppsTasksTaskDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Dependencies', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async DeletemjBizAppsTasksTaskDependency(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Dependencies', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Links
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskLink_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    EntityID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(450)
    RecordID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Entity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskLinkViewResult {
    @Field(() => [mjBizAppsTasksTaskLink_])
    Results: mjBizAppsTasksTaskLink_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskLink_)
export class mjBizAppsTasksTaskLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskLinkViewResult)
    async RunmjBizAppsTasksTaskLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskLinkViewResult)
    async RunmjBizAppsTasksTaskLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskLinkViewResult)
    async RunmjBizAppsTasksTaskLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskLink_, { nullable: true })
    async mjBizAppsTasksTaskLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskLink_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskLinks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async CreatemjBizAppsTasksTaskLink(
        @Arg('input', () => CreatemjBizAppsTasksTaskLinkInput) input: CreatemjBizAppsTasksTaskLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async UpdatemjBizAppsTasksTaskLink(
        @Arg('input', () => UpdatemjBizAppsTasksTaskLinkInput) input: UpdatemjBizAppsTasksTaskLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async DeletemjBizAppsTasksTaskLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Notification Configs
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskNotificationConfig_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskTypeID?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    OverdueNotificationsEnabled?: boolean;
        
    @Field(() => Int, {nullable: true}) 
    OverdueGracePeriodHours?: number;
        
    @Field(() => Int, {nullable: true}) 
    OverdueRepeatIntervalHours?: number;
        
    @Field(() => Boolean, {nullable: true}) 
    NotifyAssignees?: boolean;
        
    @Field(() => Boolean, {nullable: true}) 
    NotifyCreator?: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OverdueActionID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    TaskType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OverdueAction?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Notification Configs
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskNotificationConfigInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskTypeID: string | null;

    @Field(() => Boolean, { nullable: true })
    OverdueNotificationsEnabled?: boolean;

    @Field(() => Int, { nullable: true })
    OverdueGracePeriodHours?: number;

    @Field(() => Int, { nullable: true })
    OverdueRepeatIntervalHours: number | null;

    @Field(() => Boolean, { nullable: true })
    NotifyAssignees?: boolean;

    @Field(() => Boolean, { nullable: true })
    NotifyCreator?: boolean;

    @Field({ nullable: true })
    OverdueActionID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Notification Configs
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskNotificationConfigInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskTypeID?: string | null;

    @Field(() => Boolean, { nullable: true })
    OverdueNotificationsEnabled?: boolean;

    @Field(() => Int, { nullable: true })
    OverdueGracePeriodHours?: number;

    @Field(() => Int, { nullable: true })
    OverdueRepeatIntervalHours?: number | null;

    @Field(() => Boolean, { nullable: true })
    NotifyAssignees?: boolean;

    @Field(() => Boolean, { nullable: true })
    NotifyCreator?: boolean;

    @Field({ nullable: true })
    OverdueActionID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Notification Configs
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskNotificationConfigViewResult {
    @Field(() => [mjBizAppsTasksTaskNotificationConfig_])
    Results: mjBizAppsTasksTaskNotificationConfig_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskNotificationConfig_)
export class mjBizAppsTasksTaskNotificationConfigResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskNotificationConfigViewResult)
    async RunmjBizAppsTasksTaskNotificationConfigViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskNotificationConfigViewResult)
    async RunmjBizAppsTasksTaskNotificationConfigViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskNotificationConfigViewResult)
    async RunmjBizAppsTasksTaskNotificationConfigDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Notification Configs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskNotificationConfig_, { nullable: true })
    async mjBizAppsTasksTaskNotificationConfig(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskNotificationConfig_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Notification Configs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationConfigs')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Configs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Notification Configs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskNotificationConfig_)
    async CreatemjBizAppsTasksTaskNotificationConfig(
        @Arg('input', () => CreatemjBizAppsTasksTaskNotificationConfigInput) input: CreatemjBizAppsTasksTaskNotificationConfigInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Notification Configs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskNotificationConfig_)
    async UpdatemjBizAppsTasksTaskNotificationConfig(
        @Arg('input', () => UpdatemjBizAppsTasksTaskNotificationConfigInput) input: UpdatemjBizAppsTasksTaskNotificationConfigInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Notification Configs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskNotificationConfig_)
    async DeletemjBizAppsTasksTaskNotificationConfig(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Notification Configs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Notification Logs
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskNotificationLog_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    NotificationType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    NotifiedUserID?: string;
        
    @Field({nullable: true}) 
    NotifiedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    NotifiedUser?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Notification Logs
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskNotificationLogInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    NotificationType?: string;

    @Field({ nullable: true })
    NotifiedUserID?: string;

    @Field({ nullable: true })
    NotifiedAt?: Date;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Notification Logs
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskNotificationLogInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    NotificationType?: string;

    @Field({ nullable: true })
    NotifiedUserID?: string;

    @Field({ nullable: true })
    NotifiedAt?: Date;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Notification Logs
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskNotificationLogViewResult {
    @Field(() => [mjBizAppsTasksTaskNotificationLog_])
    Results: mjBizAppsTasksTaskNotificationLog_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskNotificationLog_)
export class mjBizAppsTasksTaskNotificationLogResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskNotificationLogViewResult)
    async RunmjBizAppsTasksTaskNotificationLogViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskNotificationLogViewResult)
    async RunmjBizAppsTasksTaskNotificationLogViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskNotificationLogViewResult)
    async RunmjBizAppsTasksTaskNotificationLogDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Notification Logs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskNotificationLog_, { nullable: true })
    async mjBizAppsTasksTaskNotificationLog(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskNotificationLog_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Notification Logs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationLogs')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Logs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Notification Logs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskNotificationLog_)
    async CreatemjBizAppsTasksTaskNotificationLog(
        @Arg('input', () => CreatemjBizAppsTasksTaskNotificationLogInput) input: CreatemjBizAppsTasksTaskNotificationLogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Notification Logs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskNotificationLog_)
    async UpdatemjBizAppsTasksTaskNotificationLog(
        @Arg('input', () => UpdatemjBizAppsTasksTaskNotificationLogInput) input: UpdatemjBizAppsTasksTaskNotificationLogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Notification Logs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskNotificationLog_)
    async DeletemjBizAppsTasksTaskNotificationLog(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Notification Logs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Roles
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskRole_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field(() => Int, {nullable: true}) 
    Sequence?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Roles
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskRoleInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Roles
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskRoleInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Roles
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskRoleViewResult {
    @Field(() => [mjBizAppsTasksTaskRole_])
    Results: mjBizAppsTasksTaskRole_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskRole_)
export class mjBizAppsTasksTaskRoleResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskRoleViewResult)
    async RunmjBizAppsTasksTaskRoleViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskRoleViewResult)
    async RunmjBizAppsTasksTaskRoleViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskRoleViewResult)
    async RunmjBizAppsTasksTaskRoleDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Roles';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskRole_, { nullable: true })
    async mjBizAppsTasksTaskRole(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskRole_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskRoles')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Roles', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async CreatemjBizAppsTasksTaskRole(
        @Arg('input', () => CreatemjBizAppsTasksTaskRoleInput) input: CreatemjBizAppsTasksTaskRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Roles', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async UpdatemjBizAppsTasksTaskRole(
        @Arg('input', () => UpdatemjBizAppsTasksTaskRoleInput) input: UpdatemjBizAppsTasksTaskRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Roles', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async DeletemjBizAppsTasksTaskRole(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Roles', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Tag Links
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTagLink_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TagID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Tag?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Tag Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTagLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    TagID?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Tag Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTagLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    TagID?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Tag Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTagLinkViewResult {
    @Field(() => [mjBizAppsTasksTaskTagLink_])
    Results: mjBizAppsTasksTaskTagLink_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTagLink_)
export class mjBizAppsTasksTaskTagLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTagLinkViewResult)
    async RunmjBizAppsTasksTaskTagLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTagLinkViewResult)
    async RunmjBizAppsTasksTaskTagLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTagLinkViewResult)
    async RunmjBizAppsTasksTaskTagLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Tag Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTagLink_, { nullable: true })
    async mjBizAppsTasksTaskTagLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTagLink_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Tag Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async CreatemjBizAppsTasksTaskTagLink(
        @Arg('input', () => CreatemjBizAppsTasksTaskTagLinkInput) input: CreatemjBizAppsTasksTaskTagLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Tag Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async UpdatemjBizAppsTasksTaskTagLink(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTagLinkInput) input: UpdatemjBizAppsTasksTaskTagLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Tag Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async DeletemjBizAppsTasksTaskTagLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Tag Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Tags
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTag_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ColorCode?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Tags
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTagInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    ColorCode: string | null;

    @Field({ nullable: true })
    Description: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Tags
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTagInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    ColorCode?: string | null;

    @Field({ nullable: true })
    Description?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Tags
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTagViewResult {
    @Field(() => [mjBizAppsTasksTaskTag_])
    Results: mjBizAppsTasksTaskTag_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTag_)
export class mjBizAppsTasksTaskTagResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTagViewResult)
    async RunmjBizAppsTasksTaskTagViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTagViewResult)
    async RunmjBizAppsTasksTaskTagViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTagViewResult)
    async RunmjBizAppsTasksTaskTagDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Tags';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTag_, { nullable: true })
    async mjBizAppsTasksTaskTag(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTag_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Tags', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTags')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tags', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Tags', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async CreatemjBizAppsTasksTaskTag(
        @Arg('input', () => CreatemjBizAppsTasksTaskTagInput) input: CreatemjBizAppsTasksTaskTagInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Tags', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async UpdatemjBizAppsTasksTaskTag(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTagInput) input: UpdatemjBizAppsTasksTaskTagInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Tags', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async DeletemjBizAppsTasksTaskTag(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Tags', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Template Item Dependencies
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTemplateItemDependency_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ItemID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    DependsOnItemID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    DependencyType?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Item?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    DependsOnItem?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Item Dependencies
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTemplateItemDependencyInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ItemID?: string;

    @Field({ nullable: true })
    DependsOnItemID?: string;

    @Field({ nullable: true })
    DependencyType?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Item Dependencies
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTemplateItemDependencyInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ItemID?: string;

    @Field({ nullable: true })
    DependsOnItemID?: string;

    @Field({ nullable: true })
    DependencyType?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Template Item Dependencies
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTemplateItemDependencyViewResult {
    @Field(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    Results: mjBizAppsTasksTaskTemplateItemDependency_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTemplateItemDependency_)
export class mjBizAppsTasksTaskTemplateItemDependencyResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTemplateItemDependencyViewResult)
    async RunmjBizAppsTasksTaskTemplateItemDependencyViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemDependencyViewResult)
    async RunmjBizAppsTasksTaskTemplateItemDependencyViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemDependencyViewResult)
    async RunmjBizAppsTasksTaskTemplateItemDependencyDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Template Item Dependencies';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItemDependency_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItemDependency(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItemDependency_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Dependencies', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async CreatemjBizAppsTasksTaskTemplateItemDependency(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemDependencyInput) input: CreatemjBizAppsTasksTaskTemplateItemDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Template Item Dependencies', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async UpdatemjBizAppsTasksTaskTemplateItemDependency(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemDependencyInput) input: UpdatemjBizAppsTasksTaskTemplateItemDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Template Item Dependencies', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async DeletemjBizAppsTasksTaskTemplateItemDependency(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Template Item Dependencies', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Template Item Roles
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTemplateItemRole_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ItemID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RoleID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Item?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Role?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Item Roles
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTemplateItemRoleInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ItemID?: string;

    @Field({ nullable: true })
    RoleID?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Item Roles
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTemplateItemRoleInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ItemID?: string;

    @Field({ nullable: true })
    RoleID?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Template Item Roles
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTemplateItemRoleViewResult {
    @Field(() => [mjBizAppsTasksTaskTemplateItemRole_])
    Results: mjBizAppsTasksTaskTemplateItemRole_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTemplateItemRole_)
export class mjBizAppsTasksTaskTemplateItemRoleResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTemplateItemRoleViewResult)
    async RunmjBizAppsTasksTaskTemplateItemRoleViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemRoleViewResult)
    async RunmjBizAppsTasksTaskTemplateItemRoleViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemRoleViewResult)
    async RunmjBizAppsTasksTaskTemplateItemRoleDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Template Item Roles';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItemRole_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItemRole(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItemRole_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Roles', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async CreatemjBizAppsTasksTaskTemplateItemRole(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemRoleInput) input: CreatemjBizAppsTasksTaskTemplateItemRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Template Item Roles', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async UpdatemjBizAppsTasksTaskTemplateItemRole(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemRoleInput) input: UpdatemjBizAppsTasksTaskTemplateItemRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Template Item Roles', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async DeletemjBizAppsTasksTaskTemplateItemRole(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Template Item Roles', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Template Items
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTemplateItem_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TemplateID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentItemID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    Priority?: string;
        
    @Field(() => Int, {nullable: true}) 
    DaysFromStart?: number;
        
    @Field(() => Float, {nullable: true}) 
    HoursEstimated?: number;
        
    @Field(() => Int, {nullable: true}) 
    Sequence?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Template?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ParentItem?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentItemID?: string;
        
    @Field(() => Int, {nullable: true}) 
    ParentItemIDDepth?: number;
        
    @Field({nullable: true}) 
    ParentItemIDPath?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    ParentItemIDIsLeaf?: boolean;
        
    @Field(() => Int, {nullable: true}) 
    ParentItemIDChildCount?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Items
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTemplateItemInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TemplateID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    ParentItemID: string | null;

    @Field({ nullable: true })
    Priority?: string;

    @Field(() => Int, { nullable: true })
    DaysFromStart: number | null;

    @Field(() => Float, { nullable: true })
    HoursEstimated: number | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Template Items
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTemplateItemInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TemplateID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    ParentItemID?: string | null;

    @Field({ nullable: true })
    Priority?: string;

    @Field(() => Int, { nullable: true })
    DaysFromStart?: number | null;

    @Field(() => Float, { nullable: true })
    HoursEstimated?: number | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Template Items
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTemplateItemViewResult {
    @Field(() => [mjBizAppsTasksTaskTemplateItem_])
    Results: mjBizAppsTasksTaskTemplateItem_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTemplateItem_)
export class mjBizAppsTasksTaskTemplateItemResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTemplateItemViewResult)
    async RunmjBizAppsTasksTaskTemplateItemViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemViewResult)
    async RunmjBizAppsTasksTaskTemplateItemViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateItemViewResult)
    async RunmjBizAppsTasksTaskTemplateItemDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Template Items';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItem_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItem(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItem_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Items', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async CreatemjBizAppsTasksTaskTemplateItem(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemInput) input: CreatemjBizAppsTasksTaskTemplateItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Template Items', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async UpdatemjBizAppsTasksTaskTemplateItem(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemInput) input: UpdatemjBizAppsTasksTaskTemplateItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Template Items', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async DeletemjBizAppsTasksTaskTemplateItem(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Template Items', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Templates
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskTemplate_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CategoryID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Category?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Type?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Templates
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTemplateInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    CategoryID: string | null;

    @Field({ nullable: true })
    TypeID: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Templates
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTemplateInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    CategoryID?: string | null;

    @Field({ nullable: true })
    TypeID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Templates
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTemplateViewResult {
    @Field(() => [mjBizAppsTasksTaskTemplate_])
    Results: mjBizAppsTasksTaskTemplate_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTemplate_)
export class mjBizAppsTasksTaskTemplateResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTemplateViewResult)
    async RunmjBizAppsTasksTaskTemplateViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateViewResult)
    async RunmjBizAppsTasksTaskTemplateViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTemplateViewResult)
    async RunmjBizAppsTasksTaskTemplateDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Templates';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplate_, { nullable: true })
    async mjBizAppsTasksTaskTemplate(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplate_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Templates', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async CreatemjBizAppsTasksTaskTemplate(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateInput) input: CreatemjBizAppsTasksTaskTemplateInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Templates', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async UpdatemjBizAppsTasksTaskTemplate(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateInput) input: UpdatemjBizAppsTasksTaskTemplateInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Templates', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async DeletemjBizAppsTasksTaskTemplate(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Templates', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Time Entries
//****************************************************************************
@ObjectType({ description: "Individual time entries logged by a person against a task on a specific business calendar date." })
export class mjBizAppsTasksTaskTimeEntry_ {
    @Field({description: "Primary key for the task time entry."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The task this time entry is logged against."}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true, description: "The Person who performed the work."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "Business calendar date the work was performed on."}) 
    WorkDate?: Date;
        
    @Field(() => Int, {nullable: true, description: "Duration of work in whole minutes (1 to 1440)."}) 
    Minutes?: number;
        
    @Field({nullable: true, description: "Optional timestamp when the work interval started (populated for timer-backed entries)."}) 
    StartedAt?: Date;
        
    @Field({nullable: true, description: "Optional timestamp when the work interval ended (populated for timer-backed entries)."}) 
    EndedAt?: Date;
        
    @Field({nullable: true, description: "Narrative description of what was accomplished during this time entry."}) 
    Notes?: string;
        
    @Field({nullable: true, description: "How the time entry was created: Manual, Timer, Imported, or Agent."}) 
    @MaxLength(20)
    Source?: string;
        
    @Field(() => Boolean, {nullable: true, description: "Whether this time entry is billable to a client or external party."}) 
    IsBillable?: boolean;
        
    @Field({nullable: true, description: "Optional Timesheet this time entry has been attached to."}) 
    @MaxLength(36)
    TimesheetID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Time Entries
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTimeEntryInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    WorkDate?: Date;

    @Field(() => Int, { nullable: true })
    Minutes?: number;

    @Field({ nullable: true })
    StartedAt: Date | null;

    @Field({ nullable: true })
    EndedAt: Date | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field({ nullable: true })
    Source?: string;

    @Field(() => Boolean, { nullable: true })
    IsBillable?: boolean;

    @Field({ nullable: true })
    TimesheetID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Time Entries
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTimeEntryInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    WorkDate?: Date;

    @Field(() => Int, { nullable: true })
    Minutes?: number;

    @Field({ nullable: true })
    StartedAt?: Date | null;

    @Field({ nullable: true })
    EndedAt?: Date | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field({ nullable: true })
    Source?: string;

    @Field(() => Boolean, { nullable: true })
    IsBillable?: boolean;

    @Field({ nullable: true })
    TimesheetID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Time Entries
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTimeEntryViewResult {
    @Field(() => [mjBizAppsTasksTaskTimeEntry_])
    Results: mjBizAppsTasksTaskTimeEntry_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTimeEntry_)
export class mjBizAppsTasksTaskTimeEntryResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTimeEntryViewResult)
    async RunmjBizAppsTasksTaskTimeEntryViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimeEntryViewResult)
    async RunmjBizAppsTasksTaskTimeEntryViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimeEntryViewResult)
    async RunmjBizAppsTasksTaskTimeEntryDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Time Entries';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTimeEntry_, { nullable: true })
    async mjBizAppsTasksTaskTimeEntry(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTimeEntry_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Time Entries', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTimeEntries')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Time Entries', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Time Entries', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimeEntry_)
    async CreatemjBizAppsTasksTaskTimeEntry(
        @Arg('input', () => CreatemjBizAppsTasksTaskTimeEntryInput) input: CreatemjBizAppsTasksTaskTimeEntryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Time Entries', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTimeEntry_)
    async UpdatemjBizAppsTasksTaskTimeEntry(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTimeEntryInput) input: UpdatemjBizAppsTasksTaskTimeEntryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Time Entries', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimeEntry_)
    async DeletemjBizAppsTasksTaskTimeEntry(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Time Entries', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Time Entry Links
//****************************************************************************
@ObjectType({ description: "Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests." })
export class mjBizAppsTasksTaskTimeEntryLink_ {
    @Field({description: "Primary key for the task time entry link."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The TaskTimeEntry being linked."}) 
    @MaxLength(36)
    TaskTimeEntryID?: string;
        
    @Field({nullable: true, description: "Target MemberJunction Entity ID for the linked external record."}) 
    @MaxLength(36)
    EntityID?: string;
        
    @Field({nullable: true, description: "Primary key value of the linked record in EntityID."}) 
    @MaxLength(450)
    RecordID?: string;
        
    @Field({nullable: true, description: "Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related."}) 
    @MaxLength(30)
    Relationship?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Entity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Time Entry Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTimeEntryLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskTimeEntryID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Relationship?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Time Entry Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTimeEntryLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskTimeEntryID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Relationship?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Time Entry Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTimeEntryLinkViewResult {
    @Field(() => [mjBizAppsTasksTaskTimeEntryLink_])
    Results: mjBizAppsTasksTaskTimeEntryLink_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTimeEntryLink_)
export class mjBizAppsTasksTaskTimeEntryLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTimeEntryLinkViewResult)
    async RunmjBizAppsTasksTaskTimeEntryLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimeEntryLinkViewResult)
    async RunmjBizAppsTasksTaskTimeEntryLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimeEntryLinkViewResult)
    async RunmjBizAppsTasksTaskTimeEntryLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Time Entry Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTimeEntryLink_, { nullable: true })
    async mjBizAppsTasksTaskTimeEntryLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTimeEntryLink_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Time Entry Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTimeEntryLinks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Time Entry Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Time Entry Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimeEntryLink_)
    async CreatemjBizAppsTasksTaskTimeEntryLink(
        @Arg('input', () => CreatemjBizAppsTasksTaskTimeEntryLinkInput) input: CreatemjBizAppsTasksTaskTimeEntryLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Time Entry Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTimeEntryLink_)
    async UpdatemjBizAppsTasksTaskTimeEntryLink(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTimeEntryLinkInput) input: UpdatemjBizAppsTasksTaskTimeEntryLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Time Entry Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimeEntryLink_)
    async DeletemjBizAppsTasksTaskTimeEntryLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Time Entry Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Timers
//****************************************************************************
@ObjectType({ description: "Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows." })
export class mjBizAppsTasksTaskTimer_ {
    @Field({description: "Primary key for the running timer."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The task currently being timed."}) 
    @MaxLength(36)
    TaskID?: string;
        
    @Field({nullable: true, description: "The Person whose stopwatch is running (unique across TaskTimer)."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "Timestamp when the timer was started."}) 
    StartedAt?: Date;
        
    @Field({nullable: true, description: "Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops."}) 
    Notes?: string;
        
    @Field(() => Boolean, {nullable: true, description: "Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops."}) 
    IsBillable?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Task?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Timers
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTimerInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    StartedAt?: Date;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => Boolean, { nullable: true })
    IsBillable?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Timers
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTimerInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    StartedAt?: Date;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsBillable?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Timers
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTimerViewResult {
    @Field(() => [mjBizAppsTasksTaskTimer_])
    Results: mjBizAppsTasksTaskTimer_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTimer_)
export class mjBizAppsTasksTaskTimerResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTimerViewResult)
    async RunmjBizAppsTasksTaskTimerViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimerViewResult)
    async RunmjBizAppsTasksTaskTimerViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTimerViewResult)
    async RunmjBizAppsTasksTaskTimerDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Timers';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTimer_, { nullable: true })
    async mjBizAppsTasksTaskTimer(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTimer_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Timers', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTimers')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Timers', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Timers', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimer_)
    async CreatemjBizAppsTasksTaskTimer(
        @Arg('input', () => CreatemjBizAppsTasksTaskTimerInput) input: CreatemjBizAppsTasksTaskTimerInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Timers', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTimer_)
    async UpdatemjBizAppsTasksTaskTimer(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTimerInput) input: UpdatemjBizAppsTasksTaskTimerInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Timers', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTimer_)
    async DeletemjBizAppsTasksTaskTimer(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Timers', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Type Status
//****************************************************************************
@ObjectType({ description: "Dynamic domain statuses and lifecycle stages configured per Task Type." })
export class mjBizAppsTasksTaskTypeStatus_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The Task Type this status belongs to."}) 
    @MaxLength(36)
    TaskTypeID?: string;
        
    @Field({nullable: true, description: "Display name of the status (e.g. Legal Review, Redlining, Pending Signature)."}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true, description: "Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING)."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true, description: "The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent."}) 
    @MaxLength(20)
    MacroStatus?: string;
        
    @Field(() => Int, {nullable: true, description: "Ordering sequence for pickers, stage progression bars, and Kanban columns."}) 
    Sequence?: number;
        
    @Field(() => Boolean, {nullable: true, description: "Whether this is the initial default status when a task of this type is created."}) 
    IsDefault?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: "Whether this status represents a closed terminal state for the task."}) 
    IsTerminal?: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    Color?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field({nullable: true, description: "Action invoked when a task enters this specific status."}) 
    @MaxLength(36)
    OnEnterActionID?: string;
        
    @Field({nullable: true, description: "Action invoked when a task leaves this specific status."}) 
    @MaxLength(36)
    OnExitActionID?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    TaskType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnEnterAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnExitAction?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Type Status
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTypeStatusInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskTypeID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    MacroStatus?: string;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsDefault?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsTerminal?: boolean;

    @Field({ nullable: true })
    Color: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field({ nullable: true })
    OnEnterActionID: string | null;

    @Field({ nullable: true })
    OnExitActionID: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Type Status
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTypeStatusInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TaskTypeID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    MacroStatus?: string;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => Boolean, { nullable: true })
    IsDefault?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsTerminal?: boolean;

    @Field({ nullable: true })
    Color?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field({ nullable: true })
    OnEnterActionID?: string | null;

    @Field({ nullable: true })
    OnExitActionID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Type Status
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTypeStatusViewResult {
    @Field(() => [mjBizAppsTasksTaskTypeStatus_])
    Results: mjBizAppsTasksTaskTypeStatus_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskTypeStatus_)
export class mjBizAppsTasksTaskTypeStatusResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTypeStatusViewResult)
    async RunmjBizAppsTasksTaskTypeStatusViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTypeStatusViewResult)
    async RunmjBizAppsTasksTaskTypeStatusViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTypeStatusViewResult)
    async RunmjBizAppsTasksTaskTypeStatusDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Type Status';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTypeStatus_, { nullable: true })
    async mjBizAppsTasksTaskTypeStatus(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTypeStatus_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Type Status', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTypeStatus')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Type Status', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Type Status', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTypeStatus_)
    async CreatemjBizAppsTasksTaskTypeStatus(
        @Arg('input', () => CreatemjBizAppsTasksTaskTypeStatusInput) input: CreatemjBizAppsTasksTaskTypeStatusInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Type Status', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTypeStatus_)
    async UpdatemjBizAppsTasksTaskTypeStatus(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTypeStatusInput) input: UpdatemjBizAppsTasksTaskTypeStatusInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Type Status', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTypeStatus_)
    async DeletemjBizAppsTasksTaskTypeStatus(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Type Status', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Types
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    DefaultPriority?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OnAssignActionID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OnCompleteActionID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OnOverdueActionID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OnPercentChangeActionID?: string;
        
    @Field(() => Boolean, {nullable: true}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: "Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows."}) 
    @MaxLength(36)
    OnRejectActionID?: string;
        
    @Field({nullable: true, description: "Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking)."}) 
    @MaxLength(36)
    OnCancelActionID?: string;
        
    @Field({nullable: true, description: "Stable unique machine code for programmatic lookups and cross-app metadata references."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true, description: "Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator)."}) 
    @MaxLength(36)
    OnCreateActionID?: string;
        
    @Field({nullable: true, description: "Action invoked whenever a task of this type changes status."}) 
    @MaxLength(36)
    OnStatusChangeActionID?: string;
        
    @Field(() => Boolean, {nullable: true, description: "When true, tasks of this type are approvals: they appear in the approvals inbox of each assignee, who records a decision on them."}) 
    IsApproval?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: "When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting."}) 
    RequiresAssigneeDecision?: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnAssignAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnCompleteAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnOverdueAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnPercentChangeAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnRejectAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnCancelAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnCreateAction?: string;
        
    @Field({nullable: true}) 
    @MaxLength(425)
    OnStatusChangeAction?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field({ nullable: true })
    DefaultPriority?: string;

    @Field({ nullable: true })
    OnAssignActionID: string | null;

    @Field({ nullable: true })
    OnCompleteActionID: string | null;

    @Field({ nullable: true })
    OnOverdueActionID: string | null;

    @Field({ nullable: true })
    OnPercentChangeActionID: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field({ nullable: true })
    OnRejectActionID: string | null;

    @Field({ nullable: true })
    OnCancelActionID: string | null;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    OnCreateActionID: string | null;

    @Field({ nullable: true })
    OnStatusChangeActionID: string | null;

    @Field(() => Boolean, { nullable: true })
    IsApproval?: boolean;

    @Field(() => Boolean, { nullable: true })
    RequiresAssigneeDecision?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Task Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field({ nullable: true })
    DefaultPriority?: string;

    @Field({ nullable: true })
    OnAssignActionID?: string | null;

    @Field({ nullable: true })
    OnCompleteActionID?: string | null;

    @Field({ nullable: true })
    OnOverdueActionID?: string | null;

    @Field({ nullable: true })
    OnPercentChangeActionID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field({ nullable: true })
    OnRejectActionID?: string | null;

    @Field({ nullable: true })
    OnCancelActionID?: string | null;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    OnCreateActionID?: string | null;

    @Field({ nullable: true })
    OnStatusChangeActionID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsApproval?: boolean;

    @Field(() => Boolean, { nullable: true })
    RequiresAssigneeDecision?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Task Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskTypeViewResult {
    @Field(() => [mjBizAppsTasksTaskType_])
    Results: mjBizAppsTasksTaskType_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTaskType_)
export class mjBizAppsTasksTaskTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskTypeViewResult)
    async RunmjBizAppsTasksTaskTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTypeViewResult)
    async RunmjBizAppsTasksTaskTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskTypeViewResult)
    async RunmjBizAppsTasksTaskTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Task Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskType_, { nullable: true })
    async mjBizAppsTasksTaskType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskType_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTypes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskType_)
    async CreatemjBizAppsTasksTaskType(
        @Arg('input', () => CreatemjBizAppsTasksTaskTypeInput) input: CreatemjBizAppsTasksTaskTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Task Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskType_)
    async UpdatemjBizAppsTasksTaskType(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTypeInput) input: UpdatemjBizAppsTasksTaskTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Task Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskType_)
    async DeletemjBizAppsTasksTaskType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Task Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Tasks
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTask_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CategoryID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    Status?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    Priority?: string;
        
    @Field({nullable: true}) 
    StartedAt?: Date;
        
    @Field({nullable: true}) 
    DueAt?: Date;
        
    @Field({nullable: true}) 
    CompletedAt?: Date;
        
    @Field(() => Float, {nullable: true}) 
    HoursEstimated?: number;
        
    @Field(() => Float, {nullable: true}) 
    HoursActual?: number;
        
    @Field(() => Int, {nullable: true}) 
    PercentComplete?: number;
        
    @Field(() => Int, {nullable: true}) 
    Sequence?: number;
        
    @Field({nullable: true}) 
    BlockedReason?: string;
        
    @Field({nullable: true}) 
    CompletionNotes?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CreatedByPersonID?: string;
        
    @Field({nullable: true}) 
    OverdueNotifiedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: "Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles."}) 
    @MaxLength(36)
    TaskTypeStatusID?: string;
        
    @Field(() => Float, {nullable: true, description: "Predicted probability (0.0000 - 1.0000) that this task breaches its target due date or SLA."}) 
    PredictedSLABreachProbability?: number;
        
    @Field({nullable: true, description: "Operational SLA breach risk tier: Low (<0.30), Medium (0.30-0.70), High (>0.70), or Critical."}) 
    @MaxLength(20)
    PredictedSLARiskBand?: string;
        
    @Field({nullable: true, description: "Timestamp when this task was last scored by the predictive SLA breach model."}) 
    PredictedSLAScoredAt?: Date;
        
    @Field({nullable: true, description: "Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused."}) 
    @MaxLength(20)
    HealthStatus?: string;
        
    @Field(() => Int, {nullable: true, description: "Owner confidence score (0-100) that this task, key result, or objective will hit its target on time."}) 
    ConfidenceScore?: number;
        
    @Field(() => Float, {nullable: true, description: "Starting baseline value for measurable key results or quantitative deliverables."}) 
    BaselineValue?: number;
        
    @Field(() => Float, {nullable: true, description: "Target goal value for measurable key results or quantitative deliverables."}) 
    TargetValue?: number;
        
    @Field(() => Float, {nullable: true, description: "Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records."}) 
    CurrentValue?: number;
        
    @Field({nullable: true, description: "Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS)."}) 
    @MaxLength(50)
    UnitOfMeasure?: string;
        
    @Field({nullable: true, description: "Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain."}) 
    @MaxLength(20)
    MetricDirection?: string;
        
    @Field(() => Float, {nullable: true, description: "Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective."}) 
    RollupWeight?: number;
        
    @Field({nullable: true, description: "Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026)."}) 
    @MaxLength(50)
    PlanningPeriod?: string;
        
    @Field({nullable: true, description: "Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None."}) 
    @MaxLength(20)
    CheckInCadence?: string;
        
    @Field({nullable: true, description: "Timestamp when the most recent TaskCheckIn was recorded for this task."}) 
    LastCheckInAt?: Date;
        
    @Field({nullable: true, description: "Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners."}) 
    NextCheckInDueAt?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Type?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Category?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Parent?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    CreatedByPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    TaskTypeStatus?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(8)
    IsSLABreached?: string;
        
    @Field(() => Int, {nullable: true}) 
    LeadDays?: number;
        
    @Field(() => Int, {nullable: true}) 
    AssignmentsCount?: number;
        
    @Field(() => Int, {nullable: true}) 
    CommentsCount?: number;
        
    @Field(() => Int, {nullable: true}) 
    LoggedMinutes?: number;
        
    @Field(() => Int, {nullable: true}) 
    AgentRunCount?: number;
        
    @Field(() => Float, {nullable: true}) 
    AgentCost?: number;
        
    @Field(() => Int, {nullable: true}) 
    AgentTokens?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Tasks
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    TypeID?: string;

    @Field({ nullable: true })
    CategoryID: string | null;

    @Field({ nullable: true })
    ParentID: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    Priority?: string;

    @Field({ nullable: true })
    StartedAt: Date | null;

    @Field({ nullable: true })
    DueAt: Date | null;

    @Field({ nullable: true })
    CompletedAt: Date | null;

    @Field(() => Float, { nullable: true })
    HoursEstimated: number | null;

    @Field(() => Float, { nullable: true })
    HoursActual: number | null;

    @Field(() => Int, { nullable: true })
    PercentComplete?: number;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field({ nullable: true })
    BlockedReason: string | null;

    @Field({ nullable: true })
    CompletionNotes: string | null;

    @Field({ nullable: true })
    CreatedByPersonID: string | null;

    @Field({ nullable: true })
    OverdueNotifiedAt: Date | null;

    @Field({ nullable: true })
    TaskTypeStatusID: string | null;

    @Field(() => Float, { nullable: true })
    PredictedSLABreachProbability: number | null;

    @Field({ nullable: true })
    PredictedSLARiskBand: string | null;

    @Field({ nullable: true })
    PredictedSLAScoredAt: Date | null;

    @Field({ nullable: true })
    HealthStatus: string | null;

    @Field(() => Int, { nullable: true })
    ConfidenceScore: number | null;

    @Field(() => Float, { nullable: true })
    BaselineValue: number | null;

    @Field(() => Float, { nullable: true })
    TargetValue: number | null;

    @Field(() => Float, { nullable: true })
    CurrentValue: number | null;

    @Field({ nullable: true })
    UnitOfMeasure: string | null;

    @Field({ nullable: true })
    MetricDirection: string | null;

    @Field(() => Float, { nullable: true })
    RollupWeight?: number;

    @Field({ nullable: true })
    PlanningPeriod: string | null;

    @Field({ nullable: true })
    CheckInCadence: string | null;

    @Field({ nullable: true })
    LastCheckInAt: Date | null;

    @Field({ nullable: true })
    NextCheckInDueAt: Date | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Tasks
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTaskInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    TypeID?: string;

    @Field({ nullable: true })
    CategoryID?: string | null;

    @Field({ nullable: true })
    ParentID?: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    Priority?: string;

    @Field({ nullable: true })
    StartedAt?: Date | null;

    @Field({ nullable: true })
    DueAt?: Date | null;

    @Field({ nullable: true })
    CompletedAt?: Date | null;

    @Field(() => Float, { nullable: true })
    HoursEstimated?: number | null;

    @Field(() => Float, { nullable: true })
    HoursActual?: number | null;

    @Field(() => Int, { nullable: true })
    PercentComplete?: number;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field({ nullable: true })
    BlockedReason?: string | null;

    @Field({ nullable: true })
    CompletionNotes?: string | null;

    @Field({ nullable: true })
    CreatedByPersonID?: string | null;

    @Field({ nullable: true })
    OverdueNotifiedAt?: Date | null;

    @Field({ nullable: true })
    TaskTypeStatusID?: string | null;

    @Field(() => Float, { nullable: true })
    PredictedSLABreachProbability?: number | null;

    @Field({ nullable: true })
    PredictedSLARiskBand?: string | null;

    @Field({ nullable: true })
    PredictedSLAScoredAt?: Date | null;

    @Field({ nullable: true })
    HealthStatus?: string | null;

    @Field(() => Int, { nullable: true })
    ConfidenceScore?: number | null;

    @Field(() => Float, { nullable: true })
    BaselineValue?: number | null;

    @Field(() => Float, { nullable: true })
    TargetValue?: number | null;

    @Field(() => Float, { nullable: true })
    CurrentValue?: number | null;

    @Field({ nullable: true })
    UnitOfMeasure?: string | null;

    @Field({ nullable: true })
    MetricDirection?: string | null;

    @Field(() => Float, { nullable: true })
    RollupWeight?: number;

    @Field({ nullable: true })
    PlanningPeriod?: string | null;

    @Field({ nullable: true })
    CheckInCadence?: string | null;

    @Field({ nullable: true })
    LastCheckInAt?: Date | null;

    @Field({ nullable: true })
    NextCheckInDueAt?: Date | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Tasks
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTaskViewResult {
    @Field(() => [mjBizAppsTasksTask_])
    Results: mjBizAppsTasksTask_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTask_)
export class mjBizAppsTasksTaskResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTaskViewResult)
    async RunmjBizAppsTasksTaskViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskViewResult)
    async RunmjBizAppsTasksTaskViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTaskViewResult)
    async RunmjBizAppsTasksTaskDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Tasks';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTask_, { nullable: true })
    async mjBizAppsTasksTask(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTask_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Tasks', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTask_)
    async CreatemjBizAppsTasksTask(
        @Arg('input', () => CreatemjBizAppsTasksTaskInput) input: CreatemjBizAppsTasksTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Tasks', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTask_)
    async UpdatemjBizAppsTasksTask(
        @Arg('input', () => UpdatemjBizAppsTasksTaskInput) input: UpdatemjBizAppsTasksTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Tasks', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTask_)
    async DeletemjBizAppsTasksTask(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Tasks', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Time Approvers
//****************************************************************************
@ObjectType({ description: "Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record." })
export class mjBizAppsTasksTimeApprover_ {
    @Field({description: "Primary key for the time approver rule."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The Person who is granted time approval authority by this rule."}) 
    @MaxLength(36)
    ApproverPersonID?: string;
        
    @Field({nullable: true, description: "Optional Worker Person whose time this rule applies to (NULL matches any worker)."}) 
    @MaxLength(36)
    WorkerPersonID?: string;
        
    @Field({nullable: true, description: "Optional project/parent Task this rule scopes approval to (NULL matches any task)."}) 
    @MaxLength(36)
    ScopeTaskID?: string;
        
    @Field(() => Boolean, {nullable: true, description: "When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule."}) 
    IncludeDescendants?: boolean;
        
    @Field({nullable: true, description: "Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink."}) 
    @MaxLength(36)
    ScopeEntityID?: string;
        
    @Field({nullable: true, description: "Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink."}) 
    @MaxLength(450)
    ScopeRecordID?: string;
        
    @Field({nullable: true, description: "Optional start date from which this approver rule is effective."}) 
    EffectiveFrom?: Date;
        
    @Field({nullable: true, description: "Optional end date through which this approver rule is effective."}) 
    EffectiveTo?: Date;
        
    @Field(() => Boolean, {nullable: true, description: "Whether this approver rule is currently active."}) 
    IsActive?: boolean;
        
    @Field({nullable: true, description: "Optional administrative notes about this approver rule."}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    ApproverPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    WorkerPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ScopeTask?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ScopeEntity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Time Approvers
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTimeApproverInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ApproverPersonID?: string;

    @Field({ nullable: true })
    WorkerPersonID: string | null;

    @Field({ nullable: true })
    ScopeTaskID: string | null;

    @Field(() => Boolean, { nullable: true })
    IncludeDescendants?: boolean;

    @Field({ nullable: true })
    ScopeEntityID: string | null;

    @Field({ nullable: true })
    ScopeRecordID: string | null;

    @Field({ nullable: true })
    EffectiveFrom: Date | null;

    @Field({ nullable: true })
    EffectiveTo: Date | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Time Approvers
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTimeApproverInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ApproverPersonID?: string;

    @Field({ nullable: true })
    WorkerPersonID?: string | null;

    @Field({ nullable: true })
    ScopeTaskID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IncludeDescendants?: boolean;

    @Field({ nullable: true })
    ScopeEntityID?: string | null;

    @Field({ nullable: true })
    ScopeRecordID?: string | null;

    @Field({ nullable: true })
    EffectiveFrom?: Date | null;

    @Field({ nullable: true })
    EffectiveTo?: Date | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Time Approvers
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTimeApproverViewResult {
    @Field(() => [mjBizAppsTasksTimeApprover_])
    Results: mjBizAppsTasksTimeApprover_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTimeApprover_)
export class mjBizAppsTasksTimeApproverResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTimeApproverViewResult)
    async RunmjBizAppsTasksTimeApproverViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimeApproverViewResult)
    async RunmjBizAppsTasksTimeApproverViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimeApproverViewResult)
    async RunmjBizAppsTasksTimeApproverDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Time Approvers';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTimeApprover_, { nullable: true })
    async mjBizAppsTasksTimeApprover(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTimeApprover_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Time Approvers', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTimeApprovers')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Time Approvers', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Time Approvers', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTimeApprover_)
    async CreatemjBizAppsTasksTimeApprover(
        @Arg('input', () => CreatemjBizAppsTasksTimeApproverInput) input: CreatemjBizAppsTasksTimeApproverInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Time Approvers', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTimeApprover_)
    async UpdatemjBizAppsTasksTimeApprover(
        @Arg('input', () => UpdatemjBizAppsTasksTimeApproverInput) input: UpdatemjBizAppsTasksTimeApproverInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Time Approvers', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTimeApprover_)
    async DeletemjBizAppsTasksTimeApprover(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Time Approvers', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Timesheet Approvals
//****************************************************************************
@ObjectType({ description: "Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox." })
export class mjBizAppsTasksTimesheetApproval_ {
    @Field({description: "Primary key for the timesheet approval part."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The Timesheet this approval slice belongs to."}) 
    @MaxLength(36)
    TimesheetID?: string;
        
    @Field(() => Int, {nullable: true, description: "Submission round number (1 on initial submit, incremented on each resubmit)."}) 
    SubmissionRound?: number;
        
    @Field({nullable: true, description: "Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice."}) 
    @MaxLength(36)
    ScopeTaskID?: string;
        
    @Field({nullable: true, description: "The approval Task created in the Tasks inbox for this slice."}) 
    @MaxLength(36)
    ApprovalTaskID?: string;
        
    @Field(() => Int, {nullable: true, description: "Total minutes in this approval slice at submission time."}) 
    Minutes?: number;
        
    @Field(() => Int, {nullable: true, description: "Total billable minutes in this approval slice at submission time."}) 
    BillableMinutes?: number;
        
    @Field(() => Int, {nullable: true, description: "Number of TaskTimeEntry rows included in this approval slice."}) 
    EntryCount?: number;
        
    @Field({nullable: true, description: "Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions."}) 
    @MaxLength(64)
    SnapshotHash?: string;
        
    @Field({nullable: true, description: "Current status of this approval slice: Pending, Approved, Rejected, or Canceled."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "The Person who recorded the approval or rejection decision."}) 
    @MaxLength(36)
    DecidedByPersonID?: string;
        
    @Field({nullable: true, description: "Timestamp when the decision on this slice was recorded."}) 
    DecidedAt?: Date;
        
    @Field({nullable: true, description: "Notes or feedback provided by the approver when deciding this slice."}) 
    DecisionNotes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ScopeTask?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ApprovalTask?: string;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    DecidedByPerson?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Approvals
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTimesheetApprovalInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TimesheetID?: string;

    @Field(() => Int, { nullable: true })
    SubmissionRound?: number;

    @Field({ nullable: true })
    ScopeTaskID: string | null;

    @Field({ nullable: true })
    ApprovalTaskID?: string;

    @Field(() => Int, { nullable: true })
    Minutes?: number;

    @Field(() => Int, { nullable: true })
    BillableMinutes?: number;

    @Field(() => Int, { nullable: true })
    EntryCount?: number;

    @Field({ nullable: true })
    SnapshotHash?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DecidedByPersonID: string | null;

    @Field({ nullable: true })
    DecidedAt: Date | null;

    @Field({ nullable: true })
    DecisionNotes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Approvals
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTimesheetApprovalInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TimesheetID?: string;

    @Field(() => Int, { nullable: true })
    SubmissionRound?: number;

    @Field({ nullable: true })
    ScopeTaskID?: string | null;

    @Field({ nullable: true })
    ApprovalTaskID?: string;

    @Field(() => Int, { nullable: true })
    Minutes?: number;

    @Field(() => Int, { nullable: true })
    BillableMinutes?: number;

    @Field(() => Int, { nullable: true })
    EntryCount?: number;

    @Field({ nullable: true })
    SnapshotHash?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DecidedByPersonID?: string | null;

    @Field({ nullable: true })
    DecidedAt?: Date | null;

    @Field({ nullable: true })
    DecisionNotes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Timesheet Approvals
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTimesheetApprovalViewResult {
    @Field(() => [mjBizAppsTasksTimesheetApproval_])
    Results: mjBizAppsTasksTimesheetApproval_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTimesheetApproval_)
export class mjBizAppsTasksTimesheetApprovalResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTimesheetApprovalViewResult)
    async RunmjBizAppsTasksTimesheetApprovalViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetApprovalViewResult)
    async RunmjBizAppsTasksTimesheetApprovalViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetApprovalViewResult)
    async RunmjBizAppsTasksTimesheetApprovalDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Timesheet Approvals';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTimesheetApproval_, { nullable: true })
    async mjBizAppsTasksTimesheetApproval(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTimesheetApproval_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Timesheet Approvals', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTimesheetApprovals')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Timesheet Approvals', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Timesheet Approvals', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetApproval_)
    async CreatemjBizAppsTasksTimesheetApproval(
        @Arg('input', () => CreatemjBizAppsTasksTimesheetApprovalInput) input: CreatemjBizAppsTasksTimesheetApprovalInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Timesheet Approvals', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTimesheetApproval_)
    async UpdatemjBizAppsTasksTimesheetApproval(
        @Arg('input', () => UpdatemjBizAppsTasksTimesheetApprovalInput) input: UpdatemjBizAppsTasksTimesheetApprovalInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Timesheet Approvals', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetApproval_)
    async DeletemjBizAppsTasksTimesheetApproval(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Timesheet Approvals', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Timesheet Links
//****************************************************************************
@ObjectType({ description: "Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports." })
export class mjBizAppsTasksTimesheetLink_ {
    @Field({description: "Primary key for the timesheet link."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The Timesheet being linked."}) 
    @MaxLength(36)
    TimesheetID?: string;
        
    @Field({nullable: true, description: "Target MemberJunction Entity ID for the linked external record."}) 
    @MaxLength(36)
    EntityID?: string;
        
    @Field({nullable: true, description: "Primary key value of the linked record in EntityID."}) 
    @MaxLength(450)
    RecordID?: string;
        
    @Field({nullable: true, description: "Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related."}) 
    @MaxLength(30)
    Relationship?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Entity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTimesheetLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TimesheetID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Relationship?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTimesheetLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    TimesheetID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    Relationship?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Timesheet Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTimesheetLinkViewResult {
    @Field(() => [mjBizAppsTasksTimesheetLink_])
    Results: mjBizAppsTasksTimesheetLink_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTimesheetLink_)
export class mjBizAppsTasksTimesheetLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTimesheetLinkViewResult)
    async RunmjBizAppsTasksTimesheetLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetLinkViewResult)
    async RunmjBizAppsTasksTimesheetLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetLinkViewResult)
    async RunmjBizAppsTasksTimesheetLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Timesheet Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTimesheetLink_, { nullable: true })
    async mjBizAppsTasksTimesheetLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTimesheetLink_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Timesheet Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTimesheetLinks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Timesheet Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Timesheet Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetLink_)
    async CreatemjBizAppsTasksTimesheetLink(
        @Arg('input', () => CreatemjBizAppsTasksTimesheetLinkInput) input: CreatemjBizAppsTasksTimesheetLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Timesheet Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTimesheetLink_)
    async UpdatemjBizAppsTasksTimesheetLink(
        @Arg('input', () => UpdatemjBizAppsTasksTimesheetLinkInput) input: UpdatemjBizAppsTasksTimesheetLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Timesheet Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetLink_)
    async DeletemjBizAppsTasksTimesheetLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Timesheet Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Timesheet Schedules
//****************************************************************************
@ObjectType({ description: "Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record." })
export class mjBizAppsTasksTimesheetSchedule_ {
    @Field({description: "Primary key for the timesheet schedule."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules)."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "Optional MJ Entity ID when scoping the schedule to an organization or department record."}) 
    @MaxLength(36)
    ScopeEntityID?: string;
        
    @Field({nullable: true, description: "Companion record ID in ScopeEntityID for entity-scoped schedules."}) 
    @MaxLength(450)
    ScopeRecordID?: string;
        
    @Field({nullable: true, description: "Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly."}) 
    @MaxLength(20)
    Cadence?: string;
        
    @Field({nullable: true, description: "First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday."}) 
    @MaxLength(10)
    WeekStartDay?: string;
        
    @Field({nullable: true, description: "Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences."}) 
    BiWeeklyAnchorDate?: Date;
        
    @Field({nullable: true, description: "Inclusive start date from which this schedule is effective (must fall on a period boundary)."}) 
    EffectiveFrom?: Date;
        
    @Field({nullable: true, description: "Optional inclusive end date through which this schedule is effective."}) 
    EffectiveTo?: Date;
        
    @Field({nullable: true, description: "Optional notes explaining this schedule or cadence change."}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ScopeEntity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Schedules
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTimesheetScheduleInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    PersonID: string | null;

    @Field({ nullable: true })
    ScopeEntityID: string | null;

    @Field({ nullable: true })
    ScopeRecordID: string | null;

    @Field({ nullable: true })
    Cadence?: string;

    @Field({ nullable: true })
    WeekStartDay?: string;

    @Field({ nullable: true })
    BiWeeklyAnchorDate?: Date;

    @Field({ nullable: true })
    EffectiveFrom?: Date;

    @Field({ nullable: true })
    EffectiveTo: Date | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheet Schedules
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTimesheetScheduleInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    PersonID?: string | null;

    @Field({ nullable: true })
    ScopeEntityID?: string | null;

    @Field({ nullable: true })
    ScopeRecordID?: string | null;

    @Field({ nullable: true })
    Cadence?: string;

    @Field({ nullable: true })
    WeekStartDay?: string;

    @Field({ nullable: true })
    BiWeeklyAnchorDate?: Date;

    @Field({ nullable: true })
    EffectiveFrom?: Date;

    @Field({ nullable: true })
    EffectiveTo?: Date | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Timesheet Schedules
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTimesheetScheduleViewResult {
    @Field(() => [mjBizAppsTasksTimesheetSchedule_])
    Results: mjBizAppsTasksTimesheetSchedule_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTimesheetSchedule_)
export class mjBizAppsTasksTimesheetScheduleResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTimesheetScheduleViewResult)
    async RunmjBizAppsTasksTimesheetScheduleViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetScheduleViewResult)
    async RunmjBizAppsTasksTimesheetScheduleViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetScheduleViewResult)
    async RunmjBizAppsTasksTimesheetScheduleDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Timesheet Schedules';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTimesheetSchedule_, { nullable: true })
    async mjBizAppsTasksTimesheetSchedule(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTimesheetSchedule_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Timesheet Schedules', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTimesheetSchedules')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Timesheet Schedules', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Timesheet Schedules', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetSchedule_)
    async CreatemjBizAppsTasksTimesheetSchedule(
        @Arg('input', () => CreatemjBizAppsTasksTimesheetScheduleInput) input: CreatemjBizAppsTasksTimesheetScheduleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Timesheet Schedules', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTimesheetSchedule_)
    async UpdatemjBizAppsTasksTimesheetSchedule(
        @Arg('input', () => UpdatemjBizAppsTasksTimesheetScheduleInput) input: UpdatemjBizAppsTasksTimesheetScheduleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Timesheet Schedules', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTimesheetSchedule_)
    async DeletemjBizAppsTasksTimesheetSchedule(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Timesheet Schedules', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Timesheets
//****************************************************************************
@ObjectType({ description: "Period timesheet header for a person, grouping task time entries across a date range for submission and approval." })
export class mjBizAppsTasksTimesheet_ {
    @Field({description: "Primary key for the timesheet."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The Person whose time entries are covered by this timesheet."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "Inclusive start date of the timesheet period."}) 
    PeriodStart?: Date;
        
    @Field({nullable: true, description: "Inclusive end date of the timesheet period."}) 
    PeriodEnd?: Date;
        
    @Field({nullable: true, description: "Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "Timestamp when the timesheet was most recently submitted."}) 
    SubmittedAt?: Date;
        
    @Field({nullable: true, description: "The MemberJunction User who submitted the timesheet."}) 
    @MaxLength(36)
    SubmittedByUserID?: string;
        
    @Field(() => Int, {nullable: true, description: "Total minutes across all time entries attached to this timesheet."}) 
    TotalMinutes?: number;
        
    @Field(() => Int, {nullable: true, description: "Total billable minutes across all time entries attached to this timesheet."}) 
    BillableMinutes?: number;
        
    @Field({nullable: true, description: "Worker notes or comments submitted with the timesheet."}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(250)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    SubmittedByUser?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheets
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTimesheetInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    PeriodStart?: Date;

    @Field({ nullable: true })
    PeriodEnd?: Date;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    SubmittedAt: Date | null;

    @Field({ nullable: true })
    SubmittedByUserID: string | null;

    @Field(() => Int, { nullable: true })
    TotalMinutes?: number;

    @Field(() => Int, { nullable: true })
    BillableMinutes?: number;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Timesheets
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksTimesheetInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    PersonID?: string;

    @Field({ nullable: true })
    PeriodStart?: Date;

    @Field({ nullable: true })
    PeriodEnd?: Date;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    SubmittedAt?: Date | null;

    @Field({ nullable: true })
    SubmittedByUserID?: string | null;

    @Field(() => Int, { nullable: true })
    TotalMinutes?: number;

    @Field(() => Int, { nullable: true })
    BillableMinutes?: number;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Timesheets
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksTimesheetViewResult {
    @Field(() => [mjBizAppsTasksTimesheet_])
    Results: mjBizAppsTasksTimesheet_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(mjBizAppsTasksTimesheet_)
export class mjBizAppsTasksTimesheetResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksTimesheetViewResult)
    async RunmjBizAppsTasksTimesheetViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetViewResult)
    async RunmjBizAppsTasksTimesheetViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksTimesheetViewResult)
    async RunmjBizAppsTasksTimesheetDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Timesheets';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTimesheet_, { nullable: true })
    async mjBizAppsTasksTimesheet(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTimesheet_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Timesheets', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTimesheets')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Timesheets', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Timesheets', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTimesheet_)
    async CreatemjBizAppsTasksTimesheet(
        @Arg('input', () => CreatemjBizAppsTasksTimesheetInput) input: CreatemjBizAppsTasksTimesheetInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Timesheets', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTimesheet_)
    async UpdatemjBizAppsTasksTimesheet(
        @Arg('input', () => UpdatemjBizAppsTasksTimesheetInput) input: UpdatemjBizAppsTasksTimesheetInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Timesheets', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTimesheet_)
    async DeletemjBizAppsTasksTimesheet(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Timesheets', key, options, provider, userPayload, pubSub);
    }
    
}