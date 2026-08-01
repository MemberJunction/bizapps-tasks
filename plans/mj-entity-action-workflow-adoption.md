# Adopting MJ's Entity Action workflow extensions

> **Status:** Tracking doc — nothing to build here yet.
> **Upstream:** MemberJunction/MJ **[#3408](https://github.com/MemberJunction/MJ/pull/3408)** · [design plan](https://github.com/MemberJunction/MJ/blob/claude/sales-deal-management-app-ueporb/plans/entity-action-workflow-extensions.md)
> **Blocked on:** that PR merging *and* its engine work landing (the PR ships schema + plan only).

---

## 1. What is changing in MJ core

`EntityAction` — MJ's generalized hook for running an Action off an entity's
create / update / delete / validate — is becoming the **workflow-hook substrate for every app on
the platform**, so no app needs to invent its own.

It already does more than its schema suggests, and this is worth knowing regardless of this PR:

| Invocation | Where it fires | Semantics |
|---|---|---|
| `Validate` | `OnValidateBeforeSave` | **A real blocking gate** — a non-`Success` result fails the save |
| `Before*` | `OnBeforeSaveExecute` | Awaited, result discarded (cannot veto) |
| `After*` | `OnAfterSaveExecute` | Fire-and-forget |

And because **`Execute Agent` is just an Action**, any binding can already run an agent — a
deterministic **flow agent** (visual editor, `Action`/`Prompt`/`Sub-Agent`/`ForEach`/`While` steps,
per-step retry and error behaviour) or a **loop agent** where judgement is genuinely needed. The
house shape is a flow agent with a `Sub-Agent` step calling a loop agent.

**What #3408 adds:**

- **`EntityAction.ScopeEntityID` + `ScopeRecordID`** — bind a workflow to *one configuration record*
  rather than to every record of an entity. This is the important one: it means **no app ever grows
  a column per type per event**, and a configuration record can surface "the workflows bound to me"
  as a real relationship instead of something buried in filter code.
- **`EntityAction.Sequence`** — deterministic ordering when several bindings share an event.
- **`EntityActionParam.ValueType = 'Entity Object Data'`** — passes `entity.GetAll()` instead of the
  live `BaseEntity`. Use it for anything that serializes, above all `Execute Agent`'s `Data` payload:
  a `BaseEntity` serializes to `{}` because its fields are getters, so the agent silently receives
  an empty payload with no error anywhere.
- Two seeded reusable `ActionFilter`s — **"field changed"** and **"field changed *to* value"** — so
  transition detection stops being hand-rolled. Without them `AfterUpdate` fires on *every* update,
  and "status *is* X" instead of "status *changed to* X" re-fires on every later save.
- `After*` routed through `QueueManager` so failures are durable and retryable rather than logged
  and swallowed.

**Authoring is pure metadata** — `metadata/entity-actions/`, with `relatedEntities` for invocations,
filters and params. No schema and no code in the consuming app.

---

## 2. What this means for BizApps Tasks

Tasks is the closest app to this change, because **it already has its own version of it**:
`TaskType.OnAssignActionID` / `OnCompleteActionID` / `OnRejectActionID` / `OnCancelActionID` /
`OnOverdueActionID` / `OnPercentChangeActionID`, fired by `TaskNotificationHandler`.

That mechanism is fine and shipping. The recommendation is **not** to remove it — it is published,
and per-`TaskType` hooks are a genuinely convenient shorthand. The recommendation is to stop
extending it, and to let `EntityAction` be the general path.

Concretely: **do not add six `On*AgentID` columns.** `Execute Agent` already lets the existing
`On*ActionID` columns run an agent, and `EntityAction` covers everything they do not.

## 3. Suggested bindings

| Entity + invocation | Scope | Work | Purpose |
|---|---|---|---|
| `TaskDecision` · `AfterCreate` | a `TaskType` | Flow agent | **The one that matters** — see §4 |
| `Task` · `AfterUpdate` (status changed to a terminal value) | a `TaskType` | Action or agent | Chain to the next stage of a process |
| `Task` · `Validate` | a `TaskType` | Action | Refuse completion until required fields / sub-tasks / dependencies are satisfied — a gate the current hooks structurally cannot provide |
| `TaskAssignment` · `AfterCreate` | a `TaskRole` | Action | Role-specific onboarding or notification |

## 4. Overlap to resolve — and two real bugs found while reading

**The overlap resolves itself, pleasantly.** `TaskDecision` is its own row carrying `OutcomeID` →
`TaskDecisionOutcome` (with `Code` and `IsTerminal`). So an `EntityAction` on **`TaskDecision`
`AfterCreate`, filtered on `OutcomeID`,** gives the full decision outcome natively — including
"Approved With Conditions" and any other outcome an operator adds — with no change to this repo.

That matters because of the first bug below.

**Bug 1 — the decision outcome never reaches the hook.** `TaskNotificationHandler` picks
`OnRejectActionID` vs `OnCancelActionID` from a boolean, so a three-outcome decision collapses to
two hooks and `TaskDecisionOutcome.Code` is discarded. The `TaskDecision` `AfterCreate` binding
above sidesteps this entirely; fixing the native hooks is optional once that exists.

**Bug 2 — hooks cannot tell what the task was about.** `invokeTaskTypeAction` passes exactly three
params: `TaskID`, `TaskName`, `Status`. **`TaskLink` is never passed**, so an action fired by a task
completing has no idea which Deal, Contract or Committee the task was for, and has to re-query.
Worth fixing independently of #3408 — pass the links.

**Also worth fixing:** `TaskNotificationHandler` uses `await import('@memberjunction/actions')` with
the comment *"to avoid hard dependency"*. That is the exact anti-pattern MJ's own guidance calls out,
and the same shape as the MJCLI `mj app` `ERR_MODULE_NOT_FOUND` production bug — the import works in
dev and fails at runtime when the dependency is genuinely absent. Should be a static import with a
declared dependency.

**One documented behaviour, not a bug:** task hooks are post-commit and non-blocking — *"a failed
action does NOT roll back the task transition."* Correct for notification, wrong for
approval-as-precondition, and the natural assumption is the opposite. Callers must check task state
themselves; `EntityAction`'s `Validate` on the *subject* record is the gate.

---

## 5. What to do now

**Nothing.** This is a tracking doc so the idea is not lost and so this repo's plans reflect where
workflow hooks are going. When #3408 merges and its engine work lands:

1. Confirm the bindings in §3 are still the right ones.
2. Author them as metadata under `metadata/entity-actions/`.
3. Build the flow agents they dispatch to.
4. Delete this file, or fold it into the repo's main plan.

## 6. Two rules to carry into the design

- **Synchronous bindings should be Actions, never agents.** `Validate` and `Before*` run inside the
  caller's transaction. A loop agent's duration is unbounded and holding a transaction open for it
  is not acceptable. Agents belong on `After*`, which is async.
- **A flow agent should create human work and finish** — it should not hold a run open waiting for
  a person. Use `MJ: AI Agent Requests` when the answer resumes the same run (minutes to hours), and
  a **bizapps-tasks** Task when it is durable, assignable work someone owns (days to weeks).

---
_Generated by [Claude Code](https://claude.ai/code)_
