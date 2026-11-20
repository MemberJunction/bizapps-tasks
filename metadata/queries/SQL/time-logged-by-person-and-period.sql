-- Time Logged by Person and Period
-- Daily and total minutes (billable vs non-billable) per person across a date range.
SELECT
    te.[PersonID],
    te.[Person]                                                             AS [PersonName],
    te.[WorkDate],
    COUNT(*)                                                                AS [EntryCount],
    SUM(te.[Minutes])                                                       AS [TotalMinutes],
    SUM(CASE WHEN te.[IsBillable] = 1 THEN te.[Minutes] ELSE 0 END)         AS [BillableMinutes],
    SUM(CASE WHEN te.[IsBillable] = 0 THEN te.[Minutes] ELSE 0 END)         AS [NonBillableMinutes]
FROM [__mj_BizAppsTasks].[vwTaskTimeEntries] te
WHERE 1 = 1
{% if StartDate %}
  AND te.[WorkDate] >= {{ StartDate | sqlDate }}
{% endif %}
{% if EndDate %}
  AND te.[WorkDate] <= {{ EndDate | sqlDate }}
{% endif %}
{% if PersonID %}
  AND te.[PersonID] = {{ PersonID | sqlString }}
{% endif %}
GROUP BY
    te.[PersonID],
    te.[Person],
    te.[WorkDate]
ORDER BY
    te.[WorkDate] DESC,
    te.[Person] ASC;
