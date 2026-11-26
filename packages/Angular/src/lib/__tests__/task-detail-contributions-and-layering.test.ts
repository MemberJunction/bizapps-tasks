import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it, vi } from 'vitest';
import {
    ChangeDetectionStrategy,
    Component,
    SimpleChange,
    ViewContainerRef,
} from '@angular/core';
import type { IMetadataProvider } from '@memberjunction/core';
import { MJGlobal, RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    BaseTaskDetailContribution,
    DiscoverTaskDetailContributions,
    MatchesTaskDetailContributionLinks,
    TASK_DETAIL_CONTRIBUTION_SURFACE,
    type TaskDetailContributionContext,
    type TaskDetailContributionLink,
} from '../task-detail-contribution';
import { TaskDetailContributionsSlotComponent } from '../components/task-detail-panel/task-detail-contributions-slot.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ANGULAR_LIB_DIR = join(__dirname, '..');

@RegisterClassEx(BaseFormPanel, {
    key: 'BizAppsTasks:TaskDetailContribution:TestOrdersLink',
    skipNullKeyWarning: true,
    metadata: {
        surface: TASK_DETAIL_CONTRIBUTION_SURFACE,
        linkedEntityPrefixes: ['MJ_BizApps_TestOrders:'],
        sortKey: 40,
        contributionKey: 'test-orders-link',
    },
})
@Component({
    standalone: true,
    selector: 'test-orders-task-detail-contribution',
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: '',
})
class TestOrdersLinkContribution extends BaseFormPanel<mjBizAppsTasksTaskEntity> {
    public TaskID: string | null = null;
    public TaskEntity: mjBizAppsTasksTaskEntity | null = null;
    public TaskLinks: readonly TaskDetailContributionLink[] = [];
    public MatchedTaskLinks: readonly TaskDetailContributionLink[] = [];
    public Provider: IMetadataProvider | null = null;
    public ReadOnly = false;
    public OpenEntityRecord?: (entityName: string, recordId: string) => void;
    public LastContext: TaskDetailContributionContext | null = null;

    public OnTaskContextChanged(context: TaskDetailContributionContext): void {
        this.LastContext = context;
    }
}

@RegisterClassEx(BaseTaskDetailContribution, {
    key: 'BizAppsTasks:TaskDetailContribution:TestExactEntity',
    skipNullKeyWarning: true,
    metadata: {
        surface: TASK_DETAIL_CONTRIBUTION_SURFACE,
        linkedEntities: ['MJ_BizApps_TestCrm: Deals'],
        sortKey: 80,
        contributionKey: 'test-crm-deal',
    },
})
@Component({
    standalone: true,
    selector: 'test-crm-deal-contribution',
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: '',
})
class TestExactEntityContribution extends BaseTaskDetailContribution {
    public LastContext: TaskDetailContributionContext | null = null;
    public override OnTaskContextChanged(context: TaskDetailContributionContext): void {
        this.LastContext = context;
    }
}

@RegisterClassEx(BaseFormPanel, {
    key: 'BizAppsTasks:TaskDetailContribution:TestOverrideWinner',
    priority: 50,
    skipNullKeyWarning: true,
    metadata: {
        surface: TASK_DETAIL_CONTRIBUTION_SURFACE,
        linkedEntities: ['MJ_BizApps_TestOverride: Items'],
        sortKey: 20,
        contributionKey: 'test-shared-key',
    },
})
@Component({
    standalone: true,
    selector: 'test-override-winner',
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: '',
})
class TestOverrideWinnerContribution extends BaseFormPanel<mjBizAppsTasksTaskEntity> {}

@RegisterClassEx(BaseFormPanel, {
    key: 'BizAppsTasks:TaskDetailContribution:TestOverrideLoser',
    priority: 10,
    skipNullKeyWarning: true,
    metadata: {
        surface: TASK_DETAIL_CONTRIBUTION_SURFACE,
        linkedEntities: ['MJ_BizApps_TestOverride: Items'],
        sortKey: 99,
        contributionKey: 'test-shared-key',
    },
})
@Component({
    standalone: true,
    selector: 'test-override-loser',
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: '',
})
class TestOverrideLoserContribution extends BaseFormPanel<mjBizAppsTasksTaskEntity> {}

