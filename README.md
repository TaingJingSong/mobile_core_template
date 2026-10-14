# Flutter Mobile Core Template

A production foundation for mobile applications built with Flutter. This repository provides a scalable architecture separating framework-level contracts, project configuration, and domain-driven feature modules. It includes automated project initialization, multi-flavor build configurations, screen-scoped state management, a sealed-core update sync engine, and pre-configured CI/CD pipelines.

---

## Table of Contents

- [Architectural Overview](#architectural-overview)
  - [The Sealed Core Principle](#the-sealed-core-principle)
  - [Layer Responsibilities](#layer-responsibilities)
  - [State Management and Lifecycle](#state-management-and-lifecycle)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Step 1: Clone and Reinitialize Repository](#step-1-clone-and-reinitialize-repository)
  - [Step 2: Run Automated Project Initialization](#step-2-run-automated-project-initialization)
  - [Step 3: Configure Environment Endpoints](#step-3-configure-environment-endpoints)
  - [Step 4: Verify the Setup](#step-4-verify-the-setup)
- [Development Workflows](#development-workflows)
  - [Running Flavors](#running-flavors)
  - [Scaffolding a Feature Module](#scaffolding-a-feature-module)
  - [Registering Dependencies](#registering-dependencies)
  - [Configuring Navigation](#configuring-navigation)
- [Template Maintenance and Synchronization](#template-maintenance-and-synchronization)
  - [How the Manifest Sync Works](#how-the-manifest-sync-works)
  - [Checking for Template Drift](#checking-for-template-drift)
  - [Pulling Core Updates](#pulling-core-updates)
  - [Publishing Core Updates (Maintainers)](#publishing-core-updates-maintainers)
- [Quality Assurance and CI/CD](#quality-assurance-and-cicd)
  - [Local Pre-Push Verification](#local-pre-push-verification)
  - [Git Pre-Commit Hook](#git-pre-commit-hook)
  - [GitHub Actions Workflows](#github-actions-workflows)

---

## Architectural Overview

### The Sealed Core Principle

The codebase is split into two distinct tiers:

1. **Sealed Core (`lib/core/`)**: Generic, reusable framework infrastructure. It contains abstract base classes, network interface contracts, domain error structures, routing delegates, and semantic theme abstractions. **Zero imports of app-specific constants, colors, or feature modules are allowed inside `lib/core/`.**
2. **Application Layer (`lib/configs/`, `lib/routes/`, `lib/modules/`)**: Project-specific implementations. This layer defines brand colors, localization keys, concrete API clients, feature screens, and view models.

This boundary ensures that bug fixes and structural enhancements made to `lib/core/` can be safely pulled into any downstream application without causing merge conflicts with project-level code.

### Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                       Feature Modules                       │
│    (lib/modules/*: models, repositories, view models, views)│
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐┌─────────────────────────────┐
│      Application Config      ││         Sealed Core         │
│  - lib/configs/theme         ││  - lib/core/base            │
│  - lib/configs/translation   ││  - lib/core/network         │
│  - lib/configs/networks      ││  - lib/core/errors          │
│  - lib/configs/app_configs   ││  - lib/core/theme           │
│  - lib/routes/app_router     ││  - lib/core/widgets         │
└──────────────────────────────┘└─────────────────────────────┘
```

- **`lib/core/base/`**: Generic `BaseViewModel` and `CoreView` widgets. Provides lifecycle hooks (`onInit`, `dispose`), transient dependency binding, and error observation.
- **`lib/core/network/`**: Protocol interfaces (`BaseApiService`, `HttpConfig`, `HeaderProvider`, `NetworkInfo`) and domain failure representations (`Failure`, `AppException`).
- **`lib/core/theme/`**: Theme resolution abstractions (`CoreColors`, `CoreTheme`, `AppColorsExtension`) separating semantic color tokens from brand palettes.
- **`lib/core/app/bootstrap.dart`**: Unified startup engine providing zoned error capture, asynchronous pre-flight checks, and DI bootstrapping.
- **`lib/configs/`**: Project implementation of themes, translations, network clients, and flavor configurations.

### State Management and Lifecycle

This template decouples state management from UI layout:

- **Screen-Scoped Lifecycles**: View models are instantiated as factory dependencies per screen using `CoreView<T>`. When the user leaves a route, the view model automatically cleans up subscriptions and disposes resources.
- **Global State Isolation**: App-wide states (such as active authentication session or dark/light theme mode) are isolated in `lib/app_providers.dart`. Individual feature screens never linger in memory longer than their route lifetime.

---

## Directory Structure

```
.
├── .github/workflows/              # Continuous integration workflows
│   ├── build_all_flavors.yml       # Weekly matrix build across all 4 flavors
│   ├── ci.yml                      # PR validation: format, analyze, test, dev APK
│   ├── release.yml                 # Production artifact tagging (AAB + IPA)
│   ├── template_drift.yml          # Automated template version tracker
│   └── template-ci.yml             # Template repository CI and shellcheck
├── .template/                      # Template seal manifest and version tracker
│   ├── manifest.json               # SHA-256 integrity register of sealed files
│   └── .gitignore
├── .template-sealed                # Path definitions of sealed core files
├── .template-version               # Pinned semantic version of core template
├── lib/
│   ├── configs/                    # Application implementations (project-owned)
│   │   ├── app_configs/            # AppConfig, FlavorConfig, binding implementations
│   │   ├── constants/              # App constants
│   │   ├── networks/               # Concrete Dio/Http clients, interceptors
│   │   ├── theme/                  # Brand colors, theme data, ThemeViewModel
│   │   └── translation/            # AppTranslationKey and language maps
│   ├── core/                       # Sealed Core (shared framework infrastructure)
│   │   ├── app/                    # bootstrap() engine and BootstrapTask
│   │   ├── base/                   # BaseViewModel, CoreView, service bindings
│   │   ├── di/                     # Service locator and core registration
│   │   ├── errors/                 # Domain failures, exceptions, and error handler
│   │   ├── mixins/                 # AutoDispose, LoadingController, NetworkAware
│   │   ├── network/                # Abstract network interfaces and contracts
│   │   ├── routing/                # Navigation logger and root navigator keys
│   │   ├── services/               # Deep linking contracts
│   │   ├── theme/                  # Semantic colors and theme extensions
│   │   ├── translation/            # Core translation key contracts
│   │   └── widgets/                # Core widgets: Gap, AppButton, CoreText, states
│   ├── data/                       # App singletons (GlobalOverlay, UserSingleton)
│   ├── modules/                    # Feature modules (auth, profile, dashboard, etc.)
│   ├── routes/                     # AppRouter, AppRoutes, and route generator
│   ├── app_providers.dart          # Root providers (minimal global scope)
│   ├── main.dart                   # Production entry point
│   ├── main_dev.dart               # Development entry point
│   ├── main_qas.dart               # Staging / QA entry point
│   ├── main_pre.dart               # Pre-production entry point
│   ├── main_app.dart               # Root MaterialApp widget
│   └── register.dart               # Central barrel exports
├── scripts/                        # Automation shell scripts
│   ├── add_module.sh               # Scaffolds new feature modules
│   ├── build_manifest.sh           # Builds .template/manifest.json
│   ├── check_template_drift.sh     # Inspects version drift from upstream template
│   ├── ci_local.sh                 # Runs CI checks locally (format, analyze, test)
│   ├── install_hooks.sh            # Installs git pre-commit hook
│   ├── new_project.sh              # Project bootstrap script
│   └── sync_template.sh            # Pulls core updates from template repo
├── test/                           # Unit and widget test suite
└── NEW_PROJECT.md                  # Comprehensive onboarding checklist
```

---

## Getting Started

### Prerequisites

Ensure the following tools are available in your path:

- Flutter SDK (stable channel, version 3.16 or higher)
- Dart SDK (version 3.2 or higher)
- Perl 5 (standard on macOS and Linux distributions)
- Git (version 2.20 or higher)

### Step 1: Clone and Reinitialize Repository

Clone the template into your new project directory and reset the git history:

```bash
git clone <template-repo-url> my_app
cd my_app
rm -rf .git
git init
```

### Step 2: Run Automated Project Initialization

Run the automated setup script:

```bash
./scripts/new_project.sh
```

You will be prompted for:

| Field | Description | Example |
|---|---|---|
| **Display Name** | User-facing application label | `Enterprise HR` |
| **Project Name** | Lowercase snake_case identifier | `enterprise_hr` |
| **Org Identifier** | Reverse domain package prefix | `com.example` |
| **Base API URL** | Primary production backend host | `https://api.example.com` |
| **Primary Color** | Brand primary color (6-character hex) | `#156EA2` |
| **Secondary Color** | Brand secondary color (6-character hex) | `#D99C26` |

The initialization script performs the following operations:
1. Executes `flutter create` with your org and project name while preserving core architecture.
2. Updates `pubspec.yaml` and replaces all `package:app_base/` import statements with your project name.
3. Configures identity constants in `lib/configs/app_configs/app_config.dart`.
4. Updates brand hex values in `lib/configs/theme/app_colors.dart`.
5. Emits clean stubs for routing and dependency injection.
6. Computes the initial cryptographic hash manifest in `.template/manifest.json`.
7. Resolves dependencies via `flutter pub get` and verifies formatting and analysis.

### Step 3: Configure Environment Endpoints

Open `lib/configs/app_configs/flavor/flavor_config.dart` and specify environment URLs:

```dart
case Environment.dev:
  return const FlavorValues(
    name: 'dev',
    url: 'https://dev-api.example.com',
    firebaseRoot: 'Dev',
  );
case Environment.qas:
  return const FlavorValues(
    name: 'qas',
    url: 'https://qa-api.example.com',
    firebaseRoot: 'Qas',
  );
case Environment.pre:
  return const FlavorValues(
    name: 'pre',
    url: 'https://pre-api.example.com',
    firebaseRoot: 'Pre',
  );
case Environment.prod:
  return const FlavorValues(
    name: 'prod',
    url: 'https://api.example.com',
    firebaseRoot: 'Prod',
  );
```

### Step 4: Verify the Setup

Execute the local verification pipeline:

```bash
./scripts/ci_local.sh --fast
```

When this command passes with zero warnings or errors, your new project is fully initialized and ready for development.

---

## Development Workflows

### Running Flavors

Every environment is represented by a dedicated entry point file that configures compile-time values before invoking the bootstrap sequence:

```bash
# Development
flutter run -t lib/main_dev.dart

# Staging / QA
flutter run -t lib/main_qas.dart

# Pre-production
flutter run -t lib/main_pre.dart

# Production
flutter run -t lib/main.dart
```

### Scaffolding a Feature Module

Use `scripts/add_module.sh` to generate a structured feature module conforming to the project's layered architecture:

```bash
./scripts/add_module.sh customer_profile
```

This creates:

```
lib/modules/customer_profile/
├── models/customer_profile_model.dart          # Domain entity
├── repository/customer_profile_repository.dart  # Data source interface & impl
├── view_models/customer_profile_view_model.dart # Screen-scoped logic
├── views/customer_profile_view.dart            # CoreView declaration
└── customer_profile.dart                       # Barrel export
```

#### Writing the ViewModel

Extend `CoreViewModel` to take advantage of lifecycle handling, busy state management, and toast notifications:

```dart
import 'package:enterprise_hr/register.dart';
import '../repository/customer_profile_repository.dart';

class CustomerProfileViewModel extends CoreViewModel {
  CustomerProfileViewModel(this._repository);

  final CustomerProfileRepository _repository;
  CustomerProfileModel? profile;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setBusy(true);
    try {
      profile = await _repository.fetchProfile();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
```

#### Writing the View

Use `CoreView<T>` to bind the widget to the ViewModel lifecycle:

```dart
import 'package:enterprise_hr/register.dart';
import '../view_models/customer_profile_view_model.dart';
import '../repository/customer_profile_repository.dart';

class CustomerProfileView extends StatelessWidget {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreView<CustomerProfileViewModel>(
      model: CustomerProfileViewModel(locator<CustomerProfileRepository>()),
      builder: (context, vm, child) {
        if (vm.isBusy) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Customer Profile')),
          body: Center(child: Text(vm.profile?.name ?? 'No data')),
        );
      },
    );
  }
}
```

### Registering Dependencies

Register application-level singletons, data sources, and repositories inside `lib/core/di/register_app.dart`:

```dart
// Repositories
locator.registerLazySingleton<CustomerProfileRepository>(
  () => CustomerProfileRepositoryImpl(locator<BaseApiService>()),
);
```

> **Note**: Core services (`LoggerBinding`, `LoaderBinding`, `BaseApiService`, `HttpConfig`) are registered automatically inside `lib/core/di/register_core.dart`. Do not duplicate them in `register_app.dart`.

### Configuring Navigation

Define static route path identifiers in `lib/routes/app_routes.dart`:

```dart
abstract class Routes {
  const Routes();

  static const initial = '/';
  static const customerProfile = '/customer-profile';
}
```

Handle the route in `lib/routes/app_router.dart`:

```dart
static Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.customerProfile:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CustomerProfileView(),
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(
          body: Center(child: Text('Route not found: ${settings.name}')),
        ),
      );
  }
}
```

---

## Template Maintenance and Synchronization

### How the Manifest Sync Works

Downstream projects maintain a `.template/manifest.json` file generated at project initialization. It contains SHA-256 hashes of every file declared in `.template-sealed`.

When you execute `scripts/sync_template.sh`:

1. It reads the local manifest and recorded hashes.
2. It fetches the latest template release into a temporary workspace.
3. For each file in `.template-sealed`:
   - **Local hash matches manifest hash**: The local project has never edited the file. It is safe to overwrite with the updated template version.
   - **Local hash differs from manifest hash**: The local project modified the sealed file. The sync halts on this file, leaves the local modification untouched, and flags a conflict.
   - **New file added to template**: The file is copied directly into the project.
4. If project package names differ, import paths (`package:<template>/`) are automatically translated into `package:<local_project>/`.
5. `.template/manifest.json` is updated with new version hashes.

### Checking for Template Drift

Inspect if your project has fallen behind the core template without modifying any local files:

```bash
./scripts/check_template_drift.sh
```

Append `--fetch` to view recent commit logs from the upstream template:

```bash
./scripts/check_template_drift.sh --fetch
```

### Pulling Core Updates

Pull updates from the upstream repository:

```bash
# Pull from latest tagged release
./scripts/sync_template.sh

# Pull from a specific tag
./scripts/sync_template.sh v1.1.0

# Dry-run comparison (outputs diff without writing files)
./scripts/sync_template.sh --check

# Force update (overwrites local modifications in sealed files)
./scripts/sync_template.sh --force
```

### Publishing Core Updates (Maintainers)

When committing improvements to `lib/core/` in the template repository:

1. Apply changes to files within `lib/core/` or `scripts/`.
2. Run test verification:
   ```bash
   ./scripts/ci_local.sh --fast
   ```
3. Bump the version in `.template-version` (e.g. `1.0.0` → `1.0.1`).
4. Rebuild the manifest:
   ```bash
   ./scripts/build_manifest.sh
   ```
5. Commit, tag, and push:
   ```bash
   git add .
   git commit -m "fix(core): ensure BaseViewModel cancels active streams on dispose"
   git tag -a v1.0.1 -m "Release v1.0.1"
   git push origin main --tags
   ```

Downstream projects can now pull the fix by running `./scripts/sync_template.sh`.

---

## Quality Assurance and CI/CD

### Local Pre-Push Verification

Before pushing code or opening pull requests, run `ci_local.sh`:

```bash
# Fast mode: checks format, analyzes with fatal infos, executes tests
./scripts/ci_local.sh --fast

# Standard mode: fast mode + builds debug Android APK
./scripts/ci_local.sh

# Complete mode: standard mode + builds debug iOS archive (macOS only)
./scripts/ci_local.sh --build
```

### Git Pre-Commit Hook

Install the automated pre-commit hook to guarantee no unformatted or failing code is committed:

```bash
./scripts/install_hooks.sh
```

To bypass the hook during temporary commits, use the standard git flag:

```bash
git commit --no-verify -m "WIP"
```

### GitHub Actions Workflows

Pre-configured workflows are located in `.github/workflows/`:

| Workflow File | Trigger | Actions Performed |
|---|---|---|
| **`ci.yml`** | Pull requests & pushes to `main`/`develop` | Validates formatting (`dart format`), executes static analysis (`flutter analyze --fatal-infos`), runs unit/widget tests with coverage artifacts, and builds debug development APK. |
| **`build_all_flavors.yml`** | Weekly schedule & manual dispatch | Matrix compilation testing all four flavor targets (`dev`, `qas`, `pre`, `prod`) to catch compile-time breakage before releases. |
| **`release.yml`** | Tag pushes (`v*.*.*`) | Signs and builds production Android App Bundle (`.aab`) and unsigned iOS IPA (`.zip`), then drafts an official GitHub Release with artifacts. |
| **`template_drift.yml`** | Weekly schedule & manual dispatch | Checks upstream template repository and creates a GitHub Issue if updates are available. |
| **`template-ci.yml`** | Template repository PRs/pushes | Verifies framework test suites and runs `shellcheck` across all utility shell scripts. |

For instructions on configuring release keystore secrets and GitHub repository variables, refer to **Phase 6.5** of [`NEW_PROJECT.md`](./NEW_PROJECT.md).
