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


import { mjBizAppsTasksMeetingAgendaItemTypeEntity, mjBizAppsTasksMeetingAgendaItemEntity, mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingLinkEntity, mjBizAppsTasksMeetingNoteEntity, mjBizAppsTasksMeetingSeriesEntity, mjBizAppsTasksMeetingSeriesAttendeeEntity, mjBizAppsTasksMeetingTypeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksTaskActivityEntity, mjBizAppsTasksTaskAssignmentEntity, mjBizAppsTasksTaskCategoryEntity, mjBizAppsTasksTaskCommentEntity, mjBizAppsTasksTaskDecisionOutcomeEntity, mjBizAppsTasksTaskDecisionEntity, mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskLinkEntity, mjBizAppsTasksTaskNotificationConfigEntity, mjBizAppsTasksTaskNotificationLogEntity, mjBizAppsTasksTaskRoleEntity, mjBizAppsTasksTaskTagLinkEntity, mjBizAppsTasksTaskTagEntity, mjBizAppsTasksTaskTemplateItemDependencyEntity, mjBizAppsTasksTaskTemplateItemRoleEntity, mjBizAppsTasksTaskTemplateItemEntity, mjBizAppsTasksTaskTemplateEntity, mjBizAppsTasksTaskTypeStatusEntity, mjBizAppsTasksTaskTypeEntity, mjBizAppsTasksTaskEntity, mjBizAppsTasksVideoProviderEntity } from '@mj-biz-apps/tasks-entities';
    

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Agenda Item Types
//****************************************************************************
@ObjectType({ description: "A kind of agenda item: Information, Discussion, Decision, Report, Presentation, Action review, Break, or one an app adds, such as Committees' Vote. A lookup rather than a fixed list, so apps extend it." })
export class mjBizAppsTasksMeetingAgendaItemType_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The type's display name. Unique."}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true, description: "A stable code apps and agenda templates refer to. Unique."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true, description: "What items of this type are for."}) 
    Description?: string;
        
    @Field({nullable: true, description: "Font Awesome icon class shown beside the item."}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field(() => Int, {nullable: true, description: "How long an item of this type takes unless the agenda says otherwise. More than 0."}) 
    DefaultDurationMinutes?: number;
        
    @Field(() => Boolean, {nullable: true, description: "When false, the type is kept for existing items but not offered for new ones."}) 
    IsActive?: boolean;
        
    @Field(() => Int, {nullable: true, description: "Display order among types."}) 
    Sequence?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Agenda Item Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingAgendaItemTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field(() => Int, { nullable: true })
    DefaultDurationMinutes: number | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Agenda Item Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingAgendaItemTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field(() => Int, { nullable: true })
    DefaultDurationMinutes?: number | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Agenda Item Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingAgendaItemTypeViewResult {
    @Field(() => [mjBizAppsTasksMeetingAgendaItemType_])
    Results: mjBizAppsTasksMeetingAgendaItemType_[];

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

@Resolver(mjBizAppsTasksMeetingAgendaItemType_)
export class mjBizAppsTasksMeetingAgendaItemTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingAgendaItemTypeViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAgendaItemTypeViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAgendaItemTypeViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Agenda Item Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingAgendaItemType_, { nullable: true })
    async mjBizAppsTasksMeetingAgendaItemType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingAgendaItemType_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Agenda Item Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingAgendaItemTypes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Agenda Item Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Agenda Item Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAgendaItemType_)
    async CreatemjBizAppsTasksMeetingAgendaItemType(
        @Arg('input', () => CreatemjBizAppsTasksMeetingAgendaItemTypeInput) input: CreatemjBizAppsTasksMeetingAgendaItemTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Agenda Item Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingAgendaItemType_)
    async UpdatemjBizAppsTasksMeetingAgendaItemType(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingAgendaItemTypeInput) input: UpdatemjBizAppsTasksMeetingAgendaItemTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Agenda Item Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAgendaItemType_)
    async DeletemjBizAppsTasksMeetingAgendaItemType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Agenda Item Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Agenda Items
