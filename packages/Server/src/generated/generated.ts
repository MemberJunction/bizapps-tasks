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
            GetReadOnlyProvider, GetReadWriteProvider } from '@memberjunction/server';
import { Metadata, EntityPermissionType, CompositeKey, UserInfo } from '@memberjunction/core'

import { MaxLength } from 'class-validator';
import * as mj_core_schema_server_object_types from '@memberjunction/server'


import { mjBizAppsCommonAddressLinkEntity, mjBizAppsCommonAddressTypeEntity, mjBizAppsCommonAddressEntity, mjBizAppsCommonContactMethodEntity, mjBizAppsCommonContactTypeEntity, mjBizAppsCommonOrganizationTypeEntity, mjBizAppsCommonOrganizationEntity, mjBizAppsCommonPersonEntity, mjBizAppsCommonRelationshipTypeEntity, mjBizAppsCommonRelationshipEntity, mjBizAppsTasksTaskActivityEntity, mjBizAppsTasksTaskAssignmentEntity, mjBizAppsTasksTaskCategoryEntity, mjBizAppsTasksTaskCommentEntity, mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskLinkEntity, mjBizAppsTasksTaskRoleEntity, mjBizAppsTasksTaskTagLinkEntity, mjBizAppsTasksTaskTagEntity, mjBizAppsTasksTaskTemplateItemDependencyEntity, mjBizAppsTasksTaskTemplateItemRoleEntity, mjBizAppsTasksTaskTemplateItemEntity, mjBizAppsTasksTaskTemplateEntity, mjBizAppsTasksTaskTypeEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
    

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Address Links
//****************************************************************************
@ObjectType({ description: `Polymorphic link table connecting Address records to any entity record in the system via EntityID and RecordID` })
export class mjBizAppsCommonAddressLink_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    AddressID: string;
        
    @Field() 
    @MaxLength(36)
    EntityID: string;
        
    @Field({description: `Primary key value(s) of the linked record. NVARCHAR(700) to support concatenated composite keys for entities without single-valued primary keys`}) 
    @MaxLength(700)
    RecordID: string;
        
    @Field() 
    @MaxLength(36)
    AddressTypeID: string;
        
    @Field(() => Boolean, {description: `Whether this is the primary address for the linked record. Only one address per entity record should be marked primary`}) 
    IsPrimary: boolean;
        
    @Field(() => Int, {nullable: true, description: `Sort order override for this specific link. When NULL, falls back to AddressType.DefaultRank. Lower values appear first`}) 
    Rank?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(255)
    Address: string;
        
    @Field() 
    @MaxLength(255)
    Entity: string;
        
    @Field() 
    @MaxLength(100)
    AddressType: string;
        
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Address Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonAddressLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    AddressID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    AddressTypeID?: string;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;

    @Field(() => Int, { nullable: true })
    Rank: number | null;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Address Links
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonAddressLinkInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    AddressID?: string;

    @Field({ nullable: true })
    EntityID?: string;

    @Field({ nullable: true })
    RecordID?: string;

    @Field({ nullable: true })
    AddressTypeID?: string;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;

    @Field(() => Int, { nullable: true })
    Rank?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Address Links
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonAddressLinkViewResult {
    @Field(() => [mjBizAppsCommonAddressLink_])
    Results: mjBizAppsCommonAddressLink_[];

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

@Resolver(mjBizAppsCommonAddressLink_)
export class mjBizAppsCommonAddressLinkResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonAddressLinkViewResult)
    async RunmjBizAppsCommonAddressLinkViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressLinkViewResult)
    async RunmjBizAppsCommonAddressLinkViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressLinkViewResult)
    async RunmjBizAppsCommonAddressLinkDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Address Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonAddressLink_, { nullable: true })
    async mjBizAppsCommonAddressLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonAddressLink_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Address Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwAddressLinks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Address Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Address Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsCommonAddressLink_)
    async CreatemjBizAppsCommonAddressLink(
        @Arg('input', () => CreatemjBizAppsCommonAddressLinkInput) input: CreatemjBizAppsCommonAddressLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Address Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonAddressLink_)
    async UpdatemjBizAppsCommonAddressLink(
        @Arg('input', () => UpdatemjBizAppsCommonAddressLinkInput) input: UpdatemjBizAppsCommonAddressLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Address Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonAddressLink_)
    async DeletemjBizAppsCommonAddressLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Address Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Address Types
