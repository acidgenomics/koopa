#!/usr/bin/env bash
set -Eeu -o pipefail

# Find FIXME and TODO comments.
# Updated 2019-07-27.

# Returns with `true` or `false` exit codes.

path="${1:-$KOOPA_HOME}"

## Directory exclusion:
## `exclude-dir={dir1,dir2}` also works.
## Don't quote this argument.

hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude="fixme-comments.sh" \
        --exclude-dir=".git" \
        --exclude-dir="${KOOPA_HOME}/cellar" \
        --exclude-dir="${KOOPA_HOME}/conda" \
        --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/doom.d" \
        --exclude-dir="${KOOPA_HOME}/system/config/dotfiles/vim" \
        "\b(FIXME|TODO)\b" \
        "$path" | \
        sort || echo "" \
)"

if [[ -n "$hits" ]]
then
    printf "FIXME/TODO comments detected.\n"
    echo "$hits"
    exit 1
else
    exit 0
fi
