#!/usr/bin/env node
/**
 * Mechanical numeric literal sweep & classification script for MemberJunction/bizapps-tasks.
 *
 * Deterministically scans TypeScript source files across `packages/` (excluding tests,
 * declarations, `generated/`, `dist/`, and `node_modules/`) for bounding numeric literals:
 * comparisons, loop bounds, `.slice()`/`.substring()` caps, `MaxRows`, recursion/hierarchy
 * depth caps, batch/chunk sizes, timeouts, retries, briefing contributor bounds, and polling
 * intervals.
 *
 * Classifies every hit into one of the 5 canonical categories:
 *   - `RunawayGuard`
 *   - `ResourceGuard`
 *   - `ProtocolLimit`
 *   - `UX`
 *   - `Tuning`
 *
 * Outputs an RFC-4180 CSV with columns:
 *   `file,line,name,value,enclosingFunction,label,disposition`
 *
 * Usage:
 *   node scripts/sweep-limits.mjs --out scripts/limits-sweep-classified.csv --also .mj/specs/limits-sweep-bizapps-tasks.csv
 *   node scripts/sweep-limits.mjs --json
 *   node scripts/sweep-limits.mjs --check-runaway
 */

import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import ts from 'typescript';

const DEFAULT_REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
export const CANONICAL_LIMITS_CONFIG_REL = 'packages/Core/src/config/TasksLimits.ts';
export const CSV_HEADER = 'file,line,name,value,enclosingFunction,label,disposition';

export const VALID_LABELS = new Set([
    'RunawayGuard',
    'ResourceGuard',
    'ProtocolLimit',
    'UX',
    'Tuning',
]);

const SOURCE_EXTENSIONS = new Set(['.ts', '.tsx', '.mts', '.cts']);
const SKIP_DIRS = new Set([
    'node_modules',
    'dist',
    'build',
    'coverage',
    '__tests__',
    '__mocks__',
    'generated',
    '.angular',
    '.turbo',
    '.git',
]);
const SKIP_FILE_RE = /\.(?:test|spec|dom\.test|d)\.(?:ts|tsx|mts|cts)$|^(?:vitest|vite)\.config\./;

const UX_PATH_RE = /^packages\/(?:Angular|AngularWidgets)\//;
const INTEGRATION_TEST_PATH_RE = /^packages\/IntegrationTests\//;

const RUNAWAY_KEYS = new Set([
    'MaxBulkTasks',
    'MaxHierarchyDepth',
    'MaxSupervisorChainDepth',
    'MaxDependencyWalkIterations',
    'MaxTemplateSortIterations',
    'MaxSeriesOccurrences',
    'BriefingMaxItemsCeiling',
    'BriefingMaxHorizonDays',
    'BriefingMaxLookbackDays',
    'BriefingWorkReportsMaxLookbackDays',
    'FindMeetingsMaxHorizonDays',
    'FindMeetingsMaxPastHours',
    'FindMeetingsMaxLimit',
    'FindSimilarTasksMaxWindowDays',
    'FindSimilarTasksMaxLimit',
    'ContributorTimeoutMs',
    'MaxContributorChars',
]);

const RESOURCE_GUARD_KEYS = new Set([
    'DefaultLookupSingleRow',
    'AmbiguousLookupMaxRows',
    'RecentLinksMaxRows',
    'RecentContextMaxRows',
    'CandidateLookupMaxRows',
    'RelatedSearchMaxRows',
    'StandardListMaxRows',
    'StandardBatchMaxRows',
    'ExtendedSearchMaxRows',
    'WorkflowBatchMaxRows',
    'BriefingTasksMaxRows',
    'BroadEntityQueryMaxRows',
    'LargeTreeQueryMaxRows',
    'SeriesMaterializationMaxRows',
    'SubtreeEffortMaxRows',
    'FindTasksDefaultMaxRows',
    'FindTasksMaxRowsCeiling',
    'FindTasksSemanticSearchFloor',
    'FindTasksSearchFetchCeiling',
    'FindWorkReportsDefaultMaxRows',
    'FindWorkReportsMaxRowsCeiling',
    'ReconcileTimesheetApprovalsDefaultMaxRows',
    'ReconcileTimesheetApprovalsMaxRowsCeiling',
    'SqlInClauseChunkSize',
    'MaxSavedTaskViews',
    'MaxMeetingTranscriptChars',
    'ZoomApiTimeoutMs',
    'TeamsWebhookTimeoutMs',
]);

