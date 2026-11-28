import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    HostListener,
    Input,
    OnDestroy,
    OnInit,
    Output,
    inject,
} from '@angular/core';
import { NgTemplateOutlet } from '@angular/common';
import {
    MJBottomSheetComponent,
    MjSlidePanelComponent,
} from '@memberjunction/ng-ui-components';
import { IsPhoneViewport, WatchPhoneViewport } from '../../phone-viewport';

/**
 * Responsive drawer shell for BizApps Tasks panels.
 *
 * Uses MJ's `<mj-slide-panel>` on desktop/tablet and switches automatically to
 * MJ's `<mj-bottom-sheet>` on phones (`<= 768px`, matching `PHONE_VIEWPORT_QUERY`).
 */
@Component({
    selector: 'bizapps-task-drawer-shell',
    standalone: true,
    imports: [NgTemplateOutlet, MjSlidePanelComponent, MJBottomSheetComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (Visible) {
            @if (IsPhone) {
                <mj-bottom-sheet
                    [Visible]="Visible"
                    [Title]="Title"
                    [AriaLabel]="Title || 'Task drawer'"
                    (VisibleChange)="onSheetVisibleChange($event)"
                    (Closed)="Closed.emit()">
                    <ng-container *ngTemplateOutlet="bodyTpl"></ng-container>
                </mj-bottom-sheet>
            } @else {
                <mj-slide-panel
                    [Visible]="Visible"
                    [Title]="Title"
                    [WidthPx]="WidthPx"
                    [MinWidthPx]="420"
                    [Resizable]="Resizable"
                    (Closed)="Closed.emit()">
                    <ng-container *ngTemplateOutlet="bodyTpl"></ng-container>
                </mj-slide-panel>
            }
        }
        <ng-template #bodyTpl>
            <ng-content></ng-content>
        </ng-template>
    `,
    styles: [`
        :host { display: contents; }
    `],
})
export class TaskDrawerShellComponent implements OnInit, OnDestroy {
    @Input() Visible = false;
    @Input() Title = '';
    @Input() WidthPx = 560;
    @Input() Resizable = true;

    @Output() Closed = new EventEmitter<void>();

    public IsPhone = false;
    private stopWatchingPhone: (() => void) | null = null;
    private cdr = inject(ChangeDetectorRef);

    public ngOnInit(): void {
        this.IsPhone = IsPhoneViewport();
        this.stopWatchingPhone = WatchPhoneViewport(() => {
            const next = IsPhoneViewport();
            if (next !== this.IsPhone) {
                this.IsPhone = next;
                this.cdr.markForCheck();
            }
        });
    }

    public onSheetVisibleChange(visible: boolean): void {
        if (!visible && this.Visible) {
            this.Closed.emit();
        }
    }

    @HostListener('document:keydown.escape')
    public onEscapeKey(): void {
        if (this.Visible) {
            this.Closed.emit();
        }
    }

    public ngOnDestroy(): void {
        this.stopWatchingPhone?.();
    }
}
