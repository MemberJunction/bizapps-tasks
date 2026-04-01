import { Component, EventEmitter, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { TaskPriorityBadgeComponent } from '../task-priority-badge/task-priority-badge.component';
import { TaskAssigneeListComponent, TaskAssigneeInfo } from '../task-assignee-list/task-assignee-list.component';

interface ActivityEntry {
    Type: 'activity' | 'comment';
    Timestamp: Date;
    PersonName?: string;
    Content: string;
    ActivityType?: string;
}

/**
 * Read-only slide-in detail view for a task. Shows all fields,
 * activity+comment timeline, assignee status dots, sub-task progress.
 * Has an "Edit" button to switch to TaskEditPanelComponent.
 */
@Component({
    selector: 'bizapps-task-detail-panel',
    standalone: true,
    imports: [CommonModule, FormsModule, TaskPriorityBadgeComponent, TaskAssigneeListComponent],
    template: `
        @if (TaskID) {
            <div class="detail-panel">
                @if (loading) {
                    <div class="loading">Loading...</div>
                } @else if (task) {
                    <div class="panel-header">
                        <h2 class="task-title">{{ task.Name }}</h2>
                        <div class="panel-actions">
                            <button class="edit-btn" (click)="EditRequested.emit(TaskID)">Edit</button>
                            <button class="close-btn" (click)="Close.emit()">&times;</button>
                        </div>
                    </div>

                    <div class="field-grid">
                        <div class="field">
                            <label>Status</label>
                            <span class="status-chip" [ngClass]="'status-' + task.Status.toLowerCase()">{{ task.Status }}</span>
                        </div>
                        <div class="field">
                            <label>Priority</label>
                            <bizapps-task-priority-badge [Priority]="task.Priority"></bizapps-task-priority-badge>
                        </div>
                        <div class="field">
                            <label>Progress</label>
                            <div class="progress-bar">
                                <div class="progress-fill" [style.width.%]="task.PercentComplete"></div>
                            </div>
                            <span class="pct-label">{{ task.PercentComplete }}%</span>
                        </div>
                        @if (task.DueAt) {
                            <div class="field">
                                <label>Due</label>
                                <span>{{ task.DueAt | date:'mediumDate' }}</span>
                            </div>
                        }
                        @if (task.StartedAt) {
                            <div class="field">
                                <label>Started</label>
                                <span>{{ task.StartedAt | date:'mediumDate' }}</span>
                            </div>
                        }
                        @if (task.HoursEstimated) {
                            <div class="field">
                                <label>Est. Hours</label>
                                <span>{{ task.HoursEstimated }}</span>
                            </div>
                        }
                        @if (task.HoursActual) {
                            <div class="field">
                                <label>Actual Hours</label>
                                <span>{{ task.HoursActual }}</span>
                            </div>
                        }
                    </div>

                    @if (task.Description) {
                        <div class="description-section">
                            <label>Description</label>
                            <p>{{ task.Description }}</p>
                        </div>
                    }

                    @if (task.BlockedReason) {
                        <div class="blocked-section">
                            <label>Blocked Reason</label>
                            <p>{{ task.BlockedReason }}</p>
                        </div>
                    }

                    <div class="section">
                        <label>Assignees</label>
                        <bizapps-task-assignee-list [Assignees]="assignees"></bizapps-task-assignee-list>
                    </div>

                    <!-- Timeline -->
                    <div class="timeline-section">
                        <label>Activity</label>
                        <!-- Inline comment creation -->
                        <div class="add-comment">
                            <input type="text" [(ngModel)]="newComment"
                                   placeholder="Add a comment..."
                                   (keydown.enter)="postComment()"
                                   class="comment-input" />
                            <button class="post-btn" (click)="postComment()" [disabled]="!newComment.trim()">Post</button>
                        </div>
                        @for (entry of timeline; track entry.Timestamp) {
                            <div class="timeline-entry" [ngClass]="'entry-' + entry.Type">
                                <span class="entry-time">{{ entry.Timestamp | date:'short' }}</span>
                                @if (entry.PersonName) {
                                    <span class="entry-person">{{ entry.PersonName }}</span>
                                }
                                <span class="entry-content">{{ entry.Content }}</span>
                            </div>
                        }
                    </div>
                }
            </div>
        }
    `,
    styles: [`
        .detail-panel { padding: 16px; max-width: 480px; }
        .panel-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
        .task-title { margin: 0; font-size: 1.2rem; }
        .panel-actions { display: flex; gap: 8px; }
        .edit-btn {
            padding: 4px 12px; border-radius: 4px; border: 1px solid #4f46e5;
            background: #4f46e5; color: #fff; cursor: pointer; font-size: 0.85rem;
        }
        .close-btn {
            background: none; border: none; font-size: 1.4rem; cursor: pointer;
            color: #9ca3af; line-height: 1;
        }
        .field-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
        .field label { display: block; font-size: 0.75rem; color: #6b7280; text-transform: uppercase; margin-bottom: 2px; }
        .progress-bar { height: 6px; background: #e5e7eb; border-radius: 3px; overflow: hidden; }
        .progress-fill { height: 100%; background: #4f46e5; border-radius: 3px; transition: width 0.3s; }
        .pct-label { font-size: 0.8rem; color: #6b7280; }
        .status-chip {
            display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 0.8rem; font-weight: 500;
        }
        .status-open { background: #dbeafe; color: #1e40af; }
        .status-inprogress { background: #e0e7ff; color: #4338ca; }
        .status-blocked { background: #fee2e2; color: #991b1b; }
        .status-completed { background: #dcfce7; color: #166534; }
        .status-cancelled { background: #f3f4f6; color: #6b7280; }
        .description-section, .blocked-section, .section { margin-bottom: 16px; }
        .description-section label, .blocked-section label, .section label,
        .timeline-section label {
            display: block; font-size: 0.75rem; color: #6b7280; text-transform: uppercase; margin-bottom: 4px;
        }
        .blocked-section { background: #fef2f2; padding: 8px; border-radius: 6px; }
        .description-section p, .blocked-section p { margin: 0; font-size: 0.9rem; }
        .timeline-section { margin-top: 16px; }
        .add-comment { display: flex; gap: 6px; margin-bottom: 12px; }
        .comment-input { flex: 1; padding: 6px 10px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 0.85rem; }
        .post-btn {
            padding: 6px 12px; border: none; border-radius: 6px;
            background: #4f46e5; color: #fff; font-size: 0.85rem; cursor: pointer;
        }
        .post-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .timeline-entry {
            display: flex; gap: 6px; padding: 6px 0; border-bottom: 1px solid #f3f4f6;
            font-size: 0.85rem; align-items: baseline;
        }
        .entry-time { color: #9ca3af; font-size: 0.75rem; white-space: nowrap; }
        .entry-person { font-weight: 600; white-space: nowrap; }
        .entry-content { color: #374151; }
        .entry-comment .entry-content { font-style: italic; }
        .loading { padding: 32px; text-align: center; color: #9ca3af; }
    `]
})
export class TaskDetailPanelComponent implements OnChanges {
    @Input() TaskID: string | null = null;
    @Input() PersonID: string | null = null;

    @Output() EditRequested = new EventEmitter<string>();
    @Output() Close = new EventEmitter<void>();

    task: any = null;
    assignees: TaskAssigneeInfo[] = [];
    timeline: ActivityEntry[] = [];
    loading = false;
    newComment = '';

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['TaskID'] && this.TaskID) {
            this.loadTask();
        }
    }

    async loadTask(): Promise<void> {
        if (!this.TaskID) return;
        this.loading = true;

        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: `ID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        this.task = result?.Results?.[0] ?? null;

        await Promise.all([this.loadAssignees(), this.loadTimeline()]);
        this.loading = false;
    }

    private async loadAssignees(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${this.TaskID}'`,
            ResultType: 'simple',
        });
        this.assignees = (result?.Results ?? []).map((a: any) => ({
            AssigneeRecordID: a.AssigneeRecordID,
            DisplayName: a.AssigneeRecordID,
            RoleName: a.RoleID,
            Status: a.Status ?? 'Pending',
        }));
    }

    private async loadTimeline(): Promise<void> {
        if (!this.TaskID) return;
        const rv = new RunView();

        const [activities, comments] = await Promise.all([
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
        ]);

        const entries: ActivityEntry[] = [];
        for (const a of activities?.Results ?? []) {
            entries.push({
                Type: 'activity',
                Timestamp: new Date(a.__mj_CreatedAt),
                ActivityType: a.ActivityType,
                Content: a.Description ?? `${a.ActivityType}`,
            });
        }
        for (const c of comments?.Results ?? []) {
            entries.push({
                Type: 'comment',
                Timestamp: new Date(c.__mj_CreatedAt),
                PersonName: c.PersonID,
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
    }
}
