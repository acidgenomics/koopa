#!/bin/sh

_koopa_major_minor_patch_version() {
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2023-03-11.
    #
    # @examples
    # _koopa_major_minor_patch_version '1.0.0.9000'
    # # 1.0.0
    # _koopa_major_minor_patch_version '1.0.0p11'
    # # 1.0.0
    # _koopa_major_minor_patch_version '1.0.0-1'
    # # 1.0.0
    # """
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$__kvar_string" ] || return 1
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '-' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d 'p' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}
