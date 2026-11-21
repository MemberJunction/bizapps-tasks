# Work Reports (Daily 15Five Flow)

Use this skill whenever the user asks about daily or periodic 15Five work reports, when a recurring `daily-15five` wake runs, or when an inter-agent supervisor review request arrives.

## 1. Typed Tools Only (Never Generic CRUD or Raw SQL)

All identity resolution (caller -> `People` and `MJ: Employees.SupervisorID` reporting lines) happens automatically in code inside these typed actions — never look up `PersonID` or query tables directly:

- **`List Work Reports`**: Discover work reports by `Scope` (`Mine`, `TeamPendingReview`, `TeamRecent`), optional `Status` (`Draft`, `Submitted`, `Reviewed`), `Since`, and `Limit`.
- **`Get Work Report`**: Load one work report's full header, markdown body, supervisor feedback, and ordered `Work Report Items` (used by both authors reviewing a draft and supervisors reviewing a teammate's submission).
- **`Draft Work Report`**: Collect task activity, check-ins, and updates for `[PeriodStart, PeriodEnd]` (defaulting to today in the user's local timezone) and create or refresh a `Draft` report.
- **`Submit Work Report`**: Transition an author-approved `Draft` report to `Submitted` and notify the supervisor's Chief of Staff.
- **`Review Work Report`**: Record supervisor-approved feedback on a `Submitted` report and transition it to `Reviewed`.

## 2. Daily Drafting (`WorkstreamKey: "daily-15five"`)

1. **Zero-activity skip**: Call **`Draft Work Report`** for the requested window (defaulting to the current local day). If it returns **`NO_ACTIVITY`**, stop immediately without creating a draft or waking the user.
2. **Five-minute structure**: Keep every report crisp and scannable in five minutes or less across **Completed**, **In Progress & Next**, **Blockers**, and **At-Risk Objectives**.
3. **Human approval first**: Never call **`Submit Work Report`** without the author's explicit approval. Present the draft summary (loaded via **`Get Work Report`** if needed) and remind the user they can also review, edit, and submit it on the **Reports** page of the Chief of Staff app.

## 3. Submitting & Supervisor Review

1. Once the author approves (with any requested edits to `Title` or `Body`), invoke **`Submit Work Report`**.
2. When acting as the **supervisor's Chief of Staff** on a submitted report:
   - Call **`List Work Reports`** (`Scope = 'TeamPendingReview'`) to locate pending submissions and **`Get Work Report`** to read the full report and linked items.
   - Draft concise, constructive feedback highlighting alignment with team priorities, unblocking moves the supervisor can take, and recognition of completed work.
   - Present the drafted feedback to the supervisor for approval. Never call **`Review Work Report`** without the supervisor's explicit sign-off.
3. Once approved, invoke **`Review Work Report`** with `WorkReportID` and `SupervisorFeedback`.

## 4. Handling Canonical Result Codes

- **`NO_ACTIVITY`**: Stop quietly — no draft needed for an inactive window.
- **`NO_PERSON_RECORD`**: Explain that the user's account is not linked to an active `People` record.
- **`PERMISSION_DENIED`**: Only the report author may draft/submit their own report, and only a mapped supervisor in `MJ: Employees` (or an administrator) may review it.
- **`NOT_FOUND` / `VALIDATION_ERROR`**: Confirm the report ID and lifecycle status (`Draft` before submit, `Submitted` before review).
- **`POLICY_DENIED` / `POLICY_DEFERRED` / `APPROVAL_REQUIRED`**: Honor the user's Agent User Policy without attempting workarounds.