//****************************************************************************
@ObjectType({ description: "One item on a meeting's agenda, nestable under a parent item of the same meeting, with its type, presenter, planned duration, what happened to it and what was agreed." })
export class mjBizAppsTasksMeetingAgendaItem_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The meeting the item is on the agenda of."}) 
    @MaxLength(36)
    MeetingID?: string;
        
    @Field({nullable: true, description: "The item this one sits under, for a sub-item. Same meeting, no cycle."}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field(() => Int, {nullable: true, description: "Order among its siblings."}) 
    Sequence?: number;
        
    @Field({nullable: true, description: "The item's title."}) 
    @MaxLength(500)
    Name?: string;
        
    @Field({nullable: true, description: "What the item covers, in Markdown."}) 
    Description?: string;
        
    @Field({nullable: true, description: "The agenda item type: Information, Discussion, Decision, and so on."}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field({nullable: true, description: "The person who presents the item."}) 
    @MaxLength(36)
    PresenterPersonID?: string;
        
    @Field(() => Int, {nullable: true, description: "How long the item is planned to take. 0 or more."}) 
    DurationMinutes?: number;
        
    @Field({nullable: true, description: "Planned, InProgress, Done, Deferred or Skipped."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "When the item was started, from the live meeting."}) 
    StartedAt?: Date;
        
    @Field({nullable: true, description: "When the item was ended."}) 
    EndedAt?: Date;
        
    @Field({nullable: true, description: "What was agreed, in a sentence or two."}) 
    Outcome?: string;
        
    @Field({nullable: true, description: "The later meeting a deferred item moved to."}) 
    @MaxLength(36)
    DeferredToMeetingID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Meeting?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    Parent?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Type?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    PresenterPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    DeferredToMeeting?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Agenda Items
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingAgendaItemInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    ParentID: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    TypeID: string | null;

    @Field({ nullable: true })
    PresenterPersonID: string | null;

    @Field(() => Int, { nullable: true })
    DurationMinutes: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    StartedAt: Date | null;

    @Field({ nullable: true })
    EndedAt: Date | null;

    @Field({ nullable: true })
    Outcome: string | null;

    @Field({ nullable: true })
    DeferredToMeetingID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Agenda Items
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingAgendaItemInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    ParentID?: string | null;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    TypeID?: string | null;

    @Field({ nullable: true })
    PresenterPersonID?: string | null;

    @Field(() => Int, { nullable: true })
    DurationMinutes?: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    StartedAt?: Date | null;

    @Field({ nullable: true })
    EndedAt?: Date | null;

    @Field({ nullable: true })
    Outcome?: string | null;

    @Field({ nullable: true })
    DeferredToMeetingID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Agenda Items
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingAgendaItemViewResult {
    @Field(() => [mjBizAppsTasksMeetingAgendaItem_])
    Results: mjBizAppsTasksMeetingAgendaItem_[];

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

@Resolver(mjBizAppsTasksMeetingAgendaItem_)
export class mjBizAppsTasksMeetingAgendaItemResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingAgendaItemViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAgendaItemViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAgendaItemViewResult)
    async RunmjBizAppsTasksMeetingAgendaItemDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Agenda Items';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingAgendaItem_, { nullable: true })
    async mjBizAppsTasksMeetingAgendaItem(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingAgendaItem_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Agenda Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingAgendaItems')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Agenda Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Agenda Items', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAgendaItem_)
    async CreatemjBizAppsTasksMeetingAgendaItem(
        @Arg('input', () => CreatemjBizAppsTasksMeetingAgendaItemInput) input: CreatemjBizAppsTasksMeetingAgendaItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Agenda Items', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingAgendaItem_)
    async UpdatemjBizAppsTasksMeetingAgendaItem(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingAgendaItemInput) input: UpdatemjBizAppsTasksMeetingAgendaItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Agenda Items', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAgendaItem_)
    async DeletemjBizAppsTasksMeetingAgendaItem(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Agenda Items', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Attendees
//****************************************************************************
@ObjectType({ description: "Someone invited to a meeting: a person, or a guest by email address; their answer to the invitation; and whether they came. A meeting has exactly one Organizer row." })
export class mjBizAppsTasksMeetingAttendee_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The meeting the attendee is invited to."}) 
    @MaxLength(36)
    MeetingID?: string;
        
    @Field({nullable: true, description: "The person invited, when they are a Person. Either this or Email is set."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "The person's MemberJunction user, when they have one, filled from the person's account. My meetings and the private-meeting filter use it."}) 
    @MaxLength(36)
    UserID?: string;
        
    @Field({nullable: true, description: "A guest's address, or the address a person's invitation goes to."}) 
    @MaxLength(255)
    Email?: string;
        
    @Field({nullable: true, description: "A guest's name."}) 
    @MaxLength(255)
    DisplayName?: string;
        
    @Field({nullable: true, description: "Organizer, Required or Optional. One Organizer row per meeting, kept in step with Meeting.OrganizerPersonID."}) 
    @MaxLength(20)
    Role?: string;
        
    @Field({nullable: true, description: "The answer to the invitation: None, Accepted, Tentative or Declined."}) 
    @MaxLength(20)
    ResponseStatus?: string;
        
    @Field({nullable: true, description: "When the invitation was answered."}) 
    RespondedAt?: Date;
        
    @Field({nullable: true, description: "Whether they came: Unknown, Present, Late, LeftEarly, Absent or Excused."}) 
    @MaxLength(20)
    AttendanceStatus?: string;
        
    @Field({nullable: true, description: "When they joined, from the live meeting or the video provider."}) 
    JoinedAt?: Date;
        
    @Field({nullable: true, description: "When they left."}) 
    LeftAt?: Date;
        
    @Field({nullable: true, description: "A note on their attendance, such as why someone is excused."}) 
    @MaxLength(500)
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Meeting?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    User?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Attendees
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingAttendeeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    PersonID: string | null;

    @Field({ nullable: true })
    UserID: string | null;

    @Field({ nullable: true })
    Email: string | null;

    @Field({ nullable: true })
    DisplayName: string | null;

    @Field({ nullable: true })
    Role?: string;

    @Field({ nullable: true })
    ResponseStatus?: string;

    @Field({ nullable: true })
    RespondedAt: Date | null;

    @Field({ nullable: true })
    AttendanceStatus?: string;

    @Field({ nullable: true })
    JoinedAt: Date | null;

    @Field({ nullable: true })
    LeftAt: Date | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Attendees
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingAttendeeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    PersonID?: string | null;

    @Field({ nullable: true })
    UserID?: string | null;

    @Field({ nullable: true })
    Email?: string | null;

    @Field({ nullable: true })
    DisplayName?: string | null;

    @Field({ nullable: true })
    Role?: string;

    @Field({ nullable: true })
    ResponseStatus?: string;

    @Field({ nullable: true })
    RespondedAt?: Date | null;

    @Field({ nullable: true })
    AttendanceStatus?: string;

    @Field({ nullable: true })
    JoinedAt?: Date | null;

    @Field({ nullable: true })
    LeftAt?: Date | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Attendees
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingAttendeeViewResult {
    @Field(() => [mjBizAppsTasksMeetingAttendee_])
    Results: mjBizAppsTasksMeetingAttendee_[];

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

@Resolver(mjBizAppsTasksMeetingAttendee_)
export class mjBizAppsTasksMeetingAttendeeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingAttendeeViewResult)
    async RunmjBizAppsTasksMeetingAttendeeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAttendeeViewResult)
    async RunmjBizAppsTasksMeetingAttendeeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingAttendeeViewResult)
    async RunmjBizAppsTasksMeetingAttendeeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Attendees';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingAttendee_, { nullable: true })
    async mjBizAppsTasksMeetingAttendee(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingAttendee_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Attendees', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingAttendees')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Attendees', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Attendees', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAttendee_)
    async CreatemjBizAppsTasksMeetingAttendee(
        @Arg('input', () => CreatemjBizAppsTasksMeetingAttendeeInput) input: CreatemjBizAppsTasksMeetingAttendeeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Attendees', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingAttendee_)
    async UpdatemjBizAppsTasksMeetingAttendee(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingAttendeeInput) input: UpdatemjBizAppsTasksMeetingAttendeeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Attendees', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingAttendee_)
    async DeletemjBizAppsTasksMeetingAttendee(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Attendees', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Links
//****************************************************************************
@ObjectType({ description: "What a meeting or a series belongs to: any record of any entity, the way TaskLink ties a task to a record. Each new occurrence of a series copies the series' links." })
export class mjBizAppsTasksMeetingLink_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The meeting that belongs to the record. Either this or SeriesID is set."}) 
    @MaxLength(36)
    MeetingID?: string;
        
    @Field({nullable: true, description: "The series that belongs to the record. Either this or MeetingID is set."}) 
    @MaxLength(36)
    SeriesID?: string;
        
    @Field({nullable: true, description: "The entity of the record the meeting belongs to."}) 
    @MaxLength(36)
    EntityID?: string;
        
    @Field({nullable: true, description: "The record's primary key, as on TaskLink."}) 
    @MaxLength(450)
    RecordID?: string;
        
    @Field({nullable: true, description: "Why the meeting belongs to the record."}) 
    @MaxLength(500)
    Description?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Meeting?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Series?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Entity?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    MeetingID: string | null;

    @Field({ nullable: true })
    SeriesID: string | null;

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
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    MeetingID?: string | null;

    @Field({ nullable: true })
    SeriesID?: string | null;

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
// RESOLVER for MJ_BizApps_Tasks: Meeting Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingLinkViewResult {
    @Field(() => [mjBizAppsTasksMeetingLink_])
    Results: mjBizAppsTasksMeetingLink_[];

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

@Resolver(mjBizAppsTasksMeetingLink_)
export class mjBizAppsTasksMeetingLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingLinkViewResult)
    async RunmjBizAppsTasksMeetingLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingLinkViewResult)
    async RunmjBizAppsTasksMeetingLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingLinkViewResult)
    async RunmjBizAppsTasksMeetingLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingLink_, { nullable: true })
    async mjBizAppsTasksMeetingLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingLink_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingLinks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingLink_)
    async CreatemjBizAppsTasksMeetingLink(
        @Arg('input', () => CreatemjBizAppsTasksMeetingLinkInput) input: CreatemjBizAppsTasksMeetingLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingLink_)
    async UpdatemjBizAppsTasksMeetingLink(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingLinkInput) input: UpdatemjBizAppsTasksMeetingLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingLink_)
    async DeletemjBizAppsTasksMeetingLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Notes
