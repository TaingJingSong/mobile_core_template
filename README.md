# Mobile Core Template

> A production-ready, highly decoupled, state-management-agnostic Flutter mobile architecture template designed for scalable team development.

---

## 🌟 Highlights

- **Sealed Core (`lib/core/`)**: Zero app-specific coupling. Pure contracts, abstractions, network clients, domain error handling, and reusable agnostic UI components.
- **State-Management-Agnostic Core**: Clean separation between domain/data logic and state management. View models are bounded per-screen, avoiding memory-leaking app-lifetime singletons.
- **Single Bootstrap Engine (`lib/core/app/bootstrap.dart`)**: Robust startup lifecycle with zone error guards, asynchronous dependency initialization, and customizable `BootstrapTask` pipelines.
- **Typed Multi-Flavor System**: Zero code duplication across environments (`dev`, `qas`, `pre`, `prod`) using unified, compile-time typed `FlavorValues` and `FlavorConfig`.
- **Automated Tooling**: Single-command project initialization (`new_project.sh`), rapid feature scaffolding (`add_module.sh`), and local CI checks (`ci_local.sh`).
- **Template Sync Engine**: Projects track the template version and file hashes via `.template/manifest.json`. Pull core updates and bugfixes anytime via `sync_template.sh` without git submodule headaches.
- **Turnkey CI/CD**: Pre-configured GitHub Actions workflows for PR analysis, weekly flavor builds, release packaging (Android AAB + iOS IPA), and template drift monitoring.

---

## 📁 Project Architecture

```
mobile_core_template/
├── .github/workflows/          # Pre-configured CI/CD workflows
│   ├── ci.yml                  # PR & main branch analysis + debug dev build
│   ├── build_all_flavors.yml   # Multi-flavor matrix build (dev, qas, pre, prod)
│   ├── release.yml             # Store release packaging (Android AAB + iOS IPA)
│   ├── template_drift.yml      # Automated template update checker
│   └── template-ci.yml         # Template repo validation & shellcheck
├── .template/                  # Template manifest and version tracking
│   ├── manifest.json           # SHA-256 seal manifest of core files
│   └── .gitignore
├── .template-sealed            # List of paths treated as immutable core
├── .template-version           # Template semantic version (e.g., 1.0.0)
├── lib/
│   ├── configs/                # App-level implementations (project-owned)
│   │   ├── app_configs/        # AppConfig constants, logger & toast bindings
│   │   │   └── flavor/         # FlavorConfig & FlavorValues
│   │   ├── constants/          # Static app constants
│   │   ├── networks/           # NetworkApiService, HttpConfigImpl, headers
│   │   ├── theme/              # AppColor, AppTheme, ThemeViewModel
│   │   └── translation/        # AppTranslationKey & language definitions
│   ├── core/                   # 🔒 SEALED CORE (template-managed)
│   │   ├── app/                # bootstrap() engine & BootstrapTask
│   │   ├── base/               # BaseViewModel, BaseView, loader/toast/logger bindings
│   │   ├── di/                 # locator.dart, register_core.dart, register_app.dart
│   │   ├── errors/             # Failure, AppException, ErrorHandler
│   │   ├── mixins/             # AutoDisposeMixin, LoadingMixin, NetworkAwareMixin
│   │   ├── network/            # BaseApiService, CoreApiBase, HttpConfig contracts
│   │   ├── routing/            # NavigatorKeys, NavigationLogger
│   │   ├── services/           # DeepLinkService interface
│   │   ├── theme/              # CoreColors, CoreTheme, AppColorsExtension
│   │   ├── translation/        # CoreTranslationKey, TranslationX extension
│   │   └── widgets/            # Gap, AppButton, CoreText, Error/Empty/Loading widgets
│   ├── data/                   # Global state singletons (GlobalOverlay, UserSingleton)
│   ├── modules/                # Feature modules (auth, profile, checkout, etc.)
│   ├── routes/                 # AppRouter, AppRoutes, route generators
│   ├── app_providers.dart      # Minimal app-global providers (Theme, Auth)
│   ├── main.dart               # Production entry point
│   ├── main_dev.dart           # Dev flavor entry point
│   ├── main_qas.dart           # QAS flavor entry point
│   ├── main_pre.dart           # Pre-prod flavor entry point
│   ├── main_app.dart           # Root MaterialApp widget with theme/routing
│   └── register.dart           # Central barrel export for app consumption
├── scripts/                    # Automation and developer workflow scripts
│   ├── new_project.sh          # Interactive project initializer
│   ├── add_module.sh           # Feature module generator
│   ├── ci_local.sh             # Local CI runner (format, analyze, test)
│   ├── check_template_drift.sh # Drift detector against remote template
│   ├── sync_template.sh        # Pulls updates from template repo
│   ├── build_manifest.sh       # Rebuilds .template/manifest.json
│   └── install_hooks.sh        # Installs local git pre-commit hook
├── test/                       # Unit, widget, and integration tests
└── NEW_PROJECT.md              # Step-by-step checklist for new apps
```

---

## 🚀 Quick Start: Starting a New Project

To initialize a new project from this template:

### 1. Clone & Re-initialize Git

```bash
git clone <template-repo-url> my_new_app
cd my_new_app
rm -rf .git && git init
```

