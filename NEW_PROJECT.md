# New Project Checklist

Follow these phases in order. Each phase ends with a verification step.
Do not skip verifications — most setup bugs surface later if you do.

---

## Prerequisites

- Flutter SDK installed (`flutter --version` works)
- The template repo cloned somewhere local
- Firebase CLI installed (`firebase --version`) if using Firebase
- An org / company identifier decided (e.g. `com.acme`)

---

## Phase 1 — Clone & Rename the Project

### 1.1 Copy the template

```bash
git clone <template-repo-url> new_app
cd new_app
rm -rf .git                    # start fresh history
git init
```

Or, on GitHub: click **Use this template** → create a new repo → clone it.

### 1.2 Rename the Flutter project

Pick these three values now and write them down:

| Value | Example | Notes |
|---|---|---|
| **Display name** | `My Company HR` | Shown under the app icon |
| **Project name (Dart package)** | `my_company_hr` | `snake_case`, used in imports |
| **Org identifier** | `com.acme` | Reverse-domain, used in bundle/package IDs |

Then run:

```bash
flutter create \
  --org com.acme \
  --project-name my_company_hr \
  --platforms ios,android \
  .
```

This regenerates the platform folders (`ios/`, `android/`) with the correct identifiers. Your `lib/` is preserved.

### 1.3 Update `pubspec.yaml`

```yaml
name: my_company_hr
description: HR mobile app for Acme
version: 1.0.0+1
```

### 1.4 Verify

```bash
flutter pub get
flutter analyze
```

**Checkpoint:** `flutter analyze` reports no issues. You haven't touched `lib/` yet — this just confirms the rename worked.

---

## Phase 2 — App Identity & Config

These are the only files you *must* edit before first run.

### 2.1 `lib/configs/app_configs/app_config.dart`

Edit the **identity**, **API**, and **locale** sections:

```dart
static const String appName = 'My Company HR';
static const String packageName = 'com.acme.my_company_hr';
static const String baseUrl = 'https://api.acme.com';
static const String defaultLocale = 'en';
static const List<String> supportedLocales = ['en', 'km'];
```

Everything else in this file can wait.

### 2.2 `lib/configs/theme/app_colors.dart`

Replace `primaryColor` and `secondaryColor` with your brand colors. Keep the semantic colors (`error`, `success`, `warning`, `info`) as-is unless you have a reason.

```dart
static const Color primaryColor = Color(0xFF...);    // your brand
static const Color secondaryColor = Color(0xFF...);  // your accent
```

### 2.3 `lib/configs/app_configs/flavor/flavor_config.dart`

Edit `valuesFor(Environment env)` — replace each URL with your project's:

```dart
case Environment.dev:
  return const FlavorValues(
    name: 'dev',
    url: 'https://dev-api.acme.com',
    firebaseRoot: 'Dev',
    distance: 1000,
  );
// ...qas, pre, prod
```

### 2.4 `lib/configs/translation/app_translation_key.dart`

Replace the app-specific keys with your project's. **Keep the core keys** (`retry`, `loading`, `somethingWentWrong`, etc.) — those are used by core widgets.

### 2.5 `lib/routes/app_routes.dart`

Clear out the route constants you don't need. Keep `initial`, `home` as starting points.

### 2.6 `lib/routes/app_router.dart`

Configure your routes:

```dart
static Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.initial:
    case Routes.home:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const HomeView(),
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
```

### 2.7 Feature modules

Feature modules live in `lib/modules/<feature_name>/` (e.g. `lib/modules/auth/`, `lib/modules/profile/`).

### 2.8 Singletons and Services

`lib/data/singletons/` provides `global_overlay.dart` and `user_singleton.dart`. Add project-specific singletons as needed.

### 2.9 Checkpoint

```bash
flutter analyze
flutter test
```

This is your **Day One** state:
- Core is intact.
- App-specific registrations are minimal.
- Router points only at routes you'll build.
- Modules folder is clean and ready.

---

## Phase 3 — Firebase Setup

Skip this phase entirely if your app doesn't use Firebase.

### 3.1 Create the Firebase project

1. Go to <https://console.firebase.google.com>
2. Create a new project, e.g. `acme-hr`
3. Add an Android app with the package name from Phase 1.2 (e.g. `com.acme.my_company_hr`)
4. Add an iOS app with the same bundle ID

### 3.2 Download the config files

**Android:** Download `google-services.json` → place at `android/app/google-services.json`.

**iOS:** Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`.

Add them via Xcode (drag into the Runner target) so they get registered in the Xcode project.

### 3.3 Set up multiple flavors (optional)

If you use different Firebase projects per flavor:
- Android: put `google-services.json` files in `android/app/src/dev/`, `android/app/src/qas/`, etc.
- iOS: put `GoogleService-Info.plist` files in `ios/config/dev/`, `ios/config/qas/`, etc. and add a Run Script build phase to copy the right one.

### 3.4 Verify

```bash
flutter run -t lib/main_dev.dart
```

**Checkpoint:** App launches. Firebase initializes without warnings.

---

## Phase 4 — Signing

### 4.1 Android — create an upload keystore

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Save the keystore somewhere safe. **Do not commit it to git.**

### 4.2 Android — create `android/key.properties`

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/Users/you/upload-keystore.jks
```