//****************************************************************************
@ObjectType({ description: "The record of what happened in a meeting, or on one of its agenda items: written by a person, or drafted by AI from a transcript with the tasks it proposes." })
export class mjBizAppsTasksMeetingNote_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The meeting the note is about."}) 
    @MaxLength(36)
    MeetingID?: string;
        
    @Field({nullable: true, description: "The agenda item the note is about, for a note on one item."}) 
    @MaxLength(36)
    AgendaItemID?: string;
        
    @Field({nullable: true, description: "Notes, Summary or Decision."}) 
    @MaxLength(20)
    Kind?: string;
        
    @Field({nullable: true, description: "The note's title."}) 
    @MaxLength(255)
    Title?: string;
        
    @Field({nullable: true, description: "The note, in Markdown."}) 
    Body?: string;
        
    @Field({nullable: true, description: "Manual for a person's note; AI for a draft from a transcript."}) 
    @MaxLength(20)
    Source?: string;
        
    @Field({nullable: true, description: "Draft or Final. Approving minutes is governance and stays with the app that owns it."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "The person who wrote the note, for a person's note."}) 
    @MaxLength(36)
    AuthorPersonID?: string;
        
    @Field({nullable: true, description: "The MJ: AI Prompt Runs record the draft came from, for an AI note."}) 
    @MaxLength(36)
    AIPromptRunID?: string;
        
    @Field({nullable: true, description: "JSON: the action items the notes propose, each with a title, an assignee, a due date, its agenda item, and the task's ID once a person accepted it. Nothing is filed without that approval."}) 
    ProposedTasks?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Meeting?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    AgendaItem?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    AuthorPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    AIPromptRun?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Notes
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingNoteInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    AgendaItemID: string | null;

    @Field({ nullable: true })
    Kind?: string;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    Body?: string;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AuthorPersonID: string | null;

    @Field({ nullable: true })
    AIPromptRunID: string | null;

    @Field({ nullable: true })
    ProposedTasks: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Notes
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingNoteInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    MeetingID?: string;

    @Field({ nullable: true })
    AgendaItemID?: string | null;

    @Field({ nullable: true })
    Kind?: string;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    Body?: string;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AuthorPersonID?: string | null;

    @Field({ nullable: true })
    AIPromptRunID?: string | null;

    @Field({ nullable: true })
    ProposedTasks?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Notes
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingNoteViewResult {
    @Field(() => [mjBizAppsTasksMeetingNote_])
    Results: mjBizAppsTasksMeetingNote_[];

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

@Resolver(mjBizAppsTasksMeetingNote_)
export class mjBizAppsTasksMeetingNoteResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingNoteViewResult)
    async RunmjBizAppsTasksMeetingNoteViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingNoteViewResult)
    async RunmjBizAppsTasksMeetingNoteViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingNoteViewResult)
    async RunmjBizAppsTasksMeetingNoteDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Notes';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingNote_, { nullable: true })
    async mjBizAppsTasksMeetingNote(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingNote_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Notes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingNotes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Notes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Notes', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingNote_)
    async CreatemjBizAppsTasksMeetingNote(
        @Arg('input', () => CreatemjBizAppsTasksMeetingNoteInput) input: CreatemjBizAppsTasksMeetingNoteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Notes', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingNote_)
    async UpdatemjBizAppsTasksMeetingNote(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingNoteInput) input: UpdatemjBizAppsTasksMeetingNoteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Notes', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingNote_)
    async DeletemjBizAppsTasksMeetingNote(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Notes', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Series
//****************************************************************************
@ObjectType({ description: "A recurring meeting. Its occurrences are real Meeting rows, made ahead of time up to a horizon; each keeps its own agenda and attendance, and one can move or be cancelled without touching the rest." })
export class mjBizAppsTasksMeetingSeries_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The series' title. Each new occurrence starts with it."}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true, description: "The series' purpose, in Markdown. Each new occurrence starts with it."}) 
    Description?: string;
        
    @Field({nullable: true, description: "The meeting type each occurrence is made from."}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field({nullable: true, description: "The person who organizes the series. Each occurrence starts with them as its organizer."}) 
    @MaxLength(36)
    OrganizerPersonID?: string;
        
    @Field({nullable: true, description: "An RFC 5545 RRULE value, such as FREQ=WEEKLY;BYDAY=TU. Its UNTIL or COUNT ends the series."}) 
    @MaxLength(500)
    RecurrenceRule?: string;
        
    @Field({nullable: true, description: "The IANA time zone the rule is expanded in, such as America/Chicago, so a 9:00 meeting stays at 9:00 across daylight-saving changes."}) 
    @MaxLength(64)
    TimeZone?: string;
        
    @Field({nullable: true, description: "The rule's DTSTART: when the first occurrence starts."}) 
    FirstStartsAt?: Date;
        
    @Field(() => Int, {nullable: true, description: "How long each occurrence lasts. More than 0."}) 
    DurationMinutes?: number;
        
    @Field({nullable: true, description: "The location each new occurrence starts with: Virtual, InPerson, Hybrid or Phone."}) 
    @MaxLength(20)
    LocationType?: string;
        
    @Field({nullable: true, description: "The room or address each new occurrence starts with."}) 
    @MaxLength(500)
    Location?: string;
        
    @Field({nullable: true, description: "The video provider each new virtual occurrence is hosted on."}) 
    @MaxLength(36)
    VideoProviderID?: string;
        
    @Field({nullable: true, description: "The visibility each new occurrence starts with: Standard, or Private for its attendees only."}) 
    @MaxLength(20)
    Visibility?: string;
        
    @Field({nullable: true, description: "Active while occurrences are still made; Ended once the rule has run out; Cancelled when the series was stopped."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "Occurrences exist up to this point in time. The scheduled job and a save extend it."}) 
    MaterializedThrough?: Date;
        
    @Field({nullable: true, description: "The person who created the series, as Task.CreatedByPersonID."}) 
    @MaxLength(36)
    CreatedByPersonID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Type?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    OrganizerPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    VideoProvider?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    CreatedByPerson?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Series
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingSeriesInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    TypeID: string | null;

    @Field({ nullable: true })
    OrganizerPersonID?: string;

    @Field({ nullable: true })
    RecurrenceRule?: string;

    @Field({ nullable: true })
    TimeZone?: string;

    @Field({ nullable: true })
    FirstStartsAt?: Date;

    @Field(() => Int, { nullable: true })
    DurationMinutes?: number;

    @Field({ nullable: true })
    LocationType?: string;

    @Field({ nullable: true })
    Location: string | null;

    @Field({ nullable: true })
    VideoProviderID: string | null;

    @Field({ nullable: true })
    Visibility?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    MaterializedThrough: Date | null;

    @Field({ nullable: true })
    CreatedByPersonID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Series
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingSeriesInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    TypeID?: string | null;

    @Field({ nullable: true })
    OrganizerPersonID?: string;

    @Field({ nullable: true })
    RecurrenceRule?: string;

    @Field({ nullable: true })
    TimeZone?: string;

    @Field({ nullable: true })
    FirstStartsAt?: Date;

    @Field(() => Int, { nullable: true })
    DurationMinutes?: number;

    @Field({ nullable: true })
    LocationType?: string;

    @Field({ nullable: true })
    Location?: string | null;

    @Field({ nullable: true })
    VideoProviderID?: string | null;

    @Field({ nullable: true })
    Visibility?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    MaterializedThrough?: Date | null;

    @Field({ nullable: true })
    CreatedByPersonID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Series
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingSeriesViewResult {
    @Field(() => [mjBizAppsTasksMeetingSeries_])
    Results: mjBizAppsTasksMeetingSeries_[];

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

@Resolver(mjBizAppsTasksMeetingSeries_)
export class mjBizAppsTasksMeetingSeriesResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingSeriesViewResult)
    async RunmjBizAppsTasksMeetingSeriesViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingSeriesViewResult)
    async RunmjBizAppsTasksMeetingSeriesViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingSeriesViewResult)
    async RunmjBizAppsTasksMeetingSeriesDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Series';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingSeries_, { nullable: true })
    async mjBizAppsTasksMeetingSeries(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingSeries_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Series', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingSeries')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Series', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Series', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingSeries_)
    async CreatemjBizAppsTasksMeetingSeries(
        @Arg('input', () => CreatemjBizAppsTasksMeetingSeriesInput) input: CreatemjBizAppsTasksMeetingSeriesInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Series', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingSeries_)
    async UpdatemjBizAppsTasksMeetingSeries(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingSeriesInput) input: UpdatemjBizAppsTasksMeetingSeriesInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Series', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingSeries_)
    async DeletemjBizAppsTasksMeetingSeries(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Series', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Series Attendees
//****************************************************************************
@ObjectType({ description: "Who each new occurrence of a series invites: a person, or a guest by email address. The organizer comes from the series itself." })
export class mjBizAppsTasksMeetingSeriesAttendee_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The series each new occurrence of which invites this attendee."}) 
    @MaxLength(36)
    SeriesID?: string;
        
    @Field({nullable: true, description: "The person invited, when they are a Person. Either this or Email is set."}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true, description: "The person's MemberJunction user, when they have one, filled from the person's account."}) 
    @MaxLength(36)
    UserID?: string;
        
    @Field({nullable: true, description: "A guest's address, or the address a person's invitation goes to."}) 
    @MaxLength(255)
    Email?: string;
        
    @Field({nullable: true, description: "A guest's name."}) 
    @MaxLength(255)
    DisplayName?: string;
        
    @Field({nullable: true, description: "Required or Optional. The organizer is the series' own."}) 
    @MaxLength(20)
    Role?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Series?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    User?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Series Attendees
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingSeriesAttendeeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    SeriesID?: string;

    @Field({ nullable: true })
    PersonID: string | null;

    @Field({ nullable: true })
    UserID: string | null;

    @Field({ nullable: true })
    Email: string | null;

    @Field({ nullable: true })
    DisplayName: string | null;

    @Field({ nullable: true })
    Role?: string;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Series Attendees
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingSeriesAttendeeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    SeriesID?: string;

    @Field({ nullable: true })
    PersonID?: string | null;

    @Field({ nullable: true })
    UserID?: string | null;

    @Field({ nullable: true })
    Email?: string | null;

    @Field({ nullable: true })
    DisplayName?: string | null;

    @Field({ nullable: true })
    Role?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Series Attendees
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingSeriesAttendeeViewResult {
    @Field(() => [mjBizAppsTasksMeetingSeriesAttendee_])
    Results: mjBizAppsTasksMeetingSeriesAttendee_[];

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

@Resolver(mjBizAppsTasksMeetingSeriesAttendee_)
export class mjBizAppsTasksMeetingSeriesAttendeeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingSeriesAttendeeViewResult)
    async RunmjBizAppsTasksMeetingSeriesAttendeeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingSeriesAttendeeViewResult)
    async RunmjBizAppsTasksMeetingSeriesAttendeeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingSeriesAttendeeViewResult)
    async RunmjBizAppsTasksMeetingSeriesAttendeeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Series Attendees';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingSeriesAttendee_, { nullable: true })
    async mjBizAppsTasksMeetingSeriesAttendee(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingSeriesAttendee_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Series Attendees', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingSeriesAttendees')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Series Attendees', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Series Attendees', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingSeriesAttendee_)
    async CreatemjBizAppsTasksMeetingSeriesAttendee(
        @Arg('input', () => CreatemjBizAppsTasksMeetingSeriesAttendeeInput) input: CreatemjBizAppsTasksMeetingSeriesAttendeeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Series Attendees', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingSeriesAttendee_)
    async UpdatemjBizAppsTasksMeetingSeriesAttendee(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingSeriesAttendeeInput) input: UpdatemjBizAppsTasksMeetingSeriesAttendeeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Series Attendees', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingSeriesAttendee_)
    async DeletemjBizAppsTasksMeetingSeriesAttendee(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Series Attendees', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meeting Types
//****************************************************************************
@ObjectType({ description: "A kind of meeting: General, One-on-one, Team, Client, Review, or one an app adds. Carries the defaults a new meeting of the type starts with and its agenda template." })
export class mjBizAppsTasksMeetingType_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The type's display name. Unique."}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true, description: "A stable code apps refer to, as TaskType.Code. Unique."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true, description: "What meetings of this type are for."}) 
    Description?: string;
        
    @Field({nullable: true, description: "Font Awesome icon class shown beside the type."}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field(() => Int, {nullable: true, description: "How long a new meeting of this type lasts unless the organizer says otherwise. More than 0."}) 
    DefaultDurationMinutes?: number;
        
    @Field({nullable: true, description: "The location a new meeting of this type starts with: Virtual, InPerson, Hybrid or Phone."}) 
    @MaxLength(20)
    DefaultLocationType?: string;
        
    @Field({nullable: true, description: "The video provider a new virtual meeting of this type is hosted on."}) 
    @MaxLength(36)
    DefaultVideoProviderID?: string;
        
    @Field({nullable: true, description: "The visibility a new meeting of this type starts with: Standard or Private."}) 
    @MaxLength(20)
    DefaultVisibility?: string;
        
    @Field({nullable: true, description: "JSON: the agenda a new meeting of this type starts with, as items with a title, an agenda item type code, a duration in minutes and sub-items."}) 
    AgendaTemplate?: string;
        
    @Field({nullable: true, description: "The MJ: AI Prompts record that drafts notes from a transcript for this type, instead of the shipped prompt."}) 
    @MaxLength(36)
    NotesPromptID?: string;
        
    @Field(() => Boolean, {nullable: true, description: "When false, the type is kept for existing meetings but not offered for new ones."}) 
    IsActive?: boolean;
        
    @Field(() => Int, {nullable: true, description: "Display order among types."}) 
    Sequence?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    DefaultVideoProvider?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    NotesPrompt?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field(() => Int, { nullable: true })
    DefaultDurationMinutes: number | null;

    @Field({ nullable: true })
    DefaultLocationType: string | null;

    @Field({ nullable: true })
    DefaultVideoProviderID: string | null;

    @Field({ nullable: true })
    DefaultVisibility: string | null;

    @Field({ nullable: true })
    AgendaTemplate: string | null;

    @Field({ nullable: true })
    NotesPromptID: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meeting Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field(() => Int, { nullable: true })
    DefaultDurationMinutes?: number | null;

    @Field({ nullable: true })
    DefaultLocationType?: string | null;

    @Field({ nullable: true })
    DefaultVideoProviderID?: string | null;

    @Field({ nullable: true })
    DefaultVisibility?: string | null;

    @Field({ nullable: true })
    AgendaTemplate?: string | null;

    @Field({ nullable: true })
    NotesPromptID?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => Int, { nullable: true })
    Sequence?: number;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meeting Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingTypeViewResult {
    @Field(() => [mjBizAppsTasksMeetingType_])
    Results: mjBizAppsTasksMeetingType_[];

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

@Resolver(mjBizAppsTasksMeetingType_)
export class mjBizAppsTasksMeetingTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingTypeViewResult)
    async RunmjBizAppsTasksMeetingTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingTypeViewResult)
    async RunmjBizAppsTasksMeetingTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingTypeViewResult)
    async RunmjBizAppsTasksMeetingTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meeting Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeetingType_, { nullable: true })
    async mjBizAppsTasksMeetingType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeetingType_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meeting Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetingTypes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meeting Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meeting Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeetingType_)
    async CreatemjBizAppsTasksMeetingType(
        @Arg('input', () => CreatemjBizAppsTasksMeetingTypeInput) input: CreatemjBizAppsTasksMeetingTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meeting Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeetingType_)
    async UpdatemjBizAppsTasksMeetingType(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingTypeInput) input: UpdatemjBizAppsTasksMeetingTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meeting Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeetingType_)
    async DeletemjBizAppsTasksMeetingType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meeting Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ_BizApps_Tasks: Meetings
