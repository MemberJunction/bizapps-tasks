import { existsSync, mkdirSync, readFileSync, statSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, '..', '..', '..');
const require = createRequire(import.meta.url);

function resolvePlaywrightPath() {
    const candidates = [
        REPO_ROOT,
        resolve(REPO_ROOT, '..'),
        resolve(REPO_ROOT, '..', 'node_modules', '.pnpm', 'node_modules'),
    ];
    return require.resolve('playwright', { paths: candidates });
}

function resolveDhtmlxGanttFiles() {
    const angularPkgDir = resolve(REPO_ROOT, 'packages/Angular');
    const pkgJsonPath = require.resolve('dhtmlx-gantt/package.json', { paths: [angularPkgDir] });
    const pkg = JSON.parse(readFileSync(pkgJsonPath, 'utf8'));
    if (!String(pkg.version).startsWith('10.') || pkg.license !== 'MIT') {
        throw new Error(`Expected dhtmlx-gantt 10.x (MIT), found ${pkg.version} (${pkg.license})`);
    }
    const baseDir = dirname(pkgJsonPath);
    return {
        version: pkg.version,
        license: pkg.license,
        css: readFileSync(resolve(baseDir, 'codebase/dhtmlxgantt.css'), 'utf8'),
        js: readFileSync(resolve(baseDir, 'codebase/dhtmlxgantt.js'), 'utf8'),
    };
}

function extractInlineStyles(relPath, hostSelector) {
    const absPath = resolve(REPO_ROOT, relPath);
    const source = readFileSync(absPath, 'utf8');
    const match = source.match(/styles:\s*\[`([\s\S]*?)`\]/);
    if (!match) {
        throw new Error(`Could not extract styles from ${relPath}`);
    }
    const css = match[1];
    if (/#[0-9a-fA-F]{3,8}\b/.test(css) || /\b(?:rgb|rgba|hsl|hsla)\s*\(/i.test(css)) {
        throw new Error(`${relPath} CSS contains forbidden raw hex/rgb/hsl color literals`);
    }
    return css
        .replace(/:host\s*::ng-deep\s*/g, `${hostSelector} `)
        .replace(/:host\b/g, hostSelector);
}

