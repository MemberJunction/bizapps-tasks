#!/usr/bin/env node
/**
 * Static repository standards & limits guard for MemberJunction/bizapps-tasks.
 *
 * Enforces:
 *   1. Zero unapproved RunawayGuard or unrouted ResourceGuard/Tuning literals in backend packages,
 *      plus exact deterministic parity between `scripts/sweep-limits.mjs` and the committed
 *      inventory CSVs (`scripts/limits-sweep-classified.csv`, `.mj/specs/limits-sweep-bizapps-tasks.csv`).
 *   2. Zero `any` type annotations/casts (`no-any`).
 *   3. Zero lazy `unknown` casts (`as unknown as Record<...>`, standalone `as unknown`, and in
 *      strict files any `: unknown` outside `catch` clauses).
 *   4. Zero `BaseEntity.Get()` / `BaseEntity.Set()` calls (`no-base-entity-get-set`).
 *
 * Usage:
 *   node scripts/check-standards.mjs
 *   node scripts/check-standards.mjs --json
 *   npm run check:standards
 */

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import ts from 'typescript';
import {
    CANONICAL_LIMITS_CONFIG_REL,
    FindUnapprovedRunawayGuards,
    FindUnroutedBackendLimits,
    FormatInventoryCsv,
    SweepLimitsLiterals,
} from './sweep-limits.mjs';

const DEFAULT_REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

const BACKEND_PACKAGE_ROOTS = [
    'packages/Core/src',
    'packages/Actions/src',
    'packages/Entities/src',
    'packages/EntitiesServer/src',
    'packages/Server/src',
];

const SKIP_DIRS = new Set([
    'node_modules',
    'dist',
    'build',
    'coverage',
    '__tests__',
    '__mocks__',
    'generated',
    '.turbo',
    '.git',
]);

const SKIP_FILE_RE = /\.(?:test|spec|d)\.(?:ts|tsx|mts|cts)$/;
const STRICT_UNKNOWN_PATH_RE = /^packages\/Core\/src\/config\//;
const LEGACY_NOMINAL_BRIDGE_TARGET_RE = /^(?:IMetadataProvider|IRunViewProvider|Parameters<typeof RunInEntityTransaction>\[0\]|GraphQLExecutableProvider|RRuleModule|\{\s*default:\s*RRuleModule\s*\}|AgendaNode\[\]|AgendaItemRow\[\]|AttendeeLookupRow\[\]|\{\s*LinkedEntityID\?: unknown;\s*LinkedEntityRecordID\?: unknown\s*\})$/;
const LEGACY_JSON_ERROR_PARSER_FILES = new Set([
    'packages/Core/src/meetings/proposed-tasks.ts',
    'packages/Core/src/meetings/agenda-template.ts',
    'packages/Core/src/meetings/ai-prompt-execution.ts',
    'packages/Core/src/meetings/person-user.ts',
    'packages/Core/src/services/TaskTemplateService.ts',
    'packages/EntitiesServer/src/video/ZoomVideoProvider.ts',
    'packages/EntitiesServer/src/meeting-caller.ts',
    'packages/EntitiesServer/src/ai/meeting-ai-runtime.ts',
    'packages/Server/src/scheduled-jobs/MeetingSeriesMaterializationJob.ts',
    'packages/Server/src/workflow/workflow-task-request.ts',
    'packages/Server/src/notifications/sendTaskNotifications.ts',
    'packages/Server/src/event-handlers/TaskNotificationHandler.ts',
]);

function walkTsFiles(dir, out = []) {
    if (!existsSync(dir)) return out;
    const entries = readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
    for (const entry of entries) {
        if (SKIP_DIRS.has(entry.name)) continue;
        const full = join(dir, entry.name);
        if (entry.isDirectory()) {
            walkTsFiles(full, out);
        } else if (entry.isFile() && ['.ts', '.mts', '.cts'].includes(extname(entry.name)) && !SKIP_FILE_RE.test(entry.name)) {
            out.push(full);
        }
    }
    return out;
}

function lineNumberAt(sf, pos) {
    return sf.getLineAndCharacterOfPosition(pos).line + 1;
}

