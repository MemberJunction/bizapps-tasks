-- ============================================================================
-- PostgreSQL counterpart of migrations/V202608270002__v1.2.x__Metadata_Sync.sql
-- `mj sync push` capture for the v1.2.x release.
-- ============================================================================

SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

-- Metadata sync for the v1.2.x release: the T-SQL file is an `mj sync push` capture of 28 core
-- sp calls (1 Application, 1 Entity, 4 EntityFields, 22 EntityRelationships). Each one calls the
-- same core function here with the same arguments. A value the capture sets is passed; a `_Clear`
-- flag clears the column; anything the capture leaves unset keeps its current value, as on SQL
-- Server. Core's spUpdateEntity takes its arguments as one jsonb object: a key that is present
-- sets the column (null clears it), a missing key keeps it.

-- Save MJ: Applications (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateApplication"(
  p_name := 'Tasks',
  p_description := 'Comprehensive task management, sub-task breakdowns, Kanban workflows, Gantt scheduling, multi-person assignments, and template automation across MemberJunction.',
  p_icon := 'fa-solid fa-list-check',
  p_defaultfornewuser := TRUE,
  p_schemaautoaddnewentities := '__mj_BizAppsTasks',
  p_color_clear := TRUE,
  p_defaultnavitems := '[
  {
    "Label": "Tasks",
    "Icon": "fa-solid fa-list-check",
    "ResourceType": "Custom",
    "DriverClass": "TasksSectionResource",
    "isDefault": true
  },
  {
    "Label": "My Tasks",
    "Icon": "fa-solid fa-user-check",
    "ResourceType": "Custom",
    "DriverClass": "MyTasksSectionResource",
    "isDefault": false
  },
  {
    "Label": "Approvals",
    "Icon": "fa-solid fa-stamp",
    "ResourceType": "Custom",
    "DriverClass": "ApprovalsSectionResource",
    "isDefault": false
  },
  {
    "Label": "Templates",
    "Icon": "fa-solid fa-copy",
    "ResourceType": "Custom",
    "DriverClass": "TemplatesSectionResource",
    "isDefault": false
  }
]',
  p_classname_clear := TRUE,
  p_defaultsequence := 100,
  p_status := 'Active',
  p_navigationstyle := 'App Switcher',
  p_topnavlocation_clear := TRUE,
  p_hidenavbariconwhenactive := FALSE,
  p_path := 'tasks',
  p_autoupdatepath := TRUE,
  p_agentsettings_clear := TRUE,
  p_id := '22541055-8ED4-4850-8ACD-E5EE1887B15B'
);

-- Save MJ: Entities (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntity"('{
  "ID": "B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466",
  "ParentID": null,
  "Name": "MJ_BizApps_Tasks: Tasks",
  "NameSuffix": null,
  "Description": null,
  "AutoUpdateDescription": true,
  "BaseView": "vwTasks",
  "BaseViewGenerated": true,
  "VirtualEntity": false,
  "TrackRecordChanges": true,
  "AuditRecordAccess": false,
  "AuditViewRuns": false,
  "IncludeInAPI": true,
  "AllowAllRowsAPI": false,
  "AllowUpdateAPI": true,
  "AllowCreateAPI": true,
  "AllowDeleteAPI": true,
  "CustomResolverAPI": false,
  "AllowUserSearchAPI": true,
  "FullTextSearchEnabled": false,
  "FullTextCatalog": null,
  "FullTextCatalogGenerated": true,
  "FullTextIndex": null,
  "FullTextIndexGenerated": true,
  "FullTextSearchFunction": null,
  "FullTextSearchFunctionGenerated": true,
  "UserViewMaxRows": 1000,
  "spCreate": null,
  "spUpdate": null,
  "spDelete": null,
  "spCreateGenerated": true,
  "spUpdateGenerated": true,
  "spDeleteGenerated": true,
  "CascadeDeletes": false,
  "DeleteType": "Hard",
  "AllowRecordMerge": false,
  "spMatch": null,
  "RelationshipDefaultDisplayType": "Search",
  "UserFormGenerated": true,
  "EntityObjectSubclassName": null,
  "EntityObjectSubclassImport": null,
  "PreferredCommunicationField": null,
  "Icon": null,
  "ScopeDefault": null,
  "RowsToPackWithSchema": "None",
  "RowsToPackSampleMethod": "random",
  "RowsToPackSampleCount": 0,
  "RowsToPackSampleOrder": null,
  "AutoRowCountFrequency": null,
  "RowCount": null,
  "RowCountRunAt": null,
  "Status": "Active",
  "DisplayName": "Tasks",
  "AllowMultipleSubtypes": false,
  "AutoUpdateFullTextSearch": true,
  "AutoUpdateAllowUserSearchAPI": true,
  "TrustServerCacheCompletely": true,
  "SupportsGeoCoding": false,
  "AutoUpdateSupportsGeoCoding": true,
  "AllowCaching": false,
  "DetectExternalChanges": false,
  "ExternalDataSourceID": null,
  "ExternalObjectName": null,
  "GeneratedBaseViewName": null,
  "AllowDirectSQLInsert": false,
  "AllowDirectSQLUpdate": false,
  "AllowDirectSQLDelete": false,
  "Configuration": "{\n  \"UI\": {\n    \"Form\": {\n      \"Layout\": \"left-nav\",\n      \"RelatedRolePolicy\": \"smart\",\n      \"PrimaryRelatedBudget\": 6\n    }\n  }\n}"
}'::jsonb);

