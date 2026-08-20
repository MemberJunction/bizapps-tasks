# BizApps Tasks — Task Workflow, Dynamic Statuses & Lifecycle Guide

This guide provides a comprehensive architecture reference for **Task Types**, **Dynamic Task Type Statuses (`TaskTypeStatus`)**, **Event-Driven Workflow / Action Hooks**, and **Multi-Domain Project Hierarchies** in `bizapps-tasks`.

---

## 1. Architectural Overview

BizApps Tasks provides a unified task engine across diverse business domains — from software development and legal compliance to civil construction and documentary media production.

```mermaid
flowchart TD
    subgraph MetadataLayer["Metadata & Type Configuration"]
        TT["TaskType<br/>• Code: DELIVERABLE, etc.<br/>• OnCreateActionID<br/>• OnStatusChangeActionID"]
        TTS["TaskTypeStatus<br/>• Code: DRAFT, APPROVED...<br/>• MacroStatus: Open/InProgress/Completed/Cancelled<br/>• IsDefault / IsTerminal<br/>• OnEnterActionID / OnExitActionID"]
        TT -->|"1:N Stages"| TTS
    end

    subgraph RuntimeLayer["Runtime Tasks & Execution"]
        T["Task Record<br/>• TypeID<br/>• TaskTypeStatusID<br/>• Status (MacroStatus)<br/>• PercentComplete"]
        TES["TaskEntityServer<br/>(Server BaseEntity Subclass)"]
        T --- TES
    end

    subgraph ActionPipeline["Event-Driven Action & Flow Agent Engine"]
        AE["ActionEngineServer<br/>(Universal Task Payload)"]
        A1["Action: Calculate Expression"]
        A2["Action: Color Converter"]
        A3["AI Flow Agent / Task Graph"]
        AE --> A1
        AE --> A2
        AE --> A3
    end

    TT -.->|"Configures"| T
    TTS -.->|"Drives Stage"| T
    TES ==>|"Non-blocking Post-Save Hooks"| AE
```

---

## 2. TaskType Machine Codes & Cross-App Metadata

Every `TaskType` possesses a stable, unique machine code (`NVARCHAR(50) NOT NULL UNIQUE`). Downstream applications (Contracts, Accounting, Sales, ATS, Marketing, Sonar) reference these codes without relying on environment-specific UUIDs.

| Task Type Name | Stable Code | Primary Domain | Shipped Default |
| :--- | :--- | :--- | :--- |
| **General** | `GENERAL` | Universal | Standard generic task tracking |
| **Action Item** | `ACTION_ITEM` | Operations / Meeting | Action items from committee/team meetings |
| **Follow-up** | `FOLLOW_UP` | CRM / Outreach | Client and prospect check-ins |
| **Deliverable** | `DELIVERABLE` | Engineering / Creative | Work products with draft/review/approval gates |
| **Approval Request** | `APPROVAL_REQUEST` | Governance / Legal | Formal sign-off and decision gating |
| **Phase / Milestone** | `PHASE_EPIC` | Project Management | High-level roadmap and project rollups |
| **Construction Milestone** | `CONSTRUCTION_MILESTONE` | Real Estate / Civil Eng | Permitting, foundation, MEP, and inspection gates |
| **Media Production Stage** | `MEDIA_PRODUCTION` | Creative / Film | Pre-production, shooting, audio/color, release |

---

## 3. Dynamic Task Stages (`TaskTypeStatus`)

