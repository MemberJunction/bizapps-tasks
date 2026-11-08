import { describe, expect, it } from 'vitest';
import {
    CountedAgentRuns,
    SummarizeAgentRuns,
    type AgentRunEffortFact,
} from '../time/AgentEffortDeduplication.js';
import {
    GroupIntoParts,
    PartSnapshotHash,
    ResolveApprovers,
    TimesheetStatusFromParts,
    type ApproverResolutionContext,
    type TaskHierarchyNode,
    type TimesheetEntryFact,
} from '../time/TimesheetApproverResolution.js';

const ROOT_A = '10000000-0000-4000-8000-000000000001';
const CHILD_A1 = '10000000-0000-4000-8000-000000000002';
const ROOT_B = '20000000-0000-4000-8000-000000000001';

const WORKER_ID = '30000000-0000-4000-8000-000000000001';
const LEAD_A = '40000000-0000-4000-8000-000000000001';
const SUBTASK_LEAD = '40000000-0000-4000-8000-000000000002';
const SPACE_LEAD = '40000000-0000-4000-8000-000000000003';
const MANAGER_ID = '40000000-0000-4000-8000-000000000004';
const ROLE_APPROVER = '40000000-0000-4000-8000-000000000005';

const TASKS_ENTITY_ID = 'E0000000-0000-4000-8000-000000000001';
const PEOPLE_ENTITY_ID = 'E0000000-0000-4000-8000-000000000002';
const SPACES_ENTITY_ID = 'E0000000-0000-4000-8000-000000000003';

describe('CountedAgentRuns & SummarizeAgentRuns (§6.3, §6.4)', () => {
    it('deduplicates child and grandchild runs when an ancestor run is linked in the same scope', () => {
        const parentRunId = 'A0000000-0000-4000-8000-000000000001';
        const child1Id = 'A0000000-0000-4000-8000-000000000002';
        const child2Id = 'A0000000-0000-4000-8000-000000000003';
        const siblingRootId = 'B0000000-0000-4000-8000-000000000001';

        const runs: AgentRunEffortFact[] = [
            {
                AIAgentRunID: parentRunId,
                ParentRunID: null,
                ParentRunIDPath: `/${parentRunId}/`,
                TaskID: ROOT_A,
                DurationSeconds: 120,
                TotalTokensUsedRollup: 10_000,
                TotalCostRollup: 0.25,
            },
            {
                AIAgentRunID: child1Id,
                ParentRunID: parentRunId,
                ParentRunIDPath: `/${parentRunId}/${child1Id}/`,
                TaskID: ROOT_A,
                DurationSeconds: 45,
                TotalTokensUsed: 4_000,
                TotalCost: 0.1,
            },
            {
                AIAgentRunID: child2Id,
                ParentRunID: parentRunId,
                ParentRunIDPath: `/${parentRunId}/${child2Id}/`,
                TaskID: CHILD_A1,
                DurationSeconds: 50,
                TotalTokensUsed: 5_000,
                TotalCost: 0.12,
            },
            {
                AIAgentRunID: siblingRootId,
                ParentRunID: null,
                ParentRunIDPath: `/${siblingRootId}/`,
                TaskID: CHILD_A1,
                DurationSeconds: 30,
                TotalTokensUsed: 2_000,
                TotalCost: 0.05,
            },
        ];

        // Subtree rollup (PerTask: false): parentRunId covers child1Id and child2Id, plus siblingRootId
        const subtreeCounted = CountedAgentRuns(runs, { PerTask: false });
        expect(subtreeCounted.map((r) => r.AIAgentRunID)).toEqual([parentRunId, siblingRootId]);

        const summary = SummarizeAgentRuns(runs, { PerTask: false });
        expect(summary.AgentRunCount).toBe(2);
        expect(summary.AgentWallClockSeconds).toBe(150);
        expect(summary.AgentTotalTokens).toBe(12_000);
        expect(summary.AgentTotalCost).toBeCloseTo(0.3, 6);

        // Per-task rollup (PerTask: true): on CHILD_A1, parentRunId is NOT linked to CHILD_A1, so child2Id IS counted for CHILD_A1's own view
        const perTaskCounted = CountedAgentRuns(runs, { PerTask: true });
        expect(perTaskCounted.map((r) => r.AIAgentRunID)).toEqual([parentRunId, child2Id, siblingRootId]);
    });

    it('counts a shared run linked to two tasks in the same subtree only once', () => {
        const sharedRunId = 'C0000000-0000-4000-8000-000000000001';
        const runs: AgentRunEffortFact[] = [
            {
                AIAgentRunID: sharedRunId,
                TaskID: ROOT_A,
                DurationSeconds: 60,
                TotalTokensUsed: 3_000,
                TotalCost: 0.08,
            },
            {
                AIAgentRunID: sharedRunId,
                TaskID: CHILD_A1,
                DurationSeconds: 60,
                TotalTokensUsed: 3_000,
                TotalCost: 0.08,
            },
        ];

        const subtreeSummary = SummarizeAgentRuns(runs, { PerTask: false });
        expect(subtreeSummary.AgentRunCount).toBe(1);
        expect(subtreeSummary.AgentTotalTokens).toBe(3_000);
        expect(subtreeSummary.AgentTotalCost).toBeCloseTo(0.08, 6);
    });
});

