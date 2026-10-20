#!/usr/bin/env bash
# guard.sh: PreToolUse hook for Edit|Write, Bash and PowerShell. Exit 2 blocks the call and
# sends the stderr message back to Claude.
# - Edit/Write: blocks edits to secrets, lockfiles, .git/ and CI workflows.
# - Bash/PowerShell: blocks shell writes (>, tee, sed -i, mv, cp, rm, ...) to the same paths,
#   the usual way around Edit/Write hooks.
# - CLAUDE_PROTECT_TESTS=1 (unattended runs only): test files are protected too.
# Works without jq (Windows Git Bash): falls back to extracting the JSON field.

INPUT=$(cat)

json_field() { # name -> raw string value of the first "name": "..." in $INPUT
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r --arg k "$1" '.tool_input[$k] // empty'
    return
  fi
  printf '%s' "$INPUT" \
    | grep -o -E "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" \
    | head -n 1 \
    | sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//; s/\\\\\"/\"/g; s/\\\\\\\\/\\\\/g"
}

PROTECTED='(^|[[:space:]/"'"'"'=])\.env(\.[A-Za-z0-9_-]+)?($|[[:space:]"'"'"';|&)])'
PROTECTED="$PROTECTED"'|(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?|composer\.lock|poetry\.lock|uv\.lock|Cargo\.lock)'
PROTECTED="$PROTECTED"'|(^|[[:space:]/"'"'"'])\.git/'
PROTECTED="$PROTECTED"'|\.github/workflows/'
if [ "${CLAUDE_PROTECT_TESTS:-0}" = "1" ]; then
  PROTECTED="$PROTECTED"'|(^|[[:space:]/"'"'"'])(tests?|__tests__|e2e)/|\.(test|spec)\.[A-Za-z]+|_test\.go'
fi

block() {
  echo "Blocked by guardrails: $1. Ask the user before changing protected files (secrets, lockfiles, .git, CI${CLAUDE_PROTECT_TESTS:+, tests})." >&2
  exit 2
}

FILE_PATH=$(json_field file_path)
if [ -n "$FILE_PATH" ]; then
  # Normalize Windows backslash separators so the patterns below match
  FILE_PATH="${FILE_PATH//\\//}"
  if printf '%s' "$FILE_PATH" | grep -q -E -- "$PROTECTED"; then
    block "$FILE_PATH is protected"
  fi
  exit 0
fi

COMMAND=$(json_field command)
if [ -n "$COMMAND" ]; then
  # Drop redirections that do not write files (2>&1, >/dev/null, > NUL) first.
  WRITES=$(printf '%s' "$COMMAND" | sed -E 's/[0-9]*>&[0-9]+//g; s/[0-9]*>>?[[:space:]]*(\/dev\/null|NUL|\$null)//g')
  if printf '%s' "$WRITES" | grep -q -E -- '>|(^|[[:space:];&|(])(tee|mv|cp|rm|truncate|Set-Content|Add-Content|Out-File|New-Item|Remove-Item|Move-Item|Copy-Item)[[:space:]]|sed[[:space:]]+(-[A-Za-z]*[[:space:]]+)*-i|perl[[:space:]]+-[A-Za-z]*i'; then
    if printf '%s' "${WRITES//\\//}" | grep -q -E -- "$PROTECTED"; then
      block "this command writes to a protected path"
    fi
  fi
fi

exit 0
