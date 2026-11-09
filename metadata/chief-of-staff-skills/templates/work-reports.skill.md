# Work Reports (Daily 15Five Flow)

Use this skill whenever the user asks about daily or periodic 15Five work reports, when a recurring `daily-15five` wake runs, or when an inter-agent supervisor review request arrives.

## 1. Resolving People & Reporting Lines

- Every `MJ_BizApps_Tasks: Work Reports` record belongs to a `PersonID` (`MJ_BizApps_Common: People`).
- Resolve the user's `PersonID` from their linked `MJ: Users` record (`LinkedEntityRecordID` when `LinkedEntityID` points to `MJ_BizApps_Common: People`, falling back to `People.LinkedUserID = User.ID` where `Status = 'Active'`). Fail closed if no active `Person` record exists.
- Resolve the reporting line from core MJ's `MJ: Employees` table (`SupervisorID` / `SupervisorEmail`), matched to `MJ: Users` and `MJ_BizApps_Common: People` by case-insensitive email (`LOWER(Email)`). Do **not** invent a parallel supervisor table in BizApps Common.

## 2. Daily Drafting (`WorkstreamKey: "daily-15five"`)

1. **Zero-activity skip**: Call `Draft Work Report` (`Tasks.DraftWorkReport`) for `[PeriodStart, PeriodEnd]` (defaulting to the current day in the user's time zone). If the action returns `NO_ACTIVITY` (no tasks changed status, completed, logged time, received check-ins, or updated extension rows such as GitHub issues/PRs in the window), **stop immediately without creating a draft or waking the user**.
2. **Five-minute structure**: Keep every report concise enough to read in five minutes or less, organized into:
   - **Completed** (`Section = 'Completed'`) — tasks finished during the window.
   - **In Progress & Next** (`Section = 'InProgress'` / `'Next'`) — active tasks that moved forward and the concrete next step.
   - **Blockers** (`Section = 'Blockers'`) — blocked tasks or unresolved dependencies needing help.
   - **At-Risk Objectives** (`Section = 'AtRisk'`) — priority objectives (`HealthStatus IN ('AtRisk', 'OffTrack')` or overdue milestones) linked to the person's work.
3. **Human approval first**: `Draft Work Report` saves the report with `Status = 'Draft'`, creates `MJ_BizApps_Tasks: Work Report Items` linking each bullet to its `TaskID`, and opens an approval request for the author. Never mark a report `Submitted` without the author's explicit approval. Tell the user they can review, edit, and submit the draft on the **Reports** page of the Chief of Staff app.

## 3. Submitting & Supervisor Review

1. When the author approves (either in chat or on the **Reports** page), invoke `Submit Work Report` (`Tasks.SubmitWorkReport`). That transitions `Status` from `'Draft'` to `'Submitted'` and dispatches an inter-agent review request to the supervisor's Chief of Staff (`ForUserID` = supervisor's `MJ: Users.ID`).
2. When acting as the **supervisor's Chief of Staff** on a submitted report:
   - Read the `WorkReport` and its `WorkReportItem` links alongside the supervisor's priority objectives and team milestones.
   - Draft constructive, specific feedback highlighting alignment with team priorities, unblocking actions the supervisor can take, and recognition of completed work.
   - Present the drafted feedback to the supervisor in their approvals queue / **Reports -> Team Reviews** tab for human review. Never send supervisor feedback without the supervisor's approval.
3. Once the supervisor edits and approves the feedback, invoke `Review Work Report` (`Tasks.ReviewWorkReport`) to stamp `SupervisorFeedback`, `ReviewedByPersonID`, `ReviewedAt`, and `Status = 'Reviewed'`, delivering the feedback onto the report and back to the author's Chief of Staff conversation.
