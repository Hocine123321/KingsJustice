#!/usr/bin/env bash
# Cheap repo checks. Runs in seconds on any machine: bash scripts/lint.sh
set -u
fail=0
report() { echo "LINT FAIL: $1"; fail=1; }

# 1. Leaked GitHub tokens. Only file names are printed, never the match.
files=$(git grep -lIE 'gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}' -- . ':!scripts/lint.sh')
if [ -n "$files" ]; then report "possible GitHub token in: $files"; fi

# 2. Leftover merge conflict markers.
files=$(git grep -lIE '^(<<<<<<< |>>>>>>> )' -- '*.swift' '*.md' '*.yml' '*.yaml' '*.json' ':!scripts/lint.sh')
if [ -n "$files" ]; then report "merge conflict markers in: $files"; fi

# 3. Tab characters in Swift sources.
files=$(git grep -lIP '\t' -- '*.swift')
if [ -n "$files" ]; then report "tab characters in: $files"; fi

# 4. Doubled backslash in a key path (ForEach(items, id: \\.id) does not compile).
files=$(git grep -lIF 'id: \\.' -- '*.swift')
if [ -n "$files" ]; then report "doubled backslash key path in: $files"; fi

# 5. Debug prints in app code.
files=$(git grep -lIE '^[[:space:]]*print\(' -- 'KingsJustice/*.swift')
if [ -n "$files" ]; then report "print() in app code: $files"; fi

if [ "$fail" -eq 0 ]; then echo "Lint passed."; fi
exit "$fail"
