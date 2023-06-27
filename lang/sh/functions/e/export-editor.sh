#!/bin/sh

_koopa_export_editor() {
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2023-06-27.
    # """
    if [ -z "${EDITOR:-}" ]
    then
        __kvar_editor="$(_koopa_bin_prefix)/vim"
        [ -x "$__kvar_editor" ] || __kvar_editor='vim'
        EDITOR="$__kvar_editor"
        unset -v __kvar_editor
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}
