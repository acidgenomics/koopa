#!/usr/bin/env zsh

_koopa_activate_fzf() {
    [[ -x "${KOOPA_PREFIX:?}/bin/fzf" ]] || return 0
    if [[ -z "${FZF_DEFAULT_OPTS:-}" ]]
    then
        export FZF_DEFAULT_OPTS="--border --color ${KOOPA_COLOR_MODE:?} --multi"
    fi
    return 0
}
