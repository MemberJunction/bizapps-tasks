import { describe, it, expect } from 'vitest';
import '../index.js';
import { IntegrationCheckRegistry } from '@memberjunction/testing-integration/registry';

describe('Tasks Integration Test Bundles', () => {
    it('registers all 8 task integration check bundles', () => {
        const bundleNames = IntegrationCheckRegistry.Instance.GetBundleNames();
        expect(bundleNames.length).toBeGreaterThanOrEqual(8);

        expect(bundleNames).toContain('task-world');
        expect(bundleNames).toContain('task-hierarchy');
        expect(bundleNames).toContain('task-dependencies');
        expect(bundleNames).toContain('task-assignments');
        expect(bundleNames).toContain('task-decisions');
        expect(bundleNames).toContain('task-templates');
        expect(bundleNames).toContain('task-statuses');
        expect(bundleNames).toContain('task-action-hooks');
    });
});
