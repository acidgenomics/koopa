#!/bin/sh

_koopa_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2023-05-09.
    # """
    __kvar_prelude_emacs_prefix="$(_koopa_prelude_emacs_prefix)"
    if [ ! -d "$__kvar_prelude_emacs_prefix" ]
    then
        _koopa_print 'Prelude Emacs is not installed.'
        unset -v __kvar_prelude_emacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_prelude_emacs_prefix" "$@"
    unset -v __kvar_prelude_emacs_prefix
    return 0
}
