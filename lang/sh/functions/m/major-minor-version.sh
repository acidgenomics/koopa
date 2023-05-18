#!/bin/sh

_koopa_major_minor_version() {
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2023-03-11.
    # """
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}
