import { test } from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Sha256File } from '../check-pg-provenance.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const SCRIPT = join(HERE, '..', 'check-pg-provenance.mjs');

function initRepo() {
    const dir = mkdtempSync(join(tmpdir(), 'pg-prov-spec-'));
    execFileSync('git', ['init', '-q'], { cwd: dir });
    execFileSync('git', ['config', 'user.email', 'test@test.com'], { cwd: dir });
    execFileSync('git', ['config', 'user.name', 'Test'], { cwd: dir });
    mkdirSync(join(dir, 'migrations'), { recursive: true });
    mkdirSync(join(dir, 'migrations-pg'), { recursive: true });
    writeFileSync(join(dir, 'README.md'), '# test\n', 'utf8');
    execFileSync('git', ['add', '.'], { cwd: dir });
    execFileSync('git', ['commit', '-q', '-m', 'base'], { cwd: dir });
    return dir;
}

test('check-pg-provenance --self-test passes', () => {
    const res = spawnSync(process.execPath, [SCRIPT, '--self-test'], { encoding: 'utf8' });
    assert.equal(res.status, 0, res.stderr || res.stdout);
    assert.match(res.stdout, /self-test passed/);
});

test('passes when a new migration carries a matching .pg.sql with valid split-bake v1 provenance', (t) => {
    const dir = initRepo();
    t.after(() => rmSync(dir, { recursive: true, force: true }));

    const name = 'V202611261400__v1.16.x__Valid.sql';
    const tsql = join(dir, 'migrations', name);
    const pg = join(dir, 'migrations-pg', 'V202611261400__v1.16.x__Valid.pg.sql');
    writeFileSync(tsql, 'ALTER TABLE [__mj_BizAppsTasks].[WorkReport] ADD [ArtifactID] UNIQUEIDENTIFIER NULL;\n', 'utf8');
    const sha = Sha256File(tsql);
    writeFileSync(
        pg,
        `-- @mj-pg-provenance: split-bake v1 source=${name} source-sha256=${sha} mode=needs-hand-rebaked\nSELECT 1;\n`,
        'utf8',
    );
    execFileSync('git', ['add', '.'], { cwd: dir });
    execFileSync('git', ['commit', '-q', '-m', 'add valid migration pair'], { cwd: dir });

    const res = spawnSync(process.execPath, [SCRIPT, 'HEAD~1', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    assert.equal(res.status, 0, res.stderr || res.stdout);
    assert.match(res.stdout, /PG counterpart & split-bake provenance verified/);
});

test('fails when a new migration has no .pg.sql counterpart', (t) => {
    const dir = initRepo();
    t.after(() => rmSync(dir, { recursive: true, force: true }));

    const name = 'V202611261401__v1.16.x__MissingPg.sql';
    writeFileSync(join(dir, 'migrations', name), 'SELECT 1;\n', 'utf8');
    execFileSync('git', ['add', '.'], { cwd: dir });
    execFileSync('git', ['commit', '-q', '-m', 'add tsql only'], { cwd: dir });

    const res = spawnSync(process.execPath, [SCRIPT, 'HEAD~1', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    assert.notEqual(res.status, 0);
    assert.match(res.stderr, /Missing PostgreSQL counterpart/);
});

test('fails when .pg.sql lacks line-1 split-bake provenance header or has stale SHA-256', (t) => {
    const dir = initRepo();
    t.after(() => rmSync(dir, { recursive: true, force: true }));

    const name = 'V202611261402__v1.16.x__BadHeader.sql';
    const tsql = join(dir, 'migrations', name);
    const pg = join(dir, 'migrations-pg', 'V202611261402__v1.16.x__BadHeader.pg.sql');
    writeFileSync(tsql, 'SELECT 1;\n', 'utf8');
    writeFileSync(pg, '-- hand authored pg file\nSELECT 1;\n', 'utf8');
    execFileSync('git', ['add', '.'], { cwd: dir });
    execFileSync('git', ['commit', '-q', '-m', 'add hand authored pg'], { cwd: dir });

    const noProv = spawnSync(process.execPath, [SCRIPT, 'HEAD~1', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    assert.notEqual(noProv.status, 0);
    assert.match(noProv.stderr, /deterministic split-bake provenance/);

    // Update to stale SHA
    writeFileSync(
        pg,
        `-- @mj-pg-provenance: split-bake v1 source=${name} source-sha256=${'a'.repeat(64)} mode=baked\nSELECT 1;\n`,
        'utf8',
    );
    execFileSync('git', ['add', '.'], { cwd: dir });
    execFileSync('git', ['commit', '-q', '-m', 'stale sha'], { cwd: dir });

    const stale = spawnSync(process.execPath, [SCRIPT, 'HEAD~2', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    assert.notEqual(stale.status, 0);
    assert.match(stale.stderr, /source-sha256 mismatch/);
});