const COMMENT_TAG_RE = /\/\/\s*(RunawayGuard|ResourceGuard|ProtocolLimit|UX|Tuning)\s*:\s*(.+)/;

function walkSourceFiles(dir, out = []) {
    if (!existsSync(dir)) return out;
    const entries = readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
    for (const entry of entries) {
        if (SKIP_DIRS.has(entry.name)) continue;
        const full = join(dir, entry.name);
        if (entry.isDirectory()) {
            walkSourceFiles(full, out);
        } else if (entry.isFile() && SOURCE_EXTENSIONS.has(extname(entry.name)) && !SKIP_FILE_RE.test(entry.name)) {
            out.push(full);
        }
    }
    return out;
}

function isArithmeticBinaryNode(node) {
    return (
        ts.isBinaryExpression(node) &&
        (node.operatorToken.kind === ts.SyntaxKind.AsteriskToken ||
            node.operatorToken.kind === ts.SyntaxKind.PlusToken ||
            node.operatorToken.kind === ts.SyntaxKind.MinusToken ||
            node.operatorToken.kind === ts.SyntaxKind.SlashToken ||
            node.operatorToken.kind === ts.SyntaxKind.PercentToken ||
            node.operatorToken.kind === ts.SyntaxKind.AsteriskAsteriskToken)
    );
}

function evaluateNumericExpr(node) {
    if (ts.isNumericLiteral(node)) {
        return Number(node.text);
    }
    if (ts.isPrefixUnaryExpression(node)) {
        const inner = evaluateNumericExpr(node.operand);
        if (inner === null) return null;
        if (node.operator === ts.SyntaxKind.MinusToken) return -inner;
        if (node.operator === ts.SyntaxKind.PlusToken) return inner;
        return null;
    }
    if (ts.isParenthesizedExpression(node)) {
        return evaluateNumericExpr(node.expression);
    }
    if (isArithmeticBinaryNode(node)) {
        const left = evaluateNumericExpr(node.left);
        const right = evaluateNumericExpr(node.right);
        if (left === null || right === null) return null;
        switch (node.operatorToken.kind) {
            case ts.SyntaxKind.AsteriskToken: return left * right;
            case ts.SyntaxKind.PlusToken: return left + right;
            case ts.SyntaxKind.MinusToken: return left - right;
            case ts.SyntaxKind.SlashToken: return right !== 0 ? left / right : null;
            case ts.SyntaxKind.PercentToken: return right !== 0 ? left % right : null;
            case ts.SyntaxKind.AsteriskAsteriskToken: return left ** right;
            default: return null;
        }
    }
    return null;
}

function isInsideSkippedNode(node, relFile) {
    for (let cur = node.parent; cur; cur = cur.parent) {
        if (ts.isTypeNode(cur) || ts.isInterfaceDeclaration(cur) || ts.isTypeAliasDeclaration(cur)) {
            return true;
        }
        if (ts.isCallExpression(cur)) {
            const calleeText = cur.expression.getText?.() ?? '';
            if (calleeText.startsWith('z.') || calleeText.startsWith('Date.UTC')) {
                return true;
            }
        }
        if (relFile === CANONICAL_LIMITS_CONFIG_REL && ts.isVariableDeclaration(cur) && ts.isIdentifier(cur.name)) {
            if (cur.name.text === 'TASKS_LIMIT_SAFETY_BOUNDS') {
                return true;
            }
        }
    }
    return false;
}

function isInsideLoopCondition(comparisonNode) {
    let cur = comparisonNode;
    while (cur.parent) {
        const parent = cur.parent;
        if (ts.isWhileStatement(parent) || ts.isDoStatement(parent)) {
            return parent.expression === cur;
        }
        if (ts.isForStatement(parent)) {
            return parent.condition === cur;
        }
        if (ts.isParenthesizedExpression(parent) || ts.isBinaryExpression(parent)) {
            cur = parent;
            continue;
        }
        break;
    }
    return false;
}