Rather than forcing every business process into a rigid 5-state status column, `TaskTypeStatus` allows each `TaskType` to define rich, domain-specific stages while maintaining standard `MacroStatus` mapping for universal Kanban, Gantt, and progress rollups.

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Task Created (IsDefault=1)
    
    state "Deliverable Lifecycle" as DELIV {
        DRAFT: Draft (Open)
        IN_REVIEW: In Review (InProgress)
        APPROVED: Approved (Completed, IsTerminal=1)
        
        DRAFT --> IN_REVIEW: Submit for Review\n[Triggers OnExit / OnEnter]
        IN_REVIEW --> APPROVED: Stakeholder Sign-Off\n[Auto-completes to 100%]
        IN_REVIEW --> DRAFT: Rework Needed
    }

    state "Approval Request Lifecycle" as APPROV {
        SUBMITTED: Submitted (Open, IsDefault=1)
        UNDER_REVIEW: Under Review (InProgress)
        APP_OK: Approved (Completed, IsTerminal=1)
        APP_REJ: Rejected (Cancelled, IsTerminal=1)

        SUBMITTED --> UNDER_REVIEW
        UNDER_REVIEW --> APP_OK: Sign-Off
        UNDER_REVIEW --> APP_REJ: Rejected / Returned
    }

    APPROVED --> [*]
    APP_OK --> [*]
    APP_REJ --> [*]
```

### MacroStatus Mapping

The `MacroStatus` column (`'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled'`) ensures:
1. **Gantt & Progress Rollup**: Subtask weighted averages and completion heuristics always calculate accurately.
2. **Terminal Auto-Completion**: When entering a status where `IsTerminal = 1`, `TaskEntityServer` automatically sets `PercentComplete = 100`, populates `CompletedAt = GETUTCDATE()`, and aligns `Status`.
3. **Cross-App Queries**: Dashboards querying `Status = 'Completed'` find all completed records regardless of custom domain status names (`Approved`, `Inspection Passed`, `Released`).

---

## 4. Event Action & Flow Agent Execution Pipeline

Task lifecycle events can automatically trigger MemberJunction **Actions** (code execution, SQL, REST APIs, or AI Agents).

```mermaid
sequenceDiagram
    autonumber
    actor User as User / Client
    participant API as GraphQL API
    participant Server as TaskEntityServer
    participant DB as SQL Server (__mj_BizAppsTasks)
    participant ActionEngine as ActionEngineServer
    participant Agent as Flow Agent / Action Runner

    User->>API: Mutate Task (Change TaskTypeStatusID / Status)
    API->>Server: Save()
    Server->>Server: Pre-Save: Sync TaskTypeStatusID <-> MacroStatus & Defaults
    Server->>Server: Capture LifecycleContext Snapshot
    Server->>DB: super.Save() [Commit Database Transaction]
    DB-->>Server: Saved Successfully
    Server->>DB: Server-authoritative Audit Log (Task Activities)
    
    rect rgb(240, 248, 255)
        Note over Server,Agent: Asynchronous Non-Blocking Action Dispatch
        Server->>ActionEngine: invokeAction(ActionID, HookType, TaskPayload)
        ActionEngine->>Agent: RunAction({ TaskID, TaskTypeCode, TaskRecord, Payload })
        Agent-->>ActionEngine: Action Result (Success / Output)
        ActionEngine-->>Server: Log Hook Result
    end

    Server-->>API: Return true
    API-->>User: GraphQL Mutation Response
