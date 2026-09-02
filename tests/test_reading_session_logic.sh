#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
osascript -l JavaScript "$ROOT/tests/test_reading_session_logic.jxa.js" \
  "$ROOT/v4/index.html" "$ROOT/supabase/migrations/202608310002_reading_sessions.sql"
