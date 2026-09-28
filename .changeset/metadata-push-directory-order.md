---
"@mj-biz-apps/tasks-entities": patch
---

`mj sync push --dir metadata` now succeeds on a fresh database.

- `metadata/.mj-sync.json` lists `entities`, `entity-relationships`, `record-processes`, `ml-training-pipelines`, `ml-models` and `ml-model-scoring-bindings` in `directoryOrder`. Folders left out of the list are pushed afterwards in alphabetical order, so `ml-model-scoring-bindings` was pushed before the model and record process it references and the push rolled back on `FK_MLModelScoringBinding_MLModel`.
- The SLA-breach model's `ArtifactFileID` is now null. It pointed at a `__mj.File` row that nothing ships, so the push failed on `FK_MLModel_ArtifactFile`. The trained artifact's bytes live on the machine that trained it, so shipping the File row would not make the model scorable either. Scoring this model throws `has no ArtifactFileID` until it is trained on the host.