-- Save MJ: Entity Fields (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityField"(
  p_displayname := 'Parent ID',
  p_description_clear := TRUE,
  p_autoupdatedescription := TRUE,
  p_isprimarykey := FALSE,
  p_isunique := FALSE,
  p_category_clear := TRUE,
  p_valuelisttype := 'None',
  p_extendedtype_clear := TRUE,
  p_codetype_clear := TRUE,
  p_defaultinview := FALSE,
  p_viewcelltemplate_clear := TRUE,
  p_defaultcolumnwidth := 150,
  p_allowupdateapi := TRUE,
  p_allowupdateinview := TRUE,
  p_includeinusersearchapi := FALSE,
  p_fulltextsearchenabled := FALSE,
  p_usersearchparamformatapi_clear := TRUE,
  p_includeingeneratedform := TRUE,
  p_generatedformsection := 'Details',
  p_isnamefield := FALSE,
  p_relatedentityid := 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865',
  p_relatedentityfieldname := 'ID',
  p_includerelatedentitynamefieldinbaseview := TRUE,
  p_relatedentitynamefieldmap_clear := TRUE,
  p_relatedentitydisplaytype := 'Search',
  p_entityidfieldname_clear := TRUE,
  p_scopedefault_clear := TRUE,
  p_autoupdaterelatedentityinfo := TRUE,
  p_valuestopackwithschema := 'Auto',
  p_status := 'Active',
  p_autoupdateisnamefield := TRUE,
  p_autoupdatedefaultinview := TRUE,
  p_autoupdatecategory := TRUE,
  p_autoupdatedisplayname := TRUE,
  p_autoupdateincludeinusersearchapi := TRUE,
  p_encrypt := FALSE,
  p_encryptionkeyid_clear := TRUE,
  p_allowdecryptinapi := FALSE,
  p_sendencryptedvalue := FALSE,
  p_issoftprimarykey := FALSE,
  p_issoftforeignkey := FALSE,
  p_relatedentityjoinfields_clear := TRUE,
  p_jsontype_clear := TRUE,
  p_jsontypeisarray := FALSE,
  p_jsontypedefinition_clear := TRUE,
  p_usersearchpredicateapi := 'Contains',
  p_autoupdateusersearchpredicate := TRUE,
  p_autoupdatefulltextsearch := TRUE,
  p_autoupdateextendedtype := TRUE,
  p_iscomputed := FALSE,
  p_embeddedrecord_clear := TRUE,
  p_configuration := '{
  "Hierarchy": {
    "IsHierarchy": true
  }
}',
  p_id := '926DE279-27FF-43D5-9F02-CB5C8CB25ED5'
);

