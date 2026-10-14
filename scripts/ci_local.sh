#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
# ci_local.sh
# ════════════════════════════════════════════════════════════════
# Runs the same checks GitHub Actions runs. Use before pushing.
#
# Usage:
#   ./scripts/ci_local.sh             # full run
#   ./scripts/ci_local.sh --fast      # analyze + test only
#   ./scripts/ci_local.sh --build     # + build dev APK (slow)

set -euo pipefail

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; BOLD=$'\033[1m'
DIM=$'\033[2m'; RESET=$'\033[0m'

MODE="full"
for arg in "$@"; do
  case "$arg" in
    --fast)  MODE="fast" ;;
    --build) MODE="build" ;;
    -h|--help) sed -n '3,12p' "$0"; exit 0 ;;
  esac
done

run() {
  printf '\n%s\n' "${BOLD}▸ $*${RESET}"
  if "$@"; then
    printf '%s\n' "${GREEN}✓${RESET} $1"
  else
    printf '%s\n' "${RED}✗${RESET} $1 failed" >&2
    exit 1
  fi
}

# ── Checks every PR runs ────────────────────────────────────────
run flutter pub get
run dart format --set-exit-if-changed lib test
run flutter analyze --fatal-infos
run flutter test --coverage

# ── Coverage floor (optional, tune per project) ─────────────────
if [[ -f "coverage/lcov.info" ]]; then
  printf '\n%s\n' "${BOLD}▸ coverage report${RESET}"
  # Requires lcov installed (brew install lcov).
  if command -v lcov >/dev/null 2>&1; then
    lcov --summary coverage/lcov.info 2>&1 | tail -n 3
  else
    printf '%s\n' "${DIM}(install lcov for coverage summary)${RESET}"
  fi
fi

[[ "$MODE" == "fast" ]] && { printf '\n%s\n' "${GREEN}${BOLD}✓ Fast checks passed.${RESET}"; exit 0; }

# ── Build checks ────────────────────────────────────────────────
run flutter build apk --debug -t lib/main_dev.dart

if [[ "$MODE" == "build" && "$(uname)" == "Darwin" ]]; then
  run flutter build ios --no-codesign --debug -t lib/main_dev.dart
fi

printf '\n%s\n' "${GREEN}${BOLD}✓ All checks passed.${RESET}"
