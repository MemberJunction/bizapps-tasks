import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '../..');
const TRADEMARK_SCRIPT = join(REPO_ROOT, 'scripts/verify-trademarks.mjs');
const ANCHOR_SCRIPT = join(REPO_ROOT, 'scripts/verify-doc-anchors.mjs');

function runScript(scriptPath, rootDir) {
    return spawnSync(process.execPath, [scriptPath, '--root', rootDir], {
        cwd: REPO_ROOT,
        encoding: 'utf8',
    });
}

function makeTempFixture(populate) {
    const dir = mkdtempSync(join(tmpdir(), 'bizapps-tasks-guards-'));
    try {
        populate(dir);
    } catch (err) {
        rmSync(dir, { recursive: true, force: true });
        throw err;
    }
    return dir;
}

describe('scripts/verify-trademarks.mjs', () => {
    it('passes cleanly on the repository root (exit 0)', () => {
        const res = runScript(TRADEMARK_SCRIPT, REPO_ROOT);
        assert.equal(res.status, 0, `Expected exit 0, got ${res.status}:\n${res.stderr}\n${res.stdout}`);
        assert.match(res.stdout, /verify-trademarks passed/);
    });

    it('fails non-zero with file:line diagnostics on synthetic banned trademark hits', () => {
        const bannedPhraseA = ['Asana', 'Grade'].join('-');
        const bannedPhraseB = ['Smart', 'Board'].join(' ');
        const bannedPhraseC = ['15', 'Five'].join('');
        const bannedPhraseD = ['Re', 'tina'].join('');
        const bannedAcronym = ['E', 'O', 'S'].join('');

        const fixture = makeTempFixture((dir) => {
            mkdirSync(join(dir, 'packages/Core/src'), { recursive: true });
            mkdirSync(join(dir, 'guides'), { recursive: true });
            writeFileSync(
                join(dir, 'packages/Core/src/sample.ts'),
                `export const title = '${bannedPhraseA} ${bannedPhraseB}';\n`,
                'utf8',
            );
            writeFileSync(
                join(dir, 'guides/SAMPLE.md'),
                `# Sample\n\nUses ${bannedPhraseC}, ${bannedPhraseD}, and ${bannedAcronym}.\n`,
                'utf8',
            );
        });

        try {
            const res = runScript(TRADEMARK_SCRIPT, fixture);
            assert.notEqual(res.status, 0, 'Expected non-zero exit on trademark hits');
            assert.match(res.stderr, /packages\/Core\/src\/sample\.ts:1/);
            assert.match(res.stderr, /guides\/SAMPLE\.md:3/);
        } finally {
            rmSync(fixture, { recursive: true, force: true });
        }
    });

    it('does not false-positive on code identifiers like taskIds, userIds, IDs, or MJ: AI Agent Rhythm Templates', () => {
        const fixture = makeTempFixture((dir) => {
            mkdirSync(join(dir, 'packages/Core/src'), { recursive: true });
            mkdirSync(join(dir, 'metadata/rhythm-templates'), { recursive: true });
            writeFileSync(
                join(dir, 'packages/Core/src/identifiers.ts'),
                [
                    'export interface BulkInput { taskIds: string[]; userIds: string[]; }',
                    'export const label = "Valid IDs and videos grid";',
                    'export const entity = "MJ: AI Agent Rhythm Templates";',
                ].join('\n'),
                'utf8',
            );
            writeFileSync(
                join(dir, 'metadata/rhythm-templates/.mj-sync.json'),
                '{"entity": "MJ: AI Agent Rhythm Templates"}\n',
                'utf8',
            );
        });

        try {
            const res = runScript(TRADEMARK_SCRIPT, fixture);
            assert.equal(res.status, 0, `Unexpected failure on clean identifiers:\n${res.stderr}`);
        } finally {
            rmSync(fixture, { recursive: true, force: true });
        }
    });

    it('fails non-zero with file:line diagnostics on synthetic WCAG 2.4.11 under WCAG 2.1 AA claim', () => {
        const fixture = makeTempFixture((dir) => {
            mkdirSync(join(dir, 'guides'), { recursive: true });
            writeFileSync(
                join(dir, 'guides/ACCESSIBILITY.md'),
                [
                    '# Tasks UX (WCAG 2.1 AA)',
                    '',
                    'FAB-Free Drawers (WCAG 2.4.11 Focus Not Obscured).',
                ].join('\n'),
                'utf8',
            );
        });

        try {
            const res = runScript(TRADEMARK_SCRIPT, fixture);
            assert.notEqual(res.status, 0, 'Expected non-zero exit on WCAG 2.4.11 misattribution');
            assert.match(res.stderr, /guides\/ACCESSIBILITY\.md:3/);
            assert.match(res.stderr, /wcag-2-1-misattribution/);
        } finally {
            rmSync(fixture, { recursive: true, force: true });
        }
    });
});

describe('scripts/verify-doc-anchors.mjs', () => {
    it('passes cleanly on the repository root (exit 0)', () => {
        const res = runScript(ANCHOR_SCRIPT, REPO_ROOT);
        assert.equal(res.status, 0, `Expected exit 0, got ${res.status}:\n${res.stderr}\n${res.stdout}`);
        assert.match(res.stdout, /verify-doc-anchors passed/);
    });

    it('fails non-zero with file:line diagnostics on synthetic broken #tasks-* links in Markdown and HTML', () => {
        const fixture = makeTempFixture((dir) => {
            mkdirSync(join(dir, 'guides'), { recursive: true });
            mkdirSync(join(dir, 'docs'), { recursive: true });
            writeFileSync(
                join(dir, 'guides/SIDEBAR.md'),
                [
                    '# Tasks Workspace',
                    '',
                    '- [Valid Section](#tasks-workspace)',
                    '- [Broken Sidebar Link](#tasks-missing-section)',
                ].join('\n'),
                'utf8',
            );
            writeFileSync(
                join(dir, 'docs/GUIDE.html'),
                [
                    '<!doctype html><html><body>',
                    '<nav><a href="#tasks-overview">Overview</a><a href="#tasks-broken-anchor">Broken</a></nav>',
                    '<section id="tasks-overview"><h2>Overview</h2></section>',
                    '</body></html>',
                ].join('\n'),
                'utf8',
            );
        });

        try {
            const res = runScript(ANCHOR_SCRIPT, fixture);
            assert.notEqual(res.status, 0, 'Expected non-zero exit on broken #tasks-* links');
            assert.match(res.stderr, /guides\/SIDEBAR\.md:4/);
            assert.match(res.stderr, /#tasks-missing-section/);
            assert.match(res.stderr, /docs\/GUIDE\.html:2/);
            assert.match(res.stderr, /#tasks-broken-anchor/);
        } finally {
            rmSync(fixture, { recursive: true, force: true });
        }
    });
});
