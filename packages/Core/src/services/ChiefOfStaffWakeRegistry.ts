import { LogError, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { BaseSingleton, GetGlobalObjectStore, IsValidUUID } from '@memberjunction/global';

/**
 * Coalesced per-user Chief of Staff workstream key for all task inbox events
 * (task assignments, task unblocks, agent task completions, and delegated meeting commitments).
 */
export const COS_TASKS_INBOX_WORKSTREAM_KEY = 'tasks-inbox';

/**
 * Coalesced per-user Chief of Staff workstream key for post-meeting transcript
 * and meeting note processing events.
 */
export const COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY = 'meetings-transcript';

export interface ChiefOfStaffWakeRequest {
    targetUserID: string;
    workstreamKey: string;
    wakeReason: string;
    resumeState: Record<string, string | number | boolean | null>;
    actingUser: UserInfo;
    metadataProvider?: IMetadataProvider;
}

export type ChiefOfStaffWakeHandler = (request: ChiefOfStaffWakeRequest) => Promise<boolean>;

/**
 * Process-wide singleton registry bridging server entity persistence hooks
 * (`@mj-biz-apps/tasks-entities-server`) to MJ's `AgentWakeTriggerService`
 * implementation registered by `@mj-biz-apps/tasks-actions` / `@mj-biz-apps/tasks-server`.
 *
 * Uses `BaseSingleton<T>` so bundler code-splitting shares one registry across packages.
 */
export class ChiefOfStaffWakeRegistry extends BaseSingleton<ChiefOfStaffWakeRegistry> {
    private _handler: ChiefOfStaffWakeHandler | null = null;

    protected constructor() {
        super();
    }

    public static get Instance(): ChiefOfStaffWakeRegistry {
        const g = GetGlobalObjectStore();
        const key = '___SINGLETON__ChiefOfStaffWakeRegistry';
        if (g && g[key]) {
            return g[key] as ChiefOfStaffWakeRegistry;
        }
        return new ChiefOfStaffWakeRegistry();
    }

    public RegisterHandler(handler: ChiefOfStaffWakeHandler): void {
        this._handler = handler;
    }

    public ClearHandler(): void {
        this._handler = null;
    }

    public get HasHandler(): boolean {
        return this._handler !== null;
    }

    /**
     * Dispatches a best-effort Chief of Staff wake through the registered server handler.
     * Never throws; returns `false` if no handler is registered, `targetUserID` is invalid,
     * or the wake is suppressed/fails.
     */
    public async Dispatch(request: ChiefOfStaffWakeRequest): Promise<boolean> {
        if (!this._handler || !IsValidUUID(request.targetUserID)) {
            return false;
        }
        try {
            return await this._handler(request);
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(
                `[BizAppsTasks] ChiefOfStaffWakeRegistry dispatch failed for workstream '${request.workstreamKey}': ${msg}`,
            );
            return false;
        }
    }
}
