#!/usr/bin/env bash
# Validates the inline <script> in index.html.
# Extracts the script body and syntax-checks it (parse only, never executed)
# so DOM/window/document references don't trip a real runtime error.
# Prints "JS OK" on success.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${1:-$DIR/index.html}"
TMP="$(mktemp -t malfa-js-XXXXXX.js)"
trap 'rm -f "$TMP"' EXIT

if [ ! -f "$SRC" ]; then
  echo "build.sh: $SRC not found" >&2
  exit 1
fi

awk '/<script>/{f=1;next}/<\/script>/{f=0}f' "$SRC" > "$TMP"

if [ ! -s "$TMP" ]; then
  echo "build.sh: no <script> content extracted from $SRC" >&2
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  node --check "$TMP"
  echo "JS OK"
  exit 0
fi

# Fallback for machines without Node: use macOS JavaScriptCore (via osascript)
# to parse the script with `new Function(src)`. That compiles/validates syntax
# without ever calling the function, so DOM globals (document, window, ...)
# never need to exist.
if command -v osascript >/dev/null 2>&1; then
  RUNNER="$DIR/.jscheck.jxa.js"
  cat > "$RUNNER" <<'JXA'
function run(argv) {
  ObjC.import('Foundation');
  var path = argv[0];
  var nsstr = $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
  var src = ObjC.unwrap(nsstr);
  new Function(src);
}
JXA
  osascript -l JavaScript "$RUNNER" "$TMP"
  rm -f "$RUNNER"
  echo "JS OK"
  exit 0
fi

echo "build.sh: neither node nor osascript available to check JS syntax" >&2
exit 1
