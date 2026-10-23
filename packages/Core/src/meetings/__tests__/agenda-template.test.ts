import { describe, it, expect } from 'vitest';
import { agendaTemplateMinutes, flattenAgendaTemplate, parseAgendaTemplate } from '../agenda-template.js';

const json = JSON.stringify({
    items: [
        { title: 'Welcome', typeCode: 'INFORMATION', durationMinutes: 5 },
        { title: 'Review', items: [{ title: 'Numbers', typeCode: 'REPORT', durationMinutes: 10 }, { title: 'Risks', durationMinutes: 15 }] },
        { title: 'Decisions', typeCode: 'DECISION', durationMinutes: 20, description: 'What we settle today' },
    ],
});

describe('an agenda template', () => {
    it('reads items, codes, durations and sub-items', () => {
        const template = parseAgendaTemplate(json)!;
        expect(template.items).toHaveLength(3);
        expect(template.items[1].items).toHaveLength(2);
        expect(template.items[2]).toMatchObject({ title: 'Decisions', typeCode: 'DECISION', durationMinutes: 20, description: 'What we settle today' });
    });

    it('takes a bare list too, and nothing for an empty text', () => {
        expect(parseAgendaTemplate('[{"title":"Only"}]')!.items[0].title).toBe('Only');
        expect(parseAgendaTemplate('')).toBeNull();
        expect(parseAgendaTemplate(null)).toBeNull();
    });

    it('says what is wrong with a bad template', () => {
        expect(() => parseAgendaTemplate('{')).toThrow('The agenda template is not JSON.');
        expect(() => parseAgendaTemplate('{"x":1}')).toThrow(/list of items/);
        expect(() => parseAgendaTemplate('[{"title":""}]')).toThrow('items[0] has no title.');
        expect(() => parseAgendaTemplate('[{"title":"a","durationMinutes":-1}]')).toThrow(/0 or more minutes/);
        expect(() => parseAgendaTemplate('[{"title":"a","items":[{"nope":1}]}]')).toThrow('items[0].items[0] has no title.');
    });

    it('flattens in order with depth, parent and sequence', () => {
        const flat = flattenAgendaTemplate(parseAgendaTemplate(json)!);
        expect(flat.map((i) => [i.title, i.depth, i.parentIndex, i.sequence])).toEqual([
            ['Welcome', 0, null, 100],
            ['Review', 0, null, 200],
            ['Numbers', 1, 1, 100],
            ['Risks', 1, 1, 200],
            ['Decisions', 0, null, 300],
        ]);
    });

    it('adds up its minutes', () => {
        expect(agendaTemplateMinutes(parseAgendaTemplate(json)!)).toBe(50);
    });
});
