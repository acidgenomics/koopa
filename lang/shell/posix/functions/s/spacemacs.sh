#!/bin/sh

_koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-01-06.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "Spacemacs is not installed at '${prefix}'."
        return 1
    fi
    _koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}
