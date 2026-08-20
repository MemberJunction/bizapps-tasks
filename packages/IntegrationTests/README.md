# @mj-biz-apps/tasks-integration-tests

Comprehensive integration check bundles for BizApps Tasks dispatched by `mj test` or standalone test runners.

## Test Bundles & Scenarios

| Bundle | Test ID | Description |
| :--- | :--- | :--- |
| `task-world` | `TSK-00` | Establishes deterministic baseline data: 15+ multi-domain categories, 8 people, 6 task types with codes, dynamic task type statuses, candidate actions (`Calculate Expression`, `Color Converter`), and 3 divergent project hierarchies (Software Dev, Corporate HQ Construction, Heritage Documentary Film). |
| `task-hierarchy` | `TSK-01` | Evaluates parent/child task creation, depth querying, and multi-domain hierarchy integrity. |
| `task-dependencies` | `TSK-02` | Tests `FinishToStart` dependency graph links and critical path chains. |
| `task-assignments` | `TSK-03` | Evaluates polymorphic task assignments (People and AI Agents) across distinct operational roles. |
| `task-decisions` | `TSK-04` | Tests formal task decisions, sign-off outcomes, and approver audit tracking. |
| `task-templates` | `TSK-05` | Evaluates task template instantiation with category and schedule offsets. |
| `task-statuses` | `TSK-06` | Tests dynamic `TaskTypeStatus` defaulting on task creation, stage transitions across `MacroStatus` values, and terminal auto-completion. |
| `task-action-hooks` | `TSK-07` | Validates non-blocking event-driven Action hook dispatch (`OnCreate`, `OnStatusChange`, `OnEnterStatus`, `OnExitStatus`) with universal task payload. |

## Running Tests

```bash
# Build integration tests bundle
pnpm --filter @mj-biz-apps/tasks-integration-tests build

# Run unit / registration tests
pnpm --filter @mj-biz-apps/tasks-integration-tests test
```
