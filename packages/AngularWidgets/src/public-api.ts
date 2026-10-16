/**
 * BizApps Tasks meeting widgets (the meetings plan, § 5): the parts of the Meetings app that any host composes, with no
 * Explorer dependency. The host reads the records and hands them in as the models in `types`; the widgets draw them and
 * ask for changes through their outputs.
 */
export * from './lib/types';
export * from './lib/format';
export * from './lib/series-rule';
export * from './lib/tokens';
export * from './lib/meeting-chips.component';
export * from './lib/attendee-response.component';
export * from './lib/meeting-list.component';
export * from './lib/meeting-card.component';
export * from './lib/meeting-header.component';
export * from './lib/meeting-people.component';
export * from './lib/meeting-agenda.component';
export * from './lib/meeting-notes.component';
export * from './lib/meeting-followups.component';
export * from './lib/meeting-links.component';
export * from './lib/meeting-live.component';
export * from './lib/meeting-series-editor.component';
export * from './lib/new-meeting-dialog.component';

export function LoadTasksMeetingWidgets(): void {}
