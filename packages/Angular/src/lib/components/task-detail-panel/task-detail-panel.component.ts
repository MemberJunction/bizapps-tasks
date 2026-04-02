import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Metadata, RunView } from '@memberjunction/core';
import { TaskAssigneeInfo } from '../task-assignee-list/task-assignee-list.component';

interface ActivityEntry {
    Type: 'activity' | 'comment';
    Timestamp: Date;
    PersonName?: string;
    Content: string;
    ActivityType?: string;
}

@Component({
    selector: 'bizapps-task-detail-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, FormsModule],
    template: `
        @if (TaskID) {
            <div class="detail-panel">
                @if (loading) {
                    <div class="panel-loading">Loading...</div>
                } @else if (task) {
                    <!-- Header -->
                    <div class="panel-header">
                        <h2 class="task-title">{{ task.Name }}</h2>
                        <div class="header-actions">
                            <button class="btn-edit" (click)="EditRequested.emit(TaskID!)">
                                <i class="fa-solid fa-pen"></i> Edit
                            </button>
                            <button class="btn-close" (click)="Close.emit()">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Status + Priority -->
                    <div class="field-row">
                        <div class="field-block">
                            <label>Status</label>
                            <span [class]="'status-badge status-' + task.Status.toLowerCase()">
                                {{ formatStatus(task.Status) }}
                            </span>
                        </div>
                        <div class="field-block">
                            <label>Priority</label>
                            <div class="priority-display">
                                <span [class]="'priority-dot priority-' + task.Priority.toLowerCase()"></span>
                                {{ task.Priority }}
                            </div>
                        </div>
                    </div>

                    <!-- Parent Task -->
                    @if (parentTaskName) {
                        <div class="field-block">
                            <label>Parent Task</label>
                            <span class="parent-link">
                                <i class="fa-solid fa-folder-open"></i>
                                {{ parentTaskName }}
                            </span>
                        </div>
                    }

                    <!-- Progress -->
                    @if (task.PercentComplete > 0 || task.Status === 'InProgress') {
                        <div class="field-block">
                            <label>Progress</label>
                            <div class="progress-row">
                                <div class="progress-bar">
                                    <div class="progress-fill" [style.width.%]="task.PercentComplete"
                                         [class.complete]="task.PercentComplete === 100"></div>
                                </div>
                                <span class="progress-pct">{{ task.PercentComplete }}%</span>
                            </div>
                        </div>
                    }

                    <!-- Dates + Hours -->
                    <div class="field-row">
                        @if (task.DueAt) {
                            <div class="field-block">
                                <label>Due</label>
                                <span>{{ task.DueAt | date:'MMM d, y' }}</span>
                            </div>
                        }
                        @if (task.StartedAt) {
                            <div class="field-block">
                                <label>Started</label>
                                <span>{{ task.StartedAt | date:'MMM d, y' }}</span>
                            </div>
                        }
                    </div>
                    <div class="field-row">
                        @if (task.HoursEstimated) {
                            <div class="field-block">
                                <label>Est. Hours</label>
                                <span>{{ task.HoursEstimated }}</span>
                            </div>
                        }
                        @if (task.HoursActual) {
                            <div class="field-block">
                                <label>Actual Hours</label>
                                <span>{{ task.HoursActual }}</span>
                            </div>
                        }
                    </div>

                    <!-- Description -->
                    @if (task.Description) {
                        <div class="field-block">
                            <label>Description</label>
                            <p class="desc-text">{{ task.Description }}</p>
                        </div>
                    }

                    <!-- Blocked Reason -->
                    @if (task.BlockedReason) {
                        <div class="blocked-banner">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            <div>
                                <strong>Blocked</strong>
                                <p>{{ task.BlockedReason }}</p>
                            </div>
                        </div>
                    }

                    <!-- Assignees -->
                    <div class="field-block">
                        <label>Assignees</label>
                        @if (assignees.length === 0) {
                            <span class="empty-text">No assignees</span>
                        }
                        @for (a of assignees; track a.AssigneeRecordID) {
                            <div class="assignee-row">
                                <span class="assignee-dot" [ngClass]="'dot-' + a.Status.toLowerCase()"></span>
                                <span class="assignee-name">{{ a.DisplayName }}</span>
                                @if (a.RoleName) {
                                    <span class="assignee-role">{{ a.RoleName }}</span>
                                }
                            </div>
                        }
                    </div>

                    <!-- Activity + Comments -->
                    <div class="field-block">
                        <label>Activity</label>
                        <div class="comment-input-row">
                            <input type="text" [(ngModel)]="newComment"
                                   placeholder="Add a comment..." class="comment-input"
                                   (keydown.enter)="postComment()" />
                            <button class="btn-post" (click)="postComment()" [disabled]="!newComment.trim()">Post</button>
                        </div>
                        <div class="timeline">
                            @for (entry of timeline; track entry.Timestamp) {
                                <div class="timeline-entry" [class.is-comment]="entry.Type === 'comment'">
                                    <span class="entry-time">{{ entry.Timestamp | date:'M/d/yy, h:mm a' }}</span>
                                    @if (entry.PersonName) {
                                        <span class="entry-person">{{ entry.PersonName }}</span>
                                    }
                                    <span class="entry-content">{{ entry.Content }}</span>
                                </div>
                            }
                            @if (timeline.length === 0) {
                                <span class="empty-text">No activity yet</span>
                            }
                        </div>
                    </div>
                }
            </div>
        }
    `,
    styles: [`
        :host {
            display: block;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            -webkit-font-smoothing: antialiased;
        }
        .detail-panel { padding: 28px 24px; }
        .panel-loading { padding: 64px; text-align: center; color: #94a3b8; font-size: 15px; }

        /* ─── Header ─── */
        .panel-header {
            display: flex; justify-content: space-between; align-items: flex-start;
            gap: 12px; margin-bottom: 24px;
        }
        .task-title {
            font-size: 22px; font-weight: 700; color: #0f172a; margin: 0;
            letter-spacing: -0.5px; line-height: 1.3;
        }
        .header-actions { display: flex; gap: 8px; flex-shrink: 0; }
        .btn-edit {
            padding: 7px 14px; border: none; border-radius: 8px;
            background: #6366f1; color: #fff; font-size: 13px; font-weight: 600;
            cursor: pointer; font-family: inherit;
            display: inline-flex; align-items: center; gap: 5px;
            transition: all 0.15s;
        }
        .btn-edit:hover { background: #4f46e5; }
        .btn-close {
            padding: 7px 10px; border: 1px solid #e2e8f0; border-radius: 8px;
            background: #fff; color: #94a3b8; font-size: 14px; cursor: pointer;
            transition: all 0.15s;
        }
        .btn-close:hover { background: #f8fafc; color: #64748b; }

        /* ─── Fields ─── */
        .field-row { display: flex; gap: 24px; margin-bottom: 16px; }
        .field-block { margin-bottom: 16px; }
        .field-block label {
            display: block; font-size: 11px; font-weight: 700; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .field-block span, .field-block p { font-size: 14px; color: #1e293b; }
        .desc-text { margin: 0; line-height: 1.6; white-space: pre-wrap; }
        .empty-text { font-size: 13px; color: #cbd5e1; font-style: italic; }
        .parent-link {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 14px; color: #6366f1; font-weight: 500;
        }
        .parent-link i { font-size: 12px; }
        .link-row {
            display: flex; align-items: center; gap: 8px; padding: 5px 0;
            font-size: 13px; color: #475569;
        }
        .link-icon { font-size: 11px; color: #94a3b8; }
        .link-entity { font-weight: 600; color: #1e293b; }
        .link-desc { color: #94a3b8; }

        /* ─── Status Badge ─── */
        .status-badge {
            display: inline-block; font-size: 12px; font-weight: 600; padding: 3px 10px;
            border-radius: 6px; white-space: nowrap;
        }
        .status-open { background: #fef3c7; color: #92400e; }
        .status-inprogress { background: #e0e7ff; color: #3730a3; }
        .status-completed { background: #d1fae5; color: #065f46; }
        .status-blocked { background: #fef2f2; color: #991b1b; }
        .status-cancelled { background: #f1f5f9; color: #64748b; }

        /* ─── Priority ─── */
        .priority-display {
            display: flex; align-items: center; gap: 6px; font-size: 14px; color: #1e293b;
        }
        .priority-dot { width: 8px; height: 8px; border-radius: 50%; }
        .priority-critical, .priority-high { background: #f43f5e; }
        .priority-medium { background: #f59e0b; }
        .priority-low { background: #10b981; }

        /* ─── Progress ─── */
        .progress-row { display: flex; align-items: center; gap: 10px; }
        .progress-bar {
            flex: 1; max-width: 200px; height: 6px; background: #e2e8f0;
            border-radius: 3px; overflow: hidden;
        }
        .progress-fill {
            height: 100%; background: #6366f1; border-radius: 3px; transition: width 0.3s;
        }
        .progress-fill.complete { background: #10b981; }
        .progress-pct { font-size: 13px; font-weight: 600; color: #64748b; }

        /* ─── Blocked Banner ─── */
        .blocked-banner {
            display: flex; gap: 10px; padding: 12px 16px; margin-bottom: 16px;
            background: #fef2f2; border-radius: 10px; border: 1px solid #fecaca;
        }
        .blocked-banner i { color: #ef4444; font-size: 16px; margin-top: 2px; }
        .blocked-banner strong { font-size: 13px; color: #991b1b; }
        .blocked-banner p { font-size: 13px; color: #991b1b; margin: 2px 0 0; line-height: 1.4; }

        /* ─── Assignees ─── */
        .assignee-row {
            display: flex; align-items: center; gap: 8px; padding: 6px 0;
        }
        .assignee-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
        .dot-pending { background: #94a3b8; }
        .dot-inprogress { background: #6366f1; }
        .dot-completed { background: #10b981; }
        .assignee-name { font-size: 14px; color: #1e293b; font-weight: 500; }
        .assignee-role {
            font-size: 11px; color: #94a3b8; background: #f1f5f9;
            padding: 1px 8px; border-radius: 6px;
        }

        /* ─── Comment Input ─── */
        .comment-input-row { display: flex; gap: 8px; margin-bottom: 16px; }
        .comment-input {
            flex: 1; padding: 8px 12px; border: 1px solid #e2e8f0; border-radius: 10px;
            font-size: 13px; font-family: inherit;
        }
        .comment-input:focus {
            outline: none; border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }
        .btn-post {
            padding: 8px 16px; border: none; border-radius: 10px;
            background: #6366f1; color: #fff; font-size: 13px; font-weight: 600;
            cursor: pointer; font-family: inherit;
        }
        .btn-post:disabled { opacity: 0.4; cursor: not-allowed; }

        /* ─── Timeline ─── */
        .timeline { display: flex; flex-direction: column; }
        .timeline-entry {
            display: flex; flex-wrap: wrap; gap: 6px; padding: 8px 0;
            border-bottom: 1px solid #f1f5f9; font-size: 13px; align-items: baseline;
        }
        .entry-time { color: #94a3b8; font-size: 11px; white-space: nowrap; }
        .entry-person { font-weight: 600; color: #1e293b; white-space: nowrap; }
        .entry-content { color: #475569; line-height: 1.4; }
        .is-comment .entry-content { font-style: italic; color: #334155; }
    `]
})
export class TaskDetailPanelComponent implements OnChanges {
    @Input() TaskID: string | null = null;
    @Input() PersonID: string | null = null;

