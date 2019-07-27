#!/usr/bin/env bash
set -Eeu -o pipefail

# Find lines containing more than 80 characters.
# Updated 2019-07-27.

# Returns with `true` or `false` exit codes.

path="${1:-$KOOPA_HOME}"

hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude-dir=".git" \
        --exclude-dir="${KOOPA_HOME}/cellar" \
        --exclude-dir="${KOOPA_HOME}/conda" \
        --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/doom.d" \
        --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/vim" \
        "^[^\n]{81}" \
        "$path" | \
        sort || echo "" \
)"

if [[ -n "$hits" ]]
then
    printf "Lines exceeding 80 characters detected.\n"
    echo "$hits"
    exit 1
else
    exit 0
fi
