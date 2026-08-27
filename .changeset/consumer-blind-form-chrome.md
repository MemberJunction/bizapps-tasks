---
'@mj-biz-apps/tasks-entities': minor
'@mj-biz-apps/tasks-ng': minor
'@mj-biz-apps/tasks-server': minor
---

Drop the form-chrome record naming `MJ_BizApps_Accounting: Journal Entry Batches` — Tasks metadata must not reference consumer apps, and the unresolvable `@lookup` rolled back the entire metadata push on any install without Accounting. Ship the v1.2.x metadata sync migration so a migrations-only install carries the full form chrome, display-name pins, and application settings with no `mj sync push` required.