### 2. Run the Initializer Script

```bash
./scripts/new_project.sh
```

The script will prompt for your project identity:
- **Display name** (e.g., `Acme Shop`)
- **Project name** (snake_case, e.g., `acme_shop`)
- **Org identifier** (e.g., `com.acme`)
- **Base API URL** (e.g., `https://api.acme.com`)
- **Brand Colors** (hex values for Primary and Secondary colors)

The script automatically:
1. Re-generates iOS and Android platform folders with your org and bundle IDs.
2. Updates `pubspec.yaml` and all `package:app_base/` imports across `lib/` and `test/`.
3. Configures `AppConfig` and brand colors.
4. Generates clean stubs for routing, DI, and routes.
5. Builds your initial `.template/manifest.json`.
6. Executes `flutter pub get` and `flutter analyze`.

### 3. Follow `NEW_PROJECT.md`

Refer to [`NEW_PROJECT.md`](./NEW_PROJECT.md) for remaining manual steps:
- Configure flavor endpoints in `lib/configs/app_configs/flavor/flavor_config.dart`.
- Drop in Firebase configuration files (if used).
- Set up Android and iOS release signing credentials.

---

## 🛠️ Daily Development Workflow

### Scaffolding a Feature Module

Generate a complete, architecturally compliant module in seconds:

```bash
./scripts/add_module.sh user_profile
```

Creates:
```
lib/modules/user_profile/
├── models/user_profile_model.dart
├── repository/user_profile_repository.dart
├── view_models/user_profile_view_model.dart
├── views/user_profile_view.dart
└── user_profile.dart (barrel export)
```

### Running Flavors

Every flavor uses its own dedicated entry point with typed configuration:

```bash
flutter run -t lib/main_dev.dart      # Development
flutter run -t lib/main_qas.dart      # QA / Staging
flutter run -t lib/main_pre.dart      # Pre-production
flutter run -t lib/main.dart          # Production
```

### Pre-Push Verification (Local CI)

Run the exact checks executed by GitHub Actions:

```bash
./scripts/ci_local.sh --fast          # Quick: format, analyze --fatal-infos, tests
./scripts/ci_local.sh                 # Full: includes debug APK build
./scripts/ci_local.sh --build         # Full + iOS debug build (macOS)
```

### Optional: Pre-Commit Hook

Install a git pre-commit hook that runs `./scripts/ci_local.sh --fast` automatically:

```bash
./scripts/install_hooks.sh
# Can be bypassed when needed with: git commit --no-verify
```

---

## 🔄 Template Synchronization (Staying Up-to-Date)

When improvements or bug fixes are made to the core template:

### 1. Check for Template Updates

```bash
./scripts/check_template_drift.sh
```

### 2. Pull Updates Safely

```bash
./scripts/sync_template.sh            # Pull latest template release
./scripts/sync_template.sh v1.1.0     # Pull a specific version
./scripts/sync_template.sh --check    # Dry-run comparison
./scripts/sync_template.sh --force    # Overwrite local edits in sealed files
```

- **Conflict Prevention**: If a project modified a sealed file locally, `sync_template.sh` warns of a conflict and skips overwriting that file unless `--force` is passed.
- **Import Normalization**: The script automatically translates package imports from the template to your project's custom package name.

---

## ⚙️ CI/CD Workflows

The template includes turnkey GitHub Actions under `.github/workflows/`:

| Workflow | Triggers | Description |
|---|---|---|
| **`ci.yml`** | PRs & push to `main`/`develop` | Formats, runs `analyze --fatal-infos`, runs tests, uploads coverage, and builds dev APK. |
| **`build_all_flavors.yml`** | Weekly or manual | Parallel matrix build verifying all 4 flavors compile. |
| **`release.yml`** | Git tag `v*.*.*` | Builds signed Android App Bundle (AAB) & unsigned iOS IPA, publishing a GitHub Release. |
| **`template_drift.yml`** | Weekly or manual | Checks if downstream projects have fallen behind the core template, opening an issue if updates exist. |
| **`template-ci.yml`** | PRs in template repo | Validates core Dart code and runs `shellcheck` across all shell scripts. |

See **Phase 6.5** in [`NEW_PROJECT.md`](./NEW_PROJECT.md) for required repository secrets (`ANDROID_KEYSTORE_BASE64`, etc.) and variables (`TEMPLATE_REPO`).

---

## 🧪 Testing Strategy

Run the test suite with coverage:

```bash
flutter test --coverage
```

The template adheres to:
- **Unit Tests**: Mock external dependencies via interfaces (`BaseApiService`, repository contracts).
- **View-Model Tests**: Verify view-model lifecycle, states, and error handling without widget overhead.
- **Widget Tests**: Validate UI presentation using `testWidgets` and `CoreView`.

---

## 📜 Architectural Rules to Maintain

1. **Keep Core Pure**: Never import `configs/`, `modules/`, `AppColor`, or feature code inside `lib/core/`.
2. **Factory View Models**: View models are screen-scoped factories. Only truly global state belongs in `lib/app_providers.dart`.
3. **Register Boundaries**: Register framework singletons in `register_core.dart` and app-specific repositories/services in `register_app.dart`.
4. **Never Rename Sealed Files**: Ensure seamless upgrades across downstream projects by keeping sealed paths stable.
