#!/bin/sh

_koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-09-13.
    # """
    __kvar_doom_emacs_prefix="$(_koopa_doom_emacs_prefix)"
    if [ ! -d "$__kvar_doom_emacs_prefix" ]
    then
        _koopa_print 'Doom Emacs is not installed.'
        unset -v __kvar_doom_emacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_doom_emacs_prefix" "$@"
    unset -v __kvar_doom_emacs_prefix
    return 0
}
