import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID } from '@memberjunction/global';
import {
    defaultMeetingNotesPromptRunner,
    deduplicateCommitmentsAgainstTasks,
    extractDecisionsFromText,
    MeetingNotesService,
    normalizeTranscriptText,
    parseProposedTasks,
    ResolveTranscriptSource,
    TasksLimitsResolver,
    type CommitmentCandidate,
    type DeduplicatedMatchedCommitment,
    type DeduplicatedNewCommitment,
    type FetchedTranscript,
    type MeetingNotesPromptRunner,
    type TaskSimilarityCandidate,
    type TranscriptMeetingContext,
    type TranscriptSourceBase,
    type TranscriptSourceContext,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksVideoProviderEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_ATTENDEES_ENTITY,
    MEETINGS_ENTITY,
    TASK_ASSIGNMENTS_ENTITY,
    TASKS_ENTITY,
    toIsoOrNull,
    VIDEO_PROVIDERS_ENTITY,
} from '../custom/action-helpers.js';
import { extractZoomMeetingIdFromUrl } from './ZoomTranscriptSource.js';

export type TranscriptProcessingStatus = 'PROCESSED' | 'TRANSCRIPT_NOT_READY' | 'NO_SOURCE';

export interface ProcessMeetingTranscriptInput {
    MeetingID: string;
    /** Optional raw transcript text supplied directly (skips source discovery when non-empty). */
    TranscriptText?: string | null;
    /** Optional explicit TranscriptSourceBase driver key override (e.g. 'ZoomTranscriptSource'). */
    SourceDriver?: string | null;
    /** Deduplication lookback window in days. Default 30. */
    WindowDays?: number;
    /** Similarity threshold `[0, 1]` for classifying a commitment as an existing task duplicate. Default 0.55. */
    DuplicateThreshold?: number;
    /** Optional custom prompt runner (primarily for testing or custom extraction pipelines). */
    PromptRunner?: MeetingNotesPromptRunner;
    /** When true (default), falls back to deterministic heuristic extraction if no AI runtime is configured. */
    AllowHeuristicFallback?: boolean;
}

export interface ProcessMeetingTranscriptResult {
    Status: TranscriptProcessingStatus;
    MeetingID: string;
    MeetingName: string;
    SourceKey: string | null;
    NoteID: string | null;
    Summary: string | null;
    Speakers: string[];
    Decisions: string[];
    MatchedExistingTasks: DeduplicatedMatchedCommitment[];
    ProposedNewCommitments: DeduplicatedNewCommitment[];
    Message: string;
}

interface CandidateSourceSpec {
    DriverKey: string;
    Context: TranscriptSourceContext;
}

interface RawCandidateTaskRow {
    ID: string;
    Name: string;
    Description?: string | null;
    Status: string;
    Priority?: string | null;
    DueAt?: string | Date | null;
    __mj_UpdatedAt?: string | Date | null;
}

interface RawCandidateAssignmentRow {
    TaskID: string;
    AssigneeRecordID: string;
}

/**
 * Orchestrates meeting transcript ingestion (Workstream 6):
 * 1. Resolves configured `TranscriptSourceBase` plugins (`AttachedFileTranscriptSource` first when
 *    `Meeting.TranscriptFileID` is present, then the provider-matched source such as `ZoomTranscriptSource`).
 * 2. Drafts a structured `MeetingNote` via `MeetingNotesService.draftFromTranscript` (falling back
 *    to `defaultMeetingNotesPromptRunner` when no AI prompt runtime is reachable and fallback is enabled).
 * 3. Extracts decisions and deduplicates proposed commitments against open/recent tasks within a
 *    configurable window (default 30 days) so existing commitments are linked rather than duplicated.
 */
export class MeetingTranscriptService {
    constructor(
        private readonly provider: IMetadataProvider = Metadata.Provider,
        private readonly resolveSource: (driverKey: string) => TranscriptSourceBase | null = ResolveTranscriptSource,
    ) {}

