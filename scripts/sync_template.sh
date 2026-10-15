#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
# sync_template.sh
# ════════════════════════════════════════════════════════════════
# Pulls updates from the template repo into this project.
#
# Usage:
#   ./scripts/sync_template.sh                    # latest tag
#   ./scripts/sync_template.sh v1.2.0             # specific tag
#   ./scripts/sync_template.sh --check            # dry-run, no writes
#   ./scripts/sync_template.sh --force            # overwrite local edits
#
# Requires: git, shasum (macOS) or sha256sum (Linux).
#
# HOW IT WORKS
#   1. Reads .template/manifest.json for stored hashes.
#   2. Clones the template into a temp directory.
#   3. For each sealed file:
#        - hash matches stored → untouched → overwrite
#        - hash differs       → locally modified → skip (or conflict)
#   4. Writes a new manifest.
#
# Edit the sealed file list in .template-sealed (template repo).

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# Config — edit these for your template
# ────────────────────────────────────────────────────────────────
TEMPLATE_REPO="${TEMPLATE_REPO:-git@github.com:your-org/mobile-template.git}"

# ────────────────────────────────────────────────────────────────
# Colors & helpers
# ────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'

info() { printf '%s\n' "${BLUE}ℹ${RESET} $*"; }
ok()   { printf '%s\n' "${GREEN}✓${RESET} $*"; }
warn() { printf '%s\n' "${YELLOW}⚠${RESET} $*"; }
err()  { printf '%s\n' "${RED}✗${RESET} $*" >&2; }
die()  { err "$*"; exit 1; }
step() { printf '\n%s\n' "${BOLD}${BLUE}▸ $*${RESET}"; }

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

# ────────────────────────────────────────────────────────────────
# Args
# ────────────────────────────────────────────────────────────────
CHECK_ONLY=0
FORCE=0
REF=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) CHECK_ONLY=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help)
      sed -n '3,30p' "$0"; exit 0 ;;
    *) REF="$1"; shift ;;
  esac
done

# ────────────────────────────────────────────────────────────────
# Sanity
# ────────────────────────────────────────────────────────────────
[[ -f "pubspec.yaml" ]]            || die "Run from the project root."
[[ -f ".template/manifest.json" ]] || die "No .template/manifest.json. Run scripts/build_manifest.sh first."
command -v git >/dev/null 2>&1     || die "git not found."

step "Template sync"
info "Repo:    $TEMPLATE_REPO"
info "Ref:     ${REF:-latest tag}"
[[ "$CHECK_ONLY" -eq 1 ]] && info "Mode:    check-only (no writes)"
[[ "$FORCE" -eq 1 ]]      && warn "Mode:    force (local edits will be overwritten)"

# ────────────────────────────────────────────────────────────────
# Read current manifest
# ────────────────────────────────────────────────────────────────
info "Reading .template/manifest.json ..."
CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' .template/manifest.json | sed 's/.*"\(.*\)"/\1/')
info "Current template version: $CURRENT_VERSION"

# Dump old hashes to a temp file for lookup.
OLD_HASHES=$(mktemp)
grep -oE '"[^"]+": *"[a-f0-9]{64}"' .template/manifest.json \
  | sed -E 's/"([^"]+)": *"([a-f0-9]{64})"/\1 \2/' > "$OLD_HASHES"

# ────────────────────────────────────────────────────────────────
# Clone template
# ────────────────────────────────────────────────────────────────
TMP=$(mktemp -d)
trap 'rm -rf "$TMP" "$OLD_HASHES"' EXIT

step "Fetching template"

if [[ -n "$REF" ]]; then
  git clone --quiet --depth 1 --branch "$REF" "$TEMPLATE_REPO" "$TMP/template" \
    || die "Failed to clone $TEMPLATE_REPO at $REF"
else
  git clone --quiet --depth 1 "$TEMPLATE_REPO" "$TMP/template" \
    || die "Failed to clone $TEMPLATE_REPO"
fi

NEW_VERSION="$(cat "$TMP/template/.template-version" 2>/dev/null || echo '0.0.0')"
ok "Fetched template version $NEW_VERSION"

# Normalize package name in fetched template if target project was renamed
TEMPLATE_PKG="$(grep -E '^name:[[:space:]]*' "$TMP/template/pubspec.yaml" 2>/dev/null | head -n1 | awk '{print $2}' || echo 'app_base')"
LOCAL_PKG="$(grep -E '^name:[[:space:]]*' pubspec.yaml | head -n1 | awk '{print $2}')"
if [[ -n "$TEMPLATE_PKG" && -n "$LOCAL_PKG" && "$TEMPLATE_PKG" != "$LOCAL_PKG" ]]; then
  find "$TMP/template" -type f -name "*.dart" -exec perl -i -pe "s|package:$TEMPLATE_PKG/|package:$LOCAL_PKG/|g" {} + 2>/dev/null || true
fi

if [[ "$NEW_VERSION" == "$CURRENT_VERSION" && "$FORCE" -eq 0 ]]; then
  ok "Already up to date ($CURRENT_VERSION). Nothing to do."
  exit 0
fi

info "Upgrading: $CURRENT_VERSION → $NEW_VERSION"

# ────────────────────────────────────────────────────────────────
# Walk sealed files
# ────────────────────────────────────────────────────────────────
step "Comparing sealed files"

UPDATED=()
CONFLICTS=()
ADDED=()
REMOVED=()

