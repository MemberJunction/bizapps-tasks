#!/usr/bin/env node
/**
 * Automated trademark & WCAG 2.1 AA citation guard for MemberJunction/bizapps-tasks.
 *
 * Scans packages/**, metadata/**, guides/**, docs/**, .mj/specs/**, and README.md
 * for prohibited third-party product/methodology terms and misattributed WCAG 2.4.11
 * citations under WCAG 2.1 AA conformance claims.
 *
 * Zero external dependencies (strict ESM Node.js).
 *
 * Usage:
 *   node scripts/verify-trademarks.mjs
 *   node scripts/verify-trademarks.mjs --root /path/to/repo
 *   node scripts/verify-trademarks.mjs --json
 */

import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const DEFAULT_REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

const SCAN_ROOTS = [
    'packages',
    'metadata',
    'guides',
    'docs',
    '.mj/specs',
    'README.md',
];

const SKIP_DIRS = new Set([
    'node_modules',
    'dist',
    'build',
    'coverage',
    '.turbo',
    '.git',
    '.backups',
]);

const TEXT_EXTENSIONS = new Set([
    '.ts',
    '.tsx',
    '.js',
    '.jsx',
    '.mjs',
    '.cjs',
    '.json',
    '.md',
    '.mdx',
    '.html',
    '.htm',
    '.css',
    '.scss',
    '.txt',
    '.yml',
    '.yaml',
    '.svg',
]);

// Official MemberJunction Core entity/metadata identifiers that legitimately include
// the word "Rhythm" (persisted __mj core entity name, never a third-party methodology claim).
const ALLOWLIST_PATTERNS = [
    /\bMJ:\s*AI Agent Rhythm Templates\b/g,
    /\bRhythm Templates?\b/g,
    /\brhythm-templates\b/g,
];

// Banned trademark rules constructed with word-boundary and case-sensitivity precision
// so code identifiers such as `taskIds`, `userIds`, or `IDs` do not false-positive.
const TRADEMARK_RULES = [
    {
        id: 'trademark-asana-grade',
        label: 'Asana-Grade',
        regex: /\bAsana-Grade\b/gi,
    },
    {
        id: 'trademark-asana',
        label: 'Asana',
        regex: /\bAsana\b/gi,
    },
    {
        id: 'trademark-smart-board',
        label: 'Smart Board',
        regex: /\bSmart\s+Board\b/gi,
    },
    {
        id: 'trademark-15five',
        label: '15Five',
        regex: /\b15Five\b/gi,
    },
    {
        id: 'trademark-retina',
        label: 'Retina',
        regex: /\bRetina\b/gi,
    },
    {
        id: 'trademark-eos',
        label: 'EOS',
        regex: /\bEOS\b/g,
    },
    {
        id: 'trademark-l10',
        label: 'L10',
        regex: /\bL10\b/g,
    },
    {
        id: 'trademark-ids',
        label: 'IDS',
        regex: /\bIDS\b/g,
    },
    {
        id: 'trademark-opsp',
        label: 'OPSP',
        regex: /\bOPSP\b/gi,
    },
    {
        id: 'trademark-rhythm',
        label: 'Rhythm',
        regex: /\bRhythm\b/g,
    },
];

const DATA_URI_BASE64_RE = /data:[a-zA-Z0-9/+.-]+;base64,[A-Za-z0-9+/=]+/g;
const WCAG_2411_RE = /\b2\.4\.11\b/g;
const WCAG_21_DOC_RE = /\bWCAG\s*2\.1\b/i;
const WCAG_22_LINE_RE = /\bWCAG\s*2\.2\b/i;

function collectTargetFiles(repoRoot) {
    const out = [];

    function walk(absPath) {
        if (!existsSync(absPath)) return;
        const st = statSync(absPath);
        if (st.isFile()) {
            const ext = extname(absPath).toLowerCase();
            if (TEXT_EXTENSIONS.has(ext) || absPath.endsWith('README.md')) {
                out.push(absPath);
            }
            return;
        }
        if (!st.isDirectory()) return;

        const entries = readdirSync(absPath, { withFileTypes: true }).sort((a, b) =>
            a.name.localeCompare(b.name),
        );
        for (const entry of entries) {
            if (SKIP_DIRS.has(entry.name)) continue;
            walk(join(absPath, entry.name));
        }
    }

    for (const relRoot of SCAN_ROOTS) {
        walk(join(repoRoot, relRoot));
    }

    return out;
}

