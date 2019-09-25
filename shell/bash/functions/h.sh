#!/usr/bin/env bash



# Help header string.
# Updated 2019-09-25.
_koopa_help_header() {
    local file
    file="$( \
        caller | \
        head -n 1 | \
        cut -d ' ' -f 2 \
    )"
    local name
    name="$(basename "$file")"
    printf "usage: %s [--help|-h]" "$name"
}
