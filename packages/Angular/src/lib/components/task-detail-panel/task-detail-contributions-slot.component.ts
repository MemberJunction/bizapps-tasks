import {
    ChangeDetectionStrategy,
    Component,
    ComponentRef,
    Input,
    OnChanges,
    OnDestroy,
    SimpleChanges,
    ViewChild,
    ViewContainerRef,
} from '@angular/core';
import { LogError, Metadata, type IMetadataProvider } from '@memberjunction/core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    DiscoverTaskDetailContributions,
    type ResolvedTaskDetailContribution,
    type TaskDetailContributionContext,
    type TaskDetailContributionInstance,
    type TaskDetailContributionLink,
} from '../../task-detail-contribution';

interface MountedContributionEntry {
    Contribution: ResolvedTaskDetailContribution;
    Ref: ComponentRef<TaskDetailContributionInstance>;
}

/**
 * Dynamic host slot rendered inside {@link TaskDetailPanelComponent} that discovers and
 * mounts downstream Open App contributions registered in `MJGlobal.Instance.ClassFactory`
 * for the inspected task and its linked entity records.
 *
 * Renders zero DOM when no downstream contributions match.
 */
@Component({
    selector: 'bizapps-task-detail-contributions',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<ng-container #anchor></ng-container>`,
    styles: [`:host { display: contents; }`],
})
export class TaskDetailContributionsSlotComponent implements OnChanges, OnDestroy {
    @Input() TaskID: string | null = null;
    @Input() TaskEntity: mjBizAppsTasksTaskEntity | null = null;
    @Input() TaskLinks: readonly TaskDetailContributionLink[] = [];
    @Input() Provider: IMetadataProvider | null = null;
    @Input() ReadOnly = false;
    @Input() OpenEntityRecord?: (entityName: string, recordId: string) => void;

    @ViewChild('anchor', { read: ViewContainerRef, static: true })
    private anchor!: ViewContainerRef;

    public mounted: MountedContributionEntry[] = [];

    public ngOnChanges(_changes: SimpleChanges): void {
        this.syncContributions();
    }

    public ngOnDestroy(): void {
        this.unmountAll();
    }

    /** Re-evaluates registered contributions against the current task and links. */
    public syncContributions(): void {
        if (!this.TaskID) {
            this.unmountAll();
            return;
        }

        const resolved = DiscoverTaskDetailContributions(this.TaskLinks ?? []);
        if (resolved.length === 0) {
            this.unmountAll();
            return;
        }

        const sameSet =
            resolved.length === this.mounted.length &&
            resolved.every((entry, idx) => entry.ComponentType === this.mounted[idx]?.Contribution.ComponentType);

        if (sameSet) {
            for (let i = 0; i < resolved.length; i++) {
                this.mounted[i].Contribution = resolved[i];
                this.applyContext(this.mounted[i].Ref, resolved[i]);
            }
            return;
        }

        this.unmountAll();
        if (!this.anchor) {
            return;
        }

        for (const entry of resolved) {
            try {
                const ref = this.anchor.createComponent(entry.ComponentType);
                this.applyContext(ref, entry);
                this.mounted.push({ Contribution: entry, Ref: ref });
            } catch (err) {
                const msg = err instanceof Error ? err.message : String(err);
                LogError(`[bizapps-task-detail-contributions] Failed to mount contribution ${entry.Registration.Key ?? entry.ComponentType.name}: ${msg}`);
            }
        }
    }

    private applyContext(
        ref: ComponentRef<TaskDetailContributionInstance>,
        entry: ResolvedTaskDetailContribution,
    ): void {
        const provider = this.Provider ?? Metadata.Provider;
        const openCallback = this.OpenEntityRecord ?? (() => {});
        const context: TaskDetailContributionContext = {
            TaskID: this.TaskID!,
            TaskEntity: this.TaskEntity,
            TaskLinks: this.TaskLinks ?? [],
            MatchedTaskLinks: entry.MatchedTaskLinks,
            Provider: provider,
            ReadOnly: this.ReadOnly,
            OpenEntityRecord: openCallback,
        };

        const instance = ref.instance;
        if (this.TaskEntity) {
            instance.Record = this.TaskEntity;
        }
        instance.TaskID = context.TaskID;
        instance.TaskEntity = context.TaskEntity;
        instance.TaskLinks = context.TaskLinks;
        instance.MatchedTaskLinks = context.MatchedTaskLinks;
        instance.Provider = context.Provider;
        instance.ReadOnly = context.ReadOnly;
        instance.OpenEntityRecord = context.OpenEntityRecord;

        if (typeof instance.OnTaskContextChanged === 'function') {
            instance.OnTaskContextChanged(context);
        }
        ref.changeDetectorRef.markForCheck();
    }

    private unmountAll(): void {
        this.anchor?.clear();
        this.mounted = [];
    }
}
