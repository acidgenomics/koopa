#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run shellcheck on all scripts in a directory.
# Updated 2019-07-27.

path="${1:-$KOOPA_HOME}"

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.

grep -Elr \
    --binary-files="without-match" \
    --exclude="fixme-comments.sh" \
    --exclude-dir=".git" \
    --exclude-dir="${KOOPA_HOME}/cellar" \
    --exclude-dir="${KOOPA_HOME}/conda" \
    --exclude-dir="${KOOPA_HOME}/system/activate/shell/zsh/fpath" \
    --exclude-dir="${KOOPA_HOME}/system/config/dotfiles" \
    '^#!/.*\b(ba)?sh\b$' \
    "$path" | \
    xargs -I {} shellcheck -x {}

printf "  OK | %s\n" "$(basename "$0")"
exit 0
