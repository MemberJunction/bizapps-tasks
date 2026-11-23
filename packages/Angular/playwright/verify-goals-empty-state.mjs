import { existsSync, mkdirSync, readFileSync, statSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, '..', '..', '..');
const require = createRequire(import.meta.url);

function loadCompiledGoalsConstants() {
    const distPath = resolve(REPO_ROOT, 'packages/Angular/dist/lib/components/goals-view/goals-view.component.js');
    if (!existsSync(distPath)) {
        throw new Error(`Compiled GoalsViewComponent not found at ${distPath}. Run pnpm run build:packages first.`);
    }
    const distJs = readFileSync(distPath, 'utf8');
    const readConst = (name) => {
        const m = new RegExp(`export const ${name} = '([^']+)';`).exec(distJs);
        if (!m) {
            throw new Error(`Missing compiled export ${name} in ${distPath}`);
        }
        return m[1];
    };
    return {
        GOALS_PLANNING_APP_NAME: readConst('GOALS_PLANNING_APP_NAME'),
        GOALS_IMPORT_ACTION_NAME: readConst('GOALS_IMPORT_ACTION_NAME'),
        GOALS_EMPTY_STATE_TITLE: readConst('GOALS_EMPTY_STATE_TITLE'),
        GOALS_EMPTY_STATE_MESSAGE: readConst('GOALS_EMPTY_STATE_MESSAGE'),
    };
}

function resolvePlaywrightPath() {
    const candidates = [
        REPO_ROOT,
        resolve(REPO_ROOT, '..'),
        resolve(REPO_ROOT, '..', 'node_modules', '.pnpm', 'node_modules'),
    ];
    return require.resolve('playwright', { paths: candidates });
}

function escapeHtml(text) {
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function extractGoalsComponentStyles() {
    const tsPath = resolve(REPO_ROOT, 'packages/Angular/src/lib/components/goals-view/goals-view.component.ts');
    const source = readFileSync(tsPath, 'utf8');
    const match = source.match(/styles:\s*\[`([\s\S]*?)`\]/);
    if (!match) {
        throw new Error('Could not extract styles from goals-view.component.ts');
    }
    const css = match[1];
    if (/#[0-9a-fA-F]{3,8}\b/.test(css) || /\b(?:rgb|rgba|hsl|hsla)\s*\(/i.test(css)) {
        throw new Error('GoalsViewComponent CSS contains forbidden raw hex/rgb/hsl color literals');
    }
    return css.replace(/:host\b/g, '.mjt-goals-host');
}

async function main() {
    const {
        GOALS_PLANNING_APP_NAME,
        GOALS_IMPORT_ACTION_NAME,
        GOALS_EMPTY_STATE_TITLE,
        GOALS_EMPTY_STATE_MESSAGE,
    } = loadCompiledGoalsConstants();
    const outArgIndex = process.argv.indexOf('--out');
    const screenshotPath =
        outArgIndex !== -1 && process.argv[outArgIndex + 1]
            ? resolve(process.argv[outArgIndex + 1])
            : resolve(REPO_ROOT, '..', '.tmp-playwright', 'bizapps-tasks-goals-empty-state.png');
    mkdirSync(dirname(screenshotPath), { recursive: true });

    const componentCss = extractGoalsComponentStyles();
    const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>BizApps Tasks — Goals View Empty State &amp; In-App Help Verification</title>
<style>
  :root {
    color-scheme: light;
    --mj-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --mj-font-family-mono: ui-monospace, SFMono-Regular, Menlo, monospace;
    --mj-text-xs: 12px;
    --mj-text-sm: 14px;
    --mj-font-semibold: 600;
    --mj-font-bold: 700;
    --mj-radius-sm: 4px;
    --mj-radius-md: 8px;
    --mj-radius-lg: 10px;
    --mj-radius-full: 9999px;
    --mj-bg-page: Canvas;
    --mj-bg-surface: Canvas;
    --mj-bg-surface-sunken: ButtonFace;
    --mj-bg-surface-hover: ButtonFace;
    --mj-border-default: ButtonBorder;
    --mj-border-subtle: ButtonBorder;
    --mj-text-primary: CanvasText;
    --mj-text-secondary: GrayText;
    --mj-text-muted: GrayText;
    --mj-brand-primary: LinkText;
    --mj-status-info-bg: ButtonFace;
    --mj-status-info-text: LinkText;
    --mj-status-error-bg: ButtonFace;
    --mj-status-error-text: MarkText;
    --mj-status-error-border: ButtonBorder;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 24px;
    background: var(--mj-bg-page);
    color: var(--mj-text-primary);
    font-family: var(--mj-font-family);
  }
  .mjt-drawer-frame {
    max-width: 680px;
    margin: 0 auto;
    border: 1px solid var(--mj-border-default);
    border-radius: var(--mj-radius-lg);
    background: var(--mj-bg-surface);
    overflow: hidden;
  }
  .mjt-drawer-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px;
    border-bottom: 1px solid var(--mj-border-default);
    background: var(--mj-bg-surface-sunken);
  }
  .mjt-drawer-title {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
  }
  .mjt-empty-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 10px;
    padding: 20px 16px;
  }
  .mjt-empty-icon {
    width: 44px;
    height: 44px;
    border-radius: var(--mj-radius-full);
    border: 1px solid var(--mj-border-default);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--mj-brand-primary);
  }
  .mjt-empty-title {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
  }
  .mjt-empty-msg {
    margin: 0;
    max-width: 520px;
    font-size: 13px;
    line-height: 1.5;
    color: var(--mj-text-secondary);
  }
  ${componentCss}
