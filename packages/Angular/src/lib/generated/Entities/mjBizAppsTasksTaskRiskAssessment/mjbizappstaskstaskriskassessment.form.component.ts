import { Component } from '@angular/core';
import { mjBizAppsTasksTaskRiskAssessmentEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Risk Assessments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskriskassessment-form',
    templateUrl: './mjbizappstaskstaskriskassessment.form.component.html'
})
export class mjBizAppsTasksTaskRiskAssessmentFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskRiskAssessmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentOverview', sectionName: 'Assessment Overview', isExpanded: true },
            { sectionKey: 'forecastAndHealth', sectionName: 'Forecast and Health', isExpanded: true },
            { sectionKey: 'risksAndEvidence', sectionName: 'Risks Payload', isExpanded: true },
            { sectionKey: 'agentRunAndCost', sectionName: 'Agent Run and Cost Telemetry', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}
