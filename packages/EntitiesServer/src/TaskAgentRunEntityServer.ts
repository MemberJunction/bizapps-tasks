/**
 * Server-side subclass of `MJ_BizApps_Tasks: Task Agent Runs` (`TaskAgentRun`).
 *
 * Enforces rules A1 and A2 (§6.3, D7):
 * - A1: Only the user who executed the `AIAgentRun` (`AIAgentRun.UserID === caller.ID`, or system/unowned
 *       runs when invoked in-process) or a holder of `Manage Time Entries` may link or unlink the run.
 * - A2: Normalizes links on `TaskID` so a task's linked runs are never nested:
 *       - If an ancestor of `AIAgentRunID` is already linked to `TaskID`, `Save()` is a no-op that
 *         adopts the ancestor link and returns `true` without writing a duplicate child row.
 *       - If descendants of `AIAgentRunID` are already linked to `TaskID`, `Save()` deletes those
 *         descendant links so the ancestor's rollup (`TotalCostRollup`, `TotalTokensUsedRollup`)
 *         replaces them cleanly.
 */
import {
    BaseEntity,
    BaseEntityResult,
    EntityDeleteOptions,
    EntitySaveOptions,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { AncestorRunIDsFor, UserCanManageTimeEntries } from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksTaskAgentRunEntity } from '@mj-biz-apps/tasks-entities';
import { GuidLiteral as guid } from './UserPeople.js';

export const TASK_AGENT_RUN_ENTITY = 'MJ_BizApps_Tasks: Task Agent Runs';
const AI_AGENT_RUNS_ENTITY = 'MJ: AI Agent Runs';
const SOURCE = 'TaskAgentRunEntityServer';

interface AgentRunRow {
    ID: string;
    UserID: string | null;
    ParentRunID: string | null;
    ParentRunIDPath?: string | null;
}