</style>
</head>
<body>
  <main class="mjt-drawer-frame">
    <header class="mjt-drawer-head">
      <h1 class="mjt-drawer-title">OKRs &amp; Goals Help</h1>
      <span class="mjt-goals-pill">BizApps Tasks 1.x</span>
    </header>
    <div class="mjt-goals-host">
      <div class="mjt-goals-view" data-testid="goals-view">
        <section class="mjt-goals-notice" role="region" aria-label="BizApps Planning OKR migration guidance">
          <div class="mjt-goals-notice__icon" aria-hidden="true">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"></circle>
              <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
            </svg>
          </div>
          <div class="mjt-goals-notice__body">
            <h2 class="mjt-goals-notice__title">Objectives &amp; Key Results (OKRs) live in ${escapeHtml(GOALS_PLANNING_APP_NAME)}</h2>
            <p class="mjt-goals-notice__copy">
              Strategic OKR task types (<code>PRIORITY_OBJECTIVE</code> and <code>KEY_RESULT</code>) are
              deactivated in BizApps Tasks 1.x while existing OKR columns remain preserved for safe upgrades.
              Use <strong>${escapeHtml(GOALS_PLANNING_APP_NAME)}</strong> to create and manage new OKRs, and run the
              <strong>${escapeHtml(GOALS_IMPORT_ACTION_NAME)}</strong> action (preview with <code>DryRun: true</code>) to
              migrate historical OKR tasks.
            </p>
          </div>
        </section>

        <div class="mjt-goals-empty" data-testid="goals-empty-state">
          <div class="mjt-empty-card">
            <div class="mjt-empty-icon" aria-hidden="true">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="9"></circle>
                <circle cx="12" cy="12" r="5"></circle>
                <circle cx="12" cy="12" r="1"></circle>
              </svg>
            </div>
            <h3 class="mjt-empty-title">${escapeHtml(GOALS_EMPTY_STATE_TITLE)}</h3>
            <p class="mjt-empty-msg">${escapeHtml(GOALS_EMPTY_STATE_MESSAGE)}</p>
          </div>
        </div>

        <section class="mjt-goals-help" data-testid="goals-in-app-help" aria-label="In-app help for OKRs and Goals">
          <h3 class="mjt-goals-help__title">In-App Help: Migrating Goals &amp; OKRs</h3>
          <ul class="mjt-goals-help__list">
            <li>
              <strong>New OKRs &amp; Strategic Priorities:</strong> Open <strong>${escapeHtml(GOALS_PLANNING_APP_NAME)}</strong>
              to create Priorities, Objectives, Key Results, Critical Numbers, and Huddle check-ins.
            </li>
            <li>
              <strong>Migrate Existing Legacy OKR Tasks:</strong> Invoke the
              <strong>${escapeHtml(GOALS_IMPORT_ACTION_NAME)}</strong> action in ${escapeHtml(GOALS_PLANNING_APP_NAME)} (starting with
              <code>DryRun: true</code>) to import historical <code>PRIORITY_OBJECTIVE</code> and
              <code>KEY_RESULT</code> tasks idempotently.
            </li>
            <li>
              <strong>Operational Tasks:</strong> Continue tracking day-to-day deliverables, action items,
              approvals, and measurable operational tasks here in BizApps Tasks.
            </li>
          </ul>
        </section>
      </div>
    </div>
  </main>
