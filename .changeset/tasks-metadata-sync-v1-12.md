---
"@mj-biz-apps/tasks-entities": minor
---

Release seed for the approval reassignment guard: `V…__v1.12.x__Metadata_Sync` creates the Tasks application setting `ApprovalReassignRoles`, empty by default, so a host that upgrades by migration gets it as one that ran `mj sync push` does. It is create-only: a host that already set its roles keeps them. It has a Postgres counterpart.
