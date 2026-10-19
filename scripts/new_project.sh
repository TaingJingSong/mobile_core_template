#!/usr/bin/env bash
# Creates a new app; never resets the current checkout.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec dart "$ROOT/tool/mobile_core.dart" create "$@"
