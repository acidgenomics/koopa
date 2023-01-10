#!/bin/sh

koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-01-06.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        koopa_print "Spacemacs is not installed at '${prefix}'."
        return 1
    fi
    koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}