</body>
</html>`;

    const playwrightPath = resolvePlaywrightPath();
    const pw = require(playwrightPath);
    const browser = await pw.chromium.launch({ headless: true });
    const pageErrors = [];
    const consoleErrors = [];

    try {
        const page = await browser.newPage({ viewport: { width: 900, height: 760 } });
        page.on('pageerror', (err) => pageErrors.push(err.message));
        page.on('console', (msg) => {
            if (msg.type() === 'error') {
                consoleErrors.push(msg.text());
            }
        });

        await page.setContent(html, { waitUntil: 'load' });
        await page.waitForSelector('[data-testid="goals-view"]');
        await page.waitForSelector('[data-testid="goals-empty-state"]');
        await page.waitForSelector('[data-testid="goals-in-app-help"]');

        const renderedText = (await page.locator('[data-testid="goals-view"]').innerText()).trim();
        for (const requiredPhrase of [
            GOALS_PLANNING_APP_NAME,
            GOALS_IMPORT_ACTION_NAME,
            'PRIORITY_OBJECTIVE',
            'KEY_RESULT',
            'In-App Help: Migrating Goals & OKRs',
        ]) {
            if (!renderedText.includes(requiredPhrase)) {
                throw new Error(`Missing required phrase in rendered Goals view: "${requiredPhrase}"`);
            }
        }

        const brokenImages = await page.evaluate(() =>
            Array.from(document.querySelectorAll('img')).filter((img) => !img.complete || img.naturalWidth === 0).length,
        );
        const noticeBox = await page.locator('.mjt-goals-notice').boundingBox();
        const emptyBox = await page.locator('[data-testid="goals-empty-state"]').boundingBox();
        const helpBox = await page.locator('[data-testid="goals-in-app-help"]').boundingBox();

        await page.screenshot({ path: screenshotPath, fullPage: true });
        if (!existsSync(screenshotPath)) {
            throw new Error(`Screenshot missing at ${screenshotPath}`);
        }
        const stat = statSync(screenshotPath);
        if (stat.size <= 0) {
            throw new Error(`Screenshot is empty at ${screenshotPath}`);
        }

        if (pageErrors.length > 0 || consoleErrors.length > 0 || brokenImages > 0) {
            throw new Error(JSON.stringify({ pageErrors, consoleErrors, brokenImages }));
        }

        console.log(
            JSON.stringify({
                passed: true,
                pageErrors: pageErrors.length,
                consoleErrors: consoleErrors.length,
                brokenImages,
                boxes: { noticeBox, emptyBox, helpBox },
                screenshotPath,
                screenshotBytes: stat.size,
            }),
        );
    } finally {
        await browser.close();
    }
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
