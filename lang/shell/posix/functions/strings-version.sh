#!/bin/sh

_koopa_macos_version() { # {{{1
    # """
    # macOS version.
    # @note Updated 2021-11-18.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    _koopa_is_macos || return 1
    x="$(/usr/bin/sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_major_version() { # {{{1
    # """
    # Program 'MAJOR' version.
    # @note Updated 2021-05-26.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    local cut version x
    [ "$#" -gt 0 ] || return 1
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f 1 \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2021-05-26.
    # """
    local cut version x
    [ "$#" -gt 0 ] || return 1
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_patch_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2021-05-26.
    # """
    local cut version x
    [ "$#" -gt 0 ] || return 1
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}
