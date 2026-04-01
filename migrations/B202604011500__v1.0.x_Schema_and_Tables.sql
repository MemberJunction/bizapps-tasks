-- BizAppsTasks Schema and Tables
-- Reusable task management for MemberJunction business applications:
-- Tasks, assignments, dependencies, categories, tags, comments,
-- templates, and activity tracking.

GO

---------------------------------------------------------------------------
-- TaskType: General, Action Item, Follow-up, Deliverable, etc.
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskType (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    IconClass NVARCHAR(100),
    DefaultPriority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    OnAssignActionID UNIQUEIDENTIFIER,
    OnCompleteActionID UNIQUEIDENTIFIER,
    OnOverdueActionID UNIQUEIDENTIFIER,
    OnPercentChangeActionID UNIQUEIDENTIFIER,
    IsActive BIT NOT NULL DEFAULT 1,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskType PRIMARY KEY (ID),
    CONSTRAINT UQ_TaskType_Name UNIQUE (Name),
    CONSTRAINT CK_TaskType_DefaultPriority CHECK (DefaultPriority IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT FK_TaskType_OnAssignAction FOREIGN KEY (OnAssignActionID) REFERENCES __mj.[Action](ID),
    CONSTRAINT FK_TaskType_OnCompleteAction FOREIGN KEY (OnCompleteActionID) REFERENCES __mj.[Action](ID),
    CONSTRAINT FK_TaskType_OnOverdueAction FOREIGN KEY (OnOverdueActionID) REFERENCES __mj.[Action](ID),
    CONSTRAINT FK_TaskType_OnPercentChangeAction FOREIGN KEY (OnPercentChangeActionID) REFERENCES __mj.[Action](ID)
);
GO

---------------------------------------------------------------------------
-- TaskCategory: hierarchical grouping (e.g. "Finance Committee", "Q1 Audit")
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskCategory (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    ParentID UNIQUEIDENTIFIER,
    ColorCode NVARCHAR(20),
    Sequence INT NOT NULL DEFAULT 100,
    IsActive BIT NOT NULL DEFAULT 1,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskCategory PRIMARY KEY (ID),
    CONSTRAINT FK_TaskCategory_Parent FOREIGN KEY (ParentID) REFERENCES __mj_BizAppsTasks.TaskCategory(ID)
);
GO

---------------------------------------------------------------------------
-- Task: the core work item
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.Task (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    TypeID UNIQUEIDENTIFIER NOT NULL,
    CategoryID UNIQUEIDENTIFIER,
    ParentID UNIQUEIDENTIFIER,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Open',
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    StartedAt DATETIMEOFFSET,
    DueAt DATETIMEOFFSET,
    CompletedAt DATETIMEOFFSET,
    HoursEstimated DECIMAL(8,2),
    HoursActual DECIMAL(8,2),
    PercentComplete INT NOT NULL DEFAULT 0,
    Sequence INT NOT NULL DEFAULT 100,
    BlockedReason NVARCHAR(MAX),
    CompletionNotes NVARCHAR(MAX),
    CreatedByPersonID UNIQUEIDENTIFIER,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Task PRIMARY KEY (ID),
    CONSTRAINT FK_Task_Type FOREIGN KEY (TypeID) REFERENCES __mj_BizAppsTasks.TaskType(ID),
    CONSTRAINT FK_Task_Category FOREIGN KEY (CategoryID) REFERENCES __mj_BizAppsTasks.TaskCategory(ID),
    CONSTRAINT FK_Task_Parent FOREIGN KEY (ParentID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_Task_CreatedByPerson FOREIGN KEY (CreatedByPersonID) REFERENCES __mj_BizAppsCommon.Person(ID),
    CONSTRAINT CK_Task_Status CHECK (Status IN ('Open', 'InProgress', 'Blocked', 'Completed', 'Cancelled')),
    CONSTRAINT CK_Task_Priority CHECK (Priority IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT CK_Task_PercentComplete CHECK (PercentComplete >= 0 AND PercentComplete <= 100)
);
GO

---------------------------------------------------------------------------
-- TaskRole: Primary, Reviewer, Observer, etc.
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskRole (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Sequence INT NOT NULL DEFAULT 100,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskRole PRIMARY KEY (ID),
    CONSTRAINT UQ_TaskRole_Name UNIQUE (Name)
);
GO

---------------------------------------------------------------------------
-- TaskAssignment: multi-person assignment with polymorphic assignee
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskAssignment (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    AssigneeEntityID UNIQUEIDENTIFIER NOT NULL,
    AssigneeRecordID NVARCHAR(450) NOT NULL,
    RoleID UNIQUEIDENTIFIER,
    RoleNotes NVARCHAR(255),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    AssignedByPersonID UNIQUEIDENTIFIER,
    AssignedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskAssignment PRIMARY KEY (ID),
    CONSTRAINT FK_TaskAssignment_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskAssignment_AssigneeEntity FOREIGN KEY (AssigneeEntityID) REFERENCES __mj.Entity(ID),
    CONSTRAINT FK_TaskAssignment_Role FOREIGN KEY (RoleID) REFERENCES __mj_BizAppsTasks.TaskRole(ID),
    CONSTRAINT FK_TaskAssignment_AssignedByPerson FOREIGN KEY (AssignedByPersonID) REFERENCES __mj_BizAppsCommon.Person(ID),
    CONSTRAINT CK_TaskAssignment_Status CHECK (Status IN ('Pending', 'InProgress', 'Completed')),
    CONSTRAINT UQ_TaskAssignment_Unique UNIQUE (TaskID, AssigneeEntityID, AssigneeRecordID, RoleID)
);
GO

---------------------------------------------------------------------------
-- TaskLink: polymorphic link from tasks to any entity record
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskLink (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    EntityID UNIQUEIDENTIFIER NOT NULL,
    RecordID NVARCHAR(450) NOT NULL,
    Description NVARCHAR(500),
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskLink PRIMARY KEY (ID),
    CONSTRAINT FK_TaskLink_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskLink_Entity FOREIGN KEY (EntityID) REFERENCES __mj.Entity(ID),
    CONSTRAINT UQ_TaskLink_Unique UNIQUE (TaskID, EntityID, RecordID)
);
GO

---------------------------------------------------------------------------
-- TaskDependency: dependency graph between tasks
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskDependency (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    DependsOnTaskID UNIQUEIDENTIFIER NOT NULL,
    DependencyType NVARCHAR(50) NOT NULL DEFAULT 'FinishToStart',
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskDependency PRIMARY KEY (ID),
    CONSTRAINT FK_TaskDependency_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskDependency_DependsOnTask FOREIGN KEY (DependsOnTaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT CK_TaskDependency_Type CHECK (DependencyType IN ('FinishToStart', 'StartToStart', 'FinishToFinish', 'StartToFinish')),
    CONSTRAINT CK_TaskDependency_NoSelfRef CHECK (TaskID <> DependsOnTaskID),
    CONSTRAINT UQ_TaskDependency_Unique UNIQUE (TaskID, DependsOnTaskID)
);
GO

---------------------------------------------------------------------------
-- TaskTag: lightweight cross-cutting labels
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTag (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(100) NOT NULL,
    ColorCode NVARCHAR(20),
    Description NVARCHAR(MAX),
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTag PRIMARY KEY (ID),
    CONSTRAINT UQ_TaskTag_Name UNIQUE (Name)
);
GO

---------------------------------------------------------------------------
-- TaskTagLink: many-to-many between Task and TaskTag
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTagLink (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    TagID UNIQUEIDENTIFIER NOT NULL,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTagLink PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTagLink_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskTagLink_Tag FOREIGN KEY (TagID) REFERENCES __mj_BizAppsTasks.TaskTag(ID),
    CONSTRAINT UQ_TaskTagLink_Unique UNIQUE (TaskID, TagID)
);
GO

---------------------------------------------------------------------------
-- TaskComment: threaded discussion on tasks
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskComment (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    ParentID UNIQUEIDENTIFIER,
    PersonID UNIQUEIDENTIFIER NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    IsEdited BIT NOT NULL DEFAULT 0,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskComment PRIMARY KEY (ID),
    CONSTRAINT FK_TaskComment_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskComment_Parent FOREIGN KEY (ParentID) REFERENCES __mj_BizAppsTasks.TaskComment(ID),
    CONSTRAINT FK_TaskComment_Person FOREIGN KEY (PersonID) REFERENCES __mj_BizAppsCommon.Person(ID)
);
GO

---------------------------------------------------------------------------
-- TaskTemplate: reusable task structures (e.g. "Board Meeting Prep")
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTemplate (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    CategoryID UNIQUEIDENTIFIER,
    TypeID UNIQUEIDENTIFIER,
    IsActive BIT NOT NULL DEFAULT 1,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTemplate PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTemplate_Category FOREIGN KEY (CategoryID) REFERENCES __mj_BizAppsTasks.TaskCategory(ID),
    CONSTRAINT FK_TaskTemplate_Type FOREIGN KEY (TypeID) REFERENCES __mj_BizAppsTasks.TaskType(ID)
);
GO

---------------------------------------------------------------------------
-- TaskTemplateItem: sub-task definitions within a template
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTemplateItem (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TemplateID UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    ParentItemID UNIQUEIDENTIFIER,
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    DaysFromStart INT,
    HoursEstimated DECIMAL(8,2),
    Sequence INT NOT NULL DEFAULT 100,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTemplateItem PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTemplateItem_Template FOREIGN KEY (TemplateID) REFERENCES __mj_BizAppsTasks.TaskTemplate(ID),
    CONSTRAINT FK_TaskTemplateItem_Parent FOREIGN KEY (ParentItemID) REFERENCES __mj_BizAppsTasks.TaskTemplateItem(ID),
    CONSTRAINT CK_TaskTemplateItem_Priority CHECK (Priority IN ('Low', 'Medium', 'High', 'Critical'))
);
GO

---------------------------------------------------------------------------
-- TaskTemplateItemDependency: dependency graph within a template
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTemplateItemDependency (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ItemID UNIQUEIDENTIFIER NOT NULL,
    DependsOnItemID UNIQUEIDENTIFIER NOT NULL,
    DependencyType NVARCHAR(50) NOT NULL DEFAULT 'FinishToStart',
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTemplateItemDependency PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTemplateItemDep_Item FOREIGN KEY (ItemID) REFERENCES __mj_BizAppsTasks.TaskTemplateItem(ID),
    CONSTRAINT FK_TaskTemplateItemDep_DependsOn FOREIGN KEY (DependsOnItemID) REFERENCES __mj_BizAppsTasks.TaskTemplateItem(ID),
    CONSTRAINT CK_TaskTemplateItemDep_Type CHECK (DependencyType IN ('FinishToStart', 'StartToStart', 'FinishToFinish', 'StartToFinish')),
    CONSTRAINT CK_TaskTemplateItemDep_NoSelfRef CHECK (ItemID <> DependsOnItemID),
    CONSTRAINT UQ_TaskTemplateItemDep_Unique UNIQUE (ItemID, DependsOnItemID)
);
GO

---------------------------------------------------------------------------
-- TaskTemplateItemRole: pre-defined assignment roles per template item
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskTemplateItemRole (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ItemID UNIQUEIDENTIFIER NOT NULL,
    RoleID UNIQUEIDENTIFIER NOT NULL,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTemplateItemRole PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTemplateItemRole_Item FOREIGN KEY (ItemID) REFERENCES __mj_BizAppsTasks.TaskTemplateItem(ID),
    CONSTRAINT FK_TaskTemplateItemRole_Role FOREIGN KEY (RoleID) REFERENCES __mj_BizAppsTasks.TaskRole(ID),
    CONSTRAINT UQ_TaskTemplateItemRole_Unique UNIQUE (ItemID, RoleID)
);
GO

---------------------------------------------------------------------------
-- TaskActivity: automatic audit log for task changes
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks.TaskActivity (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskID UNIQUEIDENTIFIER NOT NULL,
    PersonID UNIQUEIDENTIFIER,
    ActivityType NVARCHAR(50) NOT NULL,
    PreviousValue NVARCHAR(500),
    NewValue NVARCHAR(500),
    Description NVARCHAR(MAX),
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskActivity PRIMARY KEY (ID),
    CONSTRAINT FK_TaskActivity_Task FOREIGN KEY (TaskID) REFERENCES __mj_BizAppsTasks.Task(ID),
    CONSTRAINT FK_TaskActivity_Person FOREIGN KEY (PersonID) REFERENCES __mj_BizAppsCommon.Person(ID),
    CONSTRAINT CK_TaskActivity_Type CHECK (ActivityType IN (
        'StatusChange', 'AssignmentAdded', 'AssignmentRemoved',
        'DueDateChanged', 'PriorityChanged', 'PercentCompleteChanged',
        'DependencyAdded', 'DependencyRemoved', 'Created', 'Completed'
    ))
);
GO
