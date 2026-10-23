#!/usr/bin/env bash
# Prints the Dart files under lib/ that the checks apply to: everything except generated
# code and the legacy files listed in scripts/legacy-files.txt.
set -euo pipefail
cd "$(dirname "$0")/.."

legacy_patterns=$(mktemp)
trap 'rm -f "$legacy_patterns"' EXIT
{ grep -v '^#' scripts/legacy-files.txt || true; } | sed '/^$/d' > "$legacy_patterns"

files=$(find lib -name '*.dart' -not -path 'lib/l10n/gen/*' | sort)

# An empty list exempts nothing (grep -f with no patterns would match nothing at all).
if [ -s "$legacy_patterns" ]; then
  echo "$files" | grep -vxF -f "$legacy_patterns" || true
else
  echo "$files"
fi
