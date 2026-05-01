#!/bin/sh

_koopa_alias_kb() {
    # """
    # Koopa 'kb' shortcut alias.
    # @note Updated 2023-05-18.
    # """
    __kvar_bash_prefix="$(_koopa_koopa_prefix)/lang/bash"
    [ -d "$__kvar_bash_prefix" ] || return 1
    cd "$__kvar_bash_prefix" || return 1
    return 0
}
