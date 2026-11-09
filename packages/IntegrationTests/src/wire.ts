import { CompositeKey, RunView, UserInfo, UserRoleInfo, type IMetadataProvider } from '@memberjunction/core';
import { ApplicationSettingEngine, type MJApplicationSettingEntity } from '@memberjunction/core-entities';
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import {
    APPLICATION_SETTING_ENTITY,
    PERSON_ENTITY,
    TASK_ACTIVITY_ENTITY,
} from './entity-names.js';

export function Quote(value: string): string {
    return value.replace(/'/g, "''");
}

export function SameID(left: string | null | undefined, right: string | null | undefined): boolean {
    return (left ?? '').toLowerCase() === (right ?? '').toLowerCase();
}

export function View(ctx: IntegrationCheckContext): RunView {
    return RunView.FromMetadataProvider(ctx.Provider as IMetadataProvider);
}

export async function FindRows<T extends object>(
    ctx: IntegrationCheckContext,
    entityName: string,
    extraFilter: string,
    fields: string[],
): Promise<T[]> {
    const res = await View(ctx).RunView<T>(
        {
            EntityName: entityName,
            ExtraFilter: extraFilter,
            Fields: fields,
            ResultType: 'simple',
            BypassCache: true,
        },
        ctx.User,
    );
    Assert(res.Success, `RunView ${entityName} failed: ${res.ErrorMessage ?? 'unknown'}`);
    return res.Results ?? [];
}

export async function FindId(ctx: IntegrationCheckContext, entityName: string, extraFilter: string): Promise<string | null> {
    const rows = await FindRows<{ ID: string }>(ctx, entityName, extraFilter, ['ID']);
    return rows[0]?.ID ?? null;
}

export async function RequireSave(
    entity: { Save: () => Promise<boolean>; LatestResult?: { CompleteMessage?: string }; ResultHistory?: Array<{ Message?: string }> },
    what: string,
): Promise<void> {
    const saved = await entity.Save();
    const message =
        entity.LatestResult?.CompleteMessage ||
        entity.ResultHistory?.[entity.ResultHistory.length - 1]?.Message ||
        'unknown';
    Assert(saved, `${what} save failed: ${message}`);
}

export async function RequireRefusal(
    action: () => Promise<boolean>,
    entity: { LatestResult?: { CompleteMessage?: string }; ResultHistory?: Array<{ Message?: string }> },
    what: string,
    expectedSubstring?: string,
): Promise<string> {
    const ok = await action();
    Assert(!ok, `${what} should have been refused, but succeeded`);
    const message =
        entity.LatestResult?.CompleteMessage ||
        entity.ResultHistory?.[entity.ResultHistory.length - 1]?.Message ||
        '';
    if (expectedSubstring) {
        Assert(
            message.toLowerCase().includes(expectedSubstring.toLowerCase()),
            `${what} refusal message '${message}' did not include '${expectedSubstring}'`,
        );
    }
    return message;
}

/**
 * Builds a `UserInfo` persona bound to `personID` via `LinkedEntityID` + `LinkedEntityRecordID`.
 *
 * When `canManage` is `false` (default), the user has only the `UI` role — sufficient for entity
 * table CRUD permissions (`cdp_UI`), while `Manage Time Entries` and `Manage Timesheets`
 * authorizations evaluate to `false`. When `canManage` is `true`, the user retains `ctx.User`'s
 * `Developer`/`Integration` roles so both authorizations evaluate to `true`.
 */
export function PersonaUser(
    ctx: IntegrationCheckContext,
    personID: string,
    options?: { canManage?: boolean },
): UserInfo {
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.Entities.find((e) => e.Name === PERSON_ENTITY);
    Assert(!!peopleEntity, 'MJ_BizApps_Common: People entity metadata loaded');

    const clone = Object.create(Object.getPrototypeOf(ctx.User)) as UserInfo;
    for (const [k, v] of Object.entries(Object.getOwnPropertyDescriptors(ctx.User))) {
        Object.defineProperty(clone, k, v);
    }
    Object.defineProperty(clone, 'LinkedEntityID', {
        value: peopleEntity!.ID,
        writable: true,
        configurable: true,
        enumerable: true,
    });
    Object.defineProperty(clone, 'LinkedEntityRecordID', {
        value: personID,
        writable: true,
        configurable: true,
        enumerable: true,
    });

    if (options?.canManage) {
        Object.defineProperty(clone, 'UserRoles', {
            value: ctx.User.UserRoles,
            writable: true,
            configurable: true,
            enumerable: true,
        });
    } else {
        const uiRole = provider.Roles.find((r) => r.Name === 'UI') ?? provider.Roles[0];
        const roleInfo = new UserRoleInfo({
            UserID: ctx.User.ID,
            RoleID: uiRole?.ID ?? '',
            Role: uiRole?.Name ?? 'UI',
        });
        Object.defineProperty(clone, 'UserRoles', {
            value: [roleInfo],
            writable: true,
            configurable: true,
            enumerable: true,
        });
    }
    return clone;
}

/**
 * Temporarily sets a `Tasks` application setting in `__mj.ApplicationSetting`, refreshes
 * `ApplicationSettingEngine`, runs `fn`, and restores the previous state afterward.
 */
export async function WithTasksSetting<T>(
    ctx: IntegrationCheckContext,
    settingName: string,
    value: string,
    fn: () => Promise<T>,
): Promise<T> {
    const provider = ctx.Provider as IMetadataProvider;
    const tasksApp = provider.Applications.find((a) => a.Name === 'Tasks');
    Assert(!!tasksApp, 'Tasks Application metadata loaded');

    const existingID = await FindId(
        ctx,
        APPLICATION_SETTING_ENTITY,
        `ApplicationID = '${tasksApp!.ID}' AND Name = '${Quote(settingName)}'`,
    );
    const settingEntity = await ctx.Provider.GetEntityObject<MJApplicationSettingEntity>(
        APPLICATION_SETTING_ENTITY,
        ctx.User,
    );

    let previousValue: string | null = null;
    let createdNew = false;

    if (existingID) {
        await settingEntity.Load(existingID);
        previousValue = settingEntity.Value;
        settingEntity.Value = value;
        await RequireSave(settingEntity, `update setting ${settingName}`);
    } else {
        createdNew = true;
        settingEntity.NewRecord();
        settingEntity.ApplicationID = tasksApp!.ID;
        settingEntity.Name = settingName;
        settingEntity.Value = value;
        await RequireSave(settingEntity, `create setting ${settingName}`);
    }

    await ApplicationSettingEngine.Instance.Config(true, ctx.User, provider);

    try {
        return await fn();
    } finally {
        if (createdNew) {
            await settingEntity.Delete();
        } else if (previousValue !== null) {
            settingEntity.Value = previousValue;
            await settingEntity.Save();
        }
        await ApplicationSettingEngine.Instance.Config(true, ctx.User, provider);
    }
}

/** Delete a task after removing activity rows the server wrote on save. */
export async function DeleteTask(ctx: IntegrationCheckContext, task: { ID: string; Delete: () => Promise<boolean> }): Promise<void> {
    const activities = await FindRows<{ ID: string }>(ctx, TASK_ACTIVITY_ENTITY, `TaskID = '${task.ID}'`, ['ID']);
    for (const row of activities) {
        const activity = await ctx.Provider.GetEntityObject(TASK_ACTIVITY_ENTITY, ctx.User);
        const key = new CompositeKey();
        key.KeyValuePairs.push({ FieldName: 'ID', Value: row.ID });
        if (await activity.InnerLoad(key)) {
            await activity.Delete();
        }
    }
    Assert(await task.Delete(), `delete task ${task.ID}`);
}
