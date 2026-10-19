# Creating and upgrading projects

## Start a new application

1. Install Flutter 3.44.3 (Dart 3.12.2), Git, and the native SDKs for your target platforms.
2. Clone this template; retain the checkout as your tooling source.
3. Preview and create a new destination:

   ```bash
   dart tool/mobile_core.dart create --name field_app --org com.acme --output ../field_app --dry-run
   dart tool/mobile_core.dart create --name field_app --org com.acme --output ../field_app
   ```

4. Run `flutter run` in the new app. Initialize Git and commit the generated result before installing optional features.
5. For API-backed applications choose `--preset standard`; for the four-environment workflow choose `--preset enterprise`. Neither installs Firebase.

Creation stages files next to the destination, uses `flutter create` for native platforms, resolves dependencies, formats, analyzes, and runs tests. A failed mandatory command returns nonzero, cleans staging, and never claims success. Existing destinations, including symlinks, are refused. The current app's modules and routing files are never reset.

## Configure an API

Use your own endpoint:

```bash
flutter run --dart-define=API_BASE_URL=https://your-real-api-host
```

The default empty URL is offline mode; accessing the standard network service without a URL throws. Production rejects HTTP, placeholder domains, embedded credentials, and query/fragment values. Development entry points may use HTTP when platform transport policies permit it. Never compile a server secret into a client.

## Install Firebase deliberately

From a generated app with a clean Git tree:

```bash
dart /path/to/template/tool/mobile_core.dart feature add firebase --dry-run
dart /path/to/template/tool/mobile_core.dart feature add firebase
```

The command installs the Dart dependencies, service source, token tests, and managed startup hook. It does not access your Firebase/Apple accounts or invent native configuration. Finish app-owned setup:

- Run `flutterfire configure` for your Firebase project and target apps. Follow its generated configuration for Firebase initialization and Android Google Services/Crashlytics Gradle plugins.
- If using generated Dart options, set `FirebaseService.optionsProvider = () => DefaultFirebaseOptions.currentPlatform` in your app's main function before calling bootstrap/initialization. Keep that assignment outside the managed `lib/app/integrations.dart` file.
- Configure Android notification permissions/channel/icon and the local-notification plugin's native build requirements. Generated apps include Java 17/desugaring support. Select a proper monochrome notification icon for release.
- Enable iOS Push Notifications and remote-notification background mode, configure APNs in Firebase, and verify the signing entitlements. Native foreground banners are used on iOS.
- Set `NotificationService.onNotificationTapped` to your app's validated navigation handler; payload values never directly trigger arbitrary routes.
- Decide when permissions should be requested. The supplied service requests them during initialization; adapt it if your product requires an onboarding prompt.
- Verify denied permissions, token refresh, foreground/background/terminated messages, and crash reporting on physical devices.

Initialization errors propagate to the startup failure screen. Collection is disabled in debug by default; disabled collection does not replace framework/platform handlers. Enabled reporting preserves existing handlers and does not suppress an error simply because a report was scheduled.

Feature removal only removes unchanged managed Dart files and tool-owned dependencies. App-owned FlutterFire options, native files, Gradle plugins, entitlements, and main-function imports must be reviewed manually. If an app import would break, removal fails analysis and restores the previous state. Customized service code must be migrated manually; the tool will not delete it.

## Version 1 to version 2 migration

Make a branch and commit a checkpoint. This is a breaking source-template change; do not run the old project initializer or replace your application's modules.

1. Move `lib/core/app/bootstrap.dart` to `lib/app/bootstrap.dart` and `lib/core/di/register_app.dart` to `lib/app/di/register_app.dart`. Update app imports/exports, remove app exports from `core/core.dart`, and preserve your registrations/tasks.
2. Adapt startup to report failures visibly. Do not let a caught Firebase/configuration error masquerade as successful initialization.
3. Replace company-specific flavor values with your `API_BASE_URL` build configuration. `firebaseRoot`, `distance`, and unused socket aliases are removed; migrate real business uses into application configuration.
4. Choose whether to keep Firebase. Existing apps that use it should retain their dependencies/configuration and adopt the redacted logging/error-handling changes. Firebase-free apps should remove imports, tasks, exports, Dart dependencies and unused native configuration, then run `flutter pub get`.
5. Keep one shared widget implementation; application-facing wrappers now re-export the core version.
6. Update the scripts/tooling through a reviewed Git diff. The new sync wrapper requires `tool/sync_template.py`. Tooling updates are not automatically sealed/synchronized.
7. Review the upstream diff, resolve conflicts, and run analysis/tests and platform builds. Do not reset the manifest to current local hashes to silence a conflict. Only maintainers deliberately establishing a reviewed baseline should use `build_manifest.sh --refresh`.

New generated apps use `.mobile-core.json` and reviewed source upgrades. The legacy sealed-file mechanism remains for existing adopters; it is not a package manager and cannot migrate application dependencies or native build settings.

## Release checklist

- Run `verify`, generated-project CI, and target platform builds.
- Configure Android release keys in ignored `android/key.properties`; never commit signing files. Release tasks fail without signing configuration.
- For iOS distribution, configure signing and export an IPA in your own release workflow. The supplied unsigned app ZIP is for build inspection only.
- Validate backend configuration, startup failure UX, logging, accessibility, and any installed integrations in the actual application.
- Keep changes and an upgrade note with each template version. Shared packages, separately installable deep links/localization, and fully automated native feature changes are future work, not current capabilities.
