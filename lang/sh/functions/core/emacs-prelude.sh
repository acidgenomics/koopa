#!/bin/sh

_koopa_emacs_prelude() {
    # """
    # Emacs Prelude.
    # @note Updated 2023-05-09.
    # """
    __kvar_emacs_prelude_prefix="$(_koopa_emacs_prelude_prefix)"
    if [ ! -d "$__kvar_emacs_prelude_prefix" ]
    then
        _koopa_print 'Emacs Prelude is not installed.'
        unset -v __kvar_emacs_prelude_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_emacs_prelude_prefix" "$@"
    unset -v __kvar_emacs_prelude_prefix
    return 0
}