while IFS= read -r entry; do
  [[ -z "$entry" || "$entry" =~ ^# ]] && continue
  SRC="$TMP/template/$entry"

  # Resolve directories into file lists.
  if [[ -d "$SRC" ]]; then
    FILES=()
    while IFS= read -r f; do
      FILES+=("${f#"$TMP/template/"}")
    done < <(find "$SRC" -type f | sort)
  elif [[ -f "$SRC" ]]; then
    FILES=("$entry")
  else
    # Sealed path missing from template — treat as removed.
    continue
  fi

  for rel in "${FILES[@]}"; do
    NEW_HASH=$(hash_file "$TMP/template/$rel")
    LOCAL_PATH="$rel"

    OLD_HASH=$(grep -E "^$rel " "$OLD_HASHES" | awk '{print $2}' || true)

    if [[ ! -f "$LOCAL_PATH" ]]; then
      # New file — safe to add.
      if [[ "$CHECK_ONLY" -eq 0 ]]; then
        mkdir -p "$(dirname "$LOCAL_PATH")"
        cp "$TMP/template/$rel" "$LOCAL_PATH"
      fi
      ADDED+=("$rel")
      continue
    fi

    LOCAL_HASH=$(hash_file "$LOCAL_PATH")

    if [[ -z "$OLD_HASH" ]]; then
      # Wasn't in old manifest — treat as new.
      if [[ "$CHECK_ONLY" -eq 0 ]]; then
        cp "$TMP/template/$rel" "$LOCAL_PATH"
      fi
      ADDED+=("$rel")
    elif [[ "$LOCAL_HASH" == "$OLD_HASH" ]]; then
      # Untouched by project — safe to update.
      if [[ "$LOCAL_HASH" == "$NEW_HASH" ]]; then
        : # already current
      else
        if [[ "$CHECK_ONLY" -eq 0 ]]; then
          cp "$TMP/template/$rel" "$LOCAL_PATH"
        fi
        UPDATED+=("$rel")
      fi
    else
      # Locally modified.
      if [[ "$FORCE" -eq 1 ]]; then
        if [[ "$CHECK_ONLY" -eq 0 ]]; then
          cp "$TMP/template/$rel" "$LOCAL_PATH"
        fi
        UPDATED+=("$rel (forced)")
      else
        CONFLICTS+=("$rel")
      fi
    fi
  done
done < "$TMP/template/.template-sealed"

# Detect files removed from the sealed list in the new template.
while IFS= read -r old_rel; do
  old_rel=$(echo "$old_rel" | awk '{print $1}')
  if ! grep -qE "^$old_rel$" "$TMP/template/.template-sealed" \
     && ! grep -rqF "$old_rel" "$TMP/template/.template-sealed" 2>/dev/null; then
    : # best-effort; skip detection — safer to not delete
  fi
done < "$OLD_HASHES"

# ────────────────────────────────────────────────────────────────
# Report
# ────────────────────────────────────────────────────────────────
step "Summary"

if [[ ${#ADDED[@]} -gt 0 ]]; then
  printf '%s\n' "${BOLD}Added (${#ADDED[@]}):${RESET}"
  for f in "${ADDED[@]}"; do printf '  + %s\n' "$f"; done
fi

if [[ ${#UPDATED[@]} -gt 0 ]]; then
  printf '\n%s\n' "${BOLD}${GREEN}Updated (${#UPDATED[@]}):${RESET}"
  for f in "${UPDATED[@]}"; do printf '  ↑ %s\n' "$f"; done
fi

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  printf '\n%s\n' "${BOLD}${RED}Conflicts (${#CONFLICTS[@]}) — locally modified, NOT overwritten:${RESET}"
  for f in "${CONFLICTS[@]}"; do printf '  ⚠ %s\n' "$f"; done
  echo
  printf '%s\n' "${DIM}Fix by either:"
  printf '%s\n' "  • Restoring the file to its sealed version (git checkout -- <file>)"
  printf '%s\n' "  • Re-running with --force (overwrites your changes)"
  printf '%s\n' "  • Comparing manually: git diff HEAD~1 <file>${RESET}"
fi

if [[ ${#REMOVED[@]} -gt 0 ]]; then
  printf '\n%s\n' "${BOLD}Removed from template (kept locally):${RESET}"
  for f in "${REMOVED[@]}"; do printf '  - %s\n' "$f"; done
fi

# ────────────────────────────────────────────────────────────────
# Write new manifest
# ────────────────────────────────────────────────────────────────
if [[ "$CHECK_ONLY" -eq 0 ]]; then
  step "Writing new manifest"
  cp "$TMP/template/.template-sealed" .template/.sealed
  # Regenerate manifest from local files, using the new version.
  VERSION="$NEW_VERSION" \
  SEALED_FILE=".template/.sealed" \
  MANIFEST_FILE=".template/manifest.json" \
  bash "$(dirname "$0")/build_manifest.sh" >/dev/null
  ok "Manifest updated to $NEW_VERSION."
else
  info "Check-only mode — manifest not updated."
fi

# ────────────────────────────────────────────────────────────────
# Final
# ────────────────────────────────────────────────────────────────
echo
if [[ ${#CONFLICTS[@]} -eq 0 ]]; then
  printf '%s\n' "${BOLD}${GREEN}✓ Sync complete. $CURRENT_VERSION → $NEW_VERSION${RESET}"
else
  printf '%s\n' "${BOLD}${YELLOW}⚠ Sync complete with ${#CONFLICTS[@]} conflict(s).${RESET}"
  printf '%s\n' "${DIM}Review the files above, resolve, then run flutter analyze.${RESET}"
fi
