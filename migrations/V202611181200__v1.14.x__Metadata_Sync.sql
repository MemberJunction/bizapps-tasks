-- =============================================================================================
-- BizApps Tasks v1.14.x -- Metadata_Sync (self-approval exempt roles become a list)
-- =============================================================================================
-- Ships the new Comments of the Tasks application setting SelfApprovalExemptRole from
-- metadata/application-settings/.tasks-settings.json: the setting now takes a comma-separated list
-- of role names (bc-aidp-next-golive#450), and a single name still works.
--
-- Written by hand: the change is one column on one row, the same update `mj sync push` makes.
-- Only Comments changes. Value is left alone, so a host that already set its exempt role keeps it.
-- The row is found by its primary key, as the metadata file's primaryKey does; an earlier
-- Metadata_Sync migration created it.
-- =============================================================================================

UPDATE [${mjSchema}].[ApplicationSetting]
SET [Comments] = N'Comma-separated NAMES of the MJ roles whose holders may decide an approval task they created themselves while PreventSelfApproval is true (bc-aidp-next-golive#450); a single name also works. They must still be one of its assignees. Names match trimmed and case-insensitively. Empty exempts nobody. A name that is not a role exempts nobody and is logged.'
WHERE [ID] = '17CC9998-9382-447B-A7DF-682A06837953';
