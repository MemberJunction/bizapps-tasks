/********************************************************************************
* ALL ENTITIES - TypeGraphQL Type Class Definition - AUTO GENERATED FILE
* Generated Entities and Resolvers for Server
*
*   >>> DO NOT MODIFY THIS FILE!!!!!!!!!!!!
*   >>> YOUR CHANGES WILL BE OVERWRITTEN
*   >>> THE NEXT TIME THIS FILE IS GENERATED
*
**********************************************************************************/
import { Arg, Ctx, Int, Query, Resolver, Field, Float, ObjectType, FieldResolver, Root, InputType, Mutation,
            PubSub, PubSubEngine, ResolverBase, RunViewByIDInput, RunViewByNameInput, RunDynamicViewInput,
            AppContext, KeyValuePairInput, DeleteOptionsInput, GraphQLTimestamp as Timestamp,
            GetReadOnlyProvider, GetReadWriteProvider, RestoreContextInput } from '@memberjunction/server';
import { Metadata, EntityPermissionType, CompositeKey, UserInfo } from '@memberjunction/core'

import { MaxLength } from 'class-validator';
import * as mj_core_schema_server_object_types from '@memberjunction/server'


import { mjBizAppsTasksTaskActivityEntity, mjBizAppsTasksTaskAssignmentEntity, mjBizAppsTasksTaskCategoryEntity, mjBizAppsTasksTaskCommentEntity, mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskLinkEntity, mjBizAppsTasksTaskNotificationConfigEntity, mjBizAppsTasksTaskNotificationLogEntity, mjBizAppsTasksTaskRoleEntity, mjBizAppsTasksTaskTagLinkEntity, mjBizAppsTasksTaskTagEntity, mjBizAppsTasksTaskTemplateItemDependencyEntity, mjBizAppsTasksTaskTemplateItemRoleEntity, mjBizAppsTasksTaskTemplateItemEntity, mjBizAppsTasksTaskTemplateEntity, mjBizAppsTasksTaskTypeEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
    

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Task Activities
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskActivity_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field() 
    @MaxLength(50)
    ActivityType: string;
        
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
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    Person?: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
// ENTITY CLASS for MJ_BizApps_Tasks: Task Assignments
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskAssignment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field() 
    @MaxLength(36)
    AssigneeEntityID: string;
        
    @Field() 
    @MaxLength(450)
    AssigneeRecordID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RoleID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    RoleNotes?: string;
        
    @Field() 
    @MaxLength(50)
    Status: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    AssignedByPersonID?: string;
        
    @Field() 
    AssignedAt: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(255)
    AssigneeEntity: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Role?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    AssignedByPerson?: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(255)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ColorCode?: string;
        
    @Field(() => Int) 
    Sequence: number;
        
    @Field(() => Boolean) 
    IsActive: boolean;
        
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
        
    @Field(() => [mjBizAppsTasksTaskTemplate_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates_CategoryIDArray: mjBizAppsTasksTaskTemplate_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates
    
    @Field(() => [mjBizAppsTasksTaskCategory_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskCategories_ParentIDArray: mjBizAppsTasksTaskCategory_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskCategories
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksMJ_BizApps_Tasks_Tasks_CategoryIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_Tasks
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCategories')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Categories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Categories', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplate_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates_CategoryIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('CategoryID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Templates', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskCategory_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskCategories_ParentIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Categories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCategories')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Categories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Categories', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksMJ_BizApps_Tasks_Tasks_CategoryIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('CategoryID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
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
// ENTITY CLASS for MJ_BizApps_Tasks: Task Comments
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskComment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field() 
    @MaxLength(36)
    PersonID: string;
        
    @Field() 
    Content: string;
        
    @Field(() => Boolean) 
    IsEdited: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(201)
    Person: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => [mjBizAppsTasksTaskComment_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskComments_ParentIDArray: mjBizAppsTasksTaskComment_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskComments
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Comments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskComment_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskComments_ParentIDArray(@Root() mjbizappstaskstaskcomment_: mjBizAppsTasksTaskComment_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstaskcomment_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Comments', rows, this.GetUserFromPayload(userPayload));
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
// ENTITY CLASS for MJ_BizApps_Tasks: Task Dependencies
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskDependency_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field() 
    @MaxLength(36)
    DependsOnTaskID: string;
        
    @Field() 
    @MaxLength(50)
    DependencyType: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(255)
    DependsOnTask: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field() 
    @MaxLength(36)
    EntityID: string;
        
    @Field() 
    @MaxLength(450)
    RecordID: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(255)
    Entity: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskLinks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field(() => Boolean) 
    OverdueNotificationsEnabled: boolean;
        
    @Field(() => Int) 
    OverdueGracePeriodHours: number;
        
    @Field(() => Int, {nullable: true}) 
    OverdueRepeatIntervalHours?: number;
        
    @Field(() => Boolean) 
    NotifyAssignees: boolean;
        
    @Field(() => Boolean) 
    NotifyCreator: boolean;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationConfigs')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Configs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field() 
    @MaxLength(50)
    NotificationType: string;
        
    @Field() 
    @MaxLength(36)
    NotifiedUserID: string;
        
    @Field() 
    NotifiedAt: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(100)
    NotifiedUser: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationLogs')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Logs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field(() => Int) 
    Sequence: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsTasksTaskTemplateItemRole_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles_RoleIDArray: mjBizAppsTasksTaskTemplateItemRole_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles
    
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments_RoleIDArray: mjBizAppsTasksTaskAssignment_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskRoles')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Roles', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemRole_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles_RoleIDArray(@Root() mjbizappstaskstaskrole_: mjBizAppsTasksTaskRole_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('RoleID')}='${mjbizappstaskstaskrole_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Roles', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskAssignment_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments_RoleIDArray(@Root() mjbizappstaskstaskrole_: mjBizAppsTasksTaskRole_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('RoleID')}='${mjbizappstaskstaskrole_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Assignments', rows, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    TaskID: string;
        
    @Field() 
    @MaxLength(36)
    TagID: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Task: string;
        
    @Field() 
    @MaxLength(100)
    Tag: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ColorCode?: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsTasksTaskTagLink_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks_TagIDArray: mjBizAppsTasksTaskTagLink_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTags')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tags', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Tags', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTagLink_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks_TagIDArray(@Root() mjbizappstaskstasktag_: mjBizAppsTasksTaskTag_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('TagID')}='${mjbizappstaskstasktag_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Tag Links', rows, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    ItemID: string;
        
    @Field() 
    @MaxLength(36)
    DependsOnItemID: string;
        
    @Field() 
    @MaxLength(50)
    DependencyType: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Item: string;
        
    @Field() 
    @MaxLength(255)
    DependsOnItem: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    ItemID: string;
        
    @Field() 
    @MaxLength(36)
    RoleID: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Item: string;
        
    @Field() 
    @MaxLength(100)
    Role: string;
        
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(36)
    TemplateID: string;
        
    @Field() 
    @MaxLength(255)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentItemID?: string;
        
    @Field() 
    @MaxLength(20)
    Priority: string;
        
    @Field(() => Int, {nullable: true}) 
    DaysFromStart?: number;
        
    @Field(() => Float, {nullable: true}) 
    HoursEstimated?: number;
        
    @Field(() => Int) 
    Sequence: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Template: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ParentItem?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentItemID?: string;
        
    @Field(() => [mjBizAppsTasksTaskTemplateItem_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems_ParentItemIDArray: mjBizAppsTasksTaskTemplateItem_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemRole_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles_ItemIDArray: mjBizAppsTasksTaskTemplateItemRole_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies_DependsOnItemIDArray: mjBizAppsTasksTaskTemplateItemDependency_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies_ItemIDArray: mjBizAppsTasksTaskTemplateItemDependency_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Items', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItem_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems_ParentItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('ParentItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Items', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemRole_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemRoles_ItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('ItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Roles', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies_DependsOnItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('DependsOnItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItemDependencies_ItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('ItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Item Dependencies', rows, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(255)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CategoryID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field(() => Boolean) 
    IsActive: boolean;
        
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
        
    @Field(() => [mjBizAppsTasksTaskTemplateItem_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems_TemplateIDArray: mjBizAppsTasksTaskTemplateItem_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Templates', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItem_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplateItems_TemplateIDArray(@Root() mjbizappstaskstasktemplate_: mjBizAppsTasksTaskTemplate_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('TemplateID')}='${mjbizappstaskstasktemplate_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Template Items', rows, this.GetUserFromPayload(userPayload));
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
// ENTITY CLASS for MJ_BizApps_Tasks: Task Types
//****************************************************************************
@ObjectType()
export class mjBizAppsTasksTaskType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field() 
    @MaxLength(20)
    DefaultPriority: string;
        
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
        
    @Field(() => Boolean) 
    IsActive: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
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
        
    @Field(() => [mjBizAppsTasksTaskNotificationConfig_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationConfigs_TaskTypeIDArray: mjBizAppsTasksTaskNotificationConfig_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationConfigs
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksMJ_BizApps_Tasks_Tasks_TypeIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_Tasks
    
    @Field(() => [mjBizAppsTasksTaskTemplate_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates_TypeIDArray: mjBizAppsTasksTaskTemplate_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskNotificationConfig_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationConfigs_TaskTypeIDArray(@Root() mjbizappstaskstasktype_: mjBizAppsTasksTaskType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Notification Configs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationConfigs')} WHERE ${provider.QuoteIdentifier('TaskTypeID')}='${mjbizappstaskstasktype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Configs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Notification Configs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksMJ_BizApps_Tasks_Tasks_TypeIDArray(@Root() mjbizappstaskstasktype_: mjBizAppsTasksTaskType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('TypeID')}='${mjbizappstaskstasktype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplate_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTemplates_TypeIDArray(@Root() mjbizappstaskstasktype_: mjBizAppsTasksTaskType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('TypeID')}='${mjbizappstaskstasktype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Templates', rows, this.GetUserFromPayload(userPayload));
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
        
    @Field() 
    @MaxLength(255)
    Name: string;
        
    @Field({nullable: true}) 
    Description?: string;
        
    @Field() 
    @MaxLength(36)
    TypeID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CategoryID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field() 
    @MaxLength(50)
    Status: string;
        
    @Field() 
    @MaxLength(20)
    Priority: string;
        
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
        
    @Field(() => Int) 
    PercentComplete: number;
        
    @Field(() => Int) 
    Sequence: number;
        
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
        
    @Field() 
    @MaxLength(100)
    Type: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Category?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Parent?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    CreatedByPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => [mjBizAppsTasksTaskDependency_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies_DependsOnTaskIDArray: mjBizAppsTasksTaskDependency_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies
    
    @Field(() => [mjBizAppsTasksTaskDependency_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies_TaskIDArray: mjBizAppsTasksTaskDependency_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksMJ_BizApps_Tasks_Tasks_ParentIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_Tasks
    
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments_TaskIDArray: mjBizAppsTasksTaskAssignment_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments
    
    @Field(() => [mjBizAppsTasksTaskLink_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskLinks_TaskIDArray: mjBizAppsTasksTaskLink_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskLinks
    
    @Field(() => [mjBizAppsTasksTaskComment_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskComments_TaskIDArray: mjBizAppsTasksTaskComment_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskComments
    
    @Field(() => [mjBizAppsTasksTaskActivity_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskActivities_TaskIDArray: mjBizAppsTasksTaskActivity_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskActivities
    
    @Field(() => [mjBizAppsTasksTaskTagLink_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks_TaskIDArray: mjBizAppsTasksTaskTagLink_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks
    
    @Field(() => [mjBizAppsTasksTaskNotificationLog_])
    mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationLogs_TaskIDArray: mjBizAppsTasksTaskNotificationLog_[]; // Link to mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationLogs
    
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
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Tasks', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskDependency_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies_DependsOnTaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('DependsOnTaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskDependency_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskDependencies_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksMJ_BizApps_Tasks_Tasks_ParentIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskAssignment_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskAssignments_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Assignments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskLink_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskLinks_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskLinks')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskComment_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskComments_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Comments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskActivity_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskActivities_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Activities', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTagLink_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskTagLinks_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Tag Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskNotificationLog_])
    async mjBizAppsTasksMJ_BizApps_Tasks_TaskNotificationLogs_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Task Notification Logs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskNotificationLogs')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Task Notification Logs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ_BizApps_Tasks: Task Notification Logs', rows, this.GetUserFromPayload(userPayload));
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