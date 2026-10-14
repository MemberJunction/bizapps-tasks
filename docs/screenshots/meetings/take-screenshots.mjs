/**
 * The Meetings app's screens (the meetings plan, § 11), taken in MJ Explorer with Playwright as the signed-in staff
 * user, light and dark, each asserted before its capture.
 *
 *   node --env-file=<env> docs/screenshots/meetings/take-screenshots.mjs [--theme light|dark|both] [--only <name>[,<name>…]]
 *   node docs/screenshots/meetings/take-screenshots.mjs --save-staff-session   # a browser opens; sign in; the session is saved
 *
 * Env: EXPLORER_URL (default http://localhost:4218), MJAPI_URL and MJ_API_KEY for the seed (the harness's), SCREENSHOT_STAFF_EMAIL
 * (the signed-in user; the seed gives them a Person and makes them the organizer of the sample meetings).
 * The sample rows are made once, by name, over GraphQL, and left in place.
 */
import { existsSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from '/Users/bcianzygmunt/Projects/collab-workspace/bizapps-collaboration/docs/screenshots/pr10/node_modules/playwright/index.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const EXPLORER = (process.env.EXPLORER_URL ?? 'http://localhost:4218').replace(/\/$/, '');
const STAFF_SESSION = join(here, 'staff-session.json');
const STAFF_EMAIL = process.env.SCREENSHOT_STAFF_EMAIL ?? '';
const APP = `${EXPLORER}/app/meetings`;

const args = process.argv.slice(2);
const option = (name, fallback) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : fallback; };
const themes = { light: ['light'], dark: ['dark'], both: ['light', 'dark'] }[option('--theme', 'both')];
const only = option('--only', null);

/** The sample world: names the screens look for. */
const SAMPLE = {
    boardPrep: 'Board prep (sample)',
    kickoff: 'Client kickoff (sample)',
    retro: 'Sprint retro (sample)',
    series: 'Weekly staff sync (sample)',
    note: 'The roadmap slides are ready; the numbers wait on finance.',
    followUp: 'Send the revised roadmap to the board',
};

