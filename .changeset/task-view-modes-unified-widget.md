---
"@mj-biz-apps/tasks-ng": patch
---
Support multi-view modes (list, kanban, gantt) in TaskPanelComponent via mj-view-toggle, unify status change hooks and read-only switches across all views. TaskRow's Assignees, Tags, and ChildCount are now optional to handle board moves where full sub-entities are not queried.
