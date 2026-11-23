import { describe, it, expect } from 'vitest';
import {
    BuildLikeClause,
    DetectSqlDialect,
    EscapeLikePattern,
    GuidLiteral,
} from '../sql-guards.js';

/**
 * Simulates SQL `LIKE pattern ESCAPE '\'` matching in JS to prove that literal strings
 * match themselves and do NOT match unrelated strings across both dialects.
 */
function matchesSqlLike(candidate: string, pattern: string, dialect: 'sqlserver' | 'postgresql'): boolean {
    if (dialect === 'sqlserver') {
        // After EscapeLikePattern(..., 'sqlserver'), every %, _, [, ], \ has been escaped with \.
        // Verify no unescaped [, %, or _ remains in a pattern that came strictly from EscapeLikePattern.
        let regexSrc = '^';
        for (let i = 0; i < pattern.length; i++) {
            const ch = pattern[i];
            if (ch === '\\' && i + 1 < pattern.length) {
                const next = pattern[++i];
                regexSrc += next.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            } else if (ch === '%') {
                regexSrc += '.*';
            } else if (ch === '_') {
                regexSrc += '.';
            } else if (ch === '[') {
                throw new Error(`Unescaped SQL Server character class '[' in pattern: ${pattern}`);
            } else {
                regexSrc += ch.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }
        }
        regexSrc += '$';
        return new RegExp(regexSrc).test(candidate);
    }

    // PostgreSQL LIKE ESCAPE '\' treats [, ] literally and only treats %, _ as wildcards.
    let regexSrc = '^';
    for (let i = 0; i < pattern.length; i++) {
        const ch = pattern[i];
        if (ch === '\\' && i + 1 < pattern.length) {
            const next = pattern[++i];
            regexSrc += next.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        } else if (ch === '%') {
            regexSrc += '.*';
        } else if (ch === '_') {
            regexSrc += '.';
        } else {
            regexSrc += ch.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        }
    }
    regexSrc += '$';
    return new RegExp(regexSrc).test(candidate);
}