-- Save MJ: Entity Fields (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityField"(
  p_displayname := 'Parent Item ID',
  p_description_clear := TRUE,
  p_autoupdatedescription := TRUE,
  p_isprimarykey := FALSE,
  p_isunique := FALSE,
  p_category_clear := TRUE,
  p_valuelisttype := 'None',
  p_extendedtype_clear := TRUE,
  p_codetype_clear := TRUE,
  p_defaultinview := FALSE,
  p_viewcelltemplate_clear := TRUE,
  p_defaultcolumnwidth := 150,
  p_allowupdateapi := TRUE,
  p_allowupdateinview := TRUE,
  p_includeinusersearchapi := FALSE,
  p_fulltextsearchenabled := FALSE,
  p_usersearchparamformatapi_clear := TRUE,
  p_includeingeneratedform := TRUE,
  p_generatedformsection := 'Details',
  p_isnamefield := FALSE,
  p_relatedentityid := 'A28FDD91-D380-427E-B374-BCEC56ED75B7',
  p_relatedentityfieldname := 'ID',
  p_includerelatedentitynamefieldinbaseview := TRUE,
  p_relatedentitynamefieldmap := 'ParentItem',
  p_relatedentitydisplaytype := 'Search',
  p_entityidfieldname_clear := TRUE,
  p_scopedefault_clear := TRUE,
  p_autoupdaterelatedentityinfo := TRUE,
  p_valuestopackwithschema := 'Auto',
  p_status := 'Active',
  p_autoupdateisnamefield := TRUE,
  p_autoupdatedefaultinview := TRUE,
  p_autoupdatecategory := TRUE,
  p_autoupdatedisplayname := TRUE,
  p_autoupdateincludeinusersearchapi := TRUE,
  p_encrypt := FALSE,
  p_encryptionkeyid_clear := TRUE,
  p_allowdecryptinapi := FALSE,
  p_sendencryptedvalue := FALSE,
  p_issoftprimarykey := FALSE,
  p_issoftforeignkey := FALSE,
  p_relatedentityjoinfields_clear := TRUE,
  p_jsontype_clear := TRUE,
  p_jsontypeisarray := FALSE,
  p_jsontypedefinition_clear := TRUE,
  p_usersearchpredicateapi := 'Contains',
  p_autoupdateusersearchpredicate := TRUE,
  p_autoupdatefulltextsearch := TRUE,
  p_autoupdateextendedtype := TRUE,
  p_iscomputed := FALSE,
  p_embeddedrecord_clear := TRUE,
  p_configuration := '{
  "Hierarchy": {
    "IsHierarchy": true
  }
}',
  p_id := '97D8E900-6AF3-4A75-92DA-1EAA66984AAE'
);

-- Save MJ: Entity Fields (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityField"(
  p_displayname := 'Parent ID',
  p_description_clear := TRUE,
  p_autoupdatedescription := TRUE,
  p_isprimarykey := FALSE,
  p_isunique := FALSE,
  p_category_clear := TRUE,
  p_valuelisttype := 'None',
  p_extendedtype_clear := TRUE,
  p_codetype_clear := TRUE,
  p_defaultinview := FALSE,
  p_viewcelltemplate_clear := TRUE,
  p_defaultcolumnwidth := 150,
  p_allowupdateapi := TRUE,
  p_allowupdateinview := TRUE,
  p_includeinusersearchapi := FALSE,
  p_fulltextsearchenabled := FALSE,
  p_usersearchparamformatapi_clear := TRUE,
  p_includeingeneratedform := TRUE,
  p_generatedformsection := 'Category',
  p_isnamefield := FALSE,
  p_relatedentityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_relatedentityfieldname := 'ID',
  p_includerelatedentitynamefieldinbaseview := TRUE,
  p_relatedentitynamefieldmap := 'Parent',
  p_relatedentitydisplaytype := 'Search',
  p_entityidfieldname_clear := TRUE,
  p_scopedefault_clear := TRUE,
  p_autoupdaterelatedentityinfo := TRUE,
  p_valuestopackwithschema := 'Auto',
  p_status := 'Active',
  p_autoupdateisnamefield := TRUE,
  p_autoupdatedefaultinview := TRUE,
  p_autoupdatecategory := TRUE,
  p_autoupdatedisplayname := TRUE,
  p_autoupdateincludeinusersearchapi := TRUE,
  p_encrypt := FALSE,
  p_encryptionkeyid_clear := TRUE,
  p_allowdecryptinapi := FALSE,
  p_sendencryptedvalue := FALSE,
  p_issoftprimarykey := FALSE,
  p_issoftforeignkey := FALSE,
  p_relatedentityjoinfields_clear := TRUE,
  p_jsontype_clear := TRUE,
  p_jsontypeisarray := FALSE,
  p_jsontypedefinition_clear := TRUE,
  p_usersearchpredicateapi := 'Contains',
  p_autoupdateusersearchpredicate := TRUE,
  p_autoupdatefulltextsearch := TRUE,
  p_autoupdateextendedtype := TRUE,
  p_iscomputed := FALSE,
  p_embeddedrecord_clear := TRUE,
  p_configuration := '{
  "Hierarchy": {
    "IsHierarchy": false
  }
}',
  p_id := 'D419FC58-9802-454E-8D34-1DFAEBEE7DF4'
);

