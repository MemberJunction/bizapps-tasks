/**
 * MEETING-WORLD: two people with MemberJunction accounts in the UI role, so the meetings checks can act as an organizer
 * and as an attendee, and read as someone the private-meeting filter keeps out. Each user is linked to their Person the
 * way bizapps-common now links them: from the user's side (User.LinkedEntityID / LinkedEntityRecordID).
 */
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import type { IMetadataProvider } from '@memberjunction/core';
import type { MJUserEntity, MJUserRoleEntity } from '@memberjunction/core-entities';
import { mjBizAppsCommonPersonEntity } from '@mj-biz-apps/common-entities';
import { PERSON_ENTITY } from '../entity-names.js';
import { FindId, Quote, RequireSave } from '../wire.js';

const USERS = 'MJ: Users';
const USER_ROLES = 'MJ: User Roles';
const ROLES = 'MJ: Roles';
export const MEETING_WORLD_DOMAIN = 'task-world.test';

export interface MeetingPersona {
    key: 'ivy' | 'jun';
    email: string;
    firstName: string;
    lastName: string;
    userId: string;
    personId: string;
}

export const MEETING_PERSONAS: ReadonlyArray<Pick<MeetingPersona, 'key' | 'email' | 'firstName' | 'lastName'>> = [
    { key: 'ivy', email: `ivy.meets@${MEETING_WORLD_DOMAIN}`, firstName: 'Ivy', lastName: 'Meets' },
    { key: 'jun', email: `jun.meets@${MEETING_WORLD_DOMAIN}`, firstName: 'Jun', lastName: 'Meets' },
];

let loaded: Record<MeetingPersona['key'], MeetingPersona> | null = null;

/** The two personas, made once: a Person, a User in the UI role, and the user's link to the person. */
export async function LoadMeetingWorld(ctx: IntegrationCheckContext): Promise<Record<MeetingPersona['key'], MeetingPersona>> {
    if (loaded) return loaded;
    const provider = ctx.Provider as IMetadataProvider;
    const peopleEntity = provider.Entities.find((entity) => entity.Name === PERSON_ENTITY);
    Assert(!!peopleEntity, `${PERSON_ENTITY} is not in metadata`);
    const uiRoleId = await FindId(ctx, ROLES, "Name = 'UI'");
    Assert(!!uiRoleId, 'the UI role is missing');

    const result = {} as Record<MeetingPersona['key'], MeetingPersona>;
    for (const persona of MEETING_PERSONAS) {
        // The person
        const existingPerson = await FindId(ctx, PERSON_ENTITY, `Email = '${Quote(persona.email)}'`);
        const person = await ctx.Provider.GetEntityObject<mjBizAppsCommonPersonEntity>(PERSON_ENTITY, ctx.User);
        if (existingPerson) await person.Load(existingPerson);
        else person.NewRecord();
        person.FirstName = persona.firstName;
        person.LastName = persona.lastName;
        person.Email = persona.email;
        person.Status = 'Active';
        await RequireSave(person, `person ${persona.email}`);

        // The user, in the UI role, linked to the person from the user's side
        const existingUser = await FindId(ctx, USERS, `Email = '${Quote(persona.email)}'`);
        const user = await ctx.Provider.GetEntityObject<MJUserEntity>(USERS, ctx.User);
        if (existingUser) await user.Load(existingUser);
        else user.NewRecord();
        user.Name = `${persona.firstName} ${persona.lastName}`;
        user.FirstName = persona.firstName;
        user.LastName = persona.lastName;
        user.Email = persona.email;
        user.Type = 'User';
        user.IsActive = true;
        user.LinkedEntityID = peopleEntity!.ID;
        user.LinkedEntityRecordID = person.ID;
        await RequireSave(user, `user ${persona.email}`);
        if (!(await FindId(ctx, USER_ROLES, `UserID = '${user.ID}' AND RoleID = '${uiRoleId}'`))) {
            const link = await ctx.Provider.GetEntityObject<MJUserRoleEntity>(USER_ROLES, ctx.User);
            link.NewRecord();
            link.UserID = user.ID;
            link.RoleID = uiRoleId!;
            await RequireSave(link, `UI role for ${persona.email}`);
        }
        result[persona.key] = { ...persona, userId: user.ID, personId: person.ID };
    }
    loaded = result;
    return result;
}
