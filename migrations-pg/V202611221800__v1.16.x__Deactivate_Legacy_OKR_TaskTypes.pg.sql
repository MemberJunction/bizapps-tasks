-- ============================================================================
-- MemberJunction PostgreSQL Migration
-- Counterpart of migrations/V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.sql
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS __mj_BizAppsTasks;
SET search_path TO __mj_BizAppsTasks, public;
SET standard_conforming_strings = on;

UPDATE __mj_BizAppsTasks."TaskType"
   SET "IsActive" = FALSE,
       "Description" = 'Legacy strategic objective task type superseded by Planning-owned Priority Tasks.'
 WHERE ("ID" = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01'::uuid OR "Code" = 'PRIORITY_OBJECTIVE')
   AND ("IsActive" = TRUE OR "Description" IS DISTINCT FROM 'Legacy strategic objective task type superseded by Planning-owned Priority Tasks.');

UPDATE __mj_BizAppsTasks."TaskType"
   SET "IsActive" = FALSE,
       "Description" = 'Legacy measurable key result task type superseded by generic measurable tasks and Planning-owned Key Results.'
 WHERE ("ID" = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02'::uuid OR "Code" = 'KEY_RESULT')
   AND ("IsActive" = TRUE OR "Description" IS DISTINCT FROM 'Legacy measurable key result task type superseded by generic measurable tasks and Planning-owned Key Results.');
