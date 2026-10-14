#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
# new_project.sh
# ════════════════════════════════════════════════════════════════
# Renames and initializes a new Flutter project from the template.
# Automates Phase 1 & Phase 2 of NEW_PROJECT.md.
#
# Usage:
#   1. git clone <template-repo-url> my_new_app
#   2. cd my_new_app
#   3. rm -rf .git && git init
#   4. ./scripts/new_project.sh
#
# Requirements: flutter, perl. macOS or Linux.

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# Terminal output
# ────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

info() { printf '%s\n' "${BLUE}ℹ${RESET} $*"; }
ok()   { printf '%s\n' "${GREEN}✓${RESET} $*"; }
warn() { printf '%s\n' "${YELLOW}⚠${RESET} $*"; }
err()  { printf '%s\n' "${RED}✗${RESET} $*" >&2; }
die()  { err "$*"; exit 1; }
step() { printf '\n%s\n' "${BOLD}${BLUE}▸ $*${RESET}"; }

# ────────────────────────────────────────────────────────────────
# Usage
# ────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
new_project.sh — initialize a new Flutter project from the template.

Run from the project root after cloning the template:

    git clone <template-repo-url> my_new_app
    cd my_new_app
    rm -rf .git && git init
    ./scripts/new_project.sh

Interactive prompts will ask for:
  - Display name      (e.g. "My Company HR")
  - Project name      (snake_case, e.g. "my_company_hr")
  - Org identifier    (reverse domain, e.g. "com.acme")
  - Base API URL      (e.g. "https://api.acme.com")
  - Primary color     (hex, e.g. "#156EA2")
  - Secondary color   (hex, e.g. "#D99C26")
EOF
  exit 0
fi

# ────────────────────────────────────────────────────────────────
# Sanity checks
# ────────────────────────────────────────────────────────────────
step "Pre-flight checks"

[[ -f "pubspec.yaml" ]]     || die "Run from the project root (no pubspec.yaml here)."
[[ -f "lib/register.dart" ]] || die "Not the template — lib/register.dart is missing."
[[ -d "lib/core" ]]         || die "Not the template — lib/core/ is missing."

command -v flutter >/dev/null 2>&1 || die "flutter CLI not found in PATH."
command -v perl    >/dev/null 2>&1 || die "perl not found in PATH."

# Detect if this is still the template or already renamed.
CURRENT_NAME="$(grep -E '^name:[[:space:]]*' pubspec.yaml | head -n1 | awk '{print $2}')"
if [[ "$CURRENT_NAME" != "app_base" ]]; then
  warn "pubspec.yaml name is '$CURRENT_NAME', not 'app_base'."
  warn "This project may already have been initialized."
  read -rp "Continue anyway? [y/N] " CONT
  [[ "$CONT" =~ ^[Yy]$ ]] || die "Aborted."
fi

ok "Looks like a fresh template."

# ────────────────────────────────────────────────────────────────
# Prompts
# ────────────────────────────────────────────────────────────────
step "Project values"

read -rp "Display name (e.g. 'My Company HR'): " DISPLAY_NAME
[[ -n "$DISPLAY_NAME" ]] || die "Display name is required."
[[ "$DISPLAY_NAME" != *"'"* ]] || die "Display name cannot contain single quotes."

read -rp "Project name, snake_case (e.g. 'my_company_hr'): " PROJECT_NAME
[[ -n "$PROJECT_NAME" ]] || die "Project name is required."
[[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9_]*$ ]] \
  || die "Project name must be snake_case starting with a letter (lowercase letters, digits, underscores)."

read -rp "Org identifier (e.g. 'com.acme'): " ORG
[[ -n "$ORG" ]] || die "Org identifier is required."
[[ "$ORG" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]] \
  || die "Org must look like 'com.acme' (lowercase, dot-separated)."

