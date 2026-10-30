Use this skill for the user's priorities, objectives, milestones, assignments and to-dos. They live in the BizApps Tasks app, not in core MemberJunction. Use it whenever the user asks about their priorities or OKRs, wants to track or assign work, asks what is on their list, or asks to be reminded of something that should stay on their list.

### 1. Find the user's person first

Tasks are owned by a **person** (`MJ_BizApps_Common: People`), not by the MJ user. Resolve **MyPersonID** once per run, before reading or writing tasks:

- `SELECT ID, FirstName, LastName FROM [__mj_BizAppsCommon].[vwPeople] WHERE LinkedUserID = '<the current user's ID>' AND Status = 'Active'`. The current user's ID and email are in your instructions.
- If that returns nothing, try `WHERE LOWER(Email) = LOWER('<the current user's email>') AND Status = 'Active'`.
- **No person found**: tell the user plainly that no People record is linked to their login, so their priorities cannot be tracked yet. Offer to create one. If they agree, call `Create Record` on `MJ_BizApps_Common: People` with `FirstName`, `LastName`, `Email` and `LinkedUserID` (the user's ID). If that fails with `PERMISSION_DENIED`, ask them to have an administrator add or link their People record. Never invent a person ID.

### 2. Reading tasks

- Always use the entity name `MJ_BizApps_Tasks: Tasks` with `Create Record`, `Update Record` and `Get Record`. **Never `MJ: Tasks`**: that is MemberJunction's internal workflow engine, not a to-do list.
- Query `[__mj_BizAppsTasks].[vwTasks]`. Useful columns: `ID`, `Name`, `Description`, `Type` (the type name), `TypeID`, `ParentID`, `RootParentID`, `Status` (`Open`, `InProgress`, `Blocked`, `Completed`, `Cancelled`), `Priority` (`Critical`, `High`, `Medium`, `Low`), `DueAt`, `CompletedAt`, `PercentComplete`, `HealthStatus` (`OnTrack`, `AtRisk`, `OffTrack`, `Completed`, `Paused`), `ConfidenceScore` (0-100), `PlanningPeriod`, `BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure`, `MetricDirection`, `CheckInCadence`, `LastCheckInAt`, `NextCheckInDueAt`, `CreatedByPersonID`, `CreatedByPerson`.
- Task types (`[__mj_BizAppsTasks].[vwTaskTypes]`): `Priority Objective`, `Key Result`, `Deliverable`, `Action Item`, `Follow-up`, `General`, `Approval Request`. Look up the IDs once per run with `SELECT ID, Name FROM [__mj_BizAppsTasks].[vwTaskTypes]`.
- **Scope every query to the user.** Their tasks are the ones they created (`CreatedByPersonID = MyPersonID`) or are assigned to, plus everything under a root objective they own. Assignments are `[__mj_BizAppsTasks].[vwTaskAssignments]` rows whose `AssigneeEntityID` is the `MJ: Entities` ID of `MJ_BizApps_Common: People` and whose `AssigneeRecordID` is the person's ID. There is no `PersonID` column on assignments.
- Progress updates are `[__mj_BizAppsTasks].[vwTaskCheckIns]` (`MJ_BizApps_Tasks: Task Check Ins`).

### 3. Priorities and objectives

- An objective is a root task (no `ParentID`) of type `Priority Objective`, usually with `PlanningPeriod` and `HealthStatus`. Its milestones and key results are child tasks (`ParentID` = the objective).
- A measurable objective or key result carries `BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure` and `MetricDirection` (`Up` or `Down`).
- **Every task you create for the user carries their person**: pass `CreatedByPersonID: MyPersonID` in the `Fields` of `Create Record`. Without it the task is invisible on their Priorities page.
- Create a `MJ_BizApps_Tasks: Task Assignments` row only when assigning work to someone other than the creator.
- The priorities the user names during onboarding still go in their policy (`InstructionsOverride`). When they want them tracked, also create the objectives here.

### 4. To-dos and reminders

- A request like *"add 'send the deck to Amith' to my list"* or *"remind me to call Mom on Wednesday"* is a **to-do**, not an objective. Create one `MJ_BizApps_Tasks: Tasks` row: a short imperative `Name`, `Status: "Open"`, `DueAt` when a date or time was given (a day with no time means 9:00 AM in the user's time zone), `CreatedByPersonID: MyPersonID`, `TypeID` of the `General` type (or `Follow-up` / `Action Item` when that fits), and **no `ParentID`, no `HealthStatus`, no `PlanningPeriod`**.
- A dated reminder also gets a one-shot wake, exactly as the core instructions describe. When that wake runs, reply with the reminder only; do not mark the task done.
- Marking a to-do done is `Update Record` with `Status: "Completed"`.
- Tell the user these appear on the **Priorities & To-dos** page of the Chief of Staff app, where they can tick them off.
