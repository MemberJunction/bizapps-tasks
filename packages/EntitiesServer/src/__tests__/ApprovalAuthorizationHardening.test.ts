import { describe, expect, it } from 'vitest';
import {
    ApprovalAssignmentAddRefusal,
    ApprovalAssignmentManageRefusal,
    ApprovalOrganizationChangeRefusal,
    ApprovalStatusChangeRefusal,
    CROSS_ORG_ASSIGN_REFUSAL,
    CROSS_ORG_CLOSE_REFUSAL,
    ORG_CHANGE_REFUSAL,
} from '../ApprovalTaskAuthority.js';
import {
    CLOSED_TASK_DECISION_REFUSAL,
    CROSS_ORG_DECISION_REFUSAL,
    TaskDecisionRefusal,
    type TaskDecisionFacts,
} from '../TaskDecisionAuthority.js';

const ORG_A = '11111111-1111-4111-8111-111111111111';
const ORG_B = '22222222-2222-4222-8222-222222222222';
const PEOPLE_ENT = 'A0000000-0000-0000-0000-000000000001';
const USER_1 = 'B0000000-0000-0000-0000-000000000001';
const PERSON_APPROVER = 'C0000000-0000-0000-0000-000000000001';
const PERSON_REQUESTER = 'C0000000-0000-0000-0000-000000000002';

function baseDecisionFacts(overrides: Partial<TaskDecisionFacts> = {}): TaskDecisionFacts {
    return {
        PreventSelfApproval: true,
        RequiresAssigneeDecision: false,
        IsApprovalTask: true,
        TaskStatus: 'Open',
        TaskOrganizationID: ORG_A,
        ActorOrganizationIDs: [ORG_A],
        DeciderUserID: USER_1,
        DeciderPersonIDs: [PERSON_APPROVER],
        DecidedByPersonID: PERSON_APPROVER,
        TaskAssignmentID: null,
        TaskCreatedByPersonID: PERSON_REQUESTER,
        Assignments: [
            {
                ID: 'asg-1',
                AssigneeEntityID: PEOPLE_ENT,
                AssigneeRecordID: PERSON_APPROVER,
                Status: 'Pending',
            },
        ],
        IsPeopleEntityID: (id) => id === PEOPLE_ENT,
        UsersEntityID: null,
        RolesEntityID: null,
        DeciderRoleIDs: [],
        DeciderIsExempt: false,
        ...overrides,
    };
}

describe('ApprovalAuthorizationHardening — cross-organization and state transition guards', () => {
    it('rejects cross-organization decision attempts even when PreventSelfApproval is off', () => {
        const refusal = TaskDecisionRefusal(
            baseDecisionFacts({
                PreventSelfApproval: false,
                TaskOrganizationID: ORG_A,
                ActorOrganizationIDs: [ORG_B],
            }),
        );
        expect(refusal).toBe(CROSS_ORG_DECISION_REFUSAL);
    });

    it('rejects decisions when actor has no verified organization membership on an org-scoped approval', () => {
        const refusal = TaskDecisionRefusal(
            baseDecisionFacts({
                TaskOrganizationID: ORG_A,
                ActorOrganizationIDs: [],
            }),
        );
        expect(refusal).toBe(CROSS_ORG_DECISION_REFUSAL);
    });

    it('allows same-organization assigned approver to decide an open approval', () => {
        expect(TaskDecisionRefusal(baseDecisionFacts())).toBeNull();
    });

    it('rejects additional decisions against already Completed or Cancelled approval tasks', () => {
        expect(TaskDecisionRefusal(baseDecisionFacts({ TaskStatus: 'Completed' }))).toBe(
            CLOSED_TASK_DECISION_REFUSAL,
        );
        expect(TaskDecisionRefusal(baseDecisionFacts({ TaskStatus: 'Cancelled' }))).toBe(
            CLOSED_TASK_DECISION_REFUSAL,
        );
    });

    it('rejects cross-organization assignment additions, reassignments, and deletions', () => {
        expect(
            ApprovalAssignmentAddRefusal({
                Sanctioned: false,
                ActorIsSystem: false,
                HasActor: true,
                TaskOrganizationID: ORG_A,
                ActorOrganizationIDs: [ORG_B],
                AssigneeIsActor: false,
                ActorIsTaskCreator: true,
                TaskIsOpen: true,
                ActorMayReassign: true,
            }),
        ).toBe(CROSS_ORG_ASSIGN_REFUSAL);

        expect(
            ApprovalAssignmentManageRefusal({
                ActorIsSystem: false,
                HasActor: true,
                TaskOrganizationID: ORG_A,
                ActorOrganizationIDs: [ORG_B],
                AssigneeIsActor: false,
                ActorMayReassign: true,
                NoUserMessage: 'no user',
                RoleRefusalMessage: 'no role',
            }),
        ).toBe(CROSS_ORG_ASSIGN_REFUSAL);
    });

    it('rejects cross-organization task closing and OrganizationID mutation on existing approval tasks', () => {
        expect(
            ApprovalStatusChangeRefusal({
                NewStatus: 'Cancelled',
                DecidedStatus: null,
                ActorMayDecide: false,
                WithdrawalSanctioned: false,
                ActorIsSystem: false,
                HasActor: true,
                ActorIsTaskCreator: true,
                ActorHoldsActiveAssignment: false,
                ActorMayReassign: true,
                TaskOrganizationID: ORG_A,
                ActorOrganizationIDs: [ORG_B],
            }),
        ).toBe(CROSS_ORG_CLOSE_REFUSAL);

        expect(
            ApprovalOrganizationChangeRefusal({
                WasApprovalType: true,
                IsApprovalType: true,
                PreviousOrganizationID: ORG_A,
                NewOrganizationID: ORG_B,
                ActorIsSystem: false,
            }),
        ).toBe(ORG_CHANGE_REFUSAL);

        expect(
            ApprovalOrganizationChangeRefusal({
                WasApprovalType: true,
                IsApprovalType: true,
                PreviousOrganizationID: ORG_A,
                NewOrganizationID: ORG_A,
                ActorIsSystem: false,
            }),
        ).toBeNull();
    });
});
