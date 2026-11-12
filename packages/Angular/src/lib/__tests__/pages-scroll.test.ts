import '@angular/compiler';
import { describe, expect, it } from 'vitest';
import { type Type } from '@angular/core';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';
import { MyTasksPageComponent } from '../pages/my-tasks.page';
import { ApprovalsPageComponent } from '../pages/approvals.page';
import { TemplatesPageComponent } from '../pages/templates.page';

function componentCss(cmp: Type<unknown>): string {
    const def = (cmp as unknown as { ɵcmp?: { styles?: string[] } }).ɵcmp;
    const raw = def?.styles ?? [];
    return raw.join('\n').replace(/\s+/g, ' ');
}

function ruleBody(css: string, selector: string): string {
    const at = css.indexOf(selector);
    if (at === -1) return '';
    const open = css.indexOf('{', at);
    const close = css.indexOf('}', open);
    return open === -1 || close === -1 ? '' : css.slice(open + 1, close);
}

describe('Tasks pages — scroll container rules (bc-aidp-next-golive#392)', () => {
    const cases: Array<{ name: string; cmp: Type<unknown>; wrapperSelector: string }> = [
        { name: 'TasksDashboardPageComponent', cmp: TasksDashboardPageComponent, wrapperSelector: '.mjt-dashboard' },
        { name: 'MyTasksPageComponent', cmp: MyTasksPageComponent, wrapperSelector: '.mjt-page-wrap' },
        { name: 'ApprovalsPageComponent', cmp: ApprovalsPageComponent, wrapperSelector: '.mjt-page-wrap' },
        { name: 'TemplatesPageComponent', cmp: TemplatesPageComponent, wrapperSelector: '.mjt-page-wrap' },
    ];

    for (const { name, cmp, wrapperSelector } of cases) {
        describe(name, () => {
            const css = componentCss(cmp);

            it('hides overflow on :host and sizes it to the shell content pane', () => {
                const host = ruleBody(css, ':host') || ruleBody(css, '[_nghost');
                expect(host).toContain('display: flex');
                expect(host).toContain('flex-direction: column');
                expect(host).toContain('height: 100%');
                expect(host).toContain('min-height: 0');
                expect(host).toContain('overflow: hidden');
            });

            it(`scrolls ${wrapperSelector} vertically within the host`, () => {
                const layout = ruleBody(css, wrapperSelector);
                expect(layout).toContain('height: 100%');
                expect(layout).toContain('min-height: 0');
                expect(layout).toContain('overflow-y: auto');
            });
        });
    }
});
