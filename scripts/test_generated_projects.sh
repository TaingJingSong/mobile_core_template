#!/usr/bin/env bash
# End-to-end generation tests. Requires Flutter, Git, and Android SDK for --build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for preset in minimal standard enterprise; do
  dart "$ROOT/tool/mobile_core.dart" create --name "sample_$preset" --org com.example --preset "$preset" --output "$TMP/$preset"
  if [[ "${1:-}" == "--build" ]]; then
    (cd "$TMP/$preset" && flutter build apk --debug)
  fi
done
cd "$TMP/minimal"
git init --quiet
git add .
git -c user.name='Template test' -c user.email='template-test@example.invalid' commit --quiet -m 'Generated app'
for feature in networking_dio firebase; do
  dart "$ROOT/tool/mobile_core.dart" feature add "$feature"
  git add .
  git -c user.name='Template test' -c user.email='template-test@example.invalid' commit --quiet -m "Install $feature"
  dart "$ROOT/tool/mobile_core.dart" feature add "$feature"
  git diff --exit-code
  if [[ "$feature" == "firebase" ]]; then
    managed="lib/integrations/firebase/fcm_token_singleton.dart"
  else
    managed="lib/integrations/networking.dart"
  fi
  printf '\n// Application customization\n' >> "$managed"
  if dart "$ROOT/tool/mobile_core.dart" feature remove "$feature"; then
    echo "ERROR: removed customized feature source" >&2
    exit 1
  fi
  [[ -f "$managed" ]] || { echo "ERROR: customized file disappeared" >&2; exit 1; }
  git show "HEAD:$managed" > "$managed"
  dart "$ROOT/tool/mobile_core.dart" feature remove "$feature"
  git add .
  git -c user.name='Template test' -c user.email='template-test@example.invalid' commit --quiet -m "Remove $feature"
done

# A mandatory dependency failure must restore tracked files and remove new source.
mkdir "$TMP/fail-bin"
printf '#!/usr/bin/env bash\nexit 23\n' > "$TMP/fail-bin/flutter"
chmod +x "$TMP/fail-bin/flutter"
if PATH="$TMP/fail-bin:$PATH" dart "$ROOT/tool/mobile_core.dart" feature add networking_dio; then
  echo "ERROR: dependency failure reported success" >&2
  exit 1
fi
git diff --exit-code
[[ ! -f lib/integrations/networking.dart ]] || { echo "ERROR: failed install left source" >&2; exit 1; }