function sanitizeSymbol(raw) {
    return raw.replace(/\s+/g, ' ').trim().slice(0, 96);
}

function readExplicitCommentTag(lines, lineIndexZeroBased) {
    const ownLine = lines[lineIndexZeroBased] ?? '';
    const ownMatch = COMMENT_TAG_RE.exec(ownLine);
    if (ownMatch) return { label: ownMatch[1], detail: ownMatch[2].trim() };

    for (let i = lineIndexZeroBased - 1; i >= 0 && i >= lineIndexZeroBased - 3; i--) {
        const trimmed = (lines[i] ?? '').trim();
        if (trimmed === '') break;
        const match = COMMENT_TAG_RE.exec(trimmed);
        if (match) return { label: match[1], detail: match[2].trim() };
        if (!trimmed.startsWith('//') && !trimmed.startsWith('*') && !trimmed.startsWith('/*')) break;
    }
    return null;
}

function isDateFormattingSlice(calleeExprText, arg0Val, arg1Val) {
    if (
        /(?:toISOString|WorkDate|PeriodStart|PeriodEnd|StartedAt|EndedAt|DueAt|anchorDate|periodKey|day|dateStr|endIso|trimmed)\b/i.test(calleeExprText) &&
        (arg1Val === 7 || arg1Val === 10 || arg1Val === 16)
    ) {
        return true;
    }
    if (calleeExprText.includes('Math.random()')) {
        return true;
    }
    if (arg0Val === 2 && arg1Val === 6 && calleeExprText.includes('toString(36)')) {
        return true;
    }
    return false;
}

