import { BaseEntity, ValidationErrorInfo, ValidationErrorType, ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { IsUUID } from '@mj-biz-apps/tasks-core';

/**
 * Server-side subclass for Task Assignments.
 *
 * `AssigneeRecordID` is a deliberately FK-less polymorphic reference
 * (NVARCHAR(450)), so the database never validates its shape — yet the
 * notification handlers and the nightly overdue job read the stored value
 * back and use it in People lookups. Rejecting non-UUID values at write time
 * closes the second-order injection window and keeps garbage assignee refs
 * out of the table; every MJ-family entity this column can point at uses a
 * UNIQUEIDENTIFIER primary key.
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Assignments', 2)
export class TaskAssignmentEntityServer extends mjBizAppsTasksTaskAssignmentEntity {
    public override Validate(): ValidationResult {
        const result = super.Validate();

        const assigneeField = this.GetFieldByName('AssigneeRecordID');
        if ((assigneeField?.Dirty || !this.IsSaved) && !IsUUID(this.AssigneeRecordID)) {
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(
                    'AssigneeRecordID',
                    'AssigneeRecordID must be a UUID.',
                    this.AssigneeRecordID,
                    ValidationErrorType.Failure
                )
            );
        }

        return result;
    }
}