    public async ProcessMeetingTranscript(
        input: ProcessMeetingTranscriptInput,
        contextUser: UserInfo,
    ): Promise<ProcessMeetingTranscriptResult> {
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(
            MEETINGS_ENTITY,
            contextUser,
        );
        if (!(await meeting.Load(input.MeetingID))) {
            throw new Error(`Meeting '${input.MeetingID}' was not found or is not accessible.`);
        }

        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const rv = RunView.FromMetadataProvider(this.provider);
        const attendeesRes = await rv.RunView<
            Pick<mjBizAppsTasksMeetingAttendeeEntity, 'PersonID' | 'Email' | 'DisplayName' | 'Role'>
        >(
            {
                EntityName: MEETING_ATTENDEES_ENTITY,
                ExtraFilter: `MeetingID = '${EscapeSQLString(meeting.ID)}'`,
                Fields: ['PersonID', 'Email', 'DisplayName', 'Role'],
                ResultType: 'simple',
                MaxRows: limits.ResourceGuards.WorkflowBatchMaxRows,
            },
            contextUser,
        );
        const attendees = attendeesRes.Success ? (attendeesRes.Results ?? []) : [];
        const organizer = attendees.find((a) => a.Role === 'Organizer');

        const meetingContext: TranscriptMeetingContext = {
            MeetingID: meeting.ID,
            Title: meeting.Name,
            StartsAt: meeting.StartsAt instanceof Date ? meeting.StartsAt : new Date(meeting.StartsAt),
            EndsAt: meeting.EndsAt instanceof Date ? meeting.EndsAt : new Date(meeting.EndsAt),
            ProviderMeetingID: meeting.VideoMeetingID ?? null,
            VideoJoinURL: meeting.VideoJoinURL ?? null,
            TranscriptFileID: meeting.TranscriptFileID ?? null,
            OrganizerEmail: organizer?.Email ?? null,
            AttendeeEmails: attendees.map((a) => a.Email).filter((e): e is string => Boolean(e)),
        };

        let fetched: FetchedTranscript | null = null;
        let sourceKey: string | null = null;
        let hadConfiguredSource = false;

        if (input.TranscriptText?.trim()) {
            const normalized = normalizeTranscriptText(input.TranscriptText);
            sourceKey = 'InlineTranscript';
            fetched = {
                Reference: {
                    SourceKey: sourceKey,
                    ExternalTranscriptID: `inline:${meeting.ID}`,
                    Title: meeting.Name,
                    Format: normalized.Format,
                },
                PlainText: normalized.PlainText,
                RawContent: input.TranscriptText,
                ContentType: 'text/plain',
                Speakers: normalized.Speakers,
            };
        } else {
            const candidateSpecs = await this.buildCandidateSources(meeting, input.SourceDriver ?? null, contextUser);
            for (const spec of candidateSpecs) {
                const driver = this.resolveSource(spec.DriverKey);
                if (!driver) continue;
                await driver.Initialize(spec.Context, contextUser);
                if (!driver.IsConfigured) continue;
                hadConfiguredSource = true;

                const ref = await driver.FindTranscript(meetingContext, contextUser);
                if (ref) {
                    fetched = await driver.FetchTranscript(ref, contextUser);
                    sourceKey = ref.SourceKey || spec.DriverKey;
                    break;
                }
            }
        }

        if (!fetched) {
            const status: TranscriptProcessingStatus = hadConfiguredSource ? 'TRANSCRIPT_NOT_READY' : 'NO_SOURCE';
            return {
                Status: status,
                MeetingID: meeting.ID,
                MeetingName: meeting.Name,
                SourceKey: null,
                NoteID: null,
                Summary: null,
                Speakers: [],
                Decisions: [],
                MatchedExistingTasks: [],
                ProposedNewCommitments: [],
                Message:
                    status === 'TRANSCRIPT_NOT_READY'
                        ? `No transcript is ready yet for meeting "${meeting.Name}". Retry on the next wake.`
                        : `No configured transcript source matched meeting "${meeting.Name}" (attach a transcript file or configure a video provider credential).`,
            };
        }

        const note = await this.draftMeetingNote(meeting.ID, fetched.PlainText, input, contextUser);
        const proposals = parseProposedTasks(note.ProposedTasks);
        const decisions = extractDecisionsFromText(`${fetched.PlainText}\n${note.Body ?? ''}`);

        const windowDays = Math.max(
            1,
            Math.min(
                limits.RunawayGuards.FindSimilarTasksMaxWindowDays,
                input.WindowDays ?? limits.Tuning.FindSimilarDefaultWindowDays,
            ),
        );
        const existingTasks = await this.loadRecentTaskCandidates(windowDays, contextUser);

        const commitmentCandidates: CommitmentCandidate[] = proposals.map((p) => ({
            ProposalID: p.id,
            Title: p.title,
            Description: p.description,
            AssigneePersonID: p.assigneePersonId,
            AssigneeName: p.assigneeName,
            DueAt: p.dueAt,
            AgendaItemID: p.agendaItemId,
        }));

        const dedup = deduplicateCommitmentsAgainstTasks(commitmentCandidates, existingTasks, {
            duplicateThreshold: input.DuplicateThreshold ?? 0.55,
        });

        return {
            Status: 'PROCESSED',
            MeetingID: meeting.ID,
            MeetingName: meeting.Name,
            SourceKey: sourceKey,
            NoteID: note.ID,
            Summary: note.Body,
            Speakers: fetched.Speakers ?? [],
            Decisions: decisions,
            MatchedExistingTasks: dedup.MatchedExistingTasks,
            ProposedNewCommitments: dedup.ProposedNewCommitments,
            Message:
                `Processed transcript for "${meeting.Name}" (${sourceKey}): ` +
                `${dedup.ProposedNewCommitments.length} new commitment(s) proposed, ` +
                `${dedup.MatchedExistingTasks.length} matched existing task(s).`,
        };
    }

