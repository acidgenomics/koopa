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
    --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/doom.d" \
    --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/vim" \
    '^#!/.*\b(ba)?sh\b$' \
    "$path" | \
    xargs -I {} shellcheck -x {}
