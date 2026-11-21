/**
 * Shared MJ-aligned semantic styles for BizApps Tasks widgets.
 *
 * Uses ONLY official MemberJunction design tokens (`--mj-*` from
 * `@memberjunction/ng-shared-generic`'s `_tokens.scss`) with safe light fallbacks
 * so widgets inherit Light/Dark themes and org brand overrides automatically in
 * both MJ Explorer and standalone Angular hosts.
 */
export const TASKS_WIDGET_TOKENS_CSS = `
    :host {
        display: block;
        font-family: var(--mj-font-family, -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', Roboto, sans-serif);
        color: var(--mj-text-primary);
        -webkit-font-smoothing: antialiased;
        box-sizing: border-box;
    }
    :host *, :host *::before, :host *::after {
        box-sizing: border-box;
    }
    .mjt-mono {
        font-family: var(--mj-font-family-mono, ui-monospace, SFMono-Regular, Menlo, monospace);
    }
    .mjt-pill {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 2px 8px;
        border-radius: var(--mj-radius-full, 9999px);
        font-size: var(--mj-text-xs, 12px);
        font-weight: var(--mj-font-semibold, 600);
        line-height: 1.4;
        border: 1px solid transparent;
        white-space: nowrap;
    }
    .mjt-pill--neutral {
        background: var(--mj-bg-surface-sunken);
        color: var(--mj-text-secondary);
        border-color: var(--mj-border-default);
    }
    .mjt-pill--brand {
        background: color-mix(in oklab, var(--mj-brand-primary) 11%, var(--mj-bg-surface));
        color: var(--mj-brand-primary);
        border-color: color-mix(in oklab, var(--mj-brand-primary) 26%, var(--mj-border-default));
    }
    .mjt-pill--success {
        background: var(--mj-status-success-bg);
        color: var(--mj-status-success-text);
        border-color: var(--mj-status-success-border, color-mix(in oklab, var(--mj-status-success) 32%, transparent));
    }
    .mjt-pill--warning {
        background: var(--mj-status-warning-bg);
        color: var(--mj-status-warning-text);
        border-color: var(--mj-status-warning-border, color-mix(in oklab, var(--mj-status-warning) 35%, transparent));
    }
    .mjt-pill--error {
        background: var(--mj-status-error-bg);
        color: var(--mj-status-error-text);
        border-color: var(--mj-status-error-border, color-mix(in oklab, var(--mj-status-error) 35%, transparent));
    }
    .mjt-pill--info {
        background: var(--mj-status-info-bg);
        color: var(--mj-status-info-text);
        border-color: var(--mj-status-info-border, color-mix(in oklab, var(--mj-brand-primary) 28%, transparent));
    }
    /* Standard MJE brand tokens (no purple) — retained class name for backwards compatibility */
    .mjt-pill--violet {
        background: color-mix(in oklab, var(--mj-brand-primary) 11%, var(--mj-bg-surface));
        color: var(--mj-brand-primary);
        border-color: color-mix(in oklab, var(--mj-brand-primary) 26%, var(--mj-border-default));
    }
    .mjt-btn-danger-outline {
        background: transparent !important;
        color: var(--mj-status-error-text) !important;
        border: 1px solid var(--mj-status-error-border, var(--mj-status-error)) !important;
    }
    .mjt-btn-danger-outline:hover:not(:disabled) {
        background: var(--mj-status-error-bg) !important;
    }
    .mjt-record-chip {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 2px 8px;
        border-radius: var(--mj-radius-sm, 4px);
        font-size: 11.5px;
        font-weight: var(--mj-font-medium, 500);
        background: var(--mj-bg-surface-sunken);
        color: var(--mj-text-link);
        border: 1px solid var(--mj-border-default);
        cursor: pointer;
        max-width: 240px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        transition: border-color 140ms ease, background 140ms ease;
    }
    .mjt-record-chip:hover {
        border-color: var(--mj-brand-primary);
        background: var(--mj-bg-surface-hover);
    }
    .mjt-field-input,
    .mjt-field-select,
    .mjt-field-textarea {
        width: 100%;
        padding: 7px 10px;
        min-height: 36px;
        border: 1px solid var(--mj-border-strong);
        border-radius: var(--mj-radius-md, 8px);
        background: var(--mj-bg-surface);
        color: var(--mj-text-primary);
        font-family: inherit;
        font-size: var(--mj-text-sm, 14px);
        transition: border-color 140ms ease, box-shadow 140ms ease;
    }
    .mjt-field-input:focus,
    .mjt-field-select:focus,
    .mjt-field-textarea:focus {
        outline: none;
        border-color: var(--mj-border-focus, var(--mj-brand-primary));
        box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 16%, transparent);
    }
    .mjt-field-input::placeholder,
    .mjt-field-textarea::placeholder {
        color: var(--mj-text-muted);
    }
    @media (pointer: coarse), (max-width: 640px) {
        .mjt-field-input,
        .mjt-field-select {
            min-height: 44px;
            font-size: 15px;
        }
    }
`;