function extractHitFromNode(node, sf, fnStack, relFile) {
    if (isInsideSkippedNode(node, relFile)) return null;

    // Avoid matching hex SHA-256 constants as work bounds
    if (ts.isNumericLiteral(node) && /^0x[0-9a-f]+$/i.test(node.text)) {
        return null;
    }

    const p = node.parent;
    let name = null;
    let isLoopBound = false;
    let isTimeoutCall = false;
    let isSliceCap = false;
    let isMathBound = false;
    let isFallbackExpr = false;
    let lineText = '';

    const { line } = sf.getLineAndCharacterOfPosition(node.getStart(sf));
    lineText = sf.text.split(/\r?\n/)[line] ?? '';

    if (ts.isPropertyAssignment(p) && ts.isIdentifier(p.name) && p.initializer === node) {
        const prop = p.name.text;
        const valCandidate = evaluateNumericExpr(node);
        const isInterestingProp =
            RUNAWAY_KEYS.has(prop) ||
            RESOURCE_GUARD_KEYS.has(prop) ||
            (/^(Depth|depth)$/.test(prop) && valCandidate !== null && valCandidate > 0) ||
            /^(MaxRows|maxRows|Limit|limit|MaxConcurrentTasks|maxConcurrent|WidthPx|Timeout|timeout|TimeoutMs|timeoutMs|Retries|retries|MaxRetries|BatchSize|ChunkSize|HorizonDays|LookbackDays|WindowDays|DurationMinutes)$/i.test(prop) ||
            /^(ContributorTimeoutMs|MaxContributorChars|DefaultBriefing|DefaultMeetings|DefaultWorkReports|MeetingNoteExcerpt|NotificationPreview|TranscriptExcerpt|DefaultSeries|DefaultMeeting|DefaultAgenda|DefaultTask|TranscriptDedup|FindSimilar|FindMeetings|ProposedTask|ZoomToken|HttpErrorDetail|CompletionNotes|FailureNotes)/.test(prop);
        if (isInterestingProp) {
            name = prop;
        }
    } else if (
        (ts.isVariableDeclaration(p) || ts.isPropertyDeclaration(p) || ts.isParameter(p)) &&
        ts.isIdentifier(p.name) &&
        p.initializer === node
    ) {
        const ident = p.name.text;
        if (
            /^(MAX_|MIN_|DEFAULT_|LIMIT_|ZOOM_|TOKEN_|CHUNK_|SETTLE_|PROPOSED_TASK_|DETAIL_SHARE_MS|LIMIT$)/.test(ident) ||
            /^(maxRows|limit|max|timeoutMs|maxDailyLoggedMinutes|DraftConfidence|WidthPx|bottomSafetyPadding|guard)$/i.test(ident)
        ) {
            name = ident;
        }
    } else if (ts.isCallExpression(p) && p.arguments.includes(node)) {
        const exprText = p.expression.getText(sf);
        if (/\.(slice|substring|substr)$/.test(exprText) && p.arguments.length >= 2 && p.arguments[1] === node) {
            const val = evaluateNumericExpr(node);
            const arg0 = evaluateNumericExpr(p.arguments[0]);
            if (val !== null && val > 2 && !isDateFormattingSlice(exprText, arg0, val)) {
                name = `${sanitizeSymbol(exprText)}_Cap`;
                isSliceCap = true;
            }
        } else if (/^Math\.(min|max)$/.test(exprText)) {
            const val = evaluateNumericExpr(node);
            if (val !== null && val > 1) {
                // Skip pure 0..100 percentage normalization unless explicitly a bound
                const callText = p.getText(sf);
                const isPercentClamp = val === 100 && /progress|confidence|Percent|score/i.test(callText);
                if (!isPercentClamp) {
                    name = `${exprText}_Bound`;
                    isMathBound = true;
                }
            }
        } else if (/^(?:AbortSignal\.timeout|setTimeout|setInterval)$/.test(exprText) && p.arguments[p.arguments.length - 1] === node) {
            name = exprText;
            isTimeoutCall = true;
        }
    } else if (ts.isBinaryExpression(p) && p.right === node) {
        const op = p.operatorToken.kind;
        const leftText = sanitizeSymbol(p.left.getText(sf));
        if (op === ts.SyntaxKind.QuestionQuestionToken || op === ts.SyntaxKind.BarBarToken) {
            if (
                /(?:HorizonDays|LookbackDays|WindowDays|DaysAhead|IncludePastHours|MaxItems|MaxRows|Limit|limit|minScore|duplicateThreshold|nearMatchThreshold|durationMinutes|DurationMinutes|DraftConfidence|interval)$/i.test(leftText) ||
                /get(?:First)?NumberParam/i.test(leftText)
            ) {
                name = `${leftText}_Fallback`;
                isFallbackExpr = true;
            }
        } else if (
            op === ts.SyntaxKind.LessThanToken ||
            op === ts.SyntaxKind.LessThanEqualsToken ||
            op === ts.SyntaxKind.GreaterThanToken ||
            op === ts.SyntaxKind.GreaterThanEqualsToken
        ) {
            const numericCandidate = evaluateNumericExpr(node);
            if (isInsideLoopCondition(p)) {
                if (
                    /(?:depth|guard|retry|retries|attempt|attempts|iteration|iterations|turn|turns|i|j|k)$/i.test(leftText) &&
                    numericCandidate !== null &&
                    numericCandidate > 1
                ) {
                    name = `${leftText}_LoopBound`;
                    isLoopBound = true;
                }
            } else if (
                numericCandidate !== null &&
                numericCandidate > 1 &&
                (/(?:offsetWidth|length)$/i.test(leftText) && !/\.length\s*>=?\s*10\b/.test(p.getText(sf)))
            ) {
                if (/offsetWidth/.test(leftText) || /content\.length/.test(leftText)) {
                    name = `${leftText}_Bound`;
                }
            }
        }
    }

    if (!name) return null;

    const numericVal = evaluateNumericExpr(node);
    if (numericVal === null || !Number.isFinite(numericVal)) return null;

    return {
        line: line + 1,
        name,
        value: String(numericVal),
        numericValue: numericVal,
        enclosingFunction: fnStack.length > 0 ? fnStack.join('.') : '<module>',
        isLoopBound,
        isTimeoutCall,
        isSliceCap,
        isMathBound,
        isFallbackExpr,
        lineText: lineText.trim(),
    };
}