Add to `.gitignore`:

```
android/key.properties
*.jks
*.keystore
```

### 4.3 Android — update `android/app/build.gradle` or `build.gradle.kts`

Add the signing config:

```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 4.4 iOS — open Xcode and set signing

```bash
open ios/Runner.xcworkspace
```

- Select the `Runner` target → **Signing & Capabilities**
- Choose your Team
- Set the Bundle Identifier to match Phase 1.2
- Enable **Automatically manage signing**

### 4.5 Verify

```bash
flutter build apk --debug
flutter build ios --no-codesign
```

**Checkpoint:** Both builds complete.

---

## Phase 5 — Run Every Flavor

### 5.1 Flutter run commands

```bash
flutter run -t lib/main_dev.dart      # dev
flutter run -t lib/main_qas.dart      # qas
flutter run -t lib/main_pre.dart      # pre
flutter run -t lib/main.dart          # prod
```

### 5.2 Add VS Code / Android Studio run configs (optional)

**`.vscode/launch.json`:**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "flutterMode": "debug"
    },
    {
      "name": "QAS",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_qas.dart",
      "flutterMode": "debug"
    },
    {
      "name": "Pre",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_pre.dart",
      "flutterMode": "debug"
    },
    {
      "name": "Prod",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "release"
    }
  ]
}
```

### 5.3 Verify

**Checkpoint:** All four flavors launch and reach the home view. You see the flavor name logged in the console (`[FLAVOR] dev` etc).

---

## Phase 6.5 — CI/CD Setup

### 6.5.1 Enable workflows

The `.github/workflows/` folder is already in place. Push the repo to GitHub and the workflows activate.

### 6.5.2 Configure repository secrets (for releases)

Only needed if you plan to ship via GitHub Releases:

**Settings → Secrets and variables → Actions → New repository secret:**

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` output |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | your key password |
| `ANDROID_STORE_PASSWORD` | your keystore password |

### 6.5.3 Configure repository variables

**Settings → Secrets and variables → Actions → Variables:**

| Variable | Value |
|---|---|
| `TEMPLATE_REPO` | URL of the template repo (used by drift check) |

### 6.5.4 Create the `template-drift` label

**Issues → Labels → New label:**

- Name: `template-drift`
- Color: `#FBCA04`

### 6.5.5 Verify CI runs

Push an empty commit and confirm the CI workflow passes:

```bash
git commit --allow-empty -m "Trigger CI"
git push
```

### 6.5.6 Local pre-commit hook (optional)

```bash
./scripts/install_hooks.sh
```

Bypass with `git commit --no-verify`.

---

## Phase 6 — Build Your First Feature

Follow this pattern for **every** feature:

### 6.1 Create the module folder

```bash
mkdir -p lib/modules/profile/{models,repository,view_models,views}
touch lib/modules/profile/profile.dart
```

### 6.2 `lib/modules/profile/profile.dart` (barrel)

```dart
export 'models/profile_model.dart';
export 'repository/profile_repository.dart';
export 'view_models/profile_view_model.dart';
export 'views/profile_view.dart';
```

### 6.3 `lib/modules/profile/models/profile_model.dart`

Plain Dart class. No Flutter imports.

```dart
class Profile {
  const Profile({required this.id, required this.name});
  final String id;
  final String name;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}
```

### 6.4 `lib/modules/profile/repository/profile_repository.dart`

Interface + implementation. View models depend on the interface.

```dart
import 'package:app_base/register.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile(String id);
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);
  final BaseApiService _api;

  @override
  Future<Profile> getProfile(String id) async {
    final response = await _api.getResponse('profile/$id');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }
}
```

### 6.5 `lib/modules/profile/view_models/profile_view_model.dart`

Extends `CoreViewModel`. Takes the repository via constructor.

```dart
import 'package:app_base/register.dart';
import '../models/profile_model.dart';
import '../repository/profile_repository.dart';

class ProfileViewModel extends CoreViewModel {
  ProfileViewModel(this._repo);
  final ProfileRepository _repo;

  Profile? _profile;
  Profile? get profile => _profile;

  Future<void> load(String id) async {
    setBusy(true, useOverlayLoader: true);
    try {
      _profile = await _repo.getProfile(id);
    } catch (e) {
      final failure = ErrorHandler.map(e);
      locator<ToastBinding>().error(failure.message);
    } finally {
      setBusy(false);
    }
  }
}
```

### 6.6 `lib/modules/profile/views/profile_view.dart`

Wraps with `CoreView`. Handles per-screen lifecycle.

