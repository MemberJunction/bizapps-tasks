-- =============================================================================================
-- BizApps Tasks v1.11.x -- Metadata_Sync (one per release)
-- =============================================================================================
-- Ships metadata/entities/.polymorphic-fk-entity-fields.json: sets EntityField.EntityIDFieldName
-- on the two polymorphic record-ID fields, naming the companion field that holds the target
-- entity's ID. MemberJunction forms, grids, cards and detail panels read it to resolve the
-- target record's name and render the value as a record link.
--
--   * MJ_BizApps_Tasks: Task Assignments . AssigneeRecordID -> AssigneeEntityID
--   * MJ_BizApps_Tasks: Task Links       . RecordID         -> EntityID
--
-- Written by hand: the change is two field updates, the same ones `mj sync push` makes. The
-- field rows are found by entity name and field name, as the metadata file's primaryKey lookup
-- does; CodeGen created them in earlier migrations.
-- =============================================================================================

UPDATE ef
SET ef.[EntityIDFieldName] = 'AssigneeEntityID'
FROM [${mjSchema}].[EntityField] ef
INNER JOIN [${mjSchema}].[Entity] e ON e.[ID] = ef.[EntityID]
WHERE e.[Name] = 'MJ_BizApps_Tasks: Task Assignments'
  AND ef.[Name] = 'AssigneeRecordID';

UPDATE ef
SET ef.[EntityIDFieldName] = 'EntityID'
FROM [${mjSchema}].[EntityField] ef
INNER JOIN [${mjSchema}].[Entity] e ON e.[ID] = ef.[EntityID]
WHERE e.[Name] = 'MJ_BizApps_Tasks: Task Links'
  AND ef.[Name] = 'RecordID';