-- Save MJ: Entity Fields (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityField"(
  p_displayname := 'Parent ID',
  p_description_clear := TRUE,
  p_autoupdatedescription := TRUE,
  p_isprimarykey := FALSE,
  p_isunique := FALSE,
  p_category_clear := TRUE,
  p_valuelisttype := 'None',
  p_extendedtype_clear := TRUE,
  p_codetype_clear := TRUE,
  p_defaultinview := FALSE,
  p_viewcelltemplate_clear := TRUE,
  p_defaultcolumnwidth := 150,
  p_allowupdateapi := TRUE,
  p_allowupdateinview := TRUE,
  p_includeinusersearchapi := FALSE,
  p_fulltextsearchenabled := FALSE,
  p_usersearchparamformatapi_clear := TRUE,
  p_includeingeneratedform := TRUE,
  p_generatedformsection := 'Details',
  p_isnamefield := FALSE,
  p_relatedentityid := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
  p_relatedentityfieldname := 'ID',
  p_includerelatedentitynamefieldinbaseview := TRUE,
  p_relatedentitynamefieldmap := 'Parent',
  p_relatedentitydisplaytype := 'Search',
  p_entityidfieldname_clear := TRUE,
  p_scopedefault_clear := TRUE,
  p_autoupdaterelatedentityinfo := TRUE,
  p_valuestopackwithschema := 'Auto',
  p_status := 'Active',
  p_autoupdateisnamefield := TRUE,
  p_autoupdatedefaultinview := TRUE,
  p_autoupdatecategory := TRUE,
  p_autoupdatedisplayname := TRUE,
  p_autoupdateincludeinusersearchapi := TRUE,
  p_encrypt := FALSE,
  p_encryptionkeyid_clear := TRUE,
  p_allowdecryptinapi := FALSE,
  p_sendencryptedvalue := FALSE,
  p_issoftprimarykey := FALSE,
  p_issoftforeignkey := FALSE,
  p_relatedentityjoinfields_clear := TRUE,
  p_jsontype_clear := TRUE,
  p_jsontypeisarray := FALSE,
  p_jsontypedefinition_clear := TRUE,
  p_usersearchpredicateapi := 'Contains',
  p_autoupdateusersearchpredicate := TRUE,
  p_autoupdatefulltextsearch := TRUE,
  p_autoupdateextendedtype := TRUE,
  p_iscomputed := FALSE,
  p_embeddedrecord_clear := TRUE,
  p_configuration := '{
  "Hierarchy": {
    "IsHierarchy": true
  }
}',
  p_id := '4DA0EEC6-3DC7-404C-9694-A65E1B58093C'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 3,
  p_relatedentityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'ParentID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname := 'Sub-tasks',
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := 'D792C155-F9E6-4583-AF2E-2C58286B4D16'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
  p_sequence := 7,
  p_relatedentityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'CreatedByPersonID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := '8C5A53EC-CA02-4B51-B8C1-9BA625AF6044'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 2,
  p_relatedentityid := '0662FC0F-3F2B-49C9-9BE8-5B59E036044A',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := 'B41F9981-030B-4EFF-92C2-9FF0460EFCFA'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 1,
  p_relatedentityid := '0662FC0F-3F2B-49C9-9BE8-5B59E036044A',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'DependsOnTaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := 'C8E7ABBB-8C96-4F7B-B5DA-9CF872A26F61'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 4,
  p_relatedentityid := 'DF98E700-1992-442B-B93E-E47379F2CA52',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := 'B62E328D-A310-4D6F-8480-AC997074B4A3'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 6,
  p_relatedentityid := 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := '1C165E6F-0DDF-441B-83B5-63F37C308558'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 7,
  p_relatedentityid := '6615EF77-83F1-49F1-B717-80EC31F77486',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := 'F8C5BE61-C2DB-4CD3-AB00-E9EF094C0A94'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 5,
  p_relatedentityid := 'B92E802C-5C1B-486D-B021-03E47069502C',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := 'BC39430A-8236-4D71-9CA8-BF48F5F5B3C8'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 8,
  p_relatedentityid := 'EA953D6B-524E-4A09-A842-9A0B0F1F850C',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := '7B5C6C40-EE9B-41FE-9B56-F641B5ED2704'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 9,
  p_relatedentityid := 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := '40FD17AE-A6D3-49EC-ACAD-58A68F6CB2F6'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
  p_sequence := 4,
  p_relatedentityid := 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'PersonID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := '8D492C02-54CF-44D6-B540-9A37EA146459'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
  p_sequence := 8,
  p_relatedentityid := '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'DecidedByPersonID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := 'E3400892-1304-4518-BF7A-CFD0EEE4659E'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
  p_sequence := 5,
  p_relatedentityid := 'DF98E700-1992-442B-B93E-E47379F2CA52',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'AssignedByPersonID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := '4E9FCAA1-19E6-437D-A968-BFEE4587E482'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
  p_sequence := 6,
  p_relatedentityid := '6615EF77-83F1-49F1-B717-80EC31F77486',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'PersonID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "None"
  }
}',
  p_id := 'A2985DA3-5B3B-4D9C-B89A-514AE8C0BD17'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '1E30141A-826F-4278-BAA9-BBE14D29E606',
  p_sequence := 2,
  p_relatedentityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TypeID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := 'E75E7A70-9034-4969-B83C-23E73111259A'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_sequence := 10,
  p_relatedentityid := '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := '533C0196-2FC5-4895-929E-A42BE9DCAC75'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '1E30141A-826F-4278-BAA9-BBE14D29E606',
  p_sequence := 3,
  p_relatedentityid := '802AEF11-BFE2-4B46-98B2-5FEBD4E35923',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TypeID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := '8593E41C-E3C6-486C-A41E-5F645F5C6EED'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '1E30141A-826F-4278-BAA9-BBE14D29E606',
  p_sequence := 1,
  p_relatedentityid := 'A210AF26-629A-4E0A-A90A-1CCE33F5D095',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TaskTypeID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := '64DE3230-A6BF-4D22-9C32-FE92C7C0D771'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
  p_sequence := 2,
  p_relatedentityid := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'ParentID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := 'DB864C7C-8F44-4FF7-85D0-EE414A46CAFD'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '802AEF11-BFE2-4B46-98B2-5FEBD4E35923',
  p_sequence := 1,
  p_relatedentityid := 'A28FDD91-D380-427E-B374-BCEC56ED75B7',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'TemplateID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := 'B12474ED-DD3B-427F-82D5-BE993D42BA21'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
  p_sequence := 3,
  p_relatedentityid := 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'CategoryID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "More"
  }
}',
  p_id := '8BC71AC8-D006-4C28-B5A7-269C53C64A0E'
);

