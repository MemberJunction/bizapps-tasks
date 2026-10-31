/**
 * Guards for IDs that reach SQL text in this package's ExtraFilters.
 *
 * Same shape as the server-side helper in `@mj-biz-apps/tasks-entities-server` (UserPeople.ts),
 * kept here so the dependency direction stays clean: tasks-core must not import from the server
 * package. An invalid ID fails the operation loudly instead of being interpolated.
 */
import { IsValidUUID } from '@memberjunction/global';

/** A UUID literal for a filter, or an error: every id here reaches SQL text. */
export function GuidLiteral(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id}'`;
}