function buildThemeTokensCss(theme) {
    if (theme === 'dark') {
        return `
  :root {
    color-scheme: dark;
    --mj-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --mj-font-family-mono: ui-monospace, SFMono-Regular, Menlo, monospace;
    --mj-text-xs: 12px;
    --mj-text-sm: 14px;
    --mj-text-base: 16px;
    --mj-text-lg: 18px;
    --mj-font-medium: 500;
    --mj-font-semibold: 600;
    --mj-font-bold: 700;
    --mj-space-1: 4px;
    --mj-space-2: 8px;
    --mj-space-3: 12px;
    --mj-space-4: 16px;
    --mj-space-5: 20px;
    --mj-radius-sm: 4px;
    --mj-radius-md: 8px;
    --mj-radius-lg: 12px;
    --mj-radius-full: 9999px;
    --mj-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.45);
    --mj-shadow-md: 0 4px 10px rgba(0, 0, 0, 0.55);
    --mj-bg-page: #0b1120;
    --mj-bg-surface: #111827;
    --mj-bg-surface-sunken: #1e293b;
    --mj-bg-surface-hover: #263349;
    --mj-bg-surface-elevated: #1f2937;
    --mj-border-default: #334155;
    --mj-border-subtle: #1f2937;
    --mj-border-strong: #475569;
    --mj-text-primary: #f1f5f9;
    --mj-text-secondary: #cbd5e1;
    --mj-text-muted: #94a3b8;
    --mj-text-disabled: #64748b;
    --mj-text-inverse: #ffffff;
    --mj-text-link: #60a5fa;
    --mj-brand-primary: #3b82f6;
    --mj-brand-primary-hover: #2563eb;
    --mj-brand-primary-active: #1d4ed8;
    --mj-brand-accent: #8b5cf6;
    --mj-status-success: #22c55e;
    --mj-status-success-bg: #052e16;
    --mj-status-success-text: #86efac;
    --mj-status-warning: #f59e0b;
    --mj-status-warning-bg: #451a03;
    --mj-status-warning-text: #fcd34d;
    --mj-status-info: #38bdf8;
    --mj-status-info-bg: #082f49;
    --mj-status-info-text: #7dd3fc;
    --mj-status-error: #ef4444;
    --mj-status-error-bg: #450a0a;
    --mj-status-error-text: #fca5a5;
    --mj-status-error-border: #7f1d1d;
  }`;
    }
    return `
  :root {
    color-scheme: light;
    --mj-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --mj-font-family-mono: ui-monospace, SFMono-Regular, Menlo, monospace;
    --mj-text-xs: 12px;
    --mj-text-sm: 14px;
    --mj-text-base: 16px;
    --mj-text-lg: 18px;
    --mj-font-medium: 500;
    --mj-font-semibold: 600;
    --mj-font-bold: 700;
    --mj-space-1: 4px;
    --mj-space-2: 8px;
    --mj-space-3: 12px;
    --mj-space-4: 16px;
    --mj-space-5: 20px;
    --mj-radius-sm: 4px;
    --mj-radius-md: 8px;
    --mj-radius-lg: 12px;
    --mj-radius-full: 9999px;
    --mj-shadow-sm: 0 1px 2px rgba(15, 23, 42, 0.08);
    --mj-shadow-md: 0 4px 10px rgba(15, 23, 42, 0.12);
    --mj-bg-page: #f8fafc;
    --mj-bg-surface: #ffffff;
    --mj-bg-surface-sunken: #f1f5f9;
    --mj-bg-surface-hover: #e2e8f0;
    --mj-bg-surface-elevated: #ffffff;
    --mj-border-default: #cbd5e1;
    --mj-border-subtle: #e2e8f0;
    --mj-border-strong: #94a3b8;
    --mj-text-primary: #0f172a;
    --mj-text-secondary: #334155;
    --mj-text-muted: #64748b;
    --mj-text-disabled: #94a3b8;
    --mj-text-inverse: #ffffff;
    --mj-text-link: #2563eb;
    --mj-brand-primary: #2563eb;
    --mj-brand-primary-hover: #1d4ed8;
    --mj-brand-primary-active: #1e40af;
    --mj-brand-accent: #7c3aed;
    --mj-status-success: #16a34a;
    --mj-status-success-bg: #dcfce7;
    --mj-status-success-text: #166534;
    --mj-status-warning: #d97706;
    --mj-status-warning-bg: #fef3c7;
    --mj-status-warning-text: #92400e;
    --mj-status-info: #0284c7;
    --mj-status-info-bg: #e0f2fe;
    --mj-status-info-text: #075985;
    --mj-status-error: #dc2626;
    --mj-status-error-bg: #fee2e2;
    --mj-status-error-text: #991b1b;
    --mj-status-error-border: #fecaca;
  }`;
}

