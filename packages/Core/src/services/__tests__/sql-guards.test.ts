import { describe, it, expect } from 'vitest';
import { GuidLiteral } from '../sql-guards.js';

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
    expect(() => GuidLiteral('A1B2C3D4-E5F6-7890-ABCD-EF1234567890\' OR 1=1', 'ItemID')).toThrow(
      /ItemID .* is not a valid ID/,
    );
  });
});
