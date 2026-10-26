import { describe, it, expect } from 'vitest';
import { meetingPermissions } from '../meetings/meeting-data';

describe('what the viewer may do on a meeting', () => {
    it('gives the organizer everything', () => {
        expect(meetingPermissions(true, true, false)).toEqual({ canEdit: true, canRun: true, canInvite: true, canWriteNotes: true, canAddFollowUps: true });
    });

    it('gives an administrator everything, invited or not', () => {
        expect(meetingPermissions(false, false, true)).toEqual({ canEdit: true, canRun: true, canInvite: true, canWriteNotes: true, canAddFollowUps: true });
    });

    it('lets an invited person write notes and follow-ups, and nothing else', () => {
        expect(meetingPermissions(false, true, false)).toEqual({ canEdit: false, canRun: false, canInvite: false, canWriteNotes: true, canAddFollowUps: true });
    });

    it('gives a stranger nothing', () => {
        expect(meetingPermissions(false, false, false)).toEqual({ canEdit: false, canRun: false, canInvite: false, canWriteNotes: false, canAddFollowUps: false });
    });
});
