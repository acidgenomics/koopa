#!/usr/bin/env bash
set -Eeuo pipefail

# Recursively run shellcheck on all scripts in a directory.

# This script requires shellcheck.
# https://github.com/koalaman/shellcheck
command -v shellcheck >/dev/null 2>&1 || { echo >&2 "shellcheck missing."; exit 1; }

find . -name "*.sh" -exec shellcheck {} \;