/** The rows the screens need, made over GraphQL as the harness user, once. Returns the sample meeting's id. */
async function seed() {
    process.env.MJ_INTEGRATION_TEST = '1';
    const { bootstrapIntegrationClient } = await import('@memberjunction/testing-integration/client');
    const { Metadata } = await import('@memberjunction/core');
    await bootstrapIntegrationClient();
    const it = await import('../../../packages/IntegrationTests/dist/index.js');
    const core = await import('@mj-biz-apps/tasks-core');
    const provider = Metadata.Provider;
    const user = provider.CurrentUser;
    const ctx = { User: user, Provider: provider, Schema: '__mj', Storage: undefined };
    const world = await it.LoadMeetingWorld(ctx);

    // The staff user's Person, linked from the user's side, so the screens show them as the organizer
    if (!STAFF_EMAIL) throw new Error('Set SCREENSHOT_STAFF_EMAIL to the signed-in staff account.');
    const peopleEntity = provider.Entities.find((e) => e.Name === it.PERSON_ENTITY);
    let [staffPerson] = await it.FindRows(ctx, it.PERSON_ENTITY, `Email = '${it.Quote(STAFF_EMAIL)}'`, ['ID']);
    if (!staffPerson) {
        const person = await provider.GetEntityObject(it.PERSON_ENTITY, user);
        person.NewRecord();
        person.FirstName = 'Ian';
        person.LastName = 'Zygmunt';
        person.Email = STAFF_EMAIL;
        person.Status = 'Active';
        await it.RequireSave(person, 'the staff person');
        staffPerson = { ID: person.ID };
    }
    const [staffUser] = await it.FindRows(ctx, 'MJ: Users', `Email = '${it.Quote(STAFF_EMAIL)}'`, ['ID', 'LinkedEntityID', 'LinkedEntityRecordID']);
    if (!staffUser) throw new Error(`No MJ user with email ${STAFF_EMAIL}.`);
    if (!staffUser.LinkedEntityRecordID || staffUser.LinkedEntityRecordID.toLowerCase() !== staffPerson.ID.toLowerCase()) {
        const u = await provider.GetEntityObject('MJ: Users', user);
        if (!(await u.Load(staffUser.ID))) throw new Error('The staff user did not load.');
        u.LinkedEntityID = peopleEntity.ID;
        u.LinkedEntityRecordID = staffPerson.ID;
        await it.RequireSave(u, 'the staff user link');
    }

    const service = new core.MeetingService(provider);
    const existing = async (name) => (await it.FindRows(ctx, core.MEETING_ENTITY, `Name = '${it.Quote(name)}'`, ['ID']))[0]?.ID ?? null;
    const at = (daysAhead, hour) => { const d = new Date(); d.setUTCDate(d.getUTCDate() + daysAhead); d.setUTCHours(hour, 0, 0, 0); return d; };

    let boardPrep = await existing(SAMPLE.boardPrep);
    if (!boardPrep) {
        const type = await service.typeByCode('TEAM', user);
        const meeting = await service.createMeeting({ name: SAMPLE.boardPrep, typeId: type?.ID ?? null, organizerPersonId: staffPerson.ID, startsAt: at(2, 15), timeZone: 'America/Chicago', description: 'What the board hears next week, and who says it.', attendees: [{ personId: world.ivy.personId }, { personId: world.jun.personId, role: 'Optional' }, { email: 'guest.counsel@example.org', displayName: 'Outside counsel' }], links: [] }, user);
        boardPrep = meeting.ID;
        const data = new core.MeetingAgendaService(provider);
        const agenda = await data.itemsOf(boardPrep, user);
        const note = await provider.GetEntityObject(core.MEETING_NOTE_ENTITY, user);
        note.NewRecord();
        note.MeetingID = boardPrep;
        note.AgendaItemID = agenda[0]?.ID ?? null;
        note.Kind = 'Notes';
        note.Title = 'Where things stand';
        note.Body = SAMPLE.note;
        note.Source = 'Manual';
        note.Status = 'Draft';
        note.AuthorPersonID = staffPerson.ID;
        await it.RequireSave(note, 'the sample note');
        const typeRow = (await it.FindRows(ctx, it.TASK_TYPE_ENTITY, "Code = 'ACTION_ITEM'", ['ID']))[0];
        const meetingsEntity = provider.Entities.find((e) => e.Name === core.MEETING_ENTITY);
        if (typeRow && meetingsEntity) {
            const task = await provider.GetEntityObject(it.TASK_ENTITY, user);
            task.NewRecord();
            task.Name = SAMPLE.followUp;
            task.TypeID = typeRow.ID;
            task.Status = 'Open';
            task.Priority = 'High';
            task.PercentComplete = 0;
            task.DueAt = at(5, 17);
            task.CreatedByPersonID = staffPerson.ID;
            await it.RequireSave(task, 'the sample follow-up');
            const link = await provider.GetEntityObject('MJ_BizApps_Tasks: Task Links', user);
            link.NewRecord();
            link.TaskID = task.ID;
            link.EntityID = meetingsEntity.ID;
            link.RecordID = boardPrep;
            link.Description = 'Follow-up from the meeting';
            await it.RequireSave(link, 'the sample follow-up link');
        }
    }
    if (!(await existing(SAMPLE.kickoff))) {
        const type = await service.typeByCode('CLIENT', user);
        await service.createMeeting({ name: SAMPLE.kickoff, typeId: type?.ID ?? null, organizerPersonId: world.ivy.personId, startsAt: at(3, 16), timeZone: 'America/New_York', locationType: 'Hybrid', location: 'Room 4B', attendees: [{ personId: staffPerson.ID }, { personId: world.jun.personId }] }, user);
    }
    if (!(await existing(SAMPLE.retro))) {
        const type = await service.typeByCode('REVIEW', user);
        const retro = await service.createMeeting({ name: SAMPLE.retro, typeId: type?.ID ?? null, organizerPersonId: staffPerson.ID, startsAt: at(-7, 14), timeZone: 'America/Chicago', attendees: [{ personId: world.ivy.personId }] }, user);
        const started = await service.startMeeting(retro.ID, user);
        const ended = started.ok ? await service.endMeeting(retro.ID, user) : started;
        if (!ended.ok) console.log(`note: the sample retro stays ${started.ok ? 'in progress' : 'scheduled'}: ${ended.message}`);
    }
    const [series] = await it.FindRows(ctx, core.MEETING_SERIES_ENTITY, `Name = '${it.Quote(SAMPLE.series)}'`, ['ID']);
    if (!series) {
        const type = await service.typeByCode('TEAM', user);
        const s = await provider.GetEntityObject(core.MEETING_SERIES_ENTITY, user);
        s.NewRecord();
        s.Name = SAMPLE.series;
        s.Description = 'The team, every week.';
        s.TypeID = type?.ID ?? null;
        s.OrganizerPersonID = staffPerson.ID;
        s.RecurrenceRule = 'FREQ=WEEKLY;BYDAY=TU';
        s.TimeZone = 'America/Chicago';
        s.FirstStartsAt = at(1, 15);
        s.DurationMinutes = 30;
        s.LocationType = 'Virtual';
        s.Visibility = 'Standard';
        s.Status = 'Active';
        await it.RequireSave(s, 'the sample series');
        const invite = await provider.GetEntityObject(core.MEETING_SERIES_ATTENDEE_ENTITY, user);
        invite.NewRecord();
        invite.SeriesID = s.ID;
        invite.PersonID = world.ivy.personId;
        invite.Role = 'Required';
        await it.RequireSave(invite, 'the sample series attendee');
    }
    const [seriesRow] = await it.FindRows(ctx, core.MEETING_SERIES_ENTITY, `Name = '${it.Quote(SAMPLE.series)}'`, ['ID']);
    return { boardPrep, seriesId: seriesRow?.ID ?? null };
}