describe('GuidLiteral', () => {
    it('wraps valid lowercase and uppercase UUIDs in single quotes', () => {
        expect(GuidLiteral('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'TaskID')).toBe(
            "'a1b2c3d4-e5f6-7890-abcd-ef1234567890'",
        );
        expect(GuidLiteral('A1B2C3D4-E5F6-7890-ABCD-EF1234567890', 'TaskID')).toBe(
            "'A1B2C3D4-E5F6-7890-ABCD-EF1234567890'",
        );
    });

    it('trims surrounding whitespace on valid UUIDs', () => {
        expect(GuidLiteral('  A1B2C3D4-E5F6-7890-ABCD-EF1234567890  ', 'TaskID')).toBe(
            "'A1B2C3D4-E5F6-7890-ABCD-EF1234567890'",
        );
    });

    it('throws a descriptive error for SQL-injection payloads and malformed strings', () => {
        expect(() => GuidLiteral("x' OR 1=1 --", 'TaskID')).toThrow(/TaskID .* is not a valid ID/);
        expect(() => GuidLiteral('', 'TypeID')).toThrow(/TypeID .* is not a valid ID/);
        expect(() => GuidLiteral('not-a-uuid', 'TemplateID')).toThrow(/TemplateID .* is not a valid ID/);
        expect(() =>
            GuidLiteral("A1B2C3D4-E5F6-7890-ABCD-EF1234567890' OR 1=1", 'ItemID'),
        ).toThrow(/ItemID .* is not a valid ID/);
    });
});

describe('DetectSqlDialect', () => {
    it('detects postgresql case-insensitively and defaults to sqlserver', () => {
        expect(DetectSqlDialect({ PlatformKey: 'postgresql' })).toBe('postgresql');
        expect(DetectSqlDialect({ PlatformKey: ' PostgreSQL ' })).toBe('postgresql');
        expect(DetectSqlDialect({ PlatformKey: 'sqlserver' })).toBe('sqlserver');
        expect(DetectSqlDialect(undefined)).toBe('sqlserver');
        expect(DetectSqlDialect(null)).toBe('sqlserver');
    });
});

describe('EscapeLikePattern', () => {
    it('escapes adjacent escape and wildcard sequences for SQL Server', () => {
        expect(EscapeLikePattern('\\%', 'sqlserver')).toBe('\\\\\\%');
        expect(EscapeLikePattern('\\', 'sqlserver')).toBe('\\\\');
        expect(EscapeLikePattern('[_]', 'sqlserver')).toBe('\\[\\_\\]');
        expect(EscapeLikePattern('%%', 'sqlserver')).toBe('\\%\\%');
        expect(EscapeLikePattern('a%b_c[d]', 'sqlserver')).toBe('a\\%b\\_c\\[d\\]');
    });

    it('escapes adjacent escape and wildcard sequences for PostgreSQL', () => {
        expect(EscapeLikePattern('\\%', 'postgresql')).toBe('\\\\\\%');
        expect(EscapeLikePattern('\\', 'postgresql')).toBe('\\\\');
        expect(EscapeLikePattern('[_]', 'postgresql')).toBe('[\\_]');
        expect(EscapeLikePattern('%%', 'postgresql')).toBe('\\%\\%');
        expect(EscapeLikePattern('a%b_c[d]', 'postgresql')).toBe('a\\%b\\_c[d]');
    });

    it('doubles single quotes and strips null bytes without mangling legitimate literals', () => {
        expect(EscapeLikePattern("O'Reilly\0 Q4 Close", 'sqlserver')).toBe("O''Reilly Q4 Close");
        expect(EscapeLikePattern("O'Reilly\0 Q4 Close", 'postgresql')).toBe("O''Reilly Q4 Close");
        expect(EscapeLikePattern('Acme Corp Q1-2026', 'sqlserver')).toBe('Acme Corp Q1-2026');
        expect(EscapeLikePattern('Acme Corp Q1-2026', 'postgresql')).toBe('Acme Corp Q1-2026');
    });

    it('guarantees literal matching and blocks wildcard expansion across both dialects', () => {
        const edgeInputs = ['\\%', '\\', '[_]', '%%', 'a%b_c[d]'];
        for (const dialect of ['sqlserver', 'postgresql'] as const) {
            for (const needle of edgeInputs) {
                const escaped = EscapeLikePattern(needle, dialect);
                expect(matchesSqlLike(needle, escaped, dialect)).toBe(true);
                expect(matchesSqlLike('unrelated-decoy-row', escaped, dialect)).toBe(false);
                if (needle === '[_]') {
                    // Must NOT match a single literal '[' + 'x' + ']'
                    expect(matchesSqlLike('[x]', escaped, dialect)).toBe(false);
                }
                if (needle === '%%') {
                    expect(matchesSqlLike('anything-at-all', escaped, dialect)).toBe(false);
                }
            }
        }
    });
});

describe('BuildLikeClause', () => {
    it('emits ESCAPE clause across match modes and dialects', () => {
        expect(BuildLikeClause('Name', 'a%b_c[d]', { dialect: 'sqlserver' })).toBe(
            "Name LIKE '%a\\%b\\_c\\[d\\]%' ESCAPE '\\'",
        );
        expect(
            BuildLikeClause('Name', 'a%b_c[d]', {
                provider: { PlatformKey: 'postgresql' },
                caseInsensitive: true,
                matchMode: 'startsWith',
            }),
        ).toBe("LOWER(Name) LIKE LOWER('a\\%b\\_c[d]%') ESCAPE '\\'");
        expect(
            BuildLikeClause('Email', '[_]', { matchMode: 'exact', caseInsensitive: true }),
        ).toBe("LOWER(Email) LIKE LOWER('\\[\\_\\]') ESCAPE '\\'");
    });
});
