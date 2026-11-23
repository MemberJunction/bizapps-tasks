/**
 * What the approval rules need to know about the signed-in user, read once per check.
 *
 * TaskAssignmentEntityServer and TaskEntityServer ask the same questions of the user saving a
 * record: which People are they, which MJ roles do they hold, is an assignee them, and do they hold
 * the reassign right. Each answer is read fresh (a role granted a minute ago counts) and kept for
 * the life of this object, so one validation never reads the same thing twice.
 *
 * Every read throws when it fails, so a caller checking a rule can fail closed.
 *
 * CONNECTS TO:
 *   READS:  MJ_BizApps_Common: People · MJ: User Roles · MJ: Roles
 *   SETTINGS: TasksSettings (@mj-biz-apps/tasks-core: ApprovalReassignRoles, SelfApprovalExemptRole)
 */
import { LogError, RunView, WellKnownUserSource, type IMetadataProvider, type IRunViewProvider, type UserInfo } from '@memberjunction/core';
import { GuidLiteral, TasksSettings } from '@mj-biz-apps/tasks-core';
import { IsPeopleEntity, PeopleForUser } from './UserPeople.js';

const USERS_ENTITY = 'MJ: Users';
const ROLES_ENTITY = 'MJ: Roles';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const EMPLOYEES_ENTITY = 'MJ: Employees';
const ORGANIZATIONS_ENTITY = 'MJ_BizApps_Common: Organizations';
const RELATIONSHIPS_ENTITY = 'MJ_BizApps_Common: Relationships';
const RELATIONSHIP_TYPES_ENTITY = 'MJ_BizApps_Common: Relationship Types';

/** One role the user holds. */
type HeldRole = { RoleID: string | null; Role: string | null };
type OrgRelationshipTypeRow = { ID: string };
type OrgRelationshipRow = {
    FromPersonID: string | null;
    ToPersonID: string | null;
    FromOrganizationID: string | null;
    ToOrganizationID: string | null;
};
type UserEmployeeRow = { ID: string; EmployeeID: string | null };
type EmployeeCompanyRow = { ID: string; CompanyID: string | null; Active: boolean | number };
type OrganizationRow = { ID: string };

const same = (a: string | null | undefined, b: string | null | undefined): boolean =>
    !!a && !!b && a.trim().toLowerCase() === b.trim().toLowerCase();

/** True when the save runs as the MJ system user: the server's own account, never a browser's. */
export function IsSystemActor(user: UserInfo | null | undefined): boolean {
    return WellKnownUserSource.Instance.IsSystemUser(user);
}

export class ApprovalActor {
    private people: Promise<string[]> | null = null;
    private roles: Promise<HeldRole[]> | null = null;
    private organizations: Promise<string[]> | null = null;

    public constructor(
        private readonly user: UserInfo,
        private readonly provider: IMetadataProvider,
        private readonly runViewProvider: IRunViewProvider | undefined,
    ) {}

    /** Every Person bound to the user (their own People link and any `People.LinkedUserID` match). */
    public PersonIDs(): Promise<string[]> {
        this.people ??= PeopleForUser(this.provider, this.runViewProvider, this.user);
        return this.people;
    }

    /** Whether `personID` is one of the user's People. An empty ID is nobody. */
    public async IsPerson(personID: string | null | undefined): Promise<boolean> {
        if (!personID) return false;
        return (await this.PersonIDs()).some((id) => same(id, personID));
    }

    /**
     * Whether an assignee is the user: one of their People, their own `MJ: Users` row, or an MJ
     * role they hold (a shared queue they could decide from).
     */
    public async IsAssignee(assigneeEntityID: string | null | undefined, assigneeRecordID: string | null | undefined): Promise<boolean> {
        if (!assigneeEntityID || !assigneeRecordID?.trim()) return false;
        if (same(assigneeEntityID, this.provider.EntityByName(USERS_ENTITY)?.ID)) return same(assigneeRecordID, this.user.ID);
        if (same(assigneeEntityID, this.provider.EntityByName(ROLES_ENTITY)?.ID)) return this.holdsRoleID(assigneeRecordID);
        if (!IsPeopleEntity(this.provider, assigneeEntityID)) return false;
        return this.IsPerson(assigneeRecordID);
    }

    /**
     * Whether the user holds the reassign right: anyone while `ApprovalReassignRoles` is empty (the
     * rule is off), otherwise a holder of a role it names, matched trimmed and case-insensitively in
     * code so the database collation cannot change the answer.
     */
    public async MayReassignApprovals(): Promise<boolean> {
        await TasksSettings.Load(this.provider, this.user);
        const allowed = TasksSettings.ApprovalReassignRoles(this.provider);
        if (allowed.length === 0) return true;
        const held = new Set((await this.heldRoles()).map((r) => (r.Role ?? '').trim().toLowerCase()));
        if (allowed.some((role) => held.has(role.toLowerCase()))) return true;
        await this.logUnknownRoles(allowed);
        return false;
    }

    /** Every MJ role the user holds: the ones the signed-in session carries and the ones the database has now. */
    public async RoleIDs(): Promise<string[]> {
        const session = (this.user.UserRoles ?? []).map((r) => r.RoleID);
        const fresh = (await this.heldRoles()).map((r) => r.RoleID);
        return [...session, ...fresh].filter((id): id is string => !!id);
    }

    /**
     * Whether the user holds the role the `SelfApprovalExemptRole` setting names, matched trimmed
     * and case-insensitively. No setting, or a name no role of theirs carries, exempts nobody.
     */
    public async HoldsSelfApprovalExemptRole(): Promise<boolean> {
        await TasksSettings.Load(this.provider, this.user);
        const exempt = TasksSettings.SelfApprovalExemptRole(this.provider)?.trim().toLowerCase();
        if (!exempt) return false;
        return (await this.heldRoles()).some((r) => (r.Role ?? '').trim().toLowerCase() === exempt);
    }

