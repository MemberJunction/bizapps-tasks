-- Overdue Task Notification Configuration
-- Adds configurable notification settings (global + per-TaskType),
-- an audit log for sent notifications, and a tracking column on Task.

GO

---------------------------------------------------------------------------
-- 1. TaskNotificationConfig: global + per-TaskType notification settings
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskNotificationConfig (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskTypeID UNIQUEIDENTIFIER,
    OverdueNotificationsEnabled BIT NOT NULL DEFAULT 1,
    OverdueGracePeriodHours INT NOT NULL DEFAULT 0,
    OverdueRepeatIntervalHours INT,
    NotifyAssignees BIT NOT NULL DEFAULT 1,
    NotifyCreator BIT NOT NULL DEFAULT 1,
    OverdueActionID UNIQUEIDENTIFIER,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskNotificationConfig PRIMARY KEY (ID),
    CONSTRAINT FK_TaskNotificationConfig_TaskType FOREIGN KEY (TaskTypeID) REFERENCES __mj_BizAppsTasks.TaskType(ID),
    CONSTRAINT FK_TaskNotificationConfig_Action FOREIGN KEY (OverdueActionID) REFERENCES __mj.[Action](ID),
    CONSTRAINT UQ_TaskNotificationConfig_TaskType UNIQUE (TaskTypeID)
);
GO

---------------------------------------------------------------------------
-- 2. TaskNotificationLog: audit trail of sent notifications
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskNotificationLog (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    NotificationType NVARCHAR(50) NOT NULL,
    NotifiedUserID UNIQUEIDENTIFIER NOT NULL,
    NotifiedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskNotificationLog PRIMARY KEY (ID),
    CONSTRAINT FK_TaskNotificationLog_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskNotificationLog_User FOREIGN KEY (NotifiedUserID) REFERENCES __mj.[User](ID),
    CONSTRAINT CK_TaskNotificationLog_Type CHECK (NotificationType IN ('Overdue', 'OverdueReminder'))
);
GO

---------------------------------------------------------------------------
-- 3. Add OverdueNotifiedAt to Task
---------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('__mj_BizAppsTasks.Task') AND name = 'OverdueNotifiedAt'
)
BEGIN
    ALTER TABLE __mj_BizAppsTasks.Task ADD OverdueNotifiedAt DATETIMEOFFSET NULL;
END
GO

---------------------------------------------------------------------------
-- 4. Global default config row (TaskTypeID = NULL)
---------------------------------------------------------------------------
INSERT INTO __mj_BizAppsTasks.TaskNotificationConfig (
    TaskTypeID, OverdueNotificationsEnabled, OverdueGracePeriodHours,
    OverdueRepeatIntervalHours, NotifyAssignees, NotifyCreator
)
VALUES (NULL, 1, 0, 24, 1, 1);
GO
