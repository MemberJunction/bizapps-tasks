import { beforeEach, describe, expect, it, vi } from 'vitest';

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    RunView: class {
        RunView = runView;
    },
}));

import { CompositeKey, type IMetadataProvider } from '@memberjunction/core';
import { LoadTaskRecordLinks } from '../task-record-links';

const TASK_1 = 'E0000000-0000-0000-0000-000000000001';
const TASK_2 = 'E0000000-0000-0000-0000-000000000002';
const ORDER_ENTITY_ID = 'A0000000-0000-0000-0000-0000000000AA';
const ORDER_1 = 'F0000000-0000-0000-0000-000000000001';
const ORDER_2 = 'F0000000-0000-0000-0000-000000000002';

const getNames = vi.fn();
const provider = {
    EntityByID: (id: string) => (id === ORDER_ENTITY_ID ? { Name: 'MJ_BizApps_Orders: Order Headers' } : undefined),
    GetEntityRecordNames: getNames,
} as unknown as IMetadataProvider;

describe('LoadTaskRecordLinks', () => {
    beforeEach(() => {
        runView.mockReset();
        getNames.mockReset();
        runView.mockResolvedValue({
            Success: true,
            Results: [
                { TaskID: TASK_1, EntityID: ORDER_ENTITY_ID, RecordID: ORDER_1, Description: null },
                { TaskID: TASK_2, EntityID: ORDER_ENTITY_ID, RecordID: ORDER_2, Description: 'Order from DEAL-1' },
                { TaskID: TASK_2, EntityID: 'unknown-entity', RecordID: ORDER_2, Description: null },
            ],
        });
        getNames.mockResolvedValue([
            { Success: true, EntityName: 'MJ_BizApps_Orders: Order Headers', CompositeKey: CompositeKey.FromID(ORDER_1.toLowerCase()), RecordName: 'ORD-000101' },
        ]);
    });

    it('groups links by task, named by record name, then description', async () => {
        const links = await LoadTaskRecordLinks([TASK_1, TASK_2], provider);

        expect(links.get(TASK_1.toLowerCase())).toEqual([
            { TaskID: TASK_1, EntityName: 'MJ_BizApps_Orders: Order Headers', RecordID: ORDER_1, Name: 'ORD-000101' },
        ]);
        expect(links.get(TASK_2.toLowerCase())?.map((l) => l.Name)).toEqual(['Order from DEAL-1']);
        expect(runView.mock.calls[0][0].ExtraFilter).toBe(`TaskID IN ('${TASK_1}','${TASK_2}')`);
    });

    it('keeps the links when the names cannot be read', async () => {
        getNames.mockRejectedValue(new Error('offline'));
        const links = await LoadTaskRecordLinks([TASK_1], provider);
        expect(links.get(TASK_1.toLowerCase())?.[0].Name).toBe('MJ_BizApps_Orders: Order Headers');
    });

    it('reads nothing for IDs that are not UUIDs', async () => {
        expect((await LoadTaskRecordLinks(['task-1'], provider)).size).toBe(0);
        expect(runView).not.toHaveBeenCalled();
    });

    it('throws when the link lookup fails', async () => {
        runView.mockResolvedValue({ Success: false, ErrorMessage: 'denied', Results: [] });
        await expect(LoadTaskRecordLinks([TASK_1], provider)).rejects.toThrow('denied');
    });
});
