import { LogError, type UserInfo } from '@memberjunction/core';
import { MJGlobal } from '@memberjunction/global';

/**
 * A video provider's driver (the meetings plan, § 7): Zoom, Teams or Google Meet, registered with MemberJunction's class
 * factory under `VideoProvider.DriverClass`. The driver is called only after the commit, every call checks the
 * provider's answer, and a failed call is logged and never loses the save's own error. Committees' base class, with
 * `UpdateMeeting` added, since a meeting can move. The drivers themselves land with the Video step; T1 ships the
 * contract and the lookup the meeting server calls.
 */
export interface VideoAttendee {
    Email: string;
    FullName: string | null;
}

export interface VideoMeetingInput {
    Title: string;
    StartsAt: Date;
    EndsAt: Date;
    TimeZone: string;
    Description?: string | null;
    Attendees?: VideoAttendee[];
}

export interface VideoMeetingResult {
    /** The link attendees join by. */
    JoinURL: string;
    /** The provider's own ID for the meeting, kept to update or delete it. */
    ProviderMeetingID: string;
    /** Dial-in numbers and codes, when the provider gives them. */
    DialInDetails?: string | null;
}

/** What a driver is given to set itself up: the provider row's id, its credential and its non-secret settings. */
export interface VideoProviderContext {
    ProviderID: string;
    CredentialID: string | null;
    Configuration: string | null;
}

export abstract class VideoProviderBase {
    /** Sets the driver up from the provider's credential (MJ: Credentials, through CredentialEngine) and settings. */
    abstract Initialize(context: VideoProviderContext, contextUser: UserInfo): Promise<void>;

    /** Whether Initialize found what it needs. */
    abstract get IsConfigured(): boolean;

    abstract CreateMeeting(input: VideoMeetingInput, contextUser: UserInfo): Promise<VideoMeetingResult>;

    /** The meeting moved or was renamed: the provider's copy follows. */
    abstract UpdateMeeting(providerMeetingId: string, input: VideoMeetingInput, contextUser: UserInfo): Promise<void>;

    /** The meeting was cancelled: the provider's copy goes. */
    abstract DeleteMeeting(providerMeetingId: string, contextUser: UserInfo): Promise<void>;
}

/** The driver registered under the class name, or null (with a logged line) when none is. */
export function resolveVideoProviderDriver(driverClass: string | null | undefined): VideoProviderBase | null {
    if (!driverClass) return null;
    try {
        const driver = MJGlobal.Instance.ClassFactory.CreateInstance<VideoProviderBase>(VideoProviderBase, driverClass);
        if (!driver) LogError(`No video provider driver is registered as '${driverClass}'.`);
        return driver ?? null;
    } catch (error) {
        LogError(`The video provider driver '${driverClass}' could not be made: ${error instanceof Error ? error.message : String(error)}`);
        return null;
    }
}
