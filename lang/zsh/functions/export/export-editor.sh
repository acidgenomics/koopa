#!/usr/bin/env zsh

_koopa_export_editor() {
    if [[ -z "${EDITOR:-}" ]]
    then
        local editor
        editor="${KOOPA_PREFIX:?}/bin/nvim"
        [[ -x "$editor" ]] || editor='vim'
        EDITOR="$editor"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}
