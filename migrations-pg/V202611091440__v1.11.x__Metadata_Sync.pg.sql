-- =============================================================================================
-- PostgreSQL counterpart of V202611091440__v1.11.x__Metadata_Sync.sql -- BizApps Tasks v1.11.x Metadata_Sync
-- =============================================================================================
-- Same records, same values, same order as the T-SQL file; see its header for what ships and why.
-- Written by hand.
-- =============================================================================================

UPDATE ${mjSchema}."EntityField" ef
SET "EntityIDFieldName" = 'AssigneeEntityID'
FROM ${mjSchema}."Entity" e
WHERE e."ID" = ef."EntityID"
  AND e."Name" = 'MJ_BizApps_Tasks: Task Assignments'
  AND ef."Name" = 'AssigneeRecordID';

UPDATE ${mjSchema}."EntityField" ef
SET "EntityIDFieldName" = 'EntityID'
FROM ${mjSchema}."Entity" e
WHERE e."ID" = ef."EntityID"
  AND e."Name" = 'MJ_BizApps_Tasks: Task Links'
  AND ef."Name" = 'RecordID';