/** Fails the run when the page doesn't show every text in `present`, or shows any in `absent`. */
async function assertScreen(page, name, { present = [], absent = [] }) {
    for (const text of present) {
        await page.getByText(text, { exact: false }).first().waitFor({ state: 'visible', timeout: 20000 }).catch(() => {
            throw new Error(`${name}: "${text}" is not on the screen`);
        });
    }
    const body = await page.locator('body').innerText();
    for (const text of absent) if (body.includes(text)) throw new Error(`${name}: "${text}" must not be on the screen`);
}

const recordUrl = (entity, id) => `${EXPLORER}/resource/record/${encodeURIComponent(entity)}/${id}`;

const SHOTS = (ids) => [
    {
        name: '01-my-meetings', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(`${APP}/${encodeURIComponent('My meetings')}`);
            await assertScreen(page, '01', { present: ['My meetings', SAMPLE.boardPrep, SAMPLE.kickoff, 'Organizer'] });
        },
    },
    {
        name: '02-meetings', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(`${APP}/Meetings`);
            await assertScreen(page, '02', { present: ['Every meeting you may see', SAMPLE.boardPrep, SAMPLE.kickoff] });
        },
    },
    {
        name: '03-series', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(`${APP}/Series`);
            await assertScreen(page, '03', { present: ['Series', SAMPLE.series, 'Every week on Tuesday'] });
        },
    },
    {
        name: '04-new-meeting', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(`${APP}/${encodeURIComponent('My meetings')}`);
            await page.getByRole('button', { name: /New meeting/ }).first().click();
            await assertScreen(page, '04', { present: ['Schedule meeting', 'Time zone', 'Who sees it', 'Invite'] });
            await page.locator('input[name="name"]').first().fill('Pricing review');
        },
    },
    {
        name: '05-meeting-page', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(recordUrl('MJ_BizApps_Tasks: Meetings', ids.boardPrep));
            await assertScreen(page, '05', { present: [SAMPLE.boardPrep, 'Add to calendar', 'Agenda', 'People', 'Outside counsel', 'Follow-ups', SAMPLE.followUp, 'Notes', 'Where things stand'] });
        },
    },
    {
        name: '06-live-meeting', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(recordUrl('MJ_BizApps_Tasks: Meetings', ids.boardPrep));
            // The first pass starts the meeting; a later pass finds it in progress and opens the live view
            const startOrRun = page.getByRole('button', { name: /Start meeting|Run meeting/ }).first();
            await startOrRun.waitFor({ state: 'visible', timeout: 30000 });
            await startOrRun.click();
            await assertScreen(page, '06', { present: ['Live', 'Item 1 of', 'Start item', 'Who is here', 'Quick note'] });
            const startItem = page.getByRole('button', { name: /Start item/ }).first();
            if (await startItem.isVisible().catch(() => false)) { await startItem.click(); await page.waitForTimeout(2500); }
        },
    },
    {
        name: '07-series-page', item: 'T4, § 5',
        run: async (page) => {
            await page.goto(recordUrl('MJ_BizApps_Tasks: Meeting Series', ids.seriesId));
            await assertScreen(page, '07', { present: [SAMPLE.series, 'Meetings in this series', 'Every week on Tuesday'] });
        },
    },
];

