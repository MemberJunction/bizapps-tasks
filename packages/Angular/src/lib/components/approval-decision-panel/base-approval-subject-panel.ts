import { Directive, Input } from '@angular/core';
import { MJGlobal } from '@memberjunction/global';

/**
 * Base class for approval-subject detail panels rendered inside {@link ApprovalDecisionPanelComponent}.
 *
 * Applications register a subject panel for their approval-linked entity via
 * `@RegisterClass(BaseApprovalSubjectPanel, '<EntityName>')`. When an approval
 * task has a `TaskLink` pointing to `<EntityName>`, the decision panel renders
 * the registered subject panel for that linked record.
 *
 * Tasks registers {@link TimesheetPartApprovalPanelComponent} for
 * `'MJ_BizApps_Tasks: Timesheet Approvals'`. Other apps (such as Forms or
 * Accounting) can register panels for their own approval subjects the same way.
 */
@Directive()
export abstract class BaseApprovalSubjectPanel {
    private _subjectRecordID: string | null = null;
    private _approvalTaskID: string | null = null;

    /** The primary key (`LinkedRecordID`) of the subject record linked via `TaskLink`. */
    @Input()
    public get SubjectRecordID(): string | null {
        return this._subjectRecordID;
    }
    public set SubjectRecordID(value: string | null) {
        const changed = value !== this._subjectRecordID;
        this._subjectRecordID = value;
        if (changed) {
            this.onSubjectInputsChanged();
        }
    }

    /** The approval task ID (`Task.ID`). */
    @Input()
    public get ApprovalTaskID(): string | null {
        return this._approvalTaskID;
    }
    public set ApprovalTaskID(value: string | null) {
        const changed = value !== this._approvalTaskID;
        this._approvalTaskID = value;
        if (changed) {
            this.onSubjectInputsChanged();
        }
    }

    /** Hook invoked whenever `SubjectRecordID` or `ApprovalTaskID` changes. */
    protected onSubjectInputsChanged(): void {
        // Subclasses may override to reload data.
    }
}

/**
 * Checks whether a {@link BaseApprovalSubjectPanel} subclass is registered in
 * `MJGlobal.Instance.ClassFactory` for the given entity name.
 *
 * @param entityName - Entity name from `TaskLink.LinkedEntity` (e.g. `'MJ_BizApps_Tasks: Timesheet Approvals'`).
 */
export function HasApprovalSubjectPanelRegistration(entityName: string): boolean {
    if (!entityName) {
        return false;
    }
    const reg = MJGlobal.Instance.ClassFactory.GetRegistration(BaseApprovalSubjectPanel, entityName);
    return reg != null;
}
