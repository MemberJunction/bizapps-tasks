/**
 * Input for `BizAppsTasks.InstantiateTemplate`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TemplateRoleAssignmentInput {
    RoleID: string;
    EntityName: string;
    RecordID: string;
}

export interface TasksInstantiateTemplateInput {
    TemplateID: string;
    StartDate: string;
    CategoryID?: string | null;
    OrganizationID?: string | null;
    RoleAssignments?: TemplateRoleAssignmentInput[];
}
