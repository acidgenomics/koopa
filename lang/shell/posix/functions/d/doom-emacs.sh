#!/bin/sh

_koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-01-06.
    # """
    local prefix
    prefix="$(_koopa_doom_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "Doom Emacs is not installed at '${prefix}'."
        return 1
    fi
    _koopa_emacs --with-profile 'doom' "$@"
    return 0
}