function isInsideCatchClause(node) {
    for (let cur = node.parent; cur; cur = cur.parent) {
        if (ts.isCatchClause(cur)) {
            return true;
        }
        if (
            ts.isArrowFunction(cur) ||
            ts.isFunctionExpression(cur)
        ) {
            const call = cur.parent;
            if (
                call &&
                ts.isCallExpression(call) &&
                ts.isPropertyAccessExpression(call.expression) &&
                call.expression.name.text === 'catch'
            ) {
                return true;
            }
            return false;
        }
        if (ts.isFunctionLike(cur) || ts.isBlock(cur)) {
            return false;
        }
    }
    return false;
}

/**
 * Checks a single TypeScript source string for `any`, lazy `unknown` casts/annotations,
 * and `BaseEntity.Get()` / `BaseEntity.Set()` calls.
 */
export function CheckSourceTextStandards(sourceText, relFile, options = {}) {
    const normalizedFile = relFile.split('\\').join('/');
    const strictUnknown = options.strictUnknown ?? STRICT_UNKNOWN_PATH_RE.test(normalizedFile);
    const sf = ts.createSourceFile(normalizedFile, sourceText, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
    const violations = [];

    function pushViolation(pos, rule, message) {
        violations.push({
            file: normalizedFile,
            line: lineNumberAt(sf, pos),
            rule,
            message,
        });
    }

    function visit(node) {
        if (node.kind === ts.SyntaxKind.AnyKeyword) {
            pushViolation(
                node.getStart(sf),
                'no-any',
                `Forbidden 'any' type detected in ${normalizedFile}. Define an explicit interface or entity-derived type instead.`,
            );
        } else if (node.kind === ts.SyntaxKind.UnknownKeyword) {
            const p = node.parent;
            const inCatch = isInsideCatchClause(node);
            const isCastExpr = p && (ts.isAsExpression(p) || ts.isTypeAssertionExpression(p)) && p.type === node;

            if (isCastExpr) {
                const outer = p.parent;
                const isDoubleBridge =
                    outer && (ts.isAsExpression(outer) || ts.isTypeAssertionExpression(outer)) && outer.expression === p;
                const outerTargetText = isDoubleBridge ? outer.type.getText(sf).trim() : '';

                if (isDoubleBridge && /^Record\s*</.test(outerTargetText)) {
                    pushViolation(
                        p.getStart(sf),
                        'no-unknown-record-cast',
                        `Forbidden 'as unknown as ${outerTargetText}' cast in ${normalizedFile}.`,
                    );
                } else if (strictUnknown || !(isDoubleBridge && LEGACY_NOMINAL_BRIDGE_TARGET_RE.test(outerTargetText)) && !LEGACY_JSON_ERROR_PARSER_FILES.has(normalizedFile)) {
                    pushViolation(
                        p.getStart(sf),
                        'no-lazy-unknown',
                        `Forbidden lazy 'as unknown' cast in ${normalizedFile}.`,
                    );
                }
            } else if (!inCatch && strictUnknown) {
                pushViolation(
                    node.getStart(sf),
                    'no-lazy-unknown',
                    `Forbidden non-catch 'unknown' type in ${normalizedFile}.`,
                );
            }
        } else if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression)) {
            const methodName = node.expression.name.text;
            if ((methodName === 'Get' || methodName === 'Set') && node.arguments.length >= 1) {
                const receiverText = node.expression.expression.getText(sf);
                const firstArg = node.arguments[0];
                const isEntityFieldStringCall = ts.isStringLiteralLike(firstArg);
                const isKnownNonEntityReceiver = /(?:Headers|SearchParams|URLSearchParams|reflect)$/i.test(receiverText);
                if (isEntityFieldStringCall && !isKnownNonEntityReceiver) {
                    pushViolation(
                        node.getStart(sf),
                        'no-base-entity-get-set',
                        `Forbidden BaseEntity.${methodName}(...) call in ${normalizedFile}. Use strongly-typed entity property accessors instead.`,
                    );
                }
            }
        }

        ts.forEachChild(node, visit);
    }

    visit(sf);
    return { violations };
}

/**
 * Runs all static standards checks across backend TypeScript packages and limits sweep parity.
 */
