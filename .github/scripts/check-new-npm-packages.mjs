#!/usr/bin/env node
/**
 * New-package npm gate — runs on the PR that adds a package, not on the release.
 *
 * WHY THIS EXISTS: `publish.yml` publishes over npm trusted publishing (OIDC, no NPM_TOKEN). A
 * package can only be published that way once it exists on npm AND has this repository's
 * `publish.yml` attached as its trusted publisher. npm will not attach a trusted publisher to a
 * package that does not exist, and creating one needs an interactive 2FA prompt, so the setup is
 * manual. What is not fixed is WHEN it is found out. `rr: packages on npm` and the same check in
 * publish.yml only ask whether the package EXISTS — and a hand-published placeholder with no
 * trusted publisher passes that, then fails the real publish partway through a release.
 *
 * HOW IT VERIFIES: the trusted-publisher setting itself cannot be read without a write-scoped npm
 * token, which is the credential trusted publishing exists to remove. So this does not ask npm
 * whether trust is configured; it looks at something only a working configuration could have
 * produced. A version published through the trusted publisher carries a public provenance
 * attestation naming the repository and workflow that built it:
 *
 *     GET /-/npm/v1/attestations/<pkg>@<version>
 *     -> predicate.buildDefinition.externalParameters.workflow
 *        { path: '.github/workflows/publish.yml', repository: 'https://github.com/<owner>/<repo>' }
 *
 * `publish.yml`, dispatched with `seed_package`, publishes a placeholder prerelease over OIDC.
 * That publish succeeds only when the trusted publisher is attached, and this gate reads the
 * attestation it leaves. The seed has to come from publish.yml itself: npm matches the exact
 * workflow filename, so a seed from any other file is refused at the token exchange.
 *
 * WHAT IT CHECKS: only packages new in this PR — publishable names present in the working tree
 * and absent at the merge base. Nothing is configured per repo: the repository comes from
 * GITHUB_REPOSITORY (or --repo, or the `origin` remote) and no scope is assumed, so this file
 * drops into any repo in the family unchanged. It does not replace validate-npm-packages.sh,
 * which still checks every package at release time.
 *
 * CAVEAT: the registry is read unauthenticated, where a restricted package returns 404 exactly
 * like one that does not exist. Every package this pipeline publishes is public.
 *
 * Usage:  node .github/scripts/check-new-npm-packages.mjs <base-ref> [--repo owner/repo]
 * Exit:   0 = no new packages, or every new package is seeded
 *         1 = a new package is missing or unverified — merge blocked
 *         2 = usage error, or the check could not be completed
 */

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

/** Bare filename, as `npm trust github --file` wants it. */
export const PUBLISH_WORKFLOW_FILE = 'publish.yml';

/** The workflow that publishes. Provenance must name this exact path. */
export const PUBLISH_WORKFLOW_PATH = `.github/workflows/${PUBLISH_WORKFLOW_FILE}`;

/** The publish workflow's display name in the Actions tab. */
export const SEED_WORKFLOW_NAME = 'Build and Publish';

/** The workflow_dispatch input on publish.yml that selects the seed path. */
export const SEED_DISPATCH_INPUT = 'seed_package';

/** The matching double-entry input; must repeat the package name exactly. */
export const SEED_CONFIRM_INPUT = 'confirm_seed_package';

/** The branch a seed is dispatched from. publish.yml refuses a seed from an unprotected branch. */
export const SEED_DISPATCH_REF = 'next';

/** Human-run helper that performs the create, trust and seed steps, skipping any already done. */
export const SEED_SCRIPT_PATH = '.github/scripts/seed-new-npm-package.sh';

/** dist-tag applied to seed publishes, so `latest` never points at a placeholder. */
export const SEED_DIST_TAG = 'seed';

/** `npm trust` shipped in this version; earlier CLIs have no such command. */
export const MIN_NPM_VERSION = '11.15.0';

/** Public registry origin. */
export const REGISTRY_URL = 'https://registry.npmjs.org';

/** A PR adding more than this many packages at once is a mistake worth stopping on. */
export const MAX_NEW_PACKAGES = 25;

/** Bounded retries for a request that neither succeeds nor 404s. */
export const NPM_MAX_RETRIES = 3;

