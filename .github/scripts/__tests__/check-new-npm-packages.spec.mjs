// Specs for .github/scripts/check-new-npm-packages.mjs. Plain node:test, no dependencies:
//   node --test .github/scripts/__tests__/*.spec.mjs
import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
    parseRepoSlug,
    resolveRepo,
    parseArgs,
    parseManifest,
    publishableNames,
    diffNewPackages,
    selectManifestPaths,
    selectVersionToVerify,
    extractProvenance,
    verifyProvenance,
    classifyPackage,
    fetchRegistryJson,
    formatGateFailure,
    packumentUrl,
    attestationUrl,
    scopeMembersUrl,
    STATUS,
    NPM_MAX_RETRIES,
    PUBLISH_WORKFLOW_FILE,
    PUBLISH_WORKFLOW_PATH,
    SEED_DISPATCH_INPUT,
    SEED_CONFIRM_INPUT,
    SEED_SCRIPT_PATH,
} from '../check-new-npm-packages.mjs';

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const REPO = 'ExampleOrg/example-app';
const REPO_URL = `https://github.com/${REPO}`;
const PKG = '@example/new-thing';

// --- fixtures ---------------------------------------------------------------

const envelope = (statement) => ({ bundle: { dsseEnvelope: { payload: Buffer.from(JSON.stringify(statement)).toString('base64') } } });

/** Wrap a workflow identity in the shape npm returns: a publish attestation beside the provenance one. */
const attestationDoc = (workflow) => ({
    attestations: [envelope({ predicate: {} }), envelope({ predicate: { buildDefinition: { externalParameters: { workflow } } } })],
});

const GOOD_WORKFLOW = { path: PUBLISH_WORKFLOW_PATH, repository: REPO_URL, ref: 'refs/heads/next' };

/** A fetch double driven by a url -> {status, body} map. Unlisted urls 404. */
const fakeFetch = (routes) => async (url) => {
    const hit = routes[url];
    return hit ? { status: hit.status, json: async () => hit.body } : { status: 404, json: async () => ({}) };
};

// --- repository identity ----------------------------------------------------

describe('parseRepoSlug', () => {
    it('accepts a plain owner/repo slug', () => {
        assert.equal(parseRepoSlug('ExampleOrg/example-app'), REPO);
    });

    it('accepts https and ssh GitHub remotes, with or without .git', () => {
        assert.equal(parseRepoSlug('https://github.com/ExampleOrg/example-app.git'), REPO);
        assert.equal(parseRepoSlug('https://github.com/ExampleOrg/example-app'), REPO);
        assert.equal(parseRepoSlug('git@github.com:ExampleOrg/example-app.git'), REPO);
        assert.equal(parseRepoSlug('ssh://git@github.com/ExampleOrg/example-app.git\n'), REPO);
    });

    it('returns null for another host, a deeper path, or a non-string', () => {
        assert.equal(parseRepoSlug('https://gitlab.com/ExampleOrg/example-app.git'), null);
        assert.equal(parseRepoSlug('a/b/c'), null);
        assert.equal(parseRepoSlug(''), null);
        assert.equal(parseRepoSlug(undefined), null);
    });
});

describe('resolveRepo', () => {
    it('prefers the flag, then GITHUB_REPOSITORY, then the origin remote', () => {
        assert.equal(resolveRepo({ flag: 'a/flag', env: 'b/env', remote: 'git@github.com:c/remote.git' }), 'a/flag');
        assert.equal(resolveRepo({ flag: null, env: 'b/env', remote: 'git@github.com:c/remote.git' }), 'b/env');
        assert.equal(resolveRepo({ flag: null, env: undefined, remote: 'git@github.com:c/remote.git' }), 'c/remote');
    });

    it('skips an unusable source rather than failing on it', () => {
        assert.equal(resolveRepo({ flag: 'not a repo', env: 'b/env', remote: null }), 'b/env');
    });

    it('throws when nothing names the repository — it must never guess', () => {
        assert.throws(() => resolveRepo({ flag: null, env: undefined, remote: null }), /--repo/);
    });
});

describe('parseArgs', () => {
    it('reads the base ref and both --repo forms', () => {
        assert.deepEqual(parseArgs(['abc123']), { baseRef: 'abc123', repoFlag: null });
        assert.deepEqual(parseArgs(['abc123', '--repo', 'a/b']), { baseRef: 'abc123', repoFlag: 'a/b' });
        assert.deepEqual(parseArgs(['--repo=a/b', 'abc123']), { baseRef: 'abc123', repoFlag: 'a/b' });
    });

    it('reports a missing base ref as null', () => {
        assert.equal(parseArgs([]).baseRef, null);
    });
});

