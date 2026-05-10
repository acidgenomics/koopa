#!/usr/bin/env zsh

_koopa_export_editor() {
    if [[ -z "${EDITOR:-}" ]]
    then
        local editor
        editor="$(_koopa_bin_prefix)/nvim"
        [[ -x "$editor" ]] || editor='vim'
        EDITOR="$editor"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}
