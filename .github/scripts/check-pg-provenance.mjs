#!/usr/bin/env node
/**
 * PostgreSQL counterpart & deterministic split-bake provenance guard for BizApps Tasks.
 *
 * Enforces on every newly added T-SQL migration (`migrations/*.sql`) between <base-ref> and <head-ref>:
 *   1. A paired PostgreSQL migration exists at `migrations-pg/<stem>.pg.sql`.
 *   2. Line 1 of the `.pg.sql` file carries the deterministic provenance stamp emitted by
 *      `mj migrate convert --split --bake-codegen`:
 *        -- @mj-pg-provenance: split-bake v1 source=<stem>.sql source-sha256=<64hex> mode=<baked|needs-hand-rebaked>
 *   3. The `source-sha256` matches the actual SHA-256 digest of `migrations/<stem>.sql`.
 *
 * Usage:
 *   node .github/scripts/check-pg-provenance.mjs <base-ref> <head-ref>
 *   node .github/scripts/check-pg-provenance.mjs --self-test
 */
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const PG_PROVENANCE_LINE_RE =
    /^-- @mj-pg-provenance: split-bake v1 source=([^\s]+) source-sha256=([0-9a-f]{64}) mode=(baked|needs-hand-rebaked)\r?$/;

export function Sha256File(absPath) {
    return createHash('sha256').update(readFileSync(absPath)).digest('hex');
}

/**
 * Validates that a single T-SQL migration has a paired `.pg.sql` file with a matching
 * line-1 `-- @mj-pg-provenance: split-bake v1 ...` header and SHA-256 digest.
 */
export function CheckMigrationPair(repoRoot, tsqlRelPath) {
    const fileName = basename(tsqlRelPath);
    const stem = fileName.replace(/\.sql$/i, '');
    const pgRelPath = `migrations-pg/${stem}.pg.sql`;
    const tsqlAbs = join(repoRoot, tsqlRelPath);
    const pgAbs = join(repoRoot, pgRelPath);

    if (!existsSync(tsqlAbs)) {
        return { ok: false, tsqlRelPath, pgRelPath, reason: `T-SQL migration '${tsqlRelPath}' does not exist on disk.` };
    }
    if (!existsSync(pgAbs)) {
        return {
            ok: false,
            tsqlRelPath,
            pgRelPath,
            reason: `Missing PostgreSQL counterpart '${pgRelPath}'. Generate it via \`mj migrate convert --split --bake-codegen\`.`,
        };
    }

    const pgContent = readFileSync(pgAbs, 'utf8');
    const firstLine = pgContent.split('\n')[0] ?? '';
    const match = PG_PROVENANCE_LINE_RE.exec(firstLine);
    if (!match) {
        return {
            ok: false,
            tsqlRelPath,
            pgRelPath,
            reason:
                `Line 1 of '${pgRelPath}' must carry deterministic split-bake provenance: ` +
                `'-- @mj-pg-provenance: split-bake v1 source=${fileName} source-sha256=<64hex> mode=<baked|needs-hand-rebaked>'.`,
        };
    }

    const [, declaredSource, declaredSha, mode] = match;
    if (declaredSource !== fileName) {
        return {
            ok: false,
            tsqlRelPath,
            pgRelPath,
            reason: `Provenance source mismatch in '${pgRelPath}': expected '${fileName}', found '${declaredSource}'.`,
        };
    }

    const actualSha = Sha256File(tsqlAbs);
    if (declaredSha !== actualSha) {
        return {
            ok: false,
            tsqlRelPath,
            pgRelPath,
            reason:
                `Provenance source-sha256 mismatch in '${pgRelPath}': declared ${declaredSha} != actual ${actualSha}. ` +
                `Re-run split-bake conversion after editing '${tsqlRelPath}'.`,
        };
    }

    return { ok: true, tsqlRelPath, pgRelPath, mode, sha256: actualSha };
}

/**
 * Inspects all newly added `migrations/*.sql` files between `baseRef` and `headRef`.
 */
