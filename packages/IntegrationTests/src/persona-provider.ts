/**
 * A check that must read or write as someone other than the harness user (a UI-only attendee, an organizer) gets a
 * GraphQL provider signed in as that person: the harness user mints the person an API key with full access, a second
 * GraphQLDataProvider is configured with it, and the keys are deleted when the bundle ends. Lifted from
 * bizapps-collaboration's harness, client transport only.
 */
import { UserInfo, type IMetadataProvider } from '@memberjunction/core';
import { BaseSingleton, GetGlobalObjectStore, UUIDsEqual } from '@memberjunction/global';
import { GraphQLDataProvider, GraphQLProviderConfigData } from '@memberjunction/graphql-dataprovider';
import { GetAPIKeyEngine } from '@memberjunction/api-keys';
import type { MJAPIKeyEntity, MJAPIKeyScopeEntity } from '@memberjunction/core-entities';
import { LoadClientConfig } from '@memberjunction/testing-integration';
import { Assert, type IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { View } from './wire.js';

const GRAPHQL_PROVIDER_SINGLETON_KEY = '___SINGLETON__GraphQLDataProvider';
const USER_ENTITY = 'MJ: Users';
const USER_ROLE_ENTITY = 'MJ: User Roles';

const personaCache = new Map<string, UserInfo>();

/** The MemberJunction user with this email, with their roles, as a UserInfo the provider can act for. */
export async function GetPersonaUser(ctx: IntegrationCheckContext, email: string): Promise<UserInfo> {
    const key = email.toLowerCase();
    const cached = personaCache.get(key);
    if (cached) return cached;
    const view = View(ctx);
    const users = await view.RunView<{ ID: string; Name: string; FirstName: string; LastName: string; Email: string; Type: string; IsActive: boolean }>(
        { EntityName: USER_ENTITY, ExtraFilter: `Email = '${key.replace(/'/g, "''")}'`, Fields: ['ID', 'Name', 'FirstName', 'LastName', 'Email', 'Type', 'IsActive'], MaxRows: 1, ResultType: 'simple' },
        ctx.User,
    );
    Assert(users.Success && (users.Results?.length ?? 0) > 0, `User with email ${email} not found.`);
    const raw = users.Results![0];
    const roles = await view.RunView<{ UserID: string; RoleID: string; Role: string }>(
        { EntityName: USER_ROLE_ENTITY, ExtraFilter: `UserID = '${raw.ID}'`, Fields: ['UserID', 'RoleID', 'Role'], ResultType: 'simple' },
        ctx.User,
    );
    const user = new UserInfo(ctx.Provider as IMetadataProvider, {
        ID: raw.ID,
        Name: raw.Name,
        FirstName: raw.FirstName,
        LastName: raw.LastName,
        Email: raw.Email,
        Type: raw.Type,
        IsActive: raw.IsActive,
        UserRoles: (roles.Results ?? []).map((r) => ({ UserID: raw.ID, RoleID: r.RoleID, Role: r.Role })),
    });
    personaCache.set(key, user);
    return user;
}

function newSecondaryGraphQLProvider(): GraphQLDataProvider {
    const store = GetGlobalObjectStore();
    const singleton = store?.[GRAPHQL_PROVIDER_SINGLETON_KEY];
    if (store) delete store[GRAPHQL_PROVIDER_SINGLETON_KEY];
    try {
        return new GraphQLDataProvider();
    } finally {
        if (store && singleton) store[GRAPHQL_PROVIDER_SINGLETON_KEY] = singleton;
    }
}

async function buildUserKeyProvider(rawKey: string): Promise<GraphQLDataProvider> {
    const client = LoadClientConfig();
    const provider = newSecondaryGraphQLProvider();
    const config = new GraphQLProviderConfigData('', client.Url, '', async () => '', undefined, undefined, undefined, undefined, rawKey);
    const ok = await provider.Config(config, undefined, true /* separateConnection */);
    if (!ok) throw new Error('secondary GraphQLDataProvider Config() returned false');
    return provider;
}

async function buildUserKeyProviderWithRetry(rawKey: string): Promise<GraphQLDataProvider> {
    const deadline = Date.now() + 60_000;
    let lastError: unknown;
    while (Date.now() < deadline) {
        try {
            return await buildUserKeyProvider(rawKey);
        } catch (error) {
            lastError = error;
            await new Promise((resolve) => setTimeout(resolve, 1_000));
        }
    }
    throw lastError instanceof Error ? lastError : new Error(String(lastError));
}

async function mintUserApiKey(ctx: IntegrationCheckContext, userId: string, label: string): Promise<{ rawKey: string; keyId: string; scopeRuleId: string }> {
    const engine = GetAPIKeyEngine();
    await engine.Config(false, ctx.User, ctx.Provider as IMetadataProvider);
    const created = await engine.CreateAPIKey({ UserId: userId, Label: label }, ctx.User);
    if (!created.Success || !created.RawKey || !created.APIKeyId) throw new Error(`CreateAPIKey('${label}') failed: ${created.Error ?? 'no raw key returned'}`);
    const fullAccess = engine.Scopes.find((scope) => scope.FullPath === 'full_access');
    if (!fullAccess) throw new Error("the seeded 'full_access' API scope was not found");
    const rule = await ctx.Provider.GetEntityObject<MJAPIKeyScopeEntity>('MJ: API Key Scopes', ctx.User);
    rule.NewRecord();
    rule.APIKeyID = created.APIKeyId;
    rule.ScopeID = fullAccess.ID;
    rule.ResourcePattern = '*';
    rule.PatternType = 'Include';
    rule.IsDeny = false;
    rule.Priority = 0;
    if (!(await rule.Save())) throw new Error(`granting full_access to the minted key failed: ${rule.LatestResult?.CompleteMessage ?? ''}`);
    return { rawKey: created.RawKey, keyId: created.APIKeyId, scopeRuleId: rule.ID };
}

export interface PersonaCheckContext extends IntegrationCheckContext {
    GraphQLProvider: GraphQLDataProvider;
}

export class PersonaContextRegistry extends BaseSingleton<PersonaContextRegistry> {
    private readonly providers = new Map<string, GraphQLDataProvider>();
    private readonly createdKeyIds: string[] = [];
    private readonly createdScopeRuleIds: string[] = [];

    public constructor() {
        super();
    }

    public static get Instance(): PersonaContextRegistry {
        return PersonaContextRegistry.getInstance<PersonaContextRegistry>();
    }

    /** The context as the person with this email: a provider signed in with a key minted for them, on first use. */
    async getPersonaContext(ctx: IntegrationCheckContext, email: string): Promise<PersonaCheckContext> {
        const user = await GetPersonaUser(ctx, email);
        const key = user.ID.toLowerCase();
        let provider = this.providers.get(key);
        if (!provider) {
            const minted = await mintUserApiKey(ctx, user.ID, `tasks-test-persona-${email}-${Date.now()}`);
            this.createdKeyIds.push(minted.keyId);
            this.createdScopeRuleIds.push(minted.scopeRuleId);
            provider = await buildUserKeyProviderWithRetry(minted.rawKey);
            this.providers.set(key, provider);
        }
        Assert(UUIDsEqual(provider.CurrentUser?.ID, user.ID), `Client provider CurrentUser must be ${email} (${user.ID}), saw ${provider.CurrentUser?.ID}`);
        return { ...ctx, Provider: provider, User: provider.CurrentUser ?? user, GraphQLProvider: provider };
    }

    /** Deletes the keys the bundle minted. */
    async cleanup(ctx: IntegrationCheckContext): Promise<void> {
        const errors: string[] = [];
        while (this.createdScopeRuleIds.length) {
            const id = this.createdScopeRuleIds.pop()!;
            try {
                const rule = await ctx.Provider.GetEntityObject<MJAPIKeyScopeEntity>('MJ: API Key Scopes', ctx.User);
                if ((await rule.Load(id)) && !(await rule.Delete())) errors.push(`API key scope rule ${id}: ${rule.LatestResult?.CompleteMessage ?? 'Delete returned false'}`);
            } catch (error) {
                errors.push(`API key scope rule ${id}: ${error instanceof Error ? error.message : String(error)}`);
            }
        }
        while (this.createdKeyIds.length) {
            const id = this.createdKeyIds.pop()!;
            try {
                const key = await ctx.Provider.GetEntityObject<MJAPIKeyEntity>('MJ: API Keys', ctx.User);
                if ((await key.Load(id)) && !(await key.Delete())) errors.push(`API key ${id}: ${key.LatestResult?.CompleteMessage ?? 'Delete returned false'}`);
            } catch (error) {
                errors.push(`API key ${id}: ${error instanceof Error ? error.message : String(error)}`);
            }
        }
        this.providers.clear();
        personaCache.clear();
        if (errors.length) throw new Error(`persona cleanup: ${errors.join('; ')}`);
    }
}

export function getPersonaContext(ctx: IntegrationCheckContext, email: string): Promise<PersonaCheckContext> {
    return PersonaContextRegistry.Instance.getPersonaContext(ctx, email);
}

export function cleanupPersonaProviders(ctx: IntegrationCheckContext): Promise<void> {
    return PersonaContextRegistry.Instance.cleanup(ctx);
}
