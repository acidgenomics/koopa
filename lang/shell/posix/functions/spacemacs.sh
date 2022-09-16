#!/bin/sh

koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2022-09-16.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}
