-- =============================================================================================
-- PostgreSQL counterpart of V202611181200__v1.14.x__Metadata_Sync.sql -- BizApps Tasks v1.14.x Metadata_Sync
-- =============================================================================================
-- Same record, same value as the T-SQL file; see its header for what ships and why.
-- Written by hand.
-- =============================================================================================

UPDATE ${mjSchema}."ApplicationSetting"
SET "Comments" = 'Comma-separated NAMES of the MJ roles whose holders may decide an approval task they created themselves while PreventSelfApproval is true (bc-aidp-next-golive#450); a single name also works. They must still be one of its assignees. Names match trimmed and case-insensitively. Empty exempts nobody. A name that is not a role exempts nobody and is logged.'
WHERE "ID" = '17CC9998-9382-447B-A7DF-682A06837953';
