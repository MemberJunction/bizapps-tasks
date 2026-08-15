import { describe, expect, it } from 'vitest';
import { TaskPriorityChipClass, TaskProgressLabel, TaskStatusChipClass } from '../task-form.helpers';

describe('task-form helpers', () => {
    it('maps status and priority to chip classes', () => {
        expect(TaskStatusChipClass('Completed')).toContain('--ok');
        expect(TaskStatusChipClass('Blocked')).toContain('--error');
        expect(TaskPriorityChipClass('Critical')).toContain('--warn');
        expect(TaskPriorityChipClass('Low')).toContain('--muted');
    });

    it('rounds a progress percent', () => {
        expect(TaskProgressLabel(33.3)).toBe('33%');
        expect(TaskProgressLabel(null)).toBe('0%');
    });
});