/** Backoff between retries, in milliseconds. */
export const NPM_RETRY_DELAY_MS = 2000;

/** Verdicts a new package can receive. Order matters: each implies the previous passed. */
export const STATUS = {
    MISSING: 'missing',
    NO_PROVENANCE: 'no-provenance',
    WRONG_PROVENANCE: 'wrong-provenance',
    READY: 'ready',
};

// ---------------------------------------------------------------------------
// Pure functions — no I/O, directly unit tested.
// ---------------------------------------------------------------------------

/**
 * `owner/repo` from a slug or a GitHub remote URL (https or ssh), or null when it is neither.
 * Anything that is not GitHub returns null: provenance from another host could never match.
 */
export function parseRepoSlug(value) {
    if (typeof value !== 'string') {
        return null;
    }
    const match = /^(?:(?:https?:\/\/|ssh:\/\/git@|git@)github\.com[:/])?([\w.-]+)\/([\w.-]+?)(?:\.git)?\/?$/.exec(value.trim());
    return match ? `${match[1]}/${match[2]}` : null;
}

/**
 * The repository whose publish workflow provenance must name. First usable source wins:
 * an explicit --repo, then GITHUB_REPOSITORY (always set in Actions), then the origin remote.
 */
export function resolveRepo({ flag, env, remote }) {
    for (const candidate of [flag, env, remote]) {
        const slug = parseRepoSlug(candidate);
        if (slug) {
            return slug;
        }
    }
    throw new Error('Could not tell which repository this is. Pass --repo owner/repo or set GITHUB_REPOSITORY.');
}

/** Split argv into the base ref and an optional `--repo owner/repo` (or `--repo=owner/repo`). */
export function parseArgs(argv) {
    const parsed = { baseRef: null, repoFlag: null };
    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === '--repo') {
            parsed.repoFlag = argv[++i] ?? null;
        } else if (arg.startsWith('--repo=')) {
            parsed.repoFlag = arg.slice('--repo='.length);
        } else if (!parsed.baseRef) {
            parsed.baseRef = arg;
        }
    }
    return parsed;
}

/**
 * Parse one package.json into the two facts this gate cares about.
 * Throws on malformed JSON rather than skipping: a manifest this gate cannot read is a manifest
 * whose publishability it cannot rule on.
 */
export function parseManifest(json, path) {
    let parsed;
    try {
        parsed = JSON.parse(json);
    } catch (err) {
        throw new Error(`Invalid JSON in ${path}: ${err.message}`);
    }
    const name = typeof parsed.name === 'string' && parsed.name ? parsed.name : null;
    return { path, name, isPrivate: parsed.private === true };
}

/**
 * Reduce manifests to the names npm would actually receive. Private packages are excluded because
 * changesets never publishes them; a nameless manifest cannot be published at all.
 */
export function publishableNames(manifests) {
    const names = new Set();
    for (const manifest of manifests) {
        if (manifest.name && !manifest.isPrivate) {
            names.add(manifest.name);
        }
    }
    return names;
}

/**
 * Names newly publishable on this branch: present at head, absent at the merge base.
 * Flipping `private: true` to `false` counts as new — that package has never been published either.
 */
export function diffNewPackages(baseNames, headNames) {
    return [...headNames].filter((name) => !baseNames.has(name)).sort();
}

/**
 * Keep the workspace manifests: `packages/<dir>/package.json`, one level deep. The same set
 * validate-npm-packages.sh checks at release time (`find packages -maxdepth 2`), so the two gates
 * rule on the same packages.
 */
export function selectManifestPaths(gitOutput) {
    return gitOutput
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => /^packages\/[^/]+\/package\.json$/.test(line));
}

/**
 * Which published version to demand provenance for. Prefers the seed tag, since a package new in
 * this PR should have nothing else; falls back to `latest` so a package whose first real version
 * was already published through the trusted publisher still verifies.
 */
export function selectVersionToVerify(packument) {
    const tags = packument?.['dist-tags'] ?? {};
    return tags[SEED_DIST_TAG] ?? tags.latest ?? null;
}

/**
 * Pull the workflow identity out of an npm attestation document. npm returns several attestations
 * per version; only the SLSA provenance one carries `buildDefinition`, so the others are skipped
 * rather than treated as malformed.
 */
export function extractProvenance(attestationDoc) {
    for (const attestation of attestationDoc?.attestations ?? []) {
        const payload = attestation?.bundle?.dsseEnvelope?.payload;
        if (!payload) {
            continue;
        }
        let statement;
        try {
            statement = JSON.parse(Buffer.from(payload, 'base64').toString('utf8'));
        } catch {
            // A single unparseable envelope must not mask a valid one alongside it.
            continue;
        }
        const workflow = statement?.predicate?.buildDefinition?.externalParameters?.workflow;
        if (workflow) {
            return { path: workflow.path ?? null, repository: workflow.repository ?? null, ref: workflow.ref ?? null };
        }
    }
    return null;
}

/**
 * Does this provenance prove this repository's publish workflow produced the package? Both fields
 * must match: the right workflow in another repository, or another workflow in this one, is not
 * the identity publish.yml will present. Owner and repo compare case-insensitively, as GitHub does.
 */
export function verifyProvenance(provenance, repo) {
    const expectedRepository = `https://github.com/${repo}`;
    if (!provenance) {
        return { ok: false, reason: 'no provenance attestation found' };
    }
    if ((provenance.repository ?? '').toLowerCase() !== expectedRepository.toLowerCase()) {
        return { ok: false, reason: `built from ${provenance.repository ?? 'an unknown repository'}, expected ${expectedRepository}` };
    }
    if (provenance.path !== PUBLISH_WORKFLOW_PATH) {
        return { ok: false, reason: `built by ${provenance.path ?? 'an unknown workflow'}, expected ${PUBLISH_WORKFLOW_PATH}` };
    }
    return { ok: true, reason: `provenance names ${repo} / ${PUBLISH_WORKFLOW_PATH}` };
}

/** A package name as it appears in a registry URL path: the scope separator is percent-encoded. */
function registryNameSegment(name) {
    return name.replace(/\//g, '%2f');
}

/** Registry path for a package's metadata. */
export function packumentUrl(name) {
    return `${REGISTRY_URL}/${registryNameSegment(name)}`;
}

/** Registry path for one version's attestations. */
export function attestationUrl(name, version) {
    return `${REGISTRY_URL}/-/npm/v1/attestations/${registryNameSegment(name)}@${version}`;
}

/** The npm page listing who can do the setup for a scoped package, or null for an unscoped one. */
export function scopeMembersUrl(name) {
    const match = /^@([^/]+)\//.exec(name);
    return match ? `https://www.npmjs.com/settings/${match[1]}/members` : null;
}

/** One line per package, aligned, so a multi-package failure stays readable. */
export function formatVerdictLine({ name, status, detail }) {
    const label = {
        [STATUS.MISSING]: 'NOT ON NPM',
        [STATUS.NO_PROVENANCE]: 'NOT SEEDED',
        [STATUS.WRONG_PROVENANCE]: 'BAD PROVENANCE',
        [STATUS.READY]: 'ready',
    }[status];
    return `  ${label.padEnd(15)} ${name}${detail ? ` — ${detail}` : ''}`;
}

/** The numbered manual steps, for whoever is not using the helper script. */
function formatManualSteps(blocked, repo) {
    const names = blocked.map((v) => v.name);
    const missing = blocked.filter((v) => v.status === STATUS.MISSING).map((v) => v.name);
    const createLines = (missing.length ? missing : names).map((name) => `     npx -y setup-npm-trusted-publish ${name}`);
    const trustLines = names.map((name) => `     npm trust github ${name} --file ${PUBLISH_WORKFLOW_FILE} --repo ${repo} --allow-publish -y`);
    const seedLines = names.map(
        (name) => `     gh workflow run ${PUBLISH_WORKFLOW_FILE} --repo ${repo} --ref ${SEED_DISPATCH_REF} -f ${SEED_DISPATCH_INPUT}=${name} -f ${SEED_CONFIRM_INPUT}=${name}`
    );
    return `1. Create the package on npm (skip any that already exist). It must exist before step 2:

${createLines.join('\n')}

2. Attach this repository's ${PUBLISH_WORKFLOW_FILE} as the trusted publisher (one 2FA prompt):

${trustLines.join('\n')}

3. Seed the package over OIDC, one package at a time. This runs only the seed job of
   "${SEED_WORKFLOW_NAME}": it builds and releases nothing, and it succeeds ONLY if step 2 worked.

${seedLines.join('\n')}

4. Re-run this check. It reads the public attestation the seed left behind.`;
}

/**
 * The whole point of the gate: tell the PR author exactly what to do, and what to do if they
 * cannot do it. Kept pure so its wording is covered by tests.
 */
export function formatGateFailure(verdicts, repo) {
    const blocked = verdicts.filter((v) => v.status !== STATUS.READY);
    const names = blocked.map((v) => v.name);
    const membersUrl = scopeMembersUrl(names[0] ?? '');

    return `
================================================================================
BLOCKED: ${blocked.length} new package(s) cannot be published by ${PUBLISH_WORKFLOW_FILE} yet
================================================================================

${blocked.map(formatVerdictLine).join('\n')}

These packages are new in this PR. Each must exist on npm, have ${repo}'s
${PUBLISH_WORKFLOW_FILE} attached as its trusted publisher, and carry a seed version published
through it — or the next release fails partway through, after other packages have shipped.

--------------------------------------------------------------------------------
HOW TO FIX (about 5 minutes, plus one 2FA prompt)
--------------------------------------------------------------------------------

Needs: npm ${MIN_NPM_VERSION} or newer (\`npm install -g npm@^${MIN_NPM_VERSION}\`), \`npm login\` on an
account with 2FA and publish rights on the package's scope, and \`gh auth login\`.

Quick path, from a checkout of this repo. It checks live state before every step, so it is
safe to re-run, and it waits for the attestation:

     ${SEED_SCRIPT_PATH} ${names.join(' ')}

Or by hand:

${formatManualSteps(blocked, repo)}

--------------------------------------------------------------------------------
IF YOU DO NOT HAVE NPM ACCESS
--------------------------------------------------------------------------------

Hand it to someone with publish rights on the scope${membersUrl ? ` (members can see the list at\n${membersUrl})` : ''}. Give them this:

     New package npm setup needed before merge:
${names.map((name) => `       ${name}`).join('\n')}
     Run: ${SEED_SCRIPT_PATH} ${names.join(' ')}
     (Repo ${repo}, workflow ${PUBLISH_WORKFLOW_FILE}, allow-publish, no environment.)

Do NOT silence this by marking the package \`"private": true\` unless it should never be
published. This gate skips private packages, so the package would quietly ship to nobody.

Reference: PUBLISH_SETUP.md, "First publish".
================================================================================
`.trimStart();
}

// ---------------------------------------------------------------------------
// I/O — git, the filesystem, and the npm registry.
// ---------------------------------------------------------------------------

/** Run git and return stdout. Throws with git's own stderr on failure. */
function git(args) {
    return execFileSync('git', args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
}

/** The origin remote's URL, or null in a checkout that has none. Quiet: having none is not an error. */
function originRemoteUrl() {
    try {
        return execFileSync('git', ['remote', 'get-url', 'origin'], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
    } catch {
        return null;
    }
}

/**
 * Workspace manifest paths at `ref`, or in the working tree when ref is null. Uses git rather
 * than a directory walk so ignored trees (node_modules, dist) never appear.
 */
export function listManifestPaths(ref) {
    const output = ref ? git(['ls-tree', '-r', '--name-only', ref, '--', 'packages']) : git(['ls-files', '--', 'packages']);
    return selectManifestPaths(output);
}

/** Read one manifest at `ref`, or from the working tree when ref is null. */
function readManifestAt(ref, path) {
    return ref ? git(['show', `${ref}:${path}`]) : readFileSync(path, 'utf8');
}

/** The set of publishable package names at `ref` (null = working tree). */
export function collectPublishableNames(ref) {
    const manifests = listManifestPaths(ref).map((path) => parseManifest(readManifestAt(ref, path), path));
    return publishableNames(manifests);
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * GET a registry document, returning `{ status, body }` where body is parsed JSON or null.
 * 200 and 404 are answers and returned immediately. Anything else is retried, then raised —
 * never downgraded to "missing", because a network blip that reads as a missing package would
 * block a PR for no reason.
 */
export async function fetchRegistryJson(url, fetchImpl = fetch, delayMs = NPM_RETRY_DELAY_MS) {
    let lastFailure = 'no attempt made';

    for (let attempt = 1; attempt <= NPM_MAX_RETRIES; attempt++) {
        let response = null;
        try {
            response = await fetchImpl(url, { headers: { accept: 'application/json' } });
        } catch (err) {
            lastFailure = `network error: ${err.message}`;
        }

        if (response && response.status === 404) {
            return { status: 404, body: null };
        }
        if (response && response.status === 200) {
            try {
                return { status: 200, body: await response.json() };
            } catch (err) {
                lastFailure = `unparseable JSON: ${err.message}`;
            }
        } else if (response) {
            lastFailure = `HTTP ${response.status}`;
        }

        if (attempt < NPM_MAX_RETRIES) {
            console.log(`   Retry ${attempt}/${NPM_MAX_RETRIES} for ${url} (${lastFailure})`);
            await sleep(delayMs);
        }
    }

    throw new Error(`Could not read ${url} after ${NPM_MAX_RETRIES} attempts (${lastFailure}). Check https://status.npmjs.org/ and re-run.`);
}

/**
 * Decide whether one new package is ready to be published by publish.yml. Three questions in
 * order, each only meaningful if the previous passed: does it exist, was it published through a
 * trusted publisher, and was that publisher this repository's.
 */
export async function classifyPackage(name, repo, fetchImpl = fetch, delayMs = NPM_RETRY_DELAY_MS) {
    const packument = await fetchRegistryJson(packumentUrl(name), fetchImpl, delayMs);
    if (packument.status === 404) {
        return { name, status: STATUS.MISSING, detail: 'package does not exist on npm' };
    }

    const version = selectVersionToVerify(packument.body);
    if (!version) {
        return { name, status: STATUS.NO_PROVENANCE, detail: 'package exists but has no published version' };
    }

    const attestations = await fetchRegistryJson(attestationUrl(name, version), fetchImpl, delayMs);
    if (attestations.status === 404) {
        return { name, status: STATUS.NO_PROVENANCE, detail: `${version} has no provenance — the seed has not been run` };
    }

    const verdict = verifyProvenance(extractProvenance(attestations.body), repo);
    return { name, status: verdict.ok ? STATUS.READY : STATUS.WRONG_PROVENANCE, detail: `${version} ${verdict.reason}` };
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/** Classify every added package, printing each verdict as it lands. */
async function classifyAll(added, repo) {
    const verdicts = [];
    for (const name of added) {
        const verdict = await classifyPackage(name, repo);
        console.log(formatVerdictLine(verdict));
        verdicts.push(verdict);
    }
    return verdicts;
}

export async function main(argv, env = process.env) {
    const { baseRef, repoFlag } = parseArgs(argv);
    if (!baseRef) {
        console.error('Usage: node .github/scripts/check-new-npm-packages.mjs <base-ref> [--repo owner/repo]');
        return 2;
    }
    const repo = resolveRepo({ flag: repoFlag, env: env.GITHUB_REPOSITORY, remote: originRemoteUrl() });

    console.log(`Comparing publishable packages against ${baseRef} (repository ${repo})...`);
    const headNames = collectPublishableNames(null);
    const added = diffNewPackages(collectPublishableNames(baseRef), headNames);

    if (added.length === 0) {
        console.log(`No new publishable packages in this PR (${headNames.size} total, none added).`);
        return 0;
    }
    if (added.length > MAX_NEW_PACKAGES) {
        console.error(`This PR adds ${added.length} packages, above the ${MAX_NEW_PACKAGES} cap. Split it.`);
        return 2;
    }

    console.log(`New publishable package(s) in this PR: ${added.length}`);
    const verdicts = await classifyAll(added, repo);
    if (verdicts.every((verdict) => verdict.status === STATUS.READY)) {
        console.log(`All ${added.length} new package(s) carry provenance from ${repo} / ${PUBLISH_WORKFLOW_PATH}.`);
        return 0;
    }

    console.error(formatGateFailure(verdicts, repo));
    return 1;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
    main(process.argv.slice(2))
        .then((code) => process.exit(code))
        .catch((err) => {
            console.error(`Check could not be completed: ${err.message}`);
            process.exit(2);
        });
}
