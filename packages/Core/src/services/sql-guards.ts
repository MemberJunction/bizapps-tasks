/**
 * Shared SQL filter guards for BizApps Tasks packages.
 *
 * - Every UUID interpolated into a RunView `ExtraFilter` routes through `GuidLiteral`
 *   so malformed or attacker-controlled strings fail loudly before reaching SQL text.
 * - Every user-supplied text interpolated into a `LIKE` clause routes through
 *   `EscapeLikePattern` / `BuildLikeClause` using explicit `ESCAPE '\'` across both
 *   SQL Server and PostgreSQL.
 */
import type { IMetadataProvider } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID } from '@memberjunction/global';

/** Database SQL dialect supported by BizApps Tasks `RunView` filters. */
export type SqlLikeDialect = 'sqlserver' | 'postgresql';

/** Match mode for constructing parameterized-safe `LIKE` filter predicates. */
export type LikeMatchMode = 'contains' | 'startsWith' | 'endsWith' | 'exact';

/** Minimal provider shape used to detect SQL dialect without pulling heavy DB packages into browser bundles. */
export interface SqlPlatformProvider {
    PlatformKey?: SqlLikeDialect | string;
}

/** Options accepted by {@link BuildLikeClause}. */
export interface BuildLikeClauseOptions {
    matchMode?: LikeMatchMode;
    caseInsensitive?: boolean;
    dialect?: SqlLikeDialect;
    provider?: IMetadataProvider | SqlPlatformProvider | null;
}

/**
 * Validates that `id` is a strict UUID and returns a single-quoted SQL literal.
 * Throws a descriptive error if `id` is not a valid UUID.
 */
export function GuidLiteral(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id.trim()}'`;
}

/**
 * Resolves the target SQL dialect from a metadata/data provider (`'postgresql'` vs `'sqlserver'`).
 * Defaults to `'sqlserver'` when the provider does not declare `PlatformKey`, which also stays
 * PostgreSQL-safe because `ESCAPE '\'` treats `\[` and `\]` as literal brackets in PostgreSQL.
 */
export function DetectSqlDialect(provider?: IMetadataProvider | SqlPlatformProvider | null): SqlLikeDialect {
    const rawKey = provider && 'PlatformKey' in provider ? provider.PlatformKey : undefined;
    const key = typeof rawKey === 'string' ? rawKey.trim().toLowerCase() : '';
    return key === 'postgresql' ? 'postgresql' : 'sqlserver';
}

/**
 * Escapes user-supplied text for safe interpolation inside a single-quoted `LIKE '...' ESCAPE '\'`
 * pattern across SQL Server and PostgreSQL:
 *
 * 1. Strips NUL bytes and doubles single quotes via `EscapeSQLString`.
 * 2. Escapes backslashes (`\` -> `\\`) BEFORE wildcards so literal `\` or `\%` never unescape a wildcard.
 * 3. Escapes `%` -> `\%` and `_` -> `\_`.
 * 4. On SQL Server (`'sqlserver'`), also escapes character-range brackets `[` -> `\[` and `]` -> `\]`.
 */
export function EscapeLikePattern(value: string, dialect: SqlLikeDialect = 'sqlserver'): string {
    const sqlQuoted = EscapeSQLString(value);
    const baseEscaped = sqlQuoted
        .replace(/\\/g, '\\\\')
        .replace(/%/g, '\\%')
        .replace(/_/g, '\\_');

    if (dialect === 'sqlserver') {
        return baseEscaped.replace(/\[/g, '\\[').replace(/\]/g, '\\]');
    }
    return baseEscaped;
}

/**
 * Builds a dual-dialect `LIKE` predicate using `ESCAPE '\'` so `%`, `_`, `[`, `]`, and `\`
 * inside `value` are always matched literally.
 */
export function BuildLikeClause(
    columnExpr: string,
    value: string,
    options: BuildLikeClauseOptions = {},
): string {
    const dialect = options.dialect ?? DetectSqlDialect(options.provider);
    const matchMode = options.matchMode ?? 'contains';
    const escaped = EscapeLikePattern(value, dialect);
    const prefix = matchMode === 'contains' || matchMode === 'endsWith' ? '%' : '';
    const suffix = matchMode === 'contains' || matchMode === 'startsWith' ? '%' : '';
    const patternLiteral = `'${prefix}${escaped}${suffix}'`;

    if (options.caseInsensitive) {
        return `LOWER(${columnExpr}) LIKE LOWER(${patternLiteral}) ESCAPE '\\'`;
    }
    return `${columnExpr} LIKE ${patternLiteral} ESCAPE '\\'`;
}
