-- =============================================================================
-- Migration: V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.sql
-- Description: Mark legacy OKR TaskType records (PRIORITY_OBJECTIVE and
--              KEY_RESULT) inactive (IsActive = 0) for existing 1.x upgrades
--              to match metadata/task-types/.task-types.json, while strictly
--              preserving all existing OKR/metric columns on [Task].
-- =============================================================================

UPDATE [${flyway:defaultSchema}].[TaskType]
   SET [IsActive] = 0,
       [Description] = N'Legacy strategic objective task type superseded by Planning-owned Priority Tasks.'
 WHERE ([ID] = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01' OR [Code] = N'PRIORITY_OBJECTIVE')
   AND ([IsActive] = 1 OR [Description] IS NULL OR [Description] <> N'Legacy strategic objective task type superseded by Planning-owned Priority Tasks.');
GO

UPDATE [${flyway:defaultSchema}].[TaskType]
   SET [IsActive] = 0,
       [Description] = N'Legacy measurable key result task type superseded by generic measurable tasks and Planning-owned Key Results.'
 WHERE ([ID] = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02' OR [Code] = N'KEY_RESULT')
   AND ([IsActive] = 1 OR [Description] IS NULL OR [Description] <> N'Legacy measurable key result task type superseded by generic measurable tasks and Planning-owned Key Results.');
GO
