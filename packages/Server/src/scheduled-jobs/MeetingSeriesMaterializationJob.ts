/**
 * Meeting Series Materialization Scheduled Job
 *
 * Runs on a cron schedule (the shipped job: daily) to extend each active series' occurrences up to the horizon
 * (the meetings plan, § 3): a slot with no meeting gets one, an untouched future meeting takes the series' values,
 * and a series whose rule has run out is marked Ended. The work is MeetingSeriesService's; this registers the
 * schedule with MemberJunction's scheduling engine, the way the overdue-task job does.
 *
 * Configuration (optional): { "HorizonDays": <number> }, default 90.
 */
import { Metadata, RunView, ValidationResult, type UserInfo } from '@memberjunction/core';
import type { MJScheduledJobEntity } from '@memberjunction/core-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseScheduledJob, type ScheduledJobExecutionContext } from '@memberjunction/scheduling-engine';
import type { NotificationContent, ScheduledJobResult } from '@memberjunction/scheduling-base-types';
import { DEFAULT_HORIZON_DAYS, MEETING_SERIES_ENTITY, MeetingSeriesService } from '@mj-biz-apps/tasks-core';

interface SeriesRow {
    ID: string;
    Name: string;
}

@RegisterClass(BaseScheduledJob, 'ScheduledJobMeetingSeriesMaterialization')
export class MeetingSeriesMaterializationJob extends BaseScheduledJob {
    async Execute(context: ScheduledJobExecutionContext): Promise<ScheduledJobResult> {
        const { ContextUser } = context;
        const horizonDays = this.horizonDays(context);
        try {
            const series = await this.activeSeries(ContextUser);
            const service = new MeetingSeriesService(Metadata.Provider);
            let created = 0;
            let updated = 0;
            let cancelled = 0;
            let ended = 0;
            const failures: string[] = [];
            for (const row of series) {
                try {
                    const result = await service.materialize(row.ID, ContextUser, { horizonDays });
                    created += result.created;
                    updated += result.updated;
                    cancelled += result.cancelled;
                    if (result.ended) ended += 1;
                } catch (error) {
                    const message = error instanceof Error ? error.message : String(error);
                    failures.push(`${row.Name} (${row.ID}): ${message}`);
                    this.logError(`Series ${row.ID} was not materialized`, error);
                }
            }
            this.log(`Materialized ${series.length} series: ${created} made, ${updated} updated, ${cancelled} cancelled, ${ended} ended, ${failures.length} failed`);
            return {
                Success: failures.length === 0,
                ErrorMessage: failures.length ? failures.join('; ') : undefined,
                Details: { series: series.length, created, updated, cancelled, ended, failures },
            };
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            this.logError('Meeting series materialization failed', error);
            return { Success: false, ErrorMessage: message };
        }
    }

    ValidateConfiguration(_schedule: MJScheduledJobEntity): ValidationResult {
        // Configuration is optional ({ HorizonDays }); a bad value falls back to the default
        const result = new ValidationResult();
        result.Success = true;
        return result;
    }

    FormatNotification(_context: ScheduledJobExecutionContext, result: ScheduledJobResult): NotificationContent {
        const details = (result.Details ?? {}) as { series?: number; created?: number; updated?: number; cancelled?: number; failures?: string[] };
        const failures = details.failures?.length ?? 0;
        return {
            Subject: `Meeting series: ${details.created ?? 0} occurrence(s) made across ${details.series ?? 0} series`,
            Body: failures
                ? `${failures} series failed to materialize: ${details.failures?.join('; ')}`
                : `${details.created ?? 0} made, ${details.updated ?? 0} updated, ${details.cancelled ?? 0} cancelled.`,
            Priority: failures ? 'High' : 'Low',
        };
    }

    private horizonDays(context: ScheduledJobExecutionContext): number {
        const configuration = (context as { Configuration?: unknown }).Configuration;
        const raw = typeof configuration === 'string' ? this.parse(configuration) : configuration;
        const value = raw && typeof raw === 'object' ? (raw as { HorizonDays?: unknown }).HorizonDays : undefined;
        const days = Number(value);
        return Number.isFinite(days) && days > 0 ? days : DEFAULT_HORIZON_DAYS;
    }

    private parse(text: string): unknown {
        try {
            return JSON.parse(text);
        } catch {
            return null;
        }
    }

    private async activeSeries(contextUser: UserInfo): Promise<SeriesRow[]> {
        const res = await new RunView().RunView<SeriesRow>(
            { EntityName: MEETING_SERIES_ENTITY, ExtraFilter: `Status = 'Active'`, Fields: ['ID', 'Name'], ResultType: 'simple', MaxRows: 5000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The active series could not be read: ${res.ErrorMessage}`);
        return res.Results;
    }
}