//****************************************************************************
@ObjectType({ description: `Categories of addresses such as Home, Work, Mailing, Billing` })
export class mjBizAppsCommonAddressType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Display name for the address type`}) 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true, description: `Detailed description of this address type`}) 
    Description?: string;
        
    @Field({nullable: true, description: `Font Awesome icon class for UI display`}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field(() => Int, {description: `Default sort order for this address type in dropdown lists. Lower values appear first. Can be overridden per-record via AddressLink.Rank`}) 
    DefaultRank: number;
        
    @Field(() => Boolean, {description: `Whether this type is available for selection in the UI. Inactive types are hidden from dropdowns but preserved for existing records`}) 
    IsActive: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsCommonAddressLink_])
    mjBizAppsCommonAddressLinks_AddressTypeIDArray: mjBizAppsCommonAddressLink_[]; // Link to mjBizAppsCommonAddressLinks
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Address Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonAddressTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field(() => Int, { nullable: true })
    DefaultRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Address Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonAddressTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field(() => Int, { nullable: true })
    DefaultRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Address Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonAddressTypeViewResult {
    @Field(() => [mjBizAppsCommonAddressType_])
    Results: mjBizAppsCommonAddressType_[];

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

@Resolver(mjBizAppsCommonAddressType_)
export class mjBizAppsCommonAddressTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonAddressTypeViewResult)
    async RunmjBizAppsCommonAddressTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressTypeViewResult)
    async RunmjBizAppsCommonAddressTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressTypeViewResult)
    async RunmjBizAppsCommonAddressTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Address Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonAddressType_, { nullable: true })
    async mjBizAppsCommonAddressType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonAddressType_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Address Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwAddressTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Address Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Address Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonAddressLink_])
    async mjBizAppsCommonAddressLinks_AddressTypeIDArray(@Root() mjbizappscommonaddresstype_: mjBizAppsCommonAddressType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Address Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwAddressLinks')} WHERE ${provider.QuoteIdentifier('AddressTypeID')}='${mjbizappscommonaddresstype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Address Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Address Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonAddressType_)
    async CreatemjBizAppsCommonAddressType(
        @Arg('input', () => CreatemjBizAppsCommonAddressTypeInput) input: CreatemjBizAppsCommonAddressTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Address Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonAddressType_)
    async UpdatemjBizAppsCommonAddressType(
        @Arg('input', () => UpdatemjBizAppsCommonAddressTypeInput) input: UpdatemjBizAppsCommonAddressTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Address Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonAddressType_)
    async DeletemjBizAppsCommonAddressType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Address Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Addresses
//****************************************************************************
@ObjectType({ description: `Standalone physical address records linked to entities via AddressLink for sharing across people and organizations` })
export class mjBizAppsCommonAddress_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Street address line 1`}) 
    @MaxLength(255)
    Line1: string;
        
    @Field({nullable: true, description: `Street address line 2 (suite, apt, etc.)`}) 
    @MaxLength(255)
    Line2?: string;
        
    @Field({nullable: true, description: `Street address line 3 (additional detail)`}) 
    @MaxLength(255)
    Line3?: string;
        
    @Field({description: `City or locality name`}) 
    @MaxLength(100)
    City: string;
        
    @Field({nullable: true, description: `State, province, or region`}) 
    @MaxLength(100)
    StateProvince?: string;
        
    @Field({nullable: true, description: `Postal or ZIP code`}) 
    @MaxLength(20)
    PostalCode?: string;
        
    @Field({description: `Country code or name, defaults to US`}) 
    @MaxLength(100)
    Country: string;
        
    @Field(() => Float, {nullable: true, description: `Geographic latitude for mapping`}) 
    Latitude?: number;
        
    @Field(() => Float, {nullable: true, description: `Geographic longitude for mapping`}) 
    Longitude?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsCommonAddressLink_])
    mjBizAppsCommonAddressLinks_AddressIDArray: mjBizAppsCommonAddressLink_[]; // Link to mjBizAppsCommonAddressLinks
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Addresses
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonAddressInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Line1?: string;

    @Field({ nullable: true })
    Line2: string | null;

    @Field({ nullable: true })
    Line3: string | null;

    @Field({ nullable: true })
    City?: string;

    @Field({ nullable: true })
    StateProvince: string | null;

    @Field({ nullable: true })
    PostalCode: string | null;

    @Field({ nullable: true })
    Country?: string;

    @Field(() => Float, { nullable: true })
    Latitude: number | null;

    @Field(() => Float, { nullable: true })
    Longitude: number | null;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Addresses
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonAddressInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Line1?: string;

    @Field({ nullable: true })
    Line2?: string | null;

    @Field({ nullable: true })
    Line3?: string | null;

    @Field({ nullable: true })
    City?: string;

    @Field({ nullable: true })
    StateProvince?: string | null;

    @Field({ nullable: true })
    PostalCode?: string | null;

    @Field({ nullable: true })
    Country?: string;

    @Field(() => Float, { nullable: true })
    Latitude?: number | null;

    @Field(() => Float, { nullable: true })
    Longitude?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Addresses
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonAddressViewResult {
    @Field(() => [mjBizAppsCommonAddress_])
    Results: mjBizAppsCommonAddress_[];

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

@Resolver(mjBizAppsCommonAddress_)
export class mjBizAppsCommonAddressResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonAddressViewResult)
    async RunmjBizAppsCommonAddressViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressViewResult)
    async RunmjBizAppsCommonAddressViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonAddressViewResult)
    async RunmjBizAppsCommonAddressDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Addresses';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonAddress_, { nullable: true })
    async mjBizAppsCommonAddress(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonAddress_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Addresses', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwAddresses')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Addresses', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Addresses', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonAddressLink_])
    async mjBizAppsCommonAddressLinks_AddressIDArray(@Root() mjbizappscommonaddress_: mjBizAppsCommonAddress_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Address Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwAddressLinks')} WHERE ${provider.QuoteIdentifier('AddressID')}='${mjbizappscommonaddress_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Address Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Address Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonAddress_)
    async CreatemjBizAppsCommonAddress(
        @Arg('input', () => CreatemjBizAppsCommonAddressInput) input: CreatemjBizAppsCommonAddressInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Addresses', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonAddress_)
    async UpdatemjBizAppsCommonAddress(
        @Arg('input', () => UpdatemjBizAppsCommonAddressInput) input: UpdatemjBizAppsCommonAddressInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Addresses', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonAddress_)
    async DeletemjBizAppsCommonAddress(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Addresses', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Contact Methods
//****************************************************************************
@ObjectType({ description: `Additional contact methods for people and organizations beyond the primary email and phone fields` })
export class mjBizAppsCommonContactMethod_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    PersonID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OrganizationID?: string;
        
    @Field() 
    @MaxLength(36)
    ContactTypeID: string;
        
    @Field({description: `The contact value: phone number, email address, URL, social media handle, etc.`}) 
    @MaxLength(500)
    Value: string;
        
    @Field({nullable: true, description: `Descriptive label such as Work cell, Personal Gmail, Corporate LinkedIn`}) 
    @MaxLength(100)
    Label?: string;
        
    @Field(() => Boolean, {description: `Whether this is the primary contact method of its type for the linked person or organization`}) 
    IsPrimary: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(244)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Organization?: string;
        
    @Field() 
    @MaxLength(100)
    ContactType: string;
        
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Contact Methods
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonContactMethodInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    PersonID: string | null;

    @Field({ nullable: true })
    OrganizationID: string | null;

    @Field({ nullable: true })
    ContactTypeID?: string;

    @Field({ nullable: true })
    Value?: string;

    @Field({ nullable: true })
    Label: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Contact Methods
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonContactMethodInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    PersonID?: string | null;

    @Field({ nullable: true })
    OrganizationID?: string | null;

    @Field({ nullable: true })
    ContactTypeID?: string;

    @Field({ nullable: true })
    Value?: string;

    @Field({ nullable: true })
    Label?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Contact Methods
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonContactMethodViewResult {
    @Field(() => [mjBizAppsCommonContactMethod_])
    Results: mjBizAppsCommonContactMethod_[];

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

@Resolver(mjBizAppsCommonContactMethod_)
export class mjBizAppsCommonContactMethodResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonContactMethodViewResult)
    async RunmjBizAppsCommonContactMethodViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonContactMethodViewResult)
    async RunmjBizAppsCommonContactMethodViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonContactMethodViewResult)
    async RunmjBizAppsCommonContactMethodDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Contact Methods';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonContactMethod_, { nullable: true })
    async mjBizAppsCommonContactMethod(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonContactMethod_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Contact Methods', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwContactMethods')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Contact Methods', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Contact Methods', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsCommonContactMethod_)
    async CreatemjBizAppsCommonContactMethod(
        @Arg('input', () => CreatemjBizAppsCommonContactMethodInput) input: CreatemjBizAppsCommonContactMethodInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Contact Methods', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonContactMethod_)
    async UpdatemjBizAppsCommonContactMethod(
        @Arg('input', () => UpdatemjBizAppsCommonContactMethodInput) input: UpdatemjBizAppsCommonContactMethodInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Contact Methods', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonContactMethod_)
    async DeletemjBizAppsCommonContactMethod(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Contact Methods', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Contact Types
//****************************************************************************
@ObjectType({ description: `Categories of contact methods such as Phone, Mobile, Email, LinkedIn, Website` })
export class mjBizAppsCommonContactType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Display name for the contact type`}) 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true, description: `Detailed description of this contact type`}) 
    Description?: string;
        
    @Field({nullable: true, description: `Font Awesome icon class for UI display`}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field(() => Int, {description: `Sort order in dropdown lists. Lower values appear first`}) 
    DisplayRank: number;
        
    @Field(() => Boolean, {description: `Whether this type is available for selection in the UI. Inactive types are hidden from dropdowns but preserved for existing records`}) 
    IsActive: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsCommonContactMethod_])
    mjBizAppsCommonContactMethods_ContactTypeIDArray: mjBizAppsCommonContactMethod_[]; // Link to mjBizAppsCommonContactMethods
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Contact Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonContactTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field(() => Int, { nullable: true })
    DisplayRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Contact Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonContactTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field(() => Int, { nullable: true })
    DisplayRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Contact Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonContactTypeViewResult {
    @Field(() => [mjBizAppsCommonContactType_])
    Results: mjBizAppsCommonContactType_[];

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

@Resolver(mjBizAppsCommonContactType_)
export class mjBizAppsCommonContactTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonContactTypeViewResult)
    async RunmjBizAppsCommonContactTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonContactTypeViewResult)
    async RunmjBizAppsCommonContactTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonContactTypeViewResult)
    async RunmjBizAppsCommonContactTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Contact Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonContactType_, { nullable: true })
    async mjBizAppsCommonContactType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonContactType_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Contact Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwContactTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Contact Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Contact Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonContactMethod_])
    async mjBizAppsCommonContactMethods_ContactTypeIDArray(@Root() mjbizappscommoncontacttype_: mjBizAppsCommonContactType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Contact Methods', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwContactMethods')} WHERE ${provider.QuoteIdentifier('ContactTypeID')}='${mjbizappscommoncontacttype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Contact Methods', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Contact Methods', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonContactType_)
    async CreatemjBizAppsCommonContactType(
        @Arg('input', () => CreatemjBizAppsCommonContactTypeInput) input: CreatemjBizAppsCommonContactTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Contact Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonContactType_)
    async UpdatemjBizAppsCommonContactType(
        @Arg('input', () => UpdatemjBizAppsCommonContactTypeInput) input: UpdatemjBizAppsCommonContactTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Contact Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonContactType_)
    async DeletemjBizAppsCommonContactType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Contact Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Organization Types
//****************************************************************************
@ObjectType({ description: `Categories of organizations such as Company, Non-Profit, Association, Government` })
export class mjBizAppsCommonOrganizationType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Display name for the organization type`}) 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true, description: `Detailed description of this organization type`}) 
    Description?: string;
        
    @Field({nullable: true, description: `Font Awesome icon class for UI display`}) 
    @MaxLength(100)
    IconClass?: string;
        
    @Field(() => Int, {description: `Sort order in dropdown lists. Lower values appear first`}) 
    DisplayRank: number;
        
    @Field(() => Boolean, {description: `Whether this type is available for selection in the UI. Inactive types are hidden from dropdowns but preserved for existing records`}) 
    IsActive: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsCommonOrganization_])
    mjBizAppsCommonOrganizations_OrganizationTypeIDArray: mjBizAppsCommonOrganization_[]; // Link to mjBizAppsCommonOrganizations
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Organization Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonOrganizationTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    IconClass: string | null;

    @Field(() => Int, { nullable: true })
    DisplayRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Organization Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonOrganizationTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    IconClass?: string | null;

    @Field(() => Int, { nullable: true })
    DisplayRank?: number;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Organization Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonOrganizationTypeViewResult {
    @Field(() => [mjBizAppsCommonOrganizationType_])
    Results: mjBizAppsCommonOrganizationType_[];

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

@Resolver(mjBizAppsCommonOrganizationType_)
export class mjBizAppsCommonOrganizationTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonOrganizationTypeViewResult)
    async RunmjBizAppsCommonOrganizationTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonOrganizationTypeViewResult)
    async RunmjBizAppsCommonOrganizationTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonOrganizationTypeViewResult)
    async RunmjBizAppsCommonOrganizationTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Organization Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonOrganizationType_, { nullable: true })
    async mjBizAppsCommonOrganizationType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonOrganizationType_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Organization Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwOrganizationTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Organization Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Organization Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonOrganization_])
    async mjBizAppsCommonOrganizations_OrganizationTypeIDArray(@Root() mjbizappscommonorganizationtype_: mjBizAppsCommonOrganizationType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Organizations', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwOrganizationsExtended')} WHERE ${provider.QuoteIdentifier('OrganizationTypeID')}='${mjbizappscommonorganizationtype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Organizations', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Organizations', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonOrganizationType_)
    async CreatemjBizAppsCommonOrganizationType(
        @Arg('input', () => CreatemjBizAppsCommonOrganizationTypeInput) input: CreatemjBizAppsCommonOrganizationTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Organization Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonOrganizationType_)
    async UpdatemjBizAppsCommonOrganizationType(
        @Arg('input', () => UpdatemjBizAppsCommonOrganizationTypeInput) input: UpdatemjBizAppsCommonOrganizationTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Organization Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonOrganizationType_)
    async DeletemjBizAppsCommonOrganizationType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Organization Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Organizations
