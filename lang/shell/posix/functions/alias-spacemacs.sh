#!/bin/sh

koopa_alias_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'spacemacs' "$@"
}
