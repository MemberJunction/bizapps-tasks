/**
 * An agenda is a tree of items in one meeting (the meetings plan, § 2.5 and § 3): an item's parent is in the same
 * meeting and the tree has no cycle; items sit in Sequence order among their siblings; durations add up against the
 * meeting's length.
 */
export interface AgendaNode {
    ID: string;
    MeetingID: string;
    ParentID: string | null;
    Sequence: number;
    DurationMinutes?: number | null;
}

const same = (a: string | null | undefined, b: string | null | undefined): boolean => !!a && !!b && a.toLowerCase() === b.toLowerCase();

/**
 * What is wrong with where an item sits, or null: its parent must be another item of the same meeting, and following
 * parents upward must never come back to the item. `siblings` is the meeting's agenda as it is, the item itself included
 * or not.
 */
export function agendaParentProblem(item: AgendaNode, agenda: readonly AgendaNode[]): string | null {
    if (!item.ParentID) return null;
    if (same(item.ParentID, item.ID)) return 'An agenda item cannot sit under itself.';
    const byId = new Map(agenda.map((node) => [node.ID.toLowerCase(), node]));
    const parent = byId.get(item.ParentID.toLowerCase());
    if (!parent) return 'The parent item is not on this agenda.';
    if (!same(parent.MeetingID, item.MeetingID)) return 'An agenda item sits under an item of the same meeting.';
    // Walk up from the parent; meeting the item again is a cycle, and a missing link ends the walk
    const seen = new Set<string>([item.ID.toLowerCase()]);
    let current: AgendaNode | undefined = parent;
    while (current) {
        const key = current.ID.toLowerCase();
        if (seen.has(key)) return 'An agenda item cannot sit under one of its own sub-items.';
        seen.add(key);
        current = current.ParentID ? byId.get(current.ParentID.toLowerCase()) : undefined;
    }
    return null;
}

/** The agenda in reading order: each item followed by its sub-items, siblings by Sequence then by ID. */
export function orderAgenda(agenda: readonly AgendaNode[]): AgendaNode[] {
    const children = new Map<string, AgendaNode[]>();
    const roots: AgendaNode[] = [];
    const ids = new Set(agenda.map((node) => node.ID.toLowerCase()));
    for (const node of agenda) {
        const parentKey = node.ParentID?.toLowerCase();
        if (parentKey && ids.has(parentKey) && !same(parentKey, node.ID)) {
            const list = children.get(parentKey) ?? [];
            list.push(node);
            children.set(parentKey, list);
        } else {
            roots.push(node);
        }
    }
    const bySequence = (a: AgendaNode, b: AgendaNode): number => a.Sequence - b.Sequence || a.ID.localeCompare(b.ID);
    const out: AgendaNode[] = [];
    const visited = new Set<string>();
    const walk = (nodes: AgendaNode[]): void => {
        for (const node of nodes.sort(bySequence)) {
            const key = node.ID.toLowerCase();
            if (visited.has(key)) continue;
            visited.add(key);
            out.push(node);
            walk(children.get(key) ?? []);
        }
    };
    walk(roots);
    return out;
}

/**
 * How long the agenda takes, in minutes: each top-level item counts its own duration when it has one, else the sum of
 * its sub-items the same way. An item without a duration and without timed sub-items counts 0.
 */
export function agendaDurationTotal(agenda: readonly AgendaNode[]): number {
    const children = new Map<string, AgendaNode[]>();
    for (const node of agenda) {
        if (!node.ParentID) continue;
        const list = children.get(node.ParentID.toLowerCase()) ?? [];
        list.push(node);
        children.set(node.ParentID.toLowerCase(), list);
    }
    const seen = new Set<string>();
    const minutesOf = (node: AgendaNode): number => {
        const key = node.ID.toLowerCase();
        if (seen.has(key)) return 0;
        seen.add(key);
        if (typeof node.DurationMinutes === 'number' && node.DurationMinutes >= 0) return node.DurationMinutes;
        return (children.get(key) ?? []).reduce((sum, child) => sum + minutesOf(child), 0);
    };
    return agenda.filter((node) => !node.ParentID).reduce((sum, node) => sum + minutesOf(node), 0);
}
