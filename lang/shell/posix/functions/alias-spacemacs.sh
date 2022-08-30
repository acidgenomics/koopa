#!/bin/sh

koopa_alias_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2022-08-30.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    "$(koopa_alias_emacs --with-profile 'spacemacs' "$@")"
    return 0
}
