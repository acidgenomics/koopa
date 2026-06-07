#!/bin/sh

_koopa_activate_fzf() {
    [ -x "${KOOPA_PREFIX:?}/bin/fzf" ] || return 0
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        _fzf_color="$(_koopa_color_mode)"
        export FZF_DEFAULT_OPTS="--border --color ${_fzf_color} --multi"
        unset -v _fzf_color
    fi
    return 0
}
