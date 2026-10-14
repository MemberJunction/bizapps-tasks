import { LogError } from '@memberjunction/core';

interface ProviderWithRunAfterCommit {
    RunAfterCommit(task: () => Promise<void> | void, description?: string): void;
}

function hasRunAfterCommit(provider: unknown): provider is ProviderWithRunAfterCommit {
    return !!provider && typeof (provider as Partial<ProviderWithRunAfterCommit>).RunAfterCommit === 'function';
}

/**
 * Runs work once the save's transaction has committed (the meetings plan, § 3: everything outside the database runs
 * after the commit), through the provider's RunAfterCommit where it has one; a provider without one runs it at once,
 * after the save returned. The work never throws into the save: a failure is logged.
 */
export function runAfterCommit(provider: unknown, description: string, task: () => Promise<void>): void {
    const guarded = async (): Promise<void> => {
        try {
            await task();
        } catch (error) {
            LogError(`${description} failed after the commit: ${error instanceof Error ? error.message : String(error)}`);
        }
    };
    if (hasRunAfterCommit(provider)) provider.RunAfterCommit(guarded, description);
    else void guarded();
}
