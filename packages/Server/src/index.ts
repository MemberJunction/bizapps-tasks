/**
 * BizApps Tasks Server Bootstrap
 * Import this package and call LoadBizAppsTasksServer() to register
 * all Tasks entity classes, actions, and services with MJ.
 */
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// Import generated packages to trigger @RegisterClass decorators
import '@mj-biz-apps/tasks-entities';
import '@mj-biz-apps/tasks-actions';

// Import core services to trigger any class registrations
import '@mj-biz-apps/tasks-core';

// Import notification handler
import { InitTaskNotificationHandler } from './event-handlers/TaskNotificationHandler.js';

// Import scheduled job drivers (registers via @RegisterClass for scheduling engine discovery)
import './scheduled-jobs/OverdueTaskNotificationJob.js';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

/**
 * Resolver paths for TypeGraphQL schema building.
 * Points to generated GraphQL resolvers (created by CodeGen).
 */
export const RESOLVER_PATHS: string[] = [
    resolve(__dirname, 'resolvers/*.js'),
    resolve(__dirname, 'generated/*.js'),
];

/**
 * Bootstrap function — call this from MJAPI's index.ts to register
 * all Tasks classes and services.
 *
 * Static imports above ensure all @RegisterClass decorators fire.
 * This function exists as the entry point for DynamicPackageLoader.
 */
export function LoadBizAppsTasksServer(): void {
    InitTaskNotificationHandler();
    console.log('[BizAppsTasks] Server loaded');
}
