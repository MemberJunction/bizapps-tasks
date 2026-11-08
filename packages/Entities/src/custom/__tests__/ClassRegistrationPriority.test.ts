import { describe, expect, it, vi } from 'vitest';
import { BaseEntity } from '@memberjunction/core';
import { MJGlobal } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
} from '../../generated/entity_subclasses.js';
import { TaskDependencyEntity } from '../TaskDependencyEntitySubclass.js';
import { TaskEntity } from '../TaskEntitySubclass.js';

describe('Tasks custom entity ClassFactory registration priorities', () => {
    it('registers TaskDependencyEntity above mjBizAppsTasksTaskDependencyEntity without a priority collision', () => {
        const factory = MJGlobal.Instance.ClassFactory;
        const key = 'MJ_BizApps_Tasks: Task Dependencies';

        const winning = factory.GetRegistration(BaseEntity, key);
        expect(winning?.SubClass).toBe(TaskDependencyEntity);
        expect(TaskDependencyEntity.prototype).toBeInstanceOf(mjBizAppsTasksTaskDependencyEntity);

        const all = factory.GetAllRegistrations(BaseEntity, key);
        const generatedReg = all.find(r => r.SubClass === mjBizAppsTasksTaskDependencyEntity);
        const customReg = all.find(r => r.SubClass === TaskDependencyEntity);
        expect(generatedReg).toBeDefined();
        expect(customReg).toBeDefined();
        expect(customReg!.Priority).toBeGreaterThan(generatedReg!.Priority);
    });

    it('registers TaskEntity above mjBizAppsTasksTaskEntity without a priority collision', () => {
        const factory = MJGlobal.Instance.ClassFactory;
        const key = 'MJ_BizApps_Tasks: Tasks';

        const winning = factory.GetRegistration(BaseEntity, key);
        expect(winning?.SubClass).toBe(TaskEntity);
        expect(TaskEntity.prototype).toBeInstanceOf(mjBizAppsTasksTaskEntity);

        const all = factory.GetAllRegistrations(BaseEntity, key);
        const generatedReg = all.find(r => r.SubClass === mjBizAppsTasksTaskEntity);
        const customReg = all.find(r => r.SubClass === TaskEntity);
        expect(generatedReg).toBeDefined();
        expect(customReg).toBeDefined();
        expect(customReg!.Priority).toBeGreaterThan(generatedReg!.Priority);
    });

    it('emits zero ClassFactory.Register priority or unrelated-class warnings when auto-incrementing priority', () => {
        const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
        try {
            const factory = MJGlobal.Instance.ClassFactory;
            factory.Register(BaseEntity, TaskDependencyEntity, 'MJ_BizApps_Tasks: Task Dependencies');
            factory.Register(BaseEntity, TaskEntity, 'MJ_BizApps_Tasks: Tasks');

            const warnings = warnSpy.mock.calls
                .map(args => String(args[0] ?? ''))
                .filter(msg => msg.includes('ClassFactory.Register'));
            expect(warnings).toEqual([]);
        } finally {
            warnSpy.mockRestore();
        }
    });
});
