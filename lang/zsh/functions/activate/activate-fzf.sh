#!/usr/bin/env zsh

_koopa_activate_fzf() {
    [[ -x "$(_koopa_bin_prefix)/fzf" ]] || return 0
    if [[ -z "${FZF_DEFAULT_OPTS:-}" ]]
    then
        local _fzf_color
        _fzf_color="$(_koopa_color_mode)"
        export FZF_DEFAULT_OPTS="--border --color ${_fzf_color} --multi"
    fi
    return 0
}
