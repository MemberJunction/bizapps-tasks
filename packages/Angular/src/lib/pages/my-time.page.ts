import { ChangeDetectionStrategy, ChangeDetectorRef, Component, inject, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LogError } from '@memberjunction/core';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person';
import { MyTimeComponent } from '../components/my-time/my-time.component';
import { RunningTimerChipComponent } from '../components/running-timer-chip/running-timer-chip.component';

/**
 * My Time page combining the running-timer header chip with the {@link MyTimeComponent}
 * weekly and period timesheet grid (§8.4).
 */
@Component({
    selector: 'bizapps-my-time-page',
    standalone: true,
    imports: [CommonModule, MyTimeComponent, RunningTimerChipComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-page-wrap">
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar">
                            <i class="fa-solid fa-stopwatch" aria-hidden="true"></i>
                        </div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">My Time &amp; Timesheets</h1>
                            <p class="mjt-subtitle">Weekly and period time entry grid, timer activity, and timesheet submission.</p>
                        </div>
                    </div>
                    <bizapps-running-timer-chip
                        [PersonID]="PersonID"
                        (TimerStopped)="OnTimerStopped()">
                    </bizapps-running-timer-chip>
                </div>
            </div>

            <div class="mjt-body-card">
                @if (PersonID) {
                    <bizapps-my-time
                        #myTimeGrid
                        [PersonID]="PersonID">
                    </bizapps-my-time>
                } @else if (PersonLookupFailed) {
                    <p class="mjt-empty">{{ LookupFailedMessage }}</p>
                } @else if (PersonResolved) {
                    <p class="mjt-empty">{{ NoPersonMessage }}</p>
                }
            </div>
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-page-wrap { display: flex; flex-direction: column; gap: 16px; padding: 16px; box-sizing: border-box; }
        .mjt-header-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
        .mjt-header-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
        .mjt-identity { display: flex; align-items: center; gap: 14px; }
        .mjt-avatar {
            width: 48px; height: 48px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-brand-primary, #0284c7); color: var(--mj-text-inverse, #ffffff);
            display: flex; align-items: center; justify-content: center; font-size: 20px;
            box-shadow: var(--mj-shadow-sm); flex-shrink: 0;
        }
        .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
        .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }
        .mjt-empty { margin: 0; font-size: 13px; color: var(--mj-text-secondary, #475569); }
        .mjt-body-card {
            background: var(--mj-bg-surface-card, #ffffff); border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px); padding: 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
    `],
})
export class MyTimePageComponent implements OnInit {
    public PersonID: string | null = null;
    public PersonResolved = false;
    public PersonLookupFailed = false;
    public readonly NoPersonMessage = NO_PERSON_MESSAGE;
    public readonly LookupFailedMessage = PERSON_LOOKUP_FAILED_MESSAGE;

    @ViewChild('myTimeGrid') public myTimeGrid?: MyTimeComponent;

    private cdr = inject(ChangeDetectorRef);

    public async ngOnInit(): Promise<void> {
        try {
            this.PersonID = await ResolveCurrentPersonID();
        } catch (err) {
            LogError(err);
            this.PersonLookupFailed = true;
        }
        this.PersonResolved = true;
        this.cdr.markForCheck();
    }

    public OnTimerStopped(): void {
        void this.myTimeGrid?.Refresh();
    }
}
