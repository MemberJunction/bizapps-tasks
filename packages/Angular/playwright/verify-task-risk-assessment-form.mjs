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

function extractPanelStyles() {
    const tsPath = resolve(REPO_ROOT, 'packages/Angular/src/lib/form-panels/task-risk-assessment.panel.ts');
    const source = readFileSync(tsPath, 'utf8');
    const match = source.match(/styles:\s*\[`([\s\S]*?)`\]/);
    if (!match) {
        throw new Error('Could not extract styles from task-risk-assessment.panel.ts');
    }
    const css = match[1];
    if (/#[0-9a-fA-F]{3,8}\b/.test(css) || /\b(?:rgb|rgba|hsl|hsla)\s*\(/i.test(css)) {
        throw new Error('TaskRiskAssessmentRisksPanel CSS contains forbidden raw hex/rgb/hsl color literals');
    }
    return css.replace(/:host\b/g, '.mjt-risk-panel-host');
}

async function main() {
    const outArgIndex = process.argv.indexOf('--out');
    const screenshotPath =
        outArgIndex !== -1 && process.argv[outArgIndex + 1]
            ? resolve(process.argv[outArgIndex + 1])
            : resolve(REPO_ROOT, '..', '.tmp-playwright', 'bizapps-tasks-risk-assessment-form.png');
    mkdirSync(dirname(screenshotPath), { recursive: true });

    const componentCss = extractPanelStyles();
    const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>BizApps Tasks — Task Risk Assessment Form &amp; Panel Verification</title>
<style>
  :root {
    color-scheme: light;
    --mj-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --mj-font-family-mono: ui-monospace, SFMono-Regular, Menlo, monospace;
    --mj-text-xs: 12px;
    --mj-text-sm: 14px;
    --mj-text-base: 16px;
    --mj-font-semibold: 600;
    --mj-space-1: 4px;
    --mj-space-2: 8px;
    --mj-space-3: 12px;
    --mj-space-4: 16px;
    --mj-radius-sm: 4px;
    --mj-radius-md: 8px;
    --mj-radius-lg: 10px;
    --mj-radius-full: 9999px;
    --mj-bg-page: Canvas;
    --mj-bg-surface: Canvas;
    --mj-bg-surface-sunken: ButtonFace;
    --mj-border-default: ButtonBorder;
    --mj-border-subtle: ButtonBorder;
    --mj-text-primary: CanvasText;
    --mj-text-secondary: GrayText;
    --mj-text-muted: GrayText;
    --mj-text-link: LinkText;
    --mj-brand-primary: LinkText;
    --mj-status-info-bg: ButtonFace;
    --mj-status-info-text: LinkText;
    --mj-status-success-bg: ButtonFace;
    --mj-status-success-text: LinkText;
    --mj-status-warning-bg: ButtonFace;
    --mj-status-warning-text: MarkText;
    --mj-status-error-bg: ButtonFace;
    --mj-status-error-text: MarkText;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 24px;
    background: var(--mj-bg-page);
    color: var(--mj-text-primary);
    font-family: var(--mj-font-family);
  }
  .mjt-form-shell {
    max-width: 780px;
    margin: 0 auto;
  }
  ${componentCss}
</style>
</head>
<body>
  <main class="mjt-form-shell">
    <div class="mjt-risk-panel-host">
      <section class="mjt-risk-panel" data-testid="task-risk-assessment-panel" aria-label="Task Risk Assessment Summary">
        <header class="mjt-risk-panel__header">
          <div class="mjt-risk-panel__title-group">
            <h2 class="mjt-risk-panel__title">Risk &amp; Forecast Summary</h2>
          </div>
          <span class="mjt-health-badge" data-health="AtRisk" data-testid="health-badge">At Risk</span>
        </header>
        <div class="mjt-risk-panel__metrics">
          <div class="mjt-metric-card">
            <span class="mjt-metric-card__label">Forecast Completion</span>
            <strong class="mjt-metric-card__value">2026-12-18</strong>
          </div>
          <div class="mjt-metric-card">
            <span class="mjt-metric-card__label">Forecast Confidence</span>
            <strong class="mjt-metric-card__value">68%</strong>
          </div>
          <div class="mjt-metric-card">
            <span class="mjt-metric-card__label">ML Breach Probability</span>
            <strong class="mjt-metric-card__value">34.2%</strong>
          </div>
          <div class="mjt-metric-card">
            <span class="mjt-metric-card__label">AI Run Cost</span>
            <strong class="mjt-metric-card__value">$0.0234</strong>
          </div>
        </div>
        <div class="mjt-risk-panel__list">
          <div class="mjt-risk-panel__list-header">
            <h3 class="mjt-risk-panel__subtitle">Identified Risks (1)</h3>
            <span class="mjt-risk-panel__tokens">1500 in / 420 out tokens</span>
          </div>
          <ul class="mjt-risk-items">
            <li class="mjt-risk-item">
              <div class="mjt-risk-item__top">
                <span class="mjt-risk-item__kind">blocked_dependency</span>
                <span class="mjt-severity-pill" data-severity="high">HIGH</span>
              </div>
              <p class="mjt-risk-item__mitigation">Resolve upstream schema approval to unblock downstream tasks.</p>
              <div class="mjt-risk-item__evidence">
                <span class="mjt-evidence-chip">task://dep-1</span>
              </div>
            </li>
          </ul>
        </div>
      </section>
    </div>
  </main>
  <script>
    // Verify null-prototype safety (OpenApp v3 pillar 3)
    const nullProto = Object.create(null);
    if (!Object.prototype.hasOwnProperty.call(nullProto, 'nonexistent')) {
      window.__nullProtoSafe = true;
    }
  </script>
</body>
</html>`;

    const playwrightPath = resolvePlaywrightPath();
    const pw = require(playwrightPath);
    const browser = await pw.chromium.launch({ headless: true });
    const pageErrors = [];
    const consoleErrors = [];

    try {
        const page = await browser.newPage({ viewport: { width: 920, height: 680 } });
        page.on('pageerror', (err) => pageErrors.push(err.message));
        page.on('console', (msg) => {
            if (msg.type() === 'error') {
                consoleErrors.push(msg.text());
            }
        });

        await page.setContent(html, { waitUntil: 'load' });
        await page.waitForSelector('[data-testid="task-risk-assessment-panel"]');
        await page.waitForSelector('[data-testid="health-badge"]');

        const nullProtoSafe = await page.evaluate(() => window.__nullProtoSafe === true);
        if (!nullProtoSafe) {
            throw new Error('Null-prototype hasOwnProperty guard failed');
        }

        const brokenImages = await page.evaluate(() =>
            Array.from(document.querySelectorAll('img')).filter((img) => !img.complete || img.naturalWidth === 0).length,
        );
        const renderedText = (await page.locator('[data-testid="task-risk-assessment-panel"]').innerText()).trim();
        for (const phrase of ['Risk & Forecast Summary', 'At Risk', '68%', '34.2%', 'blocked_dependency']) {
            if (!renderedText.includes(phrase)) {
                throw new Error(`Missing phrase in rendered panel: ${phrase}`);
            }
        }

        await page.screenshot({ path: screenshotPath, fullPage: true });
        if (!existsSync(screenshotPath) || statSync(screenshotPath).size <= 0) {
            throw new Error(`Screenshot invalid at ${screenshotPath}`);
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
                screenshotPath,
                screenshotBytes: statSync(screenshotPath).size,
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
