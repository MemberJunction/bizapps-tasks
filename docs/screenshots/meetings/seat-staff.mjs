/**
 * Gives the staff account the screenshot runner signs in with a user on a fresh host: an MJ user by email, the UI role
 * and, when ROLES names it, the Developer role (the roles the account held on the first dev database). The runner's
 * own seed then makes their Person and the user's link to it. Idempotent: rows that exist are left alone.
 *
 *   SCREENSHOT_STAFF_EMAIL=<email> [STAFF_NAME="First Last"] [ROLES=UI,Developer] node --env-file=<env> docs/screenshots/meetings/seat-staff.mjs
 */
process.env.MJ_INTEGRATION_TEST = '1';
const { bootstrapIntegrationClient } = await import('@memberjunction/testing-integration/client');
const { Metadata, RunView } = await import('@memberjunction/core');
await bootstrapIntegrationClient();
const provider = Metadata.Provider;
const admin = provider.CurrentUser;
if (!admin) throw new Error('The GraphQL provider has no CurrentUser: check MJAPI_URL and MJ_API_KEY.');
const email = process.env.SCREENSHOT_STAFF_EMAIL;
if (!email) throw new Error('Set SCREENSHOT_STAFF_EMAIL.');
const name = process.env.STAFF_NAME ?? email.split('@')[0];
const roles = (process.env.ROLES ?? 'UI,Developer').split(',').map((r) => r.trim()).filter(Boolean);
const quote = (s) => String(s).replace(/'/g, "''");
const one = async (entityName, filter, fields) => {
    const r = await new RunView().RunView({ EntityName: entityName, ExtraFilter: filter, Fields: fields, ResultType: 'simple', MaxRows: 1 }, admin);
    if (!r.Success) throw new Error(`${entityName}: ${r.ErrorMessage}`);
    return r.Results[0] ?? null;
};
const save = async (entity, what) => { if (!(await entity.Save())) throw new Error(`${what} was not saved: ${entity.LatestResult?.CompleteMessage ?? entity.LatestResult?.Message ?? ''}`); };

let user = await one('MJ: Users', `Email = '${quote(email)}'`, ['ID', 'Name']);
if (!user) {
    const u = await provider.GetEntityObject('MJ: Users', admin);
    u.NewRecord();
    u.Name = name;
    u.Email = email;
    u.Type = 'User';
    u.IsActive = true;
    const [first, ...rest] = name.split(' ');
    u.FirstName = first;
    u.LastName = rest.join(' ') || null;
    await save(u, 'the staff user');
    user = { ID: u.ID, Name: u.Name };
    console.log(`made user ${email} (${u.ID})`);
} else console.log(`user ${email} exists (${user.ID})`);

for (const roleName of roles) {
    const role = await one('MJ: Roles', `Name = '${quote(roleName)}'`, ['ID']);
    if (!role) { console.log(`no role named ${roleName}; skipped`); continue; }
    const have = await one('MJ: User Roles', `UserID = '${user.ID}' AND RoleID = '${role.ID}'`, ['ID']);
    if (have) { console.log(`role ${roleName} already held`); continue; }
    const ur = await provider.GetEntityObject('MJ: User Roles', admin);
    ur.NewRecord();
    ur.UserID = user.ID;
    ur.RoleID = role.ID;
    await save(ur, `the ${roleName} role`);
    console.log(`granted ${roleName}`);
}
process.exit(0);
