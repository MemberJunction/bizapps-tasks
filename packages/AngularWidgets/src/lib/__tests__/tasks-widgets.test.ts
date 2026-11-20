import '@angular/compiler';
import { describe, it, expect, vi } from 'vitest';
import {
    ConnectedTasksWidgetComponent,
    TaskAdaptiveSpotlightComponent,
    TaskApprovalCardComponent,
    TaskCommandPaletteComponent,
    TaskCompletionRingComponent,
    TaskOkrCheckInComponent,
    TaskQuickCaptureComponent,
    TaskUrgencyStripComponent,
    TaskWorkflowStepperComponent,
    type TaskWidgetItem,
} from '../tasks/index';

describe('tasks-ng-widgets L1 contracts', () => {
    it('TaskCompletionRingComponent toggles Completed <-> Open', () => {
        const ring = new TaskCompletionRingComponent();
        ring.Status = 'Open';
        const emitted: string[] = [];
        ring.Toggled.subscribe((s) => emitted.push(s));

        ring.onClick({ stopPropagation: vi.fn() } as unknown as MouseEvent);
        expect(emitted).toEqual(['Completed']);

        ring.Status = 'Completed';
        ring.onClick({ stopPropagation: vi.fn() } as unknown as MouseEvent);
        expect(emitted).toEqual(['Completed', 'Open']);
    });

    it('TaskWorkflowStepperComponent sorts stages by Sequence and resolves active index', () => {
        const stepper = new TaskWorkflowStepperComponent();
        stepper.Statuses = [
            { ID: 's3', TaskTypeID: 't1', Name: 'QA', Code: 'QA', MacroStatus: 'InProgress', Sequence: 30, IsDefault: false, IsTerminal: false, Color: null, IconClass: null },
            { ID: 's1', TaskTypeID: 't1', Name: 'Spec', Code: 'SPEC', MacroStatus: 'Open', Sequence: 10, IsDefault: true, IsTerminal: false, Color: null, IconClass: null },
            { ID: 's2', TaskTypeID: 't1', Name: 'Build', Code: 'BUILD', MacroStatus: 'InProgress', Sequence: 20, IsDefault: false, IsTerminal: false, Color: null, IconClass: null },
        ];
        stepper.ActiveStatusID = 'S2';
        expect(stepper.SortedStatuses.map((s) => s.Name)).toEqual(['Spec', 'Build', 'QA']);
        expect(stepper.CurrentIndex).toBe(1);
    });

    it('TaskQuickCaptureComponent parses natural language and clears draft on submit', () => {
        const qc = new TaskQuickCaptureComponent();
        qc.DraftText = 'Prep board deck tomorrow @Jordan #Exec !high ~2h';
        const submissions: unknown[] = [];
        qc.Submitted.subscribe((e) => submissions.push(e));

        expect(qc.HasPreviewChips).toBe(true);
        expect(qc.Parsed.Title).toBe('Prep board deck');
        qc.submit();

        expect(qc.DraftText).toBe('');
        expect(submissions).toHaveLength(1);
        expect(submissions[0]).toMatchObject({
            Title: 'Prep board deck',
            Priority: 'High',
            AssigneeQuery: 'Jordan',
            TagNames: ['Exec'],
            HoursEstimated: 2,
        });
    });

    it('TaskUrgencyStripComponent hides when all counts are zero and toggles filter keys', () => {
        const strip = new TaskUrgencyStripComponent();
        expect(strip.HasAnySignal).toBe(false);

        strip.Counts = { Overdue: 2, Blocked: 0, PendingApprovals: 1, SlaAtRisk: 0 };
        expect(strip.HasAnySignal).toBe(true);

        const changes: string[] = [];
        strip.FilterChange.subscribe((k) => changes.push(k));
        strip.toggle('overdue');
        strip.ActiveFilter = 'overdue';
        strip.toggle('overdue');
        expect(changes).toEqual(['overdue', '']);
    });

    it('TaskApprovalCardComponent emits decisions and resets condition composer', () => {
        const card = new TaskApprovalCardComponent();
        card.Task = {
            ID: 't-1',
            Name: 'Approve renewal discount',
            Description: null,
            ParentID: null,
            Status: 'Open',
            Priority: 'High',
            DueAt: null,
            PercentComplete: 0,
            IsApproval: true,
        };
        const decisions: unknown[] = [];
        card.DecisionSubmitted.subscribe((e) => decisions.push(e));
        card.ShowConditionComposer = true;
        card.ConditionNote = 'Needs CFO review';
        card.decide('ApprovedWithConditions', 'Needs CFO review');

        expect(card.ShowConditionComposer).toBe(false);
        expect(card.ConditionNote).toBe('');
        expect(decisions).toEqual([{ TaskID: 't-1', OutcomeCode: 'ApprovedWithConditions', Notes: 'Needs CFO review' }]);
    });

    it('TaskOkrCheckInComponent formats units and emits check-in payload', () => {
        const okr = new TaskOkrCheckInComponent();
        okr.Snapshot = {
            TaskID: 'kr-1',
            BaselineValue: 40,
            TargetValue: 90,
            CurrentValue: 72,
            UnitOfMeasure: '%',
            MetricDirection: 'Increase',
            PercentComplete: 64,
            HealthStatus: 'OnTrack',
            ConfidenceScore: 8,
            PlanningPeriod: 'Q4 2026',
            CheckInCadence: 'Weekly',
            LastCheckInAt: null,
            NextCheckInDueAt: null,
        };
        expect(okr.formatMetric(72)).toBe('72%');
        okr.ToggleComposer();
        okr.DraftValue = 80;
        okr.DraftSummary = 'Closed 3 enterprise migrations';
        const submitted: unknown[] = [];
        okr.CheckInSubmitted.subscribe((e) => submitted.push(e));
        okr.submit();

        expect(okr.ComposerOpen).toBe(false);
        expect(submitted).toEqual([
            {
                TaskID: 'kr-1',
                NewValue: 80,
                HealthStatus: 'OnTrack',
                ConfidenceScore: 8,
                Summary: 'Closed 3 enterprise migrations',
                Blockers: null,
                NextSteps: null,
            },
        ]);
    });

    it('TaskAdaptiveSpotlightComponent collapses cleanly on plain General tasks', () => {
        const spot = new TaskAdaptiveSpotlightComponent();
        spot.Data = {
            TaskID: 'g-1',
            TaskName: 'Book conference room',
            Archetype: 'general',
            Status: 'Open',
            DueAt: null,
            PercentComplete: 0,
            HoursEstimated: null,
            HoursActual: null,
            BlockedReason: null,
            BlockingDependencyNames: [],
            PredictedSLARiskBand: null,
            PredictedSLABreachProbability: null,
        };
        expect(spot.ShouldRender).toBe(false);

        spot.Data = { ...spot.Data, Archetype: 'key-result' };
        expect(spot.ShouldRender).toBe(true);
    });

    it('ConnectedTasksWidgetComponent filters completed tasks unless ShowCompleted is enabled', () => {
        const widget = new ConnectedTasksWidgetComponent();
        const tasks: TaskWidgetItem[] = [
            { ID: '1', Name: 'Open task', Description: null, ParentID: null, Status: 'Open', Priority: 'High', DueAt: null, PercentComplete: 0 },
            { ID: '2', Name: 'Done task', Description: null, ParentID: null, Status: 'Completed', Priority: 'Low', DueAt: null, PercentComplete: 100 },
        ];
        widget.Tasks = tasks;
        expect(widget.ActiveCount).toBe(1);
        expect(widget.CompletedCount).toBe(1);
        expect(widget.VisibleTasks.map((t) => t.ID)).toEqual(['1']);

        widget.ShowCompleted = true;
        expect(widget.VisibleTasks.map((t) => t.ID)).toEqual(['1', '2']);
    });

    it('TaskCommandPaletteComponent filters items and supports keyboard selection', () => {
        const palette = new TaskCommandPaletteComponent();
        palette.Items = [
            { ID: 'c1', Label: 'New Task', Group: 'Actions', IconClass: 'fa-solid fa-plus' },
            { ID: 'c2', Label: 'Approve Acme Discount', Group: 'Tasks', IconClass: 'fa-solid fa-stamp', TaskID: 't-9' },
        ];
        palette.Query = 'acme';
        expect(palette.FilteredItems.map((i) => i.ID)).toEqual(['c2']);

        const selected: string[] = [];
        palette.ItemSelected.subscribe((i) => selected.push(i.ID));
        palette.select(palette.FilteredItems[0]);
        expect(selected).toEqual(['c2']);
        expect(palette.Query).toBe('');
    });
});