    @Output() EditRequested = new EventEmitter<string>();
    @Output() Close = new EventEmitter<void>();

    task: any = null;
    parentTaskName: string | null = null;
    assignees: TaskAssigneeInfo[] = [];
    taskLinks: { ID: string; EntityName: string; Description: string | null }[] = [];
    timeline: ActivityEntry[] = [];
    loading = false;
    newComment = '';
    private cdr = inject(ChangeDetectorRef);

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['TaskID'] && this.TaskID) {
            this.loadTask();
        }
    }

    formatStatus(status: string): string {
        return status?.replace(/([a-z])([A-Z])/g, '$1 $2') ?? '';
    }

    async loadTask(): Promise<void> {
        if (!this.TaskID) return;
        this.loading = true;
        this.cdr.markForCheck();

        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        this.task = result?.Results?.[0] ?? null;

        await Promise.all([this.loadAssignees(), this.loadTimeline(), this.loadParentTask(), this.loadTaskLinks()]);
        this.loading = false;
        this.cdr.markForCheck();
    }

    private async loadParentTask(): Promise<void> {
        this.parentTaskName = null;
        if (!this.task?.ParentID) return;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ID = '${this.task.ParentID}'`,
            ResultType: 'simple',
            MaxRows: 1,
        });
        this.parentTaskName = result?.Results?.[0]?.Name ?? null;
    }

    private async loadTaskLinks(): Promise<void> {
        this.taskLinks = [];
        if (!this.TaskID) return;
        const rv = new RunView();
        const [linksResult, entitiesResult] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Links',
                ExtraFilter: `TaskID = '${this.TaskID}'`,
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ: Entities',
                ResultType: 'simple',
            }),
        ]);
        const entityMap = new Map<string, string>();
        for (const e of entitiesResult?.Results ?? []) {
            entityMap.set(e.ID, e.Name);
        }
        this.taskLinks = (linksResult?.Results ?? []).map((l: any) => ({
            ID: l.ID,
            EntityName: entityMap.get(l.EntityID) ?? l.EntityID,
            Description: l.Description,
        }));
    }

    private async loadAssignees(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const [assignmentResult, peopleResult, rolesResult] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Assignments',
                ExtraFilter: `TaskID = '${this.TaskID}'`,
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Common: People',
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Roles',
                ResultType: 'simple',
            }),
        ]);

        const personMap = new Map<string, string>();
        for (const p of peopleResult?.Results ?? []) {
            personMap.set(p.ID, `${p.FirstName} ${p.LastName}`);
        }
        const roleMap = new Map<string, string>();
        for (const r of rolesResult?.Results ?? []) {
            roleMap.set(r.ID, r.Name);
        }

        this.assignees = (assignmentResult?.Results ?? []).map((a: any) => ({
            AssigneeRecordID: a.AssigneeRecordID,
            DisplayName: personMap.get(a.AssigneeRecordID) ?? a.AssigneeRecordID,
            RoleName: roleMap.get(a.RoleID) ?? '',
            Status: a.Status ?? 'Pending',
        }));
    }

    private async loadTimeline(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();

        const [activities, comments, people] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Activities',
                ExtraFilter: `TaskID = '${this.TaskID}'`,
                OrderBy: '__mj_CreatedAt DESC',
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Comments',
                ExtraFilter: `TaskID = '${this.TaskID}'`,
                OrderBy: '__mj_CreatedAt DESC',
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Common: People',
                ResultType: 'simple',
            }),
        ]);

        const personMap = new Map<string, string>();
        for (const p of people?.Results ?? []) {
            personMap.set(p.ID, `${p.FirstName} ${p.LastName}`);
        }

        const entries: ActivityEntry[] = [];
        for (const a of activities?.Results ?? []) {
            entries.push({
                Type: 'activity',
                Timestamp: new Date(a.__mj_CreatedAt),
                PersonName: a.PersonID ? personMap.get(a.PersonID) : undefined,
                ActivityType: a.ActivityType,
                Content: a.Description ?? `${a.ActivityType}`,
            });
        }
        for (const c of comments?.Results ?? []) {
            entries.push({
                Type: 'comment',
                Timestamp: new Date(c.__mj_CreatedAt),
                PersonName: personMap.get(c.PersonID) ?? c.PersonID,
                Content: c.Content,
            });
        }
        this.timeline = entries.sort((a, b) => b.Timestamp.getTime() - a.Timestamp.getTime());
    }

    async postComment(): Promise<void> {
        if (!this.newComment.trim() || !this.TaskID) return;
        const comment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Comments');
        comment.NewRecord();
        comment.Set('TaskID', this.TaskID);
        if (this.PersonID) comment.Set('PersonID', this.PersonID);
        comment.Set('Content', this.newComment.trim());
        await comment.Save();
        this.newComment = '';
        await this.loadTimeline();
        this.cdr.markForCheck();
    }
}
