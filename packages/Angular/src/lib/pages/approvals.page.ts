import { Component, ChangeDetectionStrategy, inject, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Metadata } from '@memberjunction/core';
import { ApprovalInboxComponent } from '../components/approval-inbox/approval-inbox.component';
import { DecisionRecordedEvent } from '../components/approval-decision-panel/approval-decision-panel.component';

@Component({
    selector: 'bizapps-approvals-page',
    standalone: true,
    imports: [CommonModule, ApprovalInboxComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar">
                            <i class="fa-solid fa-stamp" aria-hidden="true"></i>
                        </div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">Approvals &amp; Decisions Inbox</h1>
                            <p class="mjt-subtitle">Review pending task decision requests, approvals, and sign-offs.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mjt-body-card">
                <bizapps-approval-inbox
                    [ApproverPersonID]="PersonID || ''"
                    (DecisionRecorded)="OnDecisionRecorded($event)">
                </bizapps-approval-inbox>
            </div>
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
            background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); color: #ffffff;
            display: flex; align-items: center; justify-content: center; font-size: 20px;
            box-shadow: 0 4px 10px rgba(139, 92, 246, 0.25); flex-shrink: 0;
        }
        .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
        .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }
        .mjt-body-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
    `]
})
export class ApprovalsPageComponent implements OnInit {
    public PersonID: string | null = null;

    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void {
        const md = new Metadata();
        this.PersonID = md.CurrentUser?.Email ?? null;
        this.cdr.markForCheck();
    }

    public OnDecisionRecorded(event: DecisionRecordedEvent): void {
        // Handled automatically by approval-inbox component
    }
}