function buildApprovalInboxHtml(theme, groupingMod) {
    const pageCss = extractInlineStyles('packages/Angular/src/lib/pages/approvals.page.ts', '.mjt-app-host');
    const panelCss = extractInlineStyles('packages/Angular/src/lib/components/approval-decision-panel/approval-decision-panel.component.ts', '.mjt-decision-host');
    const now = Date.parse('2026-11-23T12:00:00.000Z');

    const sampleItems = [
        {
            ID: '11111111-1111-4111-8111-111111111101',
            Name: 'Q4_[100%] Revenue Close Sign-Off',
            Description: '### Close Readiness\nVerify **deferred revenue** schedule and `100%` ledger tie-out.',
            Priority: 'Critical',
            DueAt: '2026-11-23T10:00:00.000Z',
            OrganizationID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
            Organization: 'Northwind Holdings US',
            CreatedAt: '2026-11-22T06:00:00.000Z',
            Hook: 'Process Approval Request Outcome',
            Linked: 'Journal Entry Batch JE-2026-11',
        },
        {
            ID: '11111111-1111-4111-8111-111111111102',
            Name: 'Vendor Onboarding Exception Review',
            Description: 'Confirm W-9 verification and **controller** approval.',
            Priority: 'High',
            DueAt: '2026-11-25T17:00:00.000Z',
            OrganizationID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
            Organization: 'Northwind Holdings US',
            CreatedAt: '2026-11-23T08:45:00.000Z',
            Hook: 'Process Approval Request Outcome',
            Linked: 'Vendor Record: Apex Logistics',
        },
        {
            ID: '11111111-1111-4111-8111-111111111103',
            Name: 'EMEA VAT Return Filing Authorization',
            Description: 'Approve monthly VAT submission for Q4_[100%] audit window.',
            Priority: 'High',
            DueAt: '2026-11-24T17:00:00.000Z',
            OrganizationID: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb2',
            Organization: 'Northwind Europe GmbH',
            CreatedAt: '2026-11-22T09:00:00.000Z',
            Hook: 'Process Approval Request Outcome',
            Linked: 'Tax Filing VAT-2026-11',
        },
    ];

    const groups = groupingMod.GroupApprovalsByOrganization(sampleItems, { sortBy: 'due', nowMs: now });
    const escapeHtml = (s) =>
        String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

    const groupHtml = groups
        .map((g) => {
            const cardsHtml = g.Items.map((item, idx) => {
                const lat = groupingMod.ComputeApprovalLatencyIndicator(item.CreatedAt, item.DueAt, now);
                const excerpt = groupingMod.StripRawMarkdownForExcerpt(item.Description);
                const selectedClass = idx === 0 && g.OrganizationName === 'Northwind Europe GmbH' ? ' is-selected' : '';
                return `
                  <article class="mjt-queue-card${selectedClass}" role="option" aria-selected="${selectedClass ? 'true' : 'false'}">
                    <div class="mjt-queue-top">
                      <span class="mjt-queue-badge">Approval</span>
                      <div class="mjt-queue-meta">
                        <span class="mjt-latency-pill mjt-latency--${lat.Tier}">${escapeHtml(lat.Label)}</span>
                        <span class="mjt-pri-pill mjt-pri--${item.Priority.toLowerCase()}">${escapeHtml(item.Priority)}</span>
                      </div>
                    </div>
                    <h4 class="mjt-queue-title">${escapeHtml(item.Name)}</h4>
                    <p class="mjt-queue-desc">${escapeHtml(excerpt)}</p>
                    <div class="mjt-queue-links">
                      <button type="button" class="mjt-queue-link-chip">${escapeHtml(item.Linked)}</button>
                    </div>
                    <div class="mjt-queue-hooks">
                      <span class="mjt-hook-tag">On approve: ${escapeHtml(item.Hook)}</span>
                    </div>
                  </article>`;
            }).join('\n');

            return `
              <section class="mjt-org-group" data-org-key="${escapeHtml(g.OrganizationKey)}">
                <button type="button" class="mjt-org-header" aria-expanded="true">
                  <div class="mjt-org-title">
                    <span>▾</span>
                    <span>${escapeHtml(g.OrganizationName)}</span>
                    <span class="mjt-org-count">${g.Count}</span>
                  </div>
                  <span class="mjt-org-latency mjt-org-latency--${g.HighestTier}">
                    Avg ${escapeHtml(g.AvgWaitFormatted)} · Max ${escapeHtml(g.MaxWaitFormatted)}
                  </span>
                </button>
                <div class="mjt-org-items">${cardsHtml}</div>
              </section>`;
        })
        .join('\n');

    return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>BizApps Tasks — Organization-Grouped Approval Inbox (${theme})</title>
<style>
  ${buildThemeTokensCss(theme)}
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 24px;
    background: var(--mj-bg-page);
    color: var(--mj-text-primary);
    font-family: var(--mj-font-family);
  }
  .page-shell {
    max-width: 1180px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border: 1px solid var(--mj-border-default);
    border-radius: var(--mj-radius-lg);
    background: var(--mj-bg-surface);
  }
  .page-header h1 { margin: 0; font-size: 20px; font-weight: 700; }
  .page-header p { margin: 4px 0 0; font-size: 13px; color: var(--mj-text-secondary); }
  .theme-pill {
    padding: 4px 10px;
    border-radius: var(--mj-radius-full);
    border: 1px solid var(--mj-border-default);
    background: var(--mj-bg-surface-sunken);
    color: var(--mj-text-secondary);
    font-size: 12px;
    font-weight: 600;
  }
  ${pageCss}
  ${panelCss}
