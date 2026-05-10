#!/usr/bin/env bash

_koopa_emacs_prelude() {
    local emacs_prelude_prefix
    emacs_prelude_prefix="$(_koopa_emacs_prelude_prefix)"
    if [[ ! -d "$emacs_prelude_prefix" ]]
    then
        _koopa_print 'Emacs Prelude is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$emacs_prelude_prefix" "$@"
    return 0
}
