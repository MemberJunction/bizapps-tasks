/**
 * Local SQL guard for the Core services: every id validated here is
 * interpolated into a RunView ExtraFilter, so it must be a strict UUID.
 * (Mirrors GuidLiteral in tasks-entities-server, which is server-only and
 * cannot be imported from this shared/universal package.)
 */
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Throws a descriptive error when `value` is not a UUID; returns it otherwise. */
export function requireUuid(value: string, name: string): string {
    if (!UUID_RE.test(value)) {
        throw new Error(`${name} '${value}' is not a valid ID.`);
    }
    return value;
}
