/**
 * A video provider driver for the harness, loaded into MJAPI with `--import <this package>/dist/video-stub.js`: it does
 * nothing with any provider, and records each call as a note on the meeting, so a check can see over the wire that the
 * meeting server called it after the commit. The checks make a Video Providers row whose DriverClass names it.
 */
import { Metadata, RunView, type UserInfo } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import type { mjBizAppsTasksMeetingNoteEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ENTITY, MEETING_NOTE_ENTITY } from '@mj-biz-apps/tasks-core';
import { VideoProviderBase, type VideoMeetingInput, type VideoMeetingResult, type VideoProviderContext } from '@mj-biz-apps/tasks-entities-server';

export const FAKE_VIDEO_DRIVER_CLASS = 'FakeVideoProvider';

@RegisterClass(VideoProviderBase, FAKE_VIDEO_DRIVER_CLASS)
export class FakeVideoProvider extends VideoProviderBase {
    private configured = false;

    async Initialize(_context: VideoProviderContext, _contextUser: UserInfo): Promise<void> {
        this.configured = true;
    }

    get IsConfigured(): boolean {
        return this.configured;
    }

    async CreateMeeting(input: VideoMeetingInput, _contextUser: UserInfo): Promise<VideoMeetingResult> {
        return { JoinURL: `https://fake.video/${encodeURIComponent(input.Title)}`, ProviderMeetingID: `fake-${Date.now()}` };
    }

    async UpdateMeeting(providerMeetingId: string, _input: VideoMeetingInput, contextUser: UserInfo): Promise<void> {
        await this.note(providerMeetingId, `FakeVideoProvider updated video meeting ${providerMeetingId}`, contextUser);
    }

    async DeleteMeeting(providerMeetingId: string, contextUser: UserInfo): Promise<void> {
        await this.note(providerMeetingId, `FakeVideoProvider deleted video meeting ${providerMeetingId}`, contextUser);
    }

    /** The call, written as a note on the meeting that carries the provider's meeting id. */
    private async note(providerMeetingId: string, body: string, contextUser: UserInfo): Promise<void> {
        const meetings = await new RunView().RunView<{ ID: string }>(
            { EntityName: MEETING_ENTITY, ExtraFilter: `VideoMeetingID = '${providerMeetingId.replace(/'/g, "''")}'`, Fields: ['ID'], ResultType: 'simple', MaxRows: 1 },
            contextUser,
        );
        const meetingId = meetings.Success ? meetings.Results[0]?.ID : undefined;
        if (!meetingId) return;
        const note = await new Metadata().GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, contextUser);
        note.NewRecord();
        note.MeetingID = meetingId;
        note.Kind = 'Notes';
        note.Title = 'Video provider';
        note.Body = body;
        note.Source = 'Manual';
        note.Status = 'Final';
        await note.Save();
    }
}

export function LoadFakeVideoProvider(): void {}
