// Comprehensive functional test of the BizApps Tasks object model on PostgreSQL.
//
// Exercises the WRITE path (CodeGen-generated CRUD functions), the READ path (FK-join base
// views), the distinctive model features (Task/TaskCategory recursive root-parent functions,
// polymorphic TaskAssignment, cross-schema Person joins into bizapps-common, DB-level CHECK
// enforcement incl. the self-dependency and PercentComplete constraints, the approval decision
// model), and full CRUD round-trips. Self-cleaning. Tasks analog of bizapps-common's
// scripts/pg-objectmodel-test.mjs — run it against a one-shot install (see
// migrations-pg/docs/PG_INSTALL_VERIFICATION.md), no codegen required.
//
// Run: node scripts/pg-objectmodel-test.mjs
// Connection via env: PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD
import { Pool } from 'pg';

const S = '__mj_bizappstasks';
const C = '__mj_bizappscommon';
const pool = new Pool({
  host: process.env.PGHOST ?? 'localhost',
  port: +(process.env.PGPORT ?? 5438),
  user: process.env.PGUSER ?? 'mj_admin',
  password: process.env.PGPASSWORD ?? 'Verify99',
  database: process.env.PGDATABASE ?? 'Tasks_OneShot',
});
const q = (sql, p) => pool.query(sql, p);

let pass = 0, fail = 0;
const ok = (n) => { pass++; console.log(`  ✓ ${n}`); };
const bad = (n, d) => { fail++; console.log(`  ✗ ${n} — ${d}`); };
const check = (n, cond, d) => (cond ? ok(n) : bad(n, d));
const created = []; // {schema, table, id} in reverse-dependency order for cleanup

async function createRow(schema, table, fn, args) {
  const keys = Object.keys(args);
  const id = (
    await q(
      `SELECT "ID" FROM ${schema}."${fn}"(${keys.map((k, i) => `${k} := $${i + 1}`).join(', ')})`,
      Object.values(args),
    )
  ).rows[0].ID;
  created.unshift({ schema, table, id });
  return id;
}

async function expectError(name, sql, params, needle) {
  try {
    await q(sql, params);
    bad(name, 'statement succeeded but should have violated a constraint');
  } catch (e) {
    check(name, e.message.includes(needle), e.message.slice(0, 120));
  }
}