function maskAllowlistedTerms(line) {
    let masked = line.replace(DATA_URI_BASE64_RE, 'data:base64,REDACTED');
    for (const re of ALLOWLIST_PATTERNS) {
        re.lastIndex = 0;
        masked = masked.replace(re, (match) => ' '.repeat(match.length));
    }
    return masked;
}

/**
 * Scans a single file's text for banned trademark terms and WCAG 2.4.11 under WCAG 2.1 AA claims.
 */
export function ScanTextForTrademarks(sourceText, relFile) {
    const normalizedFile = relFile.split('\\').join('/');
    const violations = [];
    const lines = sourceText.split(/\r?\n/);
    const fileMentionsWcag21 = WCAG_21_DOC_RE.test(sourceText);

    for (let i = 0; i < lines.length; i++) {
        const lineNum = i + 1;
        const rawLine = lines[i];
        const maskedLine = maskAllowlistedTerms(rawLine);

        for (const rule of TRADEMARK_RULES) {
            rule.regex.lastIndex = 0;
            let match;
            while ((match = rule.regex.exec(maskedLine)) !== null) {
                violations.push({
                    file: normalizedFile,
                    line: lineNum,
                    rule: rule.id,
                    term: match[0],
                    message: `Prohibited third-party trademark term '${match[0]}' (${rule.label}) found in ${normalizedFile}:${lineNum}`,
                });
            }
        }

        WCAG_2411_RE.lastIndex = 0;
        if (WCAG_2411_RE.test(maskedLine) && !WCAG_22_LINE_RE.test(rawLine)) {
            if (fileMentionsWcag21 || /\bWCAG\b/i.test(rawLine)) {
                violations.push({
                    file: normalizedFile,
                    line: lineNum,
                    rule: 'wcag-2-1-misattribution',
                    term: '2.4.11',
                    message: `WCAG 2.4.11 (a WCAG 2.2 criterion) misattributed under WCAG 2.1 AA claim in ${normalizedFile}:${lineNum}`,
                });
            }
        }
    }

    return violations;
}

/**
 * Runs the trademark & WCAG 2.1 AA citation check across the target repository root.
 */
export function VerifyTrademarks(options = {}) {
    const repoRoot = resolve(options.repoRoot ?? DEFAULT_REPO_ROOT);
    const files = collectTargetFiles(repoRoot);
    const violations = [];

    for (const absFile of files) {
        const relFile = relative(repoRoot, absFile).split('\\').join('/');
        const text = readFileSync(absFile, 'utf8');
        violations.push(...ScanTextForTrademarks(text, relFile));
    }

    return {
        ok: violations.length === 0,
        repoRoot,
        filesScanned: files.length,
        violations,
    };
}

function main() {
    const argv = process.argv.slice(2);
    let repoRoot = DEFAULT_REPO_ROOT;
    let json = false;

    for (let i = 0; i < argv.length; i++) {
        if (argv[i] === '--root' && argv[i + 1]) {
            repoRoot = resolve(argv[++i]);
        } else if (argv[i] === '--json') {
            json = true;
        }
    }

    const result = VerifyTrademarks({ repoRoot });
    if (json) {
        console.log(JSON.stringify(result, null, 2));
    } else if (!result.ok) {
        console.error(`✗ verify-trademarks failed with ${result.violations.length} hit(s):`);
        for (const v of result.violations) {
            console.error(`  ${v.file}:${v.line}  [${v.rule}] ${v.message}`);
        }
    } else {
        console.log(
            `✓ verify-trademarks passed (${result.filesScanned} files scanned across packages, metadata, guides, docs, .mj/specs, README.md; 0 trademark or WCAG 2.4.11 violations).`,
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
