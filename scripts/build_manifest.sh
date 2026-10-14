#!/usr/bin/env bash
# Builds .template/manifest.json for a newly-created project or during sync.
set -euo pipefail

VERSION="${VERSION:-$(cat .template-version 2>/dev/null || echo '0.0.0')}"
SEALED_FILE="${SEALED_FILE:-.template-sealed}"
MANIFEST_FILE="${MANIFEST_FILE:-.template/manifest.json}"

mkdir -p "$(dirname "$MANIFEST_FILE")"

# Hash a single file. Uses shasum on macOS, sha256sum on Linux.
hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

# Emit JSON.
{
  printf '{\n'
  printf '  "version": "%s",\n' "$VERSION"
  printf '  "sealed_at": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '  "files": {\n'

  FIRST=1
  while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" =~ ^# ]] && continue
    if [[ -d "$entry" ]]; then
      # Recurse into directories.
      while IFS= read -r f; do
        [[ -f "$f" ]] || continue
        H=$(hash_file "$f")
        [[ $FIRST -eq 0 ]] && printf ',\n'
        FIRST=0
        printf '    "%s": "%s"' "$f" "$H"
      done < <(find "$entry" -type f | sort)
    elif [[ -f "$entry" ]]; then
      H=$(hash_file "$entry")
      [[ $FIRST -eq 0 ]] && printf ',\n'
      FIRST=0
      printf '    "%s": "%s"' "$entry" "$H"
    fi
  done < "$SEALED_FILE"

  printf '\n  }\n'
  printf '}\n'
} > "$MANIFEST_FILE"

echo "✓ Wrote $MANIFEST_FILE ($(wc -l < "$MANIFEST_FILE" | tr -d ' ') lines)"
