import { Component, ChangeDetectionStrategy, inject, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Metadata } from '@memberjunction/core';
import { OpenTaskRecord } from '../open-task-record';
import { MyTasksComponent } from '../components/my-tasks/my-tasks.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskRow } from '../components/task-list/task-list.component';

@Component({
    selector: 'bizapps-my-tasks-page',
    standalone: true,
    imports: [CommonModule, MyTasksComponent, TaskDetailPanelComponent, TaskEditPanelComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar">
                            <i class="fa-solid fa-user-check" aria-hidden="true"></i>
                        </div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">My Tasks &amp; Deliverables</h1>
                            <p class="mjt-subtitle">Tasks assigned to you across all projects, committees, and workspaces.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mjt-body-card">
                <bizapps-my-tasks
                    [PersonID]="PersonID || ''"
                    (AfterTaskSelected)="OnTaskSelected($event)"
                    (TaskDoubleClicked)="OpenFullRecord($event.ID)">
                </bizapps-my-tasks>
            </div>

            @if (PanelMode !== 'none') {
                <div class="mjt-panel-backdrop" (click)="PanelMode = 'none'"></div>
                <aside class="mjt-side-panel">
                    @if (PanelMode === 'detail') {
                        <bizapps-task-detail-panel
                            [TaskID]="SelectedTaskID"
                            [PersonID]="PersonID"
                            (EditRequested)="PanelMode = 'edit'"
                            (OpenRecordRequested)="OpenFullRecord($event)"
                            (Close)="PanelMode = 'none'">
                        </bizapps-task-detail-panel>
                    }
                    @if (PanelMode === 'edit') {
                        <bizapps-task-edit-panel
                            [TaskID]="SelectedTaskID"
                            (Saved)="PanelMode = 'none'"
                            (Cancel)="PanelMode = 'none'">
                        </bizapps-task-edit-panel>
                    }
                </aside>
            }
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-page-wrap { display: flex; flex-direction: column; gap: 16px; padding: 16px; box-sizing: border-box; }
        .mjt-header-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
        .mjt-header-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
        .mjt-identity { display: flex; align-items: center; gap: 14px; }
        .mjt-avatar {
            width: 48px; height: 48px; border-radius: var(--mj-radius-md, 8px);
            background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: #ffffff;
            display: flex; align-items: center; justify-content: center; font-size: 20px;
            box-shadow: 0 4px 10px rgba(16, 185, 129, 0.25); flex-shrink: 0;
        }
        .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
        .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }
        .mjt-body-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
        .mjt-panel-backdrop { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45); z-index: 999; }
        .mjt-side-panel {
            position: fixed; top: 0; right: 0; bottom: 0; width: 540px; max-width: 90vw;
            background: var(--mj-bg-surface-card, #ffffff); z-index: 1000;
            box-shadow: -4px 0 24px rgba(0, 0, 0, 0.15); overflow-y: auto;
        }
    `]
})
export class MyTasksPageComponent implements OnInit {
    public PersonID: string | null = null;
    public SelectedTaskID: string | null = null;
    public PanelMode: 'none' | 'detail' | 'edit' = 'none';

    private cdr = inject(ChangeDetectorRef);

    public OpenFullRecord(taskID: string | null): void {
        OpenTaskRecord(taskID);
    }

    ngOnInit(): void {
        const md = new Metadata();
        this.PersonID = md.CurrentUser?.Email ?? null;
        this.cdr.markForCheck();
    }

    public OnTaskSelected(row: TaskRow): void {
        this.SelectedTaskID = row.ID;
        this.PanelMode = 'detail';
        this.cdr.markForCheck();
    }
}