export function CheckRepoPgProvenance(repoRoot, baseRef, headRef) {
    const out = execFileSync(
        'git',
        ['diff', '--name-only', '--diff-filter=A', baseRef, headRef, '--', 'migrations/*.sql'],
        { cwd: repoRoot, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] },
    );
    const added = out
        .split(/\r?\n/)
        .map((s) => s.trim())
        .filter((s) => s.length > 0 && s.endsWith('.sql'));

    if (added.length === 0) {
        return { ok: true, checked: [], failures: [] };
    }

    const checked = added.map((rel) => CheckMigrationPair(repoRoot, rel));
    const failures = checked.filter((r) => !r.ok);
    return { ok: failures.length === 0, checked, failures };
}

function selfTest() {
    const dir = mkdtempSync(join(tmpdir(), 'pg-prov-self-'));
    try {
        mkdirSync(join(dir, 'migrations'), { recursive: true });
        mkdirSync(join(dir, 'migrations-pg'), { recursive: true });

        const migName = 'V202611261400__v1.16.x__Sample.sql';
        const tsqlPath = join(dir, 'migrations', migName);
        const pgPath = join(dir, 'migrations-pg', 'V202611261400__v1.16.x__Sample.pg.sql');
        writeFileSync(tsqlPath, 'SELECT 1;\n', 'utf8');
        const sha = Sha256File(tsqlPath);

        // 1. Missing PG counterpart fails
        const missing = CheckMigrationPair(dir, `migrations/${migName}`);
        if (missing.ok) throw new Error('Expected missing counterpart to fail');

        // 2. Missing provenance header fails
        writeFileSync(pgPath, 'SELECT 1;\n', 'utf8');
        const noHeader = CheckMigrationPair(dir, `migrations/${migName}`);
        if (noHeader.ok) throw new Error('Expected missing provenance header to fail');

        // 3. Mismatched SHA fails
        writeFileSync(
            pgPath,
            `-- @mj-pg-provenance: split-bake v1 source=${migName} source-sha256=${'0'.repeat(64)} mode=baked\nSELECT 1;\n`,
            'utf8',
        );
        const badSha = CheckMigrationPair(dir, `migrations/${migName}`);
        if (badSha.ok) throw new Error('Expected mismatched SHA to fail');

        // 4. Valid baked header passes
        writeFileSync(
            pgPath,
            `-- @mj-pg-provenance: split-bake v1 source=${migName} source-sha256=${sha} mode=baked\nSELECT 1;\n`,
            'utf8',
        );
        const okBaked = CheckMigrationPair(dir, `migrations/${migName}`);
        if (!okBaked.ok) throw new Error(`Expected valid baked header to pass: ${okBaked.reason}`);

        // 5. Valid needs-hand-rebaked header passes
        writeFileSync(
            pgPath,
            `-- @mj-pg-provenance: split-bake v1 source=${migName} source-sha256=${sha} mode=needs-hand-rebaked\nSELECT 1;\n`,
            'utf8',
        );
        const okRebaked = CheckMigrationPair(dir, `migrations/${migName}`);
        if (!okRebaked.ok) throw new Error(`Expected valid needs-hand-rebaked header to pass: ${okRebaked.reason}`);

        console.log('✓ check-pg-provenance self-test passed (5 fixtures).');
        return 0;
    } finally {
        rmSync(dir, { recursive: true, force: true });
    }
}

function isDirectlyExecuted() {
    if (!process.argv[1]) return false;
    try {
        return realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url));
    } catch {
        return false;
    }
}

if (isDirectlyExecuted()) {
    const args = process.argv.slice(2);
    if (args[0] === '--self-test') {
        process.exit(selfTest());
    }
    const baseRef = args[0];
    const headRef = args[1] ?? 'HEAD';
    if (!baseRef) {
        console.error('Usage: node .github/scripts/check-pg-provenance.mjs <base-ref> <head-ref> | --self-test');
        process.exit(2);
    }

    const result = CheckRepoPgProvenance(process.cwd(), baseRef, headRef);
    if (result.checked.length === 0) {
        console.log(`No new T-SQL migrations added between ${baseRef} and ${headRef}.`);
        process.exit(0);
    }
    for (const item of result.checked) {
        if (item.ok) {
            console.log(`  ok       ${item.tsqlRelPath} -> ${item.pgRelPath} (mode=${item.mode})`);
        } else {
            console.error(`::error::${item.reason}`);
        }
    }
    if (!result.ok) {
        process.exit(1);
    }
    console.log(`✓ PG counterpart & split-bake provenance verified (${result.checked.length} migration(s)).`);
}