@RegisterClass(BaseEntity, TASK_AGENT_RUN_ENTITY)
export class TaskAgentRunEntityServer extends mjBizAppsTasksTaskAgentRunEntity {
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const user = this.ContextCurrentUser;
        if (!this.IsSaved && user && this.TaskID && this.AIAgentRunID) {
            try {
                const normResult = await this.normalizeTaskLinksPreSave();
                if (normResult === 'skip_covered_by_ancestor') {
                    return true;
                }
            } catch (err: unknown) {
                const msg = err instanceof Error ? err.message : String(err);
                LogError(`${SOURCE}.Save link normalization failed: ${msg}`);
                const res = new BaseEntityResult();
                res.Type = this.IsSaved ? 'update' : 'create';
                res.Success = false;
                res.Message = msg;
                this.ResultHistory.push(res);
                return false;
            }
        }
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        try {
            const refusal = await this.checkRunOwnership();
            if (refusal) {
                const res = new BaseEntityResult();
                res.Type = 'delete';
                res.Success = false;
                res.Message = refusal;
                this.ResultHistory.push(res);
                return false;
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.Delete failed: ${msg}`);
            const res = new BaseEntityResult();
            res.Type = 'delete';
            res.Success = false;
            res.Message = `Could not unlink agent run (${msg}).`;
            this.ResultHistory.push(res);
            return false;
        }
        return super.Delete(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusal = await this.checkRunOwnership();
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, refusal, null));
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.ValidateAsync failed: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, `Agent run link validation failed (${msg}).`, null),
            );
        }
        return result;
    }

    private async checkRunOwnership(): Promise<string | null> {
        const provider = Metadata.Provider;
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'A signed-in user is required to link or unlink AI agent runs.';
        }

        const runLit = guid(this.AIAgentRunID, 'AIAgentRunID');
        const rv = new RunView(this.RunViewProviderToUse);
        const runRes = await rv.RunView<AgentRunRow>(
            {
                EntityName: AI_AGENT_RUNS_ENTITY,
                ExtraFilter: `ID = ${runLit}`,
                Fields: ['ID', 'UserID', 'ParentRunID', 'ParentRunIDPath'],
                MaxRows: 1,
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!runRes?.Success) {
            throw new Error(runRes?.ErrorMessage ?? 'AI Agent Run lookup failed');
        }
        const run = runRes.Results?.[0];
        if (!run) {
            return `AI Agent Run '${this.AIAgentRunID}' was not found.`;
        }

        if (UserCanManageTimeEntries(user, provider)) {
            return null;
        }

        if (run.UserID && run.UserID.trim().toLowerCase() !== user.ID.trim().toLowerCase()) {
            return 'You can only link or unlink AI agent runs that you started yourself unless you hold Manage Time Entries.';
        }
        return null;
    }

    /**
     * Enforces A2 (D7): if an ancestor of `this.AIAgentRunID` is already linked to `this.TaskID`,
     * skips creating the child link; if descendants of `this.AIAgentRunID` are linked to `this.TaskID`,
     * deletes those descendant links.
     */
    private async normalizeTaskLinksPreSave(): Promise<'proceed' | 'skip_covered_by_ancestor'> {
        const user = this.ContextCurrentUser!;
        const rv = new RunView(this.RunViewProviderToUse);
        const taskLit = guid(this.TaskID, 'TaskID');
        const runLit = guid(this.AIAgentRunID, 'AIAgentRunID');

        // Check ownership first before mutating any existing links
        const refusal = await this.checkRunOwnership();
        if (refusal) {
            throw new Error(refusal);
        }

        const existingLinksRes = await rv.RunView<{ ID: string; AIAgentRunID: string }>(
            {
                EntityName: TASK_AGENT_RUN_ENTITY,
                ExtraFilter: `TaskID = ${taskLit}`,
                Fields: ['ID', 'AIAgentRunID'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!existingLinksRes?.Success) {
            throw new Error(existingLinksRes?.ErrorMessage ?? 'Existing task agent links lookup failed');
        }
        const existingLinks = existingLinksRes.Results ?? [];
        if (existingLinks.length === 0) {
            return 'proceed';
        }

        // Exact duplicate check
        const exactMatch = existingLinks.find(
            (l) => l.AIAgentRunID.trim().toLowerCase() === this.AIAgentRunID.trim().toLowerCase(),
        );
        if (exactMatch) {
            await this.Load(exactMatch.ID);
            return 'skip_covered_by_ancestor';
        }

        // Load lineage for the new run and all existing linked runs on this task
        const allRunLiterals = [
            runLit,
            ...existingLinks.map((l) => guid(l.AIAgentRunID, 'AIAgentRunID')),
        ];
        const runsRes = await rv.RunView<AgentRunRow>(
            {
                EntityName: AI_AGENT_RUNS_ENTITY,
                ExtraFilter: `ID IN (${allRunLiterals.join(', ')})`,
                Fields: ['ID', 'ParentRunID', 'ParentRunIDPath'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!runsRes?.Success) {
            throw new Error(runsRes?.ErrorMessage ?? 'AI Agent Runs lineage lookup failed');
        }
        const runRows = runsRes.Results ?? [];
        const parentMap = new Map<string, string>();
        for (const r of runRows) {
            if (r.ParentRunID) {
                parentMap.set(r.ID.trim().toLowerCase(), r.ParentRunID.trim().toLowerCase());
            }
        }

        const newRunRow = runRows.find((r) => r.ID.trim().toLowerCase() === this.AIAgentRunID.trim().toLowerCase());
        if (!newRunRow) {
            return 'proceed';
        }

        // 1. Check if any existing link on this task is an ANCESTOR of the new run
        const newRunAncestors = AncestorRunIDsFor(
            {
                AIAgentRunID: newRunRow.ID,
                ParentRunID: newRunRow.ParentRunID,
                ParentRunIDPath: newRunRow.ParentRunIDPath,
            },
            parentMap,
        );
        const coveringAncestorLink = existingLinks.find((l) =>
            newRunAncestors.has(l.AIAgentRunID.trim().toLowerCase()),
        );
        if (coveringAncestorLink) {
            await this.Load(coveringAncestorLink.ID);
            return 'skip_covered_by_ancestor';
        }

        // 2. Check if any existing links on this task are DESCENDANTS of the new run
        const selfNorm = this.AIAgentRunID.trim().toLowerCase();
        const descendantLinksToDelete: string[] = [];

        for (const link of existingLinks) {
            const linkedRow = runRows.find((r) => r.ID.trim().toLowerCase() === link.AIAgentRunID.trim().toLowerCase());
            if (!linkedRow) continue;
            const ancestors = AncestorRunIDsFor(
                {
                    AIAgentRunID: linkedRow.ID,
                    ParentRunID: linkedRow.ParentRunID,
                    ParentRunIDPath: linkedRow.ParentRunIDPath,
                },
                parentMap,
            );
            if (ancestors.has(selfNorm)) {
                descendantLinksToDelete.push(link.ID);
            }
        }

        if (descendantLinksToDelete.length > 0) {
            const md = new Metadata();
            for (const delId of descendantLinksToDelete) {
                const childLink = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                    TASK_AGENT_RUN_ENTITY,
                    user,
                );
                if (await childLink.Load(delId)) {
                    await childLink.Delete();
                }
            }
        }

        return 'proceed';
    }
}
