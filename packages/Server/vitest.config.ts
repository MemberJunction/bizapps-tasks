import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    testTimeout: 15000,
    include: ['src/**/__tests__/**/*.test.ts'],
    // Child processes, not worker threads: server-limits.test.ts imports TimesheetApprovalReconcileJob
    // without mocking MJ server dependencies, pulling in native addons through MJ, and vitest 1.x's
    // thread pool segfaults tearing those down after every test passes on Linux (exit 139).
    pool: 'forks',
    coverage: {
      provider: 'v8',
      include: ['src/scheduled-jobs/**/*.ts', 'src/event-handlers/**/*.ts', 'src/notifications/**/*.ts'],
    },
  },
});
