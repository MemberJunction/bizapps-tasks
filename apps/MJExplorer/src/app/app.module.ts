import { NgModule, APP_INITIALIZER } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';

// MJ Consolidated Module Bundles
import { MJExplorerModulesBundle, SharedService } from '@memberjunction/ng-explorer-modules';
import { AuthServicesModule, RedirectComponent, MJAuthBase } from '@memberjunction/ng-auth-services';
import { MJExplorerAppModule } from '@memberjunction/ng-explorer-app';

// Pre-built MJ class registrations
import { CLASS_REGISTRATIONS } from '@memberjunction/ng-bootstrap';

// BizApps Common class registrations
import { CLASS_REGISTRATIONS as COMMON_CLASSES } from '@mj-biz-apps/common-ng';

// BizApps Tasks module + class registrations
import { BizAppsTasksModule, LoadBizAppsTasksClient } from '@mj-biz-apps/tasks-ng';
LoadBizAppsTasksClient();

// MSAL
import { MsalGuardConfiguration } from '@azure/msal-angular';
import { InteractionType } from '@azure/msal-browser';

// App
import { AppComponent } from './app.component';
import { environment } from '../environments/environment';

// Merge all class registrations
const combinedClasses = [...CLASS_REGISTRATIONS, ...COMMON_CLASSES];

export function MSALGuardConfigFactory(): MsalGuardConfiguration {
  return { interactionType: InteractionType.Redirect };
}

export function initializeAuth(authService: MJAuthBase): () => Promise<void> {
  return () => authService.initialize();
}

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    MJExplorerModulesBundle,
    AuthServicesModule.forRoot(environment),
    MJExplorerAppModule.forRoot(environment),
    BizAppsTasksModule,
  ],
  providers: [
    SharedService,
    provideHttpClient(withInterceptorsFromDi()),
    {
      provide: APP_INITIALIZER,
      useFactory: initializeAuth,
      deps: [MJAuthBase],
      multi: true
    }
  ],
  bootstrap: [AppComponent, RedirectComponent],
})
export class AppModule {}