//****************************************************************************
@ObjectType({ description: `Companies, associations, government bodies, and other organizations with hierarchy support` })
export class mjBizAppsCommonOrganization_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Common or display name of the organization`}) 
    @MaxLength(255)
    Name: string;
        
    @Field({nullable: true, description: `Full legal name if different from display name`}) 
    @MaxLength(255)
    LegalName?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    OrganizationTypeID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParentID?: string;
        
    @Field({nullable: true, description: `Primary website URL`}) 
    @MaxLength(1000)
    Website?: string;
        
    @Field({nullable: true, description: `URL to organization logo image`}) 
    @MaxLength(1000)
    LogoURL?: string;
        
    @Field({nullable: true, description: `Description of the organization purpose and scope`}) 
    Description?: string;
        
    @Field({nullable: true, description: `Primary contact email address`}) 
    @MaxLength(255)
    Email?: string;
        
    @Field({nullable: true, description: `Primary phone number`}) 
    @MaxLength(50)
    Phone?: string;
        
    @Field({nullable: true, description: `Date the organization was founded or incorporated`}) 
    FoundedDate?: Date;
        
    @Field({nullable: true, description: `Tax identification number such as EIN`}) 
    @MaxLength(50)
    TaxID?: string;
        
    @Field({description: `Current status: Active, Inactive, or Dissolved`}) 
    @MaxLength(50)
    Status: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    OrganizationType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    Parent?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    PrimaryAddressLine1?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    PrimaryAddressLine2?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressCity?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressState?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    PrimaryAddressPostalCode?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressCountry?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    PrimaryEmail?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    PrimaryPhone?: string;
        
    @Field(() => Int, {nullable: true}) 
    ActivePersonCount?: number;
        
    @Field(() => Int, {nullable: true}) 
    ChildOrgCount?: number;
        
    @Field(() => [mjBizAppsCommonOrganization_])
    mjBizAppsCommonOrganizations_ParentIDArray: mjBizAppsCommonOrganization_[]; // Link to mjBizAppsCommonOrganizations
    
    @Field(() => [mjBizAppsCommonRelationship_])
    mjBizAppsCommonRelationships_ToOrganizationIDArray: mjBizAppsCommonRelationship_[]; // Link to mjBizAppsCommonRelationships
    
    @Field(() => [mjBizAppsCommonContactMethod_])
    mjBizAppsCommonContactMethods_OrganizationIDArray: mjBizAppsCommonContactMethod_[]; // Link to mjBizAppsCommonContactMethods
    
    @Field(() => [mjBizAppsCommonRelationship_])
    mjBizAppsCommonRelationships_FromOrganizationIDArray: mjBizAppsCommonRelationship_[]; // Link to mjBizAppsCommonRelationships
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Organizations
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonOrganizationInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    LegalName: string | null;

    @Field({ nullable: true })
    OrganizationTypeID: string | null;

    @Field({ nullable: true })
    ParentID: string | null;

    @Field({ nullable: true })
    Website: string | null;

    @Field({ nullable: true })
    LogoURL: string | null;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    Email: string | null;

    @Field({ nullable: true })
    Phone: string | null;

    @Field({ nullable: true })
    FoundedDate: Date | null;

    @Field({ nullable: true })
    TaxID: string | null;

    @Field({ nullable: true })
    Status?: string;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Organizations
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonOrganizationInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    LegalName?: string | null;

    @Field({ nullable: true })
    OrganizationTypeID?: string | null;

    @Field({ nullable: true })
    ParentID?: string | null;

    @Field({ nullable: true })
    Website?: string | null;

    @Field({ nullable: true })
    LogoURL?: string | null;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    Email?: string | null;

    @Field({ nullable: true })
    Phone?: string | null;

    @Field({ nullable: true })
    FoundedDate?: Date | null;

    @Field({ nullable: true })
    TaxID?: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Organizations
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonOrganizationViewResult {
    @Field(() => [mjBizAppsCommonOrganization_])
    Results: mjBizAppsCommonOrganization_[];

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

@Resolver(mjBizAppsCommonOrganization_)
export class mjBizAppsCommonOrganizationResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonOrganizationViewResult)
    async RunmjBizAppsCommonOrganizationViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonOrganizationViewResult)
    async RunmjBizAppsCommonOrganizationViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonOrganizationViewResult)
    async RunmjBizAppsCommonOrganizationDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Organizations';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonOrganization_, { nullable: true })
    async mjBizAppsCommonOrganization(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonOrganization_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Organizations', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwOrganizationsExtended')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Organizations', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Organizations', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonOrganization_])
    async mjBizAppsCommonOrganizations_ParentIDArray(@Root() mjbizappscommonorganization_: mjBizAppsCommonOrganization_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Organizations', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwOrganizationsExtended')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappscommonorganization_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Organizations', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Organizations', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonRelationship_])
    async mjBizAppsCommonRelationships_ToOrganizationIDArray(@Root() mjbizappscommonorganization_: mjBizAppsCommonOrganization_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('ToOrganizationID')}='${mjbizappscommonorganization_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonContactMethod_])
    async mjBizAppsCommonContactMethods_OrganizationIDArray(@Root() mjbizappscommonorganization_: mjBizAppsCommonOrganization_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Contact Methods', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwContactMethods')} WHERE ${provider.QuoteIdentifier('OrganizationID')}='${mjbizappscommonorganization_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Contact Methods', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Contact Methods', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonRelationship_])
    async mjBizAppsCommonRelationships_FromOrganizationIDArray(@Root() mjbizappscommonorganization_: mjBizAppsCommonOrganization_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('FromOrganizationID')}='${mjbizappscommonorganization_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonOrganization_)
    async CreatemjBizAppsCommonOrganization(
        @Arg('input', () => CreatemjBizAppsCommonOrganizationInput) input: CreatemjBizAppsCommonOrganizationInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Organizations', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonOrganization_)
    async UpdatemjBizAppsCommonOrganization(
        @Arg('input', () => UpdatemjBizAppsCommonOrganizationInput) input: UpdatemjBizAppsCommonOrganizationInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Organizations', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonOrganization_)
    async DeletemjBizAppsCommonOrganization(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Organizations', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: People
//****************************************************************************
@ObjectType({ description: `Individual people, optionally linked to MJ system user accounts` })
export class mjBizAppsCommonPerson_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `First (given) name`}) 
    @MaxLength(100)
    FirstName: string;
        
    @Field({description: `Last (family) name`}) 
    @MaxLength(100)
    LastName: string;
        
    @Field({nullable: true, description: `Middle name or initial`}) 
    @MaxLength(100)
    MiddleName?: string;
        
    @Field({nullable: true, description: `Name prefix such as Dr., Mr., Ms., Rev.`}) 
    @MaxLength(20)
    Prefix?: string;
        
    @Field({nullable: true, description: `Name suffix such as Jr., III, PhD, Esq.`}) 
    @MaxLength(20)
    Suffix?: string;
        
    @Field({nullable: true, description: `Nickname or preferred name the person goes by`}) 
    @MaxLength(100)
    PreferredName?: string;
        
    @Field({nullable: true, description: `Professional or job title, e.g. VP of Engineering, Board Director`}) 
    @MaxLength(200)
    Title?: string;
        
    @Field({nullable: true, description: `Primary email address for this person`}) 
    @MaxLength(255)
    Email?: string;
        
    @Field({nullable: true, description: `Primary phone number for this person`}) 
    @MaxLength(50)
    Phone?: string;
        
    @Field({nullable: true, description: `Date of birth`}) 
    DateOfBirth?: Date;
        
    @Field({nullable: true, description: `Gender identity`}) 
    @MaxLength(50)
    Gender?: string;
        
    @Field({nullable: true, description: `URL to profile photo or avatar image`}) 
    @MaxLength(1000)
    PhotoURL?: string;
        
    @Field({nullable: true, description: `Biographical text or notes about this person`}) 
    Bio?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    LinkedUserID?: string;
        
    @Field({description: `Current status: Active, Inactive, or Deceased`}) 
    @MaxLength(50)
    Status: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    LinkedUser?: string;
        
    @Field({nullable: true}) 
    @MaxLength(244)
    DisplayName?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    PrimaryAddressLine1?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    PrimaryAddressLine2?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressCity?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressState?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    PrimaryAddressPostalCode?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressCountry?: string;
        
    @Field(() => Float, {nullable: true}) 
    PrimaryAddressLatitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    PrimaryAddressLongitude?: number;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    PrimaryAddressType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    PrimaryEmail?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    PrimaryPhone?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    CurrentOrganizationID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    CurrentOrganizationName?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    CurrentJobTitle?: string;
        
    @Field(() => [mjBizAppsTasksTaskActivity_])
    mjBizAppsTasksTaskActivities_PersonIDArray: mjBizAppsTasksTaskActivity_[]; // Link to mjBizAppsTasksTaskActivities
    
    @Field(() => [mjBizAppsTasksTaskComment_])
    mjBizAppsTasksTaskComments_PersonIDArray: mjBizAppsTasksTaskComment_[]; // Link to mjBizAppsTasksTaskComments
    
    @Field(() => [mjBizAppsCommonContactMethod_])
    mjBizAppsCommonContactMethods_PersonIDArray: mjBizAppsCommonContactMethod_[]; // Link to mjBizAppsCommonContactMethods
    
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    mjBizAppsTasksTaskAssignments_AssignedByPersonIDArray: mjBizAppsTasksTaskAssignment_[]; // Link to mjBizAppsTasksTaskAssignments
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksTasks_CreatedByPersonIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksTasks
    
    @Field(() => [mjBizAppsCommonRelationship_])
    mjBizAppsCommonRelationships_ToPersonIDArray: mjBizAppsCommonRelationship_[]; // Link to mjBizAppsCommonRelationships
    
    @Field(() => [mjBizAppsCommonRelationship_])
    mjBizAppsCommonRelationships_FromPersonIDArray: mjBizAppsCommonRelationship_[]; // Link to mjBizAppsCommonRelationships
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: People
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonPersonInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    FirstName?: string;

    @Field({ nullable: true })
    LastName?: string;

    @Field({ nullable: true })
    MiddleName: string | null;

    @Field({ nullable: true })
    Prefix: string | null;

    @Field({ nullable: true })
    Suffix: string | null;

    @Field({ nullable: true })
    PreferredName: string | null;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    Email: string | null;

    @Field({ nullable: true })
    Phone: string | null;

    @Field({ nullable: true })
    DateOfBirth: Date | null;

    @Field({ nullable: true })
    Gender: string | null;

    @Field({ nullable: true })
    PhotoURL: string | null;

    @Field({ nullable: true })
    Bio: string | null;

    @Field({ nullable: true })
    LinkedUserID: string | null;

    @Field({ nullable: true })
    Status?: string;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: People
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonPersonInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    FirstName?: string;

    @Field({ nullable: true })
    LastName?: string;

    @Field({ nullable: true })
    MiddleName?: string | null;

    @Field({ nullable: true })
    Prefix?: string | null;

    @Field({ nullable: true })
    Suffix?: string | null;

    @Field({ nullable: true })
    PreferredName?: string | null;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    Email?: string | null;

    @Field({ nullable: true })
    Phone?: string | null;

    @Field({ nullable: true })
    DateOfBirth?: Date | null;

    @Field({ nullable: true })
    Gender?: string | null;

    @Field({ nullable: true })
    PhotoURL?: string | null;

    @Field({ nullable: true })
    Bio?: string | null;

    @Field({ nullable: true })
    LinkedUserID?: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: People
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonPersonViewResult {
    @Field(() => [mjBizAppsCommonPerson_])
    Results: mjBizAppsCommonPerson_[];

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

@Resolver(mjBizAppsCommonPerson_)
export class mjBizAppsCommonPersonResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonPersonViewResult)
    async RunmjBizAppsCommonPersonViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonPersonViewResult)
    async RunmjBizAppsCommonPersonViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonPersonViewResult)
    async RunmjBizAppsCommonPersonDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: People';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonPerson_, { nullable: true })
    async mjBizAppsCommonPerson(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonPerson_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: People', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwPeopleExtended')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: People', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: People', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskActivity_])
    async mjBizAppsTasksTaskActivities_PersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('PersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Activities', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskComment_])
    async mjBizAppsTasksTaskComments_PersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('PersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Comments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonContactMethod_])
    async mjBizAppsCommonContactMethods_PersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Contact Methods', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwContactMethods')} WHERE ${provider.QuoteIdentifier('PersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Contact Methods', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Contact Methods', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskAssignment_])
    async mjBizAppsTasksTaskAssignments_AssignedByPersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('AssignedByPersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Assignments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksTasks_CreatedByPersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('CreatedByPersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonRelationship_])
    async mjBizAppsCommonRelationships_ToPersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('ToPersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsCommonRelationship_])
    async mjBizAppsCommonRelationships_FromPersonIDArray(@Root() mjbizappscommonperson_: mjBizAppsCommonPerson_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('FromPersonID')}='${mjbizappscommonperson_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonPerson_)
    async CreatemjBizAppsCommonPerson(
        @Arg('input', () => CreatemjBizAppsCommonPersonInput) input: CreatemjBizAppsCommonPersonInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: People', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonPerson_)
    async UpdatemjBizAppsCommonPerson(
        @Arg('input', () => UpdatemjBizAppsCommonPersonInput) input: UpdatemjBizAppsCommonPersonInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: People', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonPerson_)
    async DeletemjBizAppsCommonPerson(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: People', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Relationship Types
//****************************************************************************
@ObjectType({ description: `Defines types of relationships between people and organizations with directionality and labeling` })
export class mjBizAppsCommonRelationshipType_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Display name for the relationship type, e.g. Employee, Spouse, Partner`}) 
    @MaxLength(100)
    Name: string;
        
    @Field({nullable: true, description: `Detailed description of this relationship type`}) 
    Description?: string;
        
    @Field({description: `Which entity types this relationship connects: PersonToPerson, PersonToOrganization, or OrganizationToOrganization`}) 
    @MaxLength(50)
    Category: string;
        
    @Field(() => Boolean, {description: `Whether the relationship has a direction. False for symmetric relationships like Spouse or Partner`}) 
    IsDirectional: boolean;
        
    @Field({nullable: true, description: `Label describing the From-to-To direction, e.g. is employee of, is parent of`}) 
    @MaxLength(100)
    ForwardLabel?: string;
        
    @Field({nullable: true, description: `Label describing the To-to-From direction, e.g. employs, is child of`}) 
    @MaxLength(100)
    ReverseLabel?: string;
        
    @Field(() => Boolean, {description: `Whether this type is available for selection in the UI. Inactive types are hidden from dropdowns but preserved for existing records`}) 
    IsActive: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [mjBizAppsCommonRelationship_])
    mjBizAppsCommonRelationships_RelationshipTypeIDArray: mjBizAppsCommonRelationship_[]; // Link to mjBizAppsCommonRelationships
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Relationship Types
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonRelationshipTypeInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description: string | null;

    @Field({ nullable: true })
    Category?: string;

    @Field(() => Boolean, { nullable: true })
    IsDirectional?: boolean;

    @Field({ nullable: true })
    ForwardLabel: string | null;

    @Field({ nullable: true })
    ReverseLabel: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Relationship Types
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonRelationshipTypeInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Description?: string | null;

    @Field({ nullable: true })
    Category?: string;

    @Field(() => Boolean, { nullable: true })
    IsDirectional?: boolean;

    @Field({ nullable: true })
    ForwardLabel?: string | null;

    @Field({ nullable: true })
    ReverseLabel?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsActive?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Relationship Types
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonRelationshipTypeViewResult {
    @Field(() => [mjBizAppsCommonRelationshipType_])
    Results: mjBizAppsCommonRelationshipType_[];

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

@Resolver(mjBizAppsCommonRelationshipType_)
export class mjBizAppsCommonRelationshipTypeResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonRelationshipTypeViewResult)
    async RunmjBizAppsCommonRelationshipTypeViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonRelationshipTypeViewResult)
    async RunmjBizAppsCommonRelationshipTypeViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonRelationshipTypeViewResult)
    async RunmjBizAppsCommonRelationshipTypeDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Relationship Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonRelationshipType_, { nullable: true })
    async mjBizAppsCommonRelationshipType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonRelationshipType_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationship Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationshipTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationship Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Relationship Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsCommonRelationship_])
    async mjBizAppsCommonRelationships_RelationshipTypeIDArray(@Root() mjbizappscommonrelationshiptype_: mjBizAppsCommonRelationshipType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('RelationshipTypeID')}='${mjbizappscommonrelationshiptype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsCommonRelationshipType_)
    async CreatemjBizAppsCommonRelationshipType(
        @Arg('input', () => CreatemjBizAppsCommonRelationshipTypeInput) input: CreatemjBizAppsCommonRelationshipTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Relationship Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonRelationshipType_)
    async UpdatemjBizAppsCommonRelationshipType(
        @Arg('input', () => UpdatemjBizAppsCommonRelationshipTypeInput) input: UpdatemjBizAppsCommonRelationshipTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Relationship Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonRelationshipType_)
    async DeletemjBizAppsCommonRelationshipType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Relationship Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Common: Relationships
