import { describe, expect, it } from 'vitest';
import { DeciderAssignments, TaskDecisionRefusal, type TaskDecisionFacts } from '../TaskDecisionAuthority.js';

const PEOPLE = 'A0000000-0000-0000-0000-000000000001';
const USERS = 'A0000000-0000-0000-0000-000000000002';
const APPROVER_USER = 'B0000000-0000-0000-0000-000000000001';
const APPROVER_PERSON = 'C0000000-0000-0000-0000-000000000001';
const REQUESTER_PERSON = 'C0000000-0000-0000-0000-000000000002';

function facts(overrides: Partial<TaskDecisionFacts> = {}): TaskDecisionFacts {
    return {
        PreventSelfApproval: true,
        IsApprovalTask: true,
        DeciderUserID: APPROVER_USER,
        DeciderPersonIDs: [APPROVER_PERSON],
        DecidedByPersonID: APPROVER_PERSON,
        TaskAssignmentID: null,
        TaskCreatedByPersonID: REQUESTER_PERSON,
        Assignments: [{ ID: 'asg-1', AssigneeEntityID: PEOPLE, AssigneeRecordID: APPROVER_PERSON, Status: 'Pending' }],
        IsPeopleEntityID: (id) => id.toLowerCase() === PEOPLE.toLowerCase(),
        UsersEntityID: USERS,
        DeciderIsExempt: false,
        ...overrides,
    };
}

describe('TaskDecisionRefusal', () => {
    it('accepts an assignee deciding a task someone else created', () => {
        expect(TaskDecisionRefusal(facts())).toBeNull();
    });

    it('accepts anything while PreventSelfApproval is off (the neutral default)', () => {
        expect(TaskDecisionRefusal(facts({ PreventSelfApproval: false, Assignments: [], TaskCreatedByPersonID: APPROVER_PERSON }))).toBeNull();
    });

    it('never checks a task whose type is not an approval type', () => {
        expect(TaskDecisionRefusal(facts({ IsApprovalTask: false, Assignments: [] }))).toBeNull();
    });

    it('refuses a decider who is not assigned', () => {
        expect(TaskDecisionRefusal(facts({ Assignments: [{ ID: 'asg-2', AssigneeEntityID: PEOPLE, AssigneeRecordID: REQUESTER_PERSON, Status: 'Pending' }] })))
            .toMatch(/not assigned to you/);
    });

    it('refuses a task with no assignments at all', () => {
        expect(TaskDecisionRefusal(facts({ Assignments: [] }))).toMatch(/not assigned to you/);
    });

    it('accepts an assignee assigned as an MJ user directly (the accounting batch approver)', () => {
        const f = facts({ Assignments: [{ ID: 'asg-u', AssigneeEntityID: USERS, AssigneeRecordID: APPROVER_USER.toLowerCase(), Status: 'Pending' }] });
        expect(TaskDecisionRefusal(f)).toBeNull();
    });

    it('compares IDs case-insensitively', () => {
        expect(TaskDecisionRefusal(facts({ DecidedByPersonID: APPROVER_PERSON.toLowerCase() }))).toBeNull();
    });

    it('refuses a decision attributed to another person', () => {
        expect(TaskDecisionRefusal(facts({ DecidedByPersonID: REQUESTER_PERSON }))).toMatch(/someone other than you/);
    });

    it('accepts a decision attributed to nobody when the decider is an assignee', () => {
        expect(TaskDecisionRefusal(facts({ DecidedByPersonID: null }))).toBeNull();
    });

    it("refuses a decision recorded against someone else's assignment", () => {
        const f = facts({
            TaskAssignmentID: 'asg-2',
            Assignments: [
                { ID: 'asg-1', AssigneeEntityID: PEOPLE, AssigneeRecordID: APPROVER_PERSON, Status: 'Pending' },
                { ID: 'asg-2', AssigneeEntityID: PEOPLE, AssigneeRecordID: REQUESTER_PERSON, Status: 'Pending' },
            ],
        });
        expect(TaskDecisionRefusal(f)).toMatch(/assignment that is not yours/);
    });

    it('accepts a decision recorded against the decider\'s own assignment', () => {
        expect(TaskDecisionRefusal(facts({ TaskAssignmentID: 'asg-1' }))).toBeNull();
    });

    it('refuses the creator of the task even when they are assigned', () => {
        expect(TaskDecisionRefusal(facts({ TaskCreatedByPersonID: APPROVER_PERSON }))).toMatch(/Nobody may approve their own request/);
    });

    it('lets a holder of the exempt role decide a task they created, as an assignee', () => {
        expect(TaskDecisionRefusal(facts({ TaskCreatedByPersonID: APPROVER_PERSON, DeciderIsExempt: true }))).toBeNull();
    });

    it('still requires the exempt role holder to be an assignee', () => {
        expect(TaskDecisionRefusal(facts({ TaskCreatedByPersonID: APPROVER_PERSON, DeciderIsExempt: true, Assignments: [] })))
            .toMatch(/not assigned to you/);
    });

    it('treats a task with no recorded creator as nobody\'s own request (TaskEntityServer stamps one whenever the creating user has a Person)', () => {
        expect(TaskDecisionRefusal(facts({ TaskCreatedByPersonID: null }))).toBeNull();
    });

    it('accepts an InProgress assignment', () => {
        expect(TaskDecisionRefusal(facts({ Assignments: [{ ID: 'asg-1', AssigneeEntityID: PEOPLE, AssigneeRecordID: APPROVER_PERSON, Status: 'InProgress' }] }))).toBeNull();
    });

    it('refuses a decider whose only assignment is Completed', () => {
        expect(TaskDecisionRefusal(facts({ Assignments: [{ ID: 'asg-1', AssigneeEntityID: PEOPLE, AssigneeRecordID: APPROVER_PERSON, Status: 'Completed' }] })))
            .toMatch(/already completed/);
    });

    it('refuses a decision naming the decider\'s own Completed assignment even when they hold another active one', () => {
        const f = facts({
            TaskAssignmentID: 'asg-done',
            Assignments: [
                { ID: 'asg-done', AssigneeEntityID: PEOPLE, AssigneeRecordID: APPROVER_PERSON, Status: 'Completed' },
                { ID: 'asg-live', AssigneeEntityID: USERS, AssigneeRecordID: APPROVER_USER, Status: 'Pending' },
            ],
        });
        expect(TaskDecisionRefusal(f)).toMatch(/already completed/);
        expect(TaskDecisionRefusal({ ...f, TaskAssignmentID: 'asg-live' })).toBeNull();
    });

    it('refuses a decider with no linked person unless they are assigned as a user', () => {
        expect(TaskDecisionRefusal(facts({ DeciderPersonIDs: [], DecidedByPersonID: null }))).toMatch(/not assigned to you/);
        expect(TaskDecisionRefusal(facts({
            DeciderPersonIDs: [],
            DecidedByPersonID: null,
            Assignments: [{ ID: 'asg-u', AssigneeEntityID: USERS, AssigneeRecordID: APPROVER_USER, Status: 'Pending' }],
        }))).toBeNull();
    });
});

describe('DeciderAssignments', () => {
    it('ignores an assignment to another entity that happens to carry the same record ID', () => {
        const other = 'A0000000-0000-0000-0000-000000000099';
        expect(DeciderAssignments(facts({ Assignments: [{ ID: 'x', AssigneeEntityID: other, AssigneeRecordID: APPROVER_PERSON, Status: 'Pending' }] }))).toEqual([]);
    });
});
