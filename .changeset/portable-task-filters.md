---
"@mj-biz-apps/tasks-ng": patch
---

The approval inbox and My Tasks build their task filters from entity metadata, with bracketed identifiers and integer-cast boolean checks, so the same filter runs on SQL Server and PostgreSQL. My Tasks now escapes quotes in the Person ID.
