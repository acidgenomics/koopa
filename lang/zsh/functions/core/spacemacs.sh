#!/usr/bin/env zsh

_koopa_spacemacs() {
    local spacemacs_prefix
    spacemacs_prefix="$(_koopa_spacemacs_prefix)"
    if [[ ! -d "$spacemacs_prefix" ]]
    then
        _koopa_print 'Spacemacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$spacemacs_prefix" "$@"
    return 0
}
