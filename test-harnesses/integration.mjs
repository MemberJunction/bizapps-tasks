/**
 * Integration suite dispatcher for BizApps Tasks.
 *
 * Supports both direct SQLServerDataProvider execution (default when DB_DATABASE is configured)
 * and GraphQLDataProvider → MJAPI execution (when IT_TRANSPORT=graphql or --graphql is passed).
 *
 *   node test-harnesses/integration.mjs
 *   node test-harnesses/integration.mjs time-entries timers agent-effort time-reporting timesheets
 *   IT_TRANSPORT=graphql node test-harnesses/integration.mjs task-world
 *
 * Opt-in bundles (not in the default list):
 *   MJ_IT_LOAD_ENTITIES_SERVER=1 node test-harnesses/integration.mjs workflow-human-tasks
 *     Workflow Human steps and agents' questions answered through the BizAppsTasks human-task
 *     provider, on MJ's real task-graph dispatcher. Direct database only; needs an MJ build that
 *     has the human-task provider contract (MJ #6763, #6777).
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
    'meetings',
    'task-org-bulk-ops',
    'task-cos-typed-skills',
    'task-cos-live',
    'project-risk-assessments',
    'artifact-convergence',
];

const args = process.argv.slice(2);
const useGraphQL = process.env.IT_TRANSPORT === 'graphql' || args.includes('--graphql');
const dbPlatform = (process.env.DB_PLATFORM ?? 'sqlserver').trim().toLowerCase();
const usePostgres = !useGraphQL && (dbPlatform === 'postgresql' || dbPlatform === 'postgres' || dbPlatform === 'pg');
const only = args.filter((a) => !a.startsWith('-'));

let provider;
let user;
let pool = null;
let closePool = null;

if (useGraphQL) {
    const { bootstrapIntegrationClient } = await import('@memberjunction/testing-integration/client');
    const { Metadata } = await import('@memberjunction/core');
    await bootstrapIntegrationClient();
    await import('../packages/IntegrationTests/dist/index.js');
    provider = Metadata.Provider;
    user = provider.CurrentUser;
    if (!user) throw new Error('GraphQL provider has no CurrentUser — check MJ_API_KEY and MJAPI.');
    console.log(`\n  Tasks integration (GraphQL → ${process.env.MJAPI_URL ?? `http://localhost:${process.env.GRAPHQL_PORT ?? 4000}`})\n`);
} else if (usePostgres) {
    let pgProviderMod;
    try {
        pgProviderMod = await import('@memberjunction/postgresql-dataprovider');
    } catch {
        pgProviderMod = await import(path.resolve(here, '../../MJ/packages/PostgreSQLDataProvider/dist/index.js'));
    }
    const { PostgreSQLDataProvider, PostgreSQLProviderConfigData } = pgProviderMod;
    const { SetProvider, StartupManager } = await import('@memberjunction/core');
    const { UserCache, GetServerPrincipal } = await import('@memberjunction/generic-database-provider');
    const pgHost = process.env.PG_HOST || process.env.DB_HOST || 'localhost';
    const pgPort = Number(process.env.PG_PORT ?? process.env.DB_PORT ?? 5432);
    const pgDatabase = process.env.PG_DATABASE || process.env.DB_DATABASE;
    const pgUser = process.env.PG_USERNAME || process.env.DB_USERNAME || 'mj_admin';
    const pgPassword = process.env.PG_PASSWORD ?? process.env.DB_PASSWORD ?? '';
    const coreSchema = process.env.MJ_CORE_SCHEMA || '__mj';

    const pgProvider = new PostgreSQLDataProvider();
    const pgConfig = new PostgreSQLProviderConfigData(
        { Host: pgHost, Port: pgPort, Database: pgDatabase, User: pgUser, Password: pgPassword },
        coreSchema,
        1,
    );
    await pgProvider.Config(pgConfig);
    SetProvider(pgProvider);
    await UserCache.Instance.Refresh(pgProvider);
    const systemUser = GetServerPrincipal() ?? undefined;
    await StartupManager.Instance.Startup(false, systemUser, pgProvider);

    provider = pgProvider;
    user = UserCache.Users.find((u) => u?.Type?.trim().toLowerCase() === 'owner') ?? UserCache.Users[0];
    if (!user) throw new Error('No context user in UserCache (PostgreSQL).');
    closePool = async () => {
        const pgPool = pgProvider.DatabaseConnection;
        await pgPool?.end?.();
    };

    process.env.MJ_IT_LOAD_ENTITIES_SERVER = process.env.MJ_IT_LOAD_ENTITIES_SERVER ?? '1';
    await import('../packages/IntegrationTests/dist/index.js');
    console.log(`\n  Tasks integration (PostgreSQL → ${pgHost}:${pgPort}/${pgDatabase})\n`);
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
    closePool = async () => {
        if (pool) await pool.close();
    };

    process.env.MJ_IT_LOAD_ENTITIES_SERVER = process.env.MJ_IT_LOAD_ENTITIES_SERVER ?? '1';
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
if (closePool) await closePool();
process.exit(fail === 0 ? 0 : 1);