// --- manifests --------------------------------------------------------------

describe('parseManifest', () => {
    it('extracts name and private flag', () => {
        assert.deepEqual(parseManifest('{"name":"@example/a","private":true}', 'p/package.json'), {
            path: 'p/package.json',
            name: '@example/a',
            isPrivate: true,
        });
    });

    it('treats a missing private field as publishable', () => {
        assert.equal(parseManifest('{"name":"@example/a"}', 'p').isPrivate, false);
    });

    it('treats the string "true" as NOT private — only a real boolean counts', () => {
        assert.equal(parseManifest('{"name":"@example/a","private":"true"}', 'p').isPrivate, false);
    });

    it('throws on malformed JSON, naming the file', () => {
        assert.throws(() => parseManifest('{nope', 'packages/X/package.json'), /packages\/X\/package\.json/);
    });
});

describe('publishableNames', () => {
    it('keeps every named public package, whatever its scope', () => {
        const names = publishableNames([
            { name: '@example/a', isPrivate: false },
            { name: '@other/b', isPrivate: false },
            { name: 'unscoped', isPrivate: false },
            { name: '@example/private', isPrivate: true },
            { name: null, isPrivate: false },
        ]);
        assert.deepEqual([...names].sort(), ['@example/a', '@other/b', 'unscoped']);
    });
});

describe('diffNewPackages', () => {
    it('returns names present at head but not at base, sorted', () => {
        assert.deepEqual(diffNewPackages(new Set(['@x/a']), new Set(['@x/c', '@x/a', '@x/b'])), ['@x/b', '@x/c']);
    });

    it('ignores packages removed at head', () => {
        assert.deepEqual(diffNewPackages(new Set(['@x/a', '@x/gone']), new Set(['@x/a'])), []);
    });

    it('treats a package flipped from private to public as new', () => {
        const base = publishableNames([{ name: '@x/a', isPrivate: true }]);
        const head = publishableNames([{ name: '@x/a', isPrivate: false }]);
        assert.deepEqual(diffNewPackages(base, head), ['@x/a']);
    });
});

describe('selectManifestPaths', () => {
    it('keeps packages/<dir>/package.json and drops everything else', () => {
        const output = ['packages/Core/package.json', 'packages/Core/src/index.ts', 'packages/Core/tsconfig.json', ''].join('\n');
        assert.deepEqual(selectManifestPaths(output), ['packages/Core/package.json']);
    });

    it('drops nested and vendored manifests, matching the release-time gate', () => {
        const output = ['packages/Core/node_modules/x/package.json', 'packages/Angular/src/fixture/package.json', 'package.json'].join('\n');
        assert.deepEqual(selectManifestPaths(output), []);
    });

    it('does not match a file merely ending in package.json', () => {
        assert.deepEqual(selectManifestPaths('packages/Core/not-package.json'), []);
    });
});

// --- provenance -------------------------------------------------------------

describe('selectVersionToVerify', () => {
    it('prefers the seed tag', () => {
        assert.equal(selectVersionToVerify({ 'dist-tags': { latest: '0.0.0', seed: '0.0.1-seed.1' } }), '0.0.1-seed.1');
    });

    it('falls back to latest when there is no seed tag', () => {
        assert.equal(selectVersionToVerify({ 'dist-tags': { latest: '1.2.3' } }), '1.2.3');
    });

    it('returns null when the package has no versions at all', () => {
        assert.equal(selectVersionToVerify({}), null);
        assert.equal(selectVersionToVerify(null), null);
    });
});

describe('extractProvenance', () => {
    it('pulls workflow identity out of the SLSA envelope, skipping the publish attestation', () => {
        assert.deepEqual(extractProvenance(attestationDoc(GOOD_WORKFLOW)), GOOD_WORKFLOW);
    });

    it('returns null when no attestation carries a buildDefinition', () => {
        assert.equal(extractProvenance({ attestations: [envelope({ predicate: {} })] }), null);
        assert.equal(extractProvenance({}), null);
    });

    it('skips an unparseable envelope rather than losing a valid one beside it', () => {
        const doc = attestationDoc(GOOD_WORKFLOW);
        doc.attestations.unshift({ bundle: { dsseEnvelope: { payload: Buffer.from('{not json').toString('base64') } } });
        assert.deepEqual(extractProvenance(doc), GOOD_WORKFLOW);
    });
});

