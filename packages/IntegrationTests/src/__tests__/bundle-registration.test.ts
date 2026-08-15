import { describe, it, expect } from 'vitest';
import '../index.js';
import { IntegrationCheckRegistry } from '@memberjunction/testing-integration/registry';

describe('Tasks Integration Test Bundles', () => {
    it('registers all 6 task integration check bundles', () => {
        const bundleNames = IntegrationCheckRegistry.Instance.GetBundleNames();
        expect(bundleNames.length).toBeGreaterThanOrEqual(6);

        expect(bundleNames).toContain('task-world');
        expect(bundleNames).toContain('task-hierarchy');
        expect(bundleNames).toContain('task-dependencies');
        expect(bundleNames).toContain('task-assignments');
        expect(bundleNames).toContain('task-decisions');
        expect(bundleNames).toContain('task-templates');
    });
});