function resolveTasksLimitsTargetDisposition(relFile, hit) {
    const f = relFile;
    const n = hit.name;
    const val = hit.numericValue;

    // 1. Canonical resolver itself
    if (f === CANONICAL_LIMITS_CONFIG_REL) {
        return {
            label: RUNAWAY_KEYS.has(n)
                ? 'RunawayGuard'
                : RESOURCE_GUARD_KEYS.has(n)
                    ? 'ResourceGuard'
                    : 'Tuning',
            disposition: 'canonical-limits-resolver',
        };
    }

    // 2. IntegrationTests harness
    if (INTEGRATION_TEST_PATH_RE.test(f)) {
        const label =
            n === 'MaxRows' || hit.isLoopBound || /MAX_|TIMEOUT|MaxConcurrent/i.test(n)
                ? 'ResourceGuard'
                : 'Tuning';
        return { label, disposition: 'retained-integration-test-harness' };
    }

    // 3. Angular UI files
    if (UX_PATH_RE.test(f)) {
        if (n === 'MaxRows' || n === 'maxRows' || n === 'MAX_INLINE_SQL_TASK_IDS') {
            return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards' };
        }
        if (/depth/i.test(n)) {
            return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxHierarchyDepth' };
        }
        return { label: 'UX', disposition: 'retained-ux-local' };
    }

    // 4. Protocol / RFC / Physical-Domain Limits
    if (
        (f.endsWith('ics.ts') && n === 'LIMIT') ||
        (f.endsWith('TimesheetApproverResolution.ts') && hit.isLoopBound) ||
        (f.endsWith('DurationFormatting.ts') && n === 'MAX_ENTRY_MINUTES') ||
        (f.endsWith('LinkAgentRunToTaskAction.ts') && n === 'Math.min_Bound' && val === 1440) ||
        (f.endsWith('TasksSettings.ts'))
    ) {
        return { label: 'ProtocolLimit', disposition: 'retained-protocol-limit' };
    }

    // 5. RunawayGuard literals across Core, Actions, Entities, EntitiesServer, Server
    if (n === 'MAX_BULK_TASKS') {
        return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxBulkTasks' };
    }
    if (n === 'MAX_SUPERVISOR_CHAIN_DEPTH') {
        return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxSupervisorChainDepth' };
    }
    if (f.endsWith('recurrence.ts') && n === 'max') {
        return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxSeriesOccurrences' };
    }
    if (f.endsWith('TaskTypedActions.ts') && n === 'Math.min_Bound') {
        if (val === 30) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxHorizonDays' };
        if (val === 50) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxItemsCeiling' };
        if (val === 365) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.FindSimilarTasksMaxWindowDays' };
        if (val === 25) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.FindSimilarTasksMaxLimit' };
        if (val === 100) return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindTasksMaxRowsCeiling' };
        if (val === 200) return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindTasksSearchFetchCeiling' };
    }
    if (f.endsWith('MeetingTypedActions.ts') && n === 'Math.min_Bound') {
        if (val === 30 && /HorizonDays|DaysAhead/i.test(hit.lineText)) {
            return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxHorizonDays' };
        }
        if (val === 30 && /LookbackDays/i.test(hit.lineText)) {
            return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxLookbackDays' };
        }
        if (val === 72) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.FindMeetingsMaxPastHours' };
        if (val === 50 && /limit/i.test(hit.lineText)) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.FindMeetingsMaxLimit' };
        if (val === 50) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxItemsCeiling' };
    }
    if (f.endsWith('WorkReportActions.ts') && n === 'Math.min_Bound') {
        if (val === 90) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingWorkReportsMaxLookbackDays' };
        if (val === 50) return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.BriefingMaxItemsCeiling' };
        if (val === 100) return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindWorkReportsMaxRowsCeiling' };
    }
    if (f.endsWith('MeetingTranscriptService.ts') && n === 'Math.min_Bound' && val === 365) {
        return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.FindSimilarTasksMaxWindowDays' };
    }
    if (hit.isLoopBound) {
        return { label: 'RunawayGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxHierarchyDepth' };
    }

    // 6. ResourceGuard literals (`MaxRows`, chunks, timeouts, saved views, transcript max chars)
    if (n === 'MaxRows') {
        const keyByVal = {
            1: 'DefaultLookupSingleRow',
            2: 'AmbiguousLookupMaxRows',
            3: 'RecentLinksMaxRows',
            5: 'RecentContextMaxRows',
            10: 'CandidateLookupMaxRows',
            25: 'RelatedSearchMaxRows',
            50: 'StandardListMaxRows',
            100: 'StandardBatchMaxRows',
            150: 'ExtendedSearchMaxRows',
            200: 'WorkflowBatchMaxRows',
            250: 'BriefingTasksMaxRows',
            500: 'BroadEntityQueryMaxRows',
            1000: 'LargeTreeQueryMaxRows',
            2000: 'SeriesMaterializationMaxRows',
            5000: 'SubtreeEffortMaxRows',
        };
        const target = keyByVal[val] ?? 'StandardBatchMaxRows';
        return { label: 'ResourceGuard', disposition: `TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.${target}` };
    }
    if (n === 'CHUNK_SIZE') {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize' };
    }
    if (n === 'MAX_SAVED_TASK_VIEWS') {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxSavedTaskViews' };
    }
    if (n === 'MAX_MEETING_TRANSCRIPT_CHARS') {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.MaxMeetingTranscriptChars' };
    }
    if (n === 'ZOOM_TIMEOUT_MS' || n === 'ZOOM_FETCH_TIMEOUT_MS') {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.ZoomApiTimeoutMs' };
    }
    if (f.endsWith('TimesheetApprovalReconcileJob.ts')) {
        if (n === 'maxRows' || val === 200) {
            return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.ReconcileTimesheetApprovalsDefaultMaxRows' };
        }
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.ReconcileTimesheetApprovalsMaxRowsCeiling' };
    }
    if (hit.isSliceCap && val === 100 && /(?:taskIds|linkedTaskIds)/i.test(n)) {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.StandardBatchMaxRows' };
    }
    if (f.endsWith('TaskTypedActions.ts') && n === 'Math.max_Bound' && val === 40) {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindTasksSemanticSearchFloor' };
    }
    if (f.endsWith('TaskTypedActions.ts') && hit.isFallbackExpr && val === 25) {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindTasksDefaultMaxRows' };
    }
    if (f.endsWith('WorkReportActions.ts') && hit.isFallbackExpr && val === 20) {
        return { label: 'ResourceGuard', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.FindWorkReportsDefaultMaxRows' };
    }

    // 7. Briefing & Tuning literals
    if (f.endsWith('MeetingNotesService.ts') && hit.isSliceCap && val === 8) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.TranscriptExcerptMaxLines' };
    }
    if (f.endsWith('MeetingTypedActions.ts') && hit.isSliceCap && val === 600) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.MeetingNoteExcerptMaxChars' };
    }
    if (f.endsWith('TaskNotificationHandler.ts') && val === 100) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.NotificationPreviewMaxChars' };
    }
    if (/MaxItems/i.test(n) && val === 10) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.DefaultBriefingMaxItems' };
    }
    if (/HorizonDays/i.test(n) && val === 7) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.DefaultBriefingHorizonDays' };
    }
    if (f.endsWith('MeetingTypedActions.ts') && /LookbackDays/i.test(n) && val === 7) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.DefaultMeetingsBriefingLookbackDays' };
    }
    if (f.endsWith('WorkReportActions.ts') && /LookbackDays/i.test(n) && val === 14) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.DefaultWorkReportsBriefingLookbackDays' };
    }
    if (n === 'DEFAULT_HORIZON_DAYS') {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultSeriesHorizonDays' };
    }
    if (n === 'DEFAULT_DURATION_MINUTES') {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultMeetingDurationMinutes' };
    }
    if (n === 'PROPOSED_TASK_CLAIM_TTL_MS') {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.ProposedTaskClaimTtlMs' };
    }
    if (n === 'TOKEN_SAFETY_MARGIN_MS') {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.ZoomTokenSafetyMarginMs' };
    }
    if (hit.isSliceCap && val === 300) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.HttpErrorDetailMaxChars' };
    }
    if (f.endsWith('ExecuteAssignedAgentAction.ts') && hit.isSliceCap) {
        return {
            label: 'Tuning',
            disposition: val === 2000
                ? 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.CompletionNotesMaxChars'
                : 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FailureNotesMaxChars',
        };
    }
    if (f.endsWith('task-similarity.ts') && (n === 'limit' || /limit/i.test(n))) {
        return {
            label: 'Tuning',
            disposition: val === 3
                ? 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.TranscriptDedupMatchLimit'
                : 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultTaskSimilarityLimit',
        };
    }
    if (f.endsWith('TaskTypedActions.ts') && hit.isFallbackExpr && val === 5 && /Limit/i.test(n)) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultTaskSimilarityLimit' };
    }
    if (/WindowDays/i.test(n) && val === 30) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FindSimilarDefaultWindowDays' };
    }
    if (f.endsWith('MeetingTypedActions.ts') && hit.isFallbackExpr) {
        if (/DaysAhead/i.test(n)) {
            return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FindMeetingsDefaultDaysAhead' };
        }
        if (/Limit/i.test(n)) {
            return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FindMeetingsDefaultLimit' };
        }
    }
    if (f.endsWith('MeetingAgendaService.ts') && (val === 10 || val === 5)) {
        return { label: 'Tuning', disposition: 'TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultAgendaItemDurationMinutes' };
    }

    return { label: 'Tuning', disposition: 'local-tuning-default' };
}