describe('verifyProvenance', () => {
    it('accepts this repository and its publish workflow', () => {
        assert.equal(verifyProvenance(GOOD_WORKFLOW, REPO).ok, true);
    });

    it('compares owner and repo case-insensitively, as GitHub does', () => {
        assert.equal(verifyProvenance(GOOD_WORKFLOW, REPO.toLowerCase()).ok, true);
    });

    it('rejects the right workflow in another repository', () => {
        const verdict = verifyProvenance({ ...GOOD_WORKFLOW, repository: 'https://github.com/Someone/else' }, REPO);
        assert.equal(verdict.ok, false);
        assert.match(verdict.reason, /Someone\/else/);
    });

    it('rejects a repository that merely starts with the expected one', () => {
        assert.equal(verifyProvenance({ ...GOOD_WORKFLOW, repository: `${REPO_URL}-fork` }, REPO).ok, false);
    });

    it('rejects another workflow in this repository', () => {
        const verdict = verifyProvenance({ ...GOOD_WORKFLOW, path: '.github/workflows/seed.yml' }, REPO);
        assert.equal(verdict.ok, false);
        assert.match(verdict.reason, /seed\.yml/);
    });

    it('rejects missing provenance', () => {
        assert.equal(verifyProvenance(null, REPO).ok, false);
    });
});

// --- registry ---------------------------------------------------------------

describe('registry urls', () => {
    it('percent-encodes the scope separator', () => {
        assert.equal(packumentUrl(PKG), 'https://registry.npmjs.org/@example%2fnew-thing');
        assert.equal(attestationUrl(PKG, '0.0.1-seed.1'), 'https://registry.npmjs.org/-/npm/v1/attestations/@example%2fnew-thing@0.0.1-seed.1');
    });

    it('derives the scope members page, and nothing for an unscoped name', () => {
        assert.equal(scopeMembersUrl(PKG), 'https://www.npmjs.com/settings/example/members');
        assert.equal(scopeMembersUrl('unscoped'), null);
    });
});

describe('fetchRegistryJson', () => {
    it('returns 404 without retrying — it is an answer, not a failure', async () => {
        let calls = 0;
        const result = await fetchRegistryJson('u', async () => (calls++, { status: 404, json: async () => ({}) }), 0);
        assert.deepEqual(result, { status: 404, body: null });
        assert.equal(calls, 1);
    });

    it('retries a server error and succeeds when it clears', async () => {
        let calls = 0;
        const fetchImpl = async () => (++calls < 2 ? { status: 503, json: async () => ({}) } : { status: 200, json: async () => ({ ok: 1 }) });
        assert.deepEqual(await fetchRegistryJson('u', fetchImpl, 0), { status: 200, body: { ok: 1 } });
        assert.equal(calls, 2);
    });

    it('throws rather than reporting missing when the registry never answers', async () => {
        let calls = 0;
        const fetchImpl = async () => {
            calls++;
            throw new Error('socket hang up');
        };
        await assert.rejects(fetchRegistryJson('u', fetchImpl, 0), /socket hang up/);
        assert.equal(calls, NPM_MAX_RETRIES);
    });
});

describe('classifyPackage', () => {
    const packument = (tags) => ({ status: 200, body: { 'dist-tags': tags } });

    it('reports MISSING when the package does not exist', async () => {
        assert.equal((await classifyPackage(PKG, REPO, fakeFetch({}), 0)).status, STATUS.MISSING);
    });

    it('reports NO_PROVENANCE when the package exists but was never seeded', async () => {
        const fetchImpl = fakeFetch({ [packumentUrl(PKG)]: packument({ latest: '0.0.0' }) });
        const verdict = await classifyPackage(PKG, REPO, fetchImpl, 0);
        assert.equal(verdict.status, STATUS.NO_PROVENANCE);
        assert.match(verdict.detail, /0\.0\.0/);
    });

    it('reports NO_PROVENANCE when the package exists with no published version', async () => {
        const fetchImpl = fakeFetch({ [packumentUrl(PKG)]: packument({}) });
        assert.equal((await classifyPackage(PKG, REPO, fetchImpl, 0)).status, STATUS.NO_PROVENANCE);
    });

    it('reports WRONG_PROVENANCE when another repository built it', async () => {
        const fetchImpl = fakeFetch({
            [packumentUrl(PKG)]: packument({ seed: '0.0.1-seed.1' }),
            [attestationUrl(PKG, '0.0.1-seed.1')]: { status: 200, body: attestationDoc({ ...GOOD_WORKFLOW, repository: 'https://github.com/Someone/else' }) },
        });
        assert.equal((await classifyPackage(PKG, REPO, fetchImpl, 0)).status, STATUS.WRONG_PROVENANCE);
    });

    it('reports READY when the seed carries this repository\'s provenance', async () => {
        const fetchImpl = fakeFetch({
            [packumentUrl(PKG)]: packument({ latest: '0.0.0', seed: '0.0.1-seed.1' }),
            [attestationUrl(PKG, '0.0.1-seed.1')]: { status: 200, body: attestationDoc(GOOD_WORKFLOW) },
        });
        const verdict = await classifyPackage(PKG, REPO, fetchImpl, 0);
        assert.equal(verdict.status, STATUS.READY);
        assert.match(verdict.detail, /0\.0\.1-seed\.1/);
    });

    it('verifies the seed tag in preference to latest', async () => {
        // Only the seed version has an attestation; asking for latest's would 404 and block.
        const fetchImpl = fakeFetch({
            [packumentUrl(PKG)]: packument({ latest: '0.0.0', seed: '0.0.1-seed.2' }),
            [attestationUrl(PKG, '0.0.1-seed.2')]: { status: 200, body: attestationDoc(GOOD_WORKFLOW) },
        });
        assert.equal((await classifyPackage(PKG, REPO, fetchImpl, 0)).status, STATUS.READY);
    });
});