describe('ResolveApprovers, GroupIntoParts, PartSnapshotHash, TimesheetStatusFromParts (§6.5, §6.6)', () => {
    const tasks: TaskHierarchyNode[] = [
        { ID: ROOT_A, Name: 'Project Alpha', ParentID: null, RootParentID: ROOT_A },
        { ID: CHILD_A1, Name: 'Discovery Workshop', ParentID: ROOT_A, RootParentID: ROOT_A },
        { ID: ROOT_B, Name: 'Project Beta', ParentID: null, RootParentID: ROOT_B },
    ];

    function makeContext(overrides: Partial<ApproverResolutionContext> = {}): ApproverResolutionContext {
        return {
            SubmitterPersonID: WORKER_ID,
            SubmitterPersonName: 'Alice Martin',
            ReferenceDate: '2026-11-04',
            TasksEntityID: TASKS_ENTITY_ID,
            PeopleEntityID: PEOPLE_ENTITY_ID,
            Tasks: tasks,
            ApproverRules: [],
            FallbackRelationshipApproverPersonIDs: [],
            FallbackRoleApproverPersonIDs: [],
            ...overrides,
        };
    }

    it('prefers a subtask own approver over its root project approver (nearest in task chain)', () => {
        const ctx = makeContext({
            ApproverRules: [
                { ApproverPersonID: LEAD_A, ScopeTaskID: ROOT_A, IncludeDescendants: true },
                { ApproverPersonID: SUBTASK_LEAD, ScopeTaskID: CHILD_A1, IncludeDescendants: true },
            ],
        });

        const res = ResolveApprovers({ TaskID: CHILD_A1, WorkDate: '2026-11-04' }, ctx);
        expect(res.ResolutionSource).toBe('TaskChain');
        expect(res.ScopeTaskID).toBe(CHILD_A1);
        expect(res.ScopeLabel).toBe('Discovery Workshop');
        expect(res.ApproverPersonIDs).toEqual([SUBTASK_LEAD]);
    });

    it('walks up to the root project when the subtask has no approver (or when the subtask approver is the submitter)', () => {
        const ctx = makeContext({
            ApproverRules: [
                // Submitter is named on the subtask -> removed by self-exclusion!
                { ApproverPersonID: WORKER_ID, ScopeTaskID: CHILD_A1, IncludeDescendants: true },
                // Project lead is named on the root task -> wins!
                { ApproverPersonID: LEAD_A, ScopeTaskID: ROOT_A, IncludeDescendants: true },
            ],
        });

        const res = ResolveApprovers({ TaskID: CHILD_A1, WorkDate: '2026-11-04' }, ctx);
        expect(res.ResolutionSource).toBe('TaskChain');
        expect(res.ScopeTaskID).toBe(ROOT_A);
        expect(res.ScopeLabel).toBe('Project Alpha');
        expect(res.ApproverPersonIDs).toEqual([LEAD_A]);
    });

    it('walks resolver scope records in priority order, then worker People rules, then relationship, then role fallback', () => {
        const spaceId = 'S0000000-0000-4000-8000-000000000001';
        const resolverMap = new Map([
            [
                ROOT_A.toLowerCase(),
                [
                    {
                        ScopeEntityID: SPACES_ENTITY_ID,
                        ScopeRecordID: spaceId,
                        ScopeLabel: 'Client Delivery Space',
                        Priority: 10,
                    },
                ],
            ],
        ]);

        // 1. Resolver scope wins when TimeApprover is named on the Space
        const resolverCtx = makeContext({
            ResolverScopesByRootTaskID: resolverMap,
            ApproverRules: [
                {
                    ApproverPersonID: SPACE_LEAD,
                    ScopeEntityID: SPACES_ENTITY_ID,
                    ScopeRecordID: spaceId,
                },
            ],
            FallbackRelationshipApproverPersonIDs: [MANAGER_ID],
        });
        const fromResolver = ResolveApprovers({ TaskID: CHILD_A1 }, resolverCtx);
        expect(fromResolver.ResolutionSource).toBe('ResolverScope');
        expect(fromResolver.ScopeEntityID).toBe(SPACES_ENTITY_ID);
        expect(fromResolver.ScopeRecordID).toBe(spaceId);
        expect(fromResolver.ScopeLabel).toBe('Client Delivery Space');
        expect(fromResolver.ApproverPersonIDs).toEqual([SPACE_LEAD]);

        // 2. Worker People rule wins when no task or resolver rule matches
        const personRuleCtx = makeContext({
            ApproverRules: [{ ApproverPersonID: MANAGER_ID, WorkerPersonID: WORKER_ID }],
            FallbackRoleApproverPersonIDs: [ROLE_APPROVER],
        });
        const fromPersonRule = ResolveApprovers({ TaskID: ROOT_B }, personRuleCtx);
        expect(fromPersonRule.ResolutionSource).toBe('PersonRule');
        expect(fromPersonRule.ScopeEntityID).toBe(PEOPLE_ENTITY_ID);
        expect(fromPersonRule.ScopeRecordID).toBe(WORKER_ID);
        expect(fromPersonRule.ScopeLabel).toBe("Alice Martin's approver");
        expect(fromPersonRule.ApproverPersonIDs).toEqual([MANAGER_ID]);

        // 3. Relationship fallback wins when no TimeApprover rule matches
        const relCtx = makeContext({
            FallbackRelationshipApproverPersonIDs: [WORKER_ID, MANAGER_ID],
            FallbackRoleApproverPersonIDs: [ROLE_APPROVER],
        });
        const fromRel = ResolveApprovers({ TaskID: ROOT_B }, relCtx);
        expect(fromRel.ResolutionSource).toBe('RelationshipFallback');
        expect(fromRel.ApproverPersonIDs).toEqual([MANAGER_ID]);

        // 4. Role fallback wins when relationship is empty
        const roleCtx = makeContext({
            FallbackRoleApproverPersonIDs: [WORKER_ID, ROLE_APPROVER],
        });
        const fromRole = ResolveApprovers({ TaskID: ROOT_B }, roleCtx);
        expect(fromRole.ResolutionSource).toBe('RoleFallback');
        expect(fromRole.ApproverPersonIDs).toEqual([ROLE_APPROVER]);

        // 5. Refuses when nobody is left after removing submitter
        const noneCtx = makeContext({
            FallbackRoleApproverPersonIDs: [WORKER_ID],
        });
        const unresolved = ResolveApprovers({ TaskID: ROOT_B, TaskName: 'Project Beta' }, noneCtx);
        expect(unresolved.ResolutionSource).toBe('Unresolved');
        expect(unresolved.ApproverPersonIDs).toEqual([]);
        expect(unresolved.RefusalMessage).toContain('No approver for time on Project Beta');
    });

    it('groups entries into parts and computes stable SHA-256 snapshot hashes', () => {
        const entries: TimesheetEntryFact[] = [
            {
                ID: 'E-1',
                TaskID: CHILD_A1,
                TaskName: 'Discovery Workshop',
                WorkDate: '2026-11-02',
                Minutes: 120,
                IsBillable: true,
                Notes: 'Kickoff',
            },
            {
                ID: 'E-2',
                TaskID: ROOT_B,
                TaskName: 'Project Beta',
                WorkDate: '2026-11-03',
                Minutes: 60,
                IsBillable: false,
                Notes: 'Internal sync',
            },
        ];

        const ctx = makeContext({
            ApproverRules: [{ ApproverPersonID: LEAD_A, ScopeTaskID: ROOT_A, IncludeDescendants: true }],
            FallbackRelationshipApproverPersonIDs: [MANAGER_ID],
        });

        const grouped = GroupIntoParts(entries, ctx, 'ProjectApproval');
        expect(grouped.RefusalMessage).toBeNull();
        expect(grouped.Parts).toHaveLength(2);

        // Hash is order-independent across entries and changes when any entry field changes
        const h1 = PartSnapshotHash(entries);
        const h2 = PartSnapshotHash([entries[1], entries[0]]);
        expect(h1).toHaveLength(64);
        expect(h1).toBe(h2);

        const hChangedMinutes = PartSnapshotHash([{ ...entries[0], Minutes: 125 }, entries[1]]);
        const hChangedBillable = PartSnapshotHash([{ ...entries[0], IsBillable: false }, entries[1]]);
        expect(hChangedMinutes).not.toBe(h1);
        expect(hChangedBillable).not.toBe(h1);
    });

    it('aggregates TimesheetStatusFromParts accurately', () => {
        expect(TimesheetStatusFromParts(['Approved', 'Approved'])).toBe('Approved');
        expect(TimesheetStatusFromParts(['Approved', 'Canceled'])).toBe('Approved');
        expect(TimesheetStatusFromParts(['Approved', 'Pending'])).toBe('Submitted');
        expect(TimesheetStatusFromParts(['Approved', 'Rejected', 'Pending'])).toBe('Rejected');
        expect(TimesheetStatusFromParts(['Canceled'])).toBe('Draft');
    });
});
