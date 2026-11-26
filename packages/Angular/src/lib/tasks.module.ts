import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';

// Standalone components — imported into the module for re-export convenience
import { TaskPriorityBadgeComponent } from './components/task-priority-badge/task-priority-badge.component';
import { TaskAssigneeListComponent } from './components/task-assignee-list/task-assignee-list.component';
import { TaskBulkActionsBarComponent } from './components/task-bulk-actions-bar/task-bulk-actions-bar.component';
import { TaskListComponent } from './components/task-list/task-list.component';
import { MyTasksComponent } from './components/my-tasks/my-tasks.component';
import { TaskDetailPanelComponent } from './components/task-detail-panel/task-detail-panel.component';
import { TaskDetailContributionsSlotComponent } from './components/task-detail-panel/task-detail-contributions-slot.component';
import { TaskEditPanelComponent } from './components/task-edit-panel/task-edit-panel.component';
import { TaskKanbanComponent } from './components/task-kanban/task-kanban.component';
import { TaskGanttComponent } from './components/task-gantt/task-gantt.component';
import { TaskTemplateWizardComponent } from './components/task-template-wizard/task-template-wizard.component';
import { TaskPanelComponent } from './components/task-panel/task-panel.component';
import { TaskDashboardComponent } from './components/task-dashboard/task-dashboard.component';
import { ApprovalInboxComponent } from './components/approval-inbox/approval-inbox.component';
import { ApprovalDecisionPanelComponent } from './components/approval-decision-panel/approval-decision-panel.component';
import { TimesheetPartApprovalPanelComponent } from './components/approval-decision-panel/timesheet-part-approval-panel.component';
import { RunningTimerChipComponent } from './components/running-timer-chip/running-timer-chip.component';
import { TaskTimeEffortComponent } from './components/task-time-effort/task-time-effort.component';
import { TimeApproversComponent } from './components/time-approvers/time-approvers.component';
import { MyTimeComponent } from './components/my-time/my-time.component';

// Dashboard Pages
import { TasksDashboardPageComponent } from './pages/tasks-dashboard.page';
import { MyTasksPageComponent } from './pages/my-tasks.page';
import { MyTimePageComponent } from './pages/my-time.page';
import { ApprovalsPageComponent } from './pages/approvals.page';
import { TemplatesPageComponent } from './pages/templates.page';
import { MyMeetingsPageComponent } from './pages/my-meetings.page';
import { MeetingsPageComponent } from './pages/meetings.page';
import { MeetingSeriesPageComponent } from './pages/meeting-series.page';
import { MyMeetingsSectionResource, MeetingsSectionResource, MeetingSeriesSectionResource, LoadMeetingsSectionResources } from './sections/meetings-sections.component';

// Section Resources (DriverClasses)
import {
    TasksSectionResource,
    MyTasksSectionResource,
    MyTimeSectionResource,
    ApprovalsSectionResource,
    TemplatesSectionResource,
    LoadTasksSectionResources,
} from './sections/tasks-sections.component';
import { ChiefOfStaffWorkReportsResource } from './chief-of-staff/chief-of-staff-work-reports.component';
import { mjBizAppsTasksTaskRiskAssessmentFormComponent } from './generated/Entities/mjBizAppsTasksTaskRiskAssessment/mjbizappstaskstaskriskassessment.form.component';
import { mjBizAppsTasksWorkReportFormComponent } from './generated/Entities/mjBizAppsTasksWorkReport/mjbizappstasksworkreport.form.component';
import { mjBizAppsTasksMeetingNoteFormComponent } from './generated/Entities/mjBizAppsTasksMeetingNote/mjbizappstasksmeetingnote.form.component';
import { TaskRiskAssessmentRisksPanel } from './form-panels/task-risk-assessment.panel';
import { WorkReportArtifactPanel } from './form-panels/work-report-artifact.panel';
import { MeetingNoteArtifactPanel } from './form-panels/meeting-note-artifact.panel';

@NgModule({
    imports: [
        CommonModule,
        FormsModule,
        SharedGenericModule,
        // Standalone components
        TaskPriorityBadgeComponent,
        TaskAssigneeListComponent,
        TaskBulkActionsBarComponent,
        TaskListComponent,
        MyTasksComponent,
        TaskDetailPanelComponent,
        TaskDetailContributionsSlotComponent,
        TaskEditPanelComponent,
        TaskKanbanComponent,
        TaskGanttComponent,
        TaskTemplateWizardComponent,
        TaskDashboardComponent,
        TaskPanelComponent,
        ApprovalInboxComponent,
        ApprovalDecisionPanelComponent,
        TimesheetPartApprovalPanelComponent,
        RunningTimerChipComponent,
        TaskTimeEffortComponent,
        TimeApproversComponent,
        MyTimeComponent,
        TasksDashboardPageComponent,
        MyTasksPageComponent,
        MyTimePageComponent,
        ApprovalsPageComponent,
        TemplatesPageComponent,
        TasksSectionResource,
        MyTasksSectionResource,
        MyTimeSectionResource,
        ApprovalsSectionResource,
        TemplatesSectionResource,
        ChiefOfStaffWorkReportsResource,
        MyMeetingsPageComponent,
        MeetingsPageComponent,
        MeetingSeriesPageComponent,
        MyMeetingsSectionResource,
        MeetingsSectionResource,
        MeetingSeriesSectionResource,
    ],
    exports: [
        TaskPriorityBadgeComponent,
        TaskAssigneeListComponent,
        TaskBulkActionsBarComponent,
        TaskListComponent,
        MyTasksComponent,
        TaskDetailPanelComponent,
        TaskDetailContributionsSlotComponent,
        TaskEditPanelComponent,
        TaskKanbanComponent,
        TaskGanttComponent,
        TaskTemplateWizardComponent,
        TaskDashboardComponent,
        TaskPanelComponent,
        ApprovalInboxComponent,
        ApprovalDecisionPanelComponent,
        TimesheetPartApprovalPanelComponent,
        RunningTimerChipComponent,
        TaskTimeEffortComponent,
        TimeApproversComponent,
        MyTimeComponent,
        TasksDashboardPageComponent,
        MyTasksPageComponent,
        MyTimePageComponent,
        ApprovalsPageComponent,
        TemplatesPageComponent,
        TasksSectionResource,
        MyTasksSectionResource,
        MyTimeSectionResource,
        ApprovalsSectionResource,
        TemplatesSectionResource,
        ChiefOfStaffWorkReportsResource,
        MyMeetingsPageComponent,
        MeetingsPageComponent,
        MeetingSeriesPageComponent,
        MyMeetingsSectionResource,
        MeetingsSectionResource,
        MeetingSeriesSectionResource,
    ]
})
export class BizAppsTasksModule { }

/** Tree-shaking prevention — call from consuming app bootstrap */
export function LoadBizAppsTasksClient() {
    LoadTasksSectionResources();
    void ChiefOfStaffWorkReportsResource;
    LoadMeetingsSectionResources();
    void mjBizAppsTasksTaskRiskAssessmentFormComponent;
    void TaskRiskAssessmentRisksPanel;
    void mjBizAppsTasksWorkReportFormComponent;
    void mjBizAppsTasksMeetingNoteFormComponent;
    void WorkReportArtifactPanel;
    void MeetingNoteArtifactPanel;
}
