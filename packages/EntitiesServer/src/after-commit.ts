import { LogError } from '@memberjunction/core';

interface ProviderWithRunAfterCommit {
    RunAfterCommit(task: () => Promise<void> | void, description?: string, token?: object): void;
    CapturePostCommitToken?: () => object | undefined;
}

function hasRunAfterCommit(provider: object | null | undefined): provider is ProviderWithRunAfterCommit {
    return !!provider && typeof (provider as Partial<ProviderWithRunAfterCommit>).RunAfterCommit === 'function';
}

/**
 * Captures the caller's open transaction token (if the provider supports `CapturePostCommitToken`)
 * before the first await inside `Save()`, so post-commit work follows the caller's transaction.
 */
export function capturePostCommitToken(provider: object | null | undefined): object | undefined {
    if (hasRunAfterCommit(provider) && typeof provider.CapturePostCommitToken === 'function') {
        return provider.CapturePostCommitToken();
    }
    return undefined;
}

/**
 * Runs work once the save's transaction has committed (the meetings plan, § 3: everything outside the database runs
 * after the commit), through the provider's RunAfterCommit where it has one. The work never throws into the save:
 * a failure is logged.
 */
export function runAfterCommit(
    provider: object | null | undefined,
    description: string,
    task: () => Promise<void>,
    token?: object,
): void {
    const guarded = async (): Promise<void> => {
        try {
            await task();
        } catch (error) {
            LogError(`${description} failed after the commit: ${error instanceof Error ? error.message : String(error)}`);
        }
    };
    // Only a database provider (the server's, MJ 6.1.6 or later, the app's floor) has RunAfterCommit. Without it
    // the caller is a client that loaded these subclasses beside its GraphQL provider, as the integration harness does:
    // the server does this work when it saves the same row, so here it is left alone rather than done a second time.
    if (hasRunAfterCommit(provider)) {
        if (token !== undefined) {
            provider.RunAfterCommit(guarded, description, token);
        } else {
            provider.RunAfterCommit(guarded, description);
        }
    }
}
