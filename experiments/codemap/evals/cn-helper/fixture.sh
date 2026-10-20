#!/usr/bin/env bash
# Seed the workspace with the tracked files of a local utility-sites checkout.
set -euo pipefail
git -C /home/user/utility-sites archive HEAD | tar -x
