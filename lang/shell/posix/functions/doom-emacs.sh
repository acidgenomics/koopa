#!/bin/sh

koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-01-06.
    # """
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        koopa_print "Doom Emacs is not installed at '${prefix}'."
        return 1
    fi
    koopa_emacs --with-profile 'doom' "$@"
    return 0
}
