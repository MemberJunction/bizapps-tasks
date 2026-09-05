/**
 * UUID boundary guard.
 *
 * `TaskAssignment.AssigneeRecordID` is free-text NVARCHAR (polymorphic record
 * reference), but several server-side code paths interpolate those values into
 * `ExtraFilter` SQL strings that run under elevated contexts (notification
 * handler, scheduled jobs). Validating that a value is a strict UUID before it
 * enters any SQL string closes the second-order injection hole.
 */

/** Strict UUID shape: 8-4-4-4-12 hex, case-insensitive. */
const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;

/**
 * Returns true when the value is a well-formed UUID and therefore safe to
 * interpolate into a SQL filter string.
 */
export function isUuid(value: string | null | undefined): value is string {
    return typeof value === 'string' && UUID_REGEX.test(value);
}
