/**
 * Input for `BizAppsTasks.RunRecurringPlaybooks`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TemplateRoleAssignmentInput {
    RoleID: string;
    EntityName: string;
    RecordID: string;
}

export interface TasksRunRecurringPlaybooksInput {
    TemplateID: string;
    AnchorDate: string;
    PeriodKey: string;
    OrganizationIDs?: string[];
    AllMirroredCompanies?: boolean;
    CategoryID?: string | null;
    RoleAssignments?: TemplateRoleAssignmentInput[];
    DryRun?: boolean;
}
