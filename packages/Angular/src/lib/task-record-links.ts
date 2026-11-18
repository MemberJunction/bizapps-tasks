import { CompositeKey, Metadata, RunView, type IMetadataProvider } from '@memberjunction/core';
import { IsValidUUID } from '@memberjunction/global';

/** A record a task is linked to (its Task Link), with a name to show. */
export interface TaskRecordLink {
    TaskID: string;
    EntityName: string;
    RecordID: string;
    /** The record's display name, else the link's description, else the entity name. */
    Name: string;
}

interface TaskLinkRow {
    TaskID: string;
    EntityID: string;
    RecordID: string;
    Description: string | null;
}

/**
 * The records each task links to, keyed by lower-cased task ID, so a list of approvals can show and
 * open the order (or other record) each one is about. Tasks with no link are absent from the map.
 *
 * @throws when the Task Links lookup fails.
 */
export async function LoadTaskRecordLinks(taskIDs: readonly string[], provider: IMetadataProvider = Metadata.Provider): Promise<Map<string, TaskRecordLink[]>> {
    const ids = taskIDs.filter((id) => IsValidUUID(id));
    const byTask = new Map<string, TaskRecordLink[]>();
    if (ids.length === 0) return byTask;

    const result = await new RunView().RunView<TaskLinkRow>({
        EntityName: 'MJ_BizApps_Tasks: Task Links',
        ExtraFilter: `TaskID IN (${ids.map((id) => `'${id}'`).join(',')})`,
        Fields: ['TaskID', 'EntityID', 'RecordID', 'Description'],
        ResultType: 'simple',
    });
    if (!result?.Success) throw new Error(result?.ErrorMessage || 'Failed to load linked records');

    const links = (result.Results ?? []).flatMap((row) => {
        const entity = provider.EntityByID(row.EntityID);
        return entity ? [{ row, entityName: entity.Name }] : [];
    });
    const names = await recordNames(links.map((l) => ({ EntityName: l.entityName, RecordID: l.row.RecordID })), provider);

    for (const { row, entityName } of links) {
        const key = row.TaskID.toLowerCase();
        const list = byTask.get(key) ?? [];
        list.push({
            TaskID: row.TaskID,
            EntityName: entityName,
            RecordID: row.RecordID,
            Name: names.get(nameKey(entityName, row.RecordID)) || row.Description || entityName,
        });
        byTask.set(key, list);
    }
    return byTask;
}

/** Record display names; a failed name lookup leaves the names out rather than failing the list. */
async function recordNames(records: Array<{ EntityName: string; RecordID: string }>, provider: IMetadataProvider): Promise<Map<string, string>> {
    const names = new Map<string, string>();
    if (records.length === 0) return names;
    try {
        const results = await provider.GetEntityRecordNames(
            records.map((r) => ({ EntityName: r.EntityName, CompositeKey: CompositeKey.FromID(r.RecordID) })),
        );
        for (const r of results ?? []) {
            const id = r.CompositeKey?.GetValueByIndex(0);
            if (r.Success && r.RecordName && id != null) names.set(nameKey(r.EntityName, String(id)), r.RecordName);
        }
    } catch {
        // Names are a nicety; the link still opens the record.
    }
    return names;
}

function nameKey(entityName: string, recordID: string): string {
    return `${entityName.toLowerCase()}|${recordID.toLowerCase()}`;
}
