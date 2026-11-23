import { describe, it, expect } from 'vitest';
import '../index.js';
import { IntegrationCheckRegistry } from '@memberjunction/testing-integration/registry';

describe('Tasks Integration Test Bundles', () => {
    it('registers all 19 task integration check bundles', () => {
        const bundleNames = IntegrationCheckRegistry.Instance.GetBundleNames();
        expect(bundleNames.length).toBeGreaterThanOrEqual(19);

        expect(bundleNames).toContain('task-world');
        expect(bundleNames).toContain('task-hierarchy');
        expect(bundleNames).toContain('task-dependencies');
        expect(bundleNames).toContain('task-assignments');
        expect(bundleNames).toContain('task-decisions');
        expect(bundleNames).toContain('task-templates');
        expect(bundleNames).toContain('task-statuses');
        expect(bundleNames).toContain('task-action-hooks');
        expect(bundleNames).toContain('task-work-bus-and-reports');
        expect(bundleNames).toContain('task-hook-routing');
        expect(bundleNames).toContain('time-entries');
        expect(bundleNames).toContain('timers');
        expect(bundleNames).toContain('agent-effort');
        expect(bundleNames).toContain('time-reporting');
        expect(bundleNames).toContain('timesheets');
        expect(bundleNames).toContain('task-org-bulk-ops');
        expect(bundleNames).toContain('task-cos-typed-skills');
        expect(bundleNames).toContain('task-cos-live');
        expect(bundleNames).toContain('project-risk-assessments');
    });
});
