/**
 * The tokens the meeting widgets draw with, bound to :host so they resolve in any host (Explorer, Collaboration) from
 * MemberJunction's semantic tokens, with fallbacks for a host that has none. Light and dark come from the host's tokens.
 */
export const MEETING_TOKENS_CSS = `
    :host {
        --mjt-text: var(--mj-text-primary, #0f172a);
        --mjt-text-muted: var(--mj-text-muted, #64748b);
        --mjt-surface: var(--mj-bg-surface-card, #ffffff);
        --mjt-surface-sunken: var(--mj-bg-surface-sunken, #f8fafc);
        --mjt-border: var(--mj-border-default, #e2e8f0);
        --mjt-border-strong: var(--mj-border-strong, #cbd5e1);
        --mjt-brand: var(--mj-brand-primary, #0076b6);
        --mjt-on-brand: var(--mj-brand-on-primary, #ffffff);
        --mjt-brand-subtle: var(--mj-brand-primary-subtle, rgba(0, 118, 182, 0.08));
        --mjt-ok-bg: var(--mj-status-success-bg, #ecfdf5);
        --mjt-ok-text: var(--mj-status-success-text, #047857);
        --mjt-info-bg: var(--mj-status-info-bg, #eff6ff);
        --mjt-info-text: var(--mj-status-info-text, #1d4ed8);
        --mjt-warn-bg: var(--mj-status-warning-bg, #fffbeb);
        --mjt-warn-text: var(--mj-status-warning-text, #b45309);
        --mjt-error-bg: var(--mj-status-error-bg, #fef2f2);
        --mjt-error-text: var(--mj-status-error-text, #b91c1c);
        --mjt-radius: var(--mj-radius-md, 8px);
        --mjt-radius-lg: var(--mj-radius-lg, 12px);
    }
    .mjt-chip { display: inline-flex; align-items: center; gap: 6px; padding: 2px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; line-height: 18px; background: var(--mjt-surface-sunken); color: var(--mjt-text-muted); border: 1px solid var(--mjt-border); white-space: nowrap; }
    .mjt-chip--ok { background: var(--mjt-ok-bg); color: var(--mjt-ok-text); border-color: transparent; }
    .mjt-chip--info { background: var(--mjt-info-bg); color: var(--mjt-info-text); border-color: transparent; }
    .mjt-chip--warn { background: var(--mjt-warn-bg); color: var(--mjt-warn-text); border-color: transparent; }
    .mjt-chip--error { background: var(--mjt-error-bg); color: var(--mjt-error-text); border-color: transparent; }
    .mjt-chip--brand { background: var(--mjt-brand-subtle); color: var(--mjt-brand); border-color: transparent; }
    .mjt-card { background: var(--mjt-surface); border: 1px solid var(--mjt-border); border-radius: var(--mjt-radius-lg); padding: 14px 16px; color: var(--mjt-text); }
    .mjt-muted { color: var(--mjt-text-muted); }
    .mjt-small { font-size: 12px; }
    .mjt-strong { font-weight: 700; }
    .mjt-row { display: flex; align-items: center; gap: 10px; }
    .mjt-grow { flex: 1; min-width: 0; }
    .mjt-input, .mjt-select, .mjt-textarea { width: 100%; box-sizing: border-box; padding: 8px 10px; border: 1px solid var(--mjt-border-strong); border-radius: var(--mjt-radius); background: var(--mjt-surface); color: var(--mjt-text); font: inherit; }
    .mjt-input:focus, .mjt-select:focus, .mjt-textarea:focus { outline: 2px solid var(--mjt-brand); outline-offset: 1px; }
    .mjt-label { display: block; font-size: 12px; font-weight: 600; color: var(--mjt-text-muted); margin-bottom: 4px; }
    .mjt-callout { padding: 8px 12px; border-radius: var(--mjt-radius); font-size: 13px; }
    .mjt-callout--error { background: var(--mjt-error-bg); color: var(--mjt-error-text); }
    .mjt-callout--info { background: var(--mjt-info-bg); color: var(--mjt-info-text); }
    .mjt-empty { padding: 20px; text-align: center; color: var(--mjt-text-muted); font-size: 13px; }
`;
