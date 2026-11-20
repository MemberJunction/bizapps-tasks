/**
 * Shared SQL filter guards for BizApps Tasks packages.
 *
 * Every UUID interpolated into a RunView `ExtraFilter` routes through `GuidLiteral`
 * so malformed or attacker-controlled strings fail loudly before reaching SQL text.
 */
import { IsValidUUID } from '@memberjunction/global';

/**
 * Validates that `id` is a strict UUID and returns a single-quoted SQL literal.
 * Throws a descriptive error if `id` is not a valid UUID.
 */
export function GuidLiteral(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id.trim()}'`;
}
