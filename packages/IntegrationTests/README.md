# @mj-biz-apps/tasks-integration-tests

GraphQL-wire integration checks for BizApps Tasks. **Private.**

`bootstrapIntegrationClient` → `GraphQLDataProvider` → MJAPI. No SQL pool.

Types, roles, and decision outcomes are **looked up** from shipped metadata. People and seed
tasks are upserted through typed `TaskEntity` / Person subclasses.

```bash
pnpm --filter @mj-biz-apps/tasks-integration-tests build
GRAPHQL_PORT=4103 node test-harnesses/integration.mjs
```
