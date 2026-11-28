-- Agent Effort and Cost by Task
-- Tasks with linked AI agent runs (deduplicated against ancestor runs on the same task),
-- total tokens, total cost, and wall-clock seconds.
WITH DedupedRuns AS (
    SELECT
        tar.[ID]                                                                AS [TaskAgentRunID],
        tar.[TaskID],
        t.[Name]                                                                AS [TaskName],
        t.[RootParentID],
        tar.[AIAgentRunID],
        tar.[Role],
        r.[AgentID],
        r.[Agent]                                                               AS [AgentName],
        r.[Status]                                                              AS [RunStatus],
        r.[StartedAt],
        r.[CompletedAt],
        CASE
            WHEN r.[CompletedAt] IS NOT NULL AND r.[CompletedAt] >= r.[StartedAt]
            THEN DATEDIFF(SECOND, r.[StartedAt], r.[CompletedAt])
            ELSE 0
        END                                                                     AS [DurationSeconds],
        COALESCE(r.[TotalTokensUsedRollup], r.[TotalTokensUsed], 0)             AS [TotalTokensUsed],
        COALESCE(r.[TotalCostRollup], r.[TotalCost], CAST(0 AS DECIMAL(19, 8))) AS [TotalCost]
    FROM [__mj_BizAppsTasks].[TaskAgentRun] tar
    INNER JOIN [__mj_BizAppsTasks].[vwTasks] t ON t.[ID] = tar.[TaskID]
    INNER JOIN [__mj].[vwAIAgentRuns] r ON r.[ID] = tar.[AIAgentRunID]
    WHERE NOT EXISTS (
        SELECT 1
        FROM [__mj_BizAppsTasks].[TaskAgentRun] tar2
        WHERE tar2.[TaskID]       = tar.[TaskID]
          AND tar2.[AIAgentRunID] <> tar.[AIAgentRunID]
          AND r.[ParentRunIDPath] LIKE '%/' + CAST(tar2.[AIAgentRunID] AS NVARCHAR(36)) + '/%'
    )
    {% if StartDate %}
      AND CAST(r.[StartedAt] AS DATE) >= {{ StartDate | sqlDate }}
    {% endif %}
    {% if EndDate %}
      AND CAST(r.[StartedAt] AS DATE) <= {{ EndDate | sqlDate }}
    {% endif %}
    {% if AgentID %}
      AND r.[AgentID] = {{ AgentID | sqlString }}
    {% endif %}
    {% if RootTaskID %}
      AND t.[RootParentID] = {{ RootTaskID | sqlString }}
    {% endif %}
)
SELECT
    d.[TaskID],
    d.[TaskName],
    d.[RootParentID],
    COUNT(*)                                                                    AS [CountedAgentRunCount],
    SUM(d.[DurationSeconds])                                                    AS [WallClockSeconds],
    SUM(d.[TotalTokensUsed])                                                    AS [TotalTokensUsed],
    SUM(d.[TotalCost])                                                          AS [TotalCost]
FROM DedupedRuns d
GROUP BY
    d.[TaskID],
    d.[TaskName],
    d.[RootParentID]
ORDER BY
    SUM(d.[TotalCost]) DESC,
    d.[TaskName] ASC;
