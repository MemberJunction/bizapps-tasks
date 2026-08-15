export interface WorldState {
    Categories: Record<string, { ID: string; Name: string }>;
    Roles: Record<string, { ID: string; Name: string }>;
    DecisionOutcomes: Record<string, { ID: string; Name: string }>;
    TaskTypes: Record<string, { ID: string; Name: string }>;
    People: Record<string, { ID: string; Email: string; FirstName: string; LastName: string }>;
    SeedTaskIDs: Record<string, string>;
}

let current: WorldState | null = null;

export function SetWorld(world: WorldState): void {
    current = world;
}

export function GetWorld(): WorldState | null {
    return current;
}

export function World(): WorldState {
    if (!current) throw new Error('Task World has not been loaded. Run task-world.TW1 first.');
    return current;
}