//****************************************************************************
@ObjectType({ description: "One meeting: a single occurrence with its own time, place, attendees, agenda, notes and follow-ups. An occurrence of a series points at its series and keeps the series' original slot as its name." })
export class mjBizAppsTasksMeeting_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The meeting's title, as Task.Name is a task's."}) 
    @MaxLength(255)
    Name?: string;
        
    @Field({nullable: true, description: "The meeting's purpose, in Markdown."}) 
    Description?: string;
        
    @Field({nullable: true, description: "The meeting type it was made from, which gave its defaults and agenda template."}) 
    @MaxLength(36)
    TypeID?: string;
        
    @Field({nullable: true, description: "The series this meeting is an occurrence of, when it is one."}) 
    @MaxLength(36)
    SeriesID?: string;
        
    @Field({nullable: true, description: "The series' original slot for this occurrence. It names the occurrence after it moves, so the series does not make it again. Set with SeriesID, empty without it."}) 
    OccurrenceStartsAt?: Date;
        
    @Field({nullable: true, description: "Draft, Scheduled, Postponed, InProgress, Completed or Cancelled. The server moves it forward: Draft to Scheduled to InProgress to Completed; Scheduled and Postponed either way; anything but Completed may be Cancelled."}) 
    @MaxLength(20)
    Status?: string;
        
    @Field({nullable: true, description: "When the meeting is planned to start."}) 
    StartsAt?: Date;
        
    @Field({nullable: true, description: "When the meeting is planned to end. Later than StartsAt."}) 
    EndsAt?: Date;
        
    @Field({nullable: true, description: "The IANA time zone the meeting is planned in, such as America/Chicago. Display and recurrence use it. Defaults from the organizer's setting, else the business time zone."}) 
    @MaxLength(64)
    TimeZone?: string;
        
    @Field({nullable: true, description: "Virtual, InPerson, Hybrid or Phone."}) 
    @MaxLength(20)
    LocationType?: string;
        
    @Field({nullable: true, description: "A room or an address, for an in-person or hybrid meeting."}) 
    @MaxLength(500)
    Location?: string;
        
    @Field({nullable: true, description: "The video provider the meeting is hosted on, for a virtual or hybrid meeting."}) 
    @MaxLength(36)
    VideoProviderID?: string;
        
    @Field({nullable: true, description: "The provider's own ID for the meeting, kept to update or delete it there."}) 
    @MaxLength(255)
    VideoMeetingID?: string;
        
    @Field({nullable: true, description: "The link attendees join by, from the provider or typed in."}) 
    @MaxLength(1000)
    VideoJoinURL?: string;
        
    @Field({nullable: true, description: "Phone numbers and access codes for joining by phone."}) 
    @MaxLength(1000)
    DialInDetails?: string;
        
    @Field({nullable: true, description: "The person who organizes the meeting. Their calendar holds its event, and the meeting always has their attendee row."}) 
    @MaxLength(36)
    OrganizerPersonID?: string;
        
    @Field({nullable: true, description: "Standard: readable by anyone who reads meetings. Private: readable only by its attendees, the organizer included."}) 
    @MaxLength(20)
    Visibility?: string;
        
    @Field({nullable: true, description: "When the live meeting was started."}) 
    ActualStartedAt?: Date;
        
    @Field({nullable: true, description: "When the live meeting was ended."}) 
    ActualEndedAt?: Date;
        
    @Field({nullable: true, description: "When the meeting was cancelled. Stamped by the server with the status."}) 
    CancelledAt?: Date;
        
    @Field({nullable: true, description: "Why the meeting was cancelled, for its attendees."}) 
    @MaxLength(500)
    CancellationReason?: string;
        
    @Field({nullable: true, description: "Where the provider's recording can be watched."}) 
    @MaxLength(1000)
    VideoRecordingURL?: string;
        
    @Field({nullable: true, description: "The MJ: Files record holding the transcript, uploaded by a person or saved there by the provider's driver. A transcript is a file in MemberJunction's storage, never a URL a user typed."}) 
    @MaxLength(36)
    TranscriptFileID?: string;
        
    @Field({nullable: true, description: "The person who created the meeting, as Task.CreatedByPersonID."}) 
    @MaxLength(36)
    CreatedByPersonID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    Type?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Series?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    VideoProvider?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    OrganizerPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    TranscriptFile?: string;
        
    @Field({nullable: true}) 
    @MaxLength(201)
    CreatedByPerson?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meetings
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksMeetingInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    TypeID: string | null;

    @Field({ nullable: true })
    SeriesID: string | null;

    @Field({ nullable: true })
    OccurrenceStartsAt: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    StartsAt?: Date;

    @Field({ nullable: true })
    EndsAt?: Date;

    @Field({ nullable: true })
    TimeZone?: string;

    @Field({ nullable: true })
    LocationType?: string;

    @Field({ nullable: true })
    Location: string | null;

    @Field({ nullable: true })
    VideoProviderID: string | null;

    @Field({ nullable: true })
    VideoMeetingID: string | null;

    @Field({ nullable: true })
    VideoJoinURL: string | null;

    @Field({ nullable: true })
    DialInDetails: string | null;

    @Field({ nullable: true })
    OrganizerPersonID?: string;

    @Field({ nullable: true })
    Visibility?: string;

    @Field({ nullable: true })
    ActualStartedAt: Date | null;

    @Field({ nullable: true })
    ActualEndedAt: Date | null;

    @Field({ nullable: true })
    CancelledAt: Date | null;

    @Field({ nullable: true })
    CancellationReason: string | null;

    @Field({ nullable: true })
    VideoRecordingURL: string | null;

    @Field({ nullable: true })
    TranscriptFileID: string | null;

    @Field({ nullable: true })
    CreatedByPersonID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Meetings
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksMeetingInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    TypeID?: string | null;

    @Field({ nullable: true })
    SeriesID?: string | null;

    @Field({ nullable: true })
    OccurrenceStartsAt?: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    StartsAt?: Date;

    @Field({ nullable: true })
    EndsAt?: Date;

    @Field({ nullable: true })
    TimeZone?: string;

    @Field({ nullable: true })
    LocationType?: string;

    @Field({ nullable: true })
    Location?: string | null;

    @Field({ nullable: true })
    VideoProviderID?: string | null;

    @Field({ nullable: true })
    VideoMeetingID?: string | null;

    @Field({ nullable: true })
    VideoJoinURL?: string | null;

    @Field({ nullable: true })
    DialInDetails?: string | null;

    @Field({ nullable: true })
    OrganizerPersonID?: string;

    @Field({ nullable: true })
    Visibility?: string;

    @Field({ nullable: true })
    ActualStartedAt?: Date | null;

    @Field({ nullable: true })
    ActualEndedAt?: Date | null;

    @Field({ nullable: true })
    CancelledAt?: Date | null;

    @Field({ nullable: true })
    CancellationReason?: string | null;

    @Field({ nullable: true })
    VideoRecordingURL?: string | null;

    @Field({ nullable: true })
    TranscriptFileID?: string | null;

    @Field({ nullable: true })
    CreatedByPersonID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Meetings
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksMeetingViewResult {
    @Field(() => [mjBizAppsTasksMeeting_])
    Results: mjBizAppsTasksMeeting_[];

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

@Resolver(mjBizAppsTasksMeeting_)
export class mjBizAppsTasksMeetingResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksMeetingViewResult)
    async RunmjBizAppsTasksMeetingViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingViewResult)
    async RunmjBizAppsTasksMeetingViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksMeetingViewResult)
    async RunmjBizAppsTasksMeetingDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Meetings';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksMeeting_, { nullable: true })
    async mjBizAppsTasksMeeting(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksMeeting_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Meetings', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwMeetings')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Meetings', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Meetings', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksMeeting_)
    async CreatemjBizAppsTasksMeeting(
        @Arg('input', () => CreatemjBizAppsTasksMeetingInput) input: CreatemjBizAppsTasksMeetingInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Meetings', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksMeeting_)
    async UpdatemjBizAppsTasksMeeting(
        @Arg('input', () => UpdatemjBizAppsTasksMeetingInput) input: UpdatemjBizAppsTasksMeetingInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Meetings', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksMeeting_)
    async DeletemjBizAppsTasksMeeting(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Meetings', key, options, provider, userPayload, pubSub);
    }
    
}

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
    @MaxLength(201)
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
    @MaxLength(201)
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
    @MaxLength(201)
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
    @MaxLength(201)
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
    @MaxLength(201)
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
// ENTITY CLASS for MJ_BizApps_Tasks: Video Providers
//****************************************************************************
@ObjectType({ description: "A video-conferencing provider a meeting can be hosted on: Zoom, Teams or Google Meet. Its secrets live in MemberJunction's credential store; the row holds only the driver and non-secret settings. Ships inactive until a host configures it." })
export class mjBizAppsTasksVideoProvider_ {
    @Field({description: "Primary key."}) 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true, description: "The provider's display name. Unique."}) 
    @MaxLength(100)
    Name?: string;
        
    @Field({nullable: true, description: "A stable code apps refer to: ZOOM, TEAMS or GOOGLE_MEET. Unique."}) 
    @MaxLength(50)
    Code?: string;
        
    @Field({nullable: true, description: "The class the driver registers with MemberJunction's class factory under VideoProviderBase."}) 
    @MaxLength(255)
    DriverClass?: string;
        
    @Field({nullable: true, description: "What this provider is and when to use it."}) 
    Description?: string;
        
    @Field({nullable: true, description: "Font Awesome icon class shown beside the provider."}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field({nullable: true, description: "The MJ: Credentials record holding the provider's secrets, decrypted through CredentialEngine. Never stored here."}) 
    @MaxLength(36)
    CredentialID?: string;
        
    @Field({nullable: true, description: "JSON: settings that are not secret, such as the organizer account or default meeting options."}) 
    Configuration?: string;
        
    @Field(() => Boolean, {nullable: true, description: "When true, the driver can fetch a transcript of a recorded meeting."}) 
    SupportsTranscripts?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: "When true, this is the provider a new virtual meeting uses unless its type says otherwise. One provider at most."}) 
    IsDefault?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: "When true, the provider is configured and offered. Ships as 0."}) 
    IsActive?: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    Credential?: string;
        
    @Field(() => [String], { nullable: true, description: `Field-level security: when non-null, the fields on this entity the calling user may read. Any other field arriving as null was withheld by the server rather than genuinely empty. Null for callers with no field restrictions.` })
    ReadableFields___?: string[];
        
}

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Video Providers
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksVideoProviderInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    DriverClass?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field({ nullable: true })
    CredentialID: string | null;

    @Field({ nullable: true })
    Configuration: string | null;

    @Field(() => Boolean, { nullable: true })
    SupportsTranscripts?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsDefault?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for MJ_BizApps_Tasks: Video Providers
//****************************************************************************
@InputType()
export class UpdatemjBizAppsTasksVideoProviderInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    DriverClass?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field({ nullable: true })
    CredentialID?: string | null;

    @Field({ nullable: true })
    Configuration?: string | null;

    @Field(() => Boolean, { nullable: true })
    SupportsTranscripts?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsDefault?: boolean;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for MJ_BizApps_Tasks: Video Providers
//****************************************************************************
@ObjectType()
export class RunmjBizAppsTasksVideoProviderViewResult {
    @Field(() => [mjBizAppsTasksVideoProvider_])
    Results: mjBizAppsTasksVideoProvider_[];

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

@Resolver(mjBizAppsTasksVideoProvider_)
export class mjBizAppsTasksVideoProviderResolver extends ResolverBase {
    @Query(() => RunmjBizAppsTasksVideoProviderViewResult)
    async RunmjBizAppsTasksVideoProviderViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksVideoProviderViewResult)
    async RunmjBizAppsTasksVideoProviderViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsTasksVideoProviderViewResult)
    async RunmjBizAppsTasksVideoProviderDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ_BizApps_Tasks: Video Providers';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksVideoProvider_, { nullable: true })
    async mjBizAppsTasksVideoProvider(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksVideoProvider_ | null> {
        this.CheckUserReadPermissions('MJ_BizApps_Tasks: Video Providers', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwVideoProviders')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'MJ_BizApps_Tasks: Video Providers', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ_BizApps_Tasks: Video Providers', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksVideoProvider_)
    async CreatemjBizAppsTasksVideoProvider(
        @Arg('input', () => CreatemjBizAppsTasksVideoProviderInput) input: CreatemjBizAppsTasksVideoProviderInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ_BizApps_Tasks: Video Providers', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksVideoProvider_)
    async UpdatemjBizAppsTasksVideoProvider(
        @Arg('input', () => UpdatemjBizAppsTasksVideoProviderInput) input: UpdatemjBizAppsTasksVideoProviderInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ_BizApps_Tasks: Video Providers', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksVideoProvider_)
    async DeletemjBizAppsTasksVideoProvider(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ_BizApps_Tasks: Video Providers', key, options, provider, userPayload, pubSub);
    }
    
}