/**
 * Integration suite dispatcher for BizApps Tasks.
 *
 * Supports both direct SQLServerDataProvider execution (default when DB_DATABASE is configured)
 * and GraphQLDataProvider → MJAPI execution (when IT_TRANSPORT=graphql or --graphql is passed).
 *
 *   node test-harnesses/integration.mjs
 *   node test-harnesses/integration.mjs time-entries timers agent-effort time-reporting timesheets
 *   IT_TRANSPORT=graphql node test-harnesses/integration.mjs task-world
 */
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

const here = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(here, '..', '.env'), quiet: true });
dotenv.config({ path: path.resolve(here, '../../MJ/.env'), quiet: true });

process.env.MJ_INTEGRATION_TEST = '1';
process.env.RUN_MUTATION_TESTS = process.env.RUN_MUTATION_TESTS ?? '1';

const ALL_BUNDLES = [
    'task-world',
    'task-hierarchy',
    'task-dependencies',
    'task-assignments',
    'task-decisions',
    'task-templates',
    'task-statuses',
    'task-action-hooks',
    'time-entries',
    'timers',
    'agent-effort',
    'time-reporting',
    'timesheets',
];

const args = process.argv.slice(2);
const useGraphQL = process.env.IT_TRANSPORT === 'graphql' || args.includes('--graphql');
const only = args.filter((a) => !a.startsWith('-'));

let provider;
let user;
let pool = null;

if (useGraphQL) {
    const { bootstrapIntegrationClient } = await import('@memberjunction/testing-integration/client');
    const { Metadata } = await import('@memberjunction/core');
    await bootstrapIntegrationClient();
    await import('../packages/IntegrationTests/dist/index.js');
    provider = Metadata.Provider;
    user = provider.CurrentUser;
    if (!user) throw new Error('GraphQL provider has no CurrentUser — check MJ_API_KEY and MJAPI.');
    console.log(`\n  Tasks integration (GraphQL → ${process.env.MJAPI_URL ?? `http://localhost:${process.env.GRAPHQL_PORT ?? 4000}`})\n`);
} else {
    const sqlMod = await import('mssql');
    const sql = sqlMod.default ?? sqlMod;
    const { DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD } = process.env;
    pool = await new sql.ConnectionPool({
        server: DB_HOST || 'localhost',
        port: Number(DB_PORT ?? 1433),
        database: DB_DATABASE,
        user: DB_USERNAME,
        password: DB_PASSWORD,
        options: { trustServerCertificate: true, encrypt: false },
        pool: { max: 10, min: 1 },
        requestTimeout: 60_000,
    }).connect();

    const { setupSQLServerClient, SQLServerProviderConfigData, UserCache } = await import(
        '@memberjunction/sqlserver-dataprovider'
    );
    provider = await setupSQLServerClient(
        new SQLServerProviderConfigData(pool, process.env.MJ_CORE_SCHEMA || '__mj'),
    );
    await UserCache.Instance.Refresh(pool);
    user = UserCache.Users.find((u) => u?.Type?.trim().toLowerCase() === 'owner') ?? UserCache.Users[0];
    if (!user) throw new Error('No context user in UserCache.');

    await import('../packages/IntegrationTests/dist/index.js');
    console.log(`\n  Tasks integration (SQL Server → ${DB_HOST || 'localhost'}:${DB_PORT ?? 1433}/${DB_DATABASE})\n`);
}

const { IntegrationCheckRegistry } = await import('@memberjunction/testing-integration/registry');

const ctx = { User: user, Provider: provider, Pool: pool, Schema: process.env.MJ_CORE_SCHEMA || '__mj', Storage: undefined };
const registry = IntegrationCheckRegistry.Instance;
const requested = only.length ? only : ALL_BUNDLES;
let pass = 0;
let fail = 0;

for (const request of requested) {
    const [bundle, localId] = request.includes('.') ? request.split('.') : [request, null];
    const checks = registry.GetBundle(bundle).filter((c) => !localId || c.Id === request);
    if (checks.length === 0) {
        console.error(`  unknown: ${request}`);
        fail += 1;
        continue;
    }
    const lifecycle = registry.GetLifecycle(bundle);
    try {
        if (lifecycle) await lifecycle.Setup(ctx);
        for (const check of checks) {
            const started = Date.now();
            try {
                await check.Fn(ctx);
                console.log(`  ok   ${check.Id.padEnd(32)} ${Date.now() - started}ms  ${check.Name}`);
                pass += 1;
            } catch (err) {
                const message = err instanceof Error ? err.message : String(err);
                console.error(`  FAIL ${check.Id.padEnd(32)} ${Date.now() - started}ms  ${message}`);
                if (process.env.IT_VERBOSE === '1' && err instanceof Error) console.error(err.stack);
                fail += 1;
            }
        }
    } finally {
        if (lifecycle) {
            await lifecycle.Teardown(ctx).catch((e) => console.warn(`  teardown warn: ${e?.message}`));
        }
    }
}

console.log(`\n  ${pass} passed / ${fail} failed\n`);
if (pool) await pool.close();
process.exit(fail === 0 ? 0 : 1);
