-- Task Effort vs Estimate Rollup
-- Root tasks and their sub-trees with HoursEstimated, EstimatedMinutes, RolledUpLoggedMinutes,
-- VarianceMinutes, % of estimate, and AgentTotalCost.
WITH RootRollups AS (
    SELECT
        t.[RootParentID]                                                        AS [RootTaskID],
        SUM(ISNULL(t.[LoggedMinutes], 0))                                       AS [RolledUpLoggedMinutes],
        SUM(ISNULL(t.[AgentRunCount], 0))                                       AS [RolledUpAgentRunCount],
        SUM(ISNULL(t.[AgentCost], CAST(0 AS DECIMAL(19, 8))))                   AS [AgentTotalCost],
        SUM(ISNULL(t.[AgentTokens], 0))                                         AS [AgentTotalTokens],
        COUNT(*)                                                                AS [TaskCountInTree]
    FROM [__mj_BizAppsTasks].[vwTasks] t
    GROUP BY t.[RootParentID]
)
SELECT
    r.[ID]                                                                      AS [RootTaskID],
    r.[Name]                                                                    AS [RootTaskName],
    r.[CategoryID],
    r.[Category]                                                                AS [CategoryName],
    r.[Status],
    r.[HoursEstimated],
    CASE
        WHEN r.[HoursEstimated] IS NOT NULL
        THEN CAST(ROUND(r.[HoursEstimated] * 60.0, 0) AS INT)
        ELSE NULL
    END                                                                         AS [EstimatedMinutes],
    ISNULL(rr.[RolledUpLoggedMinutes], 0)                                       AS [RolledUpLoggedMinutes],
    CASE
        WHEN r.[HoursEstimated] IS NOT NULL
        THEN ISNULL(rr.[RolledUpLoggedMinutes], 0) - CAST(ROUND(r.[HoursEstimated] * 60.0, 0) AS INT)
        ELSE NULL
    END                                                                         AS [VarianceMinutes],
    CASE
        WHEN r.[HoursEstimated] IS NOT NULL AND r.[HoursEstimated] > 0
        THEN CAST(ROUND((ISNULL(rr.[RolledUpLoggedMinutes], 0) * 100.0) / (r.[HoursEstimated] * 60.0), 2) AS DECIMAL(10, 2))
        ELSE NULL
    END                                                                         AS [PercentOfEstimate],
    ISNULL(rr.[RolledUpAgentRunCount], 0)                                       AS [RolledUpAgentRunCount],
    ISNULL(rr.[AgentTotalCost], CAST(0 AS DECIMAL(19, 8)))                      AS [AgentTotalCost],
    ISNULL(rr.[AgentTotalTokens], 0)                                            AS [AgentTotalTokens],
    ISNULL(rr.[TaskCountInTree], 1)                                             AS [TaskCountInTree]
FROM [__mj_BizAppsTasks].[vwTasks] r
LEFT JOIN RootRollups rr ON rr.[RootTaskID] = r.[ID]
WHERE r.[ParentID] IS NULL
{% if RootTaskID %}
  AND r.[ID] = {{ RootTaskID | sqlString }}
{% endif %}
{% if CategoryID %}
  AND r.[CategoryID] = {{ CategoryID | sqlString }}
{% endif %}
{% if OnlyOverEstimate %}
  AND ({{ OnlyOverEstimate | sqlString }} NOT IN ('1', 'true', 'True', 'TRUE')
       OR (r.[HoursEstimated] IS NOT NULL AND ISNULL(rr.[RolledUpLoggedMinutes], 0) > CAST(ROUND(r.[HoursEstimated] * 60.0, 0) AS INT)))
{% endif %}
ORDER BY
    ISNULL(rr.[RolledUpLoggedMinutes], 0) DESC,
    r.[Name] ASC;
