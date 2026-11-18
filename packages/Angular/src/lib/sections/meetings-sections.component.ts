import { Component, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClass } from '@memberjunction/global';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import type { ResourceData } from '@memberjunction/core-entities';
import { MyMeetingsPageComponent } from '../pages/my-meetings.page';
import { MeetingsPageComponent } from '../pages/meetings.page';
import { MeetingSeriesPageComponent } from '../pages/meeting-series.page';

/** The Meetings application's nav items (metadata/applications/.meetings-application.json), as Explorer resources. */
@Component({
    selector: 'bizapps-my-meetings-section-resource',
    standalone: true,
    imports: [CommonModule, MyMeetingsPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-my-meetings-page></bizapps-my-meetings-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MyMeetingsSectionResource')
export class MyMeetingsSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'My meetings';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-user-clock';
    }
}

@Component({
    selector: 'bizapps-meetings-section-resource',
    standalone: true,
    imports: [CommonModule, MeetingsPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-meetings-page></bizapps-meetings-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MeetingsSectionResource')
export class MeetingsSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Meetings';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-calendar-check';
    }
}

@Component({
    selector: 'bizapps-meeting-series-section-resource',
    standalone: true,
    imports: [CommonModule, MeetingSeriesPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-meeting-series-page></bizapps-meeting-series-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MeetingSeriesSectionResource')
export class MeetingSeriesSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Series';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-repeat';
    }
}

/** Anchors the three resources so a bundler keeps their registrations. */
export function LoadMeetingsSectionResources(): void {
    const anchor = [MyMeetingsSectionResource, MeetingsSectionResource, MeetingSeriesSectionResource];
    if (!anchor.length) throw new Error('Meetings section resources missing');
}
