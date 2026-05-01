#!/usr/bin/env bash

_koopa_activate_fzf() {
    [[ -x "$(_koopa_bin_prefix)/fzf" ]] || return 0
    if [[ -z "${FZF_DEFAULT_OPTS:-}" ]]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}
