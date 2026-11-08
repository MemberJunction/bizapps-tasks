-- Logged Time by Linked Record
-- Total human minutes, billable minutes, and AI agent cost across all tasks
-- linked to an external entity/record via TaskLink (including descendant sub-tasks).
WITH LinkedTasks AS (
    SELECT DISTINCT
        tl.[EntityID],
        tl.[Entity]                                                             AS [EntityName],
        tl.[RecordID],
        t.[ID]                                                                  AS [TaskID],
        t.[Name]                                                                AS [TaskName],
        t.[AgentRunCount],
        t.[AgentCost],
        t.[AgentTokens]
    FROM [__mj_BizAppsTasks].[vwTaskLinks] tl
    INNER JOIN [__mj_BizAppsTasks].[vwTasks] t
        ON t.[ID] = tl.[TaskID]
        OR t.[RootParentID] = tl.[TaskID]
    WHERE 1 = 1
    {% if EntityName %}
      AND tl.[Entity] = {{ EntityName | sqlString }}
    {% endif %}
    {% if RecordID %}
      AND tl.[RecordID] = {{ RecordID | sqlString }}
    {% endif %}
),
FilteredEntries AS (
    SELECT
        te.[TaskID],
        SUM(te.[Minutes])                                                       AS [TotalMinutes],
        SUM(CASE WHEN te.[IsBillable] = 1 THEN te.[Minutes] ELSE 0 END)         AS [BillableMinutes],
        COUNT(*)                                                                AS [EntryCount]
    FROM [__mj_BizAppsTasks].[TaskTimeEntry] te
    WHERE 1 = 1
    {% if StartDate %}
      AND te.[WorkDate] >= {{ StartDate | sqlDate }}
    {% endif %}
    {% if EndDate %}
      AND te.[WorkDate] <= {{ EndDate | sqlDate }}
    {% endif %}
    GROUP BY te.[TaskID]
)
SELECT
    lt.[EntityID],
    lt.[EntityName],
    lt.[RecordID],
    COUNT(DISTINCT lt.[TaskID])                                                 AS [TaskCount],
    SUM(ISNULL(fe.[EntryCount], 0))                                             AS [TimeEntryCount],
    SUM(ISNULL(fe.[TotalMinutes], 0))                                           AS [TotalMinutes],
    SUM(ISNULL(fe.[BillableMinutes], 0))                                        AS [BillableMinutes],
    SUM(ISNULL(lt.[AgentRunCount], 0))                                          AS [AgentRunCount],
    SUM(ISNULL(lt.[AgentCost], CAST(0 AS DECIMAL(19, 8))))                      AS [AgentTotalCost],
    SUM(ISNULL(lt.[AgentTokens], 0))                                            AS [AgentTotalTokens]
FROM LinkedTasks lt
LEFT JOIN FilteredEntries fe ON fe.[TaskID] = lt.[TaskID]
GROUP BY
    lt.[EntityID],
    lt.[EntityName],
    lt.[RecordID]
ORDER BY
    SUM(ISNULL(fe.[TotalMinutes], 0)) DESC,
    lt.[EntityName] ASC,
    lt.[RecordID] ASC;
