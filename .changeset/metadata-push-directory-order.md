---
"@mj-biz-apps/tasks-entities": patch
---

`mj sync push --dir metadata` now succeeds on a fresh database.

- `metadata/.mj-sync.json` lists `entities`, `entity-relationships`, `record-processes`, `ml-training-pipelines`, `ml-models` and `ml-model-scoring-bindings` in `directoryOrder`. Folders left out of the list are pushed afterwards in alphabetical order, so `ml-model-scoring-bindings` was pushed before the model and record process it references and the push rolled back on `FK_MLModelScoringBinding_MLModel`.
- The SLA-breach model no longer carries `ArtifactFileID`. It pointed at a `__mj.File` row that nothing ships, so the push failed on `FK_MLModel_ArtifactFile`. The key is removed rather than set to null because push writes every key it finds, nulls included, so a null would clear the link on the host where the model was trained. `ml-models/.mj-sync.json` now excludes `ArtifactFileID` on pull so the next pull does not write it back. The trained artifact's bytes live on the machine that trained it, so shipping the File row would not make the model scorable either.

On a database where the model has not been trained, scoring it fails with `has no ArtifactFileID`. The daily scoring Record Process ships `Active` with a nightly schedule, so each run marks every task `Failed` and logs an error per record until the model is trained on that host.

The `Validate Changes` workflow now fails when a folder under `metadata/` is missing from `directoryOrder` in `metadata/.mj-sync.json`.
