#!/bin/sh

koopa_major_minor_version() {
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}
