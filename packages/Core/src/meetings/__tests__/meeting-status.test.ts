import { describe, it, expect } from 'vitest';
import { isMeetingStatus, isOrganizerOnlyMove, meetingStatusMoveAllowed, meetingStatusMoveRefusal } from '../meeting-status.js';

describe('a meeting\'s status moves', () => {
    it('moves forward: Draft to Scheduled to InProgress to Completed', () => {
        expect(meetingStatusMoveAllowed('Draft', 'Scheduled')).toBe(true);
        expect(meetingStatusMoveAllowed('Scheduled', 'InProgress')).toBe(true);
        expect(meetingStatusMoveAllowed('InProgress', 'Completed')).toBe(true);
    });

    it('does not move back along the chain', () => {
        expect(meetingStatusMoveAllowed('Scheduled', 'Draft')).toBe(false);
        expect(meetingStatusMoveAllowed('InProgress', 'Scheduled')).toBe(false);
        expect(meetingStatusMoveAllowed('Completed', 'InProgress')).toBe(false);
    });

    it('lets Scheduled and Postponed move either way', () => {
        expect(meetingStatusMoveAllowed('Scheduled', 'Postponed')).toBe(true);
        expect(meetingStatusMoveAllowed('Postponed', 'Scheduled')).toBe(true);
    });

    it('lets anything but Completed be Cancelled, and nothing leave Cancelled', () => {
        for (const from of ['Draft', 'Scheduled', 'Postponed', 'InProgress'] as const) expect(meetingStatusMoveAllowed(from, 'Cancelled')).toBe(true);
        expect(meetingStatusMoveAllowed('Completed', 'Cancelled')).toBe(false);
        expect(meetingStatusMoveAllowed('Cancelled', 'Scheduled')).toBe(false);
    });

    it('says why a move is refused, and nothing when it is allowed', () => {
        expect(meetingStatusMoveRefusal('Scheduled', 'InProgress')).toBeNull();
        expect(meetingStatusMoveRefusal('Scheduled', 'Scheduled')).toBeNull();
        expect(meetingStatusMoveRefusal('Completed', 'Cancelled')).toBe('A completed meeting does not change status.');
        expect(meetingStatusMoveRefusal('Draft', 'Completed')).toBe('A Draft meeting moves to Scheduled, Cancelled, not to Completed.');
    });

    it('marks starting, ending and cancelling as the organizer\'s moves', () => {
        expect(isOrganizerOnlyMove('Scheduled', 'InProgress')).toBe(true);
        expect(isOrganizerOnlyMove('InProgress', 'Completed')).toBe(true);
        expect(isOrganizerOnlyMove('Scheduled', 'Cancelled')).toBe(true);
        expect(isOrganizerOnlyMove('Draft', 'Scheduled')).toBe(false);
        expect(isOrganizerOnlyMove('Scheduled', 'Postponed')).toBe(false);
    });

    it('recognises the status list', () => {
        expect(isMeetingStatus('Postponed')).toBe(true);
        expect(isMeetingStatus('Open')).toBe(false);
    });
});
