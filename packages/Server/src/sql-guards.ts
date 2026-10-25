/**
 * SQL filter guards for the tasks server package.
 *
 * Local copy of the EntitiesServer `GuidLiteral` helper (that package does not
 * export it from its public API, and cross-package re-exports are not allowed).
 * Every id interpolated into RunView ExtraFilter text in this package routes
 * through here as defense-in-depth.
 */
import { IsValidUUID } from '@memberjunction/global';

/** A UUID literal for a filter, or an error: every id here reaches SQL text. */
export function GuidLiteral(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id}'`;
}