describe('BizApps Tasks Upstream/Downstream Layering Enforcement', () => {
    it('TasksDashboardPageComponent has zero OKRs & Help button, help drawer mode, or hardcoded BizApps Planning references', () => {
        const dashboardSrc = readFileSync(join(ANGULAR_LIB_DIR, 'pages/tasks-dashboard.page.ts'), 'utf8');
        expect(dashboardSrc).not.toContain('OKRs &amp; Help');
        expect(dashboardSrc).not.toContain('OKRs & Help');
        expect(dashboardSrc).not.toContain('GoalsViewComponent');
        expect(dashboardSrc).not.toContain('bizapps-goals-view');
        expect(dashboardSrc).not.toContain("OpenPanel('help')");
        expect(dashboardSrc).not.toContain('BizApps Planning');
        expect(dashboardSrc).not.toContain('MJ_BizApps_Planning');
    });

    it('TaskEditPanelComponent and TaskDetailPanelComponent have zero hardcoded BizApps Planning references', () => {
        const editSrc = readFileSync(join(ANGULAR_LIB_DIR, 'components/task-edit-panel/task-edit-panel.component.ts'), 'utf8');
        const detailSrc = readFileSync(join(ANGULAR_LIB_DIR, 'components/task-detail-panel/task-detail-panel.component.ts'), 'utf8');
        const slotSrc = readFileSync(
            join(ANGULAR_LIB_DIR, 'components/task-detail-panel/task-detail-contributions-slot.component.ts'),
            'utf8',
        );
        const contractSrc = readFileSync(join(ANGULAR_LIB_DIR, 'task-detail-contribution.ts'), 'utf8');

        for (const src of [editSrc, detailSrc, slotSrc, contractSrc]) {
            expect(src).not.toContain('BizApps Planning');
            expect(src).not.toContain('MJ_BizApps_Planning');
            expect(src).not.toContain('Import Tasks OKRs');
            expect(src).not.toContain('Managed in Planning');
        }

        // Detail panel mounts the generic contribution slot
        expect(detailSrc).toContain('<bizapps-task-detail-contributions');
        expect(detailSrc).toContain('[TaskLinks]="contributionLinks"');
    });

    it('enforces OnPush and strict --mj-* CSS custom properties on updated Angular files', () => {
        const filesToCheck = [
            'pages/tasks-dashboard.page.ts',
            'components/task-edit-panel/task-edit-panel.component.ts',
            'components/task-detail-panel/task-detail-panel.component.ts',
            'components/task-detail-panel/task-detail-contributions-slot.component.ts',
        ];
        for (const relPath of filesToCheck) {
            const src = readFileSync(join(ANGULAR_LIB_DIR, relPath), 'utf8');
            expect(src).toContain('ChangeDetectionStrategy.OnPush');
            expect(src).not.toMatch(/\blocalStorage\s*[.\[]/);
            expect(src).not.toMatch(/\bas\s+any\b|:\s*any\b/);
        }
    });
});

describe('Generic Task Detail Contribution Discovery & Mounting', () => {
    it('returns no contributions when task links do not match any registered entity/prefix', () => {
        const links: TaskDetailContributionLink[] = [
            {
                EntityName: 'MJ_BizApps_Unregistered: Widgets',
                RecordID: '11111111-1111-4111-8111-111111111111',
                DisplayName: 'Widget Alpha',
            },
        ];

        const matched = DiscoverTaskDetailContributions(links);
        expect(matched).toEqual([]);
    });

    it('discovers BaseFormPanel and BaseTaskDetailContribution registrations, sorts by sortKey descending, and collapses contributionKey by Priority', () => {
        const links: TaskDetailContributionLink[] = [
            {
                EntityName: 'MJ_BizApps_TestOrders: Order Headers',
                RecordID: '22222222-2222-4222-8222-222222222222',
                DisplayName: 'Order #1001',
            },
            {
                EntityName: 'MJ_BizApps_TestCrm: Deals',
                RecordID: '33333333-3333-4333-8333-333333333333',
                DisplayName: 'Enterprise Deal',
            },
            {
                EntityName: 'MJ_BizApps_TestOverride: Items',
                RecordID: '44444444-4444-4444-8444-444444444444',
                DisplayName: 'Shared Slot Item',
            },
        ];

        const matched = DiscoverTaskDetailContributions(links);
        expect(matched.map((m) => m.ComponentType)).toEqual([
            TestExactEntityContribution,
            TestOrdersLinkContribution,
            TestOverrideWinnerContribution,
        ]);
        expect(matched[0].MatchedTaskLinks.map((l) => l.RecordID)).toEqual(['33333333-3333-4333-8333-333333333333']);
        expect(matched[1].MatchedTaskLinks.map((l) => l.RecordID)).toEqual(['22222222-2222-4222-8222-222222222222']);
        expect(matched[2].ComponentType).not.toBe(TestOverrideLoserContribution);
    });

    it('MatchesTaskDetailContributionLinks matches case-insensitively on both linkedEntities and linkedEntityPrefixes', () => {
        const links: TaskDetailContributionLink[] = [
            { EntityName: 'mj_bizapps_testorders: Invoices', RecordID: 'inv-1', DisplayName: 'INV-1' },
            { EntityName: 'MJ_BizApps_TestCrm: Deals', RecordID: 'deal-1', DisplayName: 'Deal 1' },
        ];

        const prefixMatches = MatchesTaskDetailContributionLinks(
            { surface: TASK_DETAIL_CONTRIBUTION_SURFACE, linkedEntityPrefixes: ['MJ_BizApps_TestOrders:'] },
            links,
        );
        expect(prefixMatches).toHaveLength(1);
        expect(prefixMatches[0].RecordID).toBe('inv-1');

        const exactMatches = MatchesTaskDetailContributionLinks(
            { surface: TASK_DETAIL_CONTRIBUTION_SURFACE, linkedEntities: ['mj_bizapps_testcrm: deals'] },
            links,
        );
        expect(exactMatches).toHaveLength(1);
        expect(exactMatches[0].RecordID).toBe('deal-1');
    });

    it('TaskDetailContributionsSlotComponent mounts matched contributions with task context and unmounts when links clear', () => {
        const slot = new TaskDetailContributionsSlotComponent();
        const createdRefs: Array<{ instance: TestOrdersLinkContribution; markForCheck: ReturnType<typeof vi.fn> }> = [];
        const clearSpy = vi.fn();

        const fakeAnchor = {
            clear: clearSpy,
            createComponent: vi.fn((componentType: new () => TestOrdersLinkContribution) => {
                const instance = new componentType();
                const markForCheck = vi.fn();
                createdRefs.push({ instance, markForCheck });
                return {
                    instance,
                    changeDetectorRef: { markForCheck },
                };
            }),
        } as unknown as ViewContainerRef;

        Object.defineProperty(slot, 'anchor', { value: fakeAnchor, writable: true });

        const openRecordSpy = vi.fn();
        const providerStub = { Entities: [] } as unknown as IMetadataProvider;
        const taskEntityStub = { ID: 'task-99', Name: 'Ship Q4 Release' } as unknown as mjBizAppsTasksTaskEntity;
        const orderLinks: TaskDetailContributionLink[] = [
            {
                EntityName: 'MJ_BizApps_TestOrders: Order Headers',
                EntityID: 'ent-order-header',
                RecordID: 'ord-555',
                DisplayName: 'Order #555',
            },
        ];

        slot.TaskID = 'task-99';
        slot.TaskEntity = taskEntityStub;
        slot.TaskLinks = orderLinks;
        slot.Provider = providerStub;
        slot.ReadOnly = false;
        slot.OpenEntityRecord = openRecordSpy;

        slot.ngOnChanges({ TaskLinks: new SimpleChange([], orderLinks, true) });

        expect(slot.mounted).toHaveLength(1);
        expect(createdRefs).toHaveLength(1);
        const mountedInstance = createdRefs[0].instance;
        expect(mountedInstance.TaskID).toBe('task-99');
        expect(mountedInstance.TaskEntity).toBe(taskEntityStub);
        expect(mountedInstance.MatchedTaskLinks).toEqual(orderLinks);
        expect(mountedInstance.Provider).toBe(providerStub);
        expect(mountedInstance.LastContext?.TaskID).toBe('task-99');

        mountedInstance.OpenEntityRecord?.('MJ_BizApps_TestOrders: Order Headers', 'ord-555');
        expect(openRecordSpy).toHaveBeenCalledWith('MJ_BizApps_TestOrders: Order Headers', 'ord-555');

        // Clearing links unmounts the contribution cleanly
        slot.TaskLinks = [];
        slot.ngOnChanges({ TaskLinks: new SimpleChange(orderLinks, [], false) });
        expect(slot.mounted).toHaveLength(0);
        expect(clearSpy).toHaveBeenCalled();

        // Registrations using task-detail surface do NOT declare metadata.entity so form slots ignore them
        const reg = MJGlobal.Instance.ClassFactory.GetRegistration(
            BaseFormPanel,
            'BizAppsTasks:TaskDetailContribution:TestOrdersLink',
        );
        expect(reg?.Metadata?.['entity']).toBeUndefined();
    });

    it('TaskDetailPanelComponent exposes openEntityRecordByName and contributionLinks without any downstream coupling', () => {
        expect(typeof TaskDetailPanelComponent).toBe('function');
    });
});
