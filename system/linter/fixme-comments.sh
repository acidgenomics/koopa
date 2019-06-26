#!/usr/bin/env bash

# Find FIXME and TODO comments.
# Modified 2019-06-26.

# Returns with `true` or `false` exit codes.

path="${1:-$PWD}"

hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude-dir={.git,cellar,conda,doom.d,vim} \
        --exclude="fixme-comments.sh" \
        "\b(FIXME|TODO)\b" \
        "$path" | \
        sort \
)"

if [[ -n "$hits" ]]
then
    echo "$hits"
    false
else
    true
fi
