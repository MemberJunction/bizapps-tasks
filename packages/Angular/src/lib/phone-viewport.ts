/**
 * Phone viewport breakpoint helper aligned with MJ's `@media (max-width: 768px)` rules.
 * Kept local so `@mj-biz-apps/tasks-ng` builds cleanly against both MJ 6.2.x and 6.3+.
 */
export const PHONE_VIEWPORT_QUERY = '(max-width: 768px)';

function phoneMedia(): MediaQueryList | null {
    if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') {
        return null;
    }
    return window.matchMedia(PHONE_VIEWPORT_QUERY) ?? null;
}

/** True at phone width (`<= 768px`). False in SSR/jsdom where `matchMedia` does not exist. */
export function IsPhoneViewport(): boolean {
    return phoneMedia()?.matches === true;
}

/**
 * Calls `onChange` whenever the viewport crosses the phone breakpoint.
 * Returns a cleanup callback suitable for `ngOnDestroy`.
 */
export function WatchPhoneViewport(onChange: () => void): () => void {
    const media = phoneMedia();
    if (!media || typeof media.addEventListener !== 'function') {
        return () => undefined;
    }
    const listener = (): void => onChange();
    media.addEventListener('change', listener);
    return () => media.removeEventListener('change', listener);
}
