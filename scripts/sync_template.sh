#!/usr/bin/env bash
# Preview by default. --apply writes only when the entire update is conflict-free.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "$ROOT/tool/sync_template.py" "$@"
