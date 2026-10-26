/**
 * A meeting's status moves forward (the meetings plan, § 3): Draft → Scheduled → InProgress → Completed; Scheduled and
 * Postponed move either way; and anything but Completed can be Cancelled. Completed and Cancelled are the end.
 */
export const MEETING_STATUSES = ['Draft', 'Scheduled', 'Postponed', 'InProgress', 'Completed', 'Cancelled'] as const;
export type MeetingStatus = (typeof MEETING_STATUSES)[number];

const MOVES: Record<MeetingStatus, readonly MeetingStatus[]> = {
    Draft: ['Scheduled', 'Cancelled'],
    Scheduled: ['Postponed', 'InProgress', 'Cancelled'],
    Postponed: ['Scheduled', 'Cancelled'],
    InProgress: ['Completed', 'Cancelled'],
    Completed: [],
    Cancelled: [],
};

/** The statuses only the organizer, or someone who may edit every meeting, moves a meeting into: start, end, cancel. */
const ORGANIZER_MOVES: readonly MeetingStatus[] = ['InProgress', 'Completed', 'Cancelled'];

export function isMeetingStatus(value: string): value is MeetingStatus {
    return (MEETING_STATUSES as readonly string[]).includes(value);
}

/** Whether a meeting may move from one status to another. Staying put is always allowed. */
export function meetingStatusMoveAllowed(from: MeetingStatus, to: MeetingStatus): boolean {
    return from === to || MOVES[from].includes(to);
}

/** Why a move is refused, in a sentence for the person who tried it, or null when it is allowed. */
export function meetingStatusMoveRefusal(from: MeetingStatus, to: MeetingStatus): string | null {
    if (meetingStatusMoveAllowed(from, to)) return null;
    if (from === 'Completed') return 'A completed meeting does not change status.';
    if (from === 'Cancelled') return 'A cancelled meeting does not change status.';
    const next = MOVES[from].join(', ');
    return `A ${from} meeting moves to ${next}, not to ${to}.`;
}

/** Whether a move is one that starts, ends or cancels the meeting: the organizer's to make. */
export function isOrganizerOnlyMove(from: MeetingStatus, to: MeetingStatus): boolean {
    return from !== to && ORGANIZER_MOVES.includes(to);
}
