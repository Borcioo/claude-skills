#!/usr/bin/env bash
# Seed the workspace with utility-sites (tracked files) plus node_modules
# hard-linked from a pre-installed copy (pnpm install --frozen-lockfile).
set -euo pipefail
MASTER="/tmp/claude-0/-home-user/0ce31b4b-ae8f-5849-8f61-b2bb40735e4f/scratchpad/us-master"
W="$(pwd)"
git -C /home/user/utility-sites archive HEAD | tar -x
git init -q
(cd "$MASTER" && find . -name node_modules -prune -type d) | while read -r d; do
  cp -al "$MASTER/$d" "$W/$d"
done