    private async buildCandidateSources(
        meeting: mjBizAppsTasksMeetingEntity,
        explicitDriver: string | null,
        contextUser: UserInfo,
    ): Promise<CandidateSourceSpec[]> {
        const specs: CandidateSourceSpec[] = [];

        // 1. Attached file always checked first when Meeting.TranscriptFileID is populated
        if (meeting.TranscriptFileID?.trim()) {
            specs.push({
                DriverKey: 'AttachedFileTranscriptSource',
                Context: {},
            });
        }

        // 2. Load video provider configuration if attached to the meeting
        const singleRowMax = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow;
        let providerRow: Pick<mjBizAppsTasksVideoProviderEntity, 'Code' | 'CredentialID' | 'Configuration' | 'SupportsTranscripts'> | null = null;
        if (meeting.VideoProviderID && IsValidUUID(meeting.VideoProviderID)) {
            const rv = RunView.FromMetadataProvider(this.provider);
            const vpRes = await rv.RunView<
                Pick<mjBizAppsTasksVideoProviderEntity, 'Code' | 'CredentialID' | 'Configuration' | 'SupportsTranscripts'>
            >(
                {
                    EntityName: VIDEO_PROVIDERS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(meeting.VideoProviderID)}'`,
                    Fields: ['Code', 'CredentialID', 'Configuration', 'SupportsTranscripts'],
                    MaxRows: singleRowMax,
                    ResultType: 'simple',
                },
                contextUser,
            );
            providerRow = vpRes.Success ? (vpRes.Results?.[0] ?? null) : null;
        }

        if (explicitDriver?.trim()) {
            const trimmed = explicitDriver.trim();
            if (!specs.some((s) => s.DriverKey === trimmed)) {
                specs.push({
                    DriverKey: trimmed,
                    Context: {
                        CredentialID: providerRow?.CredentialID ?? null,
                        Configuration: providerRow?.Configuration ?? null,
                    },
                });
            }
            return specs;
        }

        // 3. Match Zoom provider or Zoom join URL
        const isZoomProvider = providerRow?.Code?.toUpperCase() === 'ZOOM';
        const hasZoomUrl = Boolean(extractZoomMeetingIdFromUrl(meeting.VideoJoinURL));
        if (isZoomProvider || hasZoomUrl) {
            let credentialId = providerRow?.CredentialID ?? null;
            let configuration = providerRow?.Configuration ?? null;

            if (!providerRow && hasZoomUrl) {
                const rv = RunView.FromMetadataProvider(this.provider);
                const zoomRes = await rv.RunView<
                    Pick<mjBizAppsTasksVideoProviderEntity, 'CredentialID' | 'Configuration'>
                >(
                    {
                        EntityName: VIDEO_PROVIDERS_ENTITY,
                        ExtraFilter: `Code = 'ZOOM' AND IsActive = 1`,
                        Fields: ['CredentialID', 'Configuration'],
                        MaxRows: singleRowMax,
                        ResultType: 'simple',
                    },
                    contextUser,
                );
                const zoomRow = zoomRes.Success ? zoomRes.Results?.[0] : undefined;
                if (zoomRow) {
                    credentialId = zoomRow.CredentialID ?? null;
                    configuration = zoomRow.Configuration ?? null;
                }
            }

            specs.push({
                DriverKey: 'ZoomTranscriptSource',
                Context: {
                    CredentialID: credentialId,
                    Configuration: configuration,
                },
            });
        }

        return specs;
    }

    private async draftMeetingNote(
        meetingID: string,
        plainText: string,
        input: ProcessMeetingTranscriptInput,
        contextUser: UserInfo,
    ): Promise<mjBizAppsTasksMeetingNoteEntity> {
        const notesService = new MeetingNotesService(this.provider);
        if (input.PromptRunner) {
            return notesService.draftFromTranscript(meetingID, plainText, contextUser, {
                promptRunner: input.PromptRunner,
            });
        }

        try {
            return await notesService.draftFromTranscript(meetingID, plainText, contextUser);
        } catch (err) {
            const allowFallback = input.AllowHeuristicFallback !== false;
            const msg = err instanceof Error ? err.message : String(err);
            const isNoRuntime =
                /No AI prompt runtime|not configured or active|did not return a valid meeting summary/i.test(msg);
            if (!allowFallback || !isNoRuntime) {
                throw err;
            }
            return notesService.draftFromTranscript(meetingID, plainText, contextUser, {
                promptRunner: defaultMeetingNotesPromptRunner,
            });
        }
    }

    private async loadRecentTaskCandidates(
        windowDays: number,
        contextUser: UserInfo,
    ): Promise<TaskSimilarityCandidate[]> {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const rv = RunView.FromMetadataProvider(this.provider);
        const cutoff = new Date(Date.now() - windowDays * 24 * 60 * 60 * 1000).toISOString();
        const tasksRes = await rv.RunView<RawCandidateTaskRow>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `Status IN ('Open', 'InProgress', 'Blocked') OR __mj_UpdatedAt >= '${EscapeSQLString(cutoff)}'`,
                Fields: ['ID', 'Name', 'Description', 'Status', 'Priority', 'DueAt', '__mj_UpdatedAt'],
                OrderBy: '__mj_UpdatedAt DESC',
                MaxRows: limits.ResourceGuards.BriefingTasksMaxRows,
                ResultType: 'simple',
            },
            contextUser,
        );
        const rows = tasksRes.Success ? (tasksRes.Results ?? []) : [];
        if (rows.length === 0) return [];

        const validIds = rows.map((r) => r.ID).filter((id) => IsValidUUID(id));
        const assigneesByTask = new Map<string, string[]>();
        if (validIds.length > 0) {
            const inList = validIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
            const assignRes = await rv.RunView<RawCandidateAssignmentRow>(
                {
                    EntityName: TASK_ASSIGNMENTS_ENTITY,
                    ExtraFilter: `TaskID IN (${inList})`,
                    Fields: ['TaskID', 'AssigneeRecordID'],
                    ResultType: 'simple',
                    MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                },
                contextUser,
            );
            for (const row of assignRes.Success ? (assignRes.Results ?? []) : []) {
                const key = row.TaskID.toLowerCase();
                const list = assigneesByTask.get(key) ?? [];
                list.push(row.AssigneeRecordID);
                assigneesByTask.set(key, list);
            }
        }

        return rows.map((r) => ({
            ID: r.ID,
            Name: r.Name,
            Description: r.Description ?? null,
            Status: r.Status,
            Priority: r.Priority ?? null,
            DueAt: toIsoOrNull(r.DueAt),
            UpdatedAt: toIsoOrNull(r.__mj_UpdatedAt),
            AssigneePersonIDs: assigneesByTask.get(r.ID.toLowerCase()) ?? [],
        }));
    }
}
