#!/bin/bash
# protect-files.sh: PreToolUse hook for Edit|Write. Exit 2 blocks the edit and
# sends the stderr message back to Claude. Based on the protect-files example
# in the Claude Code hooks guide; requires jq.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Normalize Windows backslash separators so the patterns below match
FILE_PATH="${FILE_PATH//\\//}"

PROTECTED_PATTERNS=(
  ".env"
  ".git/"
  "package-lock.json"
  "pnpm-lock.yaml"
  "yarn.lock"
  "bun.lock"
  "composer.lock"
  "poetry.lock"
  "uv.lock"
  "Cargo.lock"
  ".github/workflows/"
)

# Unattended loops (/goal, ralph-loop, claude -p) only: also block test edits,
# because rewriting tests is the most common way agents fake a green run.
# Keep this off for interactive TDD, where writing tests is the first step.
if [ "${CLAUDE_PROTECT_TESTS:-0}" = "1" ]; then
  PROTECTED_PATTERNS+=("tests/" "test/" "__tests__/" ".test." ".spec." "_test.go")
fi

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'. Ask the user before changing it." >&2
    exit 2
  fi
done

exit 0