/**
 * Classifies a swept numeric literal hit into one of the 5 canonical categories and resolves its disposition.
 */
export function ClassifyLimitHit(relFile, hit, explicitTag) {
    const normalizedFile = relFile.split('\\').join('/');
    if (explicitTag && VALID_LABELS.has(explicitTag.label)) {
        return { label: explicitTag.label, disposition: explicitTag.detail };
    }
    return resolveTasksLimitsTargetDisposition(normalizedFile, hit);
}

function scanSingleFile(absPath, repoRoot) {
    const text = readFileSync(absPath, 'utf8');
    const lines = text.split(/\r?\n/);
    const relFile = relative(repoRoot, absPath).split('\\').join('/');
    const scriptKind = absPath.endsWith('.tsx')
        ? ts.ScriptKind.TSX
        : ts.ScriptKind.TS;
    const sf = ts.createSourceFile(absPath, text, ts.ScriptTarget.Latest, true, scriptKind);
    const records = [];
    const seenPositions = new Set();

    function visit(node, fnStack) {
        let nextStack = fnStack;
        if (
            ts.isFunctionDeclaration(node) ||
            ts.isMethodDeclaration(node) ||
            ts.isFunctionExpression(node) ||
            ts.isArrowFunction(node) ||
            ts.isGetAccessorDeclaration(node) ||
            ts.isSetAccessorDeclaration(node)
        ) {
            const fnName =
                node.name && ts.isIdentifier(node.name)
                    ? node.name.text
                    : ts.isVariableDeclaration(node.parent) && ts.isIdentifier(node.parent.name)
                        ? node.parent.name.text
                        : '<anon>';
            nextStack = [...fnStack, fnName];
        } else if (ts.isClassDeclaration(node) && node.name) {
            nextStack = [...fnStack, node.name.text];
        }

        const isCandidateExpr =
            ts.isNumericLiteral(node) ||
            isArithmeticBinaryNode(node) ||
            (ts.isPrefixUnaryExpression(node) &&
                (node.operator === ts.SyntaxKind.MinusToken || node.operator === ts.SyntaxKind.PlusToken));

        if (isCandidateExpr) {
            const hit = extractHitFromNode(node, sf, fnStack, relFile);
            if (hit) {
                const dedupKey = `${hit.line}:${hit.name}`;
                if (!seenPositions.has(dedupKey)) {
                    seenPositions.add(dedupKey);
                    const explicitTag = readExplicitCommentTag(lines, hit.line - 1);
                    const { label, disposition } = ClassifyLimitHit(relFile, hit, explicitTag);
                    records.push({
                        file: relFile,
                        line: hit.line,
                        name: hit.name,
                        value: hit.value,
                        enclosingFunction: hit.enclosingFunction,
                        label,
                        disposition,
                    });
                }
                if (ts.isBinaryExpression(node)) {
                    return;
                }
            }
        }

        ts.forEachChild(node, (child) => visit(child, nextStack));
    }

    visit(sf, []);
    return records;
}