```

### Universal Task Event Payload

Every action hook receives a structured parameter set:

```typescript
{
    TaskID: string;
    RecordID: string;
    TaskName: string;
    TaskTypeCode: string;
    TaskTypeStatusID: string | null;
    TaskTypeStatusCode: string | null;
    Status: 'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';
    PreviousStatus: string | null;
    PercentComplete: number;
    Priority: 'Low' | 'Medium' | 'High' | 'Critical';
    DueAt: Date | null;
    TaskRecord: Record<string, unknown>;
    Payload: string; // Serialized JSON payload object
}
```

---

## 5. Multi-Domain Project Hierarchies

The task engine models deeply nested, multi-tier project structures across distinct corporate departments:

```mermaid
graph TD
    subgraph P1["Project 1: Software & Platform Launch"]
        P1R["Website Redesign & Portal Launch<br/><i>(Deliverable, 40%)</i>"]
        P1R --> P1_1["GraphQL API Resolvers<br/><i>(General, 70%)</i>"]
        P1R --> P1_2["Angular Explorer Dashboard<br/><i>(Deliverable, 40%)</i>"]
        P1R --> P1_3["Security Review<br/><i>(Approval Request, 0%)</i>"]
        P1R --> P1_4["Production CI/CD Deploy<br/><i>(Action Item, 0%)</i>"]
    end

    subgraph P2["Project 2: Corporate HQ Campus Construction"]
        P2R["Corporate HQ Campus Construction & Relocation<br/><i>(Construction Milestone, 45%)</i>"]
        P2R --> P2_1["Architectural Blueprints<br/><i>(Deliverable, 100%)</i>"]
        P2R --> P2_2["Zoning Variance & Permits<br/><i>(Approval Request, 100%)</i>"]
        P2R --> P2_3["Excavation & Concrete Pour<br/><i>(Construction Milestone, 100%)</i>"]
        P2R --> P2_4["Structural Steel Erection<br/><i>(Construction Milestone, 60%)</i>"]
        P2R --> P2_5["MEP Rough-In<br/><i>(Construction Milestone, 20%)</i>"]
        P2R --> P2_6["Workplace Interior Fit-Out<br/><i>(Deliverable, 0%)</i>"]
        P2R --> P2_7["Life Safety & Occupancy Cert<br/><i>(Approval Request, 0%)</i>"]
        
        P2_1 -.->|"FinishToStart"| P2_3
        P2_2 -.->|"FinishToStart"| P2_3
        P2_3 -.->|"FinishToStart"| P2_4
        P2_4 -.->|"FinishToStart"| P2_5
    end

    subgraph P3["Project 3: 50-Year Company Heritage Documentary"]
        P3R["50-Year Company Heritage Documentary Film<br/><i>(Media Production Stage, 50%)</i>"]
        P3R --> P3_1["Archival Research & Rights<br/><i>(Deliverable, 100%)</i>"]
        P3R --> P3_2["Founder 4K Interviews<br/><i>(Media Production, 100%)</i>"]
        P3R --> P3_3["Assembly Edit & Rough Cut<br/><i>(Media Production, 75%)</i>"]
        P3R --> P3_4["Score Recording & Sound Mix<br/><i>(Deliverable, 30%)</i>"]
        P3R --> P3_5["Master 4K HDR Color Grading<br/><i>(Media Production, 0%)</i>"]
        P3R --> P3_6["Global Premiere Broadcast<br/><i>(Deliverable, 0%)</i>"]

        P3_1 -.->|"FinishToStart"| P3_3
        P3_2 -.->|"FinishToStart"| P3_3
        P3_3 -.->|"FinishToStart"| P3_5
    end
```

---

## 6. Integration Test Suite Architecture

The integration test suite (`@mj-biz-apps/tasks-integration-tests`) runs deterministically through the GraphQL and BaseEntity server runtime.

```mermaid
flowchart LR
    subgraph Suite["Tasks Integration Test Suite"]
        TSK00["TSK-00: Task World<br/>(Establishes Baseline Categories, People, 3 Projects, Actions)"]
        TSK01["TSK-01: Hierarchy<br/>(Multi-Level & Multi-Project Parent/Child)"]
        TSK02["TSK-02: Dependencies<br/>(FinishToStart Graph & Cycles)"]
        TSK03["TSK-03: Assignments<br/>(Polymorphic Assignees & Roles)"]
        TSK04["TSK-04: Decisions<br/>(Formal Approval & Sign-Offs)"]
        TSK05["TSK-05: Templates<br/>(Workflow Instantiation)"]
        TSK06["TSK-06: Statuses<br/>(Dynamic Lifecycle & Terminal Auto-Completion)"]
        TSK07["TSK-07: Action Hooks<br/>(Event Triggers & Action Invocations)"]
    end

    TSK00 --> TSK01 --> TSK02 --> TSK03 --> TSK04 --> TSK05 --> TSK06 --> TSK07
```