export function CheckStandards(options = {}) {
    const repoRoot = resolve(options.repoRoot ?? DEFAULT_REPO_ROOT);
    const violations = [];
    const scannedFiles = [];

    for (const relRoot of BACKEND_PACKAGE_ROOTS) {
        const absRoot = join(repoRoot, relRoot);
        walkTsFiles(absRoot, scannedFiles);
    }

    for (const absFile of scannedFiles) {
        const relFile = relative(repoRoot, absFile).split('\\').join('/');
        const text = readFileSync(absFile, 'utf8');
        const res = CheckSourceTextStandards(text, relFile, options);
        violations.push(...res.violations);
    }

    const sweep = SweepLimitsLiterals({ repoRoot, roots: ['packages'] });
    const unapprovedRunaway = FindUnapprovedRunawayGuards(sweep.records);
    for (const hit of unapprovedRunaway) {
        violations.push({
            file: hit.file,
            line: hit.line,
            rule: 'no-unapproved-runaway-guard',
            message: `Unapproved RunawayGuard literal '${hit.name} = ${hit.value}' in ${hit.enclosingFunction} -> route via TasksLimitsResolver`,
        });
    }

    const unroutedBackend = FindUnroutedBackendLimits(sweep.records);
    for (const hit of unroutedBackend) {
        violations.push({
            file: hit.file,
            line: hit.line,
            rule: 'no-unrouted-backend-limit',
            message: `Unrouted backend ${hit.label} literal '${hit.name} = ${hit.value}' (${hit.disposition}) -> route via TasksLimitsResolver`,
        });
    }

    const generatedCsv = FormatInventoryCsv(sweep.records);
    for (const csvRel of ['scripts/limits-sweep-classified.csv', '.mj/specs/limits-sweep-bizapps-tasks.csv']) {
        const csvAbs = join(repoRoot, csvRel);
        if (!existsSync(csvAbs)) {
            violations.push({
                file: csvRel,
                line: 1,
                rule: 'limits-csv-parity',
                message: `Missing required classified limits CSV: ${csvRel}`,
            });
            continue;
        }
        const committed = readFileSync(csvAbs, 'utf8');
        if (committed !== generatedCsv) {
            violations.push({
                file: csvRel,
                line: 1,
                rule: 'limits-csv-parity',
                message: `${csvRel} is out of date with scripts/sweep-limits.mjs. Run: node scripts/sweep-limits.mjs --out scripts/limits-sweep-classified.csv --also .mj/specs/limits-sweep-bizapps-tasks.csv`,
            });
        }
    }

    return {
        ok: violations.length === 0,
        filesScanned: scannedFiles.length,
        violations,
        sweepSummary: {
            filesScanned: sweep.filesScanned,
            totalHits: sweep.records.length,
            unapprovedRunawayCount: unapprovedRunaway.length,
            unroutedBackendCount: unroutedBackend.length,
            canonicalLimitsFile: CANONICAL_LIMITS_CONFIG_REL,
        },
    };
}

function main() {
    const argv = process.argv.slice(2);
    let repoRoot = DEFAULT_REPO_ROOT;
    let json = false;
    for (let i = 0; i < argv.length; i++) {
        if (argv[i] === '--repo-root' && argv[i + 1]) {
            repoRoot = resolve(argv[++i]);
        } else if (argv[i] === '--json') {
            json = true;
        }
    }

    const result = CheckStandards({ repoRoot });
    if (json) {
        console.log(JSON.stringify(result, null, 2));
    } else if (!result.ok) {
        console.error(`✗ check:standards failed with ${result.violations.length} violation(s):`);
        for (const v of result.violations) {
            console.error(`  ${v.file}:${v.line}  [${v.rule}] ${v.message}`);
        }
    } else {
        console.log(
            `✓ check:standards passed (${result.filesScanned} backend TypeScript files checked, ${result.sweepSummary.totalHits} swept limit entries, 0 unrouted backend limits, CSV parity verified).`,
        );
    }

    if (!result.ok) {
        process.exit(1);
    }
}

const isEntrypoint = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isEntrypoint) {
    main();
}
