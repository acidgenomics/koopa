#!/usr/bin/env bash

# Find FIXME and TODO comments.
# Modified 2019-06-26.

# Returns with `true` or `false` exit codes.

path="${1:-$PWD}"

# shellcheck disable=SC2063
hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude "*/.git/*" \
        --exclude "*/dotfiles/doom.d/*" \
        --exclude "*/vim/pack/*" \
        --exclude "*-fixme-comments" \
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
