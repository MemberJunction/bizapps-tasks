import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import {
    FormatMeetingNoteMarkdown,
    MeetingNotesComponent,
    canDraftNotesWithAI,
    canManageNoteProposals,
} from '../meeting-notes.component';

const HERE = dirname(fileURLToPath(import.meta.url));
const COMPONENT_FILE = resolve(HERE, '../meeting-notes.component.ts');

describe('FormatMeetingNoteMarkdown', () => {
    it('returns empty string for empty input', () => {
        expect(FormatMeetingNoteMarkdown('')).toBe('');
    });

    it('converts [[EntityName|RecordID|DisplayName]] tokens into bold markdown labels', () => {
        const raw =
            '## Summary\n- Confirmed milestone with [[MJ_BizApps_Common: People|1111-2222|Dr. Catherine Holloway]] for [[MJ_BizApps_Tasks: Tasks|3333-4444|Q4 Audit Deliverable]].';
        const formatted = FormatMeetingNoteMarkdown(raw);
        expect(formatted).toBe(
            '## Summary\n- Confirmed milestone with **Dr. Catherine Holloway** for **Q4 Audit Deliverable**.',
        );
    });

    it('converts @{"_mode":"mention",...} JSON tokens into @Name', () => {
        const raw =
            'Action items for @{"_mode":"mention","type":"user","id":"u-1","name":"Elena Vance"} regarding @{"_mode":"mention","type":"record","entityName":"Accounts","name":"Northwind Corp","ID":"acc-1"}.';
        const formatted = FormatMeetingNoteMarkdown(raw);
        expect(formatted).toBe('Action items for @Elena Vance regarding @Northwind Corp.');
        expect(formatted).not.toContain('@{"_mode"');
    });

    it('handles mixed record links, JSON mentions, CRLF endings, and rich Markdown together', () => {
        const raw = [
            '## Key Decisions',
            '',
            '- Approved budget with @{"_mode":"mention","type":"user","id":"u-2","displayName":"Marcus Reid"}',
            '- Linked [[MJ_BizApps_Common: Organizations|org-1|Blue Cypress]]',
            '',
            '> Follow up with **Finance** on `INV-2026`.',
        ].join('\r\n');

        const formatted = FormatMeetingNoteMarkdown(raw);
        expect(formatted).toContain('## Key Decisions');
        expect(formatted).toContain('- Approved budget with @Marcus Reid');
        expect(formatted).toContain('- Linked **Blue Cypress**');
        expect(formatted).toContain('> Follow up with **Finance** on `INV-2026`.');
        expect(formatted).not.toContain('\r');
    });

    it('leaves non-mention or malformed @{...} text untouched without throwing', () => {
        const raw = 'Keep @{"other":"value"} and @{broken json intact.';
        expect(FormatMeetingNoteMarkdown(raw)).toBe(raw);
    });
});

describe('MeetingNotesComponent Markdown rendering and styling', () => {
    it('renders note bodies through mj-markdown with FormatMeetingNoteMarkdown and updated placeholder', () => {
        const source = readFileSync(COMPONENT_FILE, 'utf8');
        expect(MeetingNotesComponent).toBeDefined();
        expect(source).toContain('<mj-markdown [data]="FormatMeetingNoteMarkdown(note.body)"></mj-markdown>');
        expect(source).toContain('Capture decisions, takeaways, and action items (Markdown supported)…');
        expect(source).not.toContain('Markdown is kept as text');
        expect(source).toContain('MarkdownModule');
    });

    it('uses --mj-* design tokens with zero hardcoded hex/rgb/rgba/hsl color literals in component styles', () => {
        const source = readFileSync(COMPONENT_FILE, 'utf8');
        const stylesMatch = source.match(/styles:\s*\[MEETING_TOKENS_CSS,\s*`([\s\S]*?)`\]/);
        expect(stylesMatch).not.toBeNull();
        const css = stylesMatch![1];
        const colorLiteralRe = /#[0-9a-fA-F]{3,8}\b|\b(?:rgb|rgba|hsl|hsla)\s*\(/g;
        expect(css.match(colorLiteralRe) ?? []).toEqual([]);
        expect(css).toContain('overflow-wrap: anywhere');
        expect(css).toContain('--mj-text-primary');
        expect(css).toContain('--mj-bg-surface-card');
    });

    it('retains existing AI drafting and proposal permission helpers', () => {
        expect(canDraftNotesWithAI(true)).toBe(true);
        expect(canDraftNotesWithAI(false)).toBe(false);
        expect(canManageNoteProposals(true, false, true)).toBe(true);
        expect(canManageNoteProposals(true, false, false)).toBe(false);
    });
});