    /** Every Organization ID the actor belongs to (via active PersonToOrganization Relationships or active Employee -> LinkedCompany). */
    public OrganizationIDs(): Promise<string[]> {
        this.organizations ??= this.loadOrganizations();
        return this.organizations;
    }

    /** Whether the actor belongs to `organizationID` (fail-closed when non-empty and membership cannot be confirmed). */
    public async BelongsToOrganization(organizationID: string | null | undefined): Promise<boolean> {
        if (!organizationID) return true;
        return (await this.OrganizationIDs()).some((id) => same(id, organizationID));
    }

    /** The role is held when the database says so, or when the signed-in session already carries it. */
    private async holdsRoleID(roleID: string): Promise<boolean> {
        if ((this.user.UserRoles ?? []).some((r) => same(r.RoleID, roleID))) return true;
        return (await this.heldRoles()).some((r) => same(r.RoleID, roleID));
    }

    private async loadOrganizations(): Promise<string[]> {
        const orgIDs = new Set<string>();
        const personIDs = await this.PersonIDs();

        if (personIDs.length > 0 && this.provider.EntityByName(RELATIONSHIP_TYPES_ENTITY) && this.provider.EntityByName(RELATIONSHIPS_ENTITY)) {
            const relTypes = await this.readRows<OrgRelationshipTypeRow>(
                RELATIONSHIP_TYPES_ENTITY,
                `Category = 'PersonToOrganization'`,
                ['ID'],
            );
            const relTypeIDs = relTypes.map((t) => t.ID).filter(Boolean);
            if (relTypeIDs.length > 0) {
                const personIn = personIDs.map((id) => GuidLiteral(id, 'PersonID')).join(', ');
                const typeIn = relTypeIDs.map((id) => GuidLiteral(id, 'RelationshipTypeID')).join(', ');
                const rels = await this.readRows<OrgRelationshipRow>(
                    RELATIONSHIPS_ENTITY,
                    `Status = 'Active' AND RelationshipTypeID IN (${typeIn}) AND (FromPersonID IN (${personIn}) OR ToPersonID IN (${personIn}))`,
                    ['FromPersonID', 'ToPersonID', 'FromOrganizationID', 'ToOrganizationID'],
                );
                for (const rel of rels) {
                    if (rel.ToOrganizationID && personIDs.some((p) => same(p, rel.FromPersonID))) {
                        orgIDs.add(rel.ToOrganizationID);
                    }
                    if (rel.FromOrganizationID && personIDs.some((p) => same(p, rel.ToPersonID))) {
                        orgIDs.add(rel.FromOrganizationID);
                    }
                }
            }
        }

        if (this.provider.EntityByName(USERS_ENTITY) && this.provider.EntityByName(EMPLOYEES_ENTITY) && this.provider.EntityByName(ORGANIZATIONS_ENTITY)) {
            const users = await this.readRows<UserEmployeeRow>(
                USERS_ENTITY,
                `ID = ${GuidLiteral(this.user.ID, 'UserID')}`,
                ['ID', 'EmployeeID'],
            );
            const employeeID = users[0]?.EmployeeID;
            if (employeeID) {
                const emps = await this.readRows<EmployeeCompanyRow>(
                    EMPLOYEES_ENTITY,
                    `ID = ${GuidLiteral(employeeID, 'EmployeeID')}`,
                    ['ID', 'CompanyID', 'Active'],
                );
                const emp = emps[0];
                const isActive = emp && (emp.Active === true || emp.Active === 1);
                if (isActive && emp.CompanyID) {
                    const orgs = await this.readRows<OrganizationRow>(
                        ORGANIZATIONS_ENTITY,
                        `LinkedCompanyID = ${GuidLiteral(emp.CompanyID, 'CompanyID')}`,
                        ['ID'],
                    );
                    for (const org of orgs) {
                        if (org.ID) orgIDs.add(org.ID);
                    }
                }
            }
        }

        return [...orgIDs];
    }

    /** The user's roles, read fresh so a role just granted counts. */
    private heldRoles(): Promise<HeldRole[]> {
        this.roles ??= this.readRows<HeldRole>(USER_ROLES_ENTITY, `UserID = ${GuidLiteral(this.user.ID, 'UserID')}`, ['RoleID', 'Role']);
        return this.roles;
    }

    /** Logs, once per refused check, the configured role names that are not roles: they match nobody. */
    private async logUnknownRoles(allowed: string[]): Promise<void> {
        const rows = await this.readRows<{ Name: string | null }>(ROLES_ENTITY, '', ['Name']);
        const known = new Set(rows.map((r) => (r.Name ?? '').trim().toLowerCase()));
        const unknown = allowed.filter((role) => !known.has(role.toLowerCase()));
        if (unknown.length > 0) {
            LogError(`ApprovalActor: the ApprovalReassignRoles setting names ${unknown.map((r) => `'${r}'`).join(', ')}, which ${unknown.length === 1 ? 'is not a role' : 'are not roles'}; nobody holds ${unknown.length === 1 ? 'it' : 'them'}.`);
        }
    }

    private async readRows<T>(entityName: string, filter: string, fields: string[]): Promise<T[]> {
        const res = await new RunView(this.runViewProvider).RunView<T>(
            { EntityName: entityName, ExtraFilter: filter, Fields: fields, ResultType: 'simple', BypassCache: true },
            this.user,
        );
        if (!res?.Success) throw new Error(res?.ErrorMessage ?? `the ${entityName} lookup returned no result`);
        return res.Results ?? [];
    }
}