/**
 * Runs the deterministic mechanical numeric literal sweep across `roots` under `repoRoot`.
 */
export function SweepLimitsLiterals(options = {}) {
    const repoRoot = options.repoRoot ?? DEFAULT_REPO_ROOT;
    const roots = options.roots && options.roots.length > 0 ? options.roots : ['packages'];
    const files = [];
    for (const root of roots) {
        const absRoot = resolve(repoRoot, root);
        walkSourceFiles(absRoot, files);
    }
    const records = [];
    for (const absFile of files) {
        records.push(...scanSingleFile(absFile, repoRoot));
    }
    records.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line || a.name.localeCompare(b.name));
    return {
        filesScanned: files.length,
        records,
    };
}

/**
 * Returns unapproved `RunawayGuard` violations outside `packages/Core/src/config/TasksLimits.ts`.
 */
export function FindUnapprovedRunawayGuards(records) {
    return records.filter(
        (r) =>
            r.label === 'RunawayGuard' &&
            r.file !== CANONICAL_LIMITS_CONFIG_REL &&
            r.disposition !== 'retained-integration-test-harness',
    );
}

function escapeCsvField(value) {
    const str = String(value ?? '');
    if (str.includes(',') || str.includes('"') || str.includes('\n')) {
        return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
}

/**
 * Formats swept inventory records as deterministic RFC-4180 CSV with columns:
 * `file,line,name,value,enclosingFunction,label,disposition`.
 */
export function FormatInventoryCsv(records) {
    const rows = [CSV_HEADER];
    for (const r of records) {
        rows.push(
            [
                escapeCsvField(r.file),
                escapeCsvField(r.line),
                escapeCsvField(r.name),
                escapeCsvField(r.value),
                escapeCsvField(r.enclosingFunction),
                escapeCsvField(r.label),
                escapeCsvField(r.disposition),
            ].join(','),
        );
    }
    return `${rows.join('\n')}\n`;
}

function parseCliArgs(argv) {
    const opts = {
        repoRoot: DEFAULT_REPO_ROOT,
        roots: [],
        outPaths: [],
        checkRunaway: false,
        json: false,
    };
    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === '--root' && argv[i + 1]) {
            opts.roots.push(argv[++i]);
        } else if (arg === '--repo-root' && argv[i + 1]) {
            opts.repoRoot = resolve(argv[++i]);
        } else if ((arg === '--out' || arg === '--also') && argv[i + 1]) {
            opts.outPaths.push(argv[++i]);
        } else if (arg === '--check-runaway') {
            opts.checkRunaway = true;
        } else if (arg === '--json') {
            opts.json = true;
        }
    }
    if (opts.roots.length === 0) {
        opts.roots.push('packages');
    }
    return opts;
}

