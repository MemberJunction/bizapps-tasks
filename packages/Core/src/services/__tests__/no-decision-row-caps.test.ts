import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import ts from 'typescript';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, '..', '..', '..', '..', '..');

/**
 * Decision-feeding paths across approval inbox, authorization, recurring-close,
 * latency reporting, and workflow dispatch that must NEVER apply arbitrary row caps
 * (`MaxRows`, `TOP`, `LIMIT`) that could truncate decision-feeding datasets.
 */
const DECISION_FEEDING_LIST_FILES: readonly string[] = [
    'packages/Core/src/services/ApprovalLatencyService.ts',
    'packages/EntitiesServer/src/ApprovalActor.ts',
    'packages/EntitiesServer/src/ApprovalTaskAuthority.ts',
    'packages/EntitiesServer/src/TaskDecisionAuthority.ts',
    'packages/EntitiesServer/src/TaskAssignmentEntityServer.ts',
    'packages/EntitiesServer/src/UserPeople.ts',
    'packages/Actions/src/custom/ApprovalOutcomeHookAction.ts',
    'packages/Angular/src/lib/components/approval-inbox/approval-inbox.component.ts',
    'packages/Angular/src/lib/pages/approvals.page.ts',
];

/**
 * Files where `MaxRows` is permitted ONLY on single-record PK/latest-row or ambiguity lookups
 * (`DefaultLookupSingleRow` / `AmbiguousLookupMaxRows`) and NEVER on multi-row decision sets.
 */
const SINGLE_ROW_LOOKUP_ALLOWLIST: Readonly<Record<string, readonly string[]>> = {
    'packages/Core/src/services/TaskOrchestrationService.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
    ],
    'packages/EntitiesServer/src/TaskDecisionEntityServer.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
        'singleRowMax',
    ],
    'packages/EntitiesServer/src/TaskEntityServer.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
        'singleRowMax',
    ],
    'packages/EntitiesServer/src/TimesheetApprovalEntityServer.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
    ],
    'packages/EntitiesServer/src/TasksRemoteOperationsServer.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
        'limits.ResourceGuards.DefaultLookupSingleRow',
    ],
    'packages/Actions/src/custom/ExecuteAssignedAgentAction.ts': [
        'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow',
    ],
    'packages/Server/src/workflow/BizAppsTasksHumanTaskProvider.ts': [
        'limits.ResourceGuards.AmbiguousLookupMaxRows',
        'limits.ResourceGuards.DefaultLookupSingleRow',
    ],
    'packages/Server/src/workflow/workflow-step-completion.ts': [
        'singleRowMax',
    ],
};

function findMaxRowsAssignments(fileRel: string): Array<{ line: number; valueText: string }> {
    const abs = resolve(REPO_ROOT, fileRel);
    const sourceText = readFileSync(abs, 'utf8');
    const sf = ts.createSourceFile(fileRel, sourceText, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
    const hits: Array<{ line: number; valueText: string }> = [];

    function visit(node: ts.Node): void {
        if (ts.isPropertyAssignment(node)) {
            const nameText = ts.isIdentifier(node.name) || ts.isStringLiteral(node.name) ? node.name.text : '';
            if (nameText === 'MaxRows') {
                const line = sf.getLineAndCharacterOfPosition(node.getStart(sf)).line + 1;
                hits.push({ line, valueText: node.initializer.getText(sf).trim() });
            }
        }
        ts.forEachChild(node, visit);
    }

    visit(sf);
    return hits;
}

describe('Zero decision-feeding row caps guard', () => {
    it('forbids any MaxRows, TOP N, or LIMIT N in multi-row decision-feeding approval, authz, latency, and inbox paths', () => {
        const sqlCapRe = /\bSELECT\s+TOP\s+\d+|\bLIMIT\s+\d+\b/i;

        for (const rel of DECISION_FEEDING_LIST_FILES) {
            const source = readFileSync(resolve(REPO_ROOT, rel), 'utf8');
            const maxRowsHits = findMaxRowsAssignments(rel);
            expect(maxRowsHits, `Unexpected MaxRows cap in decision-feeding file ${rel}`).toEqual([]);
            expect(sqlCapRe.test(source), `Unexpected SQL TOP/LIMIT cap in ${rel}`).toBe(false);
        }
    });

    it('restricts MaxRows in decision/workflow/recurring-close orchestration exclusively to single-row or ambiguity lookups', () => {
        const sqlCapRe = /\bSELECT\s+TOP\s+\d+|\bLIMIT\s+\d+\b/i;

        for (const [rel, allowedExprs] of Object.entries(SINGLE_ROW_LOOKUP_ALLOWLIST)) {
            const source = readFileSync(resolve(REPO_ROOT, rel), 'utf8');
            expect(sqlCapRe.test(source), `Unexpected SQL TOP/LIMIT cap in ${rel}`).toBe(false);

            const hits = findMaxRowsAssignments(rel);
            for (const hit of hits) {
                expect(
                    allowedExprs.includes(hit.valueText),
                    `Unexpected MaxRows expression '${hit.valueText}' at ${rel}:${hit.line}`,
                ).toBe(true);
            }
        }
    });
});