async function saveStaffSession() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext({ viewport: { width: 1600, height: 1000 } });
    const page = await context.newPage();
    await page.goto(`${EXPLORER}/`);
    console.log('Sign in as staff in the browser window. The session is saved when the app shows.');
    await page.waitForURL(/\/app\//, { timeout: Number(process.env.STAFF_SIGNIN_MINUTES || 10) * 60 * 1000 });
    await page.waitForTimeout(3000);
    await context.storageState({ path: STAFF_SESSION });
    console.log(`Saved ${STAFF_SESSION}. Keep it out of git.`);
    await browser.close();
}

async function main() {
    if (args.includes('--save-staff-session')) return saveStaffSession();
    mkdirSync(here, { recursive: true });
    if (!existsSync(STAFF_SESSION)) throw new Error(`No ${STAFF_SESSION}: run --save-staff-session first.`);
    const ids = await seed();
    const onlyNames = only ? only.split(',').map((n) => n.trim()).filter(Boolean) : [];
    const wanted = SHOTS(ids).filter((s) => !onlyNames.length || onlyNames.includes(s.name));
    const browser = await chromium.launch({ headless: true });
    const failures = [];
    for (const theme of themes) {
        for (const shot of wanted) {
            const context = await browser.newContext({ viewport: { width: 1600, height: 1000 }, storageState: STAFF_SESSION });
            await context.addInitScript((t) => { try { localStorage.setItem('mj-theme', t); } catch { /* theme falls back */ } }, theme);
            const page = await context.newPage();
            const errors = [];
            page.on('pageerror', (e) => errors.push(String(e)));
            page.on('console', (message) => { if (message.type() === 'error') errors.push(`console: ${message.text()}`); });
            try {
                await shot.run(page);
                await page.waitForTimeout(600);
                await page.screenshot({ path: join(here, `${shot.name}-${theme}.png`) });
                console.log(`ok   ${shot.name}-${theme}.png (item ${shot.item})${errors.length ? `  page errors: ${errors.length}` : ''}`);
                if (process.env.SHOT_DEBUG && errors.length) console.log(`     ${[...new Set(errors.map((e) => e.split('\n')[0].slice(0, 200)))].slice(0, 20).join('\n     ')}`);
            } catch (error) {
                await page.screenshot({ path: join(here, `${shot.name}-${theme}-FAILED.png`) }).catch(() => undefined);
                failures.push(`${shot.name}-${theme}: ${error instanceof Error ? error.message : String(error)}`);
                if (errors.length) console.log(`     page errors (${errors.length}):\n       ${[...new Set(errors.map((e) => e.split('\n')[0].slice(0, 300)))].slice(0, 10).join('\n       ')}`);
                console.log(`     at ${page.url()}`);
                console.log(`FAIL ${shot.name}-${theme}: ${error instanceof Error ? error.message.split('\n')[0] : String(error)}`);
            } finally {
                await context.close();
            }
        }
    }
    await browser.close();
    if (failures.length) {
        console.log(`\n${failures.length} screenshot(s) failed their assertions:\n${failures.map((f) => `  ${f}`).join('\n')}`);
        process.exit(1);
    }
    process.exit(0);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