//****************************************************************************
@ObjectType({ description: `Typed, directional links between people and organizations supporting Person-to-Person, Person-to-Organization, and Organization-to-Organization relationships` })
export class mjBizAppsCommonRelationship_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    RelationshipTypeID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    FromPersonID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    FromOrganizationID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ToPersonID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ToOrganizationID?: string;
        
    @Field({nullable: true, description: `Contextual title for this specific relationship, e.g. CEO, Primary Contact, Founding Member`}) 
    @MaxLength(255)
    Title?: string;
        
    @Field({nullable: true, description: `Date the relationship began`}) 
    StartDate?: Date;
        
    @Field({nullable: true, description: `Date the relationship ended, if applicable`}) 
    EndDate?: Date;
        
    @Field({description: `Current status: Active, Inactive, or Ended`}) 
    @MaxLength(50)
    Status: string;
        
    @Field({nullable: true, description: `Additional notes about this relationship`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(100)
    RelationshipType: string;
        
    @Field({nullable: true}) 
    @MaxLength(244)
    FromPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    FromOrganization?: string;
        
    @Field({nullable: true}) 
    @MaxLength(244)
    ToPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(255)
    ToOrganization?: string;
        
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Relationships
//****************************************************************************
@InputType()
export class CreatemjBizAppsCommonRelationshipInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    RelationshipTypeID?: string;

    @Field({ nullable: true })
    FromPersonID: string | null;

    @Field({ nullable: true })
    FromOrganizationID: string | null;

    @Field({ nullable: true })
    ToPersonID: string | null;

    @Field({ nullable: true })
    ToOrganizationID: string | null;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    StartDate: Date | null;

    @Field({ nullable: true })
    EndDate: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    Notes: string | null;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Common: Relationships
//****************************************************************************
@InputType()
export class UpdatemjBizAppsCommonRelationshipInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    RelationshipTypeID?: string;

    @Field({ nullable: true })
    FromPersonID?: string | null;

    @Field({ nullable: true })
    FromOrganizationID?: string | null;

    @Field({ nullable: true })
    ToPersonID?: string | null;

    @Field({ nullable: true })
    ToOrganizationID?: string | null;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    StartDate?: Date | null;

    @Field({ nullable: true })
    EndDate?: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Common: Relationships
//****************************************************************************
@ObjectType()
export class RunmjBizAppsCommonRelationshipViewResult {
    @Field(() => [mjBizAppsCommonRelationship_])
    Results: mjBizAppsCommonRelationship_[];

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

@Resolver(mjBizAppsCommonRelationship_)
export class mjBizAppsCommonRelationshipResolver extends ResolverBase {
    @Query(() => RunmjBizAppsCommonRelationshipViewResult)
    async RunmjBizAppsCommonRelationshipViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonRelationshipViewResult)
    async RunmjBizAppsCommonRelationshipViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunmjBizAppsCommonRelationshipViewResult)
    async RunmjBizAppsCommonRelationshipDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'MJ.BizApps.Common: Relationships';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsCommonRelationship_, { nullable: true })
    async mjBizAppsCommonRelationship(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsCommonRelationship_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Common: Relationships', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsCommon', 'vwRelationships')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Common: Relationships', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Common: Relationships', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsCommonRelationship_)
    async CreatemjBizAppsCommonRelationship(
        @Arg('input', () => CreatemjBizAppsCommonRelationshipInput) input: CreatemjBizAppsCommonRelationshipInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Common: Relationships', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsCommonRelationship_)
    async UpdatemjBizAppsCommonRelationship(
        @Arg('input', () => UpdatemjBizAppsCommonRelationshipInput) input: UpdatemjBizAppsCommonRelationshipInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Common: Relationships', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsCommonRelationship_)
    async DeletemjBizAppsCommonRelationship(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Common: Relationships', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Activities
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
    @MaxLength(244)
    Person?: string;
        
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Activities
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Activities
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Activities
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Activities';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskActivity_, { nullable: true })
    async mjBizAppsTasksTaskActivity(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskActivity_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Activities', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async CreatemjBizAppsTasksTaskActivity(
        @Arg('input', () => CreatemjBizAppsTasksTaskActivityInput) input: CreatemjBizAppsTasksTaskActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Activities', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async UpdatemjBizAppsTasksTaskActivity(
        @Arg('input', () => UpdatemjBizAppsTasksTaskActivityInput) input: UpdatemjBizAppsTasksTaskActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Activities', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskActivity_)
    async DeletemjBizAppsTasksTaskActivity(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Activities', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Assignments
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
    @MaxLength(244)
    AssignedByPerson?: string;
        
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Assignments
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Assignments
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Assignments
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Assignments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskAssignment_, { nullable: true })
    async mjBizAppsTasksTaskAssignment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskAssignment_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Assignments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async CreatemjBizAppsTasksTaskAssignment(
        @Arg('input', () => CreatemjBizAppsTasksTaskAssignmentInput) input: CreatemjBizAppsTasksTaskAssignmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Assignments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async UpdatemjBizAppsTasksTaskAssignment(
        @Arg('input', () => UpdatemjBizAppsTasksTaskAssignmentInput) input: UpdatemjBizAppsTasksTaskAssignmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Assignments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskAssignment_)
    async DeletemjBizAppsTasksTaskAssignment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Assignments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Categories
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
        
    @Field(() => [mjBizAppsTasksTaskCategory_])
    mjBizAppsTasksTaskCategories_ParentIDArray: mjBizAppsTasksTaskCategory_[]; // Link to mjBizAppsTasksTaskCategories
    
    @Field(() => [mjBizAppsTasksTaskTemplate_])
    mjBizAppsTasksTaskTemplates_CategoryIDArray: mjBizAppsTasksTaskTemplate_[]; // Link to mjBizAppsTasksTaskTemplates
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksTasks_CategoryIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksTasks
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Categories
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Categories
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Categories
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Categories';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskCategory_, { nullable: true })
    async mjBizAppsTasksTaskCategory(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskCategory_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Categories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCategories')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Categories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Categories', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskCategory_])
    async mjBizAppsTasksTaskCategories_ParentIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Categories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskCategories')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Categories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Categories', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplate_])
    async mjBizAppsTasksTaskTemplates_CategoryIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('CategoryID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Templates', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksTasks_CategoryIDArray(@Root() mjbizappstaskstaskcategory_: mjBizAppsTasksTaskCategory_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('CategoryID')}='${mjbizappstaskstaskcategory_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async CreatemjBizAppsTasksTaskCategory(
        @Arg('input', () => CreatemjBizAppsTasksTaskCategoryInput) input: CreatemjBizAppsTasksTaskCategoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Categories', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async UpdatemjBizAppsTasksTaskCategory(
        @Arg('input', () => UpdatemjBizAppsTasksTaskCategoryInput) input: UpdatemjBizAppsTasksTaskCategoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Categories', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskCategory_)
    async DeletemjBizAppsTasksTaskCategory(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Categories', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Comments
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
        
    @Field({nullable: true}) 
    @MaxLength(244)
    Person?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => [mjBizAppsTasksTaskComment_])
    mjBizAppsTasksTaskComments_ParentIDArray: mjBizAppsTasksTaskComment_[]; // Link to mjBizAppsTasksTaskComments
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Comments
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Comments
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Comments
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Comments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskComment_, { nullable: true })
    async mjBizAppsTasksTaskComment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskComment_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Comments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskComment_])
    async mjBizAppsTasksTaskComments_ParentIDArray(@Root() mjbizappstaskstaskcomment_: mjBizAppsTasksTaskComment_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstaskcomment_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Comments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async CreatemjBizAppsTasksTaskComment(
        @Arg('input', () => CreatemjBizAppsTasksTaskCommentInput) input: CreatemjBizAppsTasksTaskCommentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Comments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async UpdatemjBizAppsTasksTaskComment(
        @Arg('input', () => UpdatemjBizAppsTasksTaskCommentInput) input: UpdatemjBizAppsTasksTaskCommentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Comments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskComment_)
    async DeletemjBizAppsTasksTaskComment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Comments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Dependencies
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
// INPUT TYPE for MJ.BizApps.Tasks: Task Dependencies
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Dependencies
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Dependencies
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Dependencies';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskDependency_, { nullable: true })
    async mjBizAppsTasksTaskDependency(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskDependency_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Dependencies', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async CreatemjBizAppsTasksTaskDependency(
        @Arg('input', () => CreatemjBizAppsTasksTaskDependencyInput) input: CreatemjBizAppsTasksTaskDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Dependencies', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async UpdatemjBizAppsTasksTaskDependency(
        @Arg('input', () => UpdatemjBizAppsTasksTaskDependencyInput) input: UpdatemjBizAppsTasksTaskDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Dependencies', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskDependency_)
    async DeletemjBizAppsTasksTaskDependency(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Dependencies', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Links
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
// INPUT TYPE for MJ.BizApps.Tasks: Task Links
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Links
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Links
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskLink_, { nullable: true })
    async mjBizAppsTasksTaskLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskLink_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskLinks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async CreatemjBizAppsTasksTaskLink(
        @Arg('input', () => CreatemjBizAppsTasksTaskLinkInput) input: CreatemjBizAppsTasksTaskLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async UpdatemjBizAppsTasksTaskLink(
        @Arg('input', () => UpdatemjBizAppsTasksTaskLinkInput) input: UpdatemjBizAppsTasksTaskLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskLink_)
    async DeletemjBizAppsTasksTaskLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Roles
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
        
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    mjBizAppsTasksTaskAssignments_RoleIDArray: mjBizAppsTasksTaskAssignment_[]; // Link to mjBizAppsTasksTaskAssignments
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemRole_])
    mjBizAppsTasksTaskTemplateItemRoles_RoleIDArray: mjBizAppsTasksTaskTemplateItemRole_[]; // Link to mjBizAppsTasksTaskTemplateItemRoles
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Roles
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Roles
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Roles
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Roles';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskRole_, { nullable: true })
    async mjBizAppsTasksTaskRole(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskRole_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskRoles')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Roles', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskAssignment_])
    async mjBizAppsTasksTaskAssignments_RoleIDArray(@Root() mjbizappstaskstaskrole_: mjBizAppsTasksTaskRole_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('RoleID')}='${mjbizappstaskstaskrole_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Assignments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemRole_])
    async mjBizAppsTasksTaskTemplateItemRoles_RoleIDArray(@Root() mjbizappstaskstaskrole_: mjBizAppsTasksTaskRole_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('RoleID')}='${mjbizappstaskstaskrole_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Roles', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async CreatemjBizAppsTasksTaskRole(
        @Arg('input', () => CreatemjBizAppsTasksTaskRoleInput) input: CreatemjBizAppsTasksTaskRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Roles', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async UpdatemjBizAppsTasksTaskRole(
        @Arg('input', () => UpdatemjBizAppsTasksTaskRoleInput) input: UpdatemjBizAppsTasksTaskRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Roles', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskRole_)
    async DeletemjBizAppsTasksTaskRole(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Roles', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Tag Links
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
// INPUT TYPE for MJ.BizApps.Tasks: Task Tag Links
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTagLinkInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    TaskID?: string;

    @Field({ nullable: true })
    TagID?: string;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Tag Links
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Tag Links
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Tag Links';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTagLink_, { nullable: true })
    async mjBizAppsTasksTaskTagLink(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTagLink_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Tag Links', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async CreatemjBizAppsTasksTaskTagLink(
        @Arg('input', () => CreatemjBizAppsTasksTaskTagLinkInput) input: CreatemjBizAppsTasksTaskTagLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Tag Links', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async UpdatemjBizAppsTasksTaskTagLink(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTagLinkInput) input: UpdatemjBizAppsTasksTaskTagLinkInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Tag Links', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTagLink_)
    async DeletemjBizAppsTasksTaskTagLink(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Tag Links', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Tags
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
    mjBizAppsTasksTaskTagLinks_TagIDArray: mjBizAppsTasksTaskTagLink_[]; // Link to mjBizAppsTasksTaskTagLinks
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Tags
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Tags
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Tags
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Tags';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTag_, { nullable: true })
    async mjBizAppsTasksTaskTag(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTag_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Tags', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTags')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Tags', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Tags', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTagLink_])
    async mjBizAppsTasksTaskTagLinks_TagIDArray(@Root() mjbizappstaskstasktag_: mjBizAppsTasksTaskTag_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('TagID')}='${mjbizappstaskstasktag_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Tag Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async CreatemjBizAppsTasksTaskTag(
        @Arg('input', () => CreatemjBizAppsTasksTaskTagInput) input: CreatemjBizAppsTasksTaskTagInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Tags', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async UpdatemjBizAppsTasksTaskTag(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTagInput) input: UpdatemjBizAppsTasksTaskTagInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Tags', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTag_)
    async DeletemjBizAppsTasksTaskTag(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Tags', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Template Item Dependencies
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
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Item Dependencies
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Item Dependencies
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Template Item Dependencies
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Template Item Dependencies';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItemDependency_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItemDependency(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItemDependency_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Dependencies', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async CreatemjBizAppsTasksTaskTemplateItemDependency(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemDependencyInput) input: CreatemjBizAppsTasksTaskTemplateItemDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Template Item Dependencies', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async UpdatemjBizAppsTasksTaskTemplateItemDependency(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemDependencyInput) input: UpdatemjBizAppsTasksTaskTemplateItemDependencyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Template Item Dependencies', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemDependency_)
    async DeletemjBizAppsTasksTaskTemplateItemDependency(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Template Item Dependencies', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Template Item Roles
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
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Item Roles
//****************************************************************************
@InputType()
export class CreatemjBizAppsTasksTaskTemplateItemRoleInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ItemID?: string;

    @Field({ nullable: true })
    RoleID?: string;
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Item Roles
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Template Item Roles
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Template Item Roles';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItemRole_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItemRole(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItemRole_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Roles', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async CreatemjBizAppsTasksTaskTemplateItemRole(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemRoleInput) input: CreatemjBizAppsTasksTaskTemplateItemRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Template Item Roles', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async UpdatemjBizAppsTasksTaskTemplateItemRole(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemRoleInput) input: UpdatemjBizAppsTasksTaskTemplateItemRoleInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Template Item Roles', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItemRole_)
    async DeletemjBizAppsTasksTaskTemplateItemRole(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Template Item Roles', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Template Items
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
        
    @Field(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    mjBizAppsTasksTaskTemplateItemDependencies_DependsOnItemIDArray: mjBizAppsTasksTaskTemplateItemDependency_[]; // Link to mjBizAppsTasksTaskTemplateItemDependencies
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemRole_])
    mjBizAppsTasksTaskTemplateItemRoles_ItemIDArray: mjBizAppsTasksTaskTemplateItemRole_[]; // Link to mjBizAppsTasksTaskTemplateItemRoles
    
    @Field(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    mjBizAppsTasksTaskTemplateItemDependencies_ItemIDArray: mjBizAppsTasksTaskTemplateItemDependency_[]; // Link to mjBizAppsTasksTaskTemplateItemDependencies
    
    @Field(() => [mjBizAppsTasksTaskTemplateItem_])
    mjBizAppsTasksTaskTemplateItems_ParentItemIDArray: mjBizAppsTasksTaskTemplateItem_[]; // Link to mjBizAppsTasksTaskTemplateItems
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Items
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Template Items
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Template Items
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Template Items';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplateItem_, { nullable: true })
    async mjBizAppsTasksTaskTemplateItem(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplateItem_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Items', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    async mjBizAppsTasksTaskTemplateItemDependencies_DependsOnItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('DependsOnItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemRole_])
    async mjBizAppsTasksTaskTemplateItemRoles_ItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Roles', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemRoles')} WHERE ${provider.QuoteIdentifier('ItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Roles', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Roles', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItemDependency_])
    async mjBizAppsTasksTaskTemplateItemDependencies_ItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItemDependencies')} WHERE ${provider.QuoteIdentifier('ItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Item Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Item Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItem_])
    async mjBizAppsTasksTaskTemplateItems_ParentItemIDArray(@Root() mjbizappstaskstasktemplateitem_: mjBizAppsTasksTaskTemplateItem_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('ParentItemID')}='${mjbizappstaskstasktemplateitem_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Items', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async CreatemjBizAppsTasksTaskTemplateItem(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateItemInput) input: CreatemjBizAppsTasksTaskTemplateItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Template Items', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async UpdatemjBizAppsTasksTaskTemplateItem(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateItemInput) input: UpdatemjBizAppsTasksTaskTemplateItemInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Template Items', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplateItem_)
    async DeletemjBizAppsTasksTaskTemplateItem(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Template Items', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Templates
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
    mjBizAppsTasksTaskTemplateItems_TemplateIDArray: mjBizAppsTasksTaskTemplateItem_[]; // Link to mjBizAppsTasksTaskTemplateItems
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Templates
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Templates
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Templates
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Templates';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskTemplate_, { nullable: true })
    async mjBizAppsTasksTaskTemplate(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskTemplate_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Templates', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskTemplateItem_])
    async mjBizAppsTasksTaskTemplateItems_TemplateIDArray(@Root() mjbizappstaskstasktemplate_: mjBizAppsTasksTaskTemplate_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Template Items', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplateItems')} WHERE ${provider.QuoteIdentifier('TemplateID')}='${mjbizappstaskstasktemplate_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Template Items', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Template Items', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async CreatemjBizAppsTasksTaskTemplate(
        @Arg('input', () => CreatemjBizAppsTasksTaskTemplateInput) input: CreatemjBizAppsTasksTaskTemplateInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Templates', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async UpdatemjBizAppsTasksTaskTemplate(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTemplateInput) input: UpdatemjBizAppsTasksTaskTemplateInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Templates', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskTemplate_)
    async DeletemjBizAppsTasksTaskTemplate(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Templates', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Task Types
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
        
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksTasks_TypeIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksTasks
    
    @Field(() => [mjBizAppsTasksTaskTemplate_])
    mjBizAppsTasksTaskTemplates_TypeIDArray: mjBizAppsTasksTaskTemplate_[]; // Link to mjBizAppsTasksTaskTemplates
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Types
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Task Types
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
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Task Types
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
        input.EntityName = 'MJ.BizApps.Tasks: Task Types';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTaskType_, { nullable: true })
    async mjBizAppsTasksTaskType(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTaskType_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Types', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTypes')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Types', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Types', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksTasks_TypeIDArray(@Root() mjbizappstaskstasktype_: mjBizAppsTasksTaskType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('TypeID')}='${mjbizappstaskstasktype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTemplate_])
    async mjBizAppsTasksTaskTemplates_TypeIDArray(@Root() mjbizappstaskstasktype_: mjBizAppsTasksTaskType_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Templates', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTemplates')} WHERE ${provider.QuoteIdentifier('TypeID')}='${mjbizappstaskstasktype_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Templates', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Templates', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTaskType_)
    async CreatemjBizAppsTasksTaskType(
        @Arg('input', () => CreatemjBizAppsTasksTaskTypeInput) input: CreatemjBizAppsTasksTaskTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Task Types', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTaskType_)
    async UpdatemjBizAppsTasksTaskType(
        @Arg('input', () => UpdatemjBizAppsTasksTaskTypeInput) input: UpdatemjBizAppsTasksTaskTypeInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Task Types', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTaskType_)
    async DeletemjBizAppsTasksTaskType(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Task Types', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for MJ.BizApps.Tasks: Tasks
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
    @MaxLength(244)
    CreatedByPerson?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    RootParentID?: string;
        
    @Field(() => [mjBizAppsTasksTaskDependency_])
    mjBizAppsTasksTaskDependencies_TaskIDArray: mjBizAppsTasksTaskDependency_[]; // Link to mjBizAppsTasksTaskDependencies
    
    @Field(() => [mjBizAppsTasksTaskTagLink_])
    mjBizAppsTasksTaskTagLinks_TaskIDArray: mjBizAppsTasksTaskTagLink_[]; // Link to mjBizAppsTasksTaskTagLinks
    
    @Field(() => [mjBizAppsTasksTaskDependency_])
    mjBizAppsTasksTaskDependencies_DependsOnTaskIDArray: mjBizAppsTasksTaskDependency_[]; // Link to mjBizAppsTasksTaskDependencies
    
    @Field(() => [mjBizAppsTasksTaskLink_])
    mjBizAppsTasksTaskLinks_TaskIDArray: mjBizAppsTasksTaskLink_[]; // Link to mjBizAppsTasksTaskLinks
    
    @Field(() => [mjBizAppsTasksTaskActivity_])
    mjBizAppsTasksTaskActivities_TaskIDArray: mjBizAppsTasksTaskActivity_[]; // Link to mjBizAppsTasksTaskActivities
    
    @Field(() => [mjBizAppsTasksTaskComment_])
    mjBizAppsTasksTaskComments_TaskIDArray: mjBizAppsTasksTaskComment_[]; // Link to mjBizAppsTasksTaskComments
    
    @Field(() => [mjBizAppsTasksTask_])
    mjBizAppsTasksTasks_ParentIDArray: mjBizAppsTasksTask_[]; // Link to mjBizAppsTasksTasks
    
    @Field(() => [mjBizAppsTasksTaskAssignment_])
    mjBizAppsTasksTaskAssignments_TaskIDArray: mjBizAppsTasksTaskAssignment_[]; // Link to mjBizAppsTasksTaskAssignments
    
}

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Tasks
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
}
    

//****************************************************************************
// INPUT TYPE for MJ.BizApps.Tasks: Tasks
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

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];
}
    
