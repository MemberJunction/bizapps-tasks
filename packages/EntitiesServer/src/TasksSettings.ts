/**
 * Typed access to the Tasks app's settings.
 *
 * MJ owns the mechanism: `__mj.ApplicationSetting` rows scoped to the `Tasks` Application, cached and
 * auto-refreshed by `ApplicationSettingEngine` (`@memberjunction/core-entities`). This is a thin façade
 * over it, so each key, default and coercion is decided once (the same shape as bizapps-orders'
 * `OrdersSettings`). An absent setting and an empty one behave the same: the default applies.
 *
 * CONNECTS TO:
 *   ENGINE: ApplicationSettingEngine (@memberjunction/core-entities)
 *   TABLE:  __mj.ApplicationSetting, scoped to the 'Tasks' Application row
 *   ROWS:   metadata/application-settings/.tasks-settings.json
 */
import { ApplicationSettingEngine } from '@memberjunction/core-entities';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

/** The `MJ: Applications` row this app's settings hang off. */
export const TASKS_APPLICATION_NAME = 'Tasks';

/** Setting keys, in one place so a typo is a compile error rather than a silent default. */
export const TASKS_SETTING = {
    /**
     * Whether a decision on an approval task must come from one of its assignees, attributed to that
     * assignee, and not from the person who created the task (bc-aidp-next-golive#320 §3). Off by
     * default, which leaves every decision accepted as before.
     */
    PreventSelfApproval: 'PreventSelfApproval',
    /**
     * The NAME of the MJ role whose holders may decide an approval task they created themselves while
     * `PreventSelfApproval` is on. They must still be an assignee. Empty exempts nobody.
     */
    SelfApprovalExemptRole: 'SelfApprovalExemptRole',
    /**
     * Comma-separated NAMES of the MJ roles whose holders may reassign or remove an assignment on an
     * approval task (bc-aidp-next-golive#389). Empty lets nobody: workflows only ever create approval
     * assignments, so nothing else needs to move one.
     */
    ApprovalReassignRoles: 'ApprovalReassignRoles',
} as const;

export type TasksSettingKey = (typeof TASKS_SETTING)[keyof typeof TASKS_SETTING];

/** Only an explicit truthy value turns a guard on; anything else keeps the neutral default (off). */
function asBoolean(raw: string | undefined, fallback: boolean): boolean {
    if (raw == null) return fallback;
    const v = raw.trim().toLowerCase();
    if (['true', '1', 'yes', 'on'].includes(v)) return true;
    if (['false', '0', 'no', 'off', ''].includes(v)) return false;
    return fallback;
}

/**
 * Deliberately read-only: there is no in-process override. These settings switch a security control,
 * so the only way to change one is the audited `ApplicationSetting` row; tests mock the engine instead.
 */
export class TasksSettings {
    /** Load the settings cache. Idempotent and cheap after the first call. */
    public static async Load(provider: IMetadataProvider, user: UserInfo): Promise<void> {
        await ApplicationSettingEngine.Instance.Config(false, user, provider);
    }

    private static raw(key: TasksSettingKey, provider: IMetadataProvider): string | undefined {
        const appID = provider.Applications?.find((a) => a.Name === TASKS_APPLICATION_NAME)?.ID;
        if (!appID) return undefined;
        return ApplicationSettingEngine.Instance.GetSetting(key, appID);
    }

    /** Whether approval decisions are limited to assignees other than the requester. Default false. */
    public static PreventSelfApproval(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.PreventSelfApproval, provider), false);
    }

    /** The role exempt from the self-approval refusal, or null when none is configured. */
    public static SelfApprovalExemptRole(provider: IMetadataProvider): string | null {
        const value = this.raw(TASKS_SETTING.SelfApprovalExemptRole, provider)?.trim();
        return value ? value : null;
    }

    /** The roles that may reassign or remove an approval assignment; empty when none is configured. */
    public static ApprovalReassignRoles(provider: IMetadataProvider): string[] {
        const raw = this.raw(TASKS_SETTING.ApprovalReassignRoles, provider) ?? '';
        return raw.split(',').map((r) => r.trim()).filter((r) => r.length > 0);
    }
}
