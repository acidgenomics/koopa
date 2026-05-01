#!/usr/bin/env bash

_koopa_prelude_emacs() {
    local prelude_emacs_prefix
    prelude_emacs_prefix="$(_koopa_prelude_emacs_prefix)"
    if [[ ! -d "$prelude_emacs_prefix" ]]
    then
        _koopa_print 'Prelude Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$prelude_emacs_prefix" "$@"
    return 0
}