//****************************************************************************
// RESOLVER for MJ.BizApps.Tasks: Tasks
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
        input.EntityName = 'MJ.BizApps.Tasks: Tasks';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => mjBizAppsTasksTask_, { nullable: true })
    async mjBizAppsTasksTask(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<mjBizAppsTasksTask_ | null> {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('ID')}='${ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('MJ.BizApps.Tasks: Tasks', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [mjBizAppsTasksTaskDependency_])
    async mjBizAppsTasksTaskDependencies_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskTagLink_])
    async mjBizAppsTasksTaskTagLinks_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Tag Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskTagLinks')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Tag Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Tag Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskDependency_])
    async mjBizAppsTasksTaskDependencies_DependsOnTaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Dependencies', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskDependencies')} WHERE ${provider.QuoteIdentifier('DependsOnTaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Dependencies', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Dependencies', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskLink_])
    async mjBizAppsTasksTaskLinks_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Links', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskLinks')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Links', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Links', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskActivity_])
    async mjBizAppsTasksTaskActivities_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskActivities')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Activities', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskComment_])
    async mjBizAppsTasksTaskComments_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Comments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskComments')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Comments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Comments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTask_])
    async mjBizAppsTasksTasks_ParentIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTasks')} WHERE ${provider.QuoteIdentifier('ParentID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [mjBizAppsTasksTaskAssignment_])
    async mjBizAppsTasksTaskAssignments_TaskIDArray(@Root() mjbizappstaskstask_: mjBizAppsTasksTask_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('MJ.BizApps.Tasks: Task Assignments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('__mj_BizAppsTasks', 'vwTaskAssignments')} WHERE ${provider.QuoteIdentifier('TaskID')}='${mjbizappstaskstask_.ID}' ` + this.getRowLevelSecurityWhereClause(provider, 'MJ.BizApps.Tasks: Task Assignments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, undefined, undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('MJ.BizApps.Tasks: Task Assignments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => mjBizAppsTasksTask_)
    async CreatemjBizAppsTasksTask(
        @Arg('input', () => CreatemjBizAppsTasksTaskInput) input: CreatemjBizAppsTasksTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('MJ.BizApps.Tasks: Tasks', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => mjBizAppsTasksTask_)
    async UpdatemjBizAppsTasksTask(
        @Arg('input', () => UpdatemjBizAppsTasksTaskInput) input: UpdatemjBizAppsTasksTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('MJ.BizApps.Tasks: Tasks', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => mjBizAppsTasksTask_)
    async DeletemjBizAppsTasksTask(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('MJ.BizApps.Tasks: Tasks', key, options, provider, userPayload, pubSub);
    }
    
}