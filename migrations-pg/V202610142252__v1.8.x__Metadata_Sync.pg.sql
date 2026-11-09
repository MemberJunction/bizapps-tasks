-- =============================================================================================
-- PostgreSQL counterpart of V202610142252__v1.8.x__Metadata_Sync.sql -- BizApps Tasks v1.8.x Metadata_Sync
-- =============================================================================================
-- Same records, same values, same order as the T-SQL file; see its header for what ships and why.
--
-- HOW IT WAS MADE
--   * `mj sql-convert --from tsql --to postgres` (MJ CLI 6.1.5) on the push log the T-SQL file
--     was generated from, the ML bench removed as in the T-SQL file. Each record is a DO block
--     that calls the core or app function, in whichever signature the host has (jsonb or named
--     parameters).
--   * The converter does not translate the lookups and guards the T-SQL file adds, so they are
--     written here by hand from the T-SQL ones, block for block:
--       - SELECT TOP 1 @x = [ID] ... ORDER BY ... becomes
--         p_x := COALESCE((SELECT "ID" ... ORDER BY ... LIMIT 1), p_x), which keeps the literal
--         ID when nothing matches, as the T-SQL assignment does.
--       - IF <guard> EXEC ... becomes IF <guard> THEN <call> END IF.
--   * Every string value is taken verbatim from the T-SQL file: the converter rewrites T-SQL
--     inside string literals.
--   * Core calls use ${mjSchema}; this app's schema is written as the converter emits it.
-- =============================================================================================

SET standard_conforming_strings = on;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_079c88df8ac0 UUID;
  p_Name_079c88df8ac0 VARCHAR(255);
  p_NameSuffix_079c88df8ac0 VARCHAR(255);
  p_Description_079c88df8ac0 TEXT;
  p_AutoUpdateDescription_079c88df8ac0 BOOLEAN;
  p_BaseView_079c88df8ac0 VARCHAR(255);
  p_BaseViewGenerated_079c88df8ac0 BOOLEAN;
  p_VirtualEntity_079c88df8ac0 BOOLEAN;
  p_TrackRecordChanges_079c88df8ac0 BOOLEAN;
  p_AuditRecordAccess_079c88df8ac0 BOOLEAN;
  p_AuditViewRuns_079c88df8ac0 BOOLEAN;
  p_IncludeInAPI_079c88df8ac0 BOOLEAN;
  p_AllowAllRowsAPI_079c88df8ac0 BOOLEAN;
  p_AllowUpdateAPI_079c88df8ac0 BOOLEAN;
  p_AllowCreateAPI_079c88df8ac0 BOOLEAN;
  p_AllowDeleteAPI_079c88df8ac0 BOOLEAN;
  p_CustomResolverAPI_079c88df8ac0 BOOLEAN;
  p_AllowUserSearchAPI_079c88df8ac0 BOOLEAN;
  p_FullTextSearchEnabled_079c88df8ac0 BOOLEAN;
  p_FullTextCatalog_079c88df8ac0 VARCHAR(255);
  p_FullTextCatalogGenerated_079c88df8ac0 BOOLEAN;
  p_FullTextIndex_079c88df8ac0 VARCHAR(255);
  p_FullTextIndexGenerated_079c88df8ac0 BOOLEAN;
  p_FullTextSearchFunction_079c88df8ac0 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_079c88df8ac0 BOOLEAN;
  p_UserViewMaxRows_079c88df8ac0 INTEGER;
  p_spCreate_079c88df8ac0 VARCHAR(255);
  p_spUpdate_079c88df8ac0 VARCHAR(255);
  p_spDelete_079c88df8ac0 VARCHAR(255);
  p_spCreateGenerated_079c88df8ac0 BOOLEAN;
  p_spUpdateGenerated_079c88df8ac0 BOOLEAN;
  p_spDeleteGenerated_079c88df8ac0 BOOLEAN;
  p_CascadeDeletes_079c88df8ac0 BOOLEAN;
  p_DeleteType_079c88df8ac0 VARCHAR(10);
  p_AllowRecordMerge_079c88df8ac0 BOOLEAN;
  p_spMatch_079c88df8ac0 VARCHAR(255);
  p_RelationshipDefaultDisplayType_079c88df8ac0 VARCHAR(20);
  p_UserFormGenerated_079c88df8ac0 BOOLEAN;
  p_EntityObjectSubclassName_079c88df8ac0 VARCHAR(255);
  p_EntityObjectSubclassImport_079c88df8ac0 VARCHAR(255);
  p_PreferredCommunicationField_079c88df8ac0 VARCHAR(255);
  p_Icon_079c88df8ac0 VARCHAR(500);
  p_ScopeDefault_079c88df8ac0 VARCHAR(100);
  p_RowsToPackWithSchema_079c88df8ac0 VARCHAR(20);
  p_RowsToPackSampleMethod_079c88df8ac0 VARCHAR(20);
  p_RowsToPackSampleCount_079c88df8ac0 INTEGER;
  p_RowsToPackSampleOrder_079c88df8ac0 TEXT;
  p_AutoRowCountFrequency_079c88df8ac0 INTEGER;
  p_RowCount_079c88df8ac0 BIGINT;
  p_RowCountRunAt_079c88df8ac0 TIMESTAMPTZ;
  p_Status_079c88df8ac0 VARCHAR(25);
  p_DisplayName_079c88df8ac0 VARCHAR(255);
  p_AllowMultipleSubtypes_079c88df8ac0 BOOLEAN;
  p_AutoUpdateFullTextSearch_079c88df8ac0 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_079c88df8ac0 BOOLEAN;
  p_TrustServerCacheCompletely_079c88df8ac0 BOOLEAN;
  p_SupportsGeoCoding_079c88df8ac0 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_079c88df8ac0 BOOLEAN;
  p_AllowCaching_079c88df8ac0 BOOLEAN;
  p_DetectExternalChanges_079c88df8ac0 BOOLEAN;
  p_ExternalDataSourceID_079c88df8ac0 UUID;
  p_ExternalObjectName_079c88df8ac0 VARCHAR(255);
  p_GeneratedBaseViewName_079c88df8ac0 VARCHAR(255);
  p_AllowDirectSQLInsert_079c88df8ac0 BOOLEAN;
  p_AllowDirectSQLUpdate_079c88df8ac0 BOOLEAN;
  p_AllowDirectSQLDelete_079c88df8ac0 BOOLEAN;
  p_Configuration_079c88df8ac0 TEXT;
  p_SubtypeSelector_079c88df8ac0 TEXT;
  p_EnableFieldLevelSecurity_079c88df8ac0 BOOLEAN;
  p_ID_079c88df8ac0 UUID;
BEGIN
  p_Name_079c88df8ac0 := 'MJ_BizApps_Tasks: Tasks';
  p_AutoUpdateDescription_079c88df8ac0 := TRUE;
  p_BaseView_079c88df8ac0 := 'vwTasks';
  p_BaseViewGenerated_079c88df8ac0 := FALSE;
  p_VirtualEntity_079c88df8ac0 := FALSE;
  p_TrackRecordChanges_079c88df8ac0 := TRUE;
  p_AuditRecordAccess_079c88df8ac0 := FALSE;
  p_AuditViewRuns_079c88df8ac0 := FALSE;
  p_IncludeInAPI_079c88df8ac0 := TRUE;
  p_AllowAllRowsAPI_079c88df8ac0 := FALSE;
  p_AllowUpdateAPI_079c88df8ac0 := TRUE;
  p_AllowCreateAPI_079c88df8ac0 := TRUE;
  p_AllowDeleteAPI_079c88df8ac0 := TRUE;
  p_CustomResolverAPI_079c88df8ac0 := FALSE;
  p_AllowUserSearchAPI_079c88df8ac0 := TRUE;
  p_FullTextSearchEnabled_079c88df8ac0 := FALSE;
  p_FullTextCatalogGenerated_079c88df8ac0 := TRUE;
  p_FullTextIndexGenerated_079c88df8ac0 := TRUE;
  p_FullTextSearchFunctionGenerated_079c88df8ac0 := TRUE;
  p_UserViewMaxRows_079c88df8ac0 := 1000;
  p_spCreateGenerated_079c88df8ac0 := TRUE;
  p_spUpdateGenerated_079c88df8ac0 := TRUE;
  p_spDeleteGenerated_079c88df8ac0 := TRUE;
  p_CascadeDeletes_079c88df8ac0 := FALSE;
  p_DeleteType_079c88df8ac0 := 'Hard';
  p_AllowRecordMerge_079c88df8ac0 := FALSE;
  p_RelationshipDefaultDisplayType_079c88df8ac0 := 'Search';
  p_UserFormGenerated_079c88df8ac0 := TRUE;
  p_Icon_079c88df8ac0 := 'fa fa-tasks';
  p_RowsToPackWithSchema_079c88df8ac0 := 'None';
  p_RowsToPackSampleMethod_079c88df8ac0 := 'random';
  p_RowsToPackSampleCount_079c88df8ac0 := 0;
  p_Status_079c88df8ac0 := 'Active';
  p_DisplayName_079c88df8ac0 := 'Tasks';
  p_AllowMultipleSubtypes_079c88df8ac0 := FALSE;
  p_AutoUpdateFullTextSearch_079c88df8ac0 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_079c88df8ac0 := FALSE;
  p_TrustServerCacheCompletely_079c88df8ac0 := TRUE;
  p_SupportsGeoCoding_079c88df8ac0 := FALSE;
  p_AutoUpdateSupportsGeoCoding_079c88df8ac0 := TRUE;
  p_AllowCaching_079c88df8ac0 := FALSE;
  p_DetectExternalChanges_079c88df8ac0 := FALSE;
  p_GeneratedBaseViewName_079c88df8ac0 := 'vwTasksGenerated';
  p_AllowDirectSQLInsert_079c88df8ac0 := FALSE;
  p_AllowDirectSQLUpdate_079c88df8ac0 := FALSE;
  p_AllowDirectSQLDelete_079c88df8ac0 := FALSE;
  p_Configuration_079c88df8ac0 := '{
  "UI": {
    "Form": {
      "Layout": "left-nav",
      "RelatedRolePolicy": "smart",
      "PrimaryRelatedBudget": 6
    }
  }
}';
  p_EnableFieldLevelSecurity_079c88df8ac0 := FALSE;
  p_ID_079c88df8ac0 := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_079c88df8ac0,
    'Name', p_Name_079c88df8ac0,
    'NameSuffix', p_NameSuffix_079c88df8ac0,
    'Description', p_Description_079c88df8ac0,
    'AutoUpdateDescription', p_AutoUpdateDescription_079c88df8ac0,
    'BaseView', p_BaseView_079c88df8ac0,
    'BaseViewGenerated', p_BaseViewGenerated_079c88df8ac0,
    'VirtualEntity', p_VirtualEntity_079c88df8ac0,
    'TrackRecordChanges', p_TrackRecordChanges_079c88df8ac0,
    'AuditRecordAccess', p_AuditRecordAccess_079c88df8ac0,
    'AuditViewRuns', p_AuditViewRuns_079c88df8ac0,
    'IncludeInAPI', p_IncludeInAPI_079c88df8ac0,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_079c88df8ac0,
    'AllowUpdateAPI', p_AllowUpdateAPI_079c88df8ac0,
    'AllowCreateAPI', p_AllowCreateAPI_079c88df8ac0,
    'AllowDeleteAPI', p_AllowDeleteAPI_079c88df8ac0,
    'CustomResolverAPI', p_CustomResolverAPI_079c88df8ac0,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_079c88df8ac0,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_079c88df8ac0,
    'FullTextCatalog', p_FullTextCatalog_079c88df8ac0,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_079c88df8ac0,
    'FullTextIndex', p_FullTextIndex_079c88df8ac0,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_079c88df8ac0,
    'FullTextSearchFunction', p_FullTextSearchFunction_079c88df8ac0,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_079c88df8ac0,
    'UserViewMaxRows', p_UserViewMaxRows_079c88df8ac0,
    'spCreate', p_spCreate_079c88df8ac0,
    'spUpdate', p_spUpdate_079c88df8ac0,
    'spDelete', p_spDelete_079c88df8ac0,
    'spCreateGenerated', p_spCreateGenerated_079c88df8ac0,
    'spUpdateGenerated', p_spUpdateGenerated_079c88df8ac0,
    'spDeleteGenerated', p_spDeleteGenerated_079c88df8ac0,
    'CascadeDeletes', p_CascadeDeletes_079c88df8ac0,
    'DeleteType', p_DeleteType_079c88df8ac0,
    'AllowRecordMerge', p_AllowRecordMerge_079c88df8ac0,
    'spMatch', p_spMatch_079c88df8ac0,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_079c88df8ac0,
    'UserFormGenerated', p_UserFormGenerated_079c88df8ac0,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_079c88df8ac0,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_079c88df8ac0,
    'PreferredCommunicationField', p_PreferredCommunicationField_079c88df8ac0,
    'Icon', p_Icon_079c88df8ac0,
    'ScopeDefault', p_ScopeDefault_079c88df8ac0,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_079c88df8ac0,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_079c88df8ac0,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_079c88df8ac0,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_079c88df8ac0,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_079c88df8ac0,
    'RowCount', p_RowCount_079c88df8ac0,
    'RowCountRunAt', p_RowCountRunAt_079c88df8ac0
  ) ||
  jsonb_build_object(
    'Status', p_Status_079c88df8ac0,
    'DisplayName', p_DisplayName_079c88df8ac0,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_079c88df8ac0,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_079c88df8ac0,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_079c88df8ac0,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_079c88df8ac0,
    'SupportsGeoCoding', p_SupportsGeoCoding_079c88df8ac0,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_079c88df8ac0,
    'AllowCaching', p_AllowCaching_079c88df8ac0,
    'DetectExternalChanges', p_DetectExternalChanges_079c88df8ac0,
    'ExternalDataSourceID', p_ExternalDataSourceID_079c88df8ac0,
    'ExternalObjectName', p_ExternalObjectName_079c88df8ac0,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_079c88df8ac0,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_079c88df8ac0,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_079c88df8ac0,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_079c88df8ac0,
    'Configuration', p_Configuration_079c88df8ac0,
    'SubtypeSelector', p_SubtypeSelector_079c88df8ac0,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_079c88df8ac0,
    'ID', p_ID_079c88df8ac0
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_d67cde34e42b UUID;
  p_Name_d67cde34e42b VARCHAR(255);
  p_NameSuffix_d67cde34e42b VARCHAR(255);
  p_Description_d67cde34e42b TEXT;
  p_AutoUpdateDescription_d67cde34e42b BOOLEAN;
  p_BaseView_d67cde34e42b VARCHAR(255);
  p_BaseViewGenerated_d67cde34e42b BOOLEAN;
  p_VirtualEntity_d67cde34e42b BOOLEAN;
  p_TrackRecordChanges_d67cde34e42b BOOLEAN;
  p_AuditRecordAccess_d67cde34e42b BOOLEAN;
  p_AuditViewRuns_d67cde34e42b BOOLEAN;
  p_IncludeInAPI_d67cde34e42b BOOLEAN;
  p_AllowAllRowsAPI_d67cde34e42b BOOLEAN;
  p_AllowUpdateAPI_d67cde34e42b BOOLEAN;
  p_AllowCreateAPI_d67cde34e42b BOOLEAN;
  p_AllowDeleteAPI_d67cde34e42b BOOLEAN;
  p_CustomResolverAPI_d67cde34e42b BOOLEAN;
  p_AllowUserSearchAPI_d67cde34e42b BOOLEAN;
  p_FullTextSearchEnabled_d67cde34e42b BOOLEAN;
  p_FullTextCatalog_d67cde34e42b VARCHAR(255);
  p_FullTextCatalogGenerated_d67cde34e42b BOOLEAN;
  p_FullTextIndex_d67cde34e42b VARCHAR(255);
  p_FullTextIndexGenerated_d67cde34e42b BOOLEAN;
  p_FullTextSearchFunction_d67cde34e42b VARCHAR(255);
  p_FullTextSearchFunctionGenerated_d67cde34e42b BOOLEAN;
  p_UserViewMaxRows_d67cde34e42b INTEGER;
  p_spCreate_d67cde34e42b VARCHAR(255);
  p_spUpdate_d67cde34e42b VARCHAR(255);
  p_spDelete_d67cde34e42b VARCHAR(255);
  p_spCreateGenerated_d67cde34e42b BOOLEAN;
  p_spUpdateGenerated_d67cde34e42b BOOLEAN;
  p_spDeleteGenerated_d67cde34e42b BOOLEAN;
  p_CascadeDeletes_d67cde34e42b BOOLEAN;
  p_DeleteType_d67cde34e42b VARCHAR(10);
  p_AllowRecordMerge_d67cde34e42b BOOLEAN;
  p_spMatch_d67cde34e42b VARCHAR(255);
  p_RelationshipDefaultDisplayType_d67cde34e42b VARCHAR(20);
  p_UserFormGenerated_d67cde34e42b BOOLEAN;
  p_EntityObjectSubclassName_d67cde34e42b VARCHAR(255);
  p_EntityObjectSubclassImport_d67cde34e42b VARCHAR(255);
  p_PreferredCommunicationField_d67cde34e42b VARCHAR(255);
  p_Icon_d67cde34e42b VARCHAR(500);
  p_ScopeDefault_d67cde34e42b VARCHAR(100);
  p_RowsToPackWithSchema_d67cde34e42b VARCHAR(20);
  p_RowsToPackSampleMethod_d67cde34e42b VARCHAR(20);
  p_RowsToPackSampleCount_d67cde34e42b INTEGER;
  p_RowsToPackSampleOrder_d67cde34e42b TEXT;
  p_AutoRowCountFrequency_d67cde34e42b INTEGER;
  p_RowCount_d67cde34e42b BIGINT;
  p_RowCountRunAt_d67cde34e42b TIMESTAMPTZ;
  p_Status_d67cde34e42b VARCHAR(25);
  p_DisplayName_d67cde34e42b VARCHAR(255);
  p_AllowMultipleSubtypes_d67cde34e42b BOOLEAN;
  p_AutoUpdateFullTextSearch_d67cde34e42b BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_d67cde34e42b BOOLEAN;
  p_TrustServerCacheCompletely_d67cde34e42b BOOLEAN;
  p_SupportsGeoCoding_d67cde34e42b BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_d67cde34e42b BOOLEAN;
  p_AllowCaching_d67cde34e42b BOOLEAN;
  p_DetectExternalChanges_d67cde34e42b BOOLEAN;
  p_ExternalDataSourceID_d67cde34e42b UUID;
  p_ExternalObjectName_d67cde34e42b VARCHAR(255);
  p_GeneratedBaseViewName_d67cde34e42b VARCHAR(255);
  p_AllowDirectSQLInsert_d67cde34e42b BOOLEAN;
  p_AllowDirectSQLUpdate_d67cde34e42b BOOLEAN;
  p_AllowDirectSQLDelete_d67cde34e42b BOOLEAN;
  p_Configuration_d67cde34e42b TEXT;
  p_SubtypeSelector_d67cde34e42b TEXT;
  p_EnableFieldLevelSecurity_d67cde34e42b BOOLEAN;
  p_ID_d67cde34e42b UUID;
BEGIN
  p_Name_d67cde34e42b := 'MJ_BizApps_Tasks: Task Categories';
  p_AutoUpdateDescription_d67cde34e42b := TRUE;
  p_BaseView_d67cde34e42b := 'vwTaskCategories';
  p_BaseViewGenerated_d67cde34e42b := TRUE;
  p_VirtualEntity_d67cde34e42b := FALSE;
  p_TrackRecordChanges_d67cde34e42b := TRUE;
  p_AuditRecordAccess_d67cde34e42b := FALSE;
  p_AuditViewRuns_d67cde34e42b := FALSE;
  p_IncludeInAPI_d67cde34e42b := TRUE;
  p_AllowAllRowsAPI_d67cde34e42b := FALSE;
  p_AllowUpdateAPI_d67cde34e42b := TRUE;
  p_AllowCreateAPI_d67cde34e42b := TRUE;
  p_AllowDeleteAPI_d67cde34e42b := TRUE;
  p_CustomResolverAPI_d67cde34e42b := FALSE;
  p_AllowUserSearchAPI_d67cde34e42b := TRUE;
  p_FullTextSearchEnabled_d67cde34e42b := FALSE;
  p_FullTextCatalogGenerated_d67cde34e42b := TRUE;
  p_FullTextIndexGenerated_d67cde34e42b := TRUE;
  p_FullTextSearchFunctionGenerated_d67cde34e42b := TRUE;
  p_UserViewMaxRows_d67cde34e42b := 1000;
  p_spCreateGenerated_d67cde34e42b := TRUE;
  p_spUpdateGenerated_d67cde34e42b := TRUE;
  p_spDeleteGenerated_d67cde34e42b := TRUE;
  p_CascadeDeletes_d67cde34e42b := FALSE;
  p_DeleteType_d67cde34e42b := 'Hard';
  p_AllowRecordMerge_d67cde34e42b := FALSE;
  p_RelationshipDefaultDisplayType_d67cde34e42b := 'Search';
  p_UserFormGenerated_d67cde34e42b := TRUE;
  p_RowsToPackWithSchema_d67cde34e42b := 'None';
  p_RowsToPackSampleMethod_d67cde34e42b := 'random';
  p_RowsToPackSampleCount_d67cde34e42b := 0;
  p_Status_d67cde34e42b := 'Active';
  p_DisplayName_d67cde34e42b := 'Task Categories';
  p_AllowMultipleSubtypes_d67cde34e42b := FALSE;
  p_AutoUpdateFullTextSearch_d67cde34e42b := TRUE;
  p_AutoUpdateAllowUserSearchAPI_d67cde34e42b := FALSE;
  p_TrustServerCacheCompletely_d67cde34e42b := TRUE;
  p_SupportsGeoCoding_d67cde34e42b := FALSE;
  p_AutoUpdateSupportsGeoCoding_d67cde34e42b := TRUE;
  p_AllowCaching_d67cde34e42b := FALSE;
  p_DetectExternalChanges_d67cde34e42b := FALSE;
  p_AllowDirectSQLInsert_d67cde34e42b := FALSE;
  p_AllowDirectSQLUpdate_d67cde34e42b := FALSE;
  p_AllowDirectSQLDelete_d67cde34e42b := FALSE;
  p_EnableFieldLevelSecurity_d67cde34e42b := FALSE;
  p_ID_d67cde34e42b := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_d67cde34e42b,
    'Name', p_Name_d67cde34e42b,
    'NameSuffix', p_NameSuffix_d67cde34e42b,
    'Description', p_Description_d67cde34e42b,
    'AutoUpdateDescription', p_AutoUpdateDescription_d67cde34e42b,
    'BaseView', p_BaseView_d67cde34e42b,
    'BaseViewGenerated', p_BaseViewGenerated_d67cde34e42b,
    'VirtualEntity', p_VirtualEntity_d67cde34e42b,
    'TrackRecordChanges', p_TrackRecordChanges_d67cde34e42b,
    'AuditRecordAccess', p_AuditRecordAccess_d67cde34e42b,
    'AuditViewRuns', p_AuditViewRuns_d67cde34e42b,
    'IncludeInAPI', p_IncludeInAPI_d67cde34e42b,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_d67cde34e42b,
    'AllowUpdateAPI', p_AllowUpdateAPI_d67cde34e42b,
    'AllowCreateAPI', p_AllowCreateAPI_d67cde34e42b,
    'AllowDeleteAPI', p_AllowDeleteAPI_d67cde34e42b,
    'CustomResolverAPI', p_CustomResolverAPI_d67cde34e42b,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_d67cde34e42b,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_d67cde34e42b,
    'FullTextCatalog', p_FullTextCatalog_d67cde34e42b,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_d67cde34e42b,
    'FullTextIndex', p_FullTextIndex_d67cde34e42b,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_d67cde34e42b,
    'FullTextSearchFunction', p_FullTextSearchFunction_d67cde34e42b,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_d67cde34e42b,
    'UserViewMaxRows', p_UserViewMaxRows_d67cde34e42b,
    'spCreate', p_spCreate_d67cde34e42b,
    'spUpdate', p_spUpdate_d67cde34e42b,
    'spDelete', p_spDelete_d67cde34e42b,
    'spCreateGenerated', p_spCreateGenerated_d67cde34e42b,
    'spUpdateGenerated', p_spUpdateGenerated_d67cde34e42b,
    'spDeleteGenerated', p_spDeleteGenerated_d67cde34e42b,
    'CascadeDeletes', p_CascadeDeletes_d67cde34e42b,
    'DeleteType', p_DeleteType_d67cde34e42b,
    'AllowRecordMerge', p_AllowRecordMerge_d67cde34e42b,
    'spMatch', p_spMatch_d67cde34e42b,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_d67cde34e42b,
    'UserFormGenerated', p_UserFormGenerated_d67cde34e42b,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_d67cde34e42b,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_d67cde34e42b,
    'PreferredCommunicationField', p_PreferredCommunicationField_d67cde34e42b,
    'Icon', p_Icon_d67cde34e42b,
    'ScopeDefault', p_ScopeDefault_d67cde34e42b,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_d67cde34e42b,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_d67cde34e42b,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_d67cde34e42b,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_d67cde34e42b,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_d67cde34e42b,
    'RowCount', p_RowCount_d67cde34e42b,
    'RowCountRunAt', p_RowCountRunAt_d67cde34e42b
  ) ||
  jsonb_build_object(
    'Status', p_Status_d67cde34e42b,
    'DisplayName', p_DisplayName_d67cde34e42b,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_d67cde34e42b,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_d67cde34e42b,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_d67cde34e42b,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_d67cde34e42b,
    'SupportsGeoCoding', p_SupportsGeoCoding_d67cde34e42b,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_d67cde34e42b,
    'AllowCaching', p_AllowCaching_d67cde34e42b,
    'DetectExternalChanges', p_DetectExternalChanges_d67cde34e42b,
    'ExternalDataSourceID', p_ExternalDataSourceID_d67cde34e42b,
    'ExternalObjectName', p_ExternalObjectName_d67cde34e42b,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_d67cde34e42b,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_d67cde34e42b,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_d67cde34e42b,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_d67cde34e42b,
    'Configuration', p_Configuration_d67cde34e42b,
    'SubtypeSelector', p_SubtypeSelector_d67cde34e42b,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_d67cde34e42b,
    'ID', p_ID_d67cde34e42b
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_7ec8d7900bf7 UUID;
  p_Name_7ec8d7900bf7 VARCHAR(255);
  p_NameSuffix_7ec8d7900bf7 VARCHAR(255);
  p_Description_7ec8d7900bf7 TEXT;
  p_AutoUpdateDescription_7ec8d7900bf7 BOOLEAN;
  p_BaseView_7ec8d7900bf7 VARCHAR(255);
  p_BaseViewGenerated_7ec8d7900bf7 BOOLEAN;
  p_VirtualEntity_7ec8d7900bf7 BOOLEAN;
  p_TrackRecordChanges_7ec8d7900bf7 BOOLEAN;
  p_AuditRecordAccess_7ec8d7900bf7 BOOLEAN;
  p_AuditViewRuns_7ec8d7900bf7 BOOLEAN;
  p_IncludeInAPI_7ec8d7900bf7 BOOLEAN;
  p_AllowAllRowsAPI_7ec8d7900bf7 BOOLEAN;
  p_AllowUpdateAPI_7ec8d7900bf7 BOOLEAN;
  p_AllowCreateAPI_7ec8d7900bf7 BOOLEAN;
  p_AllowDeleteAPI_7ec8d7900bf7 BOOLEAN;
  p_CustomResolverAPI_7ec8d7900bf7 BOOLEAN;
  p_AllowUserSearchAPI_7ec8d7900bf7 BOOLEAN;
  p_FullTextSearchEnabled_7ec8d7900bf7 BOOLEAN;
  p_FullTextCatalog_7ec8d7900bf7 VARCHAR(255);
  p_FullTextCatalogGenerated_7ec8d7900bf7 BOOLEAN;
  p_FullTextIndex_7ec8d7900bf7 VARCHAR(255);
  p_FullTextIndexGenerated_7ec8d7900bf7 BOOLEAN;
  p_FullTextSearchFunction_7ec8d7900bf7 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_7ec8d7900bf7 BOOLEAN;
  p_UserViewMaxRows_7ec8d7900bf7 INTEGER;
  p_spCreate_7ec8d7900bf7 VARCHAR(255);
  p_spUpdate_7ec8d7900bf7 VARCHAR(255);
  p_spDelete_7ec8d7900bf7 VARCHAR(255);
  p_spCreateGenerated_7ec8d7900bf7 BOOLEAN;
  p_spUpdateGenerated_7ec8d7900bf7 BOOLEAN;
  p_spDeleteGenerated_7ec8d7900bf7 BOOLEAN;
  p_CascadeDeletes_7ec8d7900bf7 BOOLEAN;
  p_DeleteType_7ec8d7900bf7 VARCHAR(10);
  p_AllowRecordMerge_7ec8d7900bf7 BOOLEAN;
  p_spMatch_7ec8d7900bf7 VARCHAR(255);
  p_RelationshipDefaultDisplayType_7ec8d7900bf7 VARCHAR(20);
  p_UserFormGenerated_7ec8d7900bf7 BOOLEAN;
  p_EntityObjectSubclassName_7ec8d7900bf7 VARCHAR(255);
  p_EntityObjectSubclassImport_7ec8d7900bf7 VARCHAR(255);
  p_PreferredCommunicationField_7ec8d7900bf7 VARCHAR(255);
  p_Icon_7ec8d7900bf7 VARCHAR(500);
  p_ScopeDefault_7ec8d7900bf7 VARCHAR(100);
  p_RowsToPackWithSchema_7ec8d7900bf7 VARCHAR(20);
  p_RowsToPackSampleMethod_7ec8d7900bf7 VARCHAR(20);
  p_RowsToPackSampleCount_7ec8d7900bf7 INTEGER;
  p_RowsToPackSampleOrder_7ec8d7900bf7 TEXT;
  p_AutoRowCountFrequency_7ec8d7900bf7 INTEGER;
  p_RowCount_7ec8d7900bf7 BIGINT;
  p_RowCountRunAt_7ec8d7900bf7 TIMESTAMPTZ;
  p_Status_7ec8d7900bf7 VARCHAR(25);
  p_DisplayName_7ec8d7900bf7 VARCHAR(255);
  p_AllowMultipleSubtypes_7ec8d7900bf7 BOOLEAN;
  p_AutoUpdateFullTextSearch_7ec8d7900bf7 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_7ec8d7900bf7 BOOLEAN;
  p_TrustServerCacheCompletely_7ec8d7900bf7 BOOLEAN;
  p_SupportsGeoCoding_7ec8d7900bf7 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_7ec8d7900bf7 BOOLEAN;
  p_AllowCaching_7ec8d7900bf7 BOOLEAN;
  p_DetectExternalChanges_7ec8d7900bf7 BOOLEAN;
  p_ExternalDataSourceID_7ec8d7900bf7 UUID;
  p_ExternalObjectName_7ec8d7900bf7 VARCHAR(255);
  p_GeneratedBaseViewName_7ec8d7900bf7 VARCHAR(255);
  p_AllowDirectSQLInsert_7ec8d7900bf7 BOOLEAN;
  p_AllowDirectSQLUpdate_7ec8d7900bf7 BOOLEAN;
  p_AllowDirectSQLDelete_7ec8d7900bf7 BOOLEAN;
  p_Configuration_7ec8d7900bf7 TEXT;
  p_SubtypeSelector_7ec8d7900bf7 TEXT;
  p_EnableFieldLevelSecurity_7ec8d7900bf7 BOOLEAN;
  p_ID_7ec8d7900bf7 UUID;
BEGIN
  p_Name_7ec8d7900bf7 := 'MJ_BizApps_Tasks: Task Templates';
  p_AutoUpdateDescription_7ec8d7900bf7 := TRUE;
  p_BaseView_7ec8d7900bf7 := 'vwTaskTemplates';
  p_BaseViewGenerated_7ec8d7900bf7 := TRUE;
  p_VirtualEntity_7ec8d7900bf7 := FALSE;
  p_TrackRecordChanges_7ec8d7900bf7 := TRUE;
  p_AuditRecordAccess_7ec8d7900bf7 := FALSE;
  p_AuditViewRuns_7ec8d7900bf7 := FALSE;
  p_IncludeInAPI_7ec8d7900bf7 := TRUE;
  p_AllowAllRowsAPI_7ec8d7900bf7 := FALSE;
  p_AllowUpdateAPI_7ec8d7900bf7 := TRUE;
  p_AllowCreateAPI_7ec8d7900bf7 := TRUE;
  p_AllowDeleteAPI_7ec8d7900bf7 := TRUE;
  p_CustomResolverAPI_7ec8d7900bf7 := FALSE;
  p_AllowUserSearchAPI_7ec8d7900bf7 := TRUE;
  p_FullTextSearchEnabled_7ec8d7900bf7 := FALSE;
  p_FullTextCatalogGenerated_7ec8d7900bf7 := TRUE;
  p_FullTextIndexGenerated_7ec8d7900bf7 := TRUE;
  p_FullTextSearchFunctionGenerated_7ec8d7900bf7 := TRUE;
  p_UserViewMaxRows_7ec8d7900bf7 := 1000;
  p_spCreateGenerated_7ec8d7900bf7 := TRUE;
  p_spUpdateGenerated_7ec8d7900bf7 := TRUE;
  p_spDeleteGenerated_7ec8d7900bf7 := TRUE;
  p_CascadeDeletes_7ec8d7900bf7 := FALSE;
  p_DeleteType_7ec8d7900bf7 := 'Hard';
  p_AllowRecordMerge_7ec8d7900bf7 := FALSE;
  p_RelationshipDefaultDisplayType_7ec8d7900bf7 := 'Search';
  p_UserFormGenerated_7ec8d7900bf7 := TRUE;
  p_RowsToPackWithSchema_7ec8d7900bf7 := 'None';
  p_RowsToPackSampleMethod_7ec8d7900bf7 := 'random';
  p_RowsToPackSampleCount_7ec8d7900bf7 := 0;
  p_Status_7ec8d7900bf7 := 'Active';
  p_DisplayName_7ec8d7900bf7 := 'Task Templates';
  p_AllowMultipleSubtypes_7ec8d7900bf7 := FALSE;
  p_AutoUpdateFullTextSearch_7ec8d7900bf7 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_7ec8d7900bf7 := FALSE;
  p_TrustServerCacheCompletely_7ec8d7900bf7 := TRUE;
  p_SupportsGeoCoding_7ec8d7900bf7 := FALSE;
  p_AutoUpdateSupportsGeoCoding_7ec8d7900bf7 := TRUE;
  p_AllowCaching_7ec8d7900bf7 := FALSE;
  p_DetectExternalChanges_7ec8d7900bf7 := FALSE;
  p_AllowDirectSQLInsert_7ec8d7900bf7 := FALSE;
  p_AllowDirectSQLUpdate_7ec8d7900bf7 := FALSE;
  p_AllowDirectSQLDelete_7ec8d7900bf7 := FALSE;
  p_EnableFieldLevelSecurity_7ec8d7900bf7 := FALSE;
  p_ID_7ec8d7900bf7 := '802AEF11-BFE2-4B46-98B2-5FEBD4E35923';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_7ec8d7900bf7,
    'Name', p_Name_7ec8d7900bf7,
    'NameSuffix', p_NameSuffix_7ec8d7900bf7,
    'Description', p_Description_7ec8d7900bf7,
    'AutoUpdateDescription', p_AutoUpdateDescription_7ec8d7900bf7,
    'BaseView', p_BaseView_7ec8d7900bf7,
    'BaseViewGenerated', p_BaseViewGenerated_7ec8d7900bf7,
    'VirtualEntity', p_VirtualEntity_7ec8d7900bf7,
    'TrackRecordChanges', p_TrackRecordChanges_7ec8d7900bf7,
    'AuditRecordAccess', p_AuditRecordAccess_7ec8d7900bf7,
    'AuditViewRuns', p_AuditViewRuns_7ec8d7900bf7,
    'IncludeInAPI', p_IncludeInAPI_7ec8d7900bf7,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_7ec8d7900bf7,
    'AllowUpdateAPI', p_AllowUpdateAPI_7ec8d7900bf7,
    'AllowCreateAPI', p_AllowCreateAPI_7ec8d7900bf7,
    'AllowDeleteAPI', p_AllowDeleteAPI_7ec8d7900bf7,
    'CustomResolverAPI', p_CustomResolverAPI_7ec8d7900bf7,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_7ec8d7900bf7,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_7ec8d7900bf7,
    'FullTextCatalog', p_FullTextCatalog_7ec8d7900bf7,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_7ec8d7900bf7,
    'FullTextIndex', p_FullTextIndex_7ec8d7900bf7,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_7ec8d7900bf7,
    'FullTextSearchFunction', p_FullTextSearchFunction_7ec8d7900bf7,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_7ec8d7900bf7,
    'UserViewMaxRows', p_UserViewMaxRows_7ec8d7900bf7,
    'spCreate', p_spCreate_7ec8d7900bf7,
    'spUpdate', p_spUpdate_7ec8d7900bf7,
    'spDelete', p_spDelete_7ec8d7900bf7,
    'spCreateGenerated', p_spCreateGenerated_7ec8d7900bf7,
    'spUpdateGenerated', p_spUpdateGenerated_7ec8d7900bf7,
    'spDeleteGenerated', p_spDeleteGenerated_7ec8d7900bf7,
    'CascadeDeletes', p_CascadeDeletes_7ec8d7900bf7,
    'DeleteType', p_DeleteType_7ec8d7900bf7,
    'AllowRecordMerge', p_AllowRecordMerge_7ec8d7900bf7,
    'spMatch', p_spMatch_7ec8d7900bf7,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_7ec8d7900bf7,
    'UserFormGenerated', p_UserFormGenerated_7ec8d7900bf7,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_7ec8d7900bf7,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_7ec8d7900bf7,
    'PreferredCommunicationField', p_PreferredCommunicationField_7ec8d7900bf7,
    'Icon', p_Icon_7ec8d7900bf7,
    'ScopeDefault', p_ScopeDefault_7ec8d7900bf7,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_7ec8d7900bf7,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_7ec8d7900bf7,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_7ec8d7900bf7,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_7ec8d7900bf7,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_7ec8d7900bf7,
    'RowCount', p_RowCount_7ec8d7900bf7,
    'RowCountRunAt', p_RowCountRunAt_7ec8d7900bf7
  ) ||
  jsonb_build_object(
    'Status', p_Status_7ec8d7900bf7,
    'DisplayName', p_DisplayName_7ec8d7900bf7,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_7ec8d7900bf7,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_7ec8d7900bf7,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_7ec8d7900bf7,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_7ec8d7900bf7,
    'SupportsGeoCoding', p_SupportsGeoCoding_7ec8d7900bf7,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_7ec8d7900bf7,
    'AllowCaching', p_AllowCaching_7ec8d7900bf7,
    'DetectExternalChanges', p_DetectExternalChanges_7ec8d7900bf7,
    'ExternalDataSourceID', p_ExternalDataSourceID_7ec8d7900bf7,
    'ExternalObjectName', p_ExternalObjectName_7ec8d7900bf7,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_7ec8d7900bf7,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_7ec8d7900bf7,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_7ec8d7900bf7,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_7ec8d7900bf7,
    'Configuration', p_Configuration_7ec8d7900bf7,
    'SubtypeSelector', p_SubtypeSelector_7ec8d7900bf7,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_7ec8d7900bf7,
    'ID', p_ID_7ec8d7900bf7
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_29e7669ed9fb UUID;
  p_Name_29e7669ed9fb VARCHAR(255);
  p_NameSuffix_29e7669ed9fb VARCHAR(255);
  p_Description_29e7669ed9fb TEXT;
  p_AutoUpdateDescription_29e7669ed9fb BOOLEAN;
  p_BaseView_29e7669ed9fb VARCHAR(255);
  p_BaseViewGenerated_29e7669ed9fb BOOLEAN;
  p_VirtualEntity_29e7669ed9fb BOOLEAN;
  p_TrackRecordChanges_29e7669ed9fb BOOLEAN;
  p_AuditRecordAccess_29e7669ed9fb BOOLEAN;
  p_AuditViewRuns_29e7669ed9fb BOOLEAN;
  p_IncludeInAPI_29e7669ed9fb BOOLEAN;
  p_AllowAllRowsAPI_29e7669ed9fb BOOLEAN;
  p_AllowUpdateAPI_29e7669ed9fb BOOLEAN;
  p_AllowCreateAPI_29e7669ed9fb BOOLEAN;
  p_AllowDeleteAPI_29e7669ed9fb BOOLEAN;
  p_CustomResolverAPI_29e7669ed9fb BOOLEAN;
  p_AllowUserSearchAPI_29e7669ed9fb BOOLEAN;
  p_FullTextSearchEnabled_29e7669ed9fb BOOLEAN;
  p_FullTextCatalog_29e7669ed9fb VARCHAR(255);
  p_FullTextCatalogGenerated_29e7669ed9fb BOOLEAN;
  p_FullTextIndex_29e7669ed9fb VARCHAR(255);
  p_FullTextIndexGenerated_29e7669ed9fb BOOLEAN;
  p_FullTextSearchFunction_29e7669ed9fb VARCHAR(255);
  p_FullTextSearchFunctionGenerated_29e7669ed9fb BOOLEAN;
  p_UserViewMaxRows_29e7669ed9fb INTEGER;
  p_spCreate_29e7669ed9fb VARCHAR(255);
  p_spUpdate_29e7669ed9fb VARCHAR(255);
  p_spDelete_29e7669ed9fb VARCHAR(255);
  p_spCreateGenerated_29e7669ed9fb BOOLEAN;
  p_spUpdateGenerated_29e7669ed9fb BOOLEAN;
  p_spDeleteGenerated_29e7669ed9fb BOOLEAN;
  p_CascadeDeletes_29e7669ed9fb BOOLEAN;
  p_DeleteType_29e7669ed9fb VARCHAR(10);
  p_AllowRecordMerge_29e7669ed9fb BOOLEAN;
  p_spMatch_29e7669ed9fb VARCHAR(255);
  p_RelationshipDefaultDisplayType_29e7669ed9fb VARCHAR(20);
  p_UserFormGenerated_29e7669ed9fb BOOLEAN;
  p_EntityObjectSubclassName_29e7669ed9fb VARCHAR(255);
  p_EntityObjectSubclassImport_29e7669ed9fb VARCHAR(255);
  p_PreferredCommunicationField_29e7669ed9fb VARCHAR(255);
  p_Icon_29e7669ed9fb VARCHAR(500);
  p_ScopeDefault_29e7669ed9fb VARCHAR(100);
  p_RowsToPackWithSchema_29e7669ed9fb VARCHAR(20);
  p_RowsToPackSampleMethod_29e7669ed9fb VARCHAR(20);
  p_RowsToPackSampleCount_29e7669ed9fb INTEGER;
  p_RowsToPackSampleOrder_29e7669ed9fb TEXT;
  p_AutoRowCountFrequency_29e7669ed9fb INTEGER;
  p_RowCount_29e7669ed9fb BIGINT;
  p_RowCountRunAt_29e7669ed9fb TIMESTAMPTZ;
  p_Status_29e7669ed9fb VARCHAR(25);
  p_DisplayName_29e7669ed9fb VARCHAR(255);
  p_AllowMultipleSubtypes_29e7669ed9fb BOOLEAN;
  p_AutoUpdateFullTextSearch_29e7669ed9fb BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_29e7669ed9fb BOOLEAN;
  p_TrustServerCacheCompletely_29e7669ed9fb BOOLEAN;
  p_SupportsGeoCoding_29e7669ed9fb BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_29e7669ed9fb BOOLEAN;
  p_AllowCaching_29e7669ed9fb BOOLEAN;
  p_DetectExternalChanges_29e7669ed9fb BOOLEAN;
  p_ExternalDataSourceID_29e7669ed9fb UUID;
  p_ExternalObjectName_29e7669ed9fb VARCHAR(255);
  p_GeneratedBaseViewName_29e7669ed9fb VARCHAR(255);
  p_AllowDirectSQLInsert_29e7669ed9fb BOOLEAN;
  p_AllowDirectSQLUpdate_29e7669ed9fb BOOLEAN;
  p_AllowDirectSQLDelete_29e7669ed9fb BOOLEAN;
  p_Configuration_29e7669ed9fb TEXT;
  p_SubtypeSelector_29e7669ed9fb TEXT;
  p_EnableFieldLevelSecurity_29e7669ed9fb BOOLEAN;
  p_ID_29e7669ed9fb UUID;
BEGIN
  p_Name_29e7669ed9fb := 'MJ_BizApps_Tasks: Task Types';
  p_AutoUpdateDescription_29e7669ed9fb := TRUE;
  p_BaseView_29e7669ed9fb := 'vwTaskTypes';
  p_BaseViewGenerated_29e7669ed9fb := TRUE;
  p_VirtualEntity_29e7669ed9fb := FALSE;
  p_TrackRecordChanges_29e7669ed9fb := TRUE;
  p_AuditRecordAccess_29e7669ed9fb := FALSE;
  p_AuditViewRuns_29e7669ed9fb := FALSE;
  p_IncludeInAPI_29e7669ed9fb := TRUE;
  p_AllowAllRowsAPI_29e7669ed9fb := FALSE;
  p_AllowUpdateAPI_29e7669ed9fb := TRUE;
  p_AllowCreateAPI_29e7669ed9fb := TRUE;
  p_AllowDeleteAPI_29e7669ed9fb := TRUE;
  p_CustomResolverAPI_29e7669ed9fb := FALSE;
  p_AllowUserSearchAPI_29e7669ed9fb := TRUE;
  p_FullTextSearchEnabled_29e7669ed9fb := FALSE;
  p_FullTextCatalogGenerated_29e7669ed9fb := TRUE;
  p_FullTextIndexGenerated_29e7669ed9fb := TRUE;
  p_FullTextSearchFunctionGenerated_29e7669ed9fb := TRUE;
  p_UserViewMaxRows_29e7669ed9fb := 1000;
  p_spCreateGenerated_29e7669ed9fb := TRUE;
  p_spUpdateGenerated_29e7669ed9fb := TRUE;
  p_spDeleteGenerated_29e7669ed9fb := TRUE;
  p_CascadeDeletes_29e7669ed9fb := FALSE;
  p_DeleteType_29e7669ed9fb := 'Hard';
  p_AllowRecordMerge_29e7669ed9fb := FALSE;
  p_RelationshipDefaultDisplayType_29e7669ed9fb := 'Search';
  p_UserFormGenerated_29e7669ed9fb := TRUE;
  p_Icon_29e7669ed9fb := 'fa fa-tasks';
  p_RowsToPackWithSchema_29e7669ed9fb := 'None';
  p_RowsToPackSampleMethod_29e7669ed9fb := 'random';
  p_RowsToPackSampleCount_29e7669ed9fb := 0;
  p_Status_29e7669ed9fb := 'Active';
  p_DisplayName_29e7669ed9fb := 'Task Types';
  p_AllowMultipleSubtypes_29e7669ed9fb := FALSE;
  p_AutoUpdateFullTextSearch_29e7669ed9fb := TRUE;
  p_AutoUpdateAllowUserSearchAPI_29e7669ed9fb := FALSE;
  p_TrustServerCacheCompletely_29e7669ed9fb := TRUE;
  p_SupportsGeoCoding_29e7669ed9fb := FALSE;
  p_AutoUpdateSupportsGeoCoding_29e7669ed9fb := TRUE;
  p_AllowCaching_29e7669ed9fb := FALSE;
  p_DetectExternalChanges_29e7669ed9fb := FALSE;
  p_AllowDirectSQLInsert_29e7669ed9fb := FALSE;
  p_AllowDirectSQLUpdate_29e7669ed9fb := FALSE;
  p_AllowDirectSQLDelete_29e7669ed9fb := FALSE;
  p_EnableFieldLevelSecurity_29e7669ed9fb := FALSE;
  p_ID_29e7669ed9fb := '1E30141A-826F-4278-BAA9-BBE14D29E606';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_29e7669ed9fb,
    'Name', p_Name_29e7669ed9fb,
    'NameSuffix', p_NameSuffix_29e7669ed9fb,
    'Description', p_Description_29e7669ed9fb,
    'AutoUpdateDescription', p_AutoUpdateDescription_29e7669ed9fb,
    'BaseView', p_BaseView_29e7669ed9fb,
    'BaseViewGenerated', p_BaseViewGenerated_29e7669ed9fb,
    'VirtualEntity', p_VirtualEntity_29e7669ed9fb,
    'TrackRecordChanges', p_TrackRecordChanges_29e7669ed9fb,
    'AuditRecordAccess', p_AuditRecordAccess_29e7669ed9fb,
    'AuditViewRuns', p_AuditViewRuns_29e7669ed9fb,
    'IncludeInAPI', p_IncludeInAPI_29e7669ed9fb,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_29e7669ed9fb,
    'AllowUpdateAPI', p_AllowUpdateAPI_29e7669ed9fb,
    'AllowCreateAPI', p_AllowCreateAPI_29e7669ed9fb,
    'AllowDeleteAPI', p_AllowDeleteAPI_29e7669ed9fb,
    'CustomResolverAPI', p_CustomResolverAPI_29e7669ed9fb,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_29e7669ed9fb,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_29e7669ed9fb,
    'FullTextCatalog', p_FullTextCatalog_29e7669ed9fb,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_29e7669ed9fb,
    'FullTextIndex', p_FullTextIndex_29e7669ed9fb,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_29e7669ed9fb,
    'FullTextSearchFunction', p_FullTextSearchFunction_29e7669ed9fb,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_29e7669ed9fb,
    'UserViewMaxRows', p_UserViewMaxRows_29e7669ed9fb,
    'spCreate', p_spCreate_29e7669ed9fb,
    'spUpdate', p_spUpdate_29e7669ed9fb,
    'spDelete', p_spDelete_29e7669ed9fb,
    'spCreateGenerated', p_spCreateGenerated_29e7669ed9fb,
    'spUpdateGenerated', p_spUpdateGenerated_29e7669ed9fb,
    'spDeleteGenerated', p_spDeleteGenerated_29e7669ed9fb,
    'CascadeDeletes', p_CascadeDeletes_29e7669ed9fb,
    'DeleteType', p_DeleteType_29e7669ed9fb,
    'AllowRecordMerge', p_AllowRecordMerge_29e7669ed9fb,
    'spMatch', p_spMatch_29e7669ed9fb,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_29e7669ed9fb,
    'UserFormGenerated', p_UserFormGenerated_29e7669ed9fb,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_29e7669ed9fb,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_29e7669ed9fb,
    'PreferredCommunicationField', p_PreferredCommunicationField_29e7669ed9fb,
    'Icon', p_Icon_29e7669ed9fb,
    'ScopeDefault', p_ScopeDefault_29e7669ed9fb,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_29e7669ed9fb,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_29e7669ed9fb,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_29e7669ed9fb,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_29e7669ed9fb,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_29e7669ed9fb,
    'RowCount', p_RowCount_29e7669ed9fb,
    'RowCountRunAt', p_RowCountRunAt_29e7669ed9fb
  ) ||
  jsonb_build_object(
    'Status', p_Status_29e7669ed9fb,
    'DisplayName', p_DisplayName_29e7669ed9fb,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_29e7669ed9fb,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_29e7669ed9fb,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_29e7669ed9fb,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_29e7669ed9fb,
    'SupportsGeoCoding', p_SupportsGeoCoding_29e7669ed9fb,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_29e7669ed9fb,
    'AllowCaching', p_AllowCaching_29e7669ed9fb,
    'DetectExternalChanges', p_DetectExternalChanges_29e7669ed9fb,
    'ExternalDataSourceID', p_ExternalDataSourceID_29e7669ed9fb,
    'ExternalObjectName', p_ExternalObjectName_29e7669ed9fb,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_29e7669ed9fb,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_29e7669ed9fb,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_29e7669ed9fb,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_29e7669ed9fb,
    'Configuration', p_Configuration_29e7669ed9fb,
    'SubtypeSelector', p_SubtypeSelector_29e7669ed9fb,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_29e7669ed9fb,
    'ID', p_ID_29e7669ed9fb
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_aa1eca6c6a47 UUID;
  p_Name_aa1eca6c6a47 VARCHAR(255);
  p_NameSuffix_aa1eca6c6a47 VARCHAR(255);
  p_Description_aa1eca6c6a47 TEXT;
  p_AutoUpdateDescription_aa1eca6c6a47 BOOLEAN;
  p_BaseView_aa1eca6c6a47 VARCHAR(255);
  p_BaseViewGenerated_aa1eca6c6a47 BOOLEAN;
  p_VirtualEntity_aa1eca6c6a47 BOOLEAN;
  p_TrackRecordChanges_aa1eca6c6a47 BOOLEAN;
  p_AuditRecordAccess_aa1eca6c6a47 BOOLEAN;
  p_AuditViewRuns_aa1eca6c6a47 BOOLEAN;
  p_IncludeInAPI_aa1eca6c6a47 BOOLEAN;
  p_AllowAllRowsAPI_aa1eca6c6a47 BOOLEAN;
  p_AllowUpdateAPI_aa1eca6c6a47 BOOLEAN;
  p_AllowCreateAPI_aa1eca6c6a47 BOOLEAN;
  p_AllowDeleteAPI_aa1eca6c6a47 BOOLEAN;
  p_CustomResolverAPI_aa1eca6c6a47 BOOLEAN;
  p_AllowUserSearchAPI_aa1eca6c6a47 BOOLEAN;
  p_FullTextSearchEnabled_aa1eca6c6a47 BOOLEAN;
  p_FullTextCatalog_aa1eca6c6a47 VARCHAR(255);
  p_FullTextCatalogGenerated_aa1eca6c6a47 BOOLEAN;
  p_FullTextIndex_aa1eca6c6a47 VARCHAR(255);
  p_FullTextIndexGenerated_aa1eca6c6a47 BOOLEAN;
  p_FullTextSearchFunction_aa1eca6c6a47 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_aa1eca6c6a47 BOOLEAN;
  p_UserViewMaxRows_aa1eca6c6a47 INTEGER;
  p_spCreate_aa1eca6c6a47 VARCHAR(255);
  p_spUpdate_aa1eca6c6a47 VARCHAR(255);
  p_spDelete_aa1eca6c6a47 VARCHAR(255);
  p_spCreateGenerated_aa1eca6c6a47 BOOLEAN;
  p_spUpdateGenerated_aa1eca6c6a47 BOOLEAN;
  p_spDeleteGenerated_aa1eca6c6a47 BOOLEAN;
  p_CascadeDeletes_aa1eca6c6a47 BOOLEAN;
  p_DeleteType_aa1eca6c6a47 VARCHAR(10);
  p_AllowRecordMerge_aa1eca6c6a47 BOOLEAN;
  p_spMatch_aa1eca6c6a47 VARCHAR(255);
  p_RelationshipDefaultDisplayType_aa1eca6c6a47 VARCHAR(20);
  p_UserFormGenerated_aa1eca6c6a47 BOOLEAN;
  p_EntityObjectSubclassName_aa1eca6c6a47 VARCHAR(255);
  p_EntityObjectSubclassImport_aa1eca6c6a47 VARCHAR(255);
  p_PreferredCommunicationField_aa1eca6c6a47 VARCHAR(255);
  p_Icon_aa1eca6c6a47 VARCHAR(500);
  p_ScopeDefault_aa1eca6c6a47 VARCHAR(100);
  p_RowsToPackWithSchema_aa1eca6c6a47 VARCHAR(20);
  p_RowsToPackSampleMethod_aa1eca6c6a47 VARCHAR(20);
  p_RowsToPackSampleCount_aa1eca6c6a47 INTEGER;
  p_RowsToPackSampleOrder_aa1eca6c6a47 TEXT;
  p_AutoRowCountFrequency_aa1eca6c6a47 INTEGER;
  p_RowCount_aa1eca6c6a47 BIGINT;
  p_RowCountRunAt_aa1eca6c6a47 TIMESTAMPTZ;
  p_Status_aa1eca6c6a47 VARCHAR(25);
  p_DisplayName_aa1eca6c6a47 VARCHAR(255);
  p_AllowMultipleSubtypes_aa1eca6c6a47 BOOLEAN;
  p_AutoUpdateFullTextSearch_aa1eca6c6a47 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_aa1eca6c6a47 BOOLEAN;
  p_TrustServerCacheCompletely_aa1eca6c6a47 BOOLEAN;
  p_SupportsGeoCoding_aa1eca6c6a47 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_aa1eca6c6a47 BOOLEAN;
  p_AllowCaching_aa1eca6c6a47 BOOLEAN;
  p_DetectExternalChanges_aa1eca6c6a47 BOOLEAN;
  p_ExternalDataSourceID_aa1eca6c6a47 UUID;
  p_ExternalObjectName_aa1eca6c6a47 VARCHAR(255);
  p_GeneratedBaseViewName_aa1eca6c6a47 VARCHAR(255);
  p_AllowDirectSQLInsert_aa1eca6c6a47 BOOLEAN;
  p_AllowDirectSQLUpdate_aa1eca6c6a47 BOOLEAN;
  p_AllowDirectSQLDelete_aa1eca6c6a47 BOOLEAN;
  p_Configuration_aa1eca6c6a47 TEXT;
  p_SubtypeSelector_aa1eca6c6a47 TEXT;
  p_EnableFieldLevelSecurity_aa1eca6c6a47 BOOLEAN;
  p_ID_aa1eca6c6a47 UUID;
BEGIN
  p_Name_aa1eca6c6a47 := 'MJ_BizApps_Tasks: Task Activities';
  p_AutoUpdateDescription_aa1eca6c6a47 := TRUE;
  p_BaseView_aa1eca6c6a47 := 'vwTaskActivities';
  p_BaseViewGenerated_aa1eca6c6a47 := TRUE;
  p_VirtualEntity_aa1eca6c6a47 := FALSE;
  p_TrackRecordChanges_aa1eca6c6a47 := TRUE;
  p_AuditRecordAccess_aa1eca6c6a47 := FALSE;
  p_AuditViewRuns_aa1eca6c6a47 := FALSE;
  p_IncludeInAPI_aa1eca6c6a47 := TRUE;
  p_AllowAllRowsAPI_aa1eca6c6a47 := FALSE;
  p_AllowUpdateAPI_aa1eca6c6a47 := TRUE;
  p_AllowCreateAPI_aa1eca6c6a47 := TRUE;
  p_AllowDeleteAPI_aa1eca6c6a47 := TRUE;
  p_CustomResolverAPI_aa1eca6c6a47 := FALSE;
  p_AllowUserSearchAPI_aa1eca6c6a47 := FALSE;
  p_FullTextSearchEnabled_aa1eca6c6a47 := FALSE;
  p_FullTextCatalogGenerated_aa1eca6c6a47 := TRUE;
  p_FullTextIndexGenerated_aa1eca6c6a47 := TRUE;
  p_FullTextSearchFunctionGenerated_aa1eca6c6a47 := TRUE;
  p_UserViewMaxRows_aa1eca6c6a47 := 1000;
  p_spCreateGenerated_aa1eca6c6a47 := TRUE;
  p_spUpdateGenerated_aa1eca6c6a47 := TRUE;
  p_spDeleteGenerated_aa1eca6c6a47 := TRUE;
  p_CascadeDeletes_aa1eca6c6a47 := FALSE;
  p_DeleteType_aa1eca6c6a47 := 'Hard';
  p_AllowRecordMerge_aa1eca6c6a47 := FALSE;
  p_RelationshipDefaultDisplayType_aa1eca6c6a47 := 'Search';
  p_UserFormGenerated_aa1eca6c6a47 := TRUE;
  p_RowsToPackWithSchema_aa1eca6c6a47 := 'None';
  p_RowsToPackSampleMethod_aa1eca6c6a47 := 'random';
  p_RowsToPackSampleCount_aa1eca6c6a47 := 0;
  p_Status_aa1eca6c6a47 := 'Active';
  p_DisplayName_aa1eca6c6a47 := 'Task Activities';
  p_AllowMultipleSubtypes_aa1eca6c6a47 := FALSE;
  p_AutoUpdateFullTextSearch_aa1eca6c6a47 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_aa1eca6c6a47 := FALSE;
  p_TrustServerCacheCompletely_aa1eca6c6a47 := TRUE;
  p_SupportsGeoCoding_aa1eca6c6a47 := FALSE;
  p_AutoUpdateSupportsGeoCoding_aa1eca6c6a47 := TRUE;
  p_AllowCaching_aa1eca6c6a47 := FALSE;
  p_DetectExternalChanges_aa1eca6c6a47 := FALSE;
  p_AllowDirectSQLInsert_aa1eca6c6a47 := FALSE;
  p_AllowDirectSQLUpdate_aa1eca6c6a47 := FALSE;
  p_AllowDirectSQLDelete_aa1eca6c6a47 := FALSE;
  p_EnableFieldLevelSecurity_aa1eca6c6a47 := FALSE;
  p_ID_aa1eca6c6a47 := '6615EF77-83F1-49F1-B717-80EC31F77486';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_aa1eca6c6a47,
    'Name', p_Name_aa1eca6c6a47,
    'NameSuffix', p_NameSuffix_aa1eca6c6a47,
    'Description', p_Description_aa1eca6c6a47,
    'AutoUpdateDescription', p_AutoUpdateDescription_aa1eca6c6a47,
    'BaseView', p_BaseView_aa1eca6c6a47,
    'BaseViewGenerated', p_BaseViewGenerated_aa1eca6c6a47,
    'VirtualEntity', p_VirtualEntity_aa1eca6c6a47,
    'TrackRecordChanges', p_TrackRecordChanges_aa1eca6c6a47,
    'AuditRecordAccess', p_AuditRecordAccess_aa1eca6c6a47,
    'AuditViewRuns', p_AuditViewRuns_aa1eca6c6a47,
    'IncludeInAPI', p_IncludeInAPI_aa1eca6c6a47,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_aa1eca6c6a47,
    'AllowUpdateAPI', p_AllowUpdateAPI_aa1eca6c6a47,
    'AllowCreateAPI', p_AllowCreateAPI_aa1eca6c6a47,
    'AllowDeleteAPI', p_AllowDeleteAPI_aa1eca6c6a47,
    'CustomResolverAPI', p_CustomResolverAPI_aa1eca6c6a47,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_aa1eca6c6a47,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_aa1eca6c6a47,
    'FullTextCatalog', p_FullTextCatalog_aa1eca6c6a47,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_aa1eca6c6a47,
    'FullTextIndex', p_FullTextIndex_aa1eca6c6a47,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_aa1eca6c6a47,
    'FullTextSearchFunction', p_FullTextSearchFunction_aa1eca6c6a47,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_aa1eca6c6a47,
    'UserViewMaxRows', p_UserViewMaxRows_aa1eca6c6a47,
    'spCreate', p_spCreate_aa1eca6c6a47,
    'spUpdate', p_spUpdate_aa1eca6c6a47,
    'spDelete', p_spDelete_aa1eca6c6a47,
    'spCreateGenerated', p_spCreateGenerated_aa1eca6c6a47,
    'spUpdateGenerated', p_spUpdateGenerated_aa1eca6c6a47,
    'spDeleteGenerated', p_spDeleteGenerated_aa1eca6c6a47,
    'CascadeDeletes', p_CascadeDeletes_aa1eca6c6a47,
    'DeleteType', p_DeleteType_aa1eca6c6a47,
    'AllowRecordMerge', p_AllowRecordMerge_aa1eca6c6a47,
    'spMatch', p_spMatch_aa1eca6c6a47,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_aa1eca6c6a47,
    'UserFormGenerated', p_UserFormGenerated_aa1eca6c6a47,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_aa1eca6c6a47,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_aa1eca6c6a47,
    'PreferredCommunicationField', p_PreferredCommunicationField_aa1eca6c6a47,
    'Icon', p_Icon_aa1eca6c6a47,
    'ScopeDefault', p_ScopeDefault_aa1eca6c6a47,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_aa1eca6c6a47,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_aa1eca6c6a47,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_aa1eca6c6a47,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_aa1eca6c6a47,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_aa1eca6c6a47,
    'RowCount', p_RowCount_aa1eca6c6a47,
    'RowCountRunAt', p_RowCountRunAt_aa1eca6c6a47
  ) ||
  jsonb_build_object(
    'Status', p_Status_aa1eca6c6a47,
    'DisplayName', p_DisplayName_aa1eca6c6a47,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_aa1eca6c6a47,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_aa1eca6c6a47,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_aa1eca6c6a47,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_aa1eca6c6a47,
    'SupportsGeoCoding', p_SupportsGeoCoding_aa1eca6c6a47,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_aa1eca6c6a47,
    'AllowCaching', p_AllowCaching_aa1eca6c6a47,
    'DetectExternalChanges', p_DetectExternalChanges_aa1eca6c6a47,
    'ExternalDataSourceID', p_ExternalDataSourceID_aa1eca6c6a47,
    'ExternalObjectName', p_ExternalObjectName_aa1eca6c6a47,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_aa1eca6c6a47,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_aa1eca6c6a47,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_aa1eca6c6a47,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_aa1eca6c6a47,
    'Configuration', p_Configuration_aa1eca6c6a47,
    'SubtypeSelector', p_SubtypeSelector_aa1eca6c6a47,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_aa1eca6c6a47,
    'ID', p_ID_aa1eca6c6a47
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_88412627162d UUID;
  p_Name_88412627162d VARCHAR(255);
  p_NameSuffix_88412627162d VARCHAR(255);
  p_Description_88412627162d TEXT;
  p_AutoUpdateDescription_88412627162d BOOLEAN;
  p_BaseView_88412627162d VARCHAR(255);
  p_BaseViewGenerated_88412627162d BOOLEAN;
  p_VirtualEntity_88412627162d BOOLEAN;
  p_TrackRecordChanges_88412627162d BOOLEAN;
  p_AuditRecordAccess_88412627162d BOOLEAN;
  p_AuditViewRuns_88412627162d BOOLEAN;
  p_IncludeInAPI_88412627162d BOOLEAN;
  p_AllowAllRowsAPI_88412627162d BOOLEAN;
  p_AllowUpdateAPI_88412627162d BOOLEAN;
  p_AllowCreateAPI_88412627162d BOOLEAN;
  p_AllowDeleteAPI_88412627162d BOOLEAN;
  p_CustomResolverAPI_88412627162d BOOLEAN;
  p_AllowUserSearchAPI_88412627162d BOOLEAN;
  p_FullTextSearchEnabled_88412627162d BOOLEAN;
  p_FullTextCatalog_88412627162d VARCHAR(255);
  p_FullTextCatalogGenerated_88412627162d BOOLEAN;
  p_FullTextIndex_88412627162d VARCHAR(255);
  p_FullTextIndexGenerated_88412627162d BOOLEAN;
  p_FullTextSearchFunction_88412627162d VARCHAR(255);
  p_FullTextSearchFunctionGenerated_88412627162d BOOLEAN;
  p_UserViewMaxRows_88412627162d INTEGER;
  p_spCreate_88412627162d VARCHAR(255);
  p_spUpdate_88412627162d VARCHAR(255);
  p_spDelete_88412627162d VARCHAR(255);
  p_spCreateGenerated_88412627162d BOOLEAN;
  p_spUpdateGenerated_88412627162d BOOLEAN;
  p_spDeleteGenerated_88412627162d BOOLEAN;
  p_CascadeDeletes_88412627162d BOOLEAN;
  p_DeleteType_88412627162d VARCHAR(10);
  p_AllowRecordMerge_88412627162d BOOLEAN;
  p_spMatch_88412627162d VARCHAR(255);
  p_RelationshipDefaultDisplayType_88412627162d VARCHAR(20);
  p_UserFormGenerated_88412627162d BOOLEAN;
  p_EntityObjectSubclassName_88412627162d VARCHAR(255);
  p_EntityObjectSubclassImport_88412627162d VARCHAR(255);
  p_PreferredCommunicationField_88412627162d VARCHAR(255);
  p_Icon_88412627162d VARCHAR(500);
  p_ScopeDefault_88412627162d VARCHAR(100);
  p_RowsToPackWithSchema_88412627162d VARCHAR(20);
  p_RowsToPackSampleMethod_88412627162d VARCHAR(20);
  p_RowsToPackSampleCount_88412627162d INTEGER;
  p_RowsToPackSampleOrder_88412627162d TEXT;
  p_AutoRowCountFrequency_88412627162d INTEGER;
  p_RowCount_88412627162d BIGINT;
  p_RowCountRunAt_88412627162d TIMESTAMPTZ;
  p_Status_88412627162d VARCHAR(25);
  p_DisplayName_88412627162d VARCHAR(255);
  p_AllowMultipleSubtypes_88412627162d BOOLEAN;
  p_AutoUpdateFullTextSearch_88412627162d BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_88412627162d BOOLEAN;
  p_TrustServerCacheCompletely_88412627162d BOOLEAN;
  p_SupportsGeoCoding_88412627162d BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_88412627162d BOOLEAN;
  p_AllowCaching_88412627162d BOOLEAN;
  p_DetectExternalChanges_88412627162d BOOLEAN;
  p_ExternalDataSourceID_88412627162d UUID;
  p_ExternalObjectName_88412627162d VARCHAR(255);
  p_GeneratedBaseViewName_88412627162d VARCHAR(255);
  p_AllowDirectSQLInsert_88412627162d BOOLEAN;
  p_AllowDirectSQLUpdate_88412627162d BOOLEAN;
  p_AllowDirectSQLDelete_88412627162d BOOLEAN;
  p_Configuration_88412627162d TEXT;
  p_SubtypeSelector_88412627162d TEXT;
  p_EnableFieldLevelSecurity_88412627162d BOOLEAN;
  p_ID_88412627162d UUID;
BEGIN
  p_Name_88412627162d := 'MJ_BizApps_Tasks: Task Assignments';
  p_AutoUpdateDescription_88412627162d := TRUE;
  p_BaseView_88412627162d := 'vwTaskAssignments';
  p_BaseViewGenerated_88412627162d := TRUE;
  p_VirtualEntity_88412627162d := FALSE;
  p_TrackRecordChanges_88412627162d := TRUE;
  p_AuditRecordAccess_88412627162d := FALSE;
  p_AuditViewRuns_88412627162d := FALSE;
  p_IncludeInAPI_88412627162d := TRUE;
  p_AllowAllRowsAPI_88412627162d := FALSE;
  p_AllowUpdateAPI_88412627162d := TRUE;
  p_AllowCreateAPI_88412627162d := TRUE;
  p_AllowDeleteAPI_88412627162d := TRUE;
  p_CustomResolverAPI_88412627162d := FALSE;
  p_AllowUserSearchAPI_88412627162d := FALSE;
  p_FullTextSearchEnabled_88412627162d := FALSE;
  p_FullTextCatalogGenerated_88412627162d := TRUE;
  p_FullTextIndexGenerated_88412627162d := TRUE;
  p_FullTextSearchFunctionGenerated_88412627162d := TRUE;
  p_UserViewMaxRows_88412627162d := 1000;
  p_spCreateGenerated_88412627162d := TRUE;
  p_spUpdateGenerated_88412627162d := TRUE;
  p_spDeleteGenerated_88412627162d := TRUE;
  p_CascadeDeletes_88412627162d := FALSE;
  p_DeleteType_88412627162d := 'Hard';
  p_AllowRecordMerge_88412627162d := FALSE;
  p_RelationshipDefaultDisplayType_88412627162d := 'Search';
  p_UserFormGenerated_88412627162d := TRUE;
  p_RowsToPackWithSchema_88412627162d := 'None';
  p_RowsToPackSampleMethod_88412627162d := 'random';
  p_RowsToPackSampleCount_88412627162d := 0;
  p_Status_88412627162d := 'Active';
  p_DisplayName_88412627162d := 'Task Assignments';
  p_AllowMultipleSubtypes_88412627162d := FALSE;
  p_AutoUpdateFullTextSearch_88412627162d := TRUE;
  p_AutoUpdateAllowUserSearchAPI_88412627162d := FALSE;
  p_TrustServerCacheCompletely_88412627162d := TRUE;
  p_SupportsGeoCoding_88412627162d := FALSE;
  p_AutoUpdateSupportsGeoCoding_88412627162d := TRUE;
  p_AllowCaching_88412627162d := FALSE;
  p_DetectExternalChanges_88412627162d := FALSE;
  p_AllowDirectSQLInsert_88412627162d := FALSE;
  p_AllowDirectSQLUpdate_88412627162d := FALSE;
  p_AllowDirectSQLDelete_88412627162d := FALSE;
  p_EnableFieldLevelSecurity_88412627162d := FALSE;
  p_ID_88412627162d := 'DF98E700-1992-442B-B93E-E47379F2CA52';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_88412627162d,
    'Name', p_Name_88412627162d,
    'NameSuffix', p_NameSuffix_88412627162d,
    'Description', p_Description_88412627162d,
    'AutoUpdateDescription', p_AutoUpdateDescription_88412627162d,
    'BaseView', p_BaseView_88412627162d,
    'BaseViewGenerated', p_BaseViewGenerated_88412627162d,
    'VirtualEntity', p_VirtualEntity_88412627162d,
    'TrackRecordChanges', p_TrackRecordChanges_88412627162d,
    'AuditRecordAccess', p_AuditRecordAccess_88412627162d,
    'AuditViewRuns', p_AuditViewRuns_88412627162d,
    'IncludeInAPI', p_IncludeInAPI_88412627162d,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_88412627162d,
    'AllowUpdateAPI', p_AllowUpdateAPI_88412627162d,
    'AllowCreateAPI', p_AllowCreateAPI_88412627162d,
    'AllowDeleteAPI', p_AllowDeleteAPI_88412627162d,
    'CustomResolverAPI', p_CustomResolverAPI_88412627162d,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_88412627162d,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_88412627162d,
    'FullTextCatalog', p_FullTextCatalog_88412627162d,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_88412627162d,
    'FullTextIndex', p_FullTextIndex_88412627162d,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_88412627162d,
    'FullTextSearchFunction', p_FullTextSearchFunction_88412627162d,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_88412627162d,
    'UserViewMaxRows', p_UserViewMaxRows_88412627162d,
    'spCreate', p_spCreate_88412627162d,
    'spUpdate', p_spUpdate_88412627162d,
    'spDelete', p_spDelete_88412627162d,
    'spCreateGenerated', p_spCreateGenerated_88412627162d,
    'spUpdateGenerated', p_spUpdateGenerated_88412627162d,
    'spDeleteGenerated', p_spDeleteGenerated_88412627162d,
    'CascadeDeletes', p_CascadeDeletes_88412627162d,
    'DeleteType', p_DeleteType_88412627162d,
    'AllowRecordMerge', p_AllowRecordMerge_88412627162d,
    'spMatch', p_spMatch_88412627162d,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_88412627162d,
    'UserFormGenerated', p_UserFormGenerated_88412627162d,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_88412627162d,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_88412627162d,
    'PreferredCommunicationField', p_PreferredCommunicationField_88412627162d,
    'Icon', p_Icon_88412627162d,
    'ScopeDefault', p_ScopeDefault_88412627162d,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_88412627162d,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_88412627162d,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_88412627162d,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_88412627162d,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_88412627162d,
    'RowCount', p_RowCount_88412627162d,
    'RowCountRunAt', p_RowCountRunAt_88412627162d
  ) ||
  jsonb_build_object(
    'Status', p_Status_88412627162d,
    'DisplayName', p_DisplayName_88412627162d,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_88412627162d,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_88412627162d,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_88412627162d,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_88412627162d,
    'SupportsGeoCoding', p_SupportsGeoCoding_88412627162d,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_88412627162d,
    'AllowCaching', p_AllowCaching_88412627162d,
    'DetectExternalChanges', p_DetectExternalChanges_88412627162d,
    'ExternalDataSourceID', p_ExternalDataSourceID_88412627162d,
    'ExternalObjectName', p_ExternalObjectName_88412627162d,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_88412627162d,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_88412627162d,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_88412627162d,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_88412627162d,
    'Configuration', p_Configuration_88412627162d,
    'SubtypeSelector', p_SubtypeSelector_88412627162d,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_88412627162d,
    'ID', p_ID_88412627162d
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_c5d6792092f6 UUID;
  p_Name_c5d6792092f6 VARCHAR(255);
  p_NameSuffix_c5d6792092f6 VARCHAR(255);
  p_Description_c5d6792092f6 TEXT;
  p_AutoUpdateDescription_c5d6792092f6 BOOLEAN;
  p_BaseView_c5d6792092f6 VARCHAR(255);
  p_BaseViewGenerated_c5d6792092f6 BOOLEAN;
  p_VirtualEntity_c5d6792092f6 BOOLEAN;
  p_TrackRecordChanges_c5d6792092f6 BOOLEAN;
  p_AuditRecordAccess_c5d6792092f6 BOOLEAN;
  p_AuditViewRuns_c5d6792092f6 BOOLEAN;
  p_IncludeInAPI_c5d6792092f6 BOOLEAN;
  p_AllowAllRowsAPI_c5d6792092f6 BOOLEAN;
  p_AllowUpdateAPI_c5d6792092f6 BOOLEAN;
  p_AllowCreateAPI_c5d6792092f6 BOOLEAN;
  p_AllowDeleteAPI_c5d6792092f6 BOOLEAN;
  p_CustomResolverAPI_c5d6792092f6 BOOLEAN;
  p_AllowUserSearchAPI_c5d6792092f6 BOOLEAN;
  p_FullTextSearchEnabled_c5d6792092f6 BOOLEAN;
  p_FullTextCatalog_c5d6792092f6 VARCHAR(255);
  p_FullTextCatalogGenerated_c5d6792092f6 BOOLEAN;
  p_FullTextIndex_c5d6792092f6 VARCHAR(255);
  p_FullTextIndexGenerated_c5d6792092f6 BOOLEAN;
  p_FullTextSearchFunction_c5d6792092f6 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_c5d6792092f6 BOOLEAN;
  p_UserViewMaxRows_c5d6792092f6 INTEGER;
  p_spCreate_c5d6792092f6 VARCHAR(255);
  p_spUpdate_c5d6792092f6 VARCHAR(255);
  p_spDelete_c5d6792092f6 VARCHAR(255);
  p_spCreateGenerated_c5d6792092f6 BOOLEAN;
  p_spUpdateGenerated_c5d6792092f6 BOOLEAN;
  p_spDeleteGenerated_c5d6792092f6 BOOLEAN;
  p_CascadeDeletes_c5d6792092f6 BOOLEAN;
  p_DeleteType_c5d6792092f6 VARCHAR(10);
  p_AllowRecordMerge_c5d6792092f6 BOOLEAN;
  p_spMatch_c5d6792092f6 VARCHAR(255);
  p_RelationshipDefaultDisplayType_c5d6792092f6 VARCHAR(20);
  p_UserFormGenerated_c5d6792092f6 BOOLEAN;
  p_EntityObjectSubclassName_c5d6792092f6 VARCHAR(255);
  p_EntityObjectSubclassImport_c5d6792092f6 VARCHAR(255);
  p_PreferredCommunicationField_c5d6792092f6 VARCHAR(255);
  p_Icon_c5d6792092f6 VARCHAR(500);
  p_ScopeDefault_c5d6792092f6 VARCHAR(100);
  p_RowsToPackWithSchema_c5d6792092f6 VARCHAR(20);
  p_RowsToPackSampleMethod_c5d6792092f6 VARCHAR(20);
  p_RowsToPackSampleCount_c5d6792092f6 INTEGER;
  p_RowsToPackSampleOrder_c5d6792092f6 TEXT;
  p_AutoRowCountFrequency_c5d6792092f6 INTEGER;
  p_RowCount_c5d6792092f6 BIGINT;
  p_RowCountRunAt_c5d6792092f6 TIMESTAMPTZ;
  p_Status_c5d6792092f6 VARCHAR(25);
  p_DisplayName_c5d6792092f6 VARCHAR(255);
  p_AllowMultipleSubtypes_c5d6792092f6 BOOLEAN;
  p_AutoUpdateFullTextSearch_c5d6792092f6 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_c5d6792092f6 BOOLEAN;
  p_TrustServerCacheCompletely_c5d6792092f6 BOOLEAN;
  p_SupportsGeoCoding_c5d6792092f6 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_c5d6792092f6 BOOLEAN;
  p_AllowCaching_c5d6792092f6 BOOLEAN;
  p_DetectExternalChanges_c5d6792092f6 BOOLEAN;
  p_ExternalDataSourceID_c5d6792092f6 UUID;
  p_ExternalObjectName_c5d6792092f6 VARCHAR(255);
  p_GeneratedBaseViewName_c5d6792092f6 VARCHAR(255);
  p_AllowDirectSQLInsert_c5d6792092f6 BOOLEAN;
  p_AllowDirectSQLUpdate_c5d6792092f6 BOOLEAN;
  p_AllowDirectSQLDelete_c5d6792092f6 BOOLEAN;
  p_Configuration_c5d6792092f6 TEXT;
  p_SubtypeSelector_c5d6792092f6 TEXT;
  p_EnableFieldLevelSecurity_c5d6792092f6 BOOLEAN;
  p_ID_c5d6792092f6 UUID;
BEGIN
  p_Name_c5d6792092f6 := 'MJ_BizApps_Tasks: Task Comments';
  p_AutoUpdateDescription_c5d6792092f6 := TRUE;
  p_BaseView_c5d6792092f6 := 'vwTaskComments';
  p_BaseViewGenerated_c5d6792092f6 := TRUE;
  p_VirtualEntity_c5d6792092f6 := FALSE;
  p_TrackRecordChanges_c5d6792092f6 := TRUE;
  p_AuditRecordAccess_c5d6792092f6 := FALSE;
  p_AuditViewRuns_c5d6792092f6 := FALSE;
  p_IncludeInAPI_c5d6792092f6 := TRUE;
  p_AllowAllRowsAPI_c5d6792092f6 := FALSE;
  p_AllowUpdateAPI_c5d6792092f6 := TRUE;
  p_AllowCreateAPI_c5d6792092f6 := TRUE;
  p_AllowDeleteAPI_c5d6792092f6 := TRUE;
  p_CustomResolverAPI_c5d6792092f6 := FALSE;
  p_AllowUserSearchAPI_c5d6792092f6 := FALSE;
  p_FullTextSearchEnabled_c5d6792092f6 := FALSE;
  p_FullTextCatalogGenerated_c5d6792092f6 := TRUE;
  p_FullTextIndexGenerated_c5d6792092f6 := TRUE;
  p_FullTextSearchFunctionGenerated_c5d6792092f6 := TRUE;
  p_UserViewMaxRows_c5d6792092f6 := 1000;
  p_spCreateGenerated_c5d6792092f6 := TRUE;
  p_spUpdateGenerated_c5d6792092f6 := TRUE;
  p_spDeleteGenerated_c5d6792092f6 := TRUE;
  p_CascadeDeletes_c5d6792092f6 := FALSE;
  p_DeleteType_c5d6792092f6 := 'Hard';
  p_AllowRecordMerge_c5d6792092f6 := FALSE;
  p_RelationshipDefaultDisplayType_c5d6792092f6 := 'Search';
  p_UserFormGenerated_c5d6792092f6 := TRUE;
  p_RowsToPackWithSchema_c5d6792092f6 := 'None';
  p_RowsToPackSampleMethod_c5d6792092f6 := 'random';
  p_RowsToPackSampleCount_c5d6792092f6 := 0;
  p_Status_c5d6792092f6 := 'Active';
  p_DisplayName_c5d6792092f6 := 'Task Comments';
  p_AllowMultipleSubtypes_c5d6792092f6 := FALSE;
  p_AutoUpdateFullTextSearch_c5d6792092f6 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_c5d6792092f6 := FALSE;
  p_TrustServerCacheCompletely_c5d6792092f6 := TRUE;
  p_SupportsGeoCoding_c5d6792092f6 := FALSE;
  p_AutoUpdateSupportsGeoCoding_c5d6792092f6 := TRUE;
  p_AllowCaching_c5d6792092f6 := FALSE;
  p_DetectExternalChanges_c5d6792092f6 := FALSE;
  p_AllowDirectSQLInsert_c5d6792092f6 := FALSE;
  p_AllowDirectSQLUpdate_c5d6792092f6 := FALSE;
  p_AllowDirectSQLDelete_c5d6792092f6 := FALSE;
  p_EnableFieldLevelSecurity_c5d6792092f6 := FALSE;
  p_ID_c5d6792092f6 := 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_c5d6792092f6,
    'Name', p_Name_c5d6792092f6,
    'NameSuffix', p_NameSuffix_c5d6792092f6,
    'Description', p_Description_c5d6792092f6,
    'AutoUpdateDescription', p_AutoUpdateDescription_c5d6792092f6,
    'BaseView', p_BaseView_c5d6792092f6,
    'BaseViewGenerated', p_BaseViewGenerated_c5d6792092f6,
    'VirtualEntity', p_VirtualEntity_c5d6792092f6,
    'TrackRecordChanges', p_TrackRecordChanges_c5d6792092f6,
    'AuditRecordAccess', p_AuditRecordAccess_c5d6792092f6,
    'AuditViewRuns', p_AuditViewRuns_c5d6792092f6,
    'IncludeInAPI', p_IncludeInAPI_c5d6792092f6,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_c5d6792092f6,
    'AllowUpdateAPI', p_AllowUpdateAPI_c5d6792092f6,
    'AllowCreateAPI', p_AllowCreateAPI_c5d6792092f6,
    'AllowDeleteAPI', p_AllowDeleteAPI_c5d6792092f6,
    'CustomResolverAPI', p_CustomResolverAPI_c5d6792092f6,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_c5d6792092f6,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_c5d6792092f6,
    'FullTextCatalog', p_FullTextCatalog_c5d6792092f6,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_c5d6792092f6,
    'FullTextIndex', p_FullTextIndex_c5d6792092f6,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_c5d6792092f6,
    'FullTextSearchFunction', p_FullTextSearchFunction_c5d6792092f6,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_c5d6792092f6,
    'UserViewMaxRows', p_UserViewMaxRows_c5d6792092f6,
    'spCreate', p_spCreate_c5d6792092f6,
    'spUpdate', p_spUpdate_c5d6792092f6,
    'spDelete', p_spDelete_c5d6792092f6,
    'spCreateGenerated', p_spCreateGenerated_c5d6792092f6,
    'spUpdateGenerated', p_spUpdateGenerated_c5d6792092f6,
    'spDeleteGenerated', p_spDeleteGenerated_c5d6792092f6,
    'CascadeDeletes', p_CascadeDeletes_c5d6792092f6,
    'DeleteType', p_DeleteType_c5d6792092f6,
    'AllowRecordMerge', p_AllowRecordMerge_c5d6792092f6,
    'spMatch', p_spMatch_c5d6792092f6,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_c5d6792092f6,
    'UserFormGenerated', p_UserFormGenerated_c5d6792092f6,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_c5d6792092f6,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_c5d6792092f6,
    'PreferredCommunicationField', p_PreferredCommunicationField_c5d6792092f6,
    'Icon', p_Icon_c5d6792092f6,
    'ScopeDefault', p_ScopeDefault_c5d6792092f6,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_c5d6792092f6,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_c5d6792092f6,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_c5d6792092f6,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_c5d6792092f6,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_c5d6792092f6,
    'RowCount', p_RowCount_c5d6792092f6,
    'RowCountRunAt', p_RowCountRunAt_c5d6792092f6
  ) ||
  jsonb_build_object(
    'Status', p_Status_c5d6792092f6,
    'DisplayName', p_DisplayName_c5d6792092f6,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_c5d6792092f6,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_c5d6792092f6,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_c5d6792092f6,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_c5d6792092f6,
    'SupportsGeoCoding', p_SupportsGeoCoding_c5d6792092f6,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_c5d6792092f6,
    'AllowCaching', p_AllowCaching_c5d6792092f6,
    'DetectExternalChanges', p_DetectExternalChanges_c5d6792092f6,
    'ExternalDataSourceID', p_ExternalDataSourceID_c5d6792092f6,
    'ExternalObjectName', p_ExternalObjectName_c5d6792092f6,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_c5d6792092f6,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_c5d6792092f6,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_c5d6792092f6,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_c5d6792092f6,
    'Configuration', p_Configuration_c5d6792092f6,
    'SubtypeSelector', p_SubtypeSelector_c5d6792092f6,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_c5d6792092f6,
    'ID', p_ID_c5d6792092f6
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_218a8c376671 UUID;
  p_Name_218a8c376671 VARCHAR(255);
  p_NameSuffix_218a8c376671 VARCHAR(255);
  p_Description_218a8c376671 TEXT;
  p_AutoUpdateDescription_218a8c376671 BOOLEAN;
  p_BaseView_218a8c376671 VARCHAR(255);
  p_BaseViewGenerated_218a8c376671 BOOLEAN;
  p_VirtualEntity_218a8c376671 BOOLEAN;
  p_TrackRecordChanges_218a8c376671 BOOLEAN;
  p_AuditRecordAccess_218a8c376671 BOOLEAN;
  p_AuditViewRuns_218a8c376671 BOOLEAN;
  p_IncludeInAPI_218a8c376671 BOOLEAN;
  p_AllowAllRowsAPI_218a8c376671 BOOLEAN;
  p_AllowUpdateAPI_218a8c376671 BOOLEAN;
  p_AllowCreateAPI_218a8c376671 BOOLEAN;
  p_AllowDeleteAPI_218a8c376671 BOOLEAN;
  p_CustomResolverAPI_218a8c376671 BOOLEAN;
  p_AllowUserSearchAPI_218a8c376671 BOOLEAN;
  p_FullTextSearchEnabled_218a8c376671 BOOLEAN;
  p_FullTextCatalog_218a8c376671 VARCHAR(255);
  p_FullTextCatalogGenerated_218a8c376671 BOOLEAN;
  p_FullTextIndex_218a8c376671 VARCHAR(255);
  p_FullTextIndexGenerated_218a8c376671 BOOLEAN;
  p_FullTextSearchFunction_218a8c376671 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_218a8c376671 BOOLEAN;
  p_UserViewMaxRows_218a8c376671 INTEGER;
  p_spCreate_218a8c376671 VARCHAR(255);
  p_spUpdate_218a8c376671 VARCHAR(255);
  p_spDelete_218a8c376671 VARCHAR(255);
  p_spCreateGenerated_218a8c376671 BOOLEAN;
  p_spUpdateGenerated_218a8c376671 BOOLEAN;
  p_spDeleteGenerated_218a8c376671 BOOLEAN;
  p_CascadeDeletes_218a8c376671 BOOLEAN;
  p_DeleteType_218a8c376671 VARCHAR(10);
  p_AllowRecordMerge_218a8c376671 BOOLEAN;
  p_spMatch_218a8c376671 VARCHAR(255);
  p_RelationshipDefaultDisplayType_218a8c376671 VARCHAR(20);
  p_UserFormGenerated_218a8c376671 BOOLEAN;
  p_EntityObjectSubclassName_218a8c376671 VARCHAR(255);
  p_EntityObjectSubclassImport_218a8c376671 VARCHAR(255);
  p_PreferredCommunicationField_218a8c376671 VARCHAR(255);
  p_Icon_218a8c376671 VARCHAR(500);
  p_ScopeDefault_218a8c376671 VARCHAR(100);
  p_RowsToPackWithSchema_218a8c376671 VARCHAR(20);
  p_RowsToPackSampleMethod_218a8c376671 VARCHAR(20);
  p_RowsToPackSampleCount_218a8c376671 INTEGER;
  p_RowsToPackSampleOrder_218a8c376671 TEXT;
  p_AutoRowCountFrequency_218a8c376671 INTEGER;
  p_RowCount_218a8c376671 BIGINT;
  p_RowCountRunAt_218a8c376671 TIMESTAMPTZ;
  p_Status_218a8c376671 VARCHAR(25);
  p_DisplayName_218a8c376671 VARCHAR(255);
  p_AllowMultipleSubtypes_218a8c376671 BOOLEAN;
  p_AutoUpdateFullTextSearch_218a8c376671 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_218a8c376671 BOOLEAN;
  p_TrustServerCacheCompletely_218a8c376671 BOOLEAN;
  p_SupportsGeoCoding_218a8c376671 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_218a8c376671 BOOLEAN;
  p_AllowCaching_218a8c376671 BOOLEAN;
  p_DetectExternalChanges_218a8c376671 BOOLEAN;
  p_ExternalDataSourceID_218a8c376671 UUID;
  p_ExternalObjectName_218a8c376671 VARCHAR(255);
  p_GeneratedBaseViewName_218a8c376671 VARCHAR(255);
  p_AllowDirectSQLInsert_218a8c376671 BOOLEAN;
  p_AllowDirectSQLUpdate_218a8c376671 BOOLEAN;
  p_AllowDirectSQLDelete_218a8c376671 BOOLEAN;
  p_Configuration_218a8c376671 TEXT;
  p_SubtypeSelector_218a8c376671 TEXT;
  p_EnableFieldLevelSecurity_218a8c376671 BOOLEAN;
  p_ID_218a8c376671 UUID;
BEGIN
  p_Name_218a8c376671 := 'MJ_BizApps_Tasks: Task Decision Outcomes';
  p_AutoUpdateDescription_218a8c376671 := TRUE;
  p_BaseView_218a8c376671 := 'vwTaskDecisionOutcomes';
  p_BaseViewGenerated_218a8c376671 := TRUE;
  p_VirtualEntity_218a8c376671 := FALSE;
  p_TrackRecordChanges_218a8c376671 := TRUE;
  p_AuditRecordAccess_218a8c376671 := FALSE;
  p_AuditViewRuns_218a8c376671 := FALSE;
  p_IncludeInAPI_218a8c376671 := TRUE;
  p_AllowAllRowsAPI_218a8c376671 := FALSE;
  p_AllowUpdateAPI_218a8c376671 := TRUE;
  p_AllowCreateAPI_218a8c376671 := TRUE;
  p_AllowDeleteAPI_218a8c376671 := TRUE;
  p_CustomResolverAPI_218a8c376671 := FALSE;
  p_AllowUserSearchAPI_218a8c376671 := FALSE;
  p_FullTextSearchEnabled_218a8c376671 := FALSE;
  p_FullTextCatalogGenerated_218a8c376671 := TRUE;
  p_FullTextIndexGenerated_218a8c376671 := TRUE;
  p_FullTextSearchFunctionGenerated_218a8c376671 := TRUE;
  p_UserViewMaxRows_218a8c376671 := 1000;
  p_spCreateGenerated_218a8c376671 := TRUE;
  p_spUpdateGenerated_218a8c376671 := TRUE;
  p_spDeleteGenerated_218a8c376671 := TRUE;
  p_CascadeDeletes_218a8c376671 := FALSE;
  p_DeleteType_218a8c376671 := 'Hard';
  p_AllowRecordMerge_218a8c376671 := FALSE;
  p_RelationshipDefaultDisplayType_218a8c376671 := 'Search';
  p_UserFormGenerated_218a8c376671 := TRUE;
  p_RowsToPackWithSchema_218a8c376671 := 'None';
  p_RowsToPackSampleMethod_218a8c376671 := 'random';
  p_RowsToPackSampleCount_218a8c376671 := 0;
  p_Status_218a8c376671 := 'Active';
  p_DisplayName_218a8c376671 := 'Task Decision Outcomes';
  p_AllowMultipleSubtypes_218a8c376671 := FALSE;
  p_AutoUpdateFullTextSearch_218a8c376671 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_218a8c376671 := FALSE;
  p_TrustServerCacheCompletely_218a8c376671 := TRUE;
  p_SupportsGeoCoding_218a8c376671 := FALSE;
  p_AutoUpdateSupportsGeoCoding_218a8c376671 := TRUE;
  p_AllowCaching_218a8c376671 := FALSE;
  p_DetectExternalChanges_218a8c376671 := FALSE;
  p_AllowDirectSQLInsert_218a8c376671 := FALSE;
  p_AllowDirectSQLUpdate_218a8c376671 := FALSE;
  p_AllowDirectSQLDelete_218a8c376671 := FALSE;
  p_EnableFieldLevelSecurity_218a8c376671 := FALSE;
  p_ID_218a8c376671 := 'D3868906-E957-4061-A79D-6CE7A96DC0ED';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_218a8c376671,
    'Name', p_Name_218a8c376671,
    'NameSuffix', p_NameSuffix_218a8c376671,
    'Description', p_Description_218a8c376671,
    'AutoUpdateDescription', p_AutoUpdateDescription_218a8c376671,
    'BaseView', p_BaseView_218a8c376671,
    'BaseViewGenerated', p_BaseViewGenerated_218a8c376671,
    'VirtualEntity', p_VirtualEntity_218a8c376671,
    'TrackRecordChanges', p_TrackRecordChanges_218a8c376671,
    'AuditRecordAccess', p_AuditRecordAccess_218a8c376671,
    'AuditViewRuns', p_AuditViewRuns_218a8c376671,
    'IncludeInAPI', p_IncludeInAPI_218a8c376671,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_218a8c376671,
    'AllowUpdateAPI', p_AllowUpdateAPI_218a8c376671,
    'AllowCreateAPI', p_AllowCreateAPI_218a8c376671,
    'AllowDeleteAPI', p_AllowDeleteAPI_218a8c376671,
    'CustomResolverAPI', p_CustomResolverAPI_218a8c376671,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_218a8c376671,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_218a8c376671,
    'FullTextCatalog', p_FullTextCatalog_218a8c376671,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_218a8c376671,
    'FullTextIndex', p_FullTextIndex_218a8c376671,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_218a8c376671,
    'FullTextSearchFunction', p_FullTextSearchFunction_218a8c376671,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_218a8c376671,
    'UserViewMaxRows', p_UserViewMaxRows_218a8c376671,
    'spCreate', p_spCreate_218a8c376671,
    'spUpdate', p_spUpdate_218a8c376671,
    'spDelete', p_spDelete_218a8c376671,
    'spCreateGenerated', p_spCreateGenerated_218a8c376671,
    'spUpdateGenerated', p_spUpdateGenerated_218a8c376671,
    'spDeleteGenerated', p_spDeleteGenerated_218a8c376671,
    'CascadeDeletes', p_CascadeDeletes_218a8c376671,
    'DeleteType', p_DeleteType_218a8c376671,
    'AllowRecordMerge', p_AllowRecordMerge_218a8c376671,
    'spMatch', p_spMatch_218a8c376671,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_218a8c376671,
    'UserFormGenerated', p_UserFormGenerated_218a8c376671,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_218a8c376671,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_218a8c376671,
    'PreferredCommunicationField', p_PreferredCommunicationField_218a8c376671,
    'Icon', p_Icon_218a8c376671,
    'ScopeDefault', p_ScopeDefault_218a8c376671,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_218a8c376671,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_218a8c376671,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_218a8c376671,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_218a8c376671,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_218a8c376671,
    'RowCount', p_RowCount_218a8c376671,
    'RowCountRunAt', p_RowCountRunAt_218a8c376671
  ) ||
  jsonb_build_object(
    'Status', p_Status_218a8c376671,
    'DisplayName', p_DisplayName_218a8c376671,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_218a8c376671,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_218a8c376671,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_218a8c376671,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_218a8c376671,
    'SupportsGeoCoding', p_SupportsGeoCoding_218a8c376671,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_218a8c376671,
    'AllowCaching', p_AllowCaching_218a8c376671,
    'DetectExternalChanges', p_DetectExternalChanges_218a8c376671,
    'ExternalDataSourceID', p_ExternalDataSourceID_218a8c376671,
    'ExternalObjectName', p_ExternalObjectName_218a8c376671,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_218a8c376671,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_218a8c376671,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_218a8c376671,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_218a8c376671,
    'Configuration', p_Configuration_218a8c376671,
    'SubtypeSelector', p_SubtypeSelector_218a8c376671,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_218a8c376671,
    'ID', p_ID_218a8c376671
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_5699580d5016 UUID;
  p_Name_5699580d5016 VARCHAR(255);
  p_NameSuffix_5699580d5016 VARCHAR(255);
  p_Description_5699580d5016 TEXT;
  p_AutoUpdateDescription_5699580d5016 BOOLEAN;
  p_BaseView_5699580d5016 VARCHAR(255);
  p_BaseViewGenerated_5699580d5016 BOOLEAN;
  p_VirtualEntity_5699580d5016 BOOLEAN;
  p_TrackRecordChanges_5699580d5016 BOOLEAN;
  p_AuditRecordAccess_5699580d5016 BOOLEAN;
  p_AuditViewRuns_5699580d5016 BOOLEAN;
  p_IncludeInAPI_5699580d5016 BOOLEAN;
  p_AllowAllRowsAPI_5699580d5016 BOOLEAN;
  p_AllowUpdateAPI_5699580d5016 BOOLEAN;
  p_AllowCreateAPI_5699580d5016 BOOLEAN;
  p_AllowDeleteAPI_5699580d5016 BOOLEAN;
  p_CustomResolverAPI_5699580d5016 BOOLEAN;
  p_AllowUserSearchAPI_5699580d5016 BOOLEAN;
  p_FullTextSearchEnabled_5699580d5016 BOOLEAN;
  p_FullTextCatalog_5699580d5016 VARCHAR(255);
  p_FullTextCatalogGenerated_5699580d5016 BOOLEAN;
  p_FullTextIndex_5699580d5016 VARCHAR(255);
  p_FullTextIndexGenerated_5699580d5016 BOOLEAN;
  p_FullTextSearchFunction_5699580d5016 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_5699580d5016 BOOLEAN;
  p_UserViewMaxRows_5699580d5016 INTEGER;
  p_spCreate_5699580d5016 VARCHAR(255);
  p_spUpdate_5699580d5016 VARCHAR(255);
  p_spDelete_5699580d5016 VARCHAR(255);
  p_spCreateGenerated_5699580d5016 BOOLEAN;
  p_spUpdateGenerated_5699580d5016 BOOLEAN;
  p_spDeleteGenerated_5699580d5016 BOOLEAN;
  p_CascadeDeletes_5699580d5016 BOOLEAN;
  p_DeleteType_5699580d5016 VARCHAR(10);
  p_AllowRecordMerge_5699580d5016 BOOLEAN;
  p_spMatch_5699580d5016 VARCHAR(255);
  p_RelationshipDefaultDisplayType_5699580d5016 VARCHAR(20);
  p_UserFormGenerated_5699580d5016 BOOLEAN;
  p_EntityObjectSubclassName_5699580d5016 VARCHAR(255);
  p_EntityObjectSubclassImport_5699580d5016 VARCHAR(255);
  p_PreferredCommunicationField_5699580d5016 VARCHAR(255);
  p_Icon_5699580d5016 VARCHAR(500);
  p_ScopeDefault_5699580d5016 VARCHAR(100);
  p_RowsToPackWithSchema_5699580d5016 VARCHAR(20);
  p_RowsToPackSampleMethod_5699580d5016 VARCHAR(20);
  p_RowsToPackSampleCount_5699580d5016 INTEGER;
  p_RowsToPackSampleOrder_5699580d5016 TEXT;
  p_AutoRowCountFrequency_5699580d5016 INTEGER;
  p_RowCount_5699580d5016 BIGINT;
  p_RowCountRunAt_5699580d5016 TIMESTAMPTZ;
  p_Status_5699580d5016 VARCHAR(25);
  p_DisplayName_5699580d5016 VARCHAR(255);
  p_AllowMultipleSubtypes_5699580d5016 BOOLEAN;
  p_AutoUpdateFullTextSearch_5699580d5016 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_5699580d5016 BOOLEAN;
  p_TrustServerCacheCompletely_5699580d5016 BOOLEAN;
  p_SupportsGeoCoding_5699580d5016 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_5699580d5016 BOOLEAN;
  p_AllowCaching_5699580d5016 BOOLEAN;
  p_DetectExternalChanges_5699580d5016 BOOLEAN;
  p_ExternalDataSourceID_5699580d5016 UUID;
  p_ExternalObjectName_5699580d5016 VARCHAR(255);
  p_GeneratedBaseViewName_5699580d5016 VARCHAR(255);
  p_AllowDirectSQLInsert_5699580d5016 BOOLEAN;
  p_AllowDirectSQLUpdate_5699580d5016 BOOLEAN;
  p_AllowDirectSQLDelete_5699580d5016 BOOLEAN;
  p_Configuration_5699580d5016 TEXT;
  p_SubtypeSelector_5699580d5016 TEXT;
  p_EnableFieldLevelSecurity_5699580d5016 BOOLEAN;
  p_ID_5699580d5016 UUID;
BEGIN
  p_Name_5699580d5016 := 'MJ_BizApps_Tasks: Task Decisions';
  p_AutoUpdateDescription_5699580d5016 := TRUE;
  p_BaseView_5699580d5016 := 'vwTaskDecisions';
  p_BaseViewGenerated_5699580d5016 := TRUE;
  p_VirtualEntity_5699580d5016 := FALSE;
  p_TrackRecordChanges_5699580d5016 := TRUE;
  p_AuditRecordAccess_5699580d5016 := FALSE;
  p_AuditViewRuns_5699580d5016 := FALSE;
  p_IncludeInAPI_5699580d5016 := TRUE;
  p_AllowAllRowsAPI_5699580d5016 := FALSE;
  p_AllowUpdateAPI_5699580d5016 := TRUE;
  p_AllowCreateAPI_5699580d5016 := TRUE;
  p_AllowDeleteAPI_5699580d5016 := TRUE;
  p_CustomResolverAPI_5699580d5016 := FALSE;
  p_AllowUserSearchAPI_5699580d5016 := FALSE;
  p_FullTextSearchEnabled_5699580d5016 := FALSE;
  p_FullTextCatalogGenerated_5699580d5016 := TRUE;
  p_FullTextIndexGenerated_5699580d5016 := TRUE;
  p_FullTextSearchFunctionGenerated_5699580d5016 := TRUE;
  p_UserViewMaxRows_5699580d5016 := 1000;
  p_spCreateGenerated_5699580d5016 := TRUE;
  p_spUpdateGenerated_5699580d5016 := TRUE;
  p_spDeleteGenerated_5699580d5016 := TRUE;
  p_CascadeDeletes_5699580d5016 := FALSE;
  p_DeleteType_5699580d5016 := 'Hard';
  p_AllowRecordMerge_5699580d5016 := FALSE;
  p_RelationshipDefaultDisplayType_5699580d5016 := 'Search';
  p_UserFormGenerated_5699580d5016 := TRUE;
  p_RowsToPackWithSchema_5699580d5016 := 'None';
  p_RowsToPackSampleMethod_5699580d5016 := 'random';
  p_RowsToPackSampleCount_5699580d5016 := 0;
  p_Status_5699580d5016 := 'Active';
  p_DisplayName_5699580d5016 := 'Task Decisions';
  p_AllowMultipleSubtypes_5699580d5016 := FALSE;
  p_AutoUpdateFullTextSearch_5699580d5016 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_5699580d5016 := FALSE;
  p_TrustServerCacheCompletely_5699580d5016 := TRUE;
  p_SupportsGeoCoding_5699580d5016 := FALSE;
  p_AutoUpdateSupportsGeoCoding_5699580d5016 := TRUE;
  p_AllowCaching_5699580d5016 := FALSE;
  p_DetectExternalChanges_5699580d5016 := FALSE;
  p_AllowDirectSQLInsert_5699580d5016 := FALSE;
  p_AllowDirectSQLUpdate_5699580d5016 := FALSE;
  p_AllowDirectSQLDelete_5699580d5016 := FALSE;
  p_EnableFieldLevelSecurity_5699580d5016 := FALSE;
  p_ID_5699580d5016 := '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_5699580d5016,
    'Name', p_Name_5699580d5016,
    'NameSuffix', p_NameSuffix_5699580d5016,
    'Description', p_Description_5699580d5016,
    'AutoUpdateDescription', p_AutoUpdateDescription_5699580d5016,
    'BaseView', p_BaseView_5699580d5016,
    'BaseViewGenerated', p_BaseViewGenerated_5699580d5016,
    'VirtualEntity', p_VirtualEntity_5699580d5016,
    'TrackRecordChanges', p_TrackRecordChanges_5699580d5016,
    'AuditRecordAccess', p_AuditRecordAccess_5699580d5016,
    'AuditViewRuns', p_AuditViewRuns_5699580d5016,
    'IncludeInAPI', p_IncludeInAPI_5699580d5016,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_5699580d5016,
    'AllowUpdateAPI', p_AllowUpdateAPI_5699580d5016,
    'AllowCreateAPI', p_AllowCreateAPI_5699580d5016,
    'AllowDeleteAPI', p_AllowDeleteAPI_5699580d5016,
    'CustomResolverAPI', p_CustomResolverAPI_5699580d5016,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_5699580d5016,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_5699580d5016,
    'FullTextCatalog', p_FullTextCatalog_5699580d5016,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_5699580d5016,
    'FullTextIndex', p_FullTextIndex_5699580d5016,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_5699580d5016,
    'FullTextSearchFunction', p_FullTextSearchFunction_5699580d5016,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_5699580d5016,
    'UserViewMaxRows', p_UserViewMaxRows_5699580d5016,
    'spCreate', p_spCreate_5699580d5016,
    'spUpdate', p_spUpdate_5699580d5016,
    'spDelete', p_spDelete_5699580d5016,
    'spCreateGenerated', p_spCreateGenerated_5699580d5016,
    'spUpdateGenerated', p_spUpdateGenerated_5699580d5016,
    'spDeleteGenerated', p_spDeleteGenerated_5699580d5016,
    'CascadeDeletes', p_CascadeDeletes_5699580d5016,
    'DeleteType', p_DeleteType_5699580d5016,
    'AllowRecordMerge', p_AllowRecordMerge_5699580d5016,
    'spMatch', p_spMatch_5699580d5016,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_5699580d5016,
    'UserFormGenerated', p_UserFormGenerated_5699580d5016,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_5699580d5016,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_5699580d5016,
    'PreferredCommunicationField', p_PreferredCommunicationField_5699580d5016,
    'Icon', p_Icon_5699580d5016,
    'ScopeDefault', p_ScopeDefault_5699580d5016,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_5699580d5016,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_5699580d5016,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_5699580d5016,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_5699580d5016,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_5699580d5016,
    'RowCount', p_RowCount_5699580d5016,
    'RowCountRunAt', p_RowCountRunAt_5699580d5016
  ) ||
  jsonb_build_object(
    'Status', p_Status_5699580d5016,
    'DisplayName', p_DisplayName_5699580d5016,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_5699580d5016,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_5699580d5016,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_5699580d5016,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_5699580d5016,
    'SupportsGeoCoding', p_SupportsGeoCoding_5699580d5016,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_5699580d5016,
    'AllowCaching', p_AllowCaching_5699580d5016,
    'DetectExternalChanges', p_DetectExternalChanges_5699580d5016,
    'ExternalDataSourceID', p_ExternalDataSourceID_5699580d5016,
    'ExternalObjectName', p_ExternalObjectName_5699580d5016,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_5699580d5016,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_5699580d5016,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_5699580d5016,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_5699580d5016,
    'Configuration', p_Configuration_5699580d5016,
    'SubtypeSelector', p_SubtypeSelector_5699580d5016,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_5699580d5016,
    'ID', p_ID_5699580d5016
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_602de2fdd484 UUID;
  p_Name_602de2fdd484 VARCHAR(255);
  p_NameSuffix_602de2fdd484 VARCHAR(255);
  p_Description_602de2fdd484 TEXT;
  p_AutoUpdateDescription_602de2fdd484 BOOLEAN;
  p_BaseView_602de2fdd484 VARCHAR(255);
  p_BaseViewGenerated_602de2fdd484 BOOLEAN;
  p_VirtualEntity_602de2fdd484 BOOLEAN;
  p_TrackRecordChanges_602de2fdd484 BOOLEAN;
  p_AuditRecordAccess_602de2fdd484 BOOLEAN;
  p_AuditViewRuns_602de2fdd484 BOOLEAN;
  p_IncludeInAPI_602de2fdd484 BOOLEAN;
  p_AllowAllRowsAPI_602de2fdd484 BOOLEAN;
  p_AllowUpdateAPI_602de2fdd484 BOOLEAN;
  p_AllowCreateAPI_602de2fdd484 BOOLEAN;
  p_AllowDeleteAPI_602de2fdd484 BOOLEAN;
  p_CustomResolverAPI_602de2fdd484 BOOLEAN;
  p_AllowUserSearchAPI_602de2fdd484 BOOLEAN;
  p_FullTextSearchEnabled_602de2fdd484 BOOLEAN;
  p_FullTextCatalog_602de2fdd484 VARCHAR(255);
  p_FullTextCatalogGenerated_602de2fdd484 BOOLEAN;
  p_FullTextIndex_602de2fdd484 VARCHAR(255);
  p_FullTextIndexGenerated_602de2fdd484 BOOLEAN;
  p_FullTextSearchFunction_602de2fdd484 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_602de2fdd484 BOOLEAN;
  p_UserViewMaxRows_602de2fdd484 INTEGER;
  p_spCreate_602de2fdd484 VARCHAR(255);
  p_spUpdate_602de2fdd484 VARCHAR(255);
  p_spDelete_602de2fdd484 VARCHAR(255);
  p_spCreateGenerated_602de2fdd484 BOOLEAN;
  p_spUpdateGenerated_602de2fdd484 BOOLEAN;
  p_spDeleteGenerated_602de2fdd484 BOOLEAN;
  p_CascadeDeletes_602de2fdd484 BOOLEAN;
  p_DeleteType_602de2fdd484 VARCHAR(10);
  p_AllowRecordMerge_602de2fdd484 BOOLEAN;
  p_spMatch_602de2fdd484 VARCHAR(255);
  p_RelationshipDefaultDisplayType_602de2fdd484 VARCHAR(20);
  p_UserFormGenerated_602de2fdd484 BOOLEAN;
  p_EntityObjectSubclassName_602de2fdd484 VARCHAR(255);
  p_EntityObjectSubclassImport_602de2fdd484 VARCHAR(255);
  p_PreferredCommunicationField_602de2fdd484 VARCHAR(255);
  p_Icon_602de2fdd484 VARCHAR(500);
  p_ScopeDefault_602de2fdd484 VARCHAR(100);
  p_RowsToPackWithSchema_602de2fdd484 VARCHAR(20);
  p_RowsToPackSampleMethod_602de2fdd484 VARCHAR(20);
  p_RowsToPackSampleCount_602de2fdd484 INTEGER;
  p_RowsToPackSampleOrder_602de2fdd484 TEXT;
  p_AutoRowCountFrequency_602de2fdd484 INTEGER;
  p_RowCount_602de2fdd484 BIGINT;
  p_RowCountRunAt_602de2fdd484 TIMESTAMPTZ;
  p_Status_602de2fdd484 VARCHAR(25);
  p_DisplayName_602de2fdd484 VARCHAR(255);
  p_AllowMultipleSubtypes_602de2fdd484 BOOLEAN;
  p_AutoUpdateFullTextSearch_602de2fdd484 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_602de2fdd484 BOOLEAN;
  p_TrustServerCacheCompletely_602de2fdd484 BOOLEAN;
  p_SupportsGeoCoding_602de2fdd484 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_602de2fdd484 BOOLEAN;
  p_AllowCaching_602de2fdd484 BOOLEAN;
  p_DetectExternalChanges_602de2fdd484 BOOLEAN;
  p_ExternalDataSourceID_602de2fdd484 UUID;
  p_ExternalObjectName_602de2fdd484 VARCHAR(255);
  p_GeneratedBaseViewName_602de2fdd484 VARCHAR(255);
  p_AllowDirectSQLInsert_602de2fdd484 BOOLEAN;
  p_AllowDirectSQLUpdate_602de2fdd484 BOOLEAN;
  p_AllowDirectSQLDelete_602de2fdd484 BOOLEAN;
  p_Configuration_602de2fdd484 TEXT;
  p_SubtypeSelector_602de2fdd484 TEXT;
  p_EnableFieldLevelSecurity_602de2fdd484 BOOLEAN;
  p_ID_602de2fdd484 UUID;
BEGIN
  p_Name_602de2fdd484 := 'MJ_BizApps_Tasks: Task Dependencies';
  p_AutoUpdateDescription_602de2fdd484 := TRUE;
  p_BaseView_602de2fdd484 := 'vwTaskDependencies';
  p_BaseViewGenerated_602de2fdd484 := TRUE;
  p_VirtualEntity_602de2fdd484 := FALSE;
  p_TrackRecordChanges_602de2fdd484 := TRUE;
  p_AuditRecordAccess_602de2fdd484 := FALSE;
  p_AuditViewRuns_602de2fdd484 := FALSE;
  p_IncludeInAPI_602de2fdd484 := TRUE;
  p_AllowAllRowsAPI_602de2fdd484 := FALSE;
  p_AllowUpdateAPI_602de2fdd484 := TRUE;
  p_AllowCreateAPI_602de2fdd484 := TRUE;
  p_AllowDeleteAPI_602de2fdd484 := TRUE;
  p_CustomResolverAPI_602de2fdd484 := FALSE;
  p_AllowUserSearchAPI_602de2fdd484 := FALSE;
  p_FullTextSearchEnabled_602de2fdd484 := FALSE;
  p_FullTextCatalogGenerated_602de2fdd484 := TRUE;
  p_FullTextIndexGenerated_602de2fdd484 := TRUE;
  p_FullTextSearchFunctionGenerated_602de2fdd484 := TRUE;
  p_UserViewMaxRows_602de2fdd484 := 1000;
  p_spCreateGenerated_602de2fdd484 := TRUE;
  p_spUpdateGenerated_602de2fdd484 := TRUE;
  p_spDeleteGenerated_602de2fdd484 := TRUE;
  p_CascadeDeletes_602de2fdd484 := FALSE;
  p_DeleteType_602de2fdd484 := 'Hard';
  p_AllowRecordMerge_602de2fdd484 := FALSE;
  p_RelationshipDefaultDisplayType_602de2fdd484 := 'Search';
  p_UserFormGenerated_602de2fdd484 := TRUE;
  p_RowsToPackWithSchema_602de2fdd484 := 'None';
  p_RowsToPackSampleMethod_602de2fdd484 := 'random';
  p_RowsToPackSampleCount_602de2fdd484 := 0;
  p_Status_602de2fdd484 := 'Active';
  p_DisplayName_602de2fdd484 := 'Task Dependencies';
  p_AllowMultipleSubtypes_602de2fdd484 := FALSE;
  p_AutoUpdateFullTextSearch_602de2fdd484 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_602de2fdd484 := FALSE;
  p_TrustServerCacheCompletely_602de2fdd484 := TRUE;
  p_SupportsGeoCoding_602de2fdd484 := FALSE;
  p_AutoUpdateSupportsGeoCoding_602de2fdd484 := TRUE;
  p_AllowCaching_602de2fdd484 := FALSE;
  p_DetectExternalChanges_602de2fdd484 := FALSE;
  p_AllowDirectSQLInsert_602de2fdd484 := FALSE;
  p_AllowDirectSQLUpdate_602de2fdd484 := FALSE;
  p_AllowDirectSQLDelete_602de2fdd484 := FALSE;
  p_EnableFieldLevelSecurity_602de2fdd484 := FALSE;
  p_ID_602de2fdd484 := '0662FC0F-3F2B-49C9-9BE8-5B59E036044A';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_602de2fdd484,
    'Name', p_Name_602de2fdd484,
    'NameSuffix', p_NameSuffix_602de2fdd484,
    'Description', p_Description_602de2fdd484,
    'AutoUpdateDescription', p_AutoUpdateDescription_602de2fdd484,
    'BaseView', p_BaseView_602de2fdd484,
    'BaseViewGenerated', p_BaseViewGenerated_602de2fdd484,
    'VirtualEntity', p_VirtualEntity_602de2fdd484,
    'TrackRecordChanges', p_TrackRecordChanges_602de2fdd484,
    'AuditRecordAccess', p_AuditRecordAccess_602de2fdd484,
    'AuditViewRuns', p_AuditViewRuns_602de2fdd484,
    'IncludeInAPI', p_IncludeInAPI_602de2fdd484,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_602de2fdd484,
    'AllowUpdateAPI', p_AllowUpdateAPI_602de2fdd484,
    'AllowCreateAPI', p_AllowCreateAPI_602de2fdd484,
    'AllowDeleteAPI', p_AllowDeleteAPI_602de2fdd484,
    'CustomResolverAPI', p_CustomResolverAPI_602de2fdd484,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_602de2fdd484,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_602de2fdd484,
    'FullTextCatalog', p_FullTextCatalog_602de2fdd484,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_602de2fdd484,
    'FullTextIndex', p_FullTextIndex_602de2fdd484,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_602de2fdd484,
    'FullTextSearchFunction', p_FullTextSearchFunction_602de2fdd484,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_602de2fdd484,
    'UserViewMaxRows', p_UserViewMaxRows_602de2fdd484,
    'spCreate', p_spCreate_602de2fdd484,
    'spUpdate', p_spUpdate_602de2fdd484,
    'spDelete', p_spDelete_602de2fdd484,
    'spCreateGenerated', p_spCreateGenerated_602de2fdd484,
    'spUpdateGenerated', p_spUpdateGenerated_602de2fdd484,
    'spDeleteGenerated', p_spDeleteGenerated_602de2fdd484,
    'CascadeDeletes', p_CascadeDeletes_602de2fdd484,
    'DeleteType', p_DeleteType_602de2fdd484,
    'AllowRecordMerge', p_AllowRecordMerge_602de2fdd484,
    'spMatch', p_spMatch_602de2fdd484,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_602de2fdd484,
    'UserFormGenerated', p_UserFormGenerated_602de2fdd484,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_602de2fdd484,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_602de2fdd484,
    'PreferredCommunicationField', p_PreferredCommunicationField_602de2fdd484,
    'Icon', p_Icon_602de2fdd484,
    'ScopeDefault', p_ScopeDefault_602de2fdd484,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_602de2fdd484,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_602de2fdd484,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_602de2fdd484,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_602de2fdd484,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_602de2fdd484,
    'RowCount', p_RowCount_602de2fdd484,
    'RowCountRunAt', p_RowCountRunAt_602de2fdd484
  ) ||
  jsonb_build_object(
    'Status', p_Status_602de2fdd484,
    'DisplayName', p_DisplayName_602de2fdd484,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_602de2fdd484,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_602de2fdd484,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_602de2fdd484,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_602de2fdd484,
    'SupportsGeoCoding', p_SupportsGeoCoding_602de2fdd484,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_602de2fdd484,
    'AllowCaching', p_AllowCaching_602de2fdd484,
    'DetectExternalChanges', p_DetectExternalChanges_602de2fdd484,
    'ExternalDataSourceID', p_ExternalDataSourceID_602de2fdd484,
    'ExternalObjectName', p_ExternalObjectName_602de2fdd484,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_602de2fdd484,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_602de2fdd484,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_602de2fdd484,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_602de2fdd484,
    'Configuration', p_Configuration_602de2fdd484,
    'SubtypeSelector', p_SubtypeSelector_602de2fdd484,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_602de2fdd484,
    'ID', p_ID_602de2fdd484
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_06cd4c8f192c UUID;
  p_Name_06cd4c8f192c VARCHAR(255);
  p_NameSuffix_06cd4c8f192c VARCHAR(255);
  p_Description_06cd4c8f192c TEXT;
  p_AutoUpdateDescription_06cd4c8f192c BOOLEAN;
  p_BaseView_06cd4c8f192c VARCHAR(255);
  p_BaseViewGenerated_06cd4c8f192c BOOLEAN;
  p_VirtualEntity_06cd4c8f192c BOOLEAN;
  p_TrackRecordChanges_06cd4c8f192c BOOLEAN;
  p_AuditRecordAccess_06cd4c8f192c BOOLEAN;
  p_AuditViewRuns_06cd4c8f192c BOOLEAN;
  p_IncludeInAPI_06cd4c8f192c BOOLEAN;
  p_AllowAllRowsAPI_06cd4c8f192c BOOLEAN;
  p_AllowUpdateAPI_06cd4c8f192c BOOLEAN;
  p_AllowCreateAPI_06cd4c8f192c BOOLEAN;
  p_AllowDeleteAPI_06cd4c8f192c BOOLEAN;
  p_CustomResolverAPI_06cd4c8f192c BOOLEAN;
  p_AllowUserSearchAPI_06cd4c8f192c BOOLEAN;
  p_FullTextSearchEnabled_06cd4c8f192c BOOLEAN;
  p_FullTextCatalog_06cd4c8f192c VARCHAR(255);
  p_FullTextCatalogGenerated_06cd4c8f192c BOOLEAN;
  p_FullTextIndex_06cd4c8f192c VARCHAR(255);
  p_FullTextIndexGenerated_06cd4c8f192c BOOLEAN;
  p_FullTextSearchFunction_06cd4c8f192c VARCHAR(255);
  p_FullTextSearchFunctionGenerated_06cd4c8f192c BOOLEAN;
  p_UserViewMaxRows_06cd4c8f192c INTEGER;
  p_spCreate_06cd4c8f192c VARCHAR(255);
  p_spUpdate_06cd4c8f192c VARCHAR(255);
  p_spDelete_06cd4c8f192c VARCHAR(255);
  p_spCreateGenerated_06cd4c8f192c BOOLEAN;
  p_spUpdateGenerated_06cd4c8f192c BOOLEAN;
  p_spDeleteGenerated_06cd4c8f192c BOOLEAN;
  p_CascadeDeletes_06cd4c8f192c BOOLEAN;
  p_DeleteType_06cd4c8f192c VARCHAR(10);
  p_AllowRecordMerge_06cd4c8f192c BOOLEAN;
  p_spMatch_06cd4c8f192c VARCHAR(255);
  p_RelationshipDefaultDisplayType_06cd4c8f192c VARCHAR(20);
  p_UserFormGenerated_06cd4c8f192c BOOLEAN;
  p_EntityObjectSubclassName_06cd4c8f192c VARCHAR(255);
  p_EntityObjectSubclassImport_06cd4c8f192c VARCHAR(255);
  p_PreferredCommunicationField_06cd4c8f192c VARCHAR(255);
  p_Icon_06cd4c8f192c VARCHAR(500);
  p_ScopeDefault_06cd4c8f192c VARCHAR(100);
  p_RowsToPackWithSchema_06cd4c8f192c VARCHAR(20);
  p_RowsToPackSampleMethod_06cd4c8f192c VARCHAR(20);
  p_RowsToPackSampleCount_06cd4c8f192c INTEGER;
  p_RowsToPackSampleOrder_06cd4c8f192c TEXT;
  p_AutoRowCountFrequency_06cd4c8f192c INTEGER;
  p_RowCount_06cd4c8f192c BIGINT;
  p_RowCountRunAt_06cd4c8f192c TIMESTAMPTZ;
  p_Status_06cd4c8f192c VARCHAR(25);
  p_DisplayName_06cd4c8f192c VARCHAR(255);
  p_AllowMultipleSubtypes_06cd4c8f192c BOOLEAN;
  p_AutoUpdateFullTextSearch_06cd4c8f192c BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_06cd4c8f192c BOOLEAN;
  p_TrustServerCacheCompletely_06cd4c8f192c BOOLEAN;
  p_SupportsGeoCoding_06cd4c8f192c BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_06cd4c8f192c BOOLEAN;
  p_AllowCaching_06cd4c8f192c BOOLEAN;
  p_DetectExternalChanges_06cd4c8f192c BOOLEAN;
  p_ExternalDataSourceID_06cd4c8f192c UUID;
  p_ExternalObjectName_06cd4c8f192c VARCHAR(255);
  p_GeneratedBaseViewName_06cd4c8f192c VARCHAR(255);
  p_AllowDirectSQLInsert_06cd4c8f192c BOOLEAN;
  p_AllowDirectSQLUpdate_06cd4c8f192c BOOLEAN;
  p_AllowDirectSQLDelete_06cd4c8f192c BOOLEAN;
  p_Configuration_06cd4c8f192c TEXT;
  p_SubtypeSelector_06cd4c8f192c TEXT;
  p_EnableFieldLevelSecurity_06cd4c8f192c BOOLEAN;
  p_ID_06cd4c8f192c UUID;
BEGIN
  p_Name_06cd4c8f192c := 'MJ_BizApps_Tasks: Task Links';
  p_AutoUpdateDescription_06cd4c8f192c := TRUE;
  p_BaseView_06cd4c8f192c := 'vwTaskLinks';
  p_BaseViewGenerated_06cd4c8f192c := TRUE;
  p_VirtualEntity_06cd4c8f192c := FALSE;
  p_TrackRecordChanges_06cd4c8f192c := TRUE;
  p_AuditRecordAccess_06cd4c8f192c := FALSE;
  p_AuditViewRuns_06cd4c8f192c := FALSE;
  p_IncludeInAPI_06cd4c8f192c := TRUE;
  p_AllowAllRowsAPI_06cd4c8f192c := FALSE;
  p_AllowUpdateAPI_06cd4c8f192c := TRUE;
  p_AllowCreateAPI_06cd4c8f192c := TRUE;
  p_AllowDeleteAPI_06cd4c8f192c := TRUE;
  p_CustomResolverAPI_06cd4c8f192c := FALSE;
  p_AllowUserSearchAPI_06cd4c8f192c := FALSE;
  p_FullTextSearchEnabled_06cd4c8f192c := FALSE;
  p_FullTextCatalogGenerated_06cd4c8f192c := TRUE;
  p_FullTextIndexGenerated_06cd4c8f192c := TRUE;
  p_FullTextSearchFunctionGenerated_06cd4c8f192c := TRUE;
  p_UserViewMaxRows_06cd4c8f192c := 1000;
  p_spCreateGenerated_06cd4c8f192c := TRUE;
  p_spUpdateGenerated_06cd4c8f192c := TRUE;
  p_spDeleteGenerated_06cd4c8f192c := TRUE;
  p_CascadeDeletes_06cd4c8f192c := FALSE;
  p_DeleteType_06cd4c8f192c := 'Hard';
  p_AllowRecordMerge_06cd4c8f192c := FALSE;
  p_RelationshipDefaultDisplayType_06cd4c8f192c := 'Search';
  p_UserFormGenerated_06cd4c8f192c := TRUE;
  p_RowsToPackWithSchema_06cd4c8f192c := 'None';
  p_RowsToPackSampleMethod_06cd4c8f192c := 'random';
  p_RowsToPackSampleCount_06cd4c8f192c := 0;
  p_Status_06cd4c8f192c := 'Active';
  p_DisplayName_06cd4c8f192c := 'Task Links';
  p_AllowMultipleSubtypes_06cd4c8f192c := FALSE;
  p_AutoUpdateFullTextSearch_06cd4c8f192c := TRUE;
  p_AutoUpdateAllowUserSearchAPI_06cd4c8f192c := FALSE;
  p_TrustServerCacheCompletely_06cd4c8f192c := TRUE;
  p_SupportsGeoCoding_06cd4c8f192c := FALSE;
  p_AutoUpdateSupportsGeoCoding_06cd4c8f192c := TRUE;
  p_AllowCaching_06cd4c8f192c := FALSE;
  p_DetectExternalChanges_06cd4c8f192c := FALSE;
  p_AllowDirectSQLInsert_06cd4c8f192c := FALSE;
  p_AllowDirectSQLUpdate_06cd4c8f192c := FALSE;
  p_AllowDirectSQLDelete_06cd4c8f192c := FALSE;
  p_EnableFieldLevelSecurity_06cd4c8f192c := FALSE;
  p_ID_06cd4c8f192c := 'B92E802C-5C1B-486D-B021-03E47069502C';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_06cd4c8f192c,
    'Name', p_Name_06cd4c8f192c,
    'NameSuffix', p_NameSuffix_06cd4c8f192c,
    'Description', p_Description_06cd4c8f192c,
    'AutoUpdateDescription', p_AutoUpdateDescription_06cd4c8f192c,
    'BaseView', p_BaseView_06cd4c8f192c,
    'BaseViewGenerated', p_BaseViewGenerated_06cd4c8f192c,
    'VirtualEntity', p_VirtualEntity_06cd4c8f192c,
    'TrackRecordChanges', p_TrackRecordChanges_06cd4c8f192c,
    'AuditRecordAccess', p_AuditRecordAccess_06cd4c8f192c,
    'AuditViewRuns', p_AuditViewRuns_06cd4c8f192c,
    'IncludeInAPI', p_IncludeInAPI_06cd4c8f192c,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_06cd4c8f192c,
    'AllowUpdateAPI', p_AllowUpdateAPI_06cd4c8f192c,
    'AllowCreateAPI', p_AllowCreateAPI_06cd4c8f192c,
    'AllowDeleteAPI', p_AllowDeleteAPI_06cd4c8f192c,
    'CustomResolverAPI', p_CustomResolverAPI_06cd4c8f192c,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_06cd4c8f192c,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_06cd4c8f192c,
    'FullTextCatalog', p_FullTextCatalog_06cd4c8f192c,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_06cd4c8f192c,
    'FullTextIndex', p_FullTextIndex_06cd4c8f192c,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_06cd4c8f192c,
    'FullTextSearchFunction', p_FullTextSearchFunction_06cd4c8f192c,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_06cd4c8f192c,
    'UserViewMaxRows', p_UserViewMaxRows_06cd4c8f192c,
    'spCreate', p_spCreate_06cd4c8f192c,
    'spUpdate', p_spUpdate_06cd4c8f192c,
    'spDelete', p_spDelete_06cd4c8f192c,
    'spCreateGenerated', p_spCreateGenerated_06cd4c8f192c,
    'spUpdateGenerated', p_spUpdateGenerated_06cd4c8f192c,
    'spDeleteGenerated', p_spDeleteGenerated_06cd4c8f192c,
    'CascadeDeletes', p_CascadeDeletes_06cd4c8f192c,
    'DeleteType', p_DeleteType_06cd4c8f192c,
    'AllowRecordMerge', p_AllowRecordMerge_06cd4c8f192c,
    'spMatch', p_spMatch_06cd4c8f192c,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_06cd4c8f192c,
    'UserFormGenerated', p_UserFormGenerated_06cd4c8f192c,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_06cd4c8f192c,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_06cd4c8f192c,
    'PreferredCommunicationField', p_PreferredCommunicationField_06cd4c8f192c,
    'Icon', p_Icon_06cd4c8f192c,
    'ScopeDefault', p_ScopeDefault_06cd4c8f192c,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_06cd4c8f192c,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_06cd4c8f192c,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_06cd4c8f192c,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_06cd4c8f192c,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_06cd4c8f192c,
    'RowCount', p_RowCount_06cd4c8f192c,
    'RowCountRunAt', p_RowCountRunAt_06cd4c8f192c
  ) ||
  jsonb_build_object(
    'Status', p_Status_06cd4c8f192c,
    'DisplayName', p_DisplayName_06cd4c8f192c,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_06cd4c8f192c,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_06cd4c8f192c,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_06cd4c8f192c,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_06cd4c8f192c,
    'SupportsGeoCoding', p_SupportsGeoCoding_06cd4c8f192c,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_06cd4c8f192c,
    'AllowCaching', p_AllowCaching_06cd4c8f192c,
    'DetectExternalChanges', p_DetectExternalChanges_06cd4c8f192c,
    'ExternalDataSourceID', p_ExternalDataSourceID_06cd4c8f192c,
    'ExternalObjectName', p_ExternalObjectName_06cd4c8f192c,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_06cd4c8f192c,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_06cd4c8f192c,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_06cd4c8f192c,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_06cd4c8f192c,
    'Configuration', p_Configuration_06cd4c8f192c,
    'SubtypeSelector', p_SubtypeSelector_06cd4c8f192c,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_06cd4c8f192c,
    'ID', p_ID_06cd4c8f192c
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_0056bb9c83d2 UUID;
  p_Name_0056bb9c83d2 VARCHAR(255);
  p_NameSuffix_0056bb9c83d2 VARCHAR(255);
  p_Description_0056bb9c83d2 TEXT;
  p_AutoUpdateDescription_0056bb9c83d2 BOOLEAN;
  p_BaseView_0056bb9c83d2 VARCHAR(255);
  p_BaseViewGenerated_0056bb9c83d2 BOOLEAN;
  p_VirtualEntity_0056bb9c83d2 BOOLEAN;
  p_TrackRecordChanges_0056bb9c83d2 BOOLEAN;
  p_AuditRecordAccess_0056bb9c83d2 BOOLEAN;
  p_AuditViewRuns_0056bb9c83d2 BOOLEAN;
  p_IncludeInAPI_0056bb9c83d2 BOOLEAN;
  p_AllowAllRowsAPI_0056bb9c83d2 BOOLEAN;
  p_AllowUpdateAPI_0056bb9c83d2 BOOLEAN;
  p_AllowCreateAPI_0056bb9c83d2 BOOLEAN;
  p_AllowDeleteAPI_0056bb9c83d2 BOOLEAN;
  p_CustomResolverAPI_0056bb9c83d2 BOOLEAN;
  p_AllowUserSearchAPI_0056bb9c83d2 BOOLEAN;
  p_FullTextSearchEnabled_0056bb9c83d2 BOOLEAN;
  p_FullTextCatalog_0056bb9c83d2 VARCHAR(255);
  p_FullTextCatalogGenerated_0056bb9c83d2 BOOLEAN;
  p_FullTextIndex_0056bb9c83d2 VARCHAR(255);
  p_FullTextIndexGenerated_0056bb9c83d2 BOOLEAN;
  p_FullTextSearchFunction_0056bb9c83d2 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_0056bb9c83d2 BOOLEAN;
  p_UserViewMaxRows_0056bb9c83d2 INTEGER;
  p_spCreate_0056bb9c83d2 VARCHAR(255);
  p_spUpdate_0056bb9c83d2 VARCHAR(255);
  p_spDelete_0056bb9c83d2 VARCHAR(255);
  p_spCreateGenerated_0056bb9c83d2 BOOLEAN;
  p_spUpdateGenerated_0056bb9c83d2 BOOLEAN;
  p_spDeleteGenerated_0056bb9c83d2 BOOLEAN;
  p_CascadeDeletes_0056bb9c83d2 BOOLEAN;
  p_DeleteType_0056bb9c83d2 VARCHAR(10);
  p_AllowRecordMerge_0056bb9c83d2 BOOLEAN;
  p_spMatch_0056bb9c83d2 VARCHAR(255);
  p_RelationshipDefaultDisplayType_0056bb9c83d2 VARCHAR(20);
  p_UserFormGenerated_0056bb9c83d2 BOOLEAN;
  p_EntityObjectSubclassName_0056bb9c83d2 VARCHAR(255);
  p_EntityObjectSubclassImport_0056bb9c83d2 VARCHAR(255);
  p_PreferredCommunicationField_0056bb9c83d2 VARCHAR(255);
  p_Icon_0056bb9c83d2 VARCHAR(500);
  p_ScopeDefault_0056bb9c83d2 VARCHAR(100);
  p_RowsToPackWithSchema_0056bb9c83d2 VARCHAR(20);
  p_RowsToPackSampleMethod_0056bb9c83d2 VARCHAR(20);
  p_RowsToPackSampleCount_0056bb9c83d2 INTEGER;
  p_RowsToPackSampleOrder_0056bb9c83d2 TEXT;
  p_AutoRowCountFrequency_0056bb9c83d2 INTEGER;
  p_RowCount_0056bb9c83d2 BIGINT;
  p_RowCountRunAt_0056bb9c83d2 TIMESTAMPTZ;
  p_Status_0056bb9c83d2 VARCHAR(25);
  p_DisplayName_0056bb9c83d2 VARCHAR(255);
  p_AllowMultipleSubtypes_0056bb9c83d2 BOOLEAN;
  p_AutoUpdateFullTextSearch_0056bb9c83d2 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_0056bb9c83d2 BOOLEAN;
  p_TrustServerCacheCompletely_0056bb9c83d2 BOOLEAN;
  p_SupportsGeoCoding_0056bb9c83d2 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_0056bb9c83d2 BOOLEAN;
  p_AllowCaching_0056bb9c83d2 BOOLEAN;
  p_DetectExternalChanges_0056bb9c83d2 BOOLEAN;
  p_ExternalDataSourceID_0056bb9c83d2 UUID;
  p_ExternalObjectName_0056bb9c83d2 VARCHAR(255);
  p_GeneratedBaseViewName_0056bb9c83d2 VARCHAR(255);
  p_AllowDirectSQLInsert_0056bb9c83d2 BOOLEAN;
  p_AllowDirectSQLUpdate_0056bb9c83d2 BOOLEAN;
  p_AllowDirectSQLDelete_0056bb9c83d2 BOOLEAN;
  p_Configuration_0056bb9c83d2 TEXT;
  p_SubtypeSelector_0056bb9c83d2 TEXT;
  p_EnableFieldLevelSecurity_0056bb9c83d2 BOOLEAN;
  p_ID_0056bb9c83d2 UUID;
BEGIN
  p_Name_0056bb9c83d2 := 'MJ_BizApps_Tasks: Task Notification Configs';
  p_AutoUpdateDescription_0056bb9c83d2 := TRUE;
  p_BaseView_0056bb9c83d2 := 'vwTaskNotificationConfigs';
  p_BaseViewGenerated_0056bb9c83d2 := TRUE;
  p_VirtualEntity_0056bb9c83d2 := FALSE;
  p_TrackRecordChanges_0056bb9c83d2 := TRUE;
  p_AuditRecordAccess_0056bb9c83d2 := FALSE;
  p_AuditViewRuns_0056bb9c83d2 := FALSE;
  p_IncludeInAPI_0056bb9c83d2 := TRUE;
  p_AllowAllRowsAPI_0056bb9c83d2 := FALSE;
  p_AllowUpdateAPI_0056bb9c83d2 := TRUE;
  p_AllowCreateAPI_0056bb9c83d2 := TRUE;
  p_AllowDeleteAPI_0056bb9c83d2 := TRUE;
  p_CustomResolverAPI_0056bb9c83d2 := FALSE;
  p_AllowUserSearchAPI_0056bb9c83d2 := FALSE;
  p_FullTextSearchEnabled_0056bb9c83d2 := FALSE;
  p_FullTextCatalogGenerated_0056bb9c83d2 := TRUE;
  p_FullTextIndexGenerated_0056bb9c83d2 := TRUE;
  p_FullTextSearchFunctionGenerated_0056bb9c83d2 := TRUE;
  p_UserViewMaxRows_0056bb9c83d2 := 1000;
  p_spCreateGenerated_0056bb9c83d2 := TRUE;
  p_spUpdateGenerated_0056bb9c83d2 := TRUE;
  p_spDeleteGenerated_0056bb9c83d2 := TRUE;
  p_CascadeDeletes_0056bb9c83d2 := FALSE;
  p_DeleteType_0056bb9c83d2 := 'Hard';
  p_AllowRecordMerge_0056bb9c83d2 := FALSE;
  p_RelationshipDefaultDisplayType_0056bb9c83d2 := 'Search';
  p_UserFormGenerated_0056bb9c83d2 := TRUE;
  p_RowsToPackWithSchema_0056bb9c83d2 := 'None';
  p_RowsToPackSampleMethod_0056bb9c83d2 := 'random';
  p_RowsToPackSampleCount_0056bb9c83d2 := 0;
  p_Status_0056bb9c83d2 := 'Active';
  p_DisplayName_0056bb9c83d2 := 'Task Notification Configs';
  p_AllowMultipleSubtypes_0056bb9c83d2 := FALSE;
  p_AutoUpdateFullTextSearch_0056bb9c83d2 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_0056bb9c83d2 := FALSE;
  p_TrustServerCacheCompletely_0056bb9c83d2 := TRUE;
  p_SupportsGeoCoding_0056bb9c83d2 := FALSE;
  p_AutoUpdateSupportsGeoCoding_0056bb9c83d2 := TRUE;
  p_AllowCaching_0056bb9c83d2 := FALSE;
  p_DetectExternalChanges_0056bb9c83d2 := FALSE;
  p_AllowDirectSQLInsert_0056bb9c83d2 := FALSE;
  p_AllowDirectSQLUpdate_0056bb9c83d2 := FALSE;
  p_AllowDirectSQLDelete_0056bb9c83d2 := FALSE;
  p_EnableFieldLevelSecurity_0056bb9c83d2 := FALSE;
  p_ID_0056bb9c83d2 := 'A210AF26-629A-4E0A-A90A-1CCE33F5D095';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_0056bb9c83d2,
    'Name', p_Name_0056bb9c83d2,
    'NameSuffix', p_NameSuffix_0056bb9c83d2,
    'Description', p_Description_0056bb9c83d2,
    'AutoUpdateDescription', p_AutoUpdateDescription_0056bb9c83d2,
    'BaseView', p_BaseView_0056bb9c83d2,
    'BaseViewGenerated', p_BaseViewGenerated_0056bb9c83d2,
    'VirtualEntity', p_VirtualEntity_0056bb9c83d2,
    'TrackRecordChanges', p_TrackRecordChanges_0056bb9c83d2,
    'AuditRecordAccess', p_AuditRecordAccess_0056bb9c83d2,
    'AuditViewRuns', p_AuditViewRuns_0056bb9c83d2,
    'IncludeInAPI', p_IncludeInAPI_0056bb9c83d2,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_0056bb9c83d2,
    'AllowUpdateAPI', p_AllowUpdateAPI_0056bb9c83d2,
    'AllowCreateAPI', p_AllowCreateAPI_0056bb9c83d2,
    'AllowDeleteAPI', p_AllowDeleteAPI_0056bb9c83d2,
    'CustomResolverAPI', p_CustomResolverAPI_0056bb9c83d2,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_0056bb9c83d2,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_0056bb9c83d2,
    'FullTextCatalog', p_FullTextCatalog_0056bb9c83d2,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_0056bb9c83d2,
    'FullTextIndex', p_FullTextIndex_0056bb9c83d2,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_0056bb9c83d2,
    'FullTextSearchFunction', p_FullTextSearchFunction_0056bb9c83d2,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_0056bb9c83d2,
    'UserViewMaxRows', p_UserViewMaxRows_0056bb9c83d2,
    'spCreate', p_spCreate_0056bb9c83d2,
    'spUpdate', p_spUpdate_0056bb9c83d2,
    'spDelete', p_spDelete_0056bb9c83d2,
    'spCreateGenerated', p_spCreateGenerated_0056bb9c83d2,
    'spUpdateGenerated', p_spUpdateGenerated_0056bb9c83d2,
    'spDeleteGenerated', p_spDeleteGenerated_0056bb9c83d2,
    'CascadeDeletes', p_CascadeDeletes_0056bb9c83d2,
    'DeleteType', p_DeleteType_0056bb9c83d2,
    'AllowRecordMerge', p_AllowRecordMerge_0056bb9c83d2,
    'spMatch', p_spMatch_0056bb9c83d2,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_0056bb9c83d2,
    'UserFormGenerated', p_UserFormGenerated_0056bb9c83d2,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_0056bb9c83d2,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_0056bb9c83d2,
    'PreferredCommunicationField', p_PreferredCommunicationField_0056bb9c83d2,
    'Icon', p_Icon_0056bb9c83d2,
    'ScopeDefault', p_ScopeDefault_0056bb9c83d2,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_0056bb9c83d2,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_0056bb9c83d2,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_0056bb9c83d2,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_0056bb9c83d2,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_0056bb9c83d2,
    'RowCount', p_RowCount_0056bb9c83d2,
    'RowCountRunAt', p_RowCountRunAt_0056bb9c83d2
  ) ||
  jsonb_build_object(
    'Status', p_Status_0056bb9c83d2,
    'DisplayName', p_DisplayName_0056bb9c83d2,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_0056bb9c83d2,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_0056bb9c83d2,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_0056bb9c83d2,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_0056bb9c83d2,
    'SupportsGeoCoding', p_SupportsGeoCoding_0056bb9c83d2,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_0056bb9c83d2,
    'AllowCaching', p_AllowCaching_0056bb9c83d2,
    'DetectExternalChanges', p_DetectExternalChanges_0056bb9c83d2,
    'ExternalDataSourceID', p_ExternalDataSourceID_0056bb9c83d2,
    'ExternalObjectName', p_ExternalObjectName_0056bb9c83d2,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_0056bb9c83d2,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_0056bb9c83d2,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_0056bb9c83d2,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_0056bb9c83d2,
    'Configuration', p_Configuration_0056bb9c83d2,
    'SubtypeSelector', p_SubtypeSelector_0056bb9c83d2,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_0056bb9c83d2,
    'ID', p_ID_0056bb9c83d2
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_87a8737c4002 UUID;
  p_Name_87a8737c4002 VARCHAR(255);
  p_NameSuffix_87a8737c4002 VARCHAR(255);
  p_Description_87a8737c4002 TEXT;
  p_AutoUpdateDescription_87a8737c4002 BOOLEAN;
  p_BaseView_87a8737c4002 VARCHAR(255);
  p_BaseViewGenerated_87a8737c4002 BOOLEAN;
  p_VirtualEntity_87a8737c4002 BOOLEAN;
  p_TrackRecordChanges_87a8737c4002 BOOLEAN;
  p_AuditRecordAccess_87a8737c4002 BOOLEAN;
  p_AuditViewRuns_87a8737c4002 BOOLEAN;
  p_IncludeInAPI_87a8737c4002 BOOLEAN;
  p_AllowAllRowsAPI_87a8737c4002 BOOLEAN;
  p_AllowUpdateAPI_87a8737c4002 BOOLEAN;
  p_AllowCreateAPI_87a8737c4002 BOOLEAN;
  p_AllowDeleteAPI_87a8737c4002 BOOLEAN;
  p_CustomResolverAPI_87a8737c4002 BOOLEAN;
  p_AllowUserSearchAPI_87a8737c4002 BOOLEAN;
  p_FullTextSearchEnabled_87a8737c4002 BOOLEAN;
  p_FullTextCatalog_87a8737c4002 VARCHAR(255);
  p_FullTextCatalogGenerated_87a8737c4002 BOOLEAN;
  p_FullTextIndex_87a8737c4002 VARCHAR(255);
  p_FullTextIndexGenerated_87a8737c4002 BOOLEAN;
  p_FullTextSearchFunction_87a8737c4002 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_87a8737c4002 BOOLEAN;
  p_UserViewMaxRows_87a8737c4002 INTEGER;
  p_spCreate_87a8737c4002 VARCHAR(255);
  p_spUpdate_87a8737c4002 VARCHAR(255);
  p_spDelete_87a8737c4002 VARCHAR(255);
  p_spCreateGenerated_87a8737c4002 BOOLEAN;
  p_spUpdateGenerated_87a8737c4002 BOOLEAN;
  p_spDeleteGenerated_87a8737c4002 BOOLEAN;
  p_CascadeDeletes_87a8737c4002 BOOLEAN;
  p_DeleteType_87a8737c4002 VARCHAR(10);
  p_AllowRecordMerge_87a8737c4002 BOOLEAN;
  p_spMatch_87a8737c4002 VARCHAR(255);
  p_RelationshipDefaultDisplayType_87a8737c4002 VARCHAR(20);
  p_UserFormGenerated_87a8737c4002 BOOLEAN;
  p_EntityObjectSubclassName_87a8737c4002 VARCHAR(255);
  p_EntityObjectSubclassImport_87a8737c4002 VARCHAR(255);
  p_PreferredCommunicationField_87a8737c4002 VARCHAR(255);
  p_Icon_87a8737c4002 VARCHAR(500);
  p_ScopeDefault_87a8737c4002 VARCHAR(100);
  p_RowsToPackWithSchema_87a8737c4002 VARCHAR(20);
  p_RowsToPackSampleMethod_87a8737c4002 VARCHAR(20);
  p_RowsToPackSampleCount_87a8737c4002 INTEGER;
  p_RowsToPackSampleOrder_87a8737c4002 TEXT;
  p_AutoRowCountFrequency_87a8737c4002 INTEGER;
  p_RowCount_87a8737c4002 BIGINT;
  p_RowCountRunAt_87a8737c4002 TIMESTAMPTZ;
  p_Status_87a8737c4002 VARCHAR(25);
  p_DisplayName_87a8737c4002 VARCHAR(255);
  p_AllowMultipleSubtypes_87a8737c4002 BOOLEAN;
  p_AutoUpdateFullTextSearch_87a8737c4002 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_87a8737c4002 BOOLEAN;
  p_TrustServerCacheCompletely_87a8737c4002 BOOLEAN;
  p_SupportsGeoCoding_87a8737c4002 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_87a8737c4002 BOOLEAN;
  p_AllowCaching_87a8737c4002 BOOLEAN;
  p_DetectExternalChanges_87a8737c4002 BOOLEAN;
  p_ExternalDataSourceID_87a8737c4002 UUID;
  p_ExternalObjectName_87a8737c4002 VARCHAR(255);
  p_GeneratedBaseViewName_87a8737c4002 VARCHAR(255);
  p_AllowDirectSQLInsert_87a8737c4002 BOOLEAN;
  p_AllowDirectSQLUpdate_87a8737c4002 BOOLEAN;
  p_AllowDirectSQLDelete_87a8737c4002 BOOLEAN;
  p_Configuration_87a8737c4002 TEXT;
  p_SubtypeSelector_87a8737c4002 TEXT;
  p_EnableFieldLevelSecurity_87a8737c4002 BOOLEAN;
  p_ID_87a8737c4002 UUID;
BEGIN
  p_Name_87a8737c4002 := 'MJ_BizApps_Tasks: Task Notification Logs';
  p_AutoUpdateDescription_87a8737c4002 := TRUE;
  p_BaseView_87a8737c4002 := 'vwTaskNotificationLogs';
  p_BaseViewGenerated_87a8737c4002 := TRUE;
  p_VirtualEntity_87a8737c4002 := FALSE;
  p_TrackRecordChanges_87a8737c4002 := TRUE;
  p_AuditRecordAccess_87a8737c4002 := FALSE;
  p_AuditViewRuns_87a8737c4002 := FALSE;
  p_IncludeInAPI_87a8737c4002 := TRUE;
  p_AllowAllRowsAPI_87a8737c4002 := FALSE;
  p_AllowUpdateAPI_87a8737c4002 := TRUE;
  p_AllowCreateAPI_87a8737c4002 := TRUE;
  p_AllowDeleteAPI_87a8737c4002 := TRUE;
  p_CustomResolverAPI_87a8737c4002 := FALSE;
  p_AllowUserSearchAPI_87a8737c4002 := FALSE;
  p_FullTextSearchEnabled_87a8737c4002 := FALSE;
  p_FullTextCatalogGenerated_87a8737c4002 := TRUE;
  p_FullTextIndexGenerated_87a8737c4002 := TRUE;
  p_FullTextSearchFunctionGenerated_87a8737c4002 := TRUE;
  p_UserViewMaxRows_87a8737c4002 := 1000;
  p_spCreateGenerated_87a8737c4002 := TRUE;
  p_spUpdateGenerated_87a8737c4002 := TRUE;
  p_spDeleteGenerated_87a8737c4002 := TRUE;
  p_CascadeDeletes_87a8737c4002 := FALSE;
  p_DeleteType_87a8737c4002 := 'Hard';
  p_AllowRecordMerge_87a8737c4002 := FALSE;
  p_RelationshipDefaultDisplayType_87a8737c4002 := 'Search';
  p_UserFormGenerated_87a8737c4002 := TRUE;
  p_RowsToPackWithSchema_87a8737c4002 := 'None';
  p_RowsToPackSampleMethod_87a8737c4002 := 'random';
  p_RowsToPackSampleCount_87a8737c4002 := 0;
  p_Status_87a8737c4002 := 'Active';
  p_DisplayName_87a8737c4002 := 'Task Notification Logs';
  p_AllowMultipleSubtypes_87a8737c4002 := FALSE;
  p_AutoUpdateFullTextSearch_87a8737c4002 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_87a8737c4002 := FALSE;
  p_TrustServerCacheCompletely_87a8737c4002 := TRUE;
  p_SupportsGeoCoding_87a8737c4002 := FALSE;
  p_AutoUpdateSupportsGeoCoding_87a8737c4002 := TRUE;
  p_AllowCaching_87a8737c4002 := FALSE;
  p_DetectExternalChanges_87a8737c4002 := FALSE;
  p_AllowDirectSQLInsert_87a8737c4002 := FALSE;
  p_AllowDirectSQLUpdate_87a8737c4002 := FALSE;
  p_AllowDirectSQLDelete_87a8737c4002 := FALSE;
  p_EnableFieldLevelSecurity_87a8737c4002 := FALSE;
  p_ID_87a8737c4002 := 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_87a8737c4002,
    'Name', p_Name_87a8737c4002,
    'NameSuffix', p_NameSuffix_87a8737c4002,
    'Description', p_Description_87a8737c4002,
    'AutoUpdateDescription', p_AutoUpdateDescription_87a8737c4002,
    'BaseView', p_BaseView_87a8737c4002,
    'BaseViewGenerated', p_BaseViewGenerated_87a8737c4002,
    'VirtualEntity', p_VirtualEntity_87a8737c4002,
    'TrackRecordChanges', p_TrackRecordChanges_87a8737c4002,
    'AuditRecordAccess', p_AuditRecordAccess_87a8737c4002,
    'AuditViewRuns', p_AuditViewRuns_87a8737c4002,
    'IncludeInAPI', p_IncludeInAPI_87a8737c4002,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_87a8737c4002,
    'AllowUpdateAPI', p_AllowUpdateAPI_87a8737c4002,
    'AllowCreateAPI', p_AllowCreateAPI_87a8737c4002,
    'AllowDeleteAPI', p_AllowDeleteAPI_87a8737c4002,
    'CustomResolverAPI', p_CustomResolverAPI_87a8737c4002,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_87a8737c4002,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_87a8737c4002,
    'FullTextCatalog', p_FullTextCatalog_87a8737c4002,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_87a8737c4002,
    'FullTextIndex', p_FullTextIndex_87a8737c4002,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_87a8737c4002,
    'FullTextSearchFunction', p_FullTextSearchFunction_87a8737c4002,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_87a8737c4002,
    'UserViewMaxRows', p_UserViewMaxRows_87a8737c4002,
    'spCreate', p_spCreate_87a8737c4002,
    'spUpdate', p_spUpdate_87a8737c4002,
    'spDelete', p_spDelete_87a8737c4002,
    'spCreateGenerated', p_spCreateGenerated_87a8737c4002,
    'spUpdateGenerated', p_spUpdateGenerated_87a8737c4002,
    'spDeleteGenerated', p_spDeleteGenerated_87a8737c4002,
    'CascadeDeletes', p_CascadeDeletes_87a8737c4002,
    'DeleteType', p_DeleteType_87a8737c4002,
    'AllowRecordMerge', p_AllowRecordMerge_87a8737c4002,
    'spMatch', p_spMatch_87a8737c4002,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_87a8737c4002,
    'UserFormGenerated', p_UserFormGenerated_87a8737c4002,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_87a8737c4002,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_87a8737c4002,
    'PreferredCommunicationField', p_PreferredCommunicationField_87a8737c4002,
    'Icon', p_Icon_87a8737c4002,
    'ScopeDefault', p_ScopeDefault_87a8737c4002,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_87a8737c4002,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_87a8737c4002,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_87a8737c4002,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_87a8737c4002,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_87a8737c4002,
    'RowCount', p_RowCount_87a8737c4002,
    'RowCountRunAt', p_RowCountRunAt_87a8737c4002
  ) ||
  jsonb_build_object(
    'Status', p_Status_87a8737c4002,
    'DisplayName', p_DisplayName_87a8737c4002,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_87a8737c4002,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_87a8737c4002,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_87a8737c4002,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_87a8737c4002,
    'SupportsGeoCoding', p_SupportsGeoCoding_87a8737c4002,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_87a8737c4002,
    'AllowCaching', p_AllowCaching_87a8737c4002,
    'DetectExternalChanges', p_DetectExternalChanges_87a8737c4002,
    'ExternalDataSourceID', p_ExternalDataSourceID_87a8737c4002,
    'ExternalObjectName', p_ExternalObjectName_87a8737c4002,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_87a8737c4002,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_87a8737c4002,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_87a8737c4002,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_87a8737c4002,
    'Configuration', p_Configuration_87a8737c4002,
    'SubtypeSelector', p_SubtypeSelector_87a8737c4002,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_87a8737c4002,
    'ID', p_ID_87a8737c4002
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_0667eb588b5e UUID;
  p_Name_0667eb588b5e VARCHAR(255);
  p_NameSuffix_0667eb588b5e VARCHAR(255);
  p_Description_0667eb588b5e TEXT;
  p_AutoUpdateDescription_0667eb588b5e BOOLEAN;
  p_BaseView_0667eb588b5e VARCHAR(255);
  p_BaseViewGenerated_0667eb588b5e BOOLEAN;
  p_VirtualEntity_0667eb588b5e BOOLEAN;
  p_TrackRecordChanges_0667eb588b5e BOOLEAN;
  p_AuditRecordAccess_0667eb588b5e BOOLEAN;
  p_AuditViewRuns_0667eb588b5e BOOLEAN;
  p_IncludeInAPI_0667eb588b5e BOOLEAN;
  p_AllowAllRowsAPI_0667eb588b5e BOOLEAN;
  p_AllowUpdateAPI_0667eb588b5e BOOLEAN;
  p_AllowCreateAPI_0667eb588b5e BOOLEAN;
  p_AllowDeleteAPI_0667eb588b5e BOOLEAN;
  p_CustomResolverAPI_0667eb588b5e BOOLEAN;
  p_AllowUserSearchAPI_0667eb588b5e BOOLEAN;
  p_FullTextSearchEnabled_0667eb588b5e BOOLEAN;
  p_FullTextCatalog_0667eb588b5e VARCHAR(255);
  p_FullTextCatalogGenerated_0667eb588b5e BOOLEAN;
  p_FullTextIndex_0667eb588b5e VARCHAR(255);
  p_FullTextIndexGenerated_0667eb588b5e BOOLEAN;
  p_FullTextSearchFunction_0667eb588b5e VARCHAR(255);
  p_FullTextSearchFunctionGenerated_0667eb588b5e BOOLEAN;
  p_UserViewMaxRows_0667eb588b5e INTEGER;
  p_spCreate_0667eb588b5e VARCHAR(255);
  p_spUpdate_0667eb588b5e VARCHAR(255);
  p_spDelete_0667eb588b5e VARCHAR(255);
  p_spCreateGenerated_0667eb588b5e BOOLEAN;
  p_spUpdateGenerated_0667eb588b5e BOOLEAN;
  p_spDeleteGenerated_0667eb588b5e BOOLEAN;
  p_CascadeDeletes_0667eb588b5e BOOLEAN;
  p_DeleteType_0667eb588b5e VARCHAR(10);
  p_AllowRecordMerge_0667eb588b5e BOOLEAN;
  p_spMatch_0667eb588b5e VARCHAR(255);
  p_RelationshipDefaultDisplayType_0667eb588b5e VARCHAR(20);
  p_UserFormGenerated_0667eb588b5e BOOLEAN;
  p_EntityObjectSubclassName_0667eb588b5e VARCHAR(255);
  p_EntityObjectSubclassImport_0667eb588b5e VARCHAR(255);
  p_PreferredCommunicationField_0667eb588b5e VARCHAR(255);
  p_Icon_0667eb588b5e VARCHAR(500);
  p_ScopeDefault_0667eb588b5e VARCHAR(100);
  p_RowsToPackWithSchema_0667eb588b5e VARCHAR(20);
  p_RowsToPackSampleMethod_0667eb588b5e VARCHAR(20);
  p_RowsToPackSampleCount_0667eb588b5e INTEGER;
  p_RowsToPackSampleOrder_0667eb588b5e TEXT;
  p_AutoRowCountFrequency_0667eb588b5e INTEGER;
  p_RowCount_0667eb588b5e BIGINT;
  p_RowCountRunAt_0667eb588b5e TIMESTAMPTZ;
  p_Status_0667eb588b5e VARCHAR(25);
  p_DisplayName_0667eb588b5e VARCHAR(255);
  p_AllowMultipleSubtypes_0667eb588b5e BOOLEAN;
  p_AutoUpdateFullTextSearch_0667eb588b5e BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_0667eb588b5e BOOLEAN;
  p_TrustServerCacheCompletely_0667eb588b5e BOOLEAN;
  p_SupportsGeoCoding_0667eb588b5e BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_0667eb588b5e BOOLEAN;
  p_AllowCaching_0667eb588b5e BOOLEAN;
  p_DetectExternalChanges_0667eb588b5e BOOLEAN;
  p_ExternalDataSourceID_0667eb588b5e UUID;
  p_ExternalObjectName_0667eb588b5e VARCHAR(255);
  p_GeneratedBaseViewName_0667eb588b5e VARCHAR(255);
  p_AllowDirectSQLInsert_0667eb588b5e BOOLEAN;
  p_AllowDirectSQLUpdate_0667eb588b5e BOOLEAN;
  p_AllowDirectSQLDelete_0667eb588b5e BOOLEAN;
  p_Configuration_0667eb588b5e TEXT;
  p_SubtypeSelector_0667eb588b5e TEXT;
  p_EnableFieldLevelSecurity_0667eb588b5e BOOLEAN;
  p_ID_0667eb588b5e UUID;
BEGIN
  p_Name_0667eb588b5e := 'MJ_BizApps_Tasks: Task Roles';
  p_AutoUpdateDescription_0667eb588b5e := TRUE;
  p_BaseView_0667eb588b5e := 'vwTaskRoles';
  p_BaseViewGenerated_0667eb588b5e := TRUE;
  p_VirtualEntity_0667eb588b5e := FALSE;
  p_TrackRecordChanges_0667eb588b5e := TRUE;
  p_AuditRecordAccess_0667eb588b5e := FALSE;
  p_AuditViewRuns_0667eb588b5e := FALSE;
  p_IncludeInAPI_0667eb588b5e := TRUE;
  p_AllowAllRowsAPI_0667eb588b5e := FALSE;
  p_AllowUpdateAPI_0667eb588b5e := TRUE;
  p_AllowCreateAPI_0667eb588b5e := TRUE;
  p_AllowDeleteAPI_0667eb588b5e := TRUE;
  p_CustomResolverAPI_0667eb588b5e := FALSE;
  p_AllowUserSearchAPI_0667eb588b5e := FALSE;
  p_FullTextSearchEnabled_0667eb588b5e := FALSE;
  p_FullTextCatalogGenerated_0667eb588b5e := TRUE;
  p_FullTextIndexGenerated_0667eb588b5e := TRUE;
  p_FullTextSearchFunctionGenerated_0667eb588b5e := TRUE;
  p_UserViewMaxRows_0667eb588b5e := 1000;
  p_spCreateGenerated_0667eb588b5e := TRUE;
  p_spUpdateGenerated_0667eb588b5e := TRUE;
  p_spDeleteGenerated_0667eb588b5e := TRUE;
  p_CascadeDeletes_0667eb588b5e := FALSE;
  p_DeleteType_0667eb588b5e := 'Hard';
  p_AllowRecordMerge_0667eb588b5e := FALSE;
  p_RelationshipDefaultDisplayType_0667eb588b5e := 'Search';
  p_UserFormGenerated_0667eb588b5e := TRUE;
  p_RowsToPackWithSchema_0667eb588b5e := 'None';
  p_RowsToPackSampleMethod_0667eb588b5e := 'random';
  p_RowsToPackSampleCount_0667eb588b5e := 0;
  p_Status_0667eb588b5e := 'Active';
  p_DisplayName_0667eb588b5e := 'Task Roles';
  p_AllowMultipleSubtypes_0667eb588b5e := FALSE;
  p_AutoUpdateFullTextSearch_0667eb588b5e := TRUE;
  p_AutoUpdateAllowUserSearchAPI_0667eb588b5e := FALSE;
  p_TrustServerCacheCompletely_0667eb588b5e := TRUE;
  p_SupportsGeoCoding_0667eb588b5e := FALSE;
  p_AutoUpdateSupportsGeoCoding_0667eb588b5e := TRUE;
  p_AllowCaching_0667eb588b5e := FALSE;
  p_DetectExternalChanges_0667eb588b5e := FALSE;
  p_AllowDirectSQLInsert_0667eb588b5e := FALSE;
  p_AllowDirectSQLUpdate_0667eb588b5e := FALSE;
  p_AllowDirectSQLDelete_0667eb588b5e := FALSE;
  p_EnableFieldLevelSecurity_0667eb588b5e := FALSE;
  p_ID_0667eb588b5e := '559054C2-8F03-4A66-B4FD-70DE5948ACE2';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_0667eb588b5e,
    'Name', p_Name_0667eb588b5e,
    'NameSuffix', p_NameSuffix_0667eb588b5e,
    'Description', p_Description_0667eb588b5e,
    'AutoUpdateDescription', p_AutoUpdateDescription_0667eb588b5e,
    'BaseView', p_BaseView_0667eb588b5e,
    'BaseViewGenerated', p_BaseViewGenerated_0667eb588b5e,
    'VirtualEntity', p_VirtualEntity_0667eb588b5e,
    'TrackRecordChanges', p_TrackRecordChanges_0667eb588b5e,
    'AuditRecordAccess', p_AuditRecordAccess_0667eb588b5e,
    'AuditViewRuns', p_AuditViewRuns_0667eb588b5e,
    'IncludeInAPI', p_IncludeInAPI_0667eb588b5e,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_0667eb588b5e,
    'AllowUpdateAPI', p_AllowUpdateAPI_0667eb588b5e,
    'AllowCreateAPI', p_AllowCreateAPI_0667eb588b5e,
    'AllowDeleteAPI', p_AllowDeleteAPI_0667eb588b5e,
    'CustomResolverAPI', p_CustomResolverAPI_0667eb588b5e,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_0667eb588b5e,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_0667eb588b5e,
    'FullTextCatalog', p_FullTextCatalog_0667eb588b5e,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_0667eb588b5e,
    'FullTextIndex', p_FullTextIndex_0667eb588b5e,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_0667eb588b5e,
    'FullTextSearchFunction', p_FullTextSearchFunction_0667eb588b5e,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_0667eb588b5e,
    'UserViewMaxRows', p_UserViewMaxRows_0667eb588b5e,
    'spCreate', p_spCreate_0667eb588b5e,
    'spUpdate', p_spUpdate_0667eb588b5e,
    'spDelete', p_spDelete_0667eb588b5e,
    'spCreateGenerated', p_spCreateGenerated_0667eb588b5e,
    'spUpdateGenerated', p_spUpdateGenerated_0667eb588b5e,
    'spDeleteGenerated', p_spDeleteGenerated_0667eb588b5e,
    'CascadeDeletes', p_CascadeDeletes_0667eb588b5e,
    'DeleteType', p_DeleteType_0667eb588b5e,
    'AllowRecordMerge', p_AllowRecordMerge_0667eb588b5e,
    'spMatch', p_spMatch_0667eb588b5e,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_0667eb588b5e,
    'UserFormGenerated', p_UserFormGenerated_0667eb588b5e,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_0667eb588b5e,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_0667eb588b5e,
    'PreferredCommunicationField', p_PreferredCommunicationField_0667eb588b5e,
    'Icon', p_Icon_0667eb588b5e,
    'ScopeDefault', p_ScopeDefault_0667eb588b5e,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_0667eb588b5e,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_0667eb588b5e,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_0667eb588b5e,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_0667eb588b5e,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_0667eb588b5e,
    'RowCount', p_RowCount_0667eb588b5e,
    'RowCountRunAt', p_RowCountRunAt_0667eb588b5e
  ) ||
  jsonb_build_object(
    'Status', p_Status_0667eb588b5e,
    'DisplayName', p_DisplayName_0667eb588b5e,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_0667eb588b5e,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_0667eb588b5e,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_0667eb588b5e,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_0667eb588b5e,
    'SupportsGeoCoding', p_SupportsGeoCoding_0667eb588b5e,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_0667eb588b5e,
    'AllowCaching', p_AllowCaching_0667eb588b5e,
    'DetectExternalChanges', p_DetectExternalChanges_0667eb588b5e,
    'ExternalDataSourceID', p_ExternalDataSourceID_0667eb588b5e,
    'ExternalObjectName', p_ExternalObjectName_0667eb588b5e,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_0667eb588b5e,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_0667eb588b5e,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_0667eb588b5e,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_0667eb588b5e,
    'Configuration', p_Configuration_0667eb588b5e,
    'SubtypeSelector', p_SubtypeSelector_0667eb588b5e,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_0667eb588b5e,
    'ID', p_ID_0667eb588b5e
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_794996b246af UUID;
  p_Name_794996b246af VARCHAR(255);
  p_NameSuffix_794996b246af VARCHAR(255);
  p_Description_794996b246af TEXT;
  p_AutoUpdateDescription_794996b246af BOOLEAN;
  p_BaseView_794996b246af VARCHAR(255);
  p_BaseViewGenerated_794996b246af BOOLEAN;
  p_VirtualEntity_794996b246af BOOLEAN;
  p_TrackRecordChanges_794996b246af BOOLEAN;
  p_AuditRecordAccess_794996b246af BOOLEAN;
  p_AuditViewRuns_794996b246af BOOLEAN;
  p_IncludeInAPI_794996b246af BOOLEAN;
  p_AllowAllRowsAPI_794996b246af BOOLEAN;
  p_AllowUpdateAPI_794996b246af BOOLEAN;
  p_AllowCreateAPI_794996b246af BOOLEAN;
  p_AllowDeleteAPI_794996b246af BOOLEAN;
  p_CustomResolverAPI_794996b246af BOOLEAN;
  p_AllowUserSearchAPI_794996b246af BOOLEAN;
  p_FullTextSearchEnabled_794996b246af BOOLEAN;
  p_FullTextCatalog_794996b246af VARCHAR(255);
  p_FullTextCatalogGenerated_794996b246af BOOLEAN;
  p_FullTextIndex_794996b246af VARCHAR(255);
  p_FullTextIndexGenerated_794996b246af BOOLEAN;
  p_FullTextSearchFunction_794996b246af VARCHAR(255);
  p_FullTextSearchFunctionGenerated_794996b246af BOOLEAN;
  p_UserViewMaxRows_794996b246af INTEGER;
  p_spCreate_794996b246af VARCHAR(255);
  p_spUpdate_794996b246af VARCHAR(255);
  p_spDelete_794996b246af VARCHAR(255);
  p_spCreateGenerated_794996b246af BOOLEAN;
  p_spUpdateGenerated_794996b246af BOOLEAN;
  p_spDeleteGenerated_794996b246af BOOLEAN;
  p_CascadeDeletes_794996b246af BOOLEAN;
  p_DeleteType_794996b246af VARCHAR(10);
  p_AllowRecordMerge_794996b246af BOOLEAN;
  p_spMatch_794996b246af VARCHAR(255);
  p_RelationshipDefaultDisplayType_794996b246af VARCHAR(20);
  p_UserFormGenerated_794996b246af BOOLEAN;
  p_EntityObjectSubclassName_794996b246af VARCHAR(255);
  p_EntityObjectSubclassImport_794996b246af VARCHAR(255);
  p_PreferredCommunicationField_794996b246af VARCHAR(255);
  p_Icon_794996b246af VARCHAR(500);
  p_ScopeDefault_794996b246af VARCHAR(100);
  p_RowsToPackWithSchema_794996b246af VARCHAR(20);
  p_RowsToPackSampleMethod_794996b246af VARCHAR(20);
  p_RowsToPackSampleCount_794996b246af INTEGER;
  p_RowsToPackSampleOrder_794996b246af TEXT;
  p_AutoRowCountFrequency_794996b246af INTEGER;
  p_RowCount_794996b246af BIGINT;
  p_RowCountRunAt_794996b246af TIMESTAMPTZ;
  p_Status_794996b246af VARCHAR(25);
  p_DisplayName_794996b246af VARCHAR(255);
  p_AllowMultipleSubtypes_794996b246af BOOLEAN;
  p_AutoUpdateFullTextSearch_794996b246af BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_794996b246af BOOLEAN;
  p_TrustServerCacheCompletely_794996b246af BOOLEAN;
  p_SupportsGeoCoding_794996b246af BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_794996b246af BOOLEAN;
  p_AllowCaching_794996b246af BOOLEAN;
  p_DetectExternalChanges_794996b246af BOOLEAN;
  p_ExternalDataSourceID_794996b246af UUID;
  p_ExternalObjectName_794996b246af VARCHAR(255);
  p_GeneratedBaseViewName_794996b246af VARCHAR(255);
  p_AllowDirectSQLInsert_794996b246af BOOLEAN;
  p_AllowDirectSQLUpdate_794996b246af BOOLEAN;
  p_AllowDirectSQLDelete_794996b246af BOOLEAN;
  p_Configuration_794996b246af TEXT;
  p_SubtypeSelector_794996b246af TEXT;
  p_EnableFieldLevelSecurity_794996b246af BOOLEAN;
  p_ID_794996b246af UUID;
BEGIN
  p_Name_794996b246af := 'MJ_BizApps_Tasks: Task Tag Links';
  p_AutoUpdateDescription_794996b246af := TRUE;
  p_BaseView_794996b246af := 'vwTaskTagLinks';
  p_BaseViewGenerated_794996b246af := TRUE;
  p_VirtualEntity_794996b246af := FALSE;
  p_TrackRecordChanges_794996b246af := TRUE;
  p_AuditRecordAccess_794996b246af := FALSE;
  p_AuditViewRuns_794996b246af := FALSE;
  p_IncludeInAPI_794996b246af := TRUE;
  p_AllowAllRowsAPI_794996b246af := FALSE;
  p_AllowUpdateAPI_794996b246af := TRUE;
  p_AllowCreateAPI_794996b246af := TRUE;
  p_AllowDeleteAPI_794996b246af := TRUE;
  p_CustomResolverAPI_794996b246af := FALSE;
  p_AllowUserSearchAPI_794996b246af := FALSE;
  p_FullTextSearchEnabled_794996b246af := FALSE;
  p_FullTextCatalogGenerated_794996b246af := TRUE;
  p_FullTextIndexGenerated_794996b246af := TRUE;
  p_FullTextSearchFunctionGenerated_794996b246af := TRUE;
  p_UserViewMaxRows_794996b246af := 1000;
  p_spCreateGenerated_794996b246af := TRUE;
  p_spUpdateGenerated_794996b246af := TRUE;
  p_spDeleteGenerated_794996b246af := TRUE;
  p_CascadeDeletes_794996b246af := FALSE;
  p_DeleteType_794996b246af := 'Hard';
  p_AllowRecordMerge_794996b246af := FALSE;
  p_RelationshipDefaultDisplayType_794996b246af := 'Search';
  p_UserFormGenerated_794996b246af := TRUE;
  p_RowsToPackWithSchema_794996b246af := 'None';
  p_RowsToPackSampleMethod_794996b246af := 'random';
  p_RowsToPackSampleCount_794996b246af := 0;
  p_Status_794996b246af := 'Active';
  p_DisplayName_794996b246af := 'Task Tag Links';
  p_AllowMultipleSubtypes_794996b246af := FALSE;
  p_AutoUpdateFullTextSearch_794996b246af := TRUE;
  p_AutoUpdateAllowUserSearchAPI_794996b246af := FALSE;
  p_TrustServerCacheCompletely_794996b246af := TRUE;
  p_SupportsGeoCoding_794996b246af := FALSE;
  p_AutoUpdateSupportsGeoCoding_794996b246af := TRUE;
  p_AllowCaching_794996b246af := FALSE;
  p_DetectExternalChanges_794996b246af := FALSE;
  p_AllowDirectSQLInsert_794996b246af := FALSE;
  p_AllowDirectSQLUpdate_794996b246af := FALSE;
  p_AllowDirectSQLDelete_794996b246af := FALSE;
  p_EnableFieldLevelSecurity_794996b246af := FALSE;
  p_ID_794996b246af := 'EA953D6B-524E-4A09-A842-9A0B0F1F850C';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_794996b246af,
    'Name', p_Name_794996b246af,
    'NameSuffix', p_NameSuffix_794996b246af,
    'Description', p_Description_794996b246af,
    'AutoUpdateDescription', p_AutoUpdateDescription_794996b246af,
    'BaseView', p_BaseView_794996b246af,
    'BaseViewGenerated', p_BaseViewGenerated_794996b246af,
    'VirtualEntity', p_VirtualEntity_794996b246af,
    'TrackRecordChanges', p_TrackRecordChanges_794996b246af,
    'AuditRecordAccess', p_AuditRecordAccess_794996b246af,
    'AuditViewRuns', p_AuditViewRuns_794996b246af,
    'IncludeInAPI', p_IncludeInAPI_794996b246af,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_794996b246af,
    'AllowUpdateAPI', p_AllowUpdateAPI_794996b246af,
    'AllowCreateAPI', p_AllowCreateAPI_794996b246af,
    'AllowDeleteAPI', p_AllowDeleteAPI_794996b246af,
    'CustomResolverAPI', p_CustomResolverAPI_794996b246af,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_794996b246af,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_794996b246af,
    'FullTextCatalog', p_FullTextCatalog_794996b246af,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_794996b246af,
    'FullTextIndex', p_FullTextIndex_794996b246af,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_794996b246af,
    'FullTextSearchFunction', p_FullTextSearchFunction_794996b246af,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_794996b246af,
    'UserViewMaxRows', p_UserViewMaxRows_794996b246af,
    'spCreate', p_spCreate_794996b246af,
    'spUpdate', p_spUpdate_794996b246af,
    'spDelete', p_spDelete_794996b246af,
    'spCreateGenerated', p_spCreateGenerated_794996b246af,
    'spUpdateGenerated', p_spUpdateGenerated_794996b246af,
    'spDeleteGenerated', p_spDeleteGenerated_794996b246af,
    'CascadeDeletes', p_CascadeDeletes_794996b246af,
    'DeleteType', p_DeleteType_794996b246af,
    'AllowRecordMerge', p_AllowRecordMerge_794996b246af,
    'spMatch', p_spMatch_794996b246af,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_794996b246af,
    'UserFormGenerated', p_UserFormGenerated_794996b246af,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_794996b246af,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_794996b246af,
    'PreferredCommunicationField', p_PreferredCommunicationField_794996b246af,
    'Icon', p_Icon_794996b246af,
    'ScopeDefault', p_ScopeDefault_794996b246af,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_794996b246af,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_794996b246af,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_794996b246af,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_794996b246af,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_794996b246af,
    'RowCount', p_RowCount_794996b246af,
    'RowCountRunAt', p_RowCountRunAt_794996b246af
  ) ||
  jsonb_build_object(
    'Status', p_Status_794996b246af,
    'DisplayName', p_DisplayName_794996b246af,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_794996b246af,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_794996b246af,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_794996b246af,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_794996b246af,
    'SupportsGeoCoding', p_SupportsGeoCoding_794996b246af,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_794996b246af,
    'AllowCaching', p_AllowCaching_794996b246af,
    'DetectExternalChanges', p_DetectExternalChanges_794996b246af,
    'ExternalDataSourceID', p_ExternalDataSourceID_794996b246af,
    'ExternalObjectName', p_ExternalObjectName_794996b246af,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_794996b246af,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_794996b246af,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_794996b246af,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_794996b246af,
    'Configuration', p_Configuration_794996b246af,
    'SubtypeSelector', p_SubtypeSelector_794996b246af,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_794996b246af,
    'ID', p_ID_794996b246af
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_946a8f1607d8 UUID;
  p_Name_946a8f1607d8 VARCHAR(255);
  p_NameSuffix_946a8f1607d8 VARCHAR(255);
  p_Description_946a8f1607d8 TEXT;
  p_AutoUpdateDescription_946a8f1607d8 BOOLEAN;
  p_BaseView_946a8f1607d8 VARCHAR(255);
  p_BaseViewGenerated_946a8f1607d8 BOOLEAN;
  p_VirtualEntity_946a8f1607d8 BOOLEAN;
  p_TrackRecordChanges_946a8f1607d8 BOOLEAN;
  p_AuditRecordAccess_946a8f1607d8 BOOLEAN;
  p_AuditViewRuns_946a8f1607d8 BOOLEAN;
  p_IncludeInAPI_946a8f1607d8 BOOLEAN;
  p_AllowAllRowsAPI_946a8f1607d8 BOOLEAN;
  p_AllowUpdateAPI_946a8f1607d8 BOOLEAN;
  p_AllowCreateAPI_946a8f1607d8 BOOLEAN;
  p_AllowDeleteAPI_946a8f1607d8 BOOLEAN;
  p_CustomResolverAPI_946a8f1607d8 BOOLEAN;
  p_AllowUserSearchAPI_946a8f1607d8 BOOLEAN;
  p_FullTextSearchEnabled_946a8f1607d8 BOOLEAN;
  p_FullTextCatalog_946a8f1607d8 VARCHAR(255);
  p_FullTextCatalogGenerated_946a8f1607d8 BOOLEAN;
  p_FullTextIndex_946a8f1607d8 VARCHAR(255);
  p_FullTextIndexGenerated_946a8f1607d8 BOOLEAN;
  p_FullTextSearchFunction_946a8f1607d8 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_946a8f1607d8 BOOLEAN;
  p_UserViewMaxRows_946a8f1607d8 INTEGER;
  p_spCreate_946a8f1607d8 VARCHAR(255);
  p_spUpdate_946a8f1607d8 VARCHAR(255);
  p_spDelete_946a8f1607d8 VARCHAR(255);
  p_spCreateGenerated_946a8f1607d8 BOOLEAN;
  p_spUpdateGenerated_946a8f1607d8 BOOLEAN;
  p_spDeleteGenerated_946a8f1607d8 BOOLEAN;
  p_CascadeDeletes_946a8f1607d8 BOOLEAN;
  p_DeleteType_946a8f1607d8 VARCHAR(10);
  p_AllowRecordMerge_946a8f1607d8 BOOLEAN;
  p_spMatch_946a8f1607d8 VARCHAR(255);
  p_RelationshipDefaultDisplayType_946a8f1607d8 VARCHAR(20);
  p_UserFormGenerated_946a8f1607d8 BOOLEAN;
  p_EntityObjectSubclassName_946a8f1607d8 VARCHAR(255);
  p_EntityObjectSubclassImport_946a8f1607d8 VARCHAR(255);
  p_PreferredCommunicationField_946a8f1607d8 VARCHAR(255);
  p_Icon_946a8f1607d8 VARCHAR(500);
  p_ScopeDefault_946a8f1607d8 VARCHAR(100);
  p_RowsToPackWithSchema_946a8f1607d8 VARCHAR(20);
  p_RowsToPackSampleMethod_946a8f1607d8 VARCHAR(20);
  p_RowsToPackSampleCount_946a8f1607d8 INTEGER;
  p_RowsToPackSampleOrder_946a8f1607d8 TEXT;
  p_AutoRowCountFrequency_946a8f1607d8 INTEGER;
  p_RowCount_946a8f1607d8 BIGINT;
  p_RowCountRunAt_946a8f1607d8 TIMESTAMPTZ;
  p_Status_946a8f1607d8 VARCHAR(25);
  p_DisplayName_946a8f1607d8 VARCHAR(255);
  p_AllowMultipleSubtypes_946a8f1607d8 BOOLEAN;
  p_AutoUpdateFullTextSearch_946a8f1607d8 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_946a8f1607d8 BOOLEAN;
  p_TrustServerCacheCompletely_946a8f1607d8 BOOLEAN;
  p_SupportsGeoCoding_946a8f1607d8 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_946a8f1607d8 BOOLEAN;
  p_AllowCaching_946a8f1607d8 BOOLEAN;
  p_DetectExternalChanges_946a8f1607d8 BOOLEAN;
  p_ExternalDataSourceID_946a8f1607d8 UUID;
  p_ExternalObjectName_946a8f1607d8 VARCHAR(255);
  p_GeneratedBaseViewName_946a8f1607d8 VARCHAR(255);
  p_AllowDirectSQLInsert_946a8f1607d8 BOOLEAN;
  p_AllowDirectSQLUpdate_946a8f1607d8 BOOLEAN;
  p_AllowDirectSQLDelete_946a8f1607d8 BOOLEAN;
  p_Configuration_946a8f1607d8 TEXT;
  p_SubtypeSelector_946a8f1607d8 TEXT;
  p_EnableFieldLevelSecurity_946a8f1607d8 BOOLEAN;
  p_ID_946a8f1607d8 UUID;
BEGIN
  p_Name_946a8f1607d8 := 'MJ_BizApps_Tasks: Task Tags';
  p_AutoUpdateDescription_946a8f1607d8 := TRUE;
  p_BaseView_946a8f1607d8 := 'vwTaskTags';
  p_BaseViewGenerated_946a8f1607d8 := TRUE;
  p_VirtualEntity_946a8f1607d8 := FALSE;
  p_TrackRecordChanges_946a8f1607d8 := TRUE;
  p_AuditRecordAccess_946a8f1607d8 := FALSE;
  p_AuditViewRuns_946a8f1607d8 := FALSE;
  p_IncludeInAPI_946a8f1607d8 := TRUE;
  p_AllowAllRowsAPI_946a8f1607d8 := FALSE;
  p_AllowUpdateAPI_946a8f1607d8 := TRUE;
  p_AllowCreateAPI_946a8f1607d8 := TRUE;
  p_AllowDeleteAPI_946a8f1607d8 := TRUE;
  p_CustomResolverAPI_946a8f1607d8 := FALSE;
  p_AllowUserSearchAPI_946a8f1607d8 := FALSE;
  p_FullTextSearchEnabled_946a8f1607d8 := FALSE;
  p_FullTextCatalogGenerated_946a8f1607d8 := TRUE;
  p_FullTextIndexGenerated_946a8f1607d8 := TRUE;
  p_FullTextSearchFunctionGenerated_946a8f1607d8 := TRUE;
  p_UserViewMaxRows_946a8f1607d8 := 1000;
  p_spCreateGenerated_946a8f1607d8 := TRUE;
  p_spUpdateGenerated_946a8f1607d8 := TRUE;
  p_spDeleteGenerated_946a8f1607d8 := TRUE;
  p_CascadeDeletes_946a8f1607d8 := FALSE;
  p_DeleteType_946a8f1607d8 := 'Hard';
  p_AllowRecordMerge_946a8f1607d8 := FALSE;
  p_RelationshipDefaultDisplayType_946a8f1607d8 := 'Search';
  p_UserFormGenerated_946a8f1607d8 := TRUE;
  p_RowsToPackWithSchema_946a8f1607d8 := 'None';
  p_RowsToPackSampleMethod_946a8f1607d8 := 'random';
  p_RowsToPackSampleCount_946a8f1607d8 := 0;
  p_Status_946a8f1607d8 := 'Active';
  p_DisplayName_946a8f1607d8 := 'Task Tags';
  p_AllowMultipleSubtypes_946a8f1607d8 := FALSE;
  p_AutoUpdateFullTextSearch_946a8f1607d8 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_946a8f1607d8 := FALSE;
  p_TrustServerCacheCompletely_946a8f1607d8 := TRUE;
  p_SupportsGeoCoding_946a8f1607d8 := FALSE;
  p_AutoUpdateSupportsGeoCoding_946a8f1607d8 := TRUE;
  p_AllowCaching_946a8f1607d8 := FALSE;
  p_DetectExternalChanges_946a8f1607d8 := FALSE;
  p_AllowDirectSQLInsert_946a8f1607d8 := FALSE;
  p_AllowDirectSQLUpdate_946a8f1607d8 := FALSE;
  p_AllowDirectSQLDelete_946a8f1607d8 := FALSE;
  p_EnableFieldLevelSecurity_946a8f1607d8 := FALSE;
  p_ID_946a8f1607d8 := '5DB17493-CD0A-4633-80D4-D4A499662C76';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_946a8f1607d8,
    'Name', p_Name_946a8f1607d8,
    'NameSuffix', p_NameSuffix_946a8f1607d8,
    'Description', p_Description_946a8f1607d8,
    'AutoUpdateDescription', p_AutoUpdateDescription_946a8f1607d8,
    'BaseView', p_BaseView_946a8f1607d8,
    'BaseViewGenerated', p_BaseViewGenerated_946a8f1607d8,
    'VirtualEntity', p_VirtualEntity_946a8f1607d8,
    'TrackRecordChanges', p_TrackRecordChanges_946a8f1607d8,
    'AuditRecordAccess', p_AuditRecordAccess_946a8f1607d8,
    'AuditViewRuns', p_AuditViewRuns_946a8f1607d8,
    'IncludeInAPI', p_IncludeInAPI_946a8f1607d8,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_946a8f1607d8,
    'AllowUpdateAPI', p_AllowUpdateAPI_946a8f1607d8,
    'AllowCreateAPI', p_AllowCreateAPI_946a8f1607d8,
    'AllowDeleteAPI', p_AllowDeleteAPI_946a8f1607d8,
    'CustomResolverAPI', p_CustomResolverAPI_946a8f1607d8,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_946a8f1607d8,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_946a8f1607d8,
    'FullTextCatalog', p_FullTextCatalog_946a8f1607d8,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_946a8f1607d8,
    'FullTextIndex', p_FullTextIndex_946a8f1607d8,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_946a8f1607d8,
    'FullTextSearchFunction', p_FullTextSearchFunction_946a8f1607d8,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_946a8f1607d8,
    'UserViewMaxRows', p_UserViewMaxRows_946a8f1607d8,
    'spCreate', p_spCreate_946a8f1607d8,
    'spUpdate', p_spUpdate_946a8f1607d8,
    'spDelete', p_spDelete_946a8f1607d8,
    'spCreateGenerated', p_spCreateGenerated_946a8f1607d8,
    'spUpdateGenerated', p_spUpdateGenerated_946a8f1607d8,
    'spDeleteGenerated', p_spDeleteGenerated_946a8f1607d8,
    'CascadeDeletes', p_CascadeDeletes_946a8f1607d8,
    'DeleteType', p_DeleteType_946a8f1607d8,
    'AllowRecordMerge', p_AllowRecordMerge_946a8f1607d8,
    'spMatch', p_spMatch_946a8f1607d8,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_946a8f1607d8,
    'UserFormGenerated', p_UserFormGenerated_946a8f1607d8,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_946a8f1607d8,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_946a8f1607d8,
    'PreferredCommunicationField', p_PreferredCommunicationField_946a8f1607d8,
    'Icon', p_Icon_946a8f1607d8,
    'ScopeDefault', p_ScopeDefault_946a8f1607d8,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_946a8f1607d8,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_946a8f1607d8,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_946a8f1607d8,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_946a8f1607d8,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_946a8f1607d8,
    'RowCount', p_RowCount_946a8f1607d8,
    'RowCountRunAt', p_RowCountRunAt_946a8f1607d8
  ) ||
  jsonb_build_object(
    'Status', p_Status_946a8f1607d8,
    'DisplayName', p_DisplayName_946a8f1607d8,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_946a8f1607d8,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_946a8f1607d8,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_946a8f1607d8,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_946a8f1607d8,
    'SupportsGeoCoding', p_SupportsGeoCoding_946a8f1607d8,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_946a8f1607d8,
    'AllowCaching', p_AllowCaching_946a8f1607d8,
    'DetectExternalChanges', p_DetectExternalChanges_946a8f1607d8,
    'ExternalDataSourceID', p_ExternalDataSourceID_946a8f1607d8,
    'ExternalObjectName', p_ExternalObjectName_946a8f1607d8,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_946a8f1607d8,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_946a8f1607d8,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_946a8f1607d8,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_946a8f1607d8,
    'Configuration', p_Configuration_946a8f1607d8,
    'SubtypeSelector', p_SubtypeSelector_946a8f1607d8,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_946a8f1607d8,
    'ID', p_ID_946a8f1607d8
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_7f28faa155cf UUID;
  p_Name_7f28faa155cf VARCHAR(255);
  p_NameSuffix_7f28faa155cf VARCHAR(255);
  p_Description_7f28faa155cf TEXT;
  p_AutoUpdateDescription_7f28faa155cf BOOLEAN;
  p_BaseView_7f28faa155cf VARCHAR(255);
  p_BaseViewGenerated_7f28faa155cf BOOLEAN;
  p_VirtualEntity_7f28faa155cf BOOLEAN;
  p_TrackRecordChanges_7f28faa155cf BOOLEAN;
  p_AuditRecordAccess_7f28faa155cf BOOLEAN;
  p_AuditViewRuns_7f28faa155cf BOOLEAN;
  p_IncludeInAPI_7f28faa155cf BOOLEAN;
  p_AllowAllRowsAPI_7f28faa155cf BOOLEAN;
  p_AllowUpdateAPI_7f28faa155cf BOOLEAN;
  p_AllowCreateAPI_7f28faa155cf BOOLEAN;
  p_AllowDeleteAPI_7f28faa155cf BOOLEAN;
  p_CustomResolverAPI_7f28faa155cf BOOLEAN;
  p_AllowUserSearchAPI_7f28faa155cf BOOLEAN;
  p_FullTextSearchEnabled_7f28faa155cf BOOLEAN;
  p_FullTextCatalog_7f28faa155cf VARCHAR(255);
  p_FullTextCatalogGenerated_7f28faa155cf BOOLEAN;
  p_FullTextIndex_7f28faa155cf VARCHAR(255);
  p_FullTextIndexGenerated_7f28faa155cf BOOLEAN;
  p_FullTextSearchFunction_7f28faa155cf VARCHAR(255);
  p_FullTextSearchFunctionGenerated_7f28faa155cf BOOLEAN;
  p_UserViewMaxRows_7f28faa155cf INTEGER;
  p_spCreate_7f28faa155cf VARCHAR(255);
  p_spUpdate_7f28faa155cf VARCHAR(255);
  p_spDelete_7f28faa155cf VARCHAR(255);
  p_spCreateGenerated_7f28faa155cf BOOLEAN;
  p_spUpdateGenerated_7f28faa155cf BOOLEAN;
  p_spDeleteGenerated_7f28faa155cf BOOLEAN;
  p_CascadeDeletes_7f28faa155cf BOOLEAN;
  p_DeleteType_7f28faa155cf VARCHAR(10);
  p_AllowRecordMerge_7f28faa155cf BOOLEAN;
  p_spMatch_7f28faa155cf VARCHAR(255);
  p_RelationshipDefaultDisplayType_7f28faa155cf VARCHAR(20);
  p_UserFormGenerated_7f28faa155cf BOOLEAN;
  p_EntityObjectSubclassName_7f28faa155cf VARCHAR(255);
  p_EntityObjectSubclassImport_7f28faa155cf VARCHAR(255);
  p_PreferredCommunicationField_7f28faa155cf VARCHAR(255);
  p_Icon_7f28faa155cf VARCHAR(500);
  p_ScopeDefault_7f28faa155cf VARCHAR(100);
  p_RowsToPackWithSchema_7f28faa155cf VARCHAR(20);
  p_RowsToPackSampleMethod_7f28faa155cf VARCHAR(20);
  p_RowsToPackSampleCount_7f28faa155cf INTEGER;
  p_RowsToPackSampleOrder_7f28faa155cf TEXT;
  p_AutoRowCountFrequency_7f28faa155cf INTEGER;
  p_RowCount_7f28faa155cf BIGINT;
  p_RowCountRunAt_7f28faa155cf TIMESTAMPTZ;
  p_Status_7f28faa155cf VARCHAR(25);
  p_DisplayName_7f28faa155cf VARCHAR(255);
  p_AllowMultipleSubtypes_7f28faa155cf BOOLEAN;
  p_AutoUpdateFullTextSearch_7f28faa155cf BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_7f28faa155cf BOOLEAN;
  p_TrustServerCacheCompletely_7f28faa155cf BOOLEAN;
  p_SupportsGeoCoding_7f28faa155cf BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_7f28faa155cf BOOLEAN;
  p_AllowCaching_7f28faa155cf BOOLEAN;
  p_DetectExternalChanges_7f28faa155cf BOOLEAN;
  p_ExternalDataSourceID_7f28faa155cf UUID;
  p_ExternalObjectName_7f28faa155cf VARCHAR(255);
  p_GeneratedBaseViewName_7f28faa155cf VARCHAR(255);
  p_AllowDirectSQLInsert_7f28faa155cf BOOLEAN;
  p_AllowDirectSQLUpdate_7f28faa155cf BOOLEAN;
  p_AllowDirectSQLDelete_7f28faa155cf BOOLEAN;
  p_Configuration_7f28faa155cf TEXT;
  p_SubtypeSelector_7f28faa155cf TEXT;
  p_EnableFieldLevelSecurity_7f28faa155cf BOOLEAN;
  p_ID_7f28faa155cf UUID;
BEGIN
  p_Name_7f28faa155cf := 'MJ_BizApps_Tasks: Task Template Item Dependencies';
  p_AutoUpdateDescription_7f28faa155cf := TRUE;
  p_BaseView_7f28faa155cf := 'vwTaskTemplateItemDependencies';
  p_BaseViewGenerated_7f28faa155cf := TRUE;
  p_VirtualEntity_7f28faa155cf := FALSE;
  p_TrackRecordChanges_7f28faa155cf := TRUE;
  p_AuditRecordAccess_7f28faa155cf := FALSE;
  p_AuditViewRuns_7f28faa155cf := FALSE;
  p_IncludeInAPI_7f28faa155cf := TRUE;
  p_AllowAllRowsAPI_7f28faa155cf := FALSE;
  p_AllowUpdateAPI_7f28faa155cf := TRUE;
  p_AllowCreateAPI_7f28faa155cf := TRUE;
  p_AllowDeleteAPI_7f28faa155cf := TRUE;
  p_CustomResolverAPI_7f28faa155cf := FALSE;
  p_AllowUserSearchAPI_7f28faa155cf := FALSE;
  p_FullTextSearchEnabled_7f28faa155cf := FALSE;
  p_FullTextCatalogGenerated_7f28faa155cf := TRUE;
  p_FullTextIndexGenerated_7f28faa155cf := TRUE;
  p_FullTextSearchFunctionGenerated_7f28faa155cf := TRUE;
  p_UserViewMaxRows_7f28faa155cf := 1000;
  p_spCreateGenerated_7f28faa155cf := TRUE;
  p_spUpdateGenerated_7f28faa155cf := TRUE;
  p_spDeleteGenerated_7f28faa155cf := TRUE;
  p_CascadeDeletes_7f28faa155cf := FALSE;
  p_DeleteType_7f28faa155cf := 'Hard';
  p_AllowRecordMerge_7f28faa155cf := FALSE;
  p_RelationshipDefaultDisplayType_7f28faa155cf := 'Search';
  p_UserFormGenerated_7f28faa155cf := TRUE;
  p_RowsToPackWithSchema_7f28faa155cf := 'None';
  p_RowsToPackSampleMethod_7f28faa155cf := 'random';
  p_RowsToPackSampleCount_7f28faa155cf := 0;
  p_Status_7f28faa155cf := 'Active';
  p_DisplayName_7f28faa155cf := 'Task Template Item Dependencies';
  p_AllowMultipleSubtypes_7f28faa155cf := FALSE;
  p_AutoUpdateFullTextSearch_7f28faa155cf := TRUE;
  p_AutoUpdateAllowUserSearchAPI_7f28faa155cf := FALSE;
  p_TrustServerCacheCompletely_7f28faa155cf := TRUE;
  p_SupportsGeoCoding_7f28faa155cf := FALSE;
  p_AutoUpdateSupportsGeoCoding_7f28faa155cf := TRUE;
  p_AllowCaching_7f28faa155cf := FALSE;
  p_DetectExternalChanges_7f28faa155cf := FALSE;
  p_AllowDirectSQLInsert_7f28faa155cf := FALSE;
  p_AllowDirectSQLUpdate_7f28faa155cf := FALSE;
  p_AllowDirectSQLDelete_7f28faa155cf := FALSE;
  p_EnableFieldLevelSecurity_7f28faa155cf := FALSE;
  p_ID_7f28faa155cf := '8A30F14C-26FF-476E-8CA1-B10EAD29A428';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_7f28faa155cf,
    'Name', p_Name_7f28faa155cf,
    'NameSuffix', p_NameSuffix_7f28faa155cf,
    'Description', p_Description_7f28faa155cf,
    'AutoUpdateDescription', p_AutoUpdateDescription_7f28faa155cf,
    'BaseView', p_BaseView_7f28faa155cf,
    'BaseViewGenerated', p_BaseViewGenerated_7f28faa155cf,
    'VirtualEntity', p_VirtualEntity_7f28faa155cf,
    'TrackRecordChanges', p_TrackRecordChanges_7f28faa155cf,
    'AuditRecordAccess', p_AuditRecordAccess_7f28faa155cf,
    'AuditViewRuns', p_AuditViewRuns_7f28faa155cf,
    'IncludeInAPI', p_IncludeInAPI_7f28faa155cf,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_7f28faa155cf,
    'AllowUpdateAPI', p_AllowUpdateAPI_7f28faa155cf,
    'AllowCreateAPI', p_AllowCreateAPI_7f28faa155cf,
    'AllowDeleteAPI', p_AllowDeleteAPI_7f28faa155cf,
    'CustomResolverAPI', p_CustomResolverAPI_7f28faa155cf,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_7f28faa155cf,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_7f28faa155cf,
    'FullTextCatalog', p_FullTextCatalog_7f28faa155cf,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_7f28faa155cf,
    'FullTextIndex', p_FullTextIndex_7f28faa155cf,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_7f28faa155cf,
    'FullTextSearchFunction', p_FullTextSearchFunction_7f28faa155cf,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_7f28faa155cf,
    'UserViewMaxRows', p_UserViewMaxRows_7f28faa155cf,
    'spCreate', p_spCreate_7f28faa155cf,
    'spUpdate', p_spUpdate_7f28faa155cf,
    'spDelete', p_spDelete_7f28faa155cf,
    'spCreateGenerated', p_spCreateGenerated_7f28faa155cf,
    'spUpdateGenerated', p_spUpdateGenerated_7f28faa155cf,
    'spDeleteGenerated', p_spDeleteGenerated_7f28faa155cf,
    'CascadeDeletes', p_CascadeDeletes_7f28faa155cf,
    'DeleteType', p_DeleteType_7f28faa155cf,
    'AllowRecordMerge', p_AllowRecordMerge_7f28faa155cf,
    'spMatch', p_spMatch_7f28faa155cf,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_7f28faa155cf,
    'UserFormGenerated', p_UserFormGenerated_7f28faa155cf,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_7f28faa155cf,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_7f28faa155cf,
    'PreferredCommunicationField', p_PreferredCommunicationField_7f28faa155cf,
    'Icon', p_Icon_7f28faa155cf,
    'ScopeDefault', p_ScopeDefault_7f28faa155cf,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_7f28faa155cf,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_7f28faa155cf,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_7f28faa155cf,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_7f28faa155cf,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_7f28faa155cf,
    'RowCount', p_RowCount_7f28faa155cf,
    'RowCountRunAt', p_RowCountRunAt_7f28faa155cf
  ) ||
  jsonb_build_object(
    'Status', p_Status_7f28faa155cf,
    'DisplayName', p_DisplayName_7f28faa155cf,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_7f28faa155cf,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_7f28faa155cf,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_7f28faa155cf,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_7f28faa155cf,
    'SupportsGeoCoding', p_SupportsGeoCoding_7f28faa155cf,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_7f28faa155cf,
    'AllowCaching', p_AllowCaching_7f28faa155cf,
    'DetectExternalChanges', p_DetectExternalChanges_7f28faa155cf,
    'ExternalDataSourceID', p_ExternalDataSourceID_7f28faa155cf,
    'ExternalObjectName', p_ExternalObjectName_7f28faa155cf,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_7f28faa155cf,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_7f28faa155cf,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_7f28faa155cf,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_7f28faa155cf,
    'Configuration', p_Configuration_7f28faa155cf,
    'SubtypeSelector', p_SubtypeSelector_7f28faa155cf,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_7f28faa155cf,
    'ID', p_ID_7f28faa155cf
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_e90c2350e3c2 UUID;
  p_Name_e90c2350e3c2 VARCHAR(255);
  p_NameSuffix_e90c2350e3c2 VARCHAR(255);
  p_Description_e90c2350e3c2 TEXT;
  p_AutoUpdateDescription_e90c2350e3c2 BOOLEAN;
  p_BaseView_e90c2350e3c2 VARCHAR(255);
  p_BaseViewGenerated_e90c2350e3c2 BOOLEAN;
  p_VirtualEntity_e90c2350e3c2 BOOLEAN;
  p_TrackRecordChanges_e90c2350e3c2 BOOLEAN;
  p_AuditRecordAccess_e90c2350e3c2 BOOLEAN;
  p_AuditViewRuns_e90c2350e3c2 BOOLEAN;
  p_IncludeInAPI_e90c2350e3c2 BOOLEAN;
  p_AllowAllRowsAPI_e90c2350e3c2 BOOLEAN;
  p_AllowUpdateAPI_e90c2350e3c2 BOOLEAN;
  p_AllowCreateAPI_e90c2350e3c2 BOOLEAN;
  p_AllowDeleteAPI_e90c2350e3c2 BOOLEAN;
  p_CustomResolverAPI_e90c2350e3c2 BOOLEAN;
  p_AllowUserSearchAPI_e90c2350e3c2 BOOLEAN;
  p_FullTextSearchEnabled_e90c2350e3c2 BOOLEAN;
  p_FullTextCatalog_e90c2350e3c2 VARCHAR(255);
  p_FullTextCatalogGenerated_e90c2350e3c2 BOOLEAN;
  p_FullTextIndex_e90c2350e3c2 VARCHAR(255);
  p_FullTextIndexGenerated_e90c2350e3c2 BOOLEAN;
  p_FullTextSearchFunction_e90c2350e3c2 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_e90c2350e3c2 BOOLEAN;
  p_UserViewMaxRows_e90c2350e3c2 INTEGER;
  p_spCreate_e90c2350e3c2 VARCHAR(255);
  p_spUpdate_e90c2350e3c2 VARCHAR(255);
  p_spDelete_e90c2350e3c2 VARCHAR(255);
  p_spCreateGenerated_e90c2350e3c2 BOOLEAN;
  p_spUpdateGenerated_e90c2350e3c2 BOOLEAN;
  p_spDeleteGenerated_e90c2350e3c2 BOOLEAN;
  p_CascadeDeletes_e90c2350e3c2 BOOLEAN;
  p_DeleteType_e90c2350e3c2 VARCHAR(10);
  p_AllowRecordMerge_e90c2350e3c2 BOOLEAN;
  p_spMatch_e90c2350e3c2 VARCHAR(255);
  p_RelationshipDefaultDisplayType_e90c2350e3c2 VARCHAR(20);
  p_UserFormGenerated_e90c2350e3c2 BOOLEAN;
  p_EntityObjectSubclassName_e90c2350e3c2 VARCHAR(255);
  p_EntityObjectSubclassImport_e90c2350e3c2 VARCHAR(255);
  p_PreferredCommunicationField_e90c2350e3c2 VARCHAR(255);
  p_Icon_e90c2350e3c2 VARCHAR(500);
  p_ScopeDefault_e90c2350e3c2 VARCHAR(100);
  p_RowsToPackWithSchema_e90c2350e3c2 VARCHAR(20);
  p_RowsToPackSampleMethod_e90c2350e3c2 VARCHAR(20);
  p_RowsToPackSampleCount_e90c2350e3c2 INTEGER;
  p_RowsToPackSampleOrder_e90c2350e3c2 TEXT;
  p_AutoRowCountFrequency_e90c2350e3c2 INTEGER;
  p_RowCount_e90c2350e3c2 BIGINT;
  p_RowCountRunAt_e90c2350e3c2 TIMESTAMPTZ;
  p_Status_e90c2350e3c2 VARCHAR(25);
  p_DisplayName_e90c2350e3c2 VARCHAR(255);
  p_AllowMultipleSubtypes_e90c2350e3c2 BOOLEAN;
  p_AutoUpdateFullTextSearch_e90c2350e3c2 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_e90c2350e3c2 BOOLEAN;
  p_TrustServerCacheCompletely_e90c2350e3c2 BOOLEAN;
  p_SupportsGeoCoding_e90c2350e3c2 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_e90c2350e3c2 BOOLEAN;
  p_AllowCaching_e90c2350e3c2 BOOLEAN;
  p_DetectExternalChanges_e90c2350e3c2 BOOLEAN;
  p_ExternalDataSourceID_e90c2350e3c2 UUID;
  p_ExternalObjectName_e90c2350e3c2 VARCHAR(255);
  p_GeneratedBaseViewName_e90c2350e3c2 VARCHAR(255);
  p_AllowDirectSQLInsert_e90c2350e3c2 BOOLEAN;
  p_AllowDirectSQLUpdate_e90c2350e3c2 BOOLEAN;
  p_AllowDirectSQLDelete_e90c2350e3c2 BOOLEAN;
  p_Configuration_e90c2350e3c2 TEXT;
  p_SubtypeSelector_e90c2350e3c2 TEXT;
  p_EnableFieldLevelSecurity_e90c2350e3c2 BOOLEAN;
  p_ID_e90c2350e3c2 UUID;
BEGIN
  p_Name_e90c2350e3c2 := 'MJ_BizApps_Tasks: Task Template Item Roles';
  p_AutoUpdateDescription_e90c2350e3c2 := TRUE;
  p_BaseView_e90c2350e3c2 := 'vwTaskTemplateItemRoles';
  p_BaseViewGenerated_e90c2350e3c2 := TRUE;
  p_VirtualEntity_e90c2350e3c2 := FALSE;
  p_TrackRecordChanges_e90c2350e3c2 := TRUE;
  p_AuditRecordAccess_e90c2350e3c2 := FALSE;
  p_AuditViewRuns_e90c2350e3c2 := FALSE;
  p_IncludeInAPI_e90c2350e3c2 := TRUE;
  p_AllowAllRowsAPI_e90c2350e3c2 := FALSE;
  p_AllowUpdateAPI_e90c2350e3c2 := TRUE;
  p_AllowCreateAPI_e90c2350e3c2 := TRUE;
  p_AllowDeleteAPI_e90c2350e3c2 := TRUE;
  p_CustomResolverAPI_e90c2350e3c2 := FALSE;
  p_AllowUserSearchAPI_e90c2350e3c2 := FALSE;
  p_FullTextSearchEnabled_e90c2350e3c2 := FALSE;
  p_FullTextCatalogGenerated_e90c2350e3c2 := TRUE;
  p_FullTextIndexGenerated_e90c2350e3c2 := TRUE;
  p_FullTextSearchFunctionGenerated_e90c2350e3c2 := TRUE;
  p_UserViewMaxRows_e90c2350e3c2 := 1000;
  p_spCreateGenerated_e90c2350e3c2 := TRUE;
  p_spUpdateGenerated_e90c2350e3c2 := TRUE;
  p_spDeleteGenerated_e90c2350e3c2 := TRUE;
  p_CascadeDeletes_e90c2350e3c2 := FALSE;
  p_DeleteType_e90c2350e3c2 := 'Hard';
  p_AllowRecordMerge_e90c2350e3c2 := FALSE;
  p_RelationshipDefaultDisplayType_e90c2350e3c2 := 'Search';
  p_UserFormGenerated_e90c2350e3c2 := TRUE;
  p_RowsToPackWithSchema_e90c2350e3c2 := 'None';
  p_RowsToPackSampleMethod_e90c2350e3c2 := 'random';
  p_RowsToPackSampleCount_e90c2350e3c2 := 0;
  p_Status_e90c2350e3c2 := 'Active';
  p_DisplayName_e90c2350e3c2 := 'Task Template Item Roles';
  p_AllowMultipleSubtypes_e90c2350e3c2 := FALSE;
  p_AutoUpdateFullTextSearch_e90c2350e3c2 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_e90c2350e3c2 := FALSE;
  p_TrustServerCacheCompletely_e90c2350e3c2 := TRUE;
  p_SupportsGeoCoding_e90c2350e3c2 := FALSE;
  p_AutoUpdateSupportsGeoCoding_e90c2350e3c2 := TRUE;
  p_AllowCaching_e90c2350e3c2 := FALSE;
  p_DetectExternalChanges_e90c2350e3c2 := FALSE;
  p_AllowDirectSQLInsert_e90c2350e3c2 := FALSE;
  p_AllowDirectSQLUpdate_e90c2350e3c2 := FALSE;
  p_AllowDirectSQLDelete_e90c2350e3c2 := FALSE;
  p_EnableFieldLevelSecurity_e90c2350e3c2 := FALSE;
  p_ID_e90c2350e3c2 := 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_e90c2350e3c2,
    'Name', p_Name_e90c2350e3c2,
    'NameSuffix', p_NameSuffix_e90c2350e3c2,
    'Description', p_Description_e90c2350e3c2,
    'AutoUpdateDescription', p_AutoUpdateDescription_e90c2350e3c2,
    'BaseView', p_BaseView_e90c2350e3c2,
    'BaseViewGenerated', p_BaseViewGenerated_e90c2350e3c2,
    'VirtualEntity', p_VirtualEntity_e90c2350e3c2,
    'TrackRecordChanges', p_TrackRecordChanges_e90c2350e3c2,
    'AuditRecordAccess', p_AuditRecordAccess_e90c2350e3c2,
    'AuditViewRuns', p_AuditViewRuns_e90c2350e3c2,
    'IncludeInAPI', p_IncludeInAPI_e90c2350e3c2,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_e90c2350e3c2,
    'AllowUpdateAPI', p_AllowUpdateAPI_e90c2350e3c2,
    'AllowCreateAPI', p_AllowCreateAPI_e90c2350e3c2,
    'AllowDeleteAPI', p_AllowDeleteAPI_e90c2350e3c2,
    'CustomResolverAPI', p_CustomResolverAPI_e90c2350e3c2,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_e90c2350e3c2,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_e90c2350e3c2,
    'FullTextCatalog', p_FullTextCatalog_e90c2350e3c2,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_e90c2350e3c2,
    'FullTextIndex', p_FullTextIndex_e90c2350e3c2,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_e90c2350e3c2,
    'FullTextSearchFunction', p_FullTextSearchFunction_e90c2350e3c2,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_e90c2350e3c2,
    'UserViewMaxRows', p_UserViewMaxRows_e90c2350e3c2,
    'spCreate', p_spCreate_e90c2350e3c2,
    'spUpdate', p_spUpdate_e90c2350e3c2,
    'spDelete', p_spDelete_e90c2350e3c2,
    'spCreateGenerated', p_spCreateGenerated_e90c2350e3c2,
    'spUpdateGenerated', p_spUpdateGenerated_e90c2350e3c2,
    'spDeleteGenerated', p_spDeleteGenerated_e90c2350e3c2,
    'CascadeDeletes', p_CascadeDeletes_e90c2350e3c2,
    'DeleteType', p_DeleteType_e90c2350e3c2,
    'AllowRecordMerge', p_AllowRecordMerge_e90c2350e3c2,
    'spMatch', p_spMatch_e90c2350e3c2,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_e90c2350e3c2,
    'UserFormGenerated', p_UserFormGenerated_e90c2350e3c2,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_e90c2350e3c2,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_e90c2350e3c2,
    'PreferredCommunicationField', p_PreferredCommunicationField_e90c2350e3c2,
    'Icon', p_Icon_e90c2350e3c2,
    'ScopeDefault', p_ScopeDefault_e90c2350e3c2,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_e90c2350e3c2,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_e90c2350e3c2,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_e90c2350e3c2,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_e90c2350e3c2,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_e90c2350e3c2,
    'RowCount', p_RowCount_e90c2350e3c2,
    'RowCountRunAt', p_RowCountRunAt_e90c2350e3c2
  ) ||
  jsonb_build_object(
    'Status', p_Status_e90c2350e3c2,
    'DisplayName', p_DisplayName_e90c2350e3c2,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_e90c2350e3c2,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_e90c2350e3c2,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_e90c2350e3c2,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_e90c2350e3c2,
    'SupportsGeoCoding', p_SupportsGeoCoding_e90c2350e3c2,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_e90c2350e3c2,
    'AllowCaching', p_AllowCaching_e90c2350e3c2,
    'DetectExternalChanges', p_DetectExternalChanges_e90c2350e3c2,
    'ExternalDataSourceID', p_ExternalDataSourceID_e90c2350e3c2,
    'ExternalObjectName', p_ExternalObjectName_e90c2350e3c2,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_e90c2350e3c2,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_e90c2350e3c2,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_e90c2350e3c2,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_e90c2350e3c2,
    'Configuration', p_Configuration_e90c2350e3c2,
    'SubtypeSelector', p_SubtypeSelector_e90c2350e3c2,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_e90c2350e3c2,
    'ID', p_ID_e90c2350e3c2
  ));
END $mj$;

-- Save MJ: Entities (core SP call only)
DO $mj$
DECLARE
  p_ParentID_784bab61a333 UUID;
  p_Name_784bab61a333 VARCHAR(255);
  p_NameSuffix_784bab61a333 VARCHAR(255);
  p_Description_784bab61a333 TEXT;
  p_AutoUpdateDescription_784bab61a333 BOOLEAN;
  p_BaseView_784bab61a333 VARCHAR(255);
  p_BaseViewGenerated_784bab61a333 BOOLEAN;
  p_VirtualEntity_784bab61a333 BOOLEAN;
  p_TrackRecordChanges_784bab61a333 BOOLEAN;
  p_AuditRecordAccess_784bab61a333 BOOLEAN;
  p_AuditViewRuns_784bab61a333 BOOLEAN;
  p_IncludeInAPI_784bab61a333 BOOLEAN;
  p_AllowAllRowsAPI_784bab61a333 BOOLEAN;
  p_AllowUpdateAPI_784bab61a333 BOOLEAN;
  p_AllowCreateAPI_784bab61a333 BOOLEAN;
  p_AllowDeleteAPI_784bab61a333 BOOLEAN;
  p_CustomResolverAPI_784bab61a333 BOOLEAN;
  p_AllowUserSearchAPI_784bab61a333 BOOLEAN;
  p_FullTextSearchEnabled_784bab61a333 BOOLEAN;
  p_FullTextCatalog_784bab61a333 VARCHAR(255);
  p_FullTextCatalogGenerated_784bab61a333 BOOLEAN;
  p_FullTextIndex_784bab61a333 VARCHAR(255);
  p_FullTextIndexGenerated_784bab61a333 BOOLEAN;
  p_FullTextSearchFunction_784bab61a333 VARCHAR(255);
  p_FullTextSearchFunctionGenerated_784bab61a333 BOOLEAN;
  p_UserViewMaxRows_784bab61a333 INTEGER;
  p_spCreate_784bab61a333 VARCHAR(255);
  p_spUpdate_784bab61a333 VARCHAR(255);
  p_spDelete_784bab61a333 VARCHAR(255);
  p_spCreateGenerated_784bab61a333 BOOLEAN;
  p_spUpdateGenerated_784bab61a333 BOOLEAN;
  p_spDeleteGenerated_784bab61a333 BOOLEAN;
  p_CascadeDeletes_784bab61a333 BOOLEAN;
  p_DeleteType_784bab61a333 VARCHAR(10);
  p_AllowRecordMerge_784bab61a333 BOOLEAN;
  p_spMatch_784bab61a333 VARCHAR(255);
  p_RelationshipDefaultDisplayType_784bab61a333 VARCHAR(20);
  p_UserFormGenerated_784bab61a333 BOOLEAN;
  p_EntityObjectSubclassName_784bab61a333 VARCHAR(255);
  p_EntityObjectSubclassImport_784bab61a333 VARCHAR(255);
  p_PreferredCommunicationField_784bab61a333 VARCHAR(255);
  p_Icon_784bab61a333 VARCHAR(500);
  p_ScopeDefault_784bab61a333 VARCHAR(100);
  p_RowsToPackWithSchema_784bab61a333 VARCHAR(20);
  p_RowsToPackSampleMethod_784bab61a333 VARCHAR(20);
  p_RowsToPackSampleCount_784bab61a333 INTEGER;
  p_RowsToPackSampleOrder_784bab61a333 TEXT;
  p_AutoRowCountFrequency_784bab61a333 INTEGER;
  p_RowCount_784bab61a333 BIGINT;
  p_RowCountRunAt_784bab61a333 TIMESTAMPTZ;
  p_Status_784bab61a333 VARCHAR(25);
  p_DisplayName_784bab61a333 VARCHAR(255);
  p_AllowMultipleSubtypes_784bab61a333 BOOLEAN;
  p_AutoUpdateFullTextSearch_784bab61a333 BOOLEAN;
  p_AutoUpdateAllowUserSearchAPI_784bab61a333 BOOLEAN;
  p_TrustServerCacheCompletely_784bab61a333 BOOLEAN;
  p_SupportsGeoCoding_784bab61a333 BOOLEAN;
  p_AutoUpdateSupportsGeoCoding_784bab61a333 BOOLEAN;
  p_AllowCaching_784bab61a333 BOOLEAN;
  p_DetectExternalChanges_784bab61a333 BOOLEAN;
  p_ExternalDataSourceID_784bab61a333 UUID;
  p_ExternalObjectName_784bab61a333 VARCHAR(255);
  p_GeneratedBaseViewName_784bab61a333 VARCHAR(255);
  p_AllowDirectSQLInsert_784bab61a333 BOOLEAN;
  p_AllowDirectSQLUpdate_784bab61a333 BOOLEAN;
  p_AllowDirectSQLDelete_784bab61a333 BOOLEAN;
  p_Configuration_784bab61a333 TEXT;
  p_SubtypeSelector_784bab61a333 TEXT;
  p_EnableFieldLevelSecurity_784bab61a333 BOOLEAN;
  p_ID_784bab61a333 UUID;
BEGIN
  p_Name_784bab61a333 := 'MJ_BizApps_Tasks: Task Template Items';
  p_AutoUpdateDescription_784bab61a333 := TRUE;
  p_BaseView_784bab61a333 := 'vwTaskTemplateItems';
  p_BaseViewGenerated_784bab61a333 := TRUE;
  p_VirtualEntity_784bab61a333 := FALSE;
  p_TrackRecordChanges_784bab61a333 := TRUE;
  p_AuditRecordAccess_784bab61a333 := FALSE;
  p_AuditViewRuns_784bab61a333 := FALSE;
  p_IncludeInAPI_784bab61a333 := TRUE;
  p_AllowAllRowsAPI_784bab61a333 := FALSE;
  p_AllowUpdateAPI_784bab61a333 := TRUE;
  p_AllowCreateAPI_784bab61a333 := TRUE;
  p_AllowDeleteAPI_784bab61a333 := TRUE;
  p_CustomResolverAPI_784bab61a333 := FALSE;
  p_AllowUserSearchAPI_784bab61a333 := FALSE;
  p_FullTextSearchEnabled_784bab61a333 := FALSE;
  p_FullTextCatalogGenerated_784bab61a333 := TRUE;
  p_FullTextIndexGenerated_784bab61a333 := TRUE;
  p_FullTextSearchFunctionGenerated_784bab61a333 := TRUE;
  p_UserViewMaxRows_784bab61a333 := 1000;
  p_spCreateGenerated_784bab61a333 := TRUE;
  p_spUpdateGenerated_784bab61a333 := TRUE;
  p_spDeleteGenerated_784bab61a333 := TRUE;
  p_CascadeDeletes_784bab61a333 := FALSE;
  p_DeleteType_784bab61a333 := 'Hard';
  p_AllowRecordMerge_784bab61a333 := FALSE;
  p_RelationshipDefaultDisplayType_784bab61a333 := 'Search';
  p_UserFormGenerated_784bab61a333 := TRUE;
  p_RowsToPackWithSchema_784bab61a333 := 'None';
  p_RowsToPackSampleMethod_784bab61a333 := 'random';
  p_RowsToPackSampleCount_784bab61a333 := 0;
  p_Status_784bab61a333 := 'Active';
  p_DisplayName_784bab61a333 := 'Task Template Items';
  p_AllowMultipleSubtypes_784bab61a333 := FALSE;
  p_AutoUpdateFullTextSearch_784bab61a333 := TRUE;
  p_AutoUpdateAllowUserSearchAPI_784bab61a333 := FALSE;
  p_TrustServerCacheCompletely_784bab61a333 := TRUE;
  p_SupportsGeoCoding_784bab61a333 := FALSE;
  p_AutoUpdateSupportsGeoCoding_784bab61a333 := TRUE;
  p_AllowCaching_784bab61a333 := FALSE;
  p_DetectExternalChanges_784bab61a333 := FALSE;
  p_AllowDirectSQLInsert_784bab61a333 := FALSE;
  p_AllowDirectSQLUpdate_784bab61a333 := FALSE;
  p_AllowDirectSQLDelete_784bab61a333 := FALSE;
  p_EnableFieldLevelSecurity_784bab61a333 := FALSE;
  p_ID_784bab61a333 := 'A28FDD91-D380-427E-B374-BCEC56ED75B7';
  PERFORM "${mjSchema}"."spUpdateEntity"(p_data := jsonb_build_object(
    'ParentID', p_ParentID_784bab61a333,
    'Name', p_Name_784bab61a333,
    'NameSuffix', p_NameSuffix_784bab61a333,
    'Description', p_Description_784bab61a333,
    'AutoUpdateDescription', p_AutoUpdateDescription_784bab61a333,
    'BaseView', p_BaseView_784bab61a333,
    'BaseViewGenerated', p_BaseViewGenerated_784bab61a333,
    'VirtualEntity', p_VirtualEntity_784bab61a333,
    'TrackRecordChanges', p_TrackRecordChanges_784bab61a333,
    'AuditRecordAccess', p_AuditRecordAccess_784bab61a333,
    'AuditViewRuns', p_AuditViewRuns_784bab61a333,
    'IncludeInAPI', p_IncludeInAPI_784bab61a333,
    'AllowAllRowsAPI', p_AllowAllRowsAPI_784bab61a333,
    'AllowUpdateAPI', p_AllowUpdateAPI_784bab61a333,
    'AllowCreateAPI', p_AllowCreateAPI_784bab61a333,
    'AllowDeleteAPI', p_AllowDeleteAPI_784bab61a333,
    'CustomResolverAPI', p_CustomResolverAPI_784bab61a333,
    'AllowUserSearchAPI', p_AllowUserSearchAPI_784bab61a333,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_784bab61a333,
    'FullTextCatalog', p_FullTextCatalog_784bab61a333,
    'FullTextCatalogGenerated', p_FullTextCatalogGenerated_784bab61a333,
    'FullTextIndex', p_FullTextIndex_784bab61a333,
    'FullTextIndexGenerated', p_FullTextIndexGenerated_784bab61a333,
    'FullTextSearchFunction', p_FullTextSearchFunction_784bab61a333,
    'FullTextSearchFunctionGenerated', p_FullTextSearchFunctionGenerated_784bab61a333,
    'UserViewMaxRows', p_UserViewMaxRows_784bab61a333,
    'spCreate', p_spCreate_784bab61a333,
    'spUpdate', p_spUpdate_784bab61a333,
    'spDelete', p_spDelete_784bab61a333,
    'spCreateGenerated', p_spCreateGenerated_784bab61a333,
    'spUpdateGenerated', p_spUpdateGenerated_784bab61a333,
    'spDeleteGenerated', p_spDeleteGenerated_784bab61a333,
    'CascadeDeletes', p_CascadeDeletes_784bab61a333,
    'DeleteType', p_DeleteType_784bab61a333,
    'AllowRecordMerge', p_AllowRecordMerge_784bab61a333,
    'spMatch', p_spMatch_784bab61a333,
    'RelationshipDefaultDisplayType', p_RelationshipDefaultDisplayType_784bab61a333,
    'UserFormGenerated', p_UserFormGenerated_784bab61a333,
    'EntityObjectSubclassName', p_EntityObjectSubclassName_784bab61a333,
    'EntityObjectSubclassImport', p_EntityObjectSubclassImport_784bab61a333,
    'PreferredCommunicationField', p_PreferredCommunicationField_784bab61a333,
    'Icon', p_Icon_784bab61a333,
    'ScopeDefault', p_ScopeDefault_784bab61a333,
    'RowsToPackWithSchema', p_RowsToPackWithSchema_784bab61a333,
    'RowsToPackSampleMethod', p_RowsToPackSampleMethod_784bab61a333,
    'RowsToPackSampleCount', p_RowsToPackSampleCount_784bab61a333,
    'RowsToPackSampleOrder', p_RowsToPackSampleOrder_784bab61a333,
    'AutoRowCountFrequency', p_AutoRowCountFrequency_784bab61a333,
    'RowCount', p_RowCount_784bab61a333,
    'RowCountRunAt', p_RowCountRunAt_784bab61a333
  ) ||
  jsonb_build_object(
    'Status', p_Status_784bab61a333,
    'DisplayName', p_DisplayName_784bab61a333,
    'AllowMultipleSubtypes', p_AllowMultipleSubtypes_784bab61a333,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_784bab61a333,
    'AutoUpdateAllowUserSearchAPI', p_AutoUpdateAllowUserSearchAPI_784bab61a333,
    'TrustServerCacheCompletely', p_TrustServerCacheCompletely_784bab61a333,
    'SupportsGeoCoding', p_SupportsGeoCoding_784bab61a333,
    'AutoUpdateSupportsGeoCoding', p_AutoUpdateSupportsGeoCoding_784bab61a333,
    'AllowCaching', p_AllowCaching_784bab61a333,
    'DetectExternalChanges', p_DetectExternalChanges_784bab61a333,
    'ExternalDataSourceID', p_ExternalDataSourceID_784bab61a333,
    'ExternalObjectName', p_ExternalObjectName_784bab61a333,
    'GeneratedBaseViewName', p_GeneratedBaseViewName_784bab61a333,
    'AllowDirectSQLInsert', p_AllowDirectSQLInsert_784bab61a333,
    'AllowDirectSQLUpdate', p_AllowDirectSQLUpdate_784bab61a333,
    'AllowDirectSQLDelete', p_AllowDirectSQLDelete_784bab61a333,
    'Configuration', p_Configuration_784bab61a333,
    'SubtypeSelector', p_SubtypeSelector_784bab61a333,
    'EnableFieldLevelSecurity', p_EnableFieldLevelSecurity_784bab61a333,
    'ID', p_ID_784bab61a333
  ));
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_2e4049dd7999 VARCHAR(255);
  p_Description_2e4049dd7999 TEXT;
  p_AutoUpdateDescription_2e4049dd7999 BOOLEAN;
  p_IsPrimaryKey_2e4049dd7999 BOOLEAN;
  p_IsUnique_2e4049dd7999 BOOLEAN;
  p_Category_2e4049dd7999 VARCHAR(255);
  p_ValueListType_2e4049dd7999 VARCHAR(20);
  p_ExtendedType_2e4049dd7999 VARCHAR(50);
  p_CodeType_2e4049dd7999 VARCHAR(50);
  p_DefaultInView_2e4049dd7999 BOOLEAN;
  p_ViewCellTemplate_2e4049dd7999 TEXT;
  p_DefaultColumnWidth_2e4049dd7999 INTEGER;
  p_AllowUpdateAPI_2e4049dd7999 BOOLEAN;
  p_AllowUpdateInView_2e4049dd7999 BOOLEAN;
  p_IncludeInUserSearchAPI_2e4049dd7999 BOOLEAN;
  p_FullTextSearchEnabled_2e4049dd7999 BOOLEAN;
  p_UserSearchParamFormatAPI_2e4049dd7999 VARCHAR(500);
  p_IncludeInGeneratedForm_2e4049dd7999 BOOLEAN;
  p_GeneratedFormSection_2e4049dd7999 VARCHAR(10);
  p_IsNameField_2e4049dd7999 BOOLEAN;
  p_RelatedEntityID_2e4049dd7999 UUID;
  p_RelatedEntityFieldName_2e4049dd7999 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_2e4049dd7999 BOOLEAN;
  p_RelatedEntityNameFieldMap_2e4049dd7999 VARCHAR(255);
  p_RelatedEntityDisplayType_2e4049dd7999 VARCHAR(20);
  p_EntityIDFieldName_2e4049dd7999 VARCHAR(100);
  p_ScopeDefault_2e4049dd7999 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_2e4049dd7999 BOOLEAN;
  p_ValuesToPackWithSchema_2e4049dd7999 VARCHAR(10);
  p_Status_2e4049dd7999 VARCHAR(25);
  p_AutoUpdateIsNameField_2e4049dd7999 BOOLEAN;
  p_AutoUpdateDefaultInView_2e4049dd7999 BOOLEAN;
  p_AutoUpdateCategory_2e4049dd7999 BOOLEAN;
  p_AutoUpdateDisplayName_2e4049dd7999 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_2e4049dd7999 BOOLEAN;
  p_Encrypt_2e4049dd7999 BOOLEAN;
  p_EncryptionKeyID_2e4049dd7999 UUID;
  p_AllowDecryptInAPI_2e4049dd7999 BOOLEAN;
  p_SendEncryptedValue_2e4049dd7999 BOOLEAN;
  p_IsSoftPrimaryKey_2e4049dd7999 BOOLEAN;
  p_IsSoftForeignKey_2e4049dd7999 BOOLEAN;
  p_RelatedEntityJoinFields_2e4049dd7999 TEXT;
  p_JSONType_2e4049dd7999 VARCHAR(255);
  p_JSONTypeIsArray_2e4049dd7999 BOOLEAN;
  p_JSONTypeDefinition_2e4049dd7999 TEXT;
  p_UserSearchPredicateAPI_2e4049dd7999 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_2e4049dd7999 BOOLEAN;
  p_AutoUpdateFullTextSearch_2e4049dd7999 BOOLEAN;
  p_AutoUpdateExtendedType_2e4049dd7999 BOOLEAN;
  p_IsComputed_2e4049dd7999 BOOLEAN;
  p_EmbeddedRecord_2e4049dd7999 TEXT;
  p_Configuration_2e4049dd7999 TEXT;
  p_ID_2e4049dd7999 UUID;
BEGIN
  p_DisplayName_2e4049dd7999 := 'Name';
  p_AutoUpdateDescription_2e4049dd7999 := TRUE;
  p_IsPrimaryKey_2e4049dd7999 := FALSE;
  p_IsUnique_2e4049dd7999 := FALSE;
  p_Category_2e4049dd7999 := 'Task Details';
  p_ValueListType_2e4049dd7999 := 'None';
  p_DefaultInView_2e4049dd7999 := TRUE;
  p_DefaultColumnWidth_2e4049dd7999 := 150;
  p_AllowUpdateAPI_2e4049dd7999 := TRUE;
  p_AllowUpdateInView_2e4049dd7999 := TRUE;
  p_IncludeInUserSearchAPI_2e4049dd7999 := TRUE;
  p_FullTextSearchEnabled_2e4049dd7999 := FALSE;
  p_IncludeInGeneratedForm_2e4049dd7999 := TRUE;
  p_GeneratedFormSection_2e4049dd7999 := 'Category';
  p_IsNameField_2e4049dd7999 := TRUE;
  p_IncludeRelatedEntityNameFieldInBaseView_2e4049dd7999 := FALSE;
  p_RelatedEntityDisplayType_2e4049dd7999 := 'Search';
  p_AutoUpdateRelatedEntityInfo_2e4049dd7999 := TRUE;
  p_ValuesToPackWithSchema_2e4049dd7999 := 'Auto';
  p_Status_2e4049dd7999 := 'Active';
  p_AutoUpdateIsNameField_2e4049dd7999 := TRUE;
  p_AutoUpdateDefaultInView_2e4049dd7999 := TRUE;
  p_AutoUpdateCategory_2e4049dd7999 := TRUE;
  p_AutoUpdateDisplayName_2e4049dd7999 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_2e4049dd7999 := FALSE;
  p_Encrypt_2e4049dd7999 := FALSE;
  p_AllowDecryptInAPI_2e4049dd7999 := FALSE;
  p_SendEncryptedValue_2e4049dd7999 := FALSE;
  p_IsSoftPrimaryKey_2e4049dd7999 := FALSE;
  p_IsSoftForeignKey_2e4049dd7999 := FALSE;
  p_JSONTypeIsArray_2e4049dd7999 := FALSE;
  p_UserSearchPredicateAPI_2e4049dd7999 := 'BeginsWith';
  p_AutoUpdateUserSearchPredicate_2e4049dd7999 := TRUE;
  p_AutoUpdateFullTextSearch_2e4049dd7999 := TRUE;
  p_AutoUpdateExtendedType_2e4049dd7999 := TRUE;
  p_IsComputed_2e4049dd7999 := FALSE;
  p_ID_2e4049dd7999 := '4C041CC2-D419-485C-9896-790003F638B9';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_2e4049dd7999,
    'Description', p_Description_2e4049dd7999,
    'AutoUpdateDescription', p_AutoUpdateDescription_2e4049dd7999,
    'IsPrimaryKey', p_IsPrimaryKey_2e4049dd7999,
    'IsUnique', p_IsUnique_2e4049dd7999,
    'Category', p_Category_2e4049dd7999,
    'ValueListType', p_ValueListType_2e4049dd7999,
    'ExtendedType', p_ExtendedType_2e4049dd7999,
    'CodeType', p_CodeType_2e4049dd7999,
    'DefaultInView', p_DefaultInView_2e4049dd7999,
    'ViewCellTemplate', p_ViewCellTemplate_2e4049dd7999,
    'DefaultColumnWidth', p_DefaultColumnWidth_2e4049dd7999,
    'AllowUpdateAPI', p_AllowUpdateAPI_2e4049dd7999,
    'AllowUpdateInView', p_AllowUpdateInView_2e4049dd7999,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_2e4049dd7999,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_2e4049dd7999,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_2e4049dd7999,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_2e4049dd7999,
    'GeneratedFormSection', p_GeneratedFormSection_2e4049dd7999,
    'IsNameField', p_IsNameField_2e4049dd7999,
    'RelatedEntityID', p_RelatedEntityID_2e4049dd7999,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_2e4049dd7999,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_2e4049dd7999,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_2e4049dd7999,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_2e4049dd7999,
    'EntityIDFieldName', p_EntityIDFieldName_2e4049dd7999,
    'ScopeDefault', p_ScopeDefault_2e4049dd7999,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_2e4049dd7999,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_2e4049dd7999,
    'Status', p_Status_2e4049dd7999,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_2e4049dd7999,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_2e4049dd7999,
    'AutoUpdateCategory', p_AutoUpdateCategory_2e4049dd7999,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_2e4049dd7999,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_2e4049dd7999,
    'Encrypt', p_Encrypt_2e4049dd7999,
    'EncryptionKeyID', p_EncryptionKeyID_2e4049dd7999,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_2e4049dd7999,
    'SendEncryptedValue', p_SendEncryptedValue_2e4049dd7999,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_2e4049dd7999,
    'IsSoftForeignKey', p_IsSoftForeignKey_2e4049dd7999,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_2e4049dd7999,
    'JSONType', p_JSONType_2e4049dd7999,
    'JSONTypeIsArray', p_JSONTypeIsArray_2e4049dd7999,
    'JSONTypeDefinition', p_JSONTypeDefinition_2e4049dd7999,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_2e4049dd7999,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_2e4049dd7999,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_2e4049dd7999,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_2e4049dd7999,
    'IsComputed', p_IsComputed_2e4049dd7999
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_2e4049dd7999,
    'Configuration', p_Configuration_2e4049dd7999,
    'ID', p_ID_2e4049dd7999
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_2e4049dd7999, p_Description := p_Description_2e4049dd7999, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_2e4049dd7999, p_IsPrimaryKey := p_IsPrimaryKey_2e4049dd7999, p_IsUnique := p_IsUnique_2e4049dd7999, p_Category := p_Category_2e4049dd7999, p_ValueListType := p_ValueListType_2e4049dd7999, p_ExtendedType := p_ExtendedType_2e4049dd7999, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_2e4049dd7999, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_2e4049dd7999, p_ViewCellTemplate := p_ViewCellTemplate_2e4049dd7999, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_2e4049dd7999, p_AllowUpdateAPI := p_AllowUpdateAPI_2e4049dd7999, p_AllowUpdateInView := p_AllowUpdateInView_2e4049dd7999, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_2e4049dd7999, p_FullTextSearchEnabled := p_FullTextSearchEnabled_2e4049dd7999, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_2e4049dd7999, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_2e4049dd7999, p_GeneratedFormSection := p_GeneratedFormSection_2e4049dd7999, p_IsNameField := p_IsNameField_2e4049dd7999, p_RelatedEntityID := p_RelatedEntityID_2e4049dd7999, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_2e4049dd7999, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_2e4049dd7999, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_2e4049dd7999, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_2e4049dd7999, p_EntityIDFieldName := p_EntityIDFieldName_2e4049dd7999, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_2e4049dd7999, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_2e4049dd7999, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_2e4049dd7999, p_Status := p_Status_2e4049dd7999, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_2e4049dd7999, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_2e4049dd7999, p_AutoUpdateCategory := p_AutoUpdateCategory_2e4049dd7999, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_2e4049dd7999, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_2e4049dd7999, p_Encrypt := p_Encrypt_2e4049dd7999, p_EncryptionKeyID := p_EncryptionKeyID_2e4049dd7999, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_2e4049dd7999, p_SendEncryptedValue := p_SendEncryptedValue_2e4049dd7999, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_2e4049dd7999, p_IsSoftForeignKey := p_IsSoftForeignKey_2e4049dd7999, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_2e4049dd7999, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_2e4049dd7999, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_2e4049dd7999, p_JSONTypeDefinition := p_JSONTypeDefinition_2e4049dd7999, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_2e4049dd7999, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_2e4049dd7999, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_2e4049dd7999, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_2e4049dd7999, p_IsComputed := p_IsComputed_2e4049dd7999, p_EmbeddedRecord := p_EmbeddedRecord_2e4049dd7999, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_2e4049dd7999, p_Configuration_Clear := TRUE, p_ID := p_ID_2e4049dd7999);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_dd961c49c803 VARCHAR(255);
  p_Description_dd961c49c803 TEXT;
  p_AutoUpdateDescription_dd961c49c803 BOOLEAN;
  p_IsPrimaryKey_dd961c49c803 BOOLEAN;
  p_IsUnique_dd961c49c803 BOOLEAN;
  p_Category_dd961c49c803 VARCHAR(255);
  p_ValueListType_dd961c49c803 VARCHAR(20);
  p_ExtendedType_dd961c49c803 VARCHAR(50);
  p_CodeType_dd961c49c803 VARCHAR(50);
  p_DefaultInView_dd961c49c803 BOOLEAN;
  p_ViewCellTemplate_dd961c49c803 TEXT;
  p_DefaultColumnWidth_dd961c49c803 INTEGER;
  p_AllowUpdateAPI_dd961c49c803 BOOLEAN;
  p_AllowUpdateInView_dd961c49c803 BOOLEAN;
  p_IncludeInUserSearchAPI_dd961c49c803 BOOLEAN;
  p_FullTextSearchEnabled_dd961c49c803 BOOLEAN;
  p_UserSearchParamFormatAPI_dd961c49c803 VARCHAR(500);
  p_IncludeInGeneratedForm_dd961c49c803 BOOLEAN;
  p_GeneratedFormSection_dd961c49c803 VARCHAR(10);
  p_IsNameField_dd961c49c803 BOOLEAN;
  p_RelatedEntityID_dd961c49c803 UUID;
  p_RelatedEntityFieldName_dd961c49c803 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_dd961c49c803 BOOLEAN;
  p_RelatedEntityNameFieldMap_dd961c49c803 VARCHAR(255);
  p_RelatedEntityDisplayType_dd961c49c803 VARCHAR(20);
  p_EntityIDFieldName_dd961c49c803 VARCHAR(100);
  p_ScopeDefault_dd961c49c803 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_dd961c49c803 BOOLEAN;
  p_ValuesToPackWithSchema_dd961c49c803 VARCHAR(10);
  p_Status_dd961c49c803 VARCHAR(25);
  p_AutoUpdateIsNameField_dd961c49c803 BOOLEAN;
  p_AutoUpdateDefaultInView_dd961c49c803 BOOLEAN;
  p_AutoUpdateCategory_dd961c49c803 BOOLEAN;
  p_AutoUpdateDisplayName_dd961c49c803 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_dd961c49c803 BOOLEAN;
  p_Encrypt_dd961c49c803 BOOLEAN;
  p_EncryptionKeyID_dd961c49c803 UUID;
  p_AllowDecryptInAPI_dd961c49c803 BOOLEAN;
  p_SendEncryptedValue_dd961c49c803 BOOLEAN;
  p_IsSoftPrimaryKey_dd961c49c803 BOOLEAN;
  p_IsSoftForeignKey_dd961c49c803 BOOLEAN;
  p_RelatedEntityJoinFields_dd961c49c803 TEXT;
  p_JSONType_dd961c49c803 VARCHAR(255);
  p_JSONTypeIsArray_dd961c49c803 BOOLEAN;
  p_JSONTypeDefinition_dd961c49c803 TEXT;
  p_UserSearchPredicateAPI_dd961c49c803 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_dd961c49c803 BOOLEAN;
  p_AutoUpdateFullTextSearch_dd961c49c803 BOOLEAN;
  p_AutoUpdateExtendedType_dd961c49c803 BOOLEAN;
  p_IsComputed_dd961c49c803 BOOLEAN;
  p_EmbeddedRecord_dd961c49c803 TEXT;
  p_Configuration_dd961c49c803 TEXT;
  p_ID_dd961c49c803 UUID;
BEGIN
  p_DisplayName_dd961c49c803 := 'ID';
  p_AutoUpdateDescription_dd961c49c803 := TRUE;
  p_IsPrimaryKey_dd961c49c803 := TRUE;
  p_IsUnique_dd961c49c803 := TRUE;
  p_Category_dd961c49c803 := 'System Metadata';
  p_ValueListType_dd961c49c803 := 'None';
  p_DefaultInView_dd961c49c803 := FALSE;
  p_DefaultColumnWidth_dd961c49c803 := 150;
  p_AllowUpdateAPI_dd961c49c803 := FALSE;
  p_AllowUpdateInView_dd961c49c803 := TRUE;
  p_IncludeInUserSearchAPI_dd961c49c803 := FALSE;
  p_FullTextSearchEnabled_dd961c49c803 := FALSE;
  p_IncludeInGeneratedForm_dd961c49c803 := TRUE;
  p_GeneratedFormSection_dd961c49c803 := 'Category';
  p_IsNameField_dd961c49c803 := FALSE;
  p_IncludeRelatedEntityNameFieldInBaseView_dd961c49c803 := FALSE;
  p_RelatedEntityDisplayType_dd961c49c803 := 'Search';
  p_AutoUpdateRelatedEntityInfo_dd961c49c803 := TRUE;
  p_ValuesToPackWithSchema_dd961c49c803 := 'Auto';
  p_Status_dd961c49c803 := 'Active';
  p_AutoUpdateIsNameField_dd961c49c803 := TRUE;
  p_AutoUpdateDefaultInView_dd961c49c803 := TRUE;
  p_AutoUpdateCategory_dd961c49c803 := TRUE;
  p_AutoUpdateDisplayName_dd961c49c803 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_dd961c49c803 := FALSE;
  p_Encrypt_dd961c49c803 := FALSE;
  p_AllowDecryptInAPI_dd961c49c803 := FALSE;
  p_SendEncryptedValue_dd961c49c803 := FALSE;
  p_IsSoftPrimaryKey_dd961c49c803 := FALSE;
  p_IsSoftForeignKey_dd961c49c803 := FALSE;
  p_JSONTypeIsArray_dd961c49c803 := FALSE;
  p_UserSearchPredicateAPI_dd961c49c803 := 'Contains';
  p_AutoUpdateUserSearchPredicate_dd961c49c803 := TRUE;
  p_AutoUpdateFullTextSearch_dd961c49c803 := TRUE;
  p_AutoUpdateExtendedType_dd961c49c803 := TRUE;
  p_IsComputed_dd961c49c803 := FALSE;
  p_ID_dd961c49c803 := 'B8AD1F96-886C-4903-8D8D-FBEBB27BB506';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_dd961c49c803,
    'Description', p_Description_dd961c49c803,
    'AutoUpdateDescription', p_AutoUpdateDescription_dd961c49c803,
    'IsPrimaryKey', p_IsPrimaryKey_dd961c49c803,
    'IsUnique', p_IsUnique_dd961c49c803,
    'Category', p_Category_dd961c49c803,
    'ValueListType', p_ValueListType_dd961c49c803,
    'ExtendedType', p_ExtendedType_dd961c49c803,
    'CodeType', p_CodeType_dd961c49c803,
    'DefaultInView', p_DefaultInView_dd961c49c803,
    'ViewCellTemplate', p_ViewCellTemplate_dd961c49c803,
    'DefaultColumnWidth', p_DefaultColumnWidth_dd961c49c803,
    'AllowUpdateAPI', p_AllowUpdateAPI_dd961c49c803,
    'AllowUpdateInView', p_AllowUpdateInView_dd961c49c803,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_dd961c49c803,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_dd961c49c803,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_dd961c49c803,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_dd961c49c803,
    'GeneratedFormSection', p_GeneratedFormSection_dd961c49c803,
    'IsNameField', p_IsNameField_dd961c49c803,
    'RelatedEntityID', p_RelatedEntityID_dd961c49c803,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_dd961c49c803,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_dd961c49c803,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_dd961c49c803,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_dd961c49c803,
    'EntityIDFieldName', p_EntityIDFieldName_dd961c49c803,
    'ScopeDefault', p_ScopeDefault_dd961c49c803,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_dd961c49c803,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_dd961c49c803,
    'Status', p_Status_dd961c49c803,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_dd961c49c803,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_dd961c49c803,
    'AutoUpdateCategory', p_AutoUpdateCategory_dd961c49c803,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_dd961c49c803,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_dd961c49c803,
    'Encrypt', p_Encrypt_dd961c49c803,
    'EncryptionKeyID', p_EncryptionKeyID_dd961c49c803,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_dd961c49c803,
    'SendEncryptedValue', p_SendEncryptedValue_dd961c49c803,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_dd961c49c803,
    'IsSoftForeignKey', p_IsSoftForeignKey_dd961c49c803,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_dd961c49c803,
    'JSONType', p_JSONType_dd961c49c803,
    'JSONTypeIsArray', p_JSONTypeIsArray_dd961c49c803,
    'JSONTypeDefinition', p_JSONTypeDefinition_dd961c49c803,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_dd961c49c803,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_dd961c49c803,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_dd961c49c803,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_dd961c49c803,
    'IsComputed', p_IsComputed_dd961c49c803
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_dd961c49c803,
    'Configuration', p_Configuration_dd961c49c803,
    'ID', p_ID_dd961c49c803
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_dd961c49c803, p_Description := p_Description_dd961c49c803, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_dd961c49c803, p_IsPrimaryKey := p_IsPrimaryKey_dd961c49c803, p_IsUnique := p_IsUnique_dd961c49c803, p_Category := p_Category_dd961c49c803, p_ValueListType := p_ValueListType_dd961c49c803, p_ExtendedType := p_ExtendedType_dd961c49c803, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_dd961c49c803, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_dd961c49c803, p_ViewCellTemplate := p_ViewCellTemplate_dd961c49c803, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_dd961c49c803, p_AllowUpdateAPI := p_AllowUpdateAPI_dd961c49c803, p_AllowUpdateInView := p_AllowUpdateInView_dd961c49c803, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_dd961c49c803, p_FullTextSearchEnabled := p_FullTextSearchEnabled_dd961c49c803, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_dd961c49c803, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_dd961c49c803, p_GeneratedFormSection := p_GeneratedFormSection_dd961c49c803, p_IsNameField := p_IsNameField_dd961c49c803, p_RelatedEntityID := p_RelatedEntityID_dd961c49c803, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_dd961c49c803, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_dd961c49c803, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_dd961c49c803, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_dd961c49c803, p_EntityIDFieldName := p_EntityIDFieldName_dd961c49c803, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_dd961c49c803, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_dd961c49c803, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_dd961c49c803, p_Status := p_Status_dd961c49c803, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_dd961c49c803, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_dd961c49c803, p_AutoUpdateCategory := p_AutoUpdateCategory_dd961c49c803, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_dd961c49c803, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_dd961c49c803, p_Encrypt := p_Encrypt_dd961c49c803, p_EncryptionKeyID := p_EncryptionKeyID_dd961c49c803, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_dd961c49c803, p_SendEncryptedValue := p_SendEncryptedValue_dd961c49c803, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_dd961c49c803, p_IsSoftForeignKey := p_IsSoftForeignKey_dd961c49c803, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_dd961c49c803, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_dd961c49c803, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_dd961c49c803, p_JSONTypeDefinition := p_JSONTypeDefinition_dd961c49c803, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_dd961c49c803, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_dd961c49c803, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_dd961c49c803, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_dd961c49c803, p_IsComputed := p_IsComputed_dd961c49c803, p_EmbeddedRecord := p_EmbeddedRecord_dd961c49c803, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_dd961c49c803, p_Configuration_Clear := TRUE, p_ID := p_ID_dd961c49c803);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_cc0fff40d5a3 VARCHAR(255);
  p_Description_cc0fff40d5a3 TEXT;
  p_AutoUpdateDescription_cc0fff40d5a3 BOOLEAN;
  p_IsPrimaryKey_cc0fff40d5a3 BOOLEAN;
  p_IsUnique_cc0fff40d5a3 BOOLEAN;
  p_Category_cc0fff40d5a3 VARCHAR(255);
  p_ValueListType_cc0fff40d5a3 VARCHAR(20);
  p_ExtendedType_cc0fff40d5a3 VARCHAR(50);
  p_CodeType_cc0fff40d5a3 VARCHAR(50);
  p_DefaultInView_cc0fff40d5a3 BOOLEAN;
  p_ViewCellTemplate_cc0fff40d5a3 TEXT;
  p_DefaultColumnWidth_cc0fff40d5a3 INTEGER;
  p_AllowUpdateAPI_cc0fff40d5a3 BOOLEAN;
  p_AllowUpdateInView_cc0fff40d5a3 BOOLEAN;
  p_IncludeInUserSearchAPI_cc0fff40d5a3 BOOLEAN;
  p_FullTextSearchEnabled_cc0fff40d5a3 BOOLEAN;
  p_UserSearchParamFormatAPI_cc0fff40d5a3 VARCHAR(500);
  p_IncludeInGeneratedForm_cc0fff40d5a3 BOOLEAN;
  p_GeneratedFormSection_cc0fff40d5a3 VARCHAR(10);
  p_IsNameField_cc0fff40d5a3 BOOLEAN;
  p_RelatedEntityID_cc0fff40d5a3 UUID;
  p_RelatedEntityFieldName_cc0fff40d5a3 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_cc0fff40d5a3 BOOLEAN;
  p_RelatedEntityNameFieldMap_cc0fff40d5a3 VARCHAR(255);
  p_RelatedEntityDisplayType_cc0fff40d5a3 VARCHAR(20);
  p_EntityIDFieldName_cc0fff40d5a3 VARCHAR(100);
  p_ScopeDefault_cc0fff40d5a3 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_cc0fff40d5a3 BOOLEAN;
  p_ValuesToPackWithSchema_cc0fff40d5a3 VARCHAR(10);
  p_Status_cc0fff40d5a3 VARCHAR(25);
  p_AutoUpdateIsNameField_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateDefaultInView_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateCategory_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateDisplayName_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_cc0fff40d5a3 BOOLEAN;
  p_Encrypt_cc0fff40d5a3 BOOLEAN;
  p_EncryptionKeyID_cc0fff40d5a3 UUID;
  p_AllowDecryptInAPI_cc0fff40d5a3 BOOLEAN;
  p_SendEncryptedValue_cc0fff40d5a3 BOOLEAN;
  p_IsSoftPrimaryKey_cc0fff40d5a3 BOOLEAN;
  p_IsSoftForeignKey_cc0fff40d5a3 BOOLEAN;
  p_RelatedEntityJoinFields_cc0fff40d5a3 TEXT;
  p_JSONType_cc0fff40d5a3 VARCHAR(255);
  p_JSONTypeIsArray_cc0fff40d5a3 BOOLEAN;
  p_JSONTypeDefinition_cc0fff40d5a3 TEXT;
  p_UserSearchPredicateAPI_cc0fff40d5a3 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateFullTextSearch_cc0fff40d5a3 BOOLEAN;
  p_AutoUpdateExtendedType_cc0fff40d5a3 BOOLEAN;
  p_IsComputed_cc0fff40d5a3 BOOLEAN;
  p_EmbeddedRecord_cc0fff40d5a3 TEXT;
  p_Configuration_cc0fff40d5a3 TEXT;
  p_ID_cc0fff40d5a3 UUID;
BEGIN
  p_DisplayName_cc0fff40d5a3 := 'Name';
  p_AutoUpdateDescription_cc0fff40d5a3 := TRUE;
  p_IsPrimaryKey_cc0fff40d5a3 := FALSE;
  p_IsUnique_cc0fff40d5a3 := FALSE;
  p_ValueListType_cc0fff40d5a3 := 'None';
  p_DefaultInView_cc0fff40d5a3 := TRUE;
  p_DefaultColumnWidth_cc0fff40d5a3 := 150;
  p_AllowUpdateAPI_cc0fff40d5a3 := TRUE;
  p_AllowUpdateInView_cc0fff40d5a3 := TRUE;
  p_IncludeInUserSearchAPI_cc0fff40d5a3 := TRUE;
  p_FullTextSearchEnabled_cc0fff40d5a3 := FALSE;
  p_IncludeInGeneratedForm_cc0fff40d5a3 := TRUE;
  p_GeneratedFormSection_cc0fff40d5a3 := 'Details';
  p_IsNameField_cc0fff40d5a3 := TRUE;
  p_IncludeRelatedEntityNameFieldInBaseView_cc0fff40d5a3 := FALSE;
  p_RelatedEntityDisplayType_cc0fff40d5a3 := 'Search';
  p_AutoUpdateRelatedEntityInfo_cc0fff40d5a3 := TRUE;
  p_ValuesToPackWithSchema_cc0fff40d5a3 := 'Auto';
  p_Status_cc0fff40d5a3 := 'Active';
  p_AutoUpdateIsNameField_cc0fff40d5a3 := TRUE;
  p_AutoUpdateDefaultInView_cc0fff40d5a3 := TRUE;
  p_AutoUpdateCategory_cc0fff40d5a3 := TRUE;
  p_AutoUpdateDisplayName_cc0fff40d5a3 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_cc0fff40d5a3 := FALSE;
  p_Encrypt_cc0fff40d5a3 := FALSE;
  p_AllowDecryptInAPI_cc0fff40d5a3 := FALSE;
  p_SendEncryptedValue_cc0fff40d5a3 := FALSE;
  p_IsSoftPrimaryKey_cc0fff40d5a3 := FALSE;
  p_IsSoftForeignKey_cc0fff40d5a3 := FALSE;
  p_JSONTypeIsArray_cc0fff40d5a3 := FALSE;
  p_UserSearchPredicateAPI_cc0fff40d5a3 := 'BeginsWith';
  p_AutoUpdateUserSearchPredicate_cc0fff40d5a3 := TRUE;
  p_AutoUpdateFullTextSearch_cc0fff40d5a3 := TRUE;
  p_AutoUpdateExtendedType_cc0fff40d5a3 := TRUE;
  p_IsComputed_cc0fff40d5a3 := FALSE;
  p_ID_cc0fff40d5a3 := '5965F6A3-F788-40DF-B248-B02A5834DB01';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_cc0fff40d5a3,
    'Description', p_Description_cc0fff40d5a3,
    'AutoUpdateDescription', p_AutoUpdateDescription_cc0fff40d5a3,
    'IsPrimaryKey', p_IsPrimaryKey_cc0fff40d5a3,
    'IsUnique', p_IsUnique_cc0fff40d5a3,
    'Category', p_Category_cc0fff40d5a3,
    'ValueListType', p_ValueListType_cc0fff40d5a3,
    'ExtendedType', p_ExtendedType_cc0fff40d5a3,
    'CodeType', p_CodeType_cc0fff40d5a3,
    'DefaultInView', p_DefaultInView_cc0fff40d5a3,
    'ViewCellTemplate', p_ViewCellTemplate_cc0fff40d5a3,
    'DefaultColumnWidth', p_DefaultColumnWidth_cc0fff40d5a3,
    'AllowUpdateAPI', p_AllowUpdateAPI_cc0fff40d5a3,
    'AllowUpdateInView', p_AllowUpdateInView_cc0fff40d5a3,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_cc0fff40d5a3,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_cc0fff40d5a3,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_cc0fff40d5a3,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_cc0fff40d5a3,
    'GeneratedFormSection', p_GeneratedFormSection_cc0fff40d5a3,
    'IsNameField', p_IsNameField_cc0fff40d5a3,
    'RelatedEntityID', p_RelatedEntityID_cc0fff40d5a3,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_cc0fff40d5a3,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_cc0fff40d5a3,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_cc0fff40d5a3,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_cc0fff40d5a3,
    'EntityIDFieldName', p_EntityIDFieldName_cc0fff40d5a3,
    'ScopeDefault', p_ScopeDefault_cc0fff40d5a3,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_cc0fff40d5a3,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_cc0fff40d5a3,
    'Status', p_Status_cc0fff40d5a3,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_cc0fff40d5a3,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_cc0fff40d5a3,
    'AutoUpdateCategory', p_AutoUpdateCategory_cc0fff40d5a3,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_cc0fff40d5a3,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_cc0fff40d5a3,
    'Encrypt', p_Encrypt_cc0fff40d5a3,
    'EncryptionKeyID', p_EncryptionKeyID_cc0fff40d5a3,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_cc0fff40d5a3,
    'SendEncryptedValue', p_SendEncryptedValue_cc0fff40d5a3,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_cc0fff40d5a3,
    'IsSoftForeignKey', p_IsSoftForeignKey_cc0fff40d5a3,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_cc0fff40d5a3,
    'JSONType', p_JSONType_cc0fff40d5a3,
    'JSONTypeIsArray', p_JSONTypeIsArray_cc0fff40d5a3,
    'JSONTypeDefinition', p_JSONTypeDefinition_cc0fff40d5a3,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_cc0fff40d5a3,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_cc0fff40d5a3,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_cc0fff40d5a3,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_cc0fff40d5a3,
    'IsComputed', p_IsComputed_cc0fff40d5a3
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_cc0fff40d5a3,
    'Configuration', p_Configuration_cc0fff40d5a3,
    'ID', p_ID_cc0fff40d5a3
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_cc0fff40d5a3, p_Description := p_Description_cc0fff40d5a3, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_cc0fff40d5a3, p_IsPrimaryKey := p_IsPrimaryKey_cc0fff40d5a3, p_IsUnique := p_IsUnique_cc0fff40d5a3, p_Category := p_Category_cc0fff40d5a3, p_Category_Clear := TRUE, p_ValueListType := p_ValueListType_cc0fff40d5a3, p_ExtendedType := p_ExtendedType_cc0fff40d5a3, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_cc0fff40d5a3, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_cc0fff40d5a3, p_ViewCellTemplate := p_ViewCellTemplate_cc0fff40d5a3, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_cc0fff40d5a3, p_AllowUpdateAPI := p_AllowUpdateAPI_cc0fff40d5a3, p_AllowUpdateInView := p_AllowUpdateInView_cc0fff40d5a3, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_cc0fff40d5a3, p_FullTextSearchEnabled := p_FullTextSearchEnabled_cc0fff40d5a3, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_cc0fff40d5a3, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_cc0fff40d5a3, p_GeneratedFormSection := p_GeneratedFormSection_cc0fff40d5a3, p_IsNameField := p_IsNameField_cc0fff40d5a3, p_RelatedEntityID := p_RelatedEntityID_cc0fff40d5a3, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_cc0fff40d5a3, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_cc0fff40d5a3, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_cc0fff40d5a3, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_cc0fff40d5a3, p_EntityIDFieldName := p_EntityIDFieldName_cc0fff40d5a3, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_cc0fff40d5a3, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_cc0fff40d5a3, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_cc0fff40d5a3, p_Status := p_Status_cc0fff40d5a3, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_cc0fff40d5a3, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_cc0fff40d5a3, p_AutoUpdateCategory := p_AutoUpdateCategory_cc0fff40d5a3, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_cc0fff40d5a3, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_cc0fff40d5a3, p_Encrypt := p_Encrypt_cc0fff40d5a3, p_EncryptionKeyID := p_EncryptionKeyID_cc0fff40d5a3, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_cc0fff40d5a3, p_SendEncryptedValue := p_SendEncryptedValue_cc0fff40d5a3, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_cc0fff40d5a3, p_IsSoftForeignKey := p_IsSoftForeignKey_cc0fff40d5a3, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_cc0fff40d5a3, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_cc0fff40d5a3, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_cc0fff40d5a3, p_JSONTypeDefinition := p_JSONTypeDefinition_cc0fff40d5a3, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_cc0fff40d5a3, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_cc0fff40d5a3, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_cc0fff40d5a3, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_cc0fff40d5a3, p_IsComputed := p_IsComputed_cc0fff40d5a3, p_EmbeddedRecord := p_EmbeddedRecord_cc0fff40d5a3, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_cc0fff40d5a3, p_Configuration_Clear := TRUE, p_ID := p_ID_cc0fff40d5a3);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_3cf950e86eec VARCHAR(255);
  p_Description_3cf950e86eec TEXT;
  p_AutoUpdateDescription_3cf950e86eec BOOLEAN;
  p_IsPrimaryKey_3cf950e86eec BOOLEAN;
  p_IsUnique_3cf950e86eec BOOLEAN;
  p_Category_3cf950e86eec VARCHAR(255);
  p_ValueListType_3cf950e86eec VARCHAR(20);
  p_ExtendedType_3cf950e86eec VARCHAR(50);
  p_CodeType_3cf950e86eec VARCHAR(50);
  p_DefaultInView_3cf950e86eec BOOLEAN;
  p_ViewCellTemplate_3cf950e86eec TEXT;
  p_DefaultColumnWidth_3cf950e86eec INTEGER;
  p_AllowUpdateAPI_3cf950e86eec BOOLEAN;
  p_AllowUpdateInView_3cf950e86eec BOOLEAN;
  p_IncludeInUserSearchAPI_3cf950e86eec BOOLEAN;
  p_FullTextSearchEnabled_3cf950e86eec BOOLEAN;
  p_UserSearchParamFormatAPI_3cf950e86eec VARCHAR(500);
  p_IncludeInGeneratedForm_3cf950e86eec BOOLEAN;
  p_GeneratedFormSection_3cf950e86eec VARCHAR(10);
  p_IsNameField_3cf950e86eec BOOLEAN;
  p_RelatedEntityID_3cf950e86eec UUID;
  p_RelatedEntityFieldName_3cf950e86eec VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_3cf950e86eec BOOLEAN;
  p_RelatedEntityNameFieldMap_3cf950e86eec VARCHAR(255);
  p_RelatedEntityDisplayType_3cf950e86eec VARCHAR(20);
  p_EntityIDFieldName_3cf950e86eec VARCHAR(100);
  p_ScopeDefault_3cf950e86eec VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_3cf950e86eec BOOLEAN;
  p_ValuesToPackWithSchema_3cf950e86eec VARCHAR(10);
  p_Status_3cf950e86eec VARCHAR(25);
  p_AutoUpdateIsNameField_3cf950e86eec BOOLEAN;
  p_AutoUpdateDefaultInView_3cf950e86eec BOOLEAN;
  p_AutoUpdateCategory_3cf950e86eec BOOLEAN;
  p_AutoUpdateDisplayName_3cf950e86eec BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_3cf950e86eec BOOLEAN;
  p_Encrypt_3cf950e86eec BOOLEAN;
  p_EncryptionKeyID_3cf950e86eec UUID;
  p_AllowDecryptInAPI_3cf950e86eec BOOLEAN;
  p_SendEncryptedValue_3cf950e86eec BOOLEAN;
  p_IsSoftPrimaryKey_3cf950e86eec BOOLEAN;
  p_IsSoftForeignKey_3cf950e86eec BOOLEAN;
  p_RelatedEntityJoinFields_3cf950e86eec TEXT;
  p_JSONType_3cf950e86eec VARCHAR(255);
  p_JSONTypeIsArray_3cf950e86eec BOOLEAN;
  p_JSONTypeDefinition_3cf950e86eec TEXT;
  p_UserSearchPredicateAPI_3cf950e86eec VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_3cf950e86eec BOOLEAN;
  p_AutoUpdateFullTextSearch_3cf950e86eec BOOLEAN;
  p_AutoUpdateExtendedType_3cf950e86eec BOOLEAN;
  p_IsComputed_3cf950e86eec BOOLEAN;
  p_EmbeddedRecord_3cf950e86eec TEXT;
  p_Configuration_3cf950e86eec TEXT;
  p_ID_3cf950e86eec UUID;
BEGIN
  p_DisplayName_3cf950e86eec := 'ID';
  p_AutoUpdateDescription_3cf950e86eec := TRUE;
  p_IsPrimaryKey_3cf950e86eec := TRUE;
  p_IsUnique_3cf950e86eec := TRUE;
  p_ValueListType_3cf950e86eec := 'None';
  p_DefaultInView_3cf950e86eec := FALSE;
  p_DefaultColumnWidth_3cf950e86eec := 150;
  p_AllowUpdateAPI_3cf950e86eec := FALSE;
  p_AllowUpdateInView_3cf950e86eec := TRUE;
  p_IncludeInUserSearchAPI_3cf950e86eec := FALSE;
  p_FullTextSearchEnabled_3cf950e86eec := FALSE;
  p_IncludeInGeneratedForm_3cf950e86eec := TRUE;
  p_GeneratedFormSection_3cf950e86eec := 'Details';
  p_IsNameField_3cf950e86eec := FALSE;
  p_IncludeRelatedEntityNameFieldInBaseView_3cf950e86eec := FALSE;
  p_RelatedEntityDisplayType_3cf950e86eec := 'Search';
  p_AutoUpdateRelatedEntityInfo_3cf950e86eec := TRUE;
  p_ValuesToPackWithSchema_3cf950e86eec := 'Auto';
  p_Status_3cf950e86eec := 'Active';
  p_AutoUpdateIsNameField_3cf950e86eec := TRUE;
  p_AutoUpdateDefaultInView_3cf950e86eec := TRUE;
  p_AutoUpdateCategory_3cf950e86eec := TRUE;
  p_AutoUpdateDisplayName_3cf950e86eec := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_3cf950e86eec := FALSE;
  p_Encrypt_3cf950e86eec := FALSE;
  p_AllowDecryptInAPI_3cf950e86eec := FALSE;
  p_SendEncryptedValue_3cf950e86eec := FALSE;
  p_IsSoftPrimaryKey_3cf950e86eec := FALSE;
  p_IsSoftForeignKey_3cf950e86eec := FALSE;
  p_JSONTypeIsArray_3cf950e86eec := FALSE;
  p_UserSearchPredicateAPI_3cf950e86eec := 'Contains';
  p_AutoUpdateUserSearchPredicate_3cf950e86eec := TRUE;
  p_AutoUpdateFullTextSearch_3cf950e86eec := TRUE;
  p_AutoUpdateExtendedType_3cf950e86eec := TRUE;
  p_IsComputed_3cf950e86eec := FALSE;
  p_ID_3cf950e86eec := 'C2856D8E-31D8-4F13-A94A-2254C7427C69';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_3cf950e86eec,
    'Description', p_Description_3cf950e86eec,
    'AutoUpdateDescription', p_AutoUpdateDescription_3cf950e86eec,
    'IsPrimaryKey', p_IsPrimaryKey_3cf950e86eec,
    'IsUnique', p_IsUnique_3cf950e86eec,
    'Category', p_Category_3cf950e86eec,
    'ValueListType', p_ValueListType_3cf950e86eec,
    'ExtendedType', p_ExtendedType_3cf950e86eec,
    'CodeType', p_CodeType_3cf950e86eec,
    'DefaultInView', p_DefaultInView_3cf950e86eec,
    'ViewCellTemplate', p_ViewCellTemplate_3cf950e86eec,
    'DefaultColumnWidth', p_DefaultColumnWidth_3cf950e86eec,
    'AllowUpdateAPI', p_AllowUpdateAPI_3cf950e86eec,
    'AllowUpdateInView', p_AllowUpdateInView_3cf950e86eec,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_3cf950e86eec,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_3cf950e86eec,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_3cf950e86eec,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_3cf950e86eec,
    'GeneratedFormSection', p_GeneratedFormSection_3cf950e86eec,
    'IsNameField', p_IsNameField_3cf950e86eec,
    'RelatedEntityID', p_RelatedEntityID_3cf950e86eec,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_3cf950e86eec,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_3cf950e86eec,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_3cf950e86eec,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_3cf950e86eec,
    'EntityIDFieldName', p_EntityIDFieldName_3cf950e86eec,
    'ScopeDefault', p_ScopeDefault_3cf950e86eec,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_3cf950e86eec,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_3cf950e86eec,
    'Status', p_Status_3cf950e86eec,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_3cf950e86eec,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_3cf950e86eec,
    'AutoUpdateCategory', p_AutoUpdateCategory_3cf950e86eec,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_3cf950e86eec,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_3cf950e86eec,
    'Encrypt', p_Encrypt_3cf950e86eec,
    'EncryptionKeyID', p_EncryptionKeyID_3cf950e86eec,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_3cf950e86eec,
    'SendEncryptedValue', p_SendEncryptedValue_3cf950e86eec,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_3cf950e86eec,
    'IsSoftForeignKey', p_IsSoftForeignKey_3cf950e86eec,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_3cf950e86eec,
    'JSONType', p_JSONType_3cf950e86eec,
    'JSONTypeIsArray', p_JSONTypeIsArray_3cf950e86eec,
    'JSONTypeDefinition', p_JSONTypeDefinition_3cf950e86eec,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_3cf950e86eec,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_3cf950e86eec,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_3cf950e86eec,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_3cf950e86eec,
    'IsComputed', p_IsComputed_3cf950e86eec
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_3cf950e86eec,
    'Configuration', p_Configuration_3cf950e86eec,
    'ID', p_ID_3cf950e86eec
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_3cf950e86eec, p_Description := p_Description_3cf950e86eec, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_3cf950e86eec, p_IsPrimaryKey := p_IsPrimaryKey_3cf950e86eec, p_IsUnique := p_IsUnique_3cf950e86eec, p_Category := p_Category_3cf950e86eec, p_Category_Clear := TRUE, p_ValueListType := p_ValueListType_3cf950e86eec, p_ExtendedType := p_ExtendedType_3cf950e86eec, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_3cf950e86eec, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_3cf950e86eec, p_ViewCellTemplate := p_ViewCellTemplate_3cf950e86eec, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_3cf950e86eec, p_AllowUpdateAPI := p_AllowUpdateAPI_3cf950e86eec, p_AllowUpdateInView := p_AllowUpdateInView_3cf950e86eec, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_3cf950e86eec, p_FullTextSearchEnabled := p_FullTextSearchEnabled_3cf950e86eec, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_3cf950e86eec, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_3cf950e86eec, p_GeneratedFormSection := p_GeneratedFormSection_3cf950e86eec, p_IsNameField := p_IsNameField_3cf950e86eec, p_RelatedEntityID := p_RelatedEntityID_3cf950e86eec, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_3cf950e86eec, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_3cf950e86eec, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_3cf950e86eec, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_3cf950e86eec, p_EntityIDFieldName := p_EntityIDFieldName_3cf950e86eec, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_3cf950e86eec, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_3cf950e86eec, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_3cf950e86eec, p_Status := p_Status_3cf950e86eec, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_3cf950e86eec, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_3cf950e86eec, p_AutoUpdateCategory := p_AutoUpdateCategory_3cf950e86eec, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_3cf950e86eec, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_3cf950e86eec, p_Encrypt := p_Encrypt_3cf950e86eec, p_EncryptionKeyID := p_EncryptionKeyID_3cf950e86eec, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_3cf950e86eec, p_SendEncryptedValue := p_SendEncryptedValue_3cf950e86eec, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_3cf950e86eec, p_IsSoftForeignKey := p_IsSoftForeignKey_3cf950e86eec, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_3cf950e86eec, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_3cf950e86eec, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_3cf950e86eec, p_JSONTypeDefinition := p_JSONTypeDefinition_3cf950e86eec, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_3cf950e86eec, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_3cf950e86eec, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_3cf950e86eec, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_3cf950e86eec, p_IsComputed := p_IsComputed_3cf950e86eec, p_EmbeddedRecord := p_EmbeddedRecord_3cf950e86eec, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_3cf950e86eec, p_Configuration_Clear := TRUE, p_ID := p_ID_3cf950e86eec);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_1eef592ea8d9 VARCHAR(255);
  p_Description_1eef592ea8d9 TEXT;
  p_AutoUpdateDescription_1eef592ea8d9 BOOLEAN;
  p_IsPrimaryKey_1eef592ea8d9 BOOLEAN;
  p_IsUnique_1eef592ea8d9 BOOLEAN;
  p_Category_1eef592ea8d9 VARCHAR(255);
  p_ValueListType_1eef592ea8d9 VARCHAR(20);
  p_ExtendedType_1eef592ea8d9 VARCHAR(50);
  p_CodeType_1eef592ea8d9 VARCHAR(50);
  p_DefaultInView_1eef592ea8d9 BOOLEAN;
  p_ViewCellTemplate_1eef592ea8d9 TEXT;
  p_DefaultColumnWidth_1eef592ea8d9 INTEGER;
  p_AllowUpdateAPI_1eef592ea8d9 BOOLEAN;
  p_AllowUpdateInView_1eef592ea8d9 BOOLEAN;
  p_IncludeInUserSearchAPI_1eef592ea8d9 BOOLEAN;
  p_FullTextSearchEnabled_1eef592ea8d9 BOOLEAN;
  p_UserSearchParamFormatAPI_1eef592ea8d9 VARCHAR(500);
  p_IncludeInGeneratedForm_1eef592ea8d9 BOOLEAN;
  p_GeneratedFormSection_1eef592ea8d9 VARCHAR(10);
  p_IsNameField_1eef592ea8d9 BOOLEAN;
  p_RelatedEntityID_1eef592ea8d9 UUID;
  p_RelatedEntityFieldName_1eef592ea8d9 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_1eef592ea8d9 BOOLEAN;
  p_RelatedEntityNameFieldMap_1eef592ea8d9 VARCHAR(255);
  p_RelatedEntityDisplayType_1eef592ea8d9 VARCHAR(20);
  p_EntityIDFieldName_1eef592ea8d9 VARCHAR(100);
  p_ScopeDefault_1eef592ea8d9 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_1eef592ea8d9 BOOLEAN;
  p_ValuesToPackWithSchema_1eef592ea8d9 VARCHAR(10);
  p_Status_1eef592ea8d9 VARCHAR(25);
  p_AutoUpdateIsNameField_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateDefaultInView_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateCategory_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateDisplayName_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_1eef592ea8d9 BOOLEAN;
  p_Encrypt_1eef592ea8d9 BOOLEAN;
  p_EncryptionKeyID_1eef592ea8d9 UUID;
  p_AllowDecryptInAPI_1eef592ea8d9 BOOLEAN;
  p_SendEncryptedValue_1eef592ea8d9 BOOLEAN;
  p_IsSoftPrimaryKey_1eef592ea8d9 BOOLEAN;
  p_IsSoftForeignKey_1eef592ea8d9 BOOLEAN;
  p_RelatedEntityJoinFields_1eef592ea8d9 TEXT;
  p_JSONType_1eef592ea8d9 VARCHAR(255);
  p_JSONTypeIsArray_1eef592ea8d9 BOOLEAN;
  p_JSONTypeDefinition_1eef592ea8d9 TEXT;
  p_UserSearchPredicateAPI_1eef592ea8d9 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateFullTextSearch_1eef592ea8d9 BOOLEAN;
  p_AutoUpdateExtendedType_1eef592ea8d9 BOOLEAN;
  p_IsComputed_1eef592ea8d9 BOOLEAN;
  p_EmbeddedRecord_1eef592ea8d9 TEXT;
  p_Configuration_1eef592ea8d9 TEXT;
  p_ID_1eef592ea8d9 UUID;
BEGIN
  p_DisplayName_1eef592ea8d9 := 'Name';
  p_AutoUpdateDescription_1eef592ea8d9 := TRUE;
  p_IsPrimaryKey_1eef592ea8d9 := FALSE;
  p_IsUnique_1eef592ea8d9 := FALSE;
  p_ValueListType_1eef592ea8d9 := 'None';
  p_DefaultInView_1eef592ea8d9 := TRUE;
  p_DefaultColumnWidth_1eef592ea8d9 := 150;
  p_AllowUpdateAPI_1eef592ea8d9 := TRUE;
  p_AllowUpdateInView_1eef592ea8d9 := TRUE;
  p_IncludeInUserSearchAPI_1eef592ea8d9 := TRUE;
  p_FullTextSearchEnabled_1eef592ea8d9 := FALSE;
  p_IncludeInGeneratedForm_1eef592ea8d9 := TRUE;
  p_GeneratedFormSection_1eef592ea8d9 := 'Details';
  p_IsNameField_1eef592ea8d9 := TRUE;
  p_IncludeRelatedEntityNameFieldInBaseView_1eef592ea8d9 := FALSE;
  p_RelatedEntityDisplayType_1eef592ea8d9 := 'Search';
  p_AutoUpdateRelatedEntityInfo_1eef592ea8d9 := TRUE;
  p_ValuesToPackWithSchema_1eef592ea8d9 := 'Auto';
  p_Status_1eef592ea8d9 := 'Active';
  p_AutoUpdateIsNameField_1eef592ea8d9 := TRUE;
  p_AutoUpdateDefaultInView_1eef592ea8d9 := TRUE;
  p_AutoUpdateCategory_1eef592ea8d9 := TRUE;
  p_AutoUpdateDisplayName_1eef592ea8d9 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_1eef592ea8d9 := FALSE;
  p_Encrypt_1eef592ea8d9 := FALSE;
  p_AllowDecryptInAPI_1eef592ea8d9 := FALSE;
  p_SendEncryptedValue_1eef592ea8d9 := FALSE;
  p_IsSoftPrimaryKey_1eef592ea8d9 := FALSE;
  p_IsSoftForeignKey_1eef592ea8d9 := FALSE;
  p_JSONTypeIsArray_1eef592ea8d9 := FALSE;
  p_UserSearchPredicateAPI_1eef592ea8d9 := 'BeginsWith';
  p_AutoUpdateUserSearchPredicate_1eef592ea8d9 := TRUE;
  p_AutoUpdateFullTextSearch_1eef592ea8d9 := TRUE;
  p_AutoUpdateExtendedType_1eef592ea8d9 := TRUE;
  p_IsComputed_1eef592ea8d9 := FALSE;
  p_ID_1eef592ea8d9 := '1B80A51F-BE02-411F-B960-63EA442C9172';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_1eef592ea8d9,
    'Description', p_Description_1eef592ea8d9,
    'AutoUpdateDescription', p_AutoUpdateDescription_1eef592ea8d9,
    'IsPrimaryKey', p_IsPrimaryKey_1eef592ea8d9,
    'IsUnique', p_IsUnique_1eef592ea8d9,
    'Category', p_Category_1eef592ea8d9,
    'ValueListType', p_ValueListType_1eef592ea8d9,
    'ExtendedType', p_ExtendedType_1eef592ea8d9,
    'CodeType', p_CodeType_1eef592ea8d9,
    'DefaultInView', p_DefaultInView_1eef592ea8d9,
    'ViewCellTemplate', p_ViewCellTemplate_1eef592ea8d9,
    'DefaultColumnWidth', p_DefaultColumnWidth_1eef592ea8d9,
    'AllowUpdateAPI', p_AllowUpdateAPI_1eef592ea8d9,
    'AllowUpdateInView', p_AllowUpdateInView_1eef592ea8d9,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_1eef592ea8d9,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_1eef592ea8d9,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_1eef592ea8d9,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_1eef592ea8d9,
    'GeneratedFormSection', p_GeneratedFormSection_1eef592ea8d9,
    'IsNameField', p_IsNameField_1eef592ea8d9,
    'RelatedEntityID', p_RelatedEntityID_1eef592ea8d9,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_1eef592ea8d9,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_1eef592ea8d9,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_1eef592ea8d9,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_1eef592ea8d9,
    'EntityIDFieldName', p_EntityIDFieldName_1eef592ea8d9,
    'ScopeDefault', p_ScopeDefault_1eef592ea8d9,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_1eef592ea8d9,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_1eef592ea8d9,
    'Status', p_Status_1eef592ea8d9,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_1eef592ea8d9,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_1eef592ea8d9,
    'AutoUpdateCategory', p_AutoUpdateCategory_1eef592ea8d9,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_1eef592ea8d9,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_1eef592ea8d9,
    'Encrypt', p_Encrypt_1eef592ea8d9,
    'EncryptionKeyID', p_EncryptionKeyID_1eef592ea8d9,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_1eef592ea8d9,
    'SendEncryptedValue', p_SendEncryptedValue_1eef592ea8d9,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_1eef592ea8d9,
    'IsSoftForeignKey', p_IsSoftForeignKey_1eef592ea8d9,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_1eef592ea8d9,
    'JSONType', p_JSONType_1eef592ea8d9,
    'JSONTypeIsArray', p_JSONTypeIsArray_1eef592ea8d9,
    'JSONTypeDefinition', p_JSONTypeDefinition_1eef592ea8d9,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_1eef592ea8d9,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_1eef592ea8d9,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_1eef592ea8d9,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_1eef592ea8d9,
    'IsComputed', p_IsComputed_1eef592ea8d9
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_1eef592ea8d9,
    'Configuration', p_Configuration_1eef592ea8d9,
    'ID', p_ID_1eef592ea8d9
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_1eef592ea8d9, p_Description := p_Description_1eef592ea8d9, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_1eef592ea8d9, p_IsPrimaryKey := p_IsPrimaryKey_1eef592ea8d9, p_IsUnique := p_IsUnique_1eef592ea8d9, p_Category := p_Category_1eef592ea8d9, p_Category_Clear := TRUE, p_ValueListType := p_ValueListType_1eef592ea8d9, p_ExtendedType := p_ExtendedType_1eef592ea8d9, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_1eef592ea8d9, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_1eef592ea8d9, p_ViewCellTemplate := p_ViewCellTemplate_1eef592ea8d9, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_1eef592ea8d9, p_AllowUpdateAPI := p_AllowUpdateAPI_1eef592ea8d9, p_AllowUpdateInView := p_AllowUpdateInView_1eef592ea8d9, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_1eef592ea8d9, p_FullTextSearchEnabled := p_FullTextSearchEnabled_1eef592ea8d9, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_1eef592ea8d9, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_1eef592ea8d9, p_GeneratedFormSection := p_GeneratedFormSection_1eef592ea8d9, p_IsNameField := p_IsNameField_1eef592ea8d9, p_RelatedEntityID := p_RelatedEntityID_1eef592ea8d9, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_1eef592ea8d9, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_1eef592ea8d9, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_1eef592ea8d9, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_1eef592ea8d9, p_EntityIDFieldName := p_EntityIDFieldName_1eef592ea8d9, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_1eef592ea8d9, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_1eef592ea8d9, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_1eef592ea8d9, p_Status := p_Status_1eef592ea8d9, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_1eef592ea8d9, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_1eef592ea8d9, p_AutoUpdateCategory := p_AutoUpdateCategory_1eef592ea8d9, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_1eef592ea8d9, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_1eef592ea8d9, p_Encrypt := p_Encrypt_1eef592ea8d9, p_EncryptionKeyID := p_EncryptionKeyID_1eef592ea8d9, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_1eef592ea8d9, p_SendEncryptedValue := p_SendEncryptedValue_1eef592ea8d9, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_1eef592ea8d9, p_IsSoftForeignKey := p_IsSoftForeignKey_1eef592ea8d9, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_1eef592ea8d9, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_1eef592ea8d9, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_1eef592ea8d9, p_JSONTypeDefinition := p_JSONTypeDefinition_1eef592ea8d9, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_1eef592ea8d9, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_1eef592ea8d9, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_1eef592ea8d9, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_1eef592ea8d9, p_IsComputed := p_IsComputed_1eef592ea8d9, p_EmbeddedRecord := p_EmbeddedRecord_1eef592ea8d9, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_1eef592ea8d9, p_Configuration_Clear := TRUE, p_ID := p_ID_1eef592ea8d9);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_99ccd266a1b4 VARCHAR(255);
  p_Description_99ccd266a1b4 TEXT;
  p_AutoUpdateDescription_99ccd266a1b4 BOOLEAN;
  p_IsPrimaryKey_99ccd266a1b4 BOOLEAN;
  p_IsUnique_99ccd266a1b4 BOOLEAN;
  p_Category_99ccd266a1b4 VARCHAR(255);
  p_ValueListType_99ccd266a1b4 VARCHAR(20);
  p_ExtendedType_99ccd266a1b4 VARCHAR(50);
  p_CodeType_99ccd266a1b4 VARCHAR(50);
  p_DefaultInView_99ccd266a1b4 BOOLEAN;
  p_ViewCellTemplate_99ccd266a1b4 TEXT;
  p_DefaultColumnWidth_99ccd266a1b4 INTEGER;
  p_AllowUpdateAPI_99ccd266a1b4 BOOLEAN;
  p_AllowUpdateInView_99ccd266a1b4 BOOLEAN;
  p_IncludeInUserSearchAPI_99ccd266a1b4 BOOLEAN;
  p_FullTextSearchEnabled_99ccd266a1b4 BOOLEAN;
  p_UserSearchParamFormatAPI_99ccd266a1b4 VARCHAR(500);
  p_IncludeInGeneratedForm_99ccd266a1b4 BOOLEAN;
  p_GeneratedFormSection_99ccd266a1b4 VARCHAR(10);
  p_IsNameField_99ccd266a1b4 BOOLEAN;
  p_RelatedEntityID_99ccd266a1b4 UUID;
  p_RelatedEntityFieldName_99ccd266a1b4 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_99ccd266a1b4 BOOLEAN;
  p_RelatedEntityNameFieldMap_99ccd266a1b4 VARCHAR(255);
  p_RelatedEntityDisplayType_99ccd266a1b4 VARCHAR(20);
  p_EntityIDFieldName_99ccd266a1b4 VARCHAR(100);
  p_ScopeDefault_99ccd266a1b4 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_99ccd266a1b4 BOOLEAN;
  p_ValuesToPackWithSchema_99ccd266a1b4 VARCHAR(10);
  p_Status_99ccd266a1b4 VARCHAR(25);
  p_AutoUpdateIsNameField_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateDefaultInView_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateCategory_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateDisplayName_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_99ccd266a1b4 BOOLEAN;
  p_Encrypt_99ccd266a1b4 BOOLEAN;
  p_EncryptionKeyID_99ccd266a1b4 UUID;
  p_AllowDecryptInAPI_99ccd266a1b4 BOOLEAN;
  p_SendEncryptedValue_99ccd266a1b4 BOOLEAN;
  p_IsSoftPrimaryKey_99ccd266a1b4 BOOLEAN;
  p_IsSoftForeignKey_99ccd266a1b4 BOOLEAN;
  p_RelatedEntityJoinFields_99ccd266a1b4 TEXT;
  p_JSONType_99ccd266a1b4 VARCHAR(255);
  p_JSONTypeIsArray_99ccd266a1b4 BOOLEAN;
  p_JSONTypeDefinition_99ccd266a1b4 TEXT;
  p_UserSearchPredicateAPI_99ccd266a1b4 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateFullTextSearch_99ccd266a1b4 BOOLEAN;
  p_AutoUpdateExtendedType_99ccd266a1b4 BOOLEAN;
  p_IsComputed_99ccd266a1b4 BOOLEAN;
  p_EmbeddedRecord_99ccd266a1b4 TEXT;
  p_Configuration_99ccd266a1b4 TEXT;
  p_ID_99ccd266a1b4 UUID;
BEGIN
  p_DisplayName_99ccd266a1b4 := 'ID';
  p_AutoUpdateDescription_99ccd266a1b4 := TRUE;
  p_IsPrimaryKey_99ccd266a1b4 := TRUE;
  p_IsUnique_99ccd266a1b4 := TRUE;
  p_ValueListType_99ccd266a1b4 := 'None';
  p_DefaultInView_99ccd266a1b4 := FALSE;
  p_DefaultColumnWidth_99ccd266a1b4 := 150;
  p_AllowUpdateAPI_99ccd266a1b4 := FALSE;
  p_AllowUpdateInView_99ccd266a1b4 := TRUE;
  p_IncludeInUserSearchAPI_99ccd266a1b4 := FALSE;
  p_FullTextSearchEnabled_99ccd266a1b4 := FALSE;
  p_IncludeInGeneratedForm_99ccd266a1b4 := TRUE;
  p_GeneratedFormSection_99ccd266a1b4 := 'Details';
  p_IsNameField_99ccd266a1b4 := FALSE;
  p_IncludeRelatedEntityNameFieldInBaseView_99ccd266a1b4 := FALSE;
  p_RelatedEntityDisplayType_99ccd266a1b4 := 'Search';
  p_AutoUpdateRelatedEntityInfo_99ccd266a1b4 := TRUE;
  p_ValuesToPackWithSchema_99ccd266a1b4 := 'Auto';
  p_Status_99ccd266a1b4 := 'Active';
  p_AutoUpdateIsNameField_99ccd266a1b4 := TRUE;
  p_AutoUpdateDefaultInView_99ccd266a1b4 := TRUE;
  p_AutoUpdateCategory_99ccd266a1b4 := TRUE;
  p_AutoUpdateDisplayName_99ccd266a1b4 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_99ccd266a1b4 := FALSE;
  p_Encrypt_99ccd266a1b4 := FALSE;
  p_AllowDecryptInAPI_99ccd266a1b4 := FALSE;
  p_SendEncryptedValue_99ccd266a1b4 := FALSE;
  p_IsSoftPrimaryKey_99ccd266a1b4 := FALSE;
  p_IsSoftForeignKey_99ccd266a1b4 := FALSE;
  p_JSONTypeIsArray_99ccd266a1b4 := FALSE;
  p_UserSearchPredicateAPI_99ccd266a1b4 := 'Contains';
  p_AutoUpdateUserSearchPredicate_99ccd266a1b4 := TRUE;
  p_AutoUpdateFullTextSearch_99ccd266a1b4 := TRUE;
  p_AutoUpdateExtendedType_99ccd266a1b4 := TRUE;
  p_IsComputed_99ccd266a1b4 := FALSE;
  p_ID_99ccd266a1b4 := '94FCEABF-A622-4502-820A-9E1F1533567D';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_99ccd266a1b4,
    'Description', p_Description_99ccd266a1b4,
    'AutoUpdateDescription', p_AutoUpdateDescription_99ccd266a1b4,
    'IsPrimaryKey', p_IsPrimaryKey_99ccd266a1b4,
    'IsUnique', p_IsUnique_99ccd266a1b4,
    'Category', p_Category_99ccd266a1b4,
    'ValueListType', p_ValueListType_99ccd266a1b4,
    'ExtendedType', p_ExtendedType_99ccd266a1b4,
    'CodeType', p_CodeType_99ccd266a1b4,
    'DefaultInView', p_DefaultInView_99ccd266a1b4,
    'ViewCellTemplate', p_ViewCellTemplate_99ccd266a1b4,
    'DefaultColumnWidth', p_DefaultColumnWidth_99ccd266a1b4,
    'AllowUpdateAPI', p_AllowUpdateAPI_99ccd266a1b4,
    'AllowUpdateInView', p_AllowUpdateInView_99ccd266a1b4,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_99ccd266a1b4,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_99ccd266a1b4,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_99ccd266a1b4,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_99ccd266a1b4,
    'GeneratedFormSection', p_GeneratedFormSection_99ccd266a1b4,
    'IsNameField', p_IsNameField_99ccd266a1b4,
    'RelatedEntityID', p_RelatedEntityID_99ccd266a1b4,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_99ccd266a1b4,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_99ccd266a1b4,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_99ccd266a1b4,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_99ccd266a1b4,
    'EntityIDFieldName', p_EntityIDFieldName_99ccd266a1b4,
    'ScopeDefault', p_ScopeDefault_99ccd266a1b4,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_99ccd266a1b4,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_99ccd266a1b4,
    'Status', p_Status_99ccd266a1b4,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_99ccd266a1b4,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_99ccd266a1b4,
    'AutoUpdateCategory', p_AutoUpdateCategory_99ccd266a1b4,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_99ccd266a1b4,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_99ccd266a1b4,
    'Encrypt', p_Encrypt_99ccd266a1b4,
    'EncryptionKeyID', p_EncryptionKeyID_99ccd266a1b4,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_99ccd266a1b4,
    'SendEncryptedValue', p_SendEncryptedValue_99ccd266a1b4,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_99ccd266a1b4,
    'IsSoftForeignKey', p_IsSoftForeignKey_99ccd266a1b4,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_99ccd266a1b4,
    'JSONType', p_JSONType_99ccd266a1b4,
    'JSONTypeIsArray', p_JSONTypeIsArray_99ccd266a1b4,
    'JSONTypeDefinition', p_JSONTypeDefinition_99ccd266a1b4,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_99ccd266a1b4,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_99ccd266a1b4,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_99ccd266a1b4,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_99ccd266a1b4,
    'IsComputed', p_IsComputed_99ccd266a1b4
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_99ccd266a1b4,
    'Configuration', p_Configuration_99ccd266a1b4,
    'ID', p_ID_99ccd266a1b4
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_99ccd266a1b4, p_Description := p_Description_99ccd266a1b4, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_99ccd266a1b4, p_IsPrimaryKey := p_IsPrimaryKey_99ccd266a1b4, p_IsUnique := p_IsUnique_99ccd266a1b4, p_Category := p_Category_99ccd266a1b4, p_Category_Clear := TRUE, p_ValueListType := p_ValueListType_99ccd266a1b4, p_ExtendedType := p_ExtendedType_99ccd266a1b4, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_99ccd266a1b4, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_99ccd266a1b4, p_ViewCellTemplate := p_ViewCellTemplate_99ccd266a1b4, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_99ccd266a1b4, p_AllowUpdateAPI := p_AllowUpdateAPI_99ccd266a1b4, p_AllowUpdateInView := p_AllowUpdateInView_99ccd266a1b4, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_99ccd266a1b4, p_FullTextSearchEnabled := p_FullTextSearchEnabled_99ccd266a1b4, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_99ccd266a1b4, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_99ccd266a1b4, p_GeneratedFormSection := p_GeneratedFormSection_99ccd266a1b4, p_IsNameField := p_IsNameField_99ccd266a1b4, p_RelatedEntityID := p_RelatedEntityID_99ccd266a1b4, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_99ccd266a1b4, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_99ccd266a1b4, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_99ccd266a1b4, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_99ccd266a1b4, p_EntityIDFieldName := p_EntityIDFieldName_99ccd266a1b4, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_99ccd266a1b4, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_99ccd266a1b4, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_99ccd266a1b4, p_Status := p_Status_99ccd266a1b4, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_99ccd266a1b4, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_99ccd266a1b4, p_AutoUpdateCategory := p_AutoUpdateCategory_99ccd266a1b4, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_99ccd266a1b4, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_99ccd266a1b4, p_Encrypt := p_Encrypt_99ccd266a1b4, p_EncryptionKeyID := p_EncryptionKeyID_99ccd266a1b4, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_99ccd266a1b4, p_SendEncryptedValue := p_SendEncryptedValue_99ccd266a1b4, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_99ccd266a1b4, p_IsSoftForeignKey := p_IsSoftForeignKey_99ccd266a1b4, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_99ccd266a1b4, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_99ccd266a1b4, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_99ccd266a1b4, p_JSONTypeDefinition := p_JSONTypeDefinition_99ccd266a1b4, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_99ccd266a1b4, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_99ccd266a1b4, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_99ccd266a1b4, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_99ccd266a1b4, p_IsComputed := p_IsComputed_99ccd266a1b4, p_EmbeddedRecord := p_EmbeddedRecord_99ccd266a1b4, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_99ccd266a1b4, p_Configuration_Clear := TRUE, p_ID := p_ID_99ccd266a1b4);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_60df81c5b6f2 VARCHAR(255);
  p_Description_60df81c5b6f2 TEXT;
  p_AutoUpdateDescription_60df81c5b6f2 BOOLEAN;
  p_IsPrimaryKey_60df81c5b6f2 BOOLEAN;
  p_IsUnique_60df81c5b6f2 BOOLEAN;
  p_Category_60df81c5b6f2 VARCHAR(255);
  p_ValueListType_60df81c5b6f2 VARCHAR(20);
  p_ExtendedType_60df81c5b6f2 VARCHAR(50);
  p_CodeType_60df81c5b6f2 VARCHAR(50);
  p_DefaultInView_60df81c5b6f2 BOOLEAN;
  p_ViewCellTemplate_60df81c5b6f2 TEXT;
  p_DefaultColumnWidth_60df81c5b6f2 INTEGER;
  p_AllowUpdateAPI_60df81c5b6f2 BOOLEAN;
  p_AllowUpdateInView_60df81c5b6f2 BOOLEAN;
  p_IncludeInUserSearchAPI_60df81c5b6f2 BOOLEAN;
  p_FullTextSearchEnabled_60df81c5b6f2 BOOLEAN;
  p_UserSearchParamFormatAPI_60df81c5b6f2 VARCHAR(500);
  p_IncludeInGeneratedForm_60df81c5b6f2 BOOLEAN;
  p_GeneratedFormSection_60df81c5b6f2 VARCHAR(10);
  p_IsNameField_60df81c5b6f2 BOOLEAN;
  p_RelatedEntityID_60df81c5b6f2 UUID;
  p_RelatedEntityFieldName_60df81c5b6f2 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_60df81c5b6f2 BOOLEAN;
  p_RelatedEntityNameFieldMap_60df81c5b6f2 VARCHAR(255);
  p_RelatedEntityDisplayType_60df81c5b6f2 VARCHAR(20);
  p_EntityIDFieldName_60df81c5b6f2 VARCHAR(100);
  p_ScopeDefault_60df81c5b6f2 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_60df81c5b6f2 BOOLEAN;
  p_ValuesToPackWithSchema_60df81c5b6f2 VARCHAR(10);
  p_Status_60df81c5b6f2 VARCHAR(25);
  p_AutoUpdateIsNameField_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateDefaultInView_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateCategory_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateDisplayName_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_60df81c5b6f2 BOOLEAN;
  p_Encrypt_60df81c5b6f2 BOOLEAN;
  p_EncryptionKeyID_60df81c5b6f2 UUID;
  p_AllowDecryptInAPI_60df81c5b6f2 BOOLEAN;
  p_SendEncryptedValue_60df81c5b6f2 BOOLEAN;
  p_IsSoftPrimaryKey_60df81c5b6f2 BOOLEAN;
  p_IsSoftForeignKey_60df81c5b6f2 BOOLEAN;
  p_RelatedEntityJoinFields_60df81c5b6f2 TEXT;
  p_JSONType_60df81c5b6f2 VARCHAR(255);
  p_JSONTypeIsArray_60df81c5b6f2 BOOLEAN;
  p_JSONTypeDefinition_60df81c5b6f2 TEXT;
  p_UserSearchPredicateAPI_60df81c5b6f2 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateFullTextSearch_60df81c5b6f2 BOOLEAN;
  p_AutoUpdateExtendedType_60df81c5b6f2 BOOLEAN;
  p_IsComputed_60df81c5b6f2 BOOLEAN;
  p_EmbeddedRecord_60df81c5b6f2 TEXT;
  p_Configuration_60df81c5b6f2 TEXT;
  p_ID_60df81c5b6f2 UUID;
BEGIN
  p_DisplayName_60df81c5b6f2 := 'Name';
  p_AutoUpdateDescription_60df81c5b6f2 := TRUE;
  p_IsPrimaryKey_60df81c5b6f2 := FALSE;
  p_IsUnique_60df81c5b6f2 := TRUE;
  p_Category_60df81c5b6f2 := 'Task Type Definition';
  p_ValueListType_60df81c5b6f2 := 'None';
  p_DefaultInView_60df81c5b6f2 := TRUE;
  p_DefaultColumnWidth_60df81c5b6f2 := 150;
  p_AllowUpdateAPI_60df81c5b6f2 := TRUE;
  p_AllowUpdateInView_60df81c5b6f2 := TRUE;
  p_IncludeInUserSearchAPI_60df81c5b6f2 := TRUE;
  p_FullTextSearchEnabled_60df81c5b6f2 := FALSE;
  p_IncludeInGeneratedForm_60df81c5b6f2 := TRUE;
  p_GeneratedFormSection_60df81c5b6f2 := 'Category';
  p_IsNameField_60df81c5b6f2 := TRUE;
  p_IncludeRelatedEntityNameFieldInBaseView_60df81c5b6f2 := FALSE;
  p_RelatedEntityDisplayType_60df81c5b6f2 := 'Search';
  p_AutoUpdateRelatedEntityInfo_60df81c5b6f2 := TRUE;
  p_ValuesToPackWithSchema_60df81c5b6f2 := 'Auto';
  p_Status_60df81c5b6f2 := 'Active';
  p_AutoUpdateIsNameField_60df81c5b6f2 := TRUE;
  p_AutoUpdateDefaultInView_60df81c5b6f2 := TRUE;
  p_AutoUpdateCategory_60df81c5b6f2 := TRUE;
  p_AutoUpdateDisplayName_60df81c5b6f2 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_60df81c5b6f2 := FALSE;
  p_Encrypt_60df81c5b6f2 := FALSE;
  p_AllowDecryptInAPI_60df81c5b6f2 := FALSE;
  p_SendEncryptedValue_60df81c5b6f2 := FALSE;
  p_IsSoftPrimaryKey_60df81c5b6f2 := FALSE;
  p_IsSoftForeignKey_60df81c5b6f2 := FALSE;
  p_JSONTypeIsArray_60df81c5b6f2 := FALSE;
  p_UserSearchPredicateAPI_60df81c5b6f2 := 'BeginsWith';
  p_AutoUpdateUserSearchPredicate_60df81c5b6f2 := TRUE;
  p_AutoUpdateFullTextSearch_60df81c5b6f2 := TRUE;
  p_AutoUpdateExtendedType_60df81c5b6f2 := TRUE;
  p_IsComputed_60df81c5b6f2 := FALSE;
  p_ID_60df81c5b6f2 := '00619351-6557-42B0-B412-1FC4283CB682';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_60df81c5b6f2,
    'Description', p_Description_60df81c5b6f2,
    'AutoUpdateDescription', p_AutoUpdateDescription_60df81c5b6f2,
    'IsPrimaryKey', p_IsPrimaryKey_60df81c5b6f2,
    'IsUnique', p_IsUnique_60df81c5b6f2,
    'Category', p_Category_60df81c5b6f2,
    'ValueListType', p_ValueListType_60df81c5b6f2,
    'ExtendedType', p_ExtendedType_60df81c5b6f2,
    'CodeType', p_CodeType_60df81c5b6f2,
    'DefaultInView', p_DefaultInView_60df81c5b6f2,
    'ViewCellTemplate', p_ViewCellTemplate_60df81c5b6f2,
    'DefaultColumnWidth', p_DefaultColumnWidth_60df81c5b6f2,
    'AllowUpdateAPI', p_AllowUpdateAPI_60df81c5b6f2,
    'AllowUpdateInView', p_AllowUpdateInView_60df81c5b6f2,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_60df81c5b6f2,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_60df81c5b6f2,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_60df81c5b6f2,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_60df81c5b6f2,
    'GeneratedFormSection', p_GeneratedFormSection_60df81c5b6f2,
    'IsNameField', p_IsNameField_60df81c5b6f2,
    'RelatedEntityID', p_RelatedEntityID_60df81c5b6f2,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_60df81c5b6f2,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_60df81c5b6f2,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_60df81c5b6f2,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_60df81c5b6f2,
    'EntityIDFieldName', p_EntityIDFieldName_60df81c5b6f2,
    'ScopeDefault', p_ScopeDefault_60df81c5b6f2,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_60df81c5b6f2,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_60df81c5b6f2,
    'Status', p_Status_60df81c5b6f2,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_60df81c5b6f2,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_60df81c5b6f2,
    'AutoUpdateCategory', p_AutoUpdateCategory_60df81c5b6f2,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_60df81c5b6f2,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_60df81c5b6f2,
    'Encrypt', p_Encrypt_60df81c5b6f2,
    'EncryptionKeyID', p_EncryptionKeyID_60df81c5b6f2,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_60df81c5b6f2,
    'SendEncryptedValue', p_SendEncryptedValue_60df81c5b6f2,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_60df81c5b6f2,
    'IsSoftForeignKey', p_IsSoftForeignKey_60df81c5b6f2,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_60df81c5b6f2,
    'JSONType', p_JSONType_60df81c5b6f2,
    'JSONTypeIsArray', p_JSONTypeIsArray_60df81c5b6f2,
    'JSONTypeDefinition', p_JSONTypeDefinition_60df81c5b6f2,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_60df81c5b6f2,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_60df81c5b6f2,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_60df81c5b6f2,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_60df81c5b6f2,
    'IsComputed', p_IsComputed_60df81c5b6f2
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_60df81c5b6f2,
    'Configuration', p_Configuration_60df81c5b6f2,
    'ID', p_ID_60df81c5b6f2
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_60df81c5b6f2, p_Description := p_Description_60df81c5b6f2, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_60df81c5b6f2, p_IsPrimaryKey := p_IsPrimaryKey_60df81c5b6f2, p_IsUnique := p_IsUnique_60df81c5b6f2, p_Category := p_Category_60df81c5b6f2, p_ValueListType := p_ValueListType_60df81c5b6f2, p_ExtendedType := p_ExtendedType_60df81c5b6f2, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_60df81c5b6f2, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_60df81c5b6f2, p_ViewCellTemplate := p_ViewCellTemplate_60df81c5b6f2, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_60df81c5b6f2, p_AllowUpdateAPI := p_AllowUpdateAPI_60df81c5b6f2, p_AllowUpdateInView := p_AllowUpdateInView_60df81c5b6f2, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_60df81c5b6f2, p_FullTextSearchEnabled := p_FullTextSearchEnabled_60df81c5b6f2, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_60df81c5b6f2, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_60df81c5b6f2, p_GeneratedFormSection := p_GeneratedFormSection_60df81c5b6f2, p_IsNameField := p_IsNameField_60df81c5b6f2, p_RelatedEntityID := p_RelatedEntityID_60df81c5b6f2, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_60df81c5b6f2, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_60df81c5b6f2, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_60df81c5b6f2, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_60df81c5b6f2, p_EntityIDFieldName := p_EntityIDFieldName_60df81c5b6f2, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_60df81c5b6f2, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_60df81c5b6f2, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_60df81c5b6f2, p_Status := p_Status_60df81c5b6f2, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_60df81c5b6f2, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_60df81c5b6f2, p_AutoUpdateCategory := p_AutoUpdateCategory_60df81c5b6f2, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_60df81c5b6f2, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_60df81c5b6f2, p_Encrypt := p_Encrypt_60df81c5b6f2, p_EncryptionKeyID := p_EncryptionKeyID_60df81c5b6f2, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_60df81c5b6f2, p_SendEncryptedValue := p_SendEncryptedValue_60df81c5b6f2, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_60df81c5b6f2, p_IsSoftForeignKey := p_IsSoftForeignKey_60df81c5b6f2, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_60df81c5b6f2, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_60df81c5b6f2, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_60df81c5b6f2, p_JSONTypeDefinition := p_JSONTypeDefinition_60df81c5b6f2, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_60df81c5b6f2, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_60df81c5b6f2, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_60df81c5b6f2, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_60df81c5b6f2, p_IsComputed := p_IsComputed_60df81c5b6f2, p_EmbeddedRecord := p_EmbeddedRecord_60df81c5b6f2, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_60df81c5b6f2, p_Configuration_Clear := TRUE, p_ID := p_ID_60df81c5b6f2);
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_DisplayName_dd1ce962cde0 VARCHAR(255);
  p_Description_dd1ce962cde0 TEXT;
  p_AutoUpdateDescription_dd1ce962cde0 BOOLEAN;
  p_IsPrimaryKey_dd1ce962cde0 BOOLEAN;
  p_IsUnique_dd1ce962cde0 BOOLEAN;
  p_Category_dd1ce962cde0 VARCHAR(255);
  p_ValueListType_dd1ce962cde0 VARCHAR(20);
  p_ExtendedType_dd1ce962cde0 VARCHAR(50);
  p_CodeType_dd1ce962cde0 VARCHAR(50);
  p_DefaultInView_dd1ce962cde0 BOOLEAN;
  p_ViewCellTemplate_dd1ce962cde0 TEXT;
  p_DefaultColumnWidth_dd1ce962cde0 INTEGER;
  p_AllowUpdateAPI_dd1ce962cde0 BOOLEAN;
  p_AllowUpdateInView_dd1ce962cde0 BOOLEAN;
  p_IncludeInUserSearchAPI_dd1ce962cde0 BOOLEAN;
  p_FullTextSearchEnabled_dd1ce962cde0 BOOLEAN;
  p_UserSearchParamFormatAPI_dd1ce962cde0 VARCHAR(500);
  p_IncludeInGeneratedForm_dd1ce962cde0 BOOLEAN;
  p_GeneratedFormSection_dd1ce962cde0 VARCHAR(10);
  p_IsNameField_dd1ce962cde0 BOOLEAN;
  p_RelatedEntityID_dd1ce962cde0 UUID;
  p_RelatedEntityFieldName_dd1ce962cde0 VARCHAR(255);
  p_IncludeRelatedEntityNameFieldInBaseView_dd1ce962cde0 BOOLEAN;
  p_RelatedEntityNameFieldMap_dd1ce962cde0 VARCHAR(255);
  p_RelatedEntityDisplayType_dd1ce962cde0 VARCHAR(20);
  p_EntityIDFieldName_dd1ce962cde0 VARCHAR(100);
  p_ScopeDefault_dd1ce962cde0 VARCHAR(100);
  p_AutoUpdateRelatedEntityInfo_dd1ce962cde0 BOOLEAN;
  p_ValuesToPackWithSchema_dd1ce962cde0 VARCHAR(10);
  p_Status_dd1ce962cde0 VARCHAR(25);
  p_AutoUpdateIsNameField_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateDefaultInView_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateCategory_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateDisplayName_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateIncludeInUserSearchAPI_dd1ce962cde0 BOOLEAN;
  p_Encrypt_dd1ce962cde0 BOOLEAN;
  p_EncryptionKeyID_dd1ce962cde0 UUID;
  p_AllowDecryptInAPI_dd1ce962cde0 BOOLEAN;
  p_SendEncryptedValue_dd1ce962cde0 BOOLEAN;
  p_IsSoftPrimaryKey_dd1ce962cde0 BOOLEAN;
  p_IsSoftForeignKey_dd1ce962cde0 BOOLEAN;
  p_RelatedEntityJoinFields_dd1ce962cde0 TEXT;
  p_JSONType_dd1ce962cde0 VARCHAR(255);
  p_JSONTypeIsArray_dd1ce962cde0 BOOLEAN;
  p_JSONTypeDefinition_dd1ce962cde0 TEXT;
  p_UserSearchPredicateAPI_dd1ce962cde0 VARCHAR(20);
  p_AutoUpdateUserSearchPredicate_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateFullTextSearch_dd1ce962cde0 BOOLEAN;
  p_AutoUpdateExtendedType_dd1ce962cde0 BOOLEAN;
  p_IsComputed_dd1ce962cde0 BOOLEAN;
  p_EmbeddedRecord_dd1ce962cde0 TEXT;
  p_Configuration_dd1ce962cde0 TEXT;
  p_ID_dd1ce962cde0 UUID;
BEGIN
  p_DisplayName_dd1ce962cde0 := 'ID';
  p_AutoUpdateDescription_dd1ce962cde0 := TRUE;
  p_IsPrimaryKey_dd1ce962cde0 := TRUE;
  p_IsUnique_dd1ce962cde0 := TRUE;
  p_Category_dd1ce962cde0 := 'System Metadata';
  p_ValueListType_dd1ce962cde0 := 'None';
  p_DefaultInView_dd1ce962cde0 := FALSE;
  p_DefaultColumnWidth_dd1ce962cde0 := 150;
  p_AllowUpdateAPI_dd1ce962cde0 := FALSE;
  p_AllowUpdateInView_dd1ce962cde0 := TRUE;
  p_IncludeInUserSearchAPI_dd1ce962cde0 := FALSE;
  p_FullTextSearchEnabled_dd1ce962cde0 := FALSE;
  p_IncludeInGeneratedForm_dd1ce962cde0 := TRUE;
  p_GeneratedFormSection_dd1ce962cde0 := 'Category';
  p_IsNameField_dd1ce962cde0 := FALSE;
  p_IncludeRelatedEntityNameFieldInBaseView_dd1ce962cde0 := FALSE;
  p_RelatedEntityDisplayType_dd1ce962cde0 := 'Search';
  p_AutoUpdateRelatedEntityInfo_dd1ce962cde0 := TRUE;
  p_ValuesToPackWithSchema_dd1ce962cde0 := 'Auto';
  p_Status_dd1ce962cde0 := 'Active';
  p_AutoUpdateIsNameField_dd1ce962cde0 := TRUE;
  p_AutoUpdateDefaultInView_dd1ce962cde0 := TRUE;
  p_AutoUpdateCategory_dd1ce962cde0 := TRUE;
  p_AutoUpdateDisplayName_dd1ce962cde0 := TRUE;
  p_AutoUpdateIncludeInUserSearchAPI_dd1ce962cde0 := FALSE;
  p_Encrypt_dd1ce962cde0 := FALSE;
  p_AllowDecryptInAPI_dd1ce962cde0 := FALSE;
  p_SendEncryptedValue_dd1ce962cde0 := FALSE;
  p_IsSoftPrimaryKey_dd1ce962cde0 := FALSE;
  p_IsSoftForeignKey_dd1ce962cde0 := FALSE;
  p_JSONTypeIsArray_dd1ce962cde0 := FALSE;
  p_UserSearchPredicateAPI_dd1ce962cde0 := 'Contains';
  p_AutoUpdateUserSearchPredicate_dd1ce962cde0 := TRUE;
  p_AutoUpdateFullTextSearch_dd1ce962cde0 := TRUE;
  p_AutoUpdateExtendedType_dd1ce962cde0 := TRUE;
  p_IsComputed_dd1ce962cde0 := FALSE;
  p_ID_dd1ce962cde0 := 'B5D4A231-3F9F-45F8-B1E5-3B0FCCABFE8B';
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
    'DisplayName', p_DisplayName_dd1ce962cde0,
    'Description', p_Description_dd1ce962cde0,
    'AutoUpdateDescription', p_AutoUpdateDescription_dd1ce962cde0,
    'IsPrimaryKey', p_IsPrimaryKey_dd1ce962cde0,
    'IsUnique', p_IsUnique_dd1ce962cde0,
    'Category', p_Category_dd1ce962cde0,
    'ValueListType', p_ValueListType_dd1ce962cde0,
    'ExtendedType', p_ExtendedType_dd1ce962cde0,
    'CodeType', p_CodeType_dd1ce962cde0,
    'DefaultInView', p_DefaultInView_dd1ce962cde0,
    'ViewCellTemplate', p_ViewCellTemplate_dd1ce962cde0,
    'DefaultColumnWidth', p_DefaultColumnWidth_dd1ce962cde0,
    'AllowUpdateAPI', p_AllowUpdateAPI_dd1ce962cde0,
    'AllowUpdateInView', p_AllowUpdateInView_dd1ce962cde0,
    'IncludeInUserSearchAPI', p_IncludeInUserSearchAPI_dd1ce962cde0,
    'FullTextSearchEnabled', p_FullTextSearchEnabled_dd1ce962cde0,
    'UserSearchParamFormatAPI', p_UserSearchParamFormatAPI_dd1ce962cde0,
    'IncludeInGeneratedForm', p_IncludeInGeneratedForm_dd1ce962cde0,
    'GeneratedFormSection', p_GeneratedFormSection_dd1ce962cde0,
    'IsNameField', p_IsNameField_dd1ce962cde0,
    'RelatedEntityID', p_RelatedEntityID_dd1ce962cde0,
    'RelatedEntityFieldName', p_RelatedEntityFieldName_dd1ce962cde0,
    'IncludeRelatedEntityNameFieldInBaseView', p_IncludeRelatedEntityNameFieldInBaseView_dd1ce962cde0,
    'RelatedEntityNameFieldMap', p_RelatedEntityNameFieldMap_dd1ce962cde0,
    'RelatedEntityDisplayType', p_RelatedEntityDisplayType_dd1ce962cde0,
    'EntityIDFieldName', p_EntityIDFieldName_dd1ce962cde0,
    'ScopeDefault', p_ScopeDefault_dd1ce962cde0,
    'AutoUpdateRelatedEntityInfo', p_AutoUpdateRelatedEntityInfo_dd1ce962cde0,
    'ValuesToPackWithSchema', p_ValuesToPackWithSchema_dd1ce962cde0,
    'Status', p_Status_dd1ce962cde0,
    'AutoUpdateIsNameField', p_AutoUpdateIsNameField_dd1ce962cde0,
    'AutoUpdateDefaultInView', p_AutoUpdateDefaultInView_dd1ce962cde0,
    'AutoUpdateCategory', p_AutoUpdateCategory_dd1ce962cde0,
    'AutoUpdateDisplayName', p_AutoUpdateDisplayName_dd1ce962cde0,
    'AutoUpdateIncludeInUserSearchAPI', p_AutoUpdateIncludeInUserSearchAPI_dd1ce962cde0,
    'Encrypt', p_Encrypt_dd1ce962cde0,
    'EncryptionKeyID', p_EncryptionKeyID_dd1ce962cde0,
    'AllowDecryptInAPI', p_AllowDecryptInAPI_dd1ce962cde0,
    'SendEncryptedValue', p_SendEncryptedValue_dd1ce962cde0,
    'IsSoftPrimaryKey', p_IsSoftPrimaryKey_dd1ce962cde0,
    'IsSoftForeignKey', p_IsSoftForeignKey_dd1ce962cde0,
    'RelatedEntityJoinFields', p_RelatedEntityJoinFields_dd1ce962cde0,
    'JSONType', p_JSONType_dd1ce962cde0,
    'JSONTypeIsArray', p_JSONTypeIsArray_dd1ce962cde0,
    'JSONTypeDefinition', p_JSONTypeDefinition_dd1ce962cde0,
    'UserSearchPredicateAPI', p_UserSearchPredicateAPI_dd1ce962cde0,
    'AutoUpdateUserSearchPredicate', p_AutoUpdateUserSearchPredicate_dd1ce962cde0,
    'AutoUpdateFullTextSearch', p_AutoUpdateFullTextSearch_dd1ce962cde0,
    'AutoUpdateExtendedType', p_AutoUpdateExtendedType_dd1ce962cde0,
    'IsComputed', p_IsComputed_dd1ce962cde0
  ) ||
  jsonb_build_object(
    'EmbeddedRecord', p_EmbeddedRecord_dd1ce962cde0,
    'Configuration', p_Configuration_dd1ce962cde0,
    'ID', p_ID_dd1ce962cde0
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityField"(p_DisplayName := p_DisplayName_dd1ce962cde0, p_Description := p_Description_dd1ce962cde0, p_Description_Clear := TRUE, p_AutoUpdateDescription := p_AutoUpdateDescription_dd1ce962cde0, p_IsPrimaryKey := p_IsPrimaryKey_dd1ce962cde0, p_IsUnique := p_IsUnique_dd1ce962cde0, p_Category := p_Category_dd1ce962cde0, p_ValueListType := p_ValueListType_dd1ce962cde0, p_ExtendedType := p_ExtendedType_dd1ce962cde0, p_ExtendedType_Clear := TRUE, p_CodeType := p_CodeType_dd1ce962cde0, p_CodeType_Clear := TRUE, p_DefaultInView := p_DefaultInView_dd1ce962cde0, p_ViewCellTemplate := p_ViewCellTemplate_dd1ce962cde0, p_ViewCellTemplate_Clear := TRUE, p_DefaultColumnWidth := p_DefaultColumnWidth_dd1ce962cde0, p_AllowUpdateAPI := p_AllowUpdateAPI_dd1ce962cde0, p_AllowUpdateInView := p_AllowUpdateInView_dd1ce962cde0, p_IncludeInUserSearchAPI := p_IncludeInUserSearchAPI_dd1ce962cde0, p_FullTextSearchEnabled := p_FullTextSearchEnabled_dd1ce962cde0, p_UserSearchParamFormatAPI := p_UserSearchParamFormatAPI_dd1ce962cde0, p_UserSearchParamFormatAPI_Clear := TRUE, p_IncludeInGeneratedForm := p_IncludeInGeneratedForm_dd1ce962cde0, p_GeneratedFormSection := p_GeneratedFormSection_dd1ce962cde0, p_IsNameField := p_IsNameField_dd1ce962cde0, p_RelatedEntityID := p_RelatedEntityID_dd1ce962cde0, p_RelatedEntityID_Clear := TRUE, p_RelatedEntityFieldName := p_RelatedEntityFieldName_dd1ce962cde0, p_RelatedEntityFieldName_Clear := TRUE, p_IncludeRelatedEntityNameFieldInBaseView := p_IncludeRelatedEntityNameFieldInBaseView_dd1ce962cde0, p_RelatedEntityNameFieldMap := p_RelatedEntityNameFieldMap_dd1ce962cde0, p_RelatedEntityNameFieldMap_Clear := TRUE, p_RelatedEntityDisplayType := p_RelatedEntityDisplayType_dd1ce962cde0, p_EntityIDFieldName := p_EntityIDFieldName_dd1ce962cde0, p_EntityIDFieldName_Clear := TRUE, p_ScopeDefault := p_ScopeDefault_dd1ce962cde0, p_ScopeDefault_Clear := TRUE, p_AutoUpdateRelatedEntityInfo := p_AutoUpdateRelatedEntityInfo_dd1ce962cde0, p_ValuesToPackWithSchema := p_ValuesToPackWithSchema_dd1ce962cde0, p_Status := p_Status_dd1ce962cde0, p_AutoUpdateIsNameField := p_AutoUpdateIsNameField_dd1ce962cde0, p_AutoUpdateDefaultInView := p_AutoUpdateDefaultInView_dd1ce962cde0, p_AutoUpdateCategory := p_AutoUpdateCategory_dd1ce962cde0, p_AutoUpdateDisplayName := p_AutoUpdateDisplayName_dd1ce962cde0, p_AutoUpdateIncludeInUserSearchAPI := p_AutoUpdateIncludeInUserSearchAPI_dd1ce962cde0, p_Encrypt := p_Encrypt_dd1ce962cde0, p_EncryptionKeyID := p_EncryptionKeyID_dd1ce962cde0, p_EncryptionKeyID_Clear := TRUE, p_AllowDecryptInAPI := p_AllowDecryptInAPI_dd1ce962cde0, p_SendEncryptedValue := p_SendEncryptedValue_dd1ce962cde0, p_IsSoftPrimaryKey := p_IsSoftPrimaryKey_dd1ce962cde0, p_IsSoftForeignKey := p_IsSoftForeignKey_dd1ce962cde0, p_RelatedEntityJoinFields := p_RelatedEntityJoinFields_dd1ce962cde0, p_RelatedEntityJoinFields_Clear := TRUE, p_JSONType := p_JSONType_dd1ce962cde0, p_JSONType_Clear := TRUE, p_JSONTypeIsArray := p_JSONTypeIsArray_dd1ce962cde0, p_JSONTypeDefinition := p_JSONTypeDefinition_dd1ce962cde0, p_JSONTypeDefinition_Clear := TRUE, p_UserSearchPredicateAPI := p_UserSearchPredicateAPI_dd1ce962cde0, p_AutoUpdateUserSearchPredicate := p_AutoUpdateUserSearchPredicate_dd1ce962cde0, p_AutoUpdateFullTextSearch := p_AutoUpdateFullTextSearch_dd1ce962cde0, p_AutoUpdateExtendedType := p_AutoUpdateExtendedType_dd1ce962cde0, p_IsComputed := p_IsComputed_dd1ce962cde0, p_EmbeddedRecord := p_EmbeddedRecord_dd1ce962cde0, p_EmbeddedRecord_Clear := TRUE, p_Configuration := p_Configuration_dd1ce962cde0, p_Configuration_Clear := TRUE, p_ID := p_ID_dd1ce962cde0);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_d7340b09b7e9 UUID;
  p_RoleID_d7340b09b7e9 UUID;
  p_CanCreate_d7340b09b7e9 BOOLEAN;
  p_CanRead_d7340b09b7e9 BOOLEAN;
  p_CanUpdate_d7340b09b7e9 BOOLEAN;
  p_CanDelete_d7340b09b7e9 BOOLEAN;
  p_ReadRLSFilterID_d7340b09b7e9 UUID;
  p_CreateRLSFilterID_d7340b09b7e9 UUID;
  p_UpdateRLSFilterID_d7340b09b7e9 UUID;
  p_DeleteRLSFilterID_d7340b09b7e9 UUID;
  p_Type_d7340b09b7e9 VARCHAR(10);
  p_ID_d7340b09b7e9 UUID;
BEGIN
  p_EntityID_d7340b09b7e9 := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';
  p_RoleID_d7340b09b7e9 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_d7340b09b7e9 := TRUE;
  p_CanRead_d7340b09b7e9 := TRUE;
  p_CanUpdate_d7340b09b7e9 := TRUE;
  p_CanDelete_d7340b09b7e9 := FALSE;
  p_Type_d7340b09b7e9 := 'Allow';
  p_ID_d7340b09b7e9 := '2F4D433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_d7340b09b7e9 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_d7340b09b7e9 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_d7340b09b7e9);
  p_ID_d7340b09b7e9 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_d7340b09b7e9 AND "RoleID" = p_RoleID_d7340b09b7e9 ORDER BY CASE WHEN "ID" = p_ID_d7340b09b7e9 THEN 0 ELSE 1 END LIMIT 1), p_ID_d7340b09b7e9);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_d7340b09b7e9,
    'RoleID', p_RoleID_d7340b09b7e9,
    'CanCreate', p_CanCreate_d7340b09b7e9,
    'CanRead', p_CanRead_d7340b09b7e9,
    'CanUpdate', p_CanUpdate_d7340b09b7e9,
    'CanDelete', p_CanDelete_d7340b09b7e9,
    'ReadRLSFilterID', p_ReadRLSFilterID_d7340b09b7e9,
    'CreateRLSFilterID', p_CreateRLSFilterID_d7340b09b7e9,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_d7340b09b7e9,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_d7340b09b7e9,
    'Type', p_Type_d7340b09b7e9,
    'ID', p_ID_d7340b09b7e9
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_d7340b09b7e9, p_RoleID := p_RoleID_d7340b09b7e9, p_CanCreate := p_CanCreate_d7340b09b7e9, p_CanRead := p_CanRead_d7340b09b7e9, p_CanUpdate := p_CanUpdate_d7340b09b7e9, p_CanDelete := p_CanDelete_d7340b09b7e9, p_ReadRLSFilterID := p_ReadRLSFilterID_d7340b09b7e9, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_d7340b09b7e9, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_d7340b09b7e9, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_d7340b09b7e9, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_d7340b09b7e9, p_ID := p_ID_d7340b09b7e9);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_a93b7cf57355 UUID;
  p_RoleID_a93b7cf57355 UUID;
  p_CanCreate_a93b7cf57355 BOOLEAN;
  p_CanRead_a93b7cf57355 BOOLEAN;
  p_CanUpdate_a93b7cf57355 BOOLEAN;
  p_CanDelete_a93b7cf57355 BOOLEAN;
  p_ReadRLSFilterID_a93b7cf57355 UUID;
  p_CreateRLSFilterID_a93b7cf57355 UUID;
  p_UpdateRLSFilterID_a93b7cf57355 UUID;
  p_DeleteRLSFilterID_a93b7cf57355 UUID;
  p_Type_a93b7cf57355 VARCHAR(10);
  p_ID_a93b7cf57355 UUID;
BEGIN
  p_EntityID_a93b7cf57355 := 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865';
  p_RoleID_a93b7cf57355 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_a93b7cf57355 := TRUE;
  p_CanRead_a93b7cf57355 := TRUE;
  p_CanUpdate_a93b7cf57355 := TRUE;
  p_CanDelete_a93b7cf57355 := FALSE;
  p_Type_a93b7cf57355 := 'Allow';
  p_ID_a93b7cf57355 := '174C433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_a93b7cf57355 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_a93b7cf57355 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_a93b7cf57355);
  p_ID_a93b7cf57355 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_a93b7cf57355 AND "RoleID" = p_RoleID_a93b7cf57355 ORDER BY CASE WHEN "ID" = p_ID_a93b7cf57355 THEN 0 ELSE 1 END LIMIT 1), p_ID_a93b7cf57355);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_a93b7cf57355,
    'RoleID', p_RoleID_a93b7cf57355,
    'CanCreate', p_CanCreate_a93b7cf57355,
    'CanRead', p_CanRead_a93b7cf57355,
    'CanUpdate', p_CanUpdate_a93b7cf57355,
    'CanDelete', p_CanDelete_a93b7cf57355,
    'ReadRLSFilterID', p_ReadRLSFilterID_a93b7cf57355,
    'CreateRLSFilterID', p_CreateRLSFilterID_a93b7cf57355,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_a93b7cf57355,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_a93b7cf57355,
    'Type', p_Type_a93b7cf57355,
    'ID', p_ID_a93b7cf57355
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_a93b7cf57355, p_RoleID := p_RoleID_a93b7cf57355, p_CanCreate := p_CanCreate_a93b7cf57355, p_CanRead := p_CanRead_a93b7cf57355, p_CanUpdate := p_CanUpdate_a93b7cf57355, p_CanDelete := p_CanDelete_a93b7cf57355, p_ReadRLSFilterID := p_ReadRLSFilterID_a93b7cf57355, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_a93b7cf57355, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_a93b7cf57355, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_a93b7cf57355, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_a93b7cf57355, p_ID := p_ID_a93b7cf57355);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_9afc883f6074 UUID;
  p_RoleID_9afc883f6074 UUID;
  p_CanCreate_9afc883f6074 BOOLEAN;
  p_CanRead_9afc883f6074 BOOLEAN;
  p_CanUpdate_9afc883f6074 BOOLEAN;
  p_CanDelete_9afc883f6074 BOOLEAN;
  p_ReadRLSFilterID_9afc883f6074 UUID;
  p_CreateRLSFilterID_9afc883f6074 UUID;
  p_UpdateRLSFilterID_9afc883f6074 UUID;
  p_DeleteRLSFilterID_9afc883f6074 UUID;
  p_Type_9afc883f6074 VARCHAR(10);
  p_ID_9afc883f6074 UUID;
BEGIN
  p_EntityID_9afc883f6074 := 'DF98E700-1992-442B-B93E-E47379F2CA52';
  p_RoleID_9afc883f6074 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_9afc883f6074 := TRUE;
  p_CanRead_9afc883f6074 := TRUE;
  p_CanUpdate_9afc883f6074 := TRUE;
  p_CanDelete_9afc883f6074 := TRUE;
  p_Type_9afc883f6074 := 'Allow';
  p_ID_9afc883f6074 := '8B4B433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_9afc883f6074 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_9afc883f6074 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_9afc883f6074);
  p_ID_9afc883f6074 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_9afc883f6074 AND "RoleID" = p_RoleID_9afc883f6074 ORDER BY CASE WHEN "ID" = p_ID_9afc883f6074 THEN 0 ELSE 1 END LIMIT 1), p_ID_9afc883f6074);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_9afc883f6074,
    'RoleID', p_RoleID_9afc883f6074,
    'CanCreate', p_CanCreate_9afc883f6074,
    'CanRead', p_CanRead_9afc883f6074,
    'CanUpdate', p_CanUpdate_9afc883f6074,
    'CanDelete', p_CanDelete_9afc883f6074,
    'ReadRLSFilterID', p_ReadRLSFilterID_9afc883f6074,
    'CreateRLSFilterID', p_CreateRLSFilterID_9afc883f6074,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_9afc883f6074,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_9afc883f6074,
    'Type', p_Type_9afc883f6074,
    'ID', p_ID_9afc883f6074
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_9afc883f6074, p_RoleID := p_RoleID_9afc883f6074, p_CanCreate := p_CanCreate_9afc883f6074, p_CanRead := p_CanRead_9afc883f6074, p_CanUpdate := p_CanUpdate_9afc883f6074, p_CanDelete := p_CanDelete_9afc883f6074, p_ReadRLSFilterID := p_ReadRLSFilterID_9afc883f6074, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_9afc883f6074, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_9afc883f6074, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_9afc883f6074, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_9afc883f6074, p_ID := p_ID_9afc883f6074);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_5361666ef78f UUID;
  p_RoleID_5361666ef78f UUID;
  p_CanCreate_5361666ef78f BOOLEAN;
  p_CanRead_5361666ef78f BOOLEAN;
  p_CanUpdate_5361666ef78f BOOLEAN;
  p_CanDelete_5361666ef78f BOOLEAN;
  p_ReadRLSFilterID_5361666ef78f UUID;
  p_CreateRLSFilterID_5361666ef78f UUID;
  p_UpdateRLSFilterID_5361666ef78f UUID;
  p_DeleteRLSFilterID_5361666ef78f UUID;
  p_Type_5361666ef78f VARCHAR(10);
  p_ID_5361666ef78f UUID;
BEGIN
  p_EntityID_5361666ef78f := 'EA953D6B-524E-4A09-A842-9A0B0F1F850C';
  p_RoleID_5361666ef78f := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_5361666ef78f := TRUE;
  p_CanRead_5361666ef78f := TRUE;
  p_CanUpdate_5361666ef78f := FALSE;
  p_CanDelete_5361666ef78f := TRUE;
  p_Type_5361666ef78f := 'Allow';
  p_ID_5361666ef78f := 'FB4B433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_5361666ef78f := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_5361666ef78f THEN 0 ELSE 1 END LIMIT 1), p_RoleID_5361666ef78f);
  p_ID_5361666ef78f := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_5361666ef78f AND "RoleID" = p_RoleID_5361666ef78f ORDER BY CASE WHEN "ID" = p_ID_5361666ef78f THEN 0 ELSE 1 END LIMIT 1), p_ID_5361666ef78f);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_5361666ef78f,
    'RoleID', p_RoleID_5361666ef78f,
    'CanCreate', p_CanCreate_5361666ef78f,
    'CanRead', p_CanRead_5361666ef78f,
    'CanUpdate', p_CanUpdate_5361666ef78f,
    'CanDelete', p_CanDelete_5361666ef78f,
    'ReadRLSFilterID', p_ReadRLSFilterID_5361666ef78f,
    'CreateRLSFilterID', p_CreateRLSFilterID_5361666ef78f,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_5361666ef78f,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_5361666ef78f,
    'Type', p_Type_5361666ef78f,
    'ID', p_ID_5361666ef78f
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_5361666ef78f, p_RoleID := p_RoleID_5361666ef78f, p_CanCreate := p_CanCreate_5361666ef78f, p_CanRead := p_CanRead_5361666ef78f, p_CanUpdate := p_CanUpdate_5361666ef78f, p_CanDelete := p_CanDelete_5361666ef78f, p_ReadRLSFilterID := p_ReadRLSFilterID_5361666ef78f, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_5361666ef78f, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_5361666ef78f, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_5361666ef78f, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_5361666ef78f, p_ID := p_ID_5361666ef78f);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_418dc5b9812e UUID;
  p_RoleID_418dc5b9812e UUID;
  p_CanCreate_418dc5b9812e BOOLEAN;
  p_CanRead_418dc5b9812e BOOLEAN;
  p_CanUpdate_418dc5b9812e BOOLEAN;
  p_CanDelete_418dc5b9812e BOOLEAN;
  p_ReadRLSFilterID_418dc5b9812e UUID;
  p_CreateRLSFilterID_418dc5b9812e UUID;
  p_UpdateRLSFilterID_418dc5b9812e UUID;
  p_DeleteRLSFilterID_418dc5b9812e UUID;
  p_Type_418dc5b9812e VARCHAR(10);
  p_ID_418dc5b9812e UUID;
BEGIN
  p_EntityID_418dc5b9812e := '5DB17493-CD0A-4633-80D4-D4A499662C76';
  p_RoleID_418dc5b9812e := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_418dc5b9812e := TRUE;
  p_CanRead_418dc5b9812e := TRUE;
  p_CanUpdate_418dc5b9812e := FALSE;
  p_CanDelete_418dc5b9812e := FALSE;
  p_Type_418dc5b9812e := 'Allow';
  p_ID_418dc5b9812e := 'DF4B433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_418dc5b9812e := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_418dc5b9812e THEN 0 ELSE 1 END LIMIT 1), p_RoleID_418dc5b9812e);
  p_ID_418dc5b9812e := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_418dc5b9812e AND "RoleID" = p_RoleID_418dc5b9812e ORDER BY CASE WHEN "ID" = p_ID_418dc5b9812e THEN 0 ELSE 1 END LIMIT 1), p_ID_418dc5b9812e);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_418dc5b9812e,
    'RoleID', p_RoleID_418dc5b9812e,
    'CanCreate', p_CanCreate_418dc5b9812e,
    'CanRead', p_CanRead_418dc5b9812e,
    'CanUpdate', p_CanUpdate_418dc5b9812e,
    'CanDelete', p_CanDelete_418dc5b9812e,
    'ReadRLSFilterID', p_ReadRLSFilterID_418dc5b9812e,
    'CreateRLSFilterID', p_CreateRLSFilterID_418dc5b9812e,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_418dc5b9812e,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_418dc5b9812e,
    'Type', p_Type_418dc5b9812e,
    'ID', p_ID_418dc5b9812e
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_418dc5b9812e, p_RoleID := p_RoleID_418dc5b9812e, p_CanCreate := p_CanCreate_418dc5b9812e, p_CanRead := p_CanRead_418dc5b9812e, p_CanUpdate := p_CanUpdate_418dc5b9812e, p_CanDelete := p_CanDelete_418dc5b9812e, p_ReadRLSFilterID := p_ReadRLSFilterID_418dc5b9812e, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_418dc5b9812e, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_418dc5b9812e, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_418dc5b9812e, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_418dc5b9812e, p_ID := p_ID_418dc5b9812e);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_3feecb359bc8 UUID;
  p_RoleID_3feecb359bc8 UUID;
  p_CanCreate_3feecb359bc8 BOOLEAN;
  p_CanRead_3feecb359bc8 BOOLEAN;
  p_CanUpdate_3feecb359bc8 BOOLEAN;
  p_CanDelete_3feecb359bc8 BOOLEAN;
  p_ReadRLSFilterID_3feecb359bc8 UUID;
  p_CreateRLSFilterID_3feecb359bc8 UUID;
  p_UpdateRLSFilterID_3feecb359bc8 UUID;
  p_DeleteRLSFilterID_3feecb359bc8 UUID;
  p_Type_3feecb359bc8 VARCHAR(10);
  p_ID_3feecb359bc8 UUID;
BEGIN
  p_EntityID_3feecb359bc8 := '559054C2-8F03-4A66-B4FD-70DE5948ACE2';
  p_RoleID_3feecb359bc8 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_3feecb359bc8 := TRUE;
  p_CanRead_3feecb359bc8 := TRUE;
  p_CanUpdate_3feecb359bc8 := FALSE;
  p_CanDelete_3feecb359bc8 := FALSE;
  p_Type_3feecb359bc8 := 'Allow';
  p_ID_3feecb359bc8 := '6F4B433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_3feecb359bc8 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_3feecb359bc8 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_3feecb359bc8);
  p_ID_3feecb359bc8 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_3feecb359bc8 AND "RoleID" = p_RoleID_3feecb359bc8 ORDER BY CASE WHEN "ID" = p_ID_3feecb359bc8 THEN 0 ELSE 1 END LIMIT 1), p_ID_3feecb359bc8);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_3feecb359bc8,
    'RoleID', p_RoleID_3feecb359bc8,
    'CanCreate', p_CanCreate_3feecb359bc8,
    'CanRead', p_CanRead_3feecb359bc8,
    'CanUpdate', p_CanUpdate_3feecb359bc8,
    'CanDelete', p_CanDelete_3feecb359bc8,
    'ReadRLSFilterID', p_ReadRLSFilterID_3feecb359bc8,
    'CreateRLSFilterID', p_CreateRLSFilterID_3feecb359bc8,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_3feecb359bc8,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_3feecb359bc8,
    'Type', p_Type_3feecb359bc8,
    'ID', p_ID_3feecb359bc8
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_3feecb359bc8, p_RoleID := p_RoleID_3feecb359bc8, p_CanCreate := p_CanCreate_3feecb359bc8, p_CanRead := p_CanRead_3feecb359bc8, p_CanUpdate := p_CanUpdate_3feecb359bc8, p_CanDelete := p_CanDelete_3feecb359bc8, p_ReadRLSFilterID := p_ReadRLSFilterID_3feecb359bc8, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_3feecb359bc8, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_3feecb359bc8, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_3feecb359bc8, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_3feecb359bc8, p_ID := p_ID_3feecb359bc8);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_6d34d3c2e364 UUID;
  p_RoleID_6d34d3c2e364 UUID;
  p_CanCreate_6d34d3c2e364 BOOLEAN;
  p_CanRead_6d34d3c2e364 BOOLEAN;
  p_CanUpdate_6d34d3c2e364 BOOLEAN;
  p_CanDelete_6d34d3c2e364 BOOLEAN;
  p_ReadRLSFilterID_6d34d3c2e364 UUID;
  p_CreateRLSFilterID_6d34d3c2e364 UUID;
  p_UpdateRLSFilterID_6d34d3c2e364 UUID;
  p_DeleteRLSFilterID_6d34d3c2e364 UUID;
  p_Type_6d34d3c2e364 VARCHAR(10);
  p_ID_6d34d3c2e364 UUID;
BEGIN
  p_EntityID_6d34d3c2e364 := '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF';
  p_RoleID_6d34d3c2e364 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_6d34d3c2e364 := TRUE;
  p_CanRead_6d34d3c2e364 := TRUE;
  p_CanUpdate_6d34d3c2e364 := FALSE;
  p_CanDelete_6d34d3c2e364 := FALSE;
  p_Type_6d34d3c2e364 := 'Allow';
  p_ID_6d34d3c2e364 := '544D433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_6d34d3c2e364 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_6d34d3c2e364 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_6d34d3c2e364);
  p_ID_6d34d3c2e364 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_6d34d3c2e364 AND "RoleID" = p_RoleID_6d34d3c2e364 ORDER BY CASE WHEN "ID" = p_ID_6d34d3c2e364 THEN 0 ELSE 1 END LIMIT 1), p_ID_6d34d3c2e364);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_6d34d3c2e364,
    'RoleID', p_RoleID_6d34d3c2e364,
    'CanCreate', p_CanCreate_6d34d3c2e364,
    'CanRead', p_CanRead_6d34d3c2e364,
    'CanUpdate', p_CanUpdate_6d34d3c2e364,
    'CanDelete', p_CanDelete_6d34d3c2e364,
    'ReadRLSFilterID', p_ReadRLSFilterID_6d34d3c2e364,
    'CreateRLSFilterID', p_CreateRLSFilterID_6d34d3c2e364,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_6d34d3c2e364,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_6d34d3c2e364,
    'Type', p_Type_6d34d3c2e364,
    'ID', p_ID_6d34d3c2e364
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_6d34d3c2e364, p_RoleID := p_RoleID_6d34d3c2e364, p_CanCreate := p_CanCreate_6d34d3c2e364, p_CanRead := p_CanRead_6d34d3c2e364, p_CanUpdate := p_CanUpdate_6d34d3c2e364, p_CanDelete := p_CanDelete_6d34d3c2e364, p_ReadRLSFilterID := p_ReadRLSFilterID_6d34d3c2e364, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_6d34d3c2e364, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_6d34d3c2e364, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_6d34d3c2e364, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_6d34d3c2e364, p_ID := p_ID_6d34d3c2e364);
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_EntityID_800c270fd0a6 UUID;
  p_RoleID_800c270fd0a6 UUID;
  p_CanCreate_800c270fd0a6 BOOLEAN;
  p_CanRead_800c270fd0a6 BOOLEAN;
  p_CanUpdate_800c270fd0a6 BOOLEAN;
  p_CanDelete_800c270fd0a6 BOOLEAN;
  p_ReadRLSFilterID_800c270fd0a6 UUID;
  p_CreateRLSFilterID_800c270fd0a6 UUID;
  p_UpdateRLSFilterID_800c270fd0a6 UUID;
  p_DeleteRLSFilterID_800c270fd0a6 UUID;
  p_Type_800c270fd0a6 VARCHAR(10);
  p_ID_800c270fd0a6 UUID;
BEGIN
  p_EntityID_800c270fd0a6 := '6615EF77-83F1-49F1-B717-80EC31F77486';
  p_RoleID_800c270fd0a6 := 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_CanCreate_800c270fd0a6 := TRUE;
  p_CanRead_800c270fd0a6 := TRUE;
  p_CanUpdate_800c270fd0a6 := FALSE;
  p_CanDelete_800c270fd0a6 := FALSE;
  p_Type_800c270fd0a6 := 'Allow';
  p_ID_800c270fd0a6 := 'A34C433E-F36B-1410-83C7-00AE8E98D1D8';
  p_RoleID_800c270fd0a6 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Role" WHERE "Name" = 'UI' ORDER BY CASE WHEN "ID" = p_RoleID_800c270fd0a6 THEN 0 ELSE 1 END LIMIT 1), p_RoleID_800c270fd0a6);
  p_ID_800c270fd0a6 := COALESCE((SELECT "ID" FROM "${mjSchema}"."EntityPermission" WHERE "EntityID" = p_EntityID_800c270fd0a6 AND "RoleID" = p_RoleID_800c270fd0a6 ORDER BY CASE WHEN "ID" = p_ID_800c270fd0a6 THEN 0 ELSE 1 END LIMIT 1), p_ID_800c270fd0a6);
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
       AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
  ) THEN
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
    'EntityID', p_EntityID_800c270fd0a6,
    'RoleID', p_RoleID_800c270fd0a6,
    'CanCreate', p_CanCreate_800c270fd0a6,
    'CanRead', p_CanRead_800c270fd0a6,
    'CanUpdate', p_CanUpdate_800c270fd0a6,
    'CanDelete', p_CanDelete_800c270fd0a6,
    'ReadRLSFilterID', p_ReadRLSFilterID_800c270fd0a6,
    'CreateRLSFilterID', p_CreateRLSFilterID_800c270fd0a6,
    'UpdateRLSFilterID', p_UpdateRLSFilterID_800c270fd0a6,
    'DeleteRLSFilterID', p_DeleteRLSFilterID_800c270fd0a6,
    'Type', p_Type_800c270fd0a6,
    'ID', p_ID_800c270fd0a6
  ));
  ELSE
    PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_EntityID := p_EntityID_800c270fd0a6, p_RoleID := p_RoleID_800c270fd0a6, p_CanCreate := p_CanCreate_800c270fd0a6, p_CanRead := p_CanRead_800c270fd0a6, p_CanUpdate := p_CanUpdate_800c270fd0a6, p_CanDelete := p_CanDelete_800c270fd0a6, p_ReadRLSFilterID := p_ReadRLSFilterID_800c270fd0a6, p_ReadRLSFilterID_Clear := TRUE, p_CreateRLSFilterID := p_CreateRLSFilterID_800c270fd0a6, p_CreateRLSFilterID_Clear := TRUE, p_UpdateRLSFilterID := p_UpdateRLSFilterID_800c270fd0a6, p_UpdateRLSFilterID_Clear := TRUE, p_DeleteRLSFilterID := p_DeleteRLSFilterID_800c270fd0a6, p_DeleteRLSFilterID_Clear := TRUE, p_Type := p_Type_800c270fd0a6, p_ID := p_ID_800c270fd0a6);
  END IF;
END $mj$;

-- Save MJ: Credential Types (core SP call only)
DO $mj$
DECLARE
  p_ID_8dbb52b17e6a UUID;
  p_Name_8dbb52b17e6a VARCHAR(100);
  p_Description_8dbb52b17e6a TEXT;
  p_Category_8dbb52b17e6a VARCHAR(50);
  p_FieldSchema_8dbb52b17e6a TEXT;
  p_IconClass_8dbb52b17e6a VARCHAR(100);
  p_ValidationEndpoint_8dbb52b17e6a VARCHAR(500);
BEGIN
  p_ID_8dbb52b17e6a := '0c04ad35-b075-4285-8255-a8b10e87d1b6';
  p_Name_8dbb52b17e6a := 'Teams Channel Webhook';
  p_Description_8dbb52b17e6a := 'Webhook URL for posting to a Microsoft Teams channel, from an Office 365 connector or a Power Automate Workflows ''post to a channel when a webhook request is received'' flow. Used by the Post Task Assignment to Teams action; name the credential after the task type''s Code.';
  p_Category_8dbb52b17e6a := 'Communication';
  p_FieldSchema_8dbb52b17e6a := '{"$schema":"http://json-schema.org/draft-07/schema#","type":"object","properties":{"webhookUrl":{"type":"string","title":"Webhook URL","description":"The channel''s webhook URL. It carries a signature that grants posting rights.","format":"uri","isSecret":true,"order":0},"explorerUrl":{"type":"string","title":"Explorer URL","description":"Base URL of MJ Explorer for this environment, used to link the card to the task. Leave empty to post without a link.","format":"uri","isSecret":false,"order":1}},"required":["webhookUrl"]}';
  p_IconClass_8dbb52b17e6a := 'fa-solid fa-comments';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."CredentialType" WHERE "ID" = p_ID_8dbb52b17e6a OR "Name" = p_Name_8dbb52b17e6a) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateCredentialType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateCredentialType"(p_data := jsonb_build_object(
      'ID', p_ID_8dbb52b17e6a,
      'Name', p_Name_8dbb52b17e6a,
      'Description', p_Description_8dbb52b17e6a,
      'Category', p_Category_8dbb52b17e6a,
      'FieldSchema', p_FieldSchema_8dbb52b17e6a,
      'IconClass', p_IconClass_8dbb52b17e6a,
      'ValidationEndpoint', p_ValidationEndpoint_8dbb52b17e6a
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateCredentialType"(p_ID := p_ID_8dbb52b17e6a, p_Name := p_Name_8dbb52b17e6a, p_Description := p_Description_8dbb52b17e6a, p_Category := p_Category_8dbb52b17e6a, p_FieldSchema := p_FieldSchema_8dbb52b17e6a, p_IconClass := p_IconClass_8dbb52b17e6a, p_ValidationEndpoint := p_ValidationEndpoint_8dbb52b17e6a, p_ValidationEndpoint_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Categories (core SP call only)
DO $mj$
DECLARE
  p_ID_fa64fc9ba4ab UUID;
  p_Name_fa64fc9ba4ab VARCHAR(255);
  p_Description_fa64fc9ba4ab TEXT;
  p_ParentID_fa64fc9ba4ab UUID;
  p_Status_fa64fc9ba4ab VARCHAR(20);
BEGIN
  p_ID_fa64fc9ba4ab := 'af554e32-1a22-47e2-ade4-a6dafec734fc';
  p_Name_fa64fc9ba4ab := 'Tasks';
  p_Description_fa64fc9ba4ab := 'Actions provided by BizApps Tasks, such as task type hooks that notify assignees outside the app.';
  p_Status_fa64fc9ba4ab := 'Active';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionCategory" WHERE "ID" = p_ID_fa64fc9ba4ab OR ("Name" = p_Name_fa64fc9ba4ab AND "ParentID" IS NULL)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionCategory'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionCategory"(p_data := jsonb_build_object(
      'ID', p_ID_fa64fc9ba4ab,
      'Name', p_Name_fa64fc9ba4ab,
      'Description', p_Description_fa64fc9ba4ab,
      'ParentID', p_ParentID_fa64fc9ba4ab,
      'Status', p_Status_fa64fc9ba4ab
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionCategory"(p_ID := p_ID_fa64fc9ba4ab, p_Name := p_Name_fa64fc9ba4ab, p_Description := p_Description_fa64fc9ba4ab, p_ParentID := p_ParentID_fa64fc9ba4ab, p_ParentID_Clear := TRUE, p_Status := p_Status_fa64fc9ba4ab);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Actions (core SP call only)
DO $mj$
DECLARE
  p_ID_5993e39a2ca8 UUID;
  p_CategoryID_5993e39a2ca8 UUID;
  p_Name_5993e39a2ca8 VARCHAR(425);
  p_Description_5993e39a2ca8 TEXT;
  p_Type_5993e39a2ca8 VARCHAR(20);
  p_UserPrompt_5993e39a2ca8 TEXT;
  p_UserComments_5993e39a2ca8 TEXT;
  p_Code_5993e39a2ca8 TEXT;
  p_CodeComments_5993e39a2ca8 TEXT;
  p_CodeApprovalStatus_5993e39a2ca8 VARCHAR(20);
  p_CodeApprovalComments_5993e39a2ca8 TEXT;
  p_CodeApprovedByUserID_5993e39a2ca8 UUID;
  p_CodeApprovedAt_5993e39a2ca8 TIMESTAMPTZ;
  p_CodeLocked_5993e39a2ca8 BOOLEAN;
  p_ForceCodeGeneration_5993e39a2ca8 BOOLEAN;
  p_RetentionPeriod_5993e39a2ca8 INTEGER;
  p_Status_5993e39a2ca8 VARCHAR(20);
  p_DriverClass_5993e39a2ca8 VARCHAR(255);
  p_ParentID_5993e39a2ca8 UUID;
  p_IconClass_5993e39a2ca8 VARCHAR(100);
  p_DefaultCompactPromptID_5993e39a2ca8 UUID;
  p_Config_5993e39a2ca8 TEXT;
  p_RuntimeActionConfiguration_5993e39a2ca8 TEXT;
  p_MaxExecutionTimeMS_5993e39a2ca8 INTEGER;
  p_CreatedByAgentID_5993e39a2ca8 UUID;
BEGIN
  p_ID_5993e39a2ca8 := '1d6adfbd-d936-4014-9c3e-c1bbf6ed9b96';
  p_CategoryID_5993e39a2ca8 := 'AF554E32-1A22-47E2-ADE4-A6DAFEC734FC';
  p_Name_5993e39a2ca8 := 'Post Task Assignment to Teams';
  p_Description_5993e39a2ca8 := 'Posts a card naming a newly assigned task and its assignee to a Microsoft Teams channel. Set it as a Task Type''s OnAssign action. The channel''s webhook URL comes from a ''Teams Channel Webhook'' credential: the one named in CredentialName, else the one named after the task type''s Code, else the credential type''s default. Accepts Office 365 connector and Power Automate Workflows webhook URLs.';
  p_Type_5993e39a2ca8 := 'Custom';
  p_UserPrompt_5993e39a2ca8 := 'Post a task assignment to a Teams channel.';
  p_CodeApprovalStatus_5993e39a2ca8 := 'Approved';
  p_CodeLocked_5993e39a2ca8 := FALSE;
  p_ForceCodeGeneration_5993e39a2ca8 := FALSE;
  p_Status_5993e39a2ca8 := 'Active';
  p_DriverClass_5993e39a2ca8 := 'Tasks.PostAssignmentToTeams';
  p_IconClass_5993e39a2ca8 := 'fa-solid fa-comments';
  p_CategoryID_5993e39a2ca8 := COALESCE((SELECT "ID" FROM "${mjSchema}"."ActionCategory" WHERE "Name" = 'Tasks' AND "ParentID" IS NULL ORDER BY CASE WHEN "ID" = p_CategoryID_5993e39a2ca8 THEN 0 ELSE 1 END LIMIT 1), p_CategoryID_5993e39a2ca8);
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."Action" WHERE "ID" = p_ID_5993e39a2ca8 OR "Name" = p_Name_5993e39a2ca8) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateAction'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateAction"(p_data := jsonb_build_object(
      'ID', p_ID_5993e39a2ca8,
      'CategoryID', p_CategoryID_5993e39a2ca8,
      'Name', p_Name_5993e39a2ca8,
      'Description', p_Description_5993e39a2ca8,
      'Type', p_Type_5993e39a2ca8,
      'UserPrompt', p_UserPrompt_5993e39a2ca8,
      'UserComments', p_UserComments_5993e39a2ca8,
      'Code', p_Code_5993e39a2ca8,
      'CodeComments', p_CodeComments_5993e39a2ca8,
      'CodeApprovalStatus', p_CodeApprovalStatus_5993e39a2ca8,
      'CodeApprovalComments', p_CodeApprovalComments_5993e39a2ca8,
      'CodeApprovedByUserID', p_CodeApprovedByUserID_5993e39a2ca8,
      'CodeApprovedAt', p_CodeApprovedAt_5993e39a2ca8,
      'CodeLocked', p_CodeLocked_5993e39a2ca8,
      'ForceCodeGeneration', p_ForceCodeGeneration_5993e39a2ca8,
      'RetentionPeriod', p_RetentionPeriod_5993e39a2ca8,
      'Status', p_Status_5993e39a2ca8,
      'DriverClass', p_DriverClass_5993e39a2ca8,
      'ParentID', p_ParentID_5993e39a2ca8,
      'IconClass', p_IconClass_5993e39a2ca8,
      'DefaultCompactPromptID', p_DefaultCompactPromptID_5993e39a2ca8,
      'Config', p_Config_5993e39a2ca8,
      'RuntimeActionConfiguration', p_RuntimeActionConfiguration_5993e39a2ca8,
      'MaxExecutionTimeMS', p_MaxExecutionTimeMS_5993e39a2ca8,
      'CreatedByAgentID', p_CreatedByAgentID_5993e39a2ca8
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateAction"(p_ID := p_ID_5993e39a2ca8, p_CategoryID := p_CategoryID_5993e39a2ca8, p_Name := p_Name_5993e39a2ca8, p_Description := p_Description_5993e39a2ca8, p_Type := p_Type_5993e39a2ca8, p_UserPrompt := p_UserPrompt_5993e39a2ca8, p_UserComments := p_UserComments_5993e39a2ca8, p_UserComments_Clear := TRUE, p_Code := p_Code_5993e39a2ca8, p_Code_Clear := TRUE, p_CodeComments := p_CodeComments_5993e39a2ca8, p_CodeComments_Clear := TRUE, p_CodeApprovalStatus := p_CodeApprovalStatus_5993e39a2ca8, p_CodeApprovalComments := p_CodeApprovalComments_5993e39a2ca8, p_CodeApprovalComments_Clear := TRUE, p_CodeApprovedByUserID := p_CodeApprovedByUserID_5993e39a2ca8, p_CodeApprovedByUserID_Clear := TRUE, p_CodeApprovedAt := p_CodeApprovedAt_5993e39a2ca8, p_CodeApprovedAt_Clear := TRUE, p_CodeLocked := p_CodeLocked_5993e39a2ca8, p_ForceCodeGeneration := p_ForceCodeGeneration_5993e39a2ca8, p_RetentionPeriod := p_RetentionPeriod_5993e39a2ca8, p_RetentionPeriod_Clear := TRUE, p_Status := p_Status_5993e39a2ca8, p_DriverClass := p_DriverClass_5993e39a2ca8, p_ParentID := p_ParentID_5993e39a2ca8, p_ParentID_Clear := TRUE, p_IconClass := p_IconClass_5993e39a2ca8, p_DefaultCompactPromptID := p_DefaultCompactPromptID_5993e39a2ca8, p_DefaultCompactPromptID_Clear := TRUE, p_Config := p_Config_5993e39a2ca8, p_Config_Clear := TRUE, p_RuntimeActionConfiguration := p_RuntimeActionConfiguration_5993e39a2ca8, p_RuntimeActionConfiguration_Clear := TRUE, p_MaxExecutionTimeMS := p_MaxExecutionTimeMS_5993e39a2ca8, p_MaxExecutionTimeMS_Clear := TRUE, p_CreatedByAgentID := p_CreatedByAgentID_5993e39a2ca8, p_CreatedByAgentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_b1a5f5a77a6c UUID;
  p_ActionID_b1a5f5a77a6c UUID;
  p_Name_b1a5f5a77a6c VARCHAR(255);
  p_DefaultValue_b1a5f5a77a6c TEXT;
  p_Type_b1a5f5a77a6c CHAR(10);
  p_ValueType_b1a5f5a77a6c VARCHAR(30);
  p_IsArray_b1a5f5a77a6c BOOLEAN;
  p_Description_b1a5f5a77a6c TEXT;
  p_IsRequired_b1a5f5a77a6c BOOLEAN;
  p_MediaModality_b1a5f5a77a6c VARCHAR(20);
  p_LogValue_b1a5f5a77a6c BOOLEAN;
BEGIN
  p_ID_b1a5f5a77a6c := '7f061431-6e3d-41da-b223-35985cb60abb';
  p_ActionID_b1a5f5a77a6c := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_b1a5f5a77a6c := 'TaskID';
  p_Type_b1a5f5a77a6c := 'Input';
  p_ValueType_b1a5f5a77a6c := 'Scalar';
  p_IsArray_b1a5f5a77a6c := FALSE;
  p_Description_b1a5f5a77a6c := 'ID of the assigned task. Passed by the OnAssign hook.';
  p_IsRequired_b1a5f5a77a6c := TRUE;
  p_LogValue_b1a5f5a77a6c := TRUE;
  p_ActionID_b1a5f5a77a6c := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_b1a5f5a77a6c THEN 0 ELSE 1 END LIMIT 1), p_ActionID_b1a5f5a77a6c);
  IF p_ActionID_b1a5f5a77a6c IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_b1a5f5a77a6c
                  OR ("Name" = p_Name_b1a5f5a77a6c AND "ActionID" = p_ActionID_b1a5f5a77a6c)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_b1a5f5a77a6c,
      'ActionID', p_ActionID_b1a5f5a77a6c,
      'Name', p_Name_b1a5f5a77a6c,
      'DefaultValue', p_DefaultValue_b1a5f5a77a6c,
      'Type', p_Type_b1a5f5a77a6c,
      'ValueType', p_ValueType_b1a5f5a77a6c,
      'IsArray', p_IsArray_b1a5f5a77a6c,
      'Description', p_Description_b1a5f5a77a6c,
      'IsRequired', p_IsRequired_b1a5f5a77a6c,
      'MediaModality', p_MediaModality_b1a5f5a77a6c,
      'LogValue', p_LogValue_b1a5f5a77a6c
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_b1a5f5a77a6c, p_ActionID := p_ActionID_b1a5f5a77a6c, p_Name := p_Name_b1a5f5a77a6c, p_DefaultValue := p_DefaultValue_b1a5f5a77a6c, p_DefaultValue_Clear := TRUE, p_Type := p_Type_b1a5f5a77a6c, p_ValueType := p_ValueType_b1a5f5a77a6c, p_IsArray := p_IsArray_b1a5f5a77a6c, p_Description := p_Description_b1a5f5a77a6c, p_IsRequired := p_IsRequired_b1a5f5a77a6c, p_MediaModality := p_MediaModality_b1a5f5a77a6c, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_b1a5f5a77a6c);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_6fd1ca4de6e9 UUID;
  p_ActionID_6fd1ca4de6e9 UUID;
  p_Name_6fd1ca4de6e9 VARCHAR(255);
  p_DefaultValue_6fd1ca4de6e9 TEXT;
  p_Type_6fd1ca4de6e9 CHAR(10);
  p_ValueType_6fd1ca4de6e9 VARCHAR(30);
  p_IsArray_6fd1ca4de6e9 BOOLEAN;
  p_Description_6fd1ca4de6e9 TEXT;
  p_IsRequired_6fd1ca4de6e9 BOOLEAN;
  p_MediaModality_6fd1ca4de6e9 VARCHAR(20);
  p_LogValue_6fd1ca4de6e9 BOOLEAN;
BEGIN
  p_ID_6fd1ca4de6e9 := 'f8ad7cd5-60bf-4139-ac79-0dbc0b2c4c09';
  p_ActionID_6fd1ca4de6e9 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_6fd1ca4de6e9 := 'TaskName';
  p_Type_6fd1ca4de6e9 := 'Input';
  p_ValueType_6fd1ca4de6e9 := 'Scalar';
  p_IsArray_6fd1ca4de6e9 := FALSE;
  p_Description_6fd1ca4de6e9 := 'Name of the assigned task. Passed by the OnAssign hook.';
  p_IsRequired_6fd1ca4de6e9 := TRUE;
  p_LogValue_6fd1ca4de6e9 := TRUE;
  p_ActionID_6fd1ca4de6e9 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_6fd1ca4de6e9 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_6fd1ca4de6e9);
  IF p_ActionID_6fd1ca4de6e9 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_6fd1ca4de6e9
                  OR ("Name" = p_Name_6fd1ca4de6e9 AND "ActionID" = p_ActionID_6fd1ca4de6e9)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_6fd1ca4de6e9,
      'ActionID', p_ActionID_6fd1ca4de6e9,
      'Name', p_Name_6fd1ca4de6e9,
      'DefaultValue', p_DefaultValue_6fd1ca4de6e9,
      'Type', p_Type_6fd1ca4de6e9,
      'ValueType', p_ValueType_6fd1ca4de6e9,
      'IsArray', p_IsArray_6fd1ca4de6e9,
      'Description', p_Description_6fd1ca4de6e9,
      'IsRequired', p_IsRequired_6fd1ca4de6e9,
      'MediaModality', p_MediaModality_6fd1ca4de6e9,
      'LogValue', p_LogValue_6fd1ca4de6e9
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_6fd1ca4de6e9, p_ActionID := p_ActionID_6fd1ca4de6e9, p_Name := p_Name_6fd1ca4de6e9, p_DefaultValue := p_DefaultValue_6fd1ca4de6e9, p_DefaultValue_Clear := TRUE, p_Type := p_Type_6fd1ca4de6e9, p_ValueType := p_ValueType_6fd1ca4de6e9, p_IsArray := p_IsArray_6fd1ca4de6e9, p_Description := p_Description_6fd1ca4de6e9, p_IsRequired := p_IsRequired_6fd1ca4de6e9, p_MediaModality := p_MediaModality_6fd1ca4de6e9, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_6fd1ca4de6e9);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_cf3e8889a24b UUID;
  p_ActionID_cf3e8889a24b UUID;
  p_Name_cf3e8889a24b VARCHAR(255);
  p_DefaultValue_cf3e8889a24b TEXT;
  p_Type_cf3e8889a24b CHAR(10);
  p_ValueType_cf3e8889a24b VARCHAR(30);
  p_IsArray_cf3e8889a24b BOOLEAN;
  p_Description_cf3e8889a24b TEXT;
  p_IsRequired_cf3e8889a24b BOOLEAN;
  p_MediaModality_cf3e8889a24b VARCHAR(20);
  p_LogValue_cf3e8889a24b BOOLEAN;
BEGIN
  p_ID_cf3e8889a24b := 'faf9a711-c628-43f9-8a51-87e1dfff1589';
  p_ActionID_cf3e8889a24b := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_cf3e8889a24b := 'TaskTypeID';
  p_Type_cf3e8889a24b := 'Input';
  p_ValueType_cf3e8889a24b := 'Scalar';
  p_IsArray_cf3e8889a24b := FALSE;
  p_Description_cf3e8889a24b := 'ID of the task''s type, used to find the credential named after its Code. Passed by the OnAssign hook.';
  p_IsRequired_cf3e8889a24b := FALSE;
  p_LogValue_cf3e8889a24b := TRUE;
  p_ActionID_cf3e8889a24b := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_cf3e8889a24b THEN 0 ELSE 1 END LIMIT 1), p_ActionID_cf3e8889a24b);
  IF p_ActionID_cf3e8889a24b IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_cf3e8889a24b
                  OR ("Name" = p_Name_cf3e8889a24b AND "ActionID" = p_ActionID_cf3e8889a24b)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_cf3e8889a24b,
      'ActionID', p_ActionID_cf3e8889a24b,
      'Name', p_Name_cf3e8889a24b,
      'DefaultValue', p_DefaultValue_cf3e8889a24b,
      'Type', p_Type_cf3e8889a24b,
      'ValueType', p_ValueType_cf3e8889a24b,
      'IsArray', p_IsArray_cf3e8889a24b,
      'Description', p_Description_cf3e8889a24b,
      'IsRequired', p_IsRequired_cf3e8889a24b,
      'MediaModality', p_MediaModality_cf3e8889a24b,
      'LogValue', p_LogValue_cf3e8889a24b
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_cf3e8889a24b, p_ActionID := p_ActionID_cf3e8889a24b, p_Name := p_Name_cf3e8889a24b, p_DefaultValue := p_DefaultValue_cf3e8889a24b, p_DefaultValue_Clear := TRUE, p_Type := p_Type_cf3e8889a24b, p_ValueType := p_ValueType_cf3e8889a24b, p_IsArray := p_IsArray_cf3e8889a24b, p_Description := p_Description_cf3e8889a24b, p_IsRequired := p_IsRequired_cf3e8889a24b, p_MediaModality := p_MediaModality_cf3e8889a24b, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_cf3e8889a24b);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_67190301cd92 UUID;
  p_ActionID_67190301cd92 UUID;
  p_Name_67190301cd92 VARCHAR(255);
  p_DefaultValue_67190301cd92 TEXT;
  p_Type_67190301cd92 CHAR(10);
  p_ValueType_67190301cd92 VARCHAR(30);
  p_IsArray_67190301cd92 BOOLEAN;
  p_Description_67190301cd92 TEXT;
  p_IsRequired_67190301cd92 BOOLEAN;
  p_MediaModality_67190301cd92 VARCHAR(20);
  p_LogValue_67190301cd92 BOOLEAN;
BEGIN
  p_ID_67190301cd92 := '6fdb1756-8f68-46f3-888b-4af5d857db62';
  p_ActionID_67190301cd92 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_67190301cd92 := 'AssigneePersonID';
  p_Type_67190301cd92 := 'Input';
  p_ValueType_67190301cd92 := 'Scalar';
  p_IsArray_67190301cd92 := FALSE;
  p_Description_67190301cd92 := 'People record ID of the assignee. Passed by the OnAssign hook.';
  p_IsRequired_67190301cd92 := FALSE;
  p_LogValue_67190301cd92 := TRUE;
  p_ActionID_67190301cd92 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_67190301cd92 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_67190301cd92);
  IF p_ActionID_67190301cd92 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_67190301cd92
                  OR ("Name" = p_Name_67190301cd92 AND "ActionID" = p_ActionID_67190301cd92)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_67190301cd92,
      'ActionID', p_ActionID_67190301cd92,
      'Name', p_Name_67190301cd92,
      'DefaultValue', p_DefaultValue_67190301cd92,
      'Type', p_Type_67190301cd92,
      'ValueType', p_ValueType_67190301cd92,
      'IsArray', p_IsArray_67190301cd92,
      'Description', p_Description_67190301cd92,
      'IsRequired', p_IsRequired_67190301cd92,
      'MediaModality', p_MediaModality_67190301cd92,
      'LogValue', p_LogValue_67190301cd92
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_67190301cd92, p_ActionID := p_ActionID_67190301cd92, p_Name := p_Name_67190301cd92, p_DefaultValue := p_DefaultValue_67190301cd92, p_DefaultValue_Clear := TRUE, p_Type := p_Type_67190301cd92, p_ValueType := p_ValueType_67190301cd92, p_IsArray := p_IsArray_67190301cd92, p_Description := p_Description_67190301cd92, p_IsRequired := p_IsRequired_67190301cd92, p_MediaModality := p_MediaModality_67190301cd92, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_67190301cd92);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_2c42ca3dc97c UUID;
  p_ActionID_2c42ca3dc97c UUID;
  p_Name_2c42ca3dc97c VARCHAR(255);
  p_DefaultValue_2c42ca3dc97c TEXT;
  p_Type_2c42ca3dc97c CHAR(10);
  p_ValueType_2c42ca3dc97c VARCHAR(30);
  p_IsArray_2c42ca3dc97c BOOLEAN;
  p_Description_2c42ca3dc97c TEXT;
  p_IsRequired_2c42ca3dc97c BOOLEAN;
  p_MediaModality_2c42ca3dc97c VARCHAR(20);
  p_LogValue_2c42ca3dc97c BOOLEAN;
BEGIN
  p_ID_2c42ca3dc97c := '12b6149b-846d-4935-a09b-42d92e5e00fa';
  p_ActionID_2c42ca3dc97c := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_2c42ca3dc97c := 'AssigneeName';
  p_Type_2c42ca3dc97c := 'Input';
  p_ValueType_2c42ca3dc97c := 'Scalar';
  p_IsArray_2c42ca3dc97c := FALSE;
  p_Description_2c42ca3dc97c := 'Display name of the assignee, shown on the card. Passed by the OnAssign hook.';
  p_IsRequired_2c42ca3dc97c := FALSE;
  p_LogValue_2c42ca3dc97c := TRUE;
  p_ActionID_2c42ca3dc97c := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_2c42ca3dc97c THEN 0 ELSE 1 END LIMIT 1), p_ActionID_2c42ca3dc97c);
  IF p_ActionID_2c42ca3dc97c IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_2c42ca3dc97c
                  OR ("Name" = p_Name_2c42ca3dc97c AND "ActionID" = p_ActionID_2c42ca3dc97c)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_2c42ca3dc97c,
      'ActionID', p_ActionID_2c42ca3dc97c,
      'Name', p_Name_2c42ca3dc97c,
      'DefaultValue', p_DefaultValue_2c42ca3dc97c,
      'Type', p_Type_2c42ca3dc97c,
      'ValueType', p_ValueType_2c42ca3dc97c,
      'IsArray', p_IsArray_2c42ca3dc97c,
      'Description', p_Description_2c42ca3dc97c,
      'IsRequired', p_IsRequired_2c42ca3dc97c,
      'MediaModality', p_MediaModality_2c42ca3dc97c,
      'LogValue', p_LogValue_2c42ca3dc97c
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_2c42ca3dc97c, p_ActionID := p_ActionID_2c42ca3dc97c, p_Name := p_Name_2c42ca3dc97c, p_DefaultValue := p_DefaultValue_2c42ca3dc97c, p_DefaultValue_Clear := TRUE, p_Type := p_Type_2c42ca3dc97c, p_ValueType := p_ValueType_2c42ca3dc97c, p_IsArray := p_IsArray_2c42ca3dc97c, p_Description := p_Description_2c42ca3dc97c, p_IsRequired := p_IsRequired_2c42ca3dc97c, p_MediaModality := p_MediaModality_2c42ca3dc97c, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_2c42ca3dc97c);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_565da7c73b54 UUID;
  p_ActionID_565da7c73b54 UUID;
  p_Name_565da7c73b54 VARCHAR(255);
  p_DefaultValue_565da7c73b54 TEXT;
  p_Type_565da7c73b54 CHAR(10);
  p_ValueType_565da7c73b54 VARCHAR(30);
  p_IsArray_565da7c73b54 BOOLEAN;
  p_Description_565da7c73b54 TEXT;
  p_IsRequired_565da7c73b54 BOOLEAN;
  p_MediaModality_565da7c73b54 VARCHAR(20);
  p_LogValue_565da7c73b54 BOOLEAN;
BEGIN
  p_ID_565da7c73b54 := '46f29ed2-903d-463d-8152-cd8ab3799595';
  p_ActionID_565da7c73b54 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_565da7c73b54 := 'Status';
  p_Type_565da7c73b54 := 'Input';
  p_ValueType_565da7c73b54 := 'Scalar';
  p_IsArray_565da7c73b54 := FALSE;
  p_Description_565da7c73b54 := 'Status of the task. Passed by the OnAssign hook; not used.';
  p_IsRequired_565da7c73b54 := FALSE;
  p_LogValue_565da7c73b54 := TRUE;
  p_ActionID_565da7c73b54 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_565da7c73b54 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_565da7c73b54);
  IF p_ActionID_565da7c73b54 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_565da7c73b54
                  OR ("Name" = p_Name_565da7c73b54 AND "ActionID" = p_ActionID_565da7c73b54)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_565da7c73b54,
      'ActionID', p_ActionID_565da7c73b54,
      'Name', p_Name_565da7c73b54,
      'DefaultValue', p_DefaultValue_565da7c73b54,
      'Type', p_Type_565da7c73b54,
      'ValueType', p_ValueType_565da7c73b54,
      'IsArray', p_IsArray_565da7c73b54,
      'Description', p_Description_565da7c73b54,
      'IsRequired', p_IsRequired_565da7c73b54,
      'MediaModality', p_MediaModality_565da7c73b54,
      'LogValue', p_LogValue_565da7c73b54
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_565da7c73b54, p_ActionID := p_ActionID_565da7c73b54, p_Name := p_Name_565da7c73b54, p_DefaultValue := p_DefaultValue_565da7c73b54, p_DefaultValue_Clear := TRUE, p_Type := p_Type_565da7c73b54, p_ValueType := p_ValueType_565da7c73b54, p_IsArray := p_IsArray_565da7c73b54, p_Description := p_Description_565da7c73b54, p_IsRequired := p_IsRequired_565da7c73b54, p_MediaModality := p_MediaModality_565da7c73b54, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_565da7c73b54);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Params (core SP call only)
DO $mj$
DECLARE
  p_ID_1e8627eca203 UUID;
  p_ActionID_1e8627eca203 UUID;
  p_Name_1e8627eca203 VARCHAR(255);
  p_DefaultValue_1e8627eca203 TEXT;
  p_Type_1e8627eca203 CHAR(10);
  p_ValueType_1e8627eca203 VARCHAR(30);
  p_IsArray_1e8627eca203 BOOLEAN;
  p_Description_1e8627eca203 TEXT;
  p_IsRequired_1e8627eca203 BOOLEAN;
  p_MediaModality_1e8627eca203 VARCHAR(20);
  p_LogValue_1e8627eca203 BOOLEAN;
BEGIN
  p_ID_1e8627eca203 := '6186cba0-3584-4c0b-a424-fc97cc64a70c';
  p_ActionID_1e8627eca203 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_Name_1e8627eca203 := 'CredentialName';
  p_Type_1e8627eca203 := 'Input';
  p_ValueType_1e8627eca203 := 'Scalar';
  p_IsArray_1e8627eca203 := FALSE;
  p_Description_1e8627eca203 := 'Name of the ''Teams Channel Webhook'' credential to use. Optional; defaults to the task type''s Code.';
  p_IsRequired_1e8627eca203 := FALSE;
  p_LogValue_1e8627eca203 := TRUE;
  p_ActionID_1e8627eca203 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_1e8627eca203 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_1e8627eca203);
  IF p_ActionID_1e8627eca203 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionParam"
               WHERE "ID" = p_ID_1e8627eca203
                  OR ("Name" = p_Name_1e8627eca203 AND "ActionID" = p_ActionID_1e8627eca203)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionParam"(p_data := jsonb_build_object(
      'ID', p_ID_1e8627eca203,
      'ActionID', p_ActionID_1e8627eca203,
      'Name', p_Name_1e8627eca203,
      'DefaultValue', p_DefaultValue_1e8627eca203,
      'Type', p_Type_1e8627eca203,
      'ValueType', p_ValueType_1e8627eca203,
      'IsArray', p_IsArray_1e8627eca203,
      'Description', p_Description_1e8627eca203,
      'IsRequired', p_IsRequired_1e8627eca203,
      'MediaModality', p_MediaModality_1e8627eca203,
      'LogValue', p_LogValue_1e8627eca203
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionParam"(p_ID := p_ID_1e8627eca203, p_ActionID := p_ActionID_1e8627eca203, p_Name := p_Name_1e8627eca203, p_DefaultValue := p_DefaultValue_1e8627eca203, p_DefaultValue_Clear := TRUE, p_Type := p_Type_1e8627eca203, p_ValueType := p_ValueType_1e8627eca203, p_IsArray := p_IsArray_1e8627eca203, p_Description := p_Description_1e8627eca203, p_IsRequired := p_IsRequired_1e8627eca203, p_MediaModality := p_MediaModality_1e8627eca203, p_MediaModality_Clear := TRUE, p_LogValue := p_LogValue_1e8627eca203);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_240b05144597 UUID;
  p_ActionID_240b05144597 UUID;
  p_ResultCode_240b05144597 VARCHAR(255);
  p_IsSuccess_240b05144597 BOOLEAN;
  p_Description_240b05144597 TEXT;
BEGIN
  p_ID_240b05144597 := 'f504719c-f2bc-41bb-ba1a-8c2b769b705c';
  p_ActionID_240b05144597 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_240b05144597 := 'SUCCESS';
  p_IsSuccess_240b05144597 := TRUE;
  p_Description_240b05144597 := 'The card was posted.';
  p_ActionID_240b05144597 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_240b05144597 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_240b05144597);
  IF p_ActionID_240b05144597 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_240b05144597
                  OR ("ResultCode" = p_ResultCode_240b05144597 AND "ActionID" = p_ActionID_240b05144597)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_240b05144597,
      'ActionID', p_ActionID_240b05144597,
      'ResultCode', p_ResultCode_240b05144597,
      'IsSuccess', p_IsSuccess_240b05144597,
      'Description', p_Description_240b05144597
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_240b05144597, p_ActionID := p_ActionID_240b05144597, p_ResultCode := p_ResultCode_240b05144597, p_IsSuccess := p_IsSuccess_240b05144597, p_Description := p_Description_240b05144597);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_221f59b186b9 UUID;
  p_ActionID_221f59b186b9 UUID;
  p_ResultCode_221f59b186b9 VARCHAR(255);
  p_IsSuccess_221f59b186b9 BOOLEAN;
  p_Description_221f59b186b9 TEXT;
BEGIN
  p_ID_221f59b186b9 := '3c55ba77-4b14-4787-a798-d98bc5502af9';
  p_ActionID_221f59b186b9 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_221f59b186b9 := 'MISSING_TASK';
  p_IsSuccess_221f59b186b9 := FALSE;
  p_Description_221f59b186b9 := 'TaskID or TaskName was not supplied.';
  p_ActionID_221f59b186b9 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_221f59b186b9 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_221f59b186b9);
  IF p_ActionID_221f59b186b9 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_221f59b186b9
                  OR ("ResultCode" = p_ResultCode_221f59b186b9 AND "ActionID" = p_ActionID_221f59b186b9)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_221f59b186b9,
      'ActionID', p_ActionID_221f59b186b9,
      'ResultCode', p_ResultCode_221f59b186b9,
      'IsSuccess', p_IsSuccess_221f59b186b9,
      'Description', p_Description_221f59b186b9
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_221f59b186b9, p_ActionID := p_ActionID_221f59b186b9, p_ResultCode := p_ResultCode_221f59b186b9, p_IsSuccess := p_IsSuccess_221f59b186b9, p_Description := p_Description_221f59b186b9);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_84f93d29b96e UUID;
  p_ActionID_84f93d29b96e UUID;
  p_ResultCode_84f93d29b96e VARCHAR(255);
  p_IsSuccess_84f93d29b96e BOOLEAN;
  p_Description_84f93d29b96e TEXT;
BEGIN
  p_ID_84f93d29b96e := '04a8334e-1be9-4513-a743-5c30f04d8558';
  p_ActionID_84f93d29b96e := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_84f93d29b96e := 'INVALID_TASK_TYPE';
  p_IsSuccess_84f93d29b96e := FALSE;
  p_Description_84f93d29b96e := 'TaskTypeID was supplied but is not a valid ID.';
  p_ActionID_84f93d29b96e := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_84f93d29b96e THEN 0 ELSE 1 END LIMIT 1), p_ActionID_84f93d29b96e);
  IF p_ActionID_84f93d29b96e IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_84f93d29b96e
                  OR ("ResultCode" = p_ResultCode_84f93d29b96e AND "ActionID" = p_ActionID_84f93d29b96e)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_84f93d29b96e,
      'ActionID', p_ActionID_84f93d29b96e,
      'ResultCode', p_ResultCode_84f93d29b96e,
      'IsSuccess', p_IsSuccess_84f93d29b96e,
      'Description', p_Description_84f93d29b96e
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_84f93d29b96e, p_ActionID := p_ActionID_84f93d29b96e, p_ResultCode := p_ResultCode_84f93d29b96e, p_IsSuccess := p_IsSuccess_84f93d29b96e, p_Description := p_Description_84f93d29b96e);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_81f7b573ea54 UUID;
  p_ActionID_81f7b573ea54 UUID;
  p_ResultCode_81f7b573ea54 VARCHAR(255);
  p_IsSuccess_81f7b573ea54 BOOLEAN;
  p_Description_81f7b573ea54 TEXT;
BEGIN
  p_ID_81f7b573ea54 := '7401f330-7522-4176-8f6a-4e05a345e47d';
  p_ActionID_81f7b573ea54 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_81f7b573ea54 := 'MISSING_CREDENTIAL';
  p_IsSuccess_81f7b573ea54 := FALSE;
  p_Description_81f7b573ea54 := 'No ''Teams Channel Webhook'' credential matched and the type has no default.';
  p_ActionID_81f7b573ea54 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_81f7b573ea54 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_81f7b573ea54);
  IF p_ActionID_81f7b573ea54 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_81f7b573ea54
                  OR ("ResultCode" = p_ResultCode_81f7b573ea54 AND "ActionID" = p_ActionID_81f7b573ea54)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_81f7b573ea54,
      'ActionID', p_ActionID_81f7b573ea54,
      'ResultCode', p_ResultCode_81f7b573ea54,
      'IsSuccess', p_IsSuccess_81f7b573ea54,
      'Description', p_Description_81f7b573ea54
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_81f7b573ea54, p_ActionID := p_ActionID_81f7b573ea54, p_ResultCode := p_ResultCode_81f7b573ea54, p_IsSuccess := p_IsSuccess_81f7b573ea54, p_Description := p_Description_81f7b573ea54);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_600737dd4198 UUID;
  p_ActionID_600737dd4198 UUID;
  p_ResultCode_600737dd4198 VARCHAR(255);
  p_IsSuccess_600737dd4198 BOOLEAN;
  p_Description_600737dd4198 TEXT;
BEGIN
  p_ID_600737dd4198 := 'c5f3b00a-d541-4e43-8bff-f5622620aff0';
  p_ActionID_600737dd4198 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_600737dd4198 := 'INVALID_WEBHOOK_URL';
  p_IsSuccess_600737dd4198 := FALSE;
  p_Description_600737dd4198 := 'The credential''s webhookUrl is not an https Teams connector or Power Automate webhook URL.';
  p_ActionID_600737dd4198 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_600737dd4198 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_600737dd4198);
  IF p_ActionID_600737dd4198 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_600737dd4198
                  OR ("ResultCode" = p_ResultCode_600737dd4198 AND "ActionID" = p_ActionID_600737dd4198)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_600737dd4198,
      'ActionID', p_ActionID_600737dd4198,
      'ResultCode', p_ResultCode_600737dd4198,
      'IsSuccess', p_IsSuccess_600737dd4198,
      'Description', p_Description_600737dd4198
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_600737dd4198, p_ActionID := p_ActionID_600737dd4198, p_ResultCode := p_ResultCode_600737dd4198, p_IsSuccess := p_IsSuccess_600737dd4198, p_Description := p_Description_600737dd4198);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_5fa96b8b9ef7 UUID;
  p_ActionID_5fa96b8b9ef7 UUID;
  p_ResultCode_5fa96b8b9ef7 VARCHAR(255);
  p_IsSuccess_5fa96b8b9ef7 BOOLEAN;
  p_Description_5fa96b8b9ef7 TEXT;
BEGIN
  p_ID_5fa96b8b9ef7 := '5b724e06-f308-4ad6-abe7-fe68f6cf83f2';
  p_ActionID_5fa96b8b9ef7 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_5fa96b8b9ef7 := 'TEAMS_ERROR';
  p_IsSuccess_5fa96b8b9ef7 := FALSE;
  p_Description_5fa96b8b9ef7 := 'The webhook rejected the post or could not be reached.';
  p_ActionID_5fa96b8b9ef7 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_5fa96b8b9ef7 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_5fa96b8b9ef7);
  IF p_ActionID_5fa96b8b9ef7 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_5fa96b8b9ef7
                  OR ("ResultCode" = p_ResultCode_5fa96b8b9ef7 AND "ActionID" = p_ActionID_5fa96b8b9ef7)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_5fa96b8b9ef7,
      'ActionID', p_ActionID_5fa96b8b9ef7,
      'ResultCode', p_ResultCode_5fa96b8b9ef7,
      'IsSuccess', p_IsSuccess_5fa96b8b9ef7,
      'Description', p_Description_5fa96b8b9ef7
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_5fa96b8b9ef7, p_ActionID := p_ActionID_5fa96b8b9ef7, p_ResultCode := p_ResultCode_5fa96b8b9ef7, p_IsSuccess := p_IsSuccess_5fa96b8b9ef7, p_Description := p_Description_5fa96b8b9ef7);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Action Result Codes (core SP call only)
DO $mj$
DECLARE
  p_ID_c35d65636ff3 UUID;
  p_ActionID_c35d65636ff3 UUID;
  p_ResultCode_c35d65636ff3 VARCHAR(255);
  p_IsSuccess_c35d65636ff3 BOOLEAN;
  p_Description_c35d65636ff3 TEXT;
BEGIN
  p_ID_c35d65636ff3 := '8fdf4376-9c6c-4961-a4ff-93f3a62e49ec';
  p_ActionID_c35d65636ff3 := '1D6ADFBD-D936-4014-9C3E-C1BBF6ED9B96';
  p_ResultCode_c35d65636ff3 := 'ERROR';
  p_IsSuccess_c35d65636ff3 := FALSE;
  p_Description_c35d65636ff3 := 'No context user.';
  p_ActionID_c35d65636ff3 := COALESCE((SELECT "ID" FROM "${mjSchema}"."Action" WHERE "Name" = 'Post Task Assignment to Teams' ORDER BY CASE WHEN "ID" = p_ActionID_c35d65636ff3 THEN 0 ELSE 1 END LIMIT 1), p_ActionID_c35d65636ff3);
  IF p_ActionID_c35d65636ff3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ActionResultCode"
               WHERE "ID" = p_ID_c35d65636ff3
                  OR ("ResultCode" = p_ResultCode_c35d65636ff3 AND "ActionID" = p_ActionID_c35d65636ff3)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateActionResultCode'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_data := jsonb_build_object(
      'ID', p_ID_c35d65636ff3,
      'ActionID', p_ActionID_c35d65636ff3,
      'ResultCode', p_ResultCode_c35d65636ff3,
      'IsSuccess', p_IsSuccess_c35d65636ff3,
      'Description', p_Description_c35d65636ff3
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateActionResultCode"(p_ID := p_ID_c35d65636ff3, p_ActionID := p_ActionID_c35d65636ff3, p_ResultCode := p_ResultCode_c35d65636ff3, p_IsSuccess := p_IsSuccess_c35d65636ff3, p_Description := p_Description_c35d65636ff3);
    END IF;
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Task Types (core SP call only)
DO $mj$
DECLARE
  p_Name_91edab42108f VARCHAR(100);
  p_Description_91edab42108f TEXT;
  p_IconClass_91edab42108f VARCHAR(100);
  p_DefaultPriority_91edab42108f VARCHAR(20);
  p_OnAssignActionID_91edab42108f UUID;
  p_OnCompleteActionID_91edab42108f UUID;
  p_OnOverdueActionID_91edab42108f UUID;
  p_OnPercentChangeActionID_91edab42108f UUID;
  p_IsActive_91edab42108f BOOLEAN;
  p_OnRejectActionID_91edab42108f UUID;
  p_OnCancelActionID_91edab42108f UUID;
  p_Code_91edab42108f VARCHAR(50);
  p_OnCreateActionID_91edab42108f UUID;
  p_OnStatusChangeActionID_91edab42108f UUID;
  p_IsApproval_91edab42108f BOOLEAN;
  p_ID_91edab42108f UUID;
BEGIN
  p_Name_91edab42108f := 'Approval Request';
  p_Description_91edab42108f := 'An approval/decision workflow request routed to one or more approvers. Consumers wire OnReject/OnCancel/OnComplete actions to feed the decision back to the source record.';
  p_IconClass_91edab42108f := 'fa-solid fa-stamp';
  p_DefaultPriority_91edab42108f := 'High';
  p_IsActive_91edab42108f := TRUE;
  p_Code_91edab42108f := 'APPROVAL_REQUEST';
  p_IsApproval_91edab42108f := TRUE;
  p_ID_91edab42108f := '5961EDE5-B996-4083-BE48-64634B4D8D1C';
  -- Postgres tasks has no IsApproval column until its 1.2-1.7 migrations get Postgres counterparts;
  -- until then this update is skipped rather than failing the install.
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = '__mj_bizappstasks' AND table_name = 'TaskType' AND column_name = 'IsApproval') THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '__mj_BizAppsTasks' AND p.proname = 'spUpdateTaskType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM __mj_BizAppsTasks."spUpdateTaskType"(p_data := jsonb_build_object(
      'Name', p_Name_91edab42108f,
      'Description', p_Description_91edab42108f,
      'IconClass', p_IconClass_91edab42108f,
      'DefaultPriority', p_DefaultPriority_91edab42108f,
      'OnAssignActionID', p_OnAssignActionID_91edab42108f,
      'OnCompleteActionID', p_OnCompleteActionID_91edab42108f,
      'OnOverdueActionID', p_OnOverdueActionID_91edab42108f,
      'OnPercentChangeActionID', p_OnPercentChangeActionID_91edab42108f,
      'IsActive', p_IsActive_91edab42108f,
      'OnRejectActionID', p_OnRejectActionID_91edab42108f,
      'OnCancelActionID', p_OnCancelActionID_91edab42108f,
      'Code', p_Code_91edab42108f,
      'OnCreateActionID', p_OnCreateActionID_91edab42108f,
      'OnStatusChangeActionID', p_OnStatusChangeActionID_91edab42108f,
      'IsApproval', p_IsApproval_91edab42108f,
      'ID', p_ID_91edab42108f
    ));
    ELSE
      PERFORM __mj_BizAppsTasks."spUpdateTaskType"(p_Name := p_Name_91edab42108f, p_Description := p_Description_91edab42108f, p_IconClass := p_IconClass_91edab42108f, p_DefaultPriority := p_DefaultPriority_91edab42108f, p_OnAssignActionID := p_OnAssignActionID_91edab42108f, p_OnAssignActionID_Clear := TRUE, p_OnCompleteActionID := p_OnCompleteActionID_91edab42108f, p_OnCompleteActionID_Clear := TRUE, p_OnOverdueActionID := p_OnOverdueActionID_91edab42108f, p_OnOverdueActionID_Clear := TRUE, p_OnPercentChangeActionID := p_OnPercentChangeActionID_91edab42108f, p_OnPercentChangeActionID_Clear := TRUE, p_IsActive := p_IsActive_91edab42108f, p_OnRejectActionID := p_OnRejectActionID_91edab42108f, p_OnRejectActionID_Clear := TRUE, p_OnCancelActionID := p_OnCancelActionID_91edab42108f, p_OnCancelActionID_Clear := TRUE, p_Code := p_Code_91edab42108f, p_OnCreateActionID := p_OnCreateActionID_91edab42108f, p_OnCreateActionID_Clear := TRUE, p_OnStatusChangeActionID := p_OnStatusChangeActionID_91edab42108f, p_OnStatusChangeActionID_Clear := TRUE, p_IsApproval := p_IsApproval_91edab42108f, p_ID := p_ID_91edab42108f);
    END IF;
  END IF;
END $mj$;
