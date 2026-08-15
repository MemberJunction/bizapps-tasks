import { Component, ChangeDetectionStrategy, OnInit, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';

interface TemplateCard {
    ID: string;
    Name: string;
    Description: string | null;
    CategoryID: string | null;
    Category: string | null;
    IsActive: boolean;
}

@Component({
    selector: 'bizapps-templates-page',
    standalone: true,
    imports: [CommonModule, TaskTemplateWizardComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar">
                            <i class="fa-solid fa-copy" aria-hidden="true"></i>
                        </div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">Task Templates &amp; Workflows</h1>
                            <p class="mjt-subtitle">Standardized repeatable project task templates and automated workflow generators.</p>
                        </div>
                    </div>
                    <button type="button" class="mjt-btn-primary" (click)="ShowWizard = true">
                        <i class="fa-solid fa-wand-magic-sparkles"></i> Instantiate Template
                    </button>
                </div>
            </div>

            <div class="mjt-body-card">
                @if (Loading) {
                    <div class="mjt-loading">Loading task templates...</div>
                } @else if (Templates.length === 0) {
                    <div class="mjt-empty">
                        <i class="fa-solid fa-copy"></i>
                        <span>No task templates created yet.</span>
                    </div>
                } @else {
                    <div class="mjt-template-grid">
                        @for (tmpl of Templates; track tmpl.ID) {
                            <div class="mjt-template-card">
                                <div class="mjt-template-head">
                                    <h3 class="mjt-template-name">{{ tmpl.Name }}</h3>
                                    @if (tmpl.Category) {
                                        <span class="mjt-category-badge">{{ tmpl.Category }}</span>
                                    }
                                </div>
                                <p class="mjt-template-desc">{{ tmpl.Description || 'No description provided.' }}</p>
                                <div class="mjt-template-foot">
                                    <button type="button" class="mjt-btn-use" (click)="SelectedTemplateID = tmpl.ID; ShowWizard = true">
                                        <i class="fa-solid fa-play"></i> Run Template
                                    </button>
                                </div>
                            </div>
                        }
                    </div>
                }
            </div>

            @if (ShowWizard) {
                <div class="mjt-panel-backdrop" (click)="CloseWizard()"></div>
                <aside class="mjt-side-panel">
                    <bizapps-task-template-wizard
                        (Created)="CloseWizard(); LoadTemplates()"
                        (Cancelled)="CloseWizard()">
                    </bizapps-task-template-wizard>
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
        .mjt-header-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
        .mjt-identity { display: flex; align-items: center; gap: 14px; }
        .mjt-avatar {
            width: 48px; height: 48px; border-radius: var(--mj-radius-md, 8px);
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #ffffff;
            display: flex; align-items: center; justify-content: center; font-size: 20px;
            box-shadow: 0 4px 10px rgba(245, 158, 11, 0.25); flex-shrink: 0;
        }
        .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
        .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }
        .mjt-btn-primary {
            padding: 6px 14px; border-radius: var(--mj-radius-sm, 6px); border: none;
            background: var(--mj-brand-primary, #0076b6); color: #ffffff;
            font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;
        }
        .mjt-body-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
        .mjt-template-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px; }
        .mjt-template-card {
            background: var(--mj-bg-surface-sunken, #f8fafc); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-md, 8px); padding: 14px 16px; display: flex; flex-direction: column; gap: 10px;
        }
        .mjt-template-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; }
        .mjt-template-name { margin: 0; font-size: 14px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-category-badge { font-size: 11px; font-weight: 600; color: #0284c7; background: rgba(2, 132, 199, 0.12); padding: 2px 8px; border-radius: 4px; }
        .mjt-template-desc { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); line-height: 1.4; flex: 1; }
        .mjt-template-foot { border-top: 1px dashed var(--mj-border-default, #e2e8f0); padding-top: 8px; }
        .mjt-btn-use {
            width: 100%; padding: 6px 10px; font-size: 12px; font-weight: 600;
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #cbd5e1);
            border-radius: var(--mj-radius-sm, 6px); color: var(--mj-brand-primary, #0076b6); cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 6px;
        }
        .mjt-btn-use:hover { background: var(--mj-brand-primary, #0076b6); color: #ffffff; border-color: var(--mj-brand-primary, #0076b6); }
        .mjt-loading, .mjt-empty { padding: 36px; text-align: center; color: var(--mj-text-muted, #64748b); font-size: 13px; }
        .mjt-panel-backdrop { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45); z-index: 999; }
        .mjt-side-panel {
            position: fixed; top: 0; right: 0; bottom: 0; width: 540px; max-width: 90vw;
            background: var(--mj-bg-surface-card, #ffffff); z-index: 1000;
            box-shadow: -4px 0 24px rgba(0, 0, 0, 0.15); overflow-y: auto;
        }
    `]
})
export class TemplatesPageComponent implements OnInit {
    public Templates: TemplateCard[] = [];
    public Loading = false;
    public ShowWizard = false;
    public SelectedTemplateID: string | null = null;

    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void {
        this.LoadTemplates();
    }

    public async LoadTemplates(): Promise<void> {
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
            const res = await rv.RunView<TemplateCard>({
                EntityName: 'MJ_BizApps_Tasks: Task Templates',
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            });
            if (res.Success && res.Results) {
                this.Templates = res.Results;
            }
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public CloseWizard(): void {
        this.ShowWizard = false;
        this.SelectedTemplateID = null;
        this.cdr.markForCheck();
    }
}
