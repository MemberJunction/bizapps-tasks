import { IMetadataProvider, Metadata } from '@memberjunction/core';
import { IsValidUUID } from '@memberjunction/global';

/*
 * ExtraFilter builders for subqueries against other Tasks entities.
 *
 * The data provider adapts a filter to its database only for the fields of the
 * entity being queried. Everything else in a subquery has to be written so it
 * runs on SQL Server and PostgreSQL as-is:
 * - Schema and view names come from metadata. PostgreSQL stores the schema in
 *   lowercase, so a hardcoded name misses there.
 * - Every identifier is in [brackets]. SQL Server reads them natively; the
 *   PostgreSQL provider turns them into "quoted" identifiers, which keeps their
 *   mixed case instead of folding it to lowercase.
 * - Boolean columns are compared through CAST(... AS INT): a bare `= 1` compares
 *   a PostgreSQL boolean with an integer, which PostgreSQL rejects.
 */

export const TASK_TYPES_ENTITY = 'MJ_BizApps_Tasks: Task Types';
export const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
export const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
export const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';
export const ROLES_ENTITY = 'MJ: Roles';

/** `[schema].[view]` for an entity's base view, as metadata names it on the current database. */
export function EntityViewRef(entityName: string, provider?: IMetadataProvider): string {
    const entity = (provider ?? Metadata.Provider)?.EntityByName(entityName);
    if (!entity) throw new Error(`Entity '${entityName}' is not in metadata`);
    return `[${entity.SchemaName}].[${entity.BaseView}]`;
}

/** A predicate that is true when a boolean column is set, on SQL Server and PostgreSQL. */
export function IsTrue(column: string): string {
    return `CAST(${column} AS INT) = 1`;
}

/** A quoted SQL string literal. */
export function SqlString(value: string): string {
    return `'${value.replace(/'/g, "''")}'`;
}

/** Predicate on the Task Types view selecting the approval types: one named type, or every IsApproval type. */
export function ApprovalTypePredicate(typeName: string | null): string {
    return typeName ? `[Name] = ${SqlString(typeName)}` : IsTrue('[IsApproval]');
}

/**
 * Tasks filter: tasks assigned to this person, or to any of the given MJ roles.
 *
 * A Task Assignment whose AssigneeEntityID is `MJ: Roles` assigns the task to the role, so it is
 * "mine" for every user who holds the role. Role IDs that are not UUIDs are dropped. Each role ID is
 * matched in upper and lower case because `AssigneeRecordID` is text, and the two databases write
 * UUIDs in different cases. When `MJ: Roles` is not in metadata, only the person is matched.
 */
export function AssignedToFilter(personID: string, roleIDs: readonly string[] = [], provider?: IMetadataProvider): string {
    const view = EntityViewRef(TASK_ASSIGNMENTS_ENTITY, provider);
    const personClause = `[AssigneeRecordID] = ${SqlString(personID)}`;
    const ids = [...new Set(roleIDs.filter((id) => IsValidUUID(id)).flatMap((id) => [id.toUpperCase(), id.toLowerCase()]))];
    const rolesEntityID = ids.length > 0 ? (provider ?? Metadata.Provider)?.EntityByName(ROLES_ENTITY)?.ID : undefined;
    if (!rolesEntityID) {
        return `[ID] IN (SELECT [TaskID] FROM ${view} WHERE ${personClause})`;
    }
    const roleClause = `([AssigneeEntityID] = ${SqlString(rolesEntityID)} AND [AssigneeRecordID] IN (${ids.map(SqlString).join(',')}))`;
    return `[ID] IN (SELECT [TaskID] FROM ${view} WHERE ${personClause} OR ${roleClause})`;
}

/**
 * Tasks filter for pending approvals: tasks of an approval type, assigned to this
 * approver or to one of their MJ roles, still open, and without any terminal decision yet.
 */
export function PendingApprovalFilter(
    approverPersonID: string,
    approvalTypeName: string | null,
    roleIDs: readonly string[] = [],
    provider?: IMetadataProvider,
): string {
    const decisions = EntityViewRef(TASK_DECISIONS_ENTITY, provider);
    const outcomes = EntityViewRef(TASK_DECISION_OUTCOMES_ENTITY, provider);
    return [
        `[TypeID] IN (SELECT [ID] FROM ${EntityViewRef(TASK_TYPES_ENTITY, provider)} WHERE ${ApprovalTypePredicate(approvalTypeName)})`,
        `[Status] NOT IN ('Completed', 'Cancelled')`,
        AssignedToFilter(approverPersonID, roleIDs, provider),
        `[ID] NOT IN (SELECT [d].[TaskID] FROM ${decisions} [d] INNER JOIN ${outcomes} [o] ON [d].[OutcomeID] = [o].[ID] WHERE ${IsTrue('[o].[IsTerminal]')})`,
    ].join(' AND ');
}
