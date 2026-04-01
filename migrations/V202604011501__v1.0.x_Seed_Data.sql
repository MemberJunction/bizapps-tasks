-- BizAppsTasks Seed Data
-- Initial lookup values for TaskType and TaskRole

GO

---------------------------------------------------------------------------
-- TaskType seed data
---------------------------------------------------------------------------
INSERT INTO __mj_BizAppsTasks.TaskType (Name, Description, IconClass, DefaultPriority)
VALUES
    ('General', 'General-purpose task', 'fa-solid fa-circle-check', 'Medium'),
    ('Action Item', 'Action item from a meeting or discussion', 'fa-solid fa-bolt', 'Medium'),
    ('Follow-up', 'Follow-up on a previous discussion or decision', 'fa-solid fa-arrow-rotate-right', 'Medium'),
    ('Deliverable', 'A concrete output or artifact to be produced', 'fa-solid fa-file-export', 'High');
GO

---------------------------------------------------------------------------
-- TaskRole seed data
---------------------------------------------------------------------------
INSERT INTO __mj_BizAppsTasks.TaskRole (Name, Description, Sequence)
VALUES
    ('Primary', 'Primary person responsible for completing the task', 10),
    ('Reviewer', 'Reviews and approves the completed work', 20),
    ('Observer', 'Kept informed of progress but not actively working on the task', 30);
GO
