#!/usr/bin/env node
/**
 * Automated documentation & HTML sidebar anchor verification guard.
 *
 * Scans all Markdown and HTML files under guides/**, docs/**, and README.md,
 * extracts all internal anchor links (including #tasks-* sidebar links and
 * cross-file relative links with #fragments), and verifies every link resolves
 * to a valid GitHub Markdown heading slug or explicit HTML id/name anchor.
 *
 * Zero external dependencies (strict ESM Node.js).
 *
 * Usage:
 *   node scripts/verify-doc-anchors.mjs
 *   node scripts/verify-doc-anchors.mjs --root /path/to/repo
 *   node scripts/verify-doc-anchors.mjs --json
 */

import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const DEFAULT_REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const SCAN_ROOTS = ['guides', 'docs', 'README.md'];
const SKIP_DIRS = new Set(['node_modules', 'dist', 'build', 'coverage', '.turbo', '.git']);
const DOC_EXTENSIONS = new Set(['.md', '.mdx', '.html', '.htm']);

/**
 * Generates a GitHub-compatible heading anchor slug from a Markdown heading title.
 */
export function SlugifyMarkdownHeading(rawTitle) {
    const plain = rawTitle
        .replace(/!\[([^\]]*)\]\([^)]*\)/g, '$1')
        .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
        .replace(/<[^>]+>/g, '')
        .replace(/[`*_~]/g, '')
        .trim()
        .toLowerCase();

    return plain
        .replace(/[^\p{L}\p{N}\s_-]/gu, '')
        .replace(/\s/g, '-');
}

function collectDocFiles(repoRoot) {
    const out = [];

    function walk(absPath) {
        if (!existsSync(absPath)) return;
        const st = statSync(absPath);
        if (st.isFile()) {
            if (DOC_EXTENSIONS.has(extname(absPath).toLowerCase())) {
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

function collectMarkdownAnchors(sourceText) {
    const anchors = new Set();
    const slugCounts = new Map();
    const lines = sourceText.split(/\r?\n/);
    let inFence = false;
    let fenceChar = '';

    for (const line of lines) {
        const fenceMatch = line.match(/^\s*(```+|~~~+)/);
        if (fenceMatch) {
            const marker = fenceMatch[1][0];
            if (!inFence) {
                inFence = true;
                fenceChar = marker;
            } else if (marker === fenceChar) {
                inFence = false;
                fenceChar = '';
            }
            continue;
        }
        if (inFence) continue;

        const headingMatch = line.match(/^#{1,6}\s+(.+?)\s*#*\s*$/);
        if (headingMatch) {
            const baseSlug = SlugifyMarkdownHeading(headingMatch[1]);
            if (baseSlug) {
                const count = slugCounts.get(baseSlug) ?? 0;
                slugCounts.set(baseSlug, count + 1);
                anchors.add(count === 0 ? baseSlug : `${baseSlug}-${count}`);
            }
        }

        for (const m of line.matchAll(/<a\b[^>]*\b(?:id|name)\s*=\s*["']([^"']+)["']/gi)) {
            anchors.add(m[1]);
        }
        for (const m of line.matchAll(/\bid\s*=\s*["']([^"']+)["']/gi)) {
            anchors.add(m[1]);
        }
    }

    return anchors;
}

function collectHtmlAnchors(sourceText) {
    const anchors = new Set();
    const cleaned = sourceText.replace(/data:[a-zA-Z0-9/+.-]+;base64,[A-Za-z0-9+/=]+/g, 'data:base64');

    for (const m of cleaned.matchAll(/\bid\s*=\s*["']([^"']+)["']/gi)) {
        anchors.add(m[1]);
    }
    for (const m of cleaned.matchAll(/<a\b[^>]*\bname\s*=\s*["']([^"']+)["']/gi)) {
        anchors.add(m[1]);
    }

    return anchors;
}

