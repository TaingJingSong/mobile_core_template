#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
# check_template_drift.sh
# ════════════════════════════════════════════════════════════════
# Checks if the project is behind the template. Non-destructive.
#
# Usage:
#   ./scripts/check_template_drift.sh
#   ./scripts/check_template_drift.sh --fetch   # also prints new commit info

set -euo pipefail

TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/TaingJingSong/mobile_core_template.git}"
case "$TEMPLATE_REPO" in
  https://*|ssh://*|git@*) ;;
  *) [[ -d "$TEMPLATE_REPO" && "$TEMPLATE_REPO" != -* ]] || { echo "Invalid TEMPLATE_REPO" >&2; exit 1; } ;;
esac
FETCH=0

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '3,10p' "$0"
  exit 0
fi

[[ "${1:-}" == "--fetch" ]] && FETCH=1

GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[0;34m'
DIM=$'\033[2m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

[[ -f ".template/manifest.json" ]] || { echo "No .template/manifest.json"; exit 1; }

CURRENT=$(grep -o '"version": *"[^"]*"' .template/manifest.json | sed 's/.*"\(.*\)"/\1/')
printf '%s\n' "${BLUE}ℹ${RESET} Local template version: $CURRENT"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git clone --quiet --depth 1 -- "$TEMPLATE_REPO" "$TMP/template" >/dev/null 2>&1 \
  || { echo "Failed to fetch template from $TEMPLATE_REPO"; exit 1; }

LATEST=$(cat "$TMP/template/.template-version" 2>/dev/null || echo '0.0.0')

if [[ "$CURRENT" == "$LATEST" ]]; then
  printf '%s\n' "${GREEN}✓${RESET} Up to date with template ($LATEST)."
  exit 0
fi

printf '%s\n' "${YELLOW}⚠${RESET} Behind template: $CURRENT → $LATEST"
echo
printf '%s\n' "${BOLD}Files that would change:${RESET}"
printf '%s\n' "${DIM}(run ./scripts/sync_template.sh --check for a full list)${RESET}"

# Rough diff of what changed — optional, and best-effort.
if [[ "$FETCH" -eq 1 ]]; then
  echo
  printf '%s\n' "${BOLD}Latest template commit:${RESET}"
  git -C "$TMP/template" log -1 --pretty='  %h %s (%cr)' 2>/dev/null || true
fi

echo
printf '%s\n' "To sync: ${BOLD}./scripts/sync_template.sh${RESET}"
