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
     * assignee, and not from the person who created the task (bc-aidp-next-golive#320 §3). On by
     * default (secure by default): only an explicit `false` setting turns the guard off.
     */
    PreventSelfApproval: 'PreventSelfApproval',
    /**
     * The NAME of the MJ role whose holders may decide an approval task they created themselves while
     * `PreventSelfApproval` is on. They must still be an assignee. Empty exempts nobody.
     */
    SelfApprovalExemptRole: 'SelfApprovalExemptRole',
} as const;

export type TasksSettingKey = (typeof TASKS_SETTING)[keyof typeof TASKS_SETTING];

/**
 * Only an explicit value flips a guard; anything else — absent, empty or unrecognized — keeps the
 * fallback, so a security control cannot be switched off by a typo or a cleared value.
 */
function asBoolean(raw: string | undefined, fallback: boolean): boolean {
    if (raw == null) return fallback;
    const v = raw.trim().toLowerCase();
    if (['true', '1', 'yes', 'on'].includes(v)) return true;
    if (['false', '0', 'no', 'off'].includes(v)) return false;
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

    /** Whether approval decisions are limited to assignees other than the requester. Default true (secure by default). */
    public static PreventSelfApproval(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.PreventSelfApproval, provider), true);
    }

    /** The role exempt from the self-approval refusal, or null when none is configured. */
    public static SelfApprovalExemptRole(provider: IMetadataProvider): string | null {
        const value = this.raw(TASKS_SETTING.SelfApprovalExemptRole, provider)?.trim();
        return value ? value : null;
    }
}