-- Save MJ: Entity Relationships (core SP call only)
SELECT 1 FROM ${mjSchema}."spUpdateEntityRelationship"(
  p_entityid := '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
  p_sequence := 1,
  p_relatedentityid := '802AEF11-BFE2-4B46-98B2-5FEBD4E35923',
  p_bundleinapi := TRUE,
  p_includeinparentallquery := FALSE,
  p_type := 'One To Many',
  p_entitykeyfield_clear := TRUE,
  p_relatedentityjoinfield := 'CategoryID',
  p_joinview_clear := TRUE,
  p_joinentityjoinfield_clear := TRUE,
  p_joinentityinversejoinfield_clear := TRUE,
  p_displayinform := TRUE,
  p_displaylocation := 'After Field Tabs',
  p_displayname_clear := TRUE,
  p_displayicontype := 'Related Entity Icon',
  p_displayicon_clear := TRUE,
  p_displaycomponentid_clear := TRUE,
  p_displaycomponentconfiguration_clear := TRUE,
  p_autoupdatefromschema := TRUE,
  p_additionalfieldstoinclude_clear := TRUE,
  p_autoupdateadditionalfieldstoinclude := TRUE,
  p_relatedrecordcollection_clear := TRUE,
  p_configuration := '{
  "UI": {
    "inclusion": "Primary"
  }
}',
  p_id := '13E6795F-ED8E-4864-BBD6-0014FC2A40DF'
);
