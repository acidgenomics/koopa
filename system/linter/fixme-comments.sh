#!/usr/bin/env bash
set -Eeu -o pipefail

# Find FIXME and TODO comments.
# Updated 2019-07-10.

# Returns with `true` or `false` exit codes.

path="${1:-$PWD}"

hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude-dir={.git,cellar,conda,doom.d,vim} \
        --exclude="fixme-comments.sh" \
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
