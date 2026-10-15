/**
 * Guards for values interpolated into RunView `ExtraFilter` strings.
 *
 * `ExtraFilter` is raw SQL appended to the server's WHERE clause — not a
 * parameterized query. Several columns in this schema are deliberately
 * FK-less polymorphic references (`TaskAssignment.AssigneeRecordID`,
 * `TaskLink.ItemID`), so the database never validates their shape: a stored
 * value is attacker-shaped until proven otherwise, and interpolating one
 * unchecked is second-order SQL injection. Every id that reaches a filter
 * must pass through one of these guards first.
 */

const UUID =
    /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;

export class InvalidFilterInputError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'InvalidFilterInputError';
    }
}

/** True when the value is a well-formed UUID string. */
export function IsUUID(value: unknown): value is string {
    return typeof value === 'string' && UUID.test(value);
}

/** Throwing guard: rejects anything that is not a UUID. */
export function RequireUUID(value: unknown, field: string): string {
    if (!IsUUID(value)) {
        throw new InvalidFilterInputError(`${field} must be a UUID.`);
    }
    return value;
}

/**
 * Filters a list down to well-formed UUIDs and renders a quoted, comma-joined
 * SQL IN-list. Malformed entries are dropped (they cannot match a
 * UNIQUEIDENTIFIER column anyway); an empty result yields a never-matching
 * placeholder so `IN ()` syntax errors are impossible.
 */
export function UuidInList(values: readonly unknown[]): string {
    const ids = values.filter(IsUUID);
    if (ids.length === 0) {
        return `'00000000-0000-0000-0000-000000000000'`;
    }
    return ids.map((id) => `'${id}'`).join(',');
}