function main() {
    const opts = parseCliArgs(process.argv.slice(2));
    const { filesScanned, records } = SweepLimitsLiterals({
        repoRoot: opts.repoRoot,
        roots: opts.roots,
    });

    const csv = FormatInventoryCsv(records);
    for (const outPath of opts.outPaths) {
        const absOut = resolve(opts.repoRoot, outPath);
        mkdirSync(dirname(absOut), { recursive: true });
        writeFileSync(absOut, csv, 'utf8');
        if (!opts.json) {
            console.log(`Wrote ${records.length} classified rows across ${filesScanned} files to ${outPath}`);
        }
    }

    const unapproved = FindUnapprovedRunawayGuards(records);
    if (opts.json) {
        console.log(
            JSON.stringify(
                {
                    filesScanned,
                    totalHits: records.length,
                    unapprovedRunawayGuards: unapproved,
                },
                null,
                2,
            ),
        );
    } else if (opts.outPaths.length === 0 && !opts.checkRunaway) {
        process.stdout.write(csv);
    }

    if (opts.checkRunaway) {
        if (unapproved.length > 0) {
            console.error(`✗ ${unapproved.length} unapproved RunawayGuard literal(s) found outside ${CANONICAL_LIMITS_CONFIG_REL}:`);
            for (const v of unapproved) {
                console.error(`  ${v.file}:${v.line}  ${v.name} = ${v.value} (${v.enclosingFunction}) -> ${v.disposition}`);
            }
            process.exit(1);
        }
        console.log(`✓ 0 unapproved RunawayGuard literals outside ${CANONICAL_LIMITS_CONFIG_REL} (${filesScanned} files scanned, ${records.length} literals).`);
    }
}

const isEntrypoint = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isEntrypoint) {
    main();
}
