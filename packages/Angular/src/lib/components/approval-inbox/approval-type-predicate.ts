/** SQL predicate on vwTaskTypes selecting the approval types: one named type, or every IsApproval type. */
export function ApprovalTypePredicate(typeName: string | null): string {
    return typeName ? `Name = '${typeName.replace(/'/g, "''")}'` : 'IsApproval = 1';
}
