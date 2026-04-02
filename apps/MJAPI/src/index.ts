/**
 * BizAppsTasks Test Harness — MJAPI Server
 * Boots an MJ API server with BizAppsTasks + BizAppsCommon packages loaded.
 */
import { createMJServer } from '@memberjunction/server-bootstrap';

// Import pre-built MJ class registrations manifest
import '@memberjunction/server-bootstrap/mj-class-registrations';

// Import BizAppsCommon server (registers common entities/resolvers)
import { RESOLVER_PATHS as COMMON_RESOLVER_PATHS } from '@mj-biz-apps/common-server';

// Import BizAppsTasks server (registers tasks entities/resolvers)
import { RESOLVER_PATHS as TASKS_RESOLVER_PATHS } from '@mj-biz-apps/tasks-server';

// Merge resolver paths from both packages
const resolverPaths = [...COMMON_RESOLVER_PATHS, ...TASKS_RESOLVER_PATHS];

// Start the server
createMJServer({ resolverPaths }).catch(console.error);
