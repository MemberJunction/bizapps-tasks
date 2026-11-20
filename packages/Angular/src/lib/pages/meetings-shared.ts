import { CompositeKey } from '@memberjunction/core';
import { SharedService } from '@memberjunction/ng-shared';
import { MEETING_ENTITY, MEETING_SERIES_ENTITY } from '@mj-biz-apps/tasks-core';

/** Opens a meeting's record in the host (an Explorer tab). */
export function OpenMeetingRecord(meetingId: string | null | undefined): void {
    if (!meetingId) return;
    SharedService.Instance.OpenEntityRecord(MEETING_ENTITY, CompositeKey.FromID(meetingId));
}

/** Opens a series' record in the host. */
export function OpenSeriesRecord(seriesId: string | null | undefined): void {
    if (!seriesId) return;
    SharedService.Instance.OpenEntityRecord(MEETING_SERIES_ENTITY, CompositeKey.FromID(seriesId));
}

/** The styles the three Meetings pages share: the header card and the body card, as the Tasks pages draw them. */
export const MEETINGS_PAGE_CSS = `
    :host { display: block; width: 100%; height: 100%; }
    .mjt-page-wrap { display: flex; flex-direction: column; gap: 16px; padding: 16px; box-sizing: border-box; }
    .mjt-header-card { background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0); border-radius: var(--mj-radius-lg, 12px); padding: 16px 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); }
    .mjt-header-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
    .mjt-identity { display: flex; align-items: center; gap: 14px; }
    .mjt-avatar { width: 48px; height: 48px; border-radius: var(--mj-radius-md, 8px); background: var(--mj-brand-primary, #0076b6); color: var(--mj-brand-on-primary, #ffffff); display: grid; place-items: center; font-size: 20px; }
    .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
    .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
    .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }
    .mjt-actions { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
    .mjt-body-card { background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0); border-radius: var(--mj-radius-lg, 12px); padding: 12px 16px 16px; }
    .mjt-seg { display: inline-flex; border: 1px solid var(--mj-border-strong, #cbd5e1); border-radius: 999px; overflow: hidden; }
    .mjt-seg button { padding: 5px 12px; border: 0; background: transparent; color: var(--mj-text-muted, #64748b); font: inherit; font-size: 12px; font-weight: 600; cursor: pointer; }
    .mjt-seg button + button { border-left: 1px solid var(--mj-border-default, #e2e8f0); }
    .mjt-seg button.on { background: var(--mj-brand-primary, #0076b6); color: var(--mj-brand-on-primary, #ffffff); }
    .mjt-empty { margin: 0; font-size: 13px; color: var(--mj-text-secondary, #475569); }
    .mjt-error { padding: 8px 12px; border-radius: var(--mj-radius-md, 8px); background: var(--mj-status-error-bg, #fef2f2); color: var(--mj-status-error-text, #b91c1c); font-size: 13px; }
    .mjt-dialog-body { padding: 4px 2px; }
`;