function stripInlineCode(line) {
    return line.replace(/`[^`]*`/g, '');
}

function extractInternalAnchorLinks(sourceText, absFile) {
    const ext = extname(absFile).toLowerCase();
    const isHtml = ext === '.html' || ext === '.htm';
    const links = [];
    const lines = sourceText.split(/\r?\n/);

    let inFence = false;
    let fenceChar = '';
    let inStyleOrScript = false;

    for (let i = 0; i < lines.length; i++) {
        const lineNum = i + 1;
        let line = lines[i].replace(/data:[a-zA-Z0-9/+.-]+;base64,[A-Za-z0-9+/=]+/g, 'data:base64');

        if (!isHtml) {
            const fenceMatch = line.match(/^\s*(```+|~~~+)/);
            if (fenceMatch) {
                const marker = fenceMatch[1][0];
                if (!inFence) {
                    inFence = true;
                    fenceChar = marker;
                } else if (marker === fenceChar) {
                    inFence = false;
                    fenceChar = '';
                }
                continue;
            }
            if (inFence) continue;

            const unscoped = stripInlineCode(line);
            // Markdown [label](url#fragment)
            for (const m of unscoped.matchAll(/!?\[[^\]]*\]\(([^)\s]+)\)/g)) {
                const target = m[1];
                if (target.includes('#')) {
                    links.push({ line: lineNum, href: target });
                }
            }
            // Inline HTML <a href="..."> in Markdown
            for (const m of unscoped.matchAll(/<a\b[^>]*\bhref\s*=\s*["']([^"']+)["']/gi)) {
                const target = m[1];
                if (target.includes('#')) {
                    links.push({ line: lineNum, href: target });
                }
            }
        } else {
            if (/<(?:style|script)\b/i.test(line)) {
                inStyleOrScript = true;
            }
            if (!inStyleOrScript) {
                for (const m of line.matchAll(/<a\b[^>]*\bhref\s*=\s*["']([^"']+)["']/gi)) {
                    const target = m[1];
                    if (target.includes('#')) {
                        links.push({ line: lineNum, href: target });
                    }
                }
            }
            if (/<\/(?:style|script)>/i.test(line)) {
                inStyleOrScript = false;
            }
        }
    }

    return links;
}

function getAnchorsForFile(absFile, cache) {
    if (cache.has(absFile)) return cache.get(absFile);
    const text = readFileSync(absFile, 'utf8');
    const ext = extname(absFile).toLowerCase();
    const anchors =
        ext === '.html' || ext === '.htm'
            ? collectHtmlAnchors(text)
            : collectMarkdownAnchors(text);
    cache.set(absFile, anchors);
    return anchors;
}

/**
 * Verifies all internal #anchor links across README.md, guides/**, and docs/**.
 */
export function VerifyDocAnchors(options = {}) {
    const repoRoot = resolve(options.repoRoot ?? DEFAULT_REPO_ROOT);
    const files = collectDocFiles(repoRoot);
    const anchorCache = new Map();
    const brokenLinks = [];
    let linksChecked = 0;

    for (const absFile of files) {
        const relFile = relative(repoRoot, absFile).split('\\').join('/');
        const text = readFileSync(absFile, 'utf8');
        const links = extractInternalAnchorLinks(text, absFile);

        for (const link of links) {
            const href = link.href.trim();
            if (/^(?:https?:|mailto:|tel:|javascript:)/i.test(href)) continue;

            const hashIdx = href.indexOf('#');
            const targetFilePart = href.slice(0, hashIdx);
            const rawFragment = href.slice(hashIdx + 1);
            if (!rawFragment) continue;

            let fragment;
            try {
                fragment = decodeURIComponent(rawFragment);
            } catch {
                fragment = rawFragment;
            }

            linksChecked++;

            const targetAbs = targetFilePart
                ? resolve(dirname(absFile), targetFilePart)
                : absFile;

            if (!existsSync(targetAbs) || !statSync(targetAbs).isFile()) {
                brokenLinks.push({
                    file: relFile,
                    line: link.line,
                    href,
                    reason: `Target file '${targetFilePart}' does not exist`,
                });
                continue;
            }

            const targetAnchors = getAnchorsForFile(targetAbs, anchorCache);
            if (!targetAnchors.has(fragment) && !targetAnchors.has(fragment.toLowerCase())) {
                const targetRel = relative(repoRoot, targetAbs).split('\\').join('/');
                brokenLinks.push({
                    file: relFile,
                    line: link.line,
                    href,
                    reason: `Anchor '#${fragment}' not found in ${targetRel}`,
                });
            }
        }
    }

    return {
        ok: brokenLinks.length === 0,
        repoRoot,
        filesScanned: files.length,
        linksChecked,
        brokenLinks,
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

    const result = VerifyDocAnchors({ repoRoot });
    if (json) {
        console.log(JSON.stringify(result, null, 2));
    } else if (!result.ok) {
        console.error(`✗ verify-doc-anchors failed with ${result.brokenLinks.length} broken anchor link(s):`);
        for (const b of result.brokenLinks) {
            console.error(`  ${b.file}:${b.line}  [${b.href}] ${b.reason}`);
        }
    } else {
        console.log(
            `✓ verify-doc-anchors passed (${result.filesScanned} doc/HTML files scanned, ${result.linksChecked} internal anchor link(s) verified, 0 broken).`,
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
