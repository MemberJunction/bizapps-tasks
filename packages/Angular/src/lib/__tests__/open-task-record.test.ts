import { describe, expect, it, vi, beforeEach } from 'vitest';
import { CompositeKey } from '@memberjunction/core';

const { open } = vi.hoisted(() => ({ open: vi.fn() }));
vi.mock('@memberjunction/ng-shared', () => ({
    SharedService: {
        Instance: {
            OpenEntityRecord: open,
        },
    },
}));

import { OpenTaskRecord, TASKS_ENTITY } from '../open-task-record';

describe('OpenTaskRecord', () => {
    beforeEach(() => {
        open.mockClear();
    });

    it('does nothing when the id is missing', () => {
        OpenTaskRecord(null);
        OpenTaskRecord(undefined);
        OpenTaskRecord('');
        expect(open).not.toHaveBeenCalled();
    });

    it('opens the Tasks entity via SharedService', () => {
        OpenTaskRecord('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
        expect(open).toHaveBeenCalledTimes(1);
        const [entity, key] = open.mock.calls[0] as [string, CompositeKey];
        expect(entity).toBe(TASKS_ENTITY);
        expect(key.ToURLSegment()).toContain('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    });
});
