#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
osascript -l JavaScript "$ROOT/tests/test_library_malfa_reorg.jxa.js" \
  "$ROOT/v4/index.html" \
  "$ROOT/supabase/migrations/20260902120525_reading_preferences_selected_book_and_weekly_goal.sql" \
  "$ROOT/supabase/migrations/20260902120540_collection_books_support_user_books.sql"
