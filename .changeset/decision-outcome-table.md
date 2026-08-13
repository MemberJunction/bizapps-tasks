---
"@mj-biz-apps/tasks-core": patch
---

Make the task decision outcomes a runtime table, so consuming apps stop hand-copying them.

`TaskDecisionOutcomeCode` was a bare union. Consumers need two runtime answers a type cannot give —
"do I accept this code?" and "does it mean approved?" — so bizapps-accounting answered both by
copying the literals into its own `Set`s. A `Set` holding a subset of a union is a legal value, so
widening the union here produced no error there: `tsc` returned 0 while the accounting approval gate
would have stopped counting a new approving outcome as approved, on the path that sends a journal
entry batch to the ERP.

Adds `TaskDecisionOutcomes` (the table), `TaskDecisionOutcomeCodes`, `IsTaskDecisionOutcomeCode`
(a narrowing guard for unvalidated input) and `IsApprovalOutcome`. `TaskDecisionOutcomeCode` is now
derived from the table, so it stays exactly what it was. `statusForOutcome` reads the table instead
of a `switch` that silently returned `undefined` for any outcome added later.

Additive — no existing caller changes. Adding an outcome now requires a seeded `TaskDecisionOutcome`
row alongside it, since `resolveOutcome` looks the code up in the database.
