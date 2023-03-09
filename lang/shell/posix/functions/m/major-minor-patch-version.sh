#!/bin/sh

_koopa_major_minor_patch_version() {
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}
