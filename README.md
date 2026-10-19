# Flutter Mobile Core Template

A Flutter starter with a small default app and an optional, more structured foundation for API-backed applications. Project creation generates into a **new destination** and verifies the result before reporting success. This is a development template, not a claim that every generated app is production-ready.

## Toolchain

Use **Flutter 3.44.3 / Dart 3.12.2**, pinned in `.fvmrc` and GitHub Actions. Flutter and Dart must be on `PATH`. The legacy sync tooling also needs Python 3.9+ and Git; the module generator needs Bash and Perl. These scripts target macOS and Linux.

## Create an app

From this repository:

```bash
dart tool/mobile_core.dart create \
  --name field_app --org com.acme --output ../field_app
cd ../field_app
flutter run
```

The default is `--preset minimal`. The destination must not exist, and its parent must exist. `--dry-run` previews creation without running Flutter or writing files. The old `scripts/new_project.sh` forwards to this command; it no longer initializes or resets the current checkout.

| Preset | Included |
| --- | --- |
| `minimal` (default) | Flutter app shell, Material theme, startup failure screen, linting, smoke test. No Firebase, Dio, DI, Provider, or flavor matrix. |
| `standard` | Existing networking, DI, routing, themes, UI components, error handling, and screen-scoped view models. One entry point. |
| `enterprise` | Standard foundation plus dev/qas/pre/prod entry points and CI/release workflows. |

The repository's `lib/` is the **standard/enterprise source**, so `flutter run` in this checkout shows that foundation. Minimal apps are generated from `tool/templates/presets/minimal`. Creation never copies your Git history, signing material, Firebase configuration, or template test tooling into the app.

All presets can start offline without credentials. In standard/enterprise apps, networking is lazy: attempting to use it without `--dart-define=API_BASE_URL=...` fails explicitly. Configured URLs must be real HTTP(S) URLs; production requires HTTPS. No company endpoints are bundled. Values compiled into an app are public configuration, not secrets.

## Optional integrations

Keep the source template checkout available. Run these commands **from your generated app**:

```bash
dart /path/to/mobile_core_template/tool/mobile_core.dart feature list
dart /path/to/mobile_core_template/tool/mobile_core.dart feature add networking_dio --dry-run
dart /path/to/mobile_core_template/tool/mobile_core.dart feature add networking_dio
dart /path/to/mobile_core_template/tool/mobile_core.dart feature remove networking_dio
```

Commit the app before adding or removing features. A clean Git working tree is mandatory for changes. `.mobile-core.json` records the preset, source version, installed dependencies, and exact generated source. Existing files are never overwritten. Removal refuses customized files and validation catches remaining application imports. Repeated adds/removes are no-ops. Ordinary failures restore source, pubspec, lockfile, and manifest; rerun `flutter pub get` afterward to refresh generated plugin metadata.

Currently supported:

- **`networking_dio`**: adds a small HTTPS Dio client and validation tests to minimal apps. Standard/enterprise already contain networking; it is part of those presets, not a removable feature.
- **`firebase`**: a bundled Firebase Core, Crashlytics, Messaging, and local-notification integration. Source and dependencies are absent until installed. Token/payload logging and implicit notification-route navigation are removed. Telemetry-disabled startup preserves existing error handlers.

Firebase installation verifies Dart source, **not a configured Firebase deployment**. The installer prints the remaining requirements. Run FlutterFire configuration for your own project, configure native plugin settings, notifications/APNs, entitlements and signing, and supply Firebase options before startup. Use an app-owned `main.dart` setup to assign `FirebaseService.optionsProvider`, or configure native platform files. Permission UX and notification callbacks belong to your app. Native account/project configuration is deliberately not guessed or deleted by removal. See [NEW_PROJECT.md](NEW_PROJECT.md).

Deep links, localization installers, separate Firebase subfeatures, and automatic native configuration migration are not implemented. Enterprise is a preset, not an assurance of compliance or production readiness.

## Application structure

```text
lib/app/              Startup and application dependency composition
lib/configs/          App-owned network adapters, environment and theme configuration
lib/core/             Reusable contracts, errors, view lifecycle, widgets and utilities
lib/modules/          Application feature modules
lib/widgets/          App-facing widgets; shared implementations re-export core widgets
lib/routes/           Application routes
tool/templates/       Generator input; optional Dart files use .dart.tmpl
```

`core/` does not import the app registration barrel. `lib/app/bootstrap.dart` owns startup and `lib/app/di/register_app.dart` owns concrete registrations. Startup exceptions show a visible fallback and flow through `FlutterError.reportError`; ordinary runtime errors retain Flutter's platform/framework handlers. The standard HTTP client preserves platform TLS certificate verification. The default logger emits only in debug builds. Production telemetry is an app decision.

For a standard/enterprise module:

```bash
dart /path/to/mobile_core_template/tool/mobile_core.dart module add profile
```

The CLI refuses an existing module. The shell wrapper accepts an explicit `--force` replacement and archives the original in `.module-backups/` before deleting anything. Register its repository in `lib/app/di/register_app.dart` and its route in `lib/routes/app_router.dart`. View models remain screen-scoped. Minimal apps use ordinary Flutter components and do not need the framework module generator.

## Verification

```bash
flutter pub get
flutter analyze --fatal-infos
flutter test
python3 -m unittest discover -s tool/tests -v
bash scripts/test_generated_projects.sh         # generate all presets; add/remove both features
bash scripts/test_generated_projects.sh --build # also build a debug APK for each preset
```

Generated apps also support `doctor` and `verify` through the source CLI. `verify` checks dependency resolution, formatting without writes, analysis, and tests; platform builds are separate. The generated-project CI job uses the same templates and minimum pinned SDK. Firebase account integration and physical-device delivery remain separate checks.

## Releases

Tagged releases pass formatting, analysis, and tests before artifact jobs start. Android release builds require `android/key.properties` and a real upload keystore; debug keys are never substituted. CI expects the `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, and `ANDROID_STORE_PASSWORD` secrets.

The iOS artifact is an **unsigned Runner.app ZIP**, not an installable IPA. A distributable IPA requires your Apple signing/export configuration. The default release workflow intentionally does not invent it.

## Source upgrades and legacy sync

New apps own copied source. Upgrade with reviewed Git diffs; they are not automatically enrolled in sealed-file synchronization. Versioned shared packages remain a future migration after stable public API boundaries are established.

For projects already using `.template/manifest.json`:

```bash
./scripts/sync_template.sh v2.0.0          # preview only; choose an existing upstream ref
./scripts/sync_template.sh v2.0.0 --apply  # apply only after reviewing
```

The default source is `https://github.com/TaingJingSong/mobile_core_template.git`; `TEMPLATE_REPO` can select an HTTPS/SSH URL or local Git repository. With no ref, sync uses the repository's default branch, not its latest tag. A tag named here is an example, not a published release guarantee.

Sync preflights the complete update. Conflicts, deleted local files, untracked-file collisions, symlinks, or unsafe paths prevent all writes and leave the baseline intact. It never executes fetched scripts. The old `--force` option is gone. Successful changes update the upstream-derived baseline, and ordinary I/O failures restore original file contents. A process kill or power failure during writes can still leave partial changes: keep a Git checkpoint and inspect the diff before rerunning. Do not regenerate the manifest to hide conflicts.

Version 2 moves startup and app registration and removes obsolete flavor fields/Firebase exports. **Existing applications need the manual migration in [NEW_PROJECT.md](NEW_PROJECT.md); syncing core files alone is not that migration.**
