#!/bin/sh

_koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-09-13.
    # """
    __kvar_spacemacs_prefix="$(_koopa_spacemacs_prefix)"
    if [ ! -d "$__kvar_spacemacs_prefix" ]
    then
        _koopa_print 'Spacemacs is not installed.'
        unset -v __kvar_spacemacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_spacemacs_prefix" "$@"
    unset -v __kvar_spacemacs_prefix
    return 0
}
