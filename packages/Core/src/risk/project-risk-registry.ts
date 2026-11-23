import type { IMetadataProvider, IRunViewProvider, UserInfo } from '@memberjunction/core';
import type {
    MLBreachSignal,
    ProjectAssigneeRawFreeBusy,
    ProjectFreeBusyProvider,
    ProjectRiskAssessmentRunResult,
    ProjectRiskMLBreachProvider,
} from './project-risk-types.js';

/** Request parameters accepted by a registered Project Risk Analyst runtime handler. */
export interface ProjectRiskReviewDispatchInput {
    TaskID: string;
    CallerContextUser: UserInfo;
    Force?: boolean;
    Provider?: IMetadataProvider;
    RunViewProvider?: IRunViewProvider | null;
    ExplicitOwnerUserID?: string | null;
    MLBreachSignalOverride?: MLBreachSignal | null;
    FreeBusyOverrides?: readonly ProjectAssigneeRawFreeBusy[] | null;
    FreeBusyProvider?: ProjectFreeBusyProvider;
    MLBreachScoreProvider?: ProjectRiskMLBreachProvider;
    Now?: Date;
}

/** Handler invoked by typed actions (Slice 3) to execute `ProjectRiskAnalystService`. */
export type ProjectRiskAnalystDispatchHandler = (
    input: ProjectRiskReviewDispatchInput,
) => Promise<ProjectRiskAssessmentRunResult>;

/**
 * In-process registry bridging `@mj-biz-apps/tasks-actions` and `@mj-biz-apps/tasks-server`
 * without circular package dependencies.
 */
export class ProjectRiskAnalystRegistry {
    private static _instance: ProjectRiskAnalystRegistry | null = null;
    private handler: ProjectRiskAnalystDispatchHandler | null = null;

    public static get Instance(): ProjectRiskAnalystRegistry {
        if (!ProjectRiskAnalystRegistry._instance) {
            ProjectRiskAnalystRegistry._instance = new ProjectRiskAnalystRegistry();
        }
        return ProjectRiskAnalystRegistry._instance;
    }

    public get HasHandler(): boolean {
        return this.handler !== null;
    }

    public RegisterHandler(handler: ProjectRiskAnalystDispatchHandler | null): void {
        this.handler = handler;
    }

    public async RunReview(input: ProjectRiskReviewDispatchInput): Promise<ProjectRiskAssessmentRunResult> {
        if (!this.handler) {
            throw new Error(
                'ProjectRiskAnalystRegistry has no registered handler. Ensure LoadBizAppsTasksServer() has run.',
            );
        }
        return this.handler(input);
    }
}
