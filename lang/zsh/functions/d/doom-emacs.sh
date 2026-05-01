#!/usr/bin/env zsh

_koopa_doom_emacs() {
    local doom_emacs_prefix
    doom_emacs_prefix="$(_koopa_doom_emacs_prefix)"
    if [[ ! -d "$doom_emacs_prefix" ]]
    then
        _koopa_print 'Doom Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$doom_emacs_prefix" "$@"
    return 0
}