</style>
</head>
<body>
  <main class="page-shell mjt-app-host" data-testid="approval-inbox-view" data-theme="${theme}">
    <header class="page-header">
      <div>
        <h1>Approvals</h1>
        <p>Organization-grouped pending decisions with latency telemetry &amp; LIKE-safe filter controls.</p>
      </div>
      <span class="theme-pill">${theme === 'dark' ? 'Dark Theme (--mj-*)' : 'Light Theme (--mj-*)'}</span>
    </header>
    <div class="mjt-app-page">
      <div class="mjt-app-controls">
        <input type="search" class="mjt-app-search" value="Q4_[100%]" aria-label="Filter pending approvals" readonly />
        <select class="mjt-app-sort" aria-label="Sort pending approvals">
          <option selected>Sort: Due Date</option>
        </select>
        <button type="button" class="mjt-group-toggle is-active" aria-pressed="true">Group by Organization</button>
      </div>
      <div class="mjt-app-grid">
        <div class="mjt-app-list" role="listbox" aria-label="Pending approval queue">
          <div class="mjt-queue-header">
            <span>Decision queue (${sampleItems.length})</span>
            <span class="mjt-queue-hint">Grouped by Task.OrganizationID</span>
          </div>
          ${groupHtml}
        </div>
        <aside class="mjt-app-detail mjt-decision-host">
          <div class="mjt-app-detail-bar">
            <span class="mjt-app-kbd-hint">List focus: <kbd>↑</kbd><kbd>↓</kbd> select · <kbd>A</kbd> / <kbd>R</kbd> prefill</span>
          </div>
          <div class="decision-panel">
            <h3 class="decision-title">EMEA VAT Return Filing Authorization</h3>
            <div class="field">
              <label class="field-label" for="outcome">Outcome</label>
              <select id="outcome" class="mj-select">
                <option selected>Approved</option>
                <option>Approved With Conditions</option>
                <option>Rejected</option>
              </select>
            </div>
            <div class="field">
              <label class="field-label" for="notes">Notes</label>
              <textarea id="notes" class="mj-textarea" rows="3">Verified organization scope and latency SLA.</textarea>
            </div>
            <div class="decision-actions">
              <button type="button" class="mj-btn mj-btn--primary">Record Decision</button>
              <button type="button" class="mj-btn mj-btn--secondary">Cancel</button>
            </div>
          </div>
        </aside>
      </div>
    </div>
  </main>
