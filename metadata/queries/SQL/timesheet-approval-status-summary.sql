-- Timesheet Approval Status Summary
-- Timesheets and their latest-round approval parts with worker, period, status,
-- approved/pending/rejected part counts, and assigned approvers.
WITH LatestRound AS (
    SELECT
        ta.[TimesheetID],
        MAX(ta.[SubmissionRound]) AS [MaxRound]
    FROM [__mj_BizAppsTasks].[TimesheetApproval] ta
    GROUP BY ta.[TimesheetID]
),
PartAgg AS (
    SELECT
        ta.[TimesheetID],
        ta.[SubmissionRound],
        COUNT(*)                                                                AS [TotalParts],
        SUM(CASE WHEN ta.[Status] = 'Approved' THEN 1 ELSE 0 END)               AS [ApprovedParts],
        SUM(CASE WHEN ta.[Status] = 'Pending'  THEN 1 ELSE 0 END)               AS [PendingParts],
        SUM(CASE WHEN ta.[Status] = 'Rejected' THEN 1 ELSE 0 END)               AS [RejectedParts]
    FROM [__mj_BizAppsTasks].[TimesheetApproval] ta
    INNER JOIN LatestRound lr
        ON lr.[TimesheetID] = ta.[TimesheetID]
       AND lr.[MaxRound]    = ta.[SubmissionRound]
    GROUP BY
        ta.[TimesheetID],
        ta.[SubmissionRound]
)
SELECT
    ts.[ID]                                                                     AS [TimesheetID],
    ts.[PersonID],
    ts.[Person]                                                                 AS [WorkerName],
    ts.[PeriodStart],
    ts.[PeriodEnd],
    ts.[Status],
    ts.[SubmittedAt],
    ts.[TotalMinutes],
    ts.[BillableMinutes],
    ISNULL(pa.[SubmissionRound], 0)                                             AS [SubmissionRound],
    ISNULL(pa.[TotalParts], 0)                                                  AS [TotalParts],
    ISNULL(pa.[ApprovedParts], 0)                                               AS [ApprovedParts],
    ISNULL(pa.[PendingParts], 0)                                                AS [PendingParts],
    ISNULL(pa.[RejectedParts], 0)                                               AS [RejectedParts]
FROM [__mj_BizAppsTasks].[vwTimesheets] ts
LEFT JOIN PartAgg pa ON pa.[TimesheetID] = ts.[ID]
WHERE 1 = 1
{% if PeriodStart %}
  AND ts.[PeriodEnd] >= {{ PeriodStart | sqlDate }}
{% endif %}
{% if PeriodEnd %}
  AND ts.[PeriodStart] <= {{ PeriodEnd | sqlDate }}
{% endif %}
{% if Status %}
  AND ts.[Status] = {{ Status | sqlString }}
{% endif %}
{% if ApproverPersonID %}
  AND EXISTS (
      SELECT 1
      FROM [__mj_BizAppsTasks].[TimesheetApproval] ta2
      INNER JOIN LatestRound lr2
          ON lr2.[TimesheetID] = ta2.[TimesheetID]
         AND lr2.[MaxRound]    = ta2.[SubmissionRound]
      INNER JOIN [__mj_BizAppsTasks].[TaskAssignment] asgn
          ON asgn.[TaskID] = ta2.[ApprovalTaskID]
      WHERE ta2.[TimesheetID]         = ts.[ID]
        AND asgn.[AssigneeRecordID]   = {{ ApproverPersonID | sqlString }}
  )
{% endif %}
ORDER BY
    ts.[PeriodStart] DESC,
    ts.[Person] ASC;
