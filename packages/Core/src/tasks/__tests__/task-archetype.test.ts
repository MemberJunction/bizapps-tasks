import { describe, it, expect } from 'vitest';
import { ResolveTaskUiArchetype, ShouldShowAdaptiveSpotlight } from '../task-archetype.js';

describe('task-archetype', () => {
    it('resolves archetypes from TaskType metadata and OKR fields', () => {
        expect(ResolveTaskUiArchetype({ Code: 'GENERAL', Name: 'General' })).toBe('general');
        expect(ResolveTaskUiArchetype({ Code: 'DELIVERABLE', Name: 'Deliverable' })).toBe('deliverable');
        expect(ResolveTaskUiArchetype({ Code: 'APPROVAL_REQUEST', Name: 'Approval Request', IsApproval: true })).toBe('approval');
        expect(ResolveTaskUiArchetype({ Code: 'CUSTOM_APP', Name: 'VP Signoff', IsApproval: true })).toBe('approval');
        expect(ResolveTaskUiArchetype({ Code: 'KEY_RESULT', Name: 'Key Result' })).toBe('key-result');
        expect(ResolveTaskUiArchetype({ Code: 'ACTION_ITEM', Name: 'Action Item' })).toBe('action-item');
        expect(ResolveTaskUiArchetype({ Code: 'GENERAL', Name: 'General' }, { TargetValue: 95 })).toBe('key-result');
    });

    it('collapses Adaptive Spotlight to false on plain General tasks', () => {
        expect(ShouldShowAdaptiveSpotlight('general', { Status: 'Open' })).toBe(false);
        expect(ShouldShowAdaptiveSpotlight('general', { Status: 'Blocked', BlockedReason: 'Waiting on legal' })).toBe(true);
        expect(ShouldShowAdaptiveSpotlight('approval', { Status: 'Open' })).toBe(true);
        expect(ShouldShowAdaptiveSpotlight('key-result', { Status: 'InProgress' })).toBe(true);
        expect(ShouldShowAdaptiveSpotlight('deliverable', { Status: 'InProgress', HoursEstimated: 16 })).toBe(true);
    });
});