```dart
import 'package:app_base/register.dart';
import '../repository/profile_repository.dart';
import '../view_models/profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return CoreView<ProfileViewModel>(
      model: ProfileViewModel(locator<ProfileRepository>()),
      onModelReady: (vm) => vm.load(id),
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: vm.profile == null
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(vm.profile!.name)),
      ),
    );
  }
}
```

### 6.7 Register the repository

In `lib/core/di/register_app.dart`:

```dart
locator.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(locator<BaseApiService>()),
);
```

### 6.8 Register the route

In `lib/routes/app_routes.dart`:

```dart
static const profileView = '/profile';
```

In `lib/routes/app_router.dart`:

```dart
case Routes.profileView:
  final id = settings.arguments as String? ?? 'default';
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => ProfileView(id: id),
  );
```

### 6.9 Verify

**Checkpoint:** Navigating to `Routes.profileView` renders the view, fetches the data, and displays the profile name.

---

## Rules of Thumb

### ✅ Do

- Add every **repo** to `registerApp()` with `registerLazySingleton`.
- Create every **view model** inline inside `CoreView` (per-screen lifecycle).
- Add every **view** to the router in `app_router.dart`.
- Put every shared widget **without app colors** into `core/widgets/`.
- Put every widget **with app colors** into `widgets/` or the feature module.
- Add every new **translation key** to `TranslationKey`.
- Log via `locator<LoggerBinding>()`, never `print()` or `debugPrint()`.

### ❌ Don't

- Add view models to `app_providers.dart` (they belong per-screen).
- Add app brand colors to `core/theme/`.
- Add feature-specific keys to `core/translation/`.
- Import `AppColor` from anything inside `core/`.
- Import feature modules from `core/`.
- Hardcode URLs — always route through `FlavorConfig`.

---

## Common Pitfalls

### App won't start after rename

You forgot to run `flutter create` in Phase 1.2. The bundle ID / package name in `ios/Runner.xcodeproj` and `android/app/build.gradle` still points at the old name. Re-run `flutter create` from the project root.

### Firebase logs "No Firebase App '[DEFAULT]' has been created"

`FirebaseService.initializeFirebase()` isn't in the flavor's task list. Open that `main_*.dart` and add the task.

### `MaterialApp` shows blank white screen after adding a route

The route path in `app_router.dart` doesn't match `Routes.X`. Case-sensitive.

### View model state leaks between visits to the same screen

You put the view model in `app_providers.dart` instead of `CoreView`. Move it back to per-screen.

### `No ThemeExtension of type AppColors found`

You didn't register `AppColors()` in `ThemeData.extensions`. Check `AppTheme.light()` / `AppTheme.dark()`.

### API returns 401 on every request

`HeaderProviderImpl` is reading the token from the wrong storage key. Check `AppConfig.keyAccessToken` matches what your login flow writes.

### Widgets render but colors are wrong

`core/widgets/` widgets use `context.appColors`. If you see `null` or grey, `AppColorsExtension` isn't registered in the theme, or the widget is hardcoding `AppColor` (in which case it belongs app-level).

---

## Per-Flavor Quick Reference

| Command | Purpose |
|---|---|
| `flutter run -t lib/main_dev.dart` | Local dev, uses dev API |
| `flutter run -t lib/main_qas.dart` | QA, uses UAT API |
| `flutter run -t lib/main_pre.dart` | Pre-prod, uses staging API |
| `flutter run -t lib/main.dart` | Prod, uses prod API |
| `flutter build apk -t lib/main.dart --release` | Release APK |
| `flutter build appbundle -t lib/main.dart --release` | Play Store AAB |
| `flutter build ipa -t lib/main.dart --release` | iOS IPA for TestFlight/App Store |

---

## Sealed Core — Never Touch Per Project

These files are part of the reusable template. If you find yourself editing them in a new project, something is wrong. Fix it in the template repo, then re-copy.

```
lib/core/base/             ← CoreViewModel, CoreView, bindings
lib/core/mixins/           ← loading, auto-dispose, network-aware
lib/core/network/          ← BaseApiService, NetworkInfo, HttpConfig interfaces
lib/core/errors/           ← Failure, AppException, ErrorHandler
lib/core/theme/            ← CoreColors, CoreTheme, AppColorsExtension
lib/core/translation/      ← CoreTranslationKey, translation extension
lib/core/routing/          ← NavigatorKeys, NavigationLogger
lib/core/widgets/          ← framework-agnostic widgets
lib/core/di/register_core.dart
lib/core/app/bootstrap.dart
```

If any file in this list references `AppColor`, `TranslationKey`, or a feature module — that's a bug. Report it against the template.

---

## What to Do After Day One

1. Add splash + onboarding screens (or delete them if unused).
2. Build your auth flow (login, OTP, reset password).
3. Pick a first feature (e.g. profile, dashboard) and follow Phase 6.
4. Add tests for `core/` — they should never need updating per-project.
5. Add your CI: `.github/workflows/` with `flutter analyze`, `flutter test`, `flutter build apk` for each flavor.
