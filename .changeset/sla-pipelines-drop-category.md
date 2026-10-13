---
"@mj-biz-apps/tasks-entities": patch
---

The six SLA-breach training pipelines no longer use task `Category` as a feature. Categories are names each installation defines for itself, so a model trained on one database could not use them on another, and the shipped model learned nothing from them (empty vocabulary). The published model row is unchanged until it is retrained; scoring is unaffected, because a value outside the model's vocabulary already encodes as all zeros.
