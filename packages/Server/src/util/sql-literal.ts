/**
 * Escapes a value for interpolation inside a single-quoted SQL string literal
 * in a server-composed RunView `ExtraFilter`, by doubling embedded single quotes.
 *
 * This matters for values that originate in end-user-writable NVARCHAR columns —
 * most importantly the polymorphic `TaskAssignment.AssigneeRecordID` (NVARCHAR(450)).
 * Without escaping, a crafted stored value becomes a second-order SQL injection when
 * the server later re-interpolates it into a filter (notification fan-out runs under
 * the saving user's context; the overdue scheduled job runs under the job's context
 * user, which is typically privileged). Legitimate UNIQUEIDENTIFIER values contain
 * no quotes and pass through unchanged.
 */
export function escapeSqlLiteral(value: string): string {
    return value.replace(/'/g, "''");
}
