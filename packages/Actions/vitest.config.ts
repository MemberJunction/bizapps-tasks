import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/**/__tests__/**/*.test.ts'],
    // Child processes, not worker threads: index.test.ts loads the whole action barrel, which pulls
    // in native addons through MJ, and vitest 1.x's thread pool segfaults tearing those down after
    // every test has passed (exit 139). Forks isolate each file in its own process instead.
    pool: 'forks',
  },
});
