/**
 * A meeting type's agenda template (the meetings plan, § 2.8): the agenda a new meeting of the type starts with, as
 * items with a title, an agenda item type code, a duration in minutes and sub-items. Kept as JSON on the type; read here.
 */
export interface AgendaTemplateItem {
    title: string;
    typeCode?: string | null;
    durationMinutes?: number | null;
    description?: string | null;
    items?: AgendaTemplateItem[];
}

export interface AgendaTemplate {
    items: AgendaTemplateItem[];
}

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function readItem(value: unknown, path: string): AgendaTemplateItem {
    if (!isRecord(value)) throw new Error(`${path} is not an agenda item.`);
    const title = typeof value.title === 'string' ? value.title.trim() : '';
    if (!title) throw new Error(`${path} has no title.`);
    const typeCode = value.typeCode == null ? null : String(value.typeCode).trim() || null;
    const description = value.description == null ? null : String(value.description);
    let durationMinutes: number | null = null;
    if (value.durationMinutes != null) {
        const minutes = Number(value.durationMinutes);
        if (!Number.isFinite(minutes) || minutes < 0) throw new Error(`${path} has a duration that is not 0 or more minutes.`);
        durationMinutes = minutes;
    }
    const items = value.items == null ? [] : value.items;
    if (!Array.isArray(items)) throw new Error(`${path}.items is not a list.`);
    return { title, typeCode, durationMinutes, description, items: items.map((child, index) => readItem(child, `${path}.items[${index}]`)) };
}

/** The template read from its JSON text, or null for an empty one. Throws, in words, when the JSON is not a template. */
export function parseAgendaTemplate(json: string | null | undefined): AgendaTemplate | null {
    if (!json || !json.trim()) return null;
    let parsed: unknown;
    try {
        parsed = JSON.parse(json);
    } catch {
        throw new Error('The agenda template is not JSON.');
    }
    const items = Array.isArray(parsed) ? parsed : isRecord(parsed) ? parsed.items : undefined;
    if (!Array.isArray(items)) throw new Error('The agenda template is a list of items, or an object with an "items" list.');
    return { items: items.map((item, index) => readItem(item, `items[${index}]`)) };
}

/** The template's items flattened in order, each with its depth and the index of its parent in the list, for saving as agenda items. */
export function flattenAgendaTemplate(template: AgendaTemplate): Array<AgendaTemplateItem & { depth: number; parentIndex: number | null; sequence: number }> {
    const out: Array<AgendaTemplateItem & { depth: number; parentIndex: number | null; sequence: number }> = [];
    const walk = (items: AgendaTemplateItem[], depth: number, parentIndex: number | null): void => {
        items.forEach((item, position) => {
            const index = out.length;
            out.push({ ...item, depth, parentIndex, sequence: (position + 1) * 100 });
            walk(item.items ?? [], depth + 1, index);
        });
    };
    walk(template.items, 0, null);
    return out;
}

/** The template's length in minutes: top-level durations, or the sub-items' where the parent has none. */
export function agendaTemplateMinutes(template: AgendaTemplate): number {
    const minutesOf = (item: AgendaTemplateItem): number =>
        item.durationMinutes != null ? item.durationMinutes : (item.items ?? []).reduce((sum, child) => sum + minutesOf(child), 0);
    return template.items.reduce((sum, item) => sum + minutesOf(item), 0);
}
