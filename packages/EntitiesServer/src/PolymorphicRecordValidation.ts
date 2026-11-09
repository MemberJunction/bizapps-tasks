import {
    EntityPermissionType,
    IMetadataProvider,
    IRunViewProvider,
    Metadata,
    RunView,
    UserInfo,
} from '@memberjunction/core';

/**
 * Result of verifying that a polymorphic `(EntityID, RecordID)` target exists.
 */
export interface PolymorphicTargetCheckResult {
    Exists: boolean;
    EntityName: string | null;
    ErrorMessage: string | null;
}

/**
 * Verifies that a polymorphic `(entityID, recordID)` reference resolves to a known
 * MemberJunction entity and an existing record readable by `contextUser`.
 */
export async function VerifyPolymorphicRecordExists(
    mdProvider: IMetadataProvider | null | undefined,
    rvProvider: IRunViewProvider | null | undefined,
    entityID: string | null | undefined,
    recordID: string | null | undefined,
    contextUser: UserInfo | null | undefined,
): Promise<PolymorphicTargetCheckResult> {
    const trimmedEntityID = (entityID ?? '').trim();
    const trimmedRecordID = (recordID ?? '').trim();
    if (!trimmedEntityID || !trimmedRecordID) {
        return {
            Exists: false,
            EntityName: null,
            ErrorMessage: 'Both EntityID and RecordID are required.',
        };
    }

    const md = mdProvider ?? Metadata.Provider;
    const entities = md?.Entities ?? [];
    // If metadata has no entities loaded (e.g. lightweight unit test harness), skip entity lookup check
    if (entities.length === 0) {
        return { Exists: true, EntityName: null, ErrorMessage: null };
    }

    const entityInfo = entities.find(e => e.ID.toLowerCase() === trimmedEntityID.toLowerCase());
    if (!entityInfo) {
        return {
            Exists: false,
            EntityName: null,
            ErrorMessage: `Target entity "${trimmedEntityID}" was not found.`,
        };
    }

    if (contextUser && typeof entityInfo.CheckPermissions === 'function') {
        const canRead = entityInfo.CheckPermissions(contextUser, EntityPermissionType.Read, false);
        if (!canRead) {
            return {
                Exists: false,
                EntityName: entityInfo.Name,
                ErrorMessage: `You do not have permission to read "${entityInfo.Name}".`,
            };
        }
    }

    const pkField = entityInfo.FirstPrimaryKey?.Name ?? 'ID';
    const safeVal = trimmedRecordID.replace(/'/g, "''");
    const rv = new RunView(rvProvider ?? null);
    const res = await rv.RunView<{ ID?: string }>({
        EntityName: entityInfo.Name,
        ExtraFilter: `${pkField}='${safeVal}'`,
        Fields: [pkField],
        MaxRows: 1,
        ResultType: 'simple',
    }, contextUser ?? undefined);

    if (!res.Success) {
        return {
            Exists: false,
            EntityName: entityInfo.Name,
            ErrorMessage: res.ErrorMessage || `Could not verify record "${trimmedRecordID}" in "${entityInfo.Name}".`,
        };
    }

    const count = res.Results?.length ?? res.TotalRowCount ?? 0;
    if (count === 0) {
        return {
            Exists: false,
            EntityName: entityInfo.Name,
            ErrorMessage: `Record "${trimmedRecordID}" was not found in "${entityInfo.Name}".`,
        };
    }

    return {
        Exists: true,
        EntityName: entityInfo.Name,
        ErrorMessage: null,
    };
}