// --- the failure message ----------------------------------------------------

describe('formatGateFailure', () => {
    const verdicts = [
        { name: '@example/missing', status: STATUS.MISSING, detail: 'package does not exist on npm' },
        { name: '@example/unseeded', status: STATUS.NO_PROVENANCE, detail: '0.0.0 has no provenance' },
        { name: '@example/fine', status: STATUS.READY, detail: '0.0.1-seed.1 ok' },
    ];
    const message = formatGateFailure(verdicts, REPO);

    it('lists only the blocked packages, not the ready ones', () => {
        assert.match(message, /BLOCKED: 2 new package/);
        assert.doesNotMatch(message, /@example\/fine/);
    });

    it('distinguishes a missing package from an unseeded one', () => {
        assert.match(message, /NOT ON NPM\s+@example\/missing/);
        assert.match(message, /NOT SEEDED\s+@example\/unseeded/);
    });

    it('offers to create only the packages that do not exist', () => {
        assert.match(message, /setup-npm-trusted-publish @example\/missing/);
        assert.doesNotMatch(message, /setup-npm-trusted-publish @example\/unseeded/);
    });

    it('gives a runnable npm trust command per blocked package, naming this repository', () => {
        for (const name of ['@example/missing', '@example/unseeded']) {
            assert.ok(message.includes(`npm trust github ${name} --file ${PUBLISH_WORKFLOW_FILE} --repo ${REPO} --allow-publish -y`));
        }
    });

    it('seeds through the publish workflow with both double-entry inputs', () => {
        assert.ok(message.includes(`gh workflow run ${PUBLISH_WORKFLOW_FILE} --repo ${REPO}`));
        assert.ok(message.includes(`-f ${SEED_DISPATCH_INPUT}=@example/missing -f ${SEED_CONFIRM_INPUT}=@example/missing`));
    });

    it('orders the steps so trust is attached before seeding', () => {
        assert.ok(message.indexOf('npm trust github') < message.indexOf('gh workflow run'));
    });

    it('offers the seed script with every blocked package, and the script exists', () => {
        assert.ok(message.includes(`${SEED_SCRIPT_PATH} @example/missing @example/unseeded`));
        assert.ok(existsSync(join(REPO_ROOT, SEED_SCRIPT_PATH)), `${SEED_SCRIPT_PATH} is missing from the repo`);
    });

    it('includes a hand-off for authors without npm access, without naming a person', () => {
        assert.match(message, /IF YOU DO NOT HAVE NPM ACCESS/);
        assert.ok(message.includes('https://www.npmjs.com/settings/example/members'));
    });

    it('warns against silencing the gate with private: true', () => {
        assert.match(message, /"private": true/);
    });
});

// --- the seed path this gate depends on --------------------------------------

describe('publish.yml seed path', () => {
    it('exposes the dispatch inputs the failure message tells people to fill in', () => {
        const workflow = readFileSync(join(REPO_ROOT, PUBLISH_WORKFLOW_PATH), 'utf8');
        assert.match(workflow, new RegExp(`^      ${SEED_DISPATCH_INPUT}:`, 'm'));
        assert.match(workflow, new RegExp(`^      ${SEED_CONFIRM_INPUT}:`, 'm'));
    });
});