</body>
</html>`;
}

function buildGanttV10Html(theme, dhx) {
    const ganttCss = extractInlineStyles('packages/Angular/src/lib/components/task-gantt/task-gantt.component.ts', '.mjt-gantt-host');
    const mjGanttThemePath = resolve(REPO_ROOT, '..', 'MJ/packages/Angular/Generic/gantt/src/lib/components/gantt-theme.css');
    const mjGanttThemeCss = existsSync(mjGanttThemePath)
        ? readFileSync(mjGanttThemePath, 'utf8').replace(/:host\s*::ng-deep\s*/g, '.mjt-gantt-host ').replace(/:host\b/g, '.mjt-gantt-host')
        : '';

    return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>BizApps Tasks — MIT dhtmlx-gantt v${dhx.version} (${theme})</title>
<style>
  ${buildThemeTokensCss(theme)}
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 24px;
    background: var(--mj-bg-page);
    color: var(--mj-text-primary);
    font-family: var(--mj-font-family);
  }
  .gantt-shell {
    max-width: 1180px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .gantt-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 18px;
    border: 1px solid var(--mj-border-default);
    border-radius: var(--mj-radius-lg);
    background: var(--mj-bg-surface);
  }
  .gantt-head h1 { margin: 0; font-size: 18px; font-weight: 700; }
  .gantt-meta {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 12px;
    color: var(--mj-text-secondary);
  }
  .pill {
    padding: 3px 9px;
    border-radius: var(--mj-radius-full);
    border: 1px solid var(--mj-border-default);
    background: var(--mj-bg-surface-sunken);
    font-weight: 600;
  }
  ${dhx.css}
  ${mjGanttThemeCss}
  ${ganttCss}
</style>
</head>
<body>
  <main class="gantt-shell mjt-gantt-host" data-testid="gantt-v10-view" data-theme="${theme}">
    <header class="gantt-head">
      <div>
        <h1>Project Timeline (MIT dhtmlx-gantt v${dhx.version})</h1>
      </div>
      <div class="gantt-meta">
        <span class="pill" id="license-badge">Initializing...</span>
        <span class="pill">${theme === 'dark' ? 'Dark Theme' : 'Light Theme'}</span>
      </div>
    </header>
    <div class="mjt-gantt-wrap">
      <div class="mjt-gantt-toolbar">
        <div class="mjt-gantt-legend">
          <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--open"></span> Open</span>
          <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--prog"></span> In Progress</span>
          <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--done"></span> Completed</span>
          <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--blocked"></span> Blocked</span>
        </div>
        <div class="mjt-gantt-right">
          <div class="mjt-gantt-zoom">
            <button type="button" class="mjt-gantt-zoom__btn">−</button>
            <span class="mjt-gantt-zoom__label">100%</span>
            <button type="button" class="mjt-gantt-zoom__btn">+</button>
          </div>
        </div>
      </div>
      <div id="gantt_here" style="width:100%;height:420px;"></div>
    </div>
  </main>
  <script>${dhx.js}</script>
  <script>
    gantt.config.date_format = '%Y-%m-%d %H:%i';
    gantt.config.readonly = true;
    gantt.config.open_tree_initially = true;
    gantt.config.row_height = 36;
    gantt.config.columns = [
      { name: 'text', label: 'Name', tree: true, width: 240 },
      { name: 'organization', label: 'Organization', width: 150 },
      { name: 'progress', label: '%', align: 'center', width: 55, template: function(t) { return Math.round((t.progress || 0) * 100) + '%'; } }
    ];
    gantt.init('gantt_here');
    gantt.parse({
      data: [
        { id: '1', text: 'FY26 Month-End Close', organization: 'Northwind US', start_date: '2026-11-02 00:00', duration: 12, progress: 0.55, open: true },
        { id: '2', text: 'Subledger Reconciliation', organization: 'Northwind US', start_date: '2026-11-02 00:00', duration: 5, progress: 1.0, parent: '1' },
        { id: '3', text: 'Controller Approval Gate', organization: 'Northwind US', start_date: '2026-11-07 00:00', duration: 3, progress: 0.4, parent: '1' },
        { id: '4', text: 'EMEA VAT Close', organization: 'Northwind Europe', start_date: '2026-11-04 00:00', duration: 8, progress: 0.25, open: true }
      ],
      links: [
        { id: 'l1', source: '2', target: '3', type: '0' }
      ]
    });
    document.getElementById('license-badge').textContent = 'dhtmlx-gantt ' + gantt.version + ' (' + String(gantt.license).toUpperCase() + ')';
  </script>
</body>
</html>`;
}

