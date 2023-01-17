#!/bin/sh

koopa_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2023-01-06.
    # """
    local prefix
    prefix="$(koopa_prelude_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        koopa_print "Prelude Emacs is not installed at '${prefix}'."
        return 1
    fi
    koopa_emacs --with-profile 'prelude' "$@"
    return 0
}