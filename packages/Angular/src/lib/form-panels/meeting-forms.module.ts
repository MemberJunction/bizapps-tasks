import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { MJButtonDirective, MjSlidePanelComponent } from '@memberjunction/ng-ui-components';
import {
    MeetingAgendaComponent,
    MeetingFollowUpsComponent,
    MeetingHeaderComponent,
    MeetingLinksComponent,
    MeetingListComponent,
    MeetingLiveComponent,
    MeetingNotesComponent,
    MeetingPeopleComponent,
} from '@mj-biz-apps/tasks-ng-widgets';
import { MeetingHeroPanel } from './meeting-hero.panel';
import { MeetingAgendaPanel, MeetingFollowUpsPanel, MeetingLinksPanel, MeetingNotesPanel, MeetingPeoplePanel, SeriesOccurrencesPanel } from './meeting-sections.panels';

const MODULE_PANELS = [MeetingHeroPanel, MeetingAgendaPanel, MeetingPeoplePanel, MeetingNotesPanel, MeetingFollowUpsPanel, MeetingLinksPanel, SeriesOccurrencesPanel];

/** The panels the generated Meetings and Meeting Series forms take: the hero, and the sections that stand in for the related grids. */
@NgModule({
    declarations: [...MODULE_PANELS],
    imports: [
        CommonModule,
        FormsModule,
        BaseFormsModule,
        MJButtonDirective,
        MjSlidePanelComponent,
        MeetingHeaderComponent,
        MeetingLiveComponent,
        MeetingAgendaComponent,
        MeetingPeopleComponent,
        MeetingNotesComponent,
        MeetingFollowUpsComponent,
        MeetingLinksComponent,
        MeetingListComponent,
    ],
    exports: [...MODULE_PANELS],
})
export class MeetingFormsModule {}