async function main() {
  console.log('\n[1] Seeded reference data (metadata-sync migrations)');
  for (const [t, want] of [['TaskType', 5], ['TaskRole', 3], ['TaskNotificationConfig', 1], ['TaskDecisionOutcome', 3]]) {
    const n = +(await q(`SELECT count(*) c FROM ${S}."${t}"`)).rows[0].c;
    check(`${t} seeded (=${want})`, n === want, `got ${n}`);
  }

  console.log('\n[2] Task create + FK-join base view');
  const typeGeneral = (await q(`SELECT "ID" FROM ${S}."TaskType" WHERE "Name"='General'`)).rows[0].ID;
  const parentTask = await createRow(S, 'Task', 'spCreateTask', { p_name: 'TEST Parent Task', p_typeid: typeGeneral });
  const childTask = await createRow(S, 'Task', 'spCreateTask', { p_name: 'TEST Child Task', p_typeid: typeGeneral, p_parentid: parentTask });
  const childRow = (await q(`SELECT "Type","Parent","RootParentID","Status","PercentComplete" FROM ${S}."vwTasks" WHERE "ID"=$1`, [childTask])).rows[0];
  check('vwTasks FK-join Type name', childRow.Type === 'General', `got ${childRow.Type}`);
  check('vwTasks FK-join Parent name', childRow.Parent === 'TEST Parent Task', `got ${childRow.Parent}`);
  check('Task defaults (Status=Open, PercentComplete=0)', childRow.Status === 'Open' && childRow.PercentComplete === 0, JSON.stringify(childRow));

  console.log('\n[3] Recursive root-parent functions (CodeGen scalar form)');
  check('Task root-parent (child.RootParentID = parent)', childRow.RootParentID === parentTask, `got ${childRow.RootParentID}`);
  const catParent = await createRow(S, 'TaskCategory', 'spCreateTaskCategory', { p_name: 'TEST Cat Parent' });
  const catChild = await createRow(S, 'TaskCategory', 'spCreateTaskCategory', { p_name: 'TEST Cat Child', p_parentid: catParent });
  const catRow = (await q(`SELECT "Parent","RootParentID" FROM ${S}."vwTaskCategories" WHERE "ID"=$1`, [catChild])).rows[0];
  check('TaskCategory root-parent + Parent name join', catRow.RootParentID === catParent && catRow.Parent === 'TEST Cat Parent', JSON.stringify(catRow));

  console.log('\n[4] DB-level CHECK enforcement');
  await expectError(
    'PercentComplete range CHECK rejects 150',
    `UPDATE ${S}."Task" SET "PercentComplete"=150 WHERE "ID"=$1`, [childTask],
    'ck_task_percentcomplete',
  );
  await expectError(
    'TaskDependency self-dependency CHECK rejects TaskID=DependsOnTaskID',
    `INSERT INTO ${S}."TaskDependency" ("TaskID","DependsOnTaskID") VALUES ($1,$1)`, [childTask],
    'ck_taskdependency_noselfref',
  );

  console.log('\n[5] TaskDependency (valid) + view join');
  const dep = await createRow(S, 'TaskDependency', 'spCreateTaskDependency', { p_taskid: childTask, p_dependsontaskid: parentTask });
  const depRow = (await q(`SELECT "Task","DependsOnTask" FROM ${S}."vwTaskDependencies" WHERE "ID"=$1`, [dep])).rows[0];
  check('vwTaskDependencies FK-join names', depRow.Task === 'TEST Child Task' && depRow.DependsOnTask === 'TEST Parent Task', JSON.stringify(depRow));

  console.log('\n[6] Cross-schema: bizapps-common Person joined into tasks views');
  const person = await createRow(C, 'Person', 'spCreatePerson', { p_firstname: 'TEST', p_lastname: 'Tasker' });
  const comment = await createRow(S, 'TaskComment', 'spCreateTaskComment', { p_taskid: childTask, p_personid: person, p_content: 'TEST comment' });
  const commentRow = (await q(`SELECT "Person" FROM ${S}."vwTaskComments" WHERE "ID"=$1`, [comment])).rows[0];
  check('vwTaskComments cross-schema Person display name', commentRow.Person === 'TEST Tasker', `got ${commentRow.Person}`);

  console.log('\n[7] Polymorphic TaskAssignment (AssigneeEntityID/AssigneeRecordID -> common Person)');
  const personEntity = (await q(`SELECT "ID" FROM __mj."Entity" WHERE "SchemaName"=$1 AND "BaseTable"='Person'`, [C])).rows[0].ID;
  const rolePrimary = (await q(`SELECT "ID" FROM ${S}."TaskRole" WHERE "Name"='Primary'`)).rows[0].ID;
  const assignment = await createRow(S, 'TaskAssignment', 'spCreateTaskAssignment', {
    p_taskid: childTask, p_assigneeentityid: personEntity, p_assigneerecordid: person, p_roleid: rolePrimary,
  });
  const asgRow = (await q(`SELECT "Role","Task","Status" FROM ${S}."vwTaskAssignments" WHERE "ID"=$1`, [assignment])).rows[0];
  check('vwTaskAssignments polymorphic assignment + Role join', asgRow.Role === 'Primary' && asgRow.Task === 'TEST Child Task' && asgRow.Status === 'Pending', JSON.stringify(asgRow));

  console.log('\n[8] Approval decision model (v1.1)');
  const typeApproval = (await q(`SELECT "ID" FROM ${S}."TaskType" WHERE "Name"='Approval Request'`)).rows[0].ID;
  const approvalTask = await createRow(S, 'Task', 'spCreateTask', { p_name: 'TEST Approval', p_typeid: typeApproval });
  const outcomeApproved = (await q(`SELECT "ID" FROM ${S}."TaskDecisionOutcome" WHERE "Code"='Approved'`)).rows[0].ID;
  const decision = await createRow(S, 'TaskDecision', 'spCreateTaskDecision', { p_taskid: approvalTask, p_outcomeid: outcomeApproved, p_decidedbypersonid: person });
  const decRow = (await q(`SELECT "Outcome","Task","DecidedByPerson" FROM ${S}."vwTaskDecisions" WHERE "ID"=$1`, [decision])).rows[0];
  check('vwTaskDecisions Outcome/Task/Person joins', decRow.Outcome === 'Approved' && decRow.Task === 'TEST Approval' && decRow.DecidedByPerson === 'TEST Tasker', JSON.stringify(decRow));

  console.log('\n[9] spUpdate round-trip + row-touch trigger');
  const before = (await q(`SELECT "__mj_UpdatedAt" FROM ${S}."Task" WHERE "ID"=$1`, [childTask])).rows[0].__mj_UpdatedAt;
  await new Promise((r) => setTimeout(r, 20));
  const upd = (await q(`SELECT "Name","PercentComplete" FROM ${S}."spUpdateTask"(p_id := $1, p_name := 'TEST Child Task v2', p_percentcomplete := 50)`, [childTask])).rows[0];
  check('spUpdateTask returns updated row from view', upd.Name === 'TEST Child Task v2' && upd.PercentComplete === 50, JSON.stringify(upd));
  const after = (await q(`SELECT "__mj_UpdatedAt" FROM ${S}."Task" WHERE "ID"=$1`, [childTask])).rows[0].__mj_UpdatedAt;
  check('fn_trg_update_task bumped __mj_UpdatedAt', new Date(after) > new Date(before), `${before} -> ${after}`);

  console.log('\n[10] spDelete cleanup (reverse-dependency order)');
  let cleaned = 0;
  for (const { schema, table, id } of created) {
    const r = await q(`SELECT "ID" FROM ${schema}."spDelete${table}"(p_id := $1)`, [id]);
    if (r.rows[0]?.ID === id) cleaned++;
  }
  check(`spDelete* removed all ${created.length} created rows`, cleaned === created.length, `cleaned ${cleaned}`);
  const leftovers = +(await q(`SELECT count(*) c FROM ${S}."Task" WHERE "Name" LIKE 'TEST %'`)).rows[0].c;
  check('no TEST leftovers', leftovers === 0, `found ${leftovers}`);

  console.log(`\nRESULT: ${pass} passed, ${fail} failed`);
  await pool.end();
  process.exit(fail ? 1 : 0);
}

main().catch(async (e) => {
  console.error('FATAL:', e.message);
  // best-effort cleanup
  for (const { schema, table, id } of created) {
    try { await q(`SELECT * FROM ${schema}."spDelete${table}"(p_id := $1)`, [id]); } catch { /* already gone */ }
  }
  await pool.end();
  process.exit(1);
});