read -rp "Base API URL (e.g. 'https://api.acme.com'): " BASE_URL
[[ -n "$BASE_URL" ]] || die "Base URL is required."
[[ "$BASE_URL" =~ ^https?:// ]] || die "Base URL must start with http:// or https://."
[[ "$BASE_URL" != *"'"* ]] || die "Base URL cannot contain single quotes."

read -rp "Primary color, hex (e.g. '#156EA2'): " PRIMARY_HEX
[[ "$PRIMARY_HEX" =~ ^#?[0-9A-Fa-f]{6}$ ]] \
  || die "Primary color must be a 6-digit hex like #156EA2."
PRIMARY_HEX="${PRIMARY_HEX#\#}"
PRIMARY_HEX="$(echo "$PRIMARY_HEX" | tr '[:lower:]' '[:upper:]')"

read -rp "Secondary color, hex (e.g. '#D99C26'): " SECONDARY_HEX
[[ "$SECONDARY_HEX" =~ ^#?[0-9A-Fa-f]{6}$ ]] \
  || die "Secondary color must be a 6-digit hex like #D99C26."
SECONDARY_HEX="${SECONDARY_HEX#\#}"
SECONDARY_HEX="$(echo "$SECONDARY_HEX" | tr '[:lower:]' '[:upper:]')"

PACKAGE_NAME="${ORG}.${PROJECT_NAME}"

# ────────────────────────────────────────────────────────────────
# Confirm
# ────────────────────────────────────────────────────────────────
step "Confirm"

printf '  %-18s %s\n' "Display name:"    "$DISPLAY_NAME"
printf '  %-18s %s\n' "Project name:"    "$PROJECT_NAME"
printf '  %-18s %s\n' "Org:"             "$ORG"
printf '  %-18s %s\n' "Package name:"    "$PACKAGE_NAME"
printf '  %-18s %s\n' "Base URL:"        "$BASE_URL"
printf '  %-18s %s\n' "Primary color:"   "#${PRIMARY_HEX}"
printf '  %-18s %s\n' "Secondary color:" "#${SECONDARY_HEX}"
echo

read -rp "Proceed? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || die "Aborted."

# ────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────

# Replace a literal string in a file. Uses env vars to avoid shell
# escaping issues.
replace_literal() {
  local file="$1" from="$2" to="$3"
  [[ -f "$file" ]] || { warn "Skipping (not found): $file"; return; }
  FROM="$from" TO="$to" perl -i -pe 's/\Q$ENV{FROM}\E/$ENV{TO}/g' "$file"
}

# Replace the first line matching a regex with a fixed replacement.
# Replacement is taken from env var REPLACEMENT to avoid escaping.
replace_line() {
  local file="$1" regex="$2" replacement="$3"
  [[ -f "$file" ]] || { warn "Skipping (not found): $file"; return; }
  REPLACEMENT="$replacement" perl -i -pe "s|$regex|\$ENV{REPLACEMENT}|" "$file"
}

# ────────────────────────────────────────────────────────────────
# Phase 1 — Rename the Flutter project
# ────────────────────────────────────────────────────────────────
step "Phase 1 — Renaming Flutter project"

# Safeguard main.dart against being clobbered by flutter create
if [[ -f "lib/main.dart" ]]; then
  cp "lib/main.dart" "lib/main.dart.tmp_keep"
fi

info "Running flutter create --org $ORG --project-name $PROJECT_NAME ..."
flutter create \
  --org "$ORG" \
  --project-name "$PROJECT_NAME" \
  --platforms ios,android \
  . >/dev/null

if [[ -f "lib/main.dart.tmp_keep" ]]; then
  mv "lib/main.dart.tmp_keep" "lib/main.dart"
fi
ok "Platform folders regenerated."

info "Updating pubspec.yaml ..."
replace_line "pubspec.yaml" "^name:.*" "name: $PROJECT_NAME"
ok "pubspec.yaml name → $PROJECT_NAME"

info "Updating package imports (package:$CURRENT_NAME → package:$PROJECT_NAME) ..."
find lib test -type f -name "*.dart" -exec perl -i -pe "s|package:$CURRENT_NAME/|package:$PROJECT_NAME/|g" {} +
ok "Imports updated to package:$PROJECT_NAME."

# ────────────────────────────────────────────────────────────────
# Phase 2 — App identity & config
# ────────────────────────────────────────────────────────────────
step "Phase 2 — App identity & config"

# 2.1 AppConfig
APP_CONFIG="lib/configs/app_configs/app_config.dart"
if [[ -f "$APP_CONFIG" ]]; then
  info "Editing $APP_CONFIG ..."
  replace_line "$APP_CONFIG" "static const String appName = '[^']*';"     "static const String appName = '$DISPLAY_NAME';"
  replace_line "$APP_CONFIG" "static const String packageName = '[^']*';" "static const String packageName = '$PACKAGE_NAME';"
  replace_line "$APP_CONFIG" "static const String baseUrl = '[^']*';"     "static const String baseUrl = '$BASE_URL';"
  ok "AppConfig updated."
else
  warn "$APP_CONFIG not found — edit it manually."
fi

# 2.2 Brand colors
APP_COLOR="lib/configs/theme/app_colors.dart"
[[ -f "$APP_COLOR" ]] || APP_COLOR="lib/configs/constants/colors/app_color.dart"
if [[ -f "$APP_COLOR" ]]; then
  info "Editing $APP_COLOR ..."
  replace_line "$APP_COLOR" "static const Color primaryColor = Color\\(0x[0-9A-Fa-f]+\\);"   "static const Color primaryColor = Color(0xFF${PRIMARY_HEX});"
  replace_line "$APP_COLOR" "static const Color secondaryColor = Color\\(0x[0-9A-Fa-f]+\\);" "static const Color secondaryColor = Color(0xFF${SECONDARY_HEX});"
  ok "Brand colors updated."
else
  warn "$APP_COLOR not found — edit it manually."
fi

# 2.3 Clear old feature modules
step "Clearing lib/modules/"
if [[ -d "lib/modules" ]]; then
  COUNT=$(find lib/modules -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  find lib/modules -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
  touch lib/modules/.gitkeep
  ok "Cleared lib/modules/ (removed $COUNT module(s))."
else
  mkdir -p lib/modules
  touch lib/modules/.gitkeep
  ok "Created empty lib/modules/."
fi

# 2.4 Stub app_router.dart
step "Stubbing lib/routes/app_router.dart"
ROUTER="lib/routes/app_router.dart"
if [[ -f "$ROUTER" ]]; then
  cp "$ROUTER" "${ROUTER}.bak"
  cat > "$ROUTER" <<DART
// ════════════════════════════════════════════════════════════════
// APP ROUTER
// ════════════════════════════════════════════════════════════════
// Add routes here as you build features. See NEW_PROJECT.md Phase 2
// and Phase 6 for the standard pattern.
//
// The previous version of this file was saved as app_router.dart.bak.
import 'package:flutter/material.dart';
import 'package:${PROJECT_NAME}/register.dart';

class AppRouter {
  AppRouter._();

  static GlobalKey<NavigatorState> get navigatorKey =>
      AppNavigatorKeys.instance.rootNavigatorKey;

  static NavigationLogger get observer =>
      NavigationLogger(locator<LoggerBinding>());

  /// Map route names to widgets.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Home View')),
          ),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for \${settings.name}')),
          ),
        );
    }
  }
}
DART
  ok "app_router.dart replaced (backup at app_router.dart.bak)."
else
  warn "$ROUTER not found — skipping."
fi

# 2.5 Stub app_routes.dart
step "Stubbing lib/routes/app_routes.dart"
ROUTES="lib/routes/app_routes.dart"
if [[ -f "$ROUTES" ]]; then
  cp "$ROUTES" "${ROUTES}.bak"
  cat > "$ROUTES" <<'DART'
// ════════════════════════════════════════════════════════════════
// APP ROUTES
// ════════════════════════════════════════════════════════════════
// Add route constants here as you build features.
// The previous version of this file was saved as app_routes.dart.bak.
abstract class Routes {
  const Routes();

  static const String initial = '/';
  static const String home = '/home';
}
DART
  ok "app_routes.dart replaced (backup at app_routes.dart.bak)."
else
  warn "$ROUTES not found — skipping."
fi

# 2.6 Stub register_app.dart
step "Stubbing lib/core/di/register_app.dart"
REGISTER="lib/core/di/register_app.dart"
if [[ -f "$REGISTER" ]]; then
  cp "$REGISTER" "${REGISTER}.bak"
  cat > "$REGISTER" <<DART
// ════════════════════════════════════════════════════════════════
// APP REGISTRATIONS — EDIT PER PROJECT
// ════════════════════════════════════════════════════════════════
// Register repositories, services, and APIs here as you add them.
// View models are NOT registered here — create them per-screen
// inside CoreView (see NEW_PROJECT.md Phase 6).
//
// The previous version of this file was saved as register_app.dart.bak.
import 'package:${PROJECT_NAME}/register.dart';

Future<void> registerApp() async {
  // ── Bindings ────────────────────────────────────────────
  locator.registerLazySingleton<LoaderBinding>(
    () => GlobalOverlayLoaderBinding(),
  );
  locator.registerLazySingleton<ToastBinding>(() => AppToastBinding());
  locator.registerLazySingleton<LoggerBinding>(() => LoggerBindingImpl());

  // ── Network ─────────────────────────────────────────────
  locator.registerLazySingleton<HttpConfig>(() => const HttpConfigImpl());
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  locator.registerLazySingleton<HeaderProvider>(() => HeaderProviderImpl());
  locator.registerLazySingleton<InterceptorProvider>(
    () => InterceptorProviderImpl(),
  );
  locator.registerLazySingleton<BaseApiService>(
    () => NetworkApiService(
      httpConfig: locator<HttpConfig>(),
      headerProvider: locator<HeaderProvider>(),
      interceptorProvider: locator<InterceptorProvider>(),
      logger: locator<LoggerBinding>(),
      loader: locator<LoaderBinding>(),
    ),
  );

  // ── Theme Repository ────────────────────────────────────
  locator.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl());

  // ── App services ────────────────────────────────────────
  locator.registerLazySingleton<DeepLinkService>(() => DeepLinkServiceImpl());

  // ── Repositories ────────────────────────────────────────
  // locator.registerLazySingleton<ProfileRepository>(
  //   () => ProfileRepositoryImpl(),
  // );

  // ── Feature APIs ────────────────────────────────────────
  // locator.registerLazySingleton(
  //   () => ProfileApi(locator<BaseApiService>()),
  // );
}
DART
  ok "register_app.dart stubbed (backup at register_app.dart.bak)."
else
  warn "$REGISTER not found — skipping."
fi

# ────────────────────────────────────────────────────────────────
# Verify
# ────────────────────────────────────────────────────────────────
step "Verifying"

info "Running flutter pub get ..."
flutter pub get >/dev/null
ok "Dependencies resolved."

info "Running flutter analyze ..."
echo
if flutter analyze 2>&1 | tail -n 30; then
  ok "Analyze completed."
fi

# ────────────────────────────────────────────────────────────────
# Done
# ────────────────────────────────────────────────────────────────
echo
printf '%s\n' "${BOLD}${GREEN}✓ Project '$PROJECT_NAME' is initialized.${RESET}"
echo
printf '%s\n' "${BOLD}What remains manual (see NEW_PROJECT.md):${RESET}"
cat <<EOF

  ${DIM}Phase 2 remaining:${RESET}
    • lib/configs/app_configs/flavor/flavor_config.dart
        → set per-flavor URLs (dev / qas / pre / prod)
    • lib/configs/translation/app_translation_key.dart
        → replace app-specific keys with your own
    • lib/data/singletons/user_singleton.dart
        → add your user fields

  ${DIM}Phase 3 (optional):${RESET}
    • Firebase: create project, drop google-services.json
      and GoogleService-Info.plist into android/app/ and ios/Runner/

  ${DIM}Phase 4:${RESET}
    • Android signing: upload-keystore.jks + android/key.properties
    • iOS signing: open ios/Runner.xcworkspace, set Team & Bundle ID

  ${DIM}Phase 5:${RESET}
    • Run each flavor:
        flutter run -t lib/main_dev.dart
        flutter run -t lib/main_qas.dart
        flutter run -t lib/main_pre.dart
        flutter run -t lib/main.dart

  ${DIM}Phase 6:${RESET}
    • Scaffold features using:
        ./scripts/add_module.sh <feature_name>

  ${DIM}Backups of edited files (delete when satisfied):${RESET}
    • lib/routes/app_router.dart.bak
    • lib/routes/app_routes.dart.bak
    • lib/core/di/register_app.dart.bak

EOF
ok "Run './scripts/new_project.sh --help' for usage."
