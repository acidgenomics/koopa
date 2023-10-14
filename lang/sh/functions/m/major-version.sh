#!/bin/sh

_koopa_major_version() {
    # """
    # Program 'MAJOR' version.
    # @note Updated 2023-10-13.
    #
    # @examples
    # _koopa_major_version '1.0.0' '1-1' '1+10'
    # # 1 1 1
    # """
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1' \
            | cut -d '-' -f '1' \
            | cut -d '+' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}
