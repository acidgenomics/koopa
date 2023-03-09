#!/bin/sh

_koopa_activate_asdf() {
    # """
    # Activate asdf.
    # @note Updated 2023-03-09.
    # """
    __kvar_prefix="${1:-}"
    if [ -z "$__kvar_prefix" ]
    then
        __kvar_prefix="$(_koopa_asdf_prefix)"
    fi
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    # NOTE Use 'asdf.fish' for Fish shell.
    __kvar_script="${__kvar_prefix}/libexec/asdf.sh"
    if [ ! -r "$__kvar_script" ]
    then
        unset -v __kvar_prefix __kvar_script
        return 0
    fi
    _koopa_is_alias 'asdf' && unalias 'asdf'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$__kvar_script"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v __kvar_nounset __kvar_prefix __kvar_script
    return 0
}