async function captureView(browser, html, selector, requiredPhrases, outPath) {
    const page = await browser.newPage({ viewport: { width: 1280, height: 820 } });
    const pageErrors = [];
    const consoleErrors = [];
    page.on('pageerror', (err) => pageErrors.push(err.message));
    page.on('console', (msg) => {
        if (msg.type() === 'error') {
            consoleErrors.push(msg.text());
        }
    });
    try {
        await page.setContent(html, { waitUntil: 'load' });
        await page.waitForSelector(selector);
        const text = (await page.locator(selector).innerText()).trim();
        for (const phrase of requiredPhrases) {
            if (!text.includes(phrase)) {
                throw new Error(`Missing phrase "${phrase}" in ${selector}`);
            }
        }
        if (text.includes('###') || text.includes('**')) {
            throw new Error(`Raw Markdown leaked into rendered DOM text for ${selector}`);
        }
        const brokenImages = await page.evaluate(() =>
            Array.from(document.querySelectorAll('img')).filter((img) => !img.complete || img.naturalWidth === 0).length,
        );
        const box = await page.locator(selector).boundingBox();
        if (!box || box.width <= 0 || box.height <= 0) {
            throw new Error(`Zero bounding box for ${selector}`);
        }
        await page.screenshot({ path: outPath, fullPage: true });
        const stat = statSync(outPath);
        if (stat.size <= 0) {
            throw new Error(`Empty screenshot at ${outPath}`);
        }
        return {
            outPath,
            bytes: stat.size,
            pageErrors,
            consoleErrors,
            brokenImages,
            box,
        };
    } finally {
        await page.close();
    }
}

async function main() {
    const groupingDist = resolve(REPO_ROOT, 'packages/Angular/dist/lib/components/approval-inbox/approval-inbox-grouping.js');
    if (!existsSync(groupingDist)) {
        throw new Error(`Missing compiled ${groupingDist}; run pnpm run build:packages first.`);
    }
    const groupingMod = await import(groupingDist);
    const dhx = resolveDhtmlxGanttFiles();
    const outDir = resolve(REPO_ROOT, 'docs/screenshots/s2');
    mkdirSync(outDir, { recursive: true });

    const pw = require(resolvePlaywrightPath());
    const browser = await pw.chromium.launch({ headless: true });
    try {
        const results = [];
        for (const theme of ['light', 'dark']) {
            results.push(
                await captureView(
                    browser,
                    buildApprovalInboxHtml(theme, groupingMod),
                    '[data-testid="approval-inbox-view"]',
                    ['Northwind Holdings US', 'Northwind Europe GmbH', 'Process Approval Request Outcome', 'Wait'],
                    resolve(outDir, `01-approval-inbox-${theme}.png`),
                ),
            );
            results.push(
                await captureView(
                    browser,
                    buildGanttV10Html(theme, dhx),
                    '[data-testid="gantt-v10-view"]',
                    [`dhtmlx-gantt ${dhx.version} (MIT)`, 'FY26 Month-End Close', 'Subledger Reconciliation'],
                    resolve(outDir, `02-gantt-v10-${theme}.png`),
                ),
            );
        }

        const totalPageErrors = results.reduce((sum, r) => sum + r.pageErrors.length, 0);
        const totalConsoleErrors = results.reduce((sum, r) => sum + r.consoleErrors.length, 0);
        const totalBrokenImages = results.reduce((sum, r) => sum + r.brokenImages, 0);

        console.log(
            JSON.stringify(
                {
                    passed: totalPageErrors === 0 && totalConsoleErrors === 0 && totalBrokenImages === 0,
                    dhtmlxGanttVersion: dhx.version,
                    dhtmlxGanttLicense: dhx.license,
                    pageErrors: totalPageErrors,
                    consoleErrors: totalConsoleErrors,
                    brokenImages: totalBrokenImages,
                    screenshots: results.map((r) => ({ path: r.outPath, bytes: r.bytes, box: r.box })),
                },
                null,
                2,
            ),
        );
        if (totalPageErrors > 0 || totalConsoleErrors > 0 || totalBrokenImages > 0) {
            process.exit(1);
        }
    } finally {
        await browser.close();
    }
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
