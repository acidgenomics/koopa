#!/bin/sh

koopa_alias_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2022-08-31.
    # """
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    "$(koopa_alias_emacs --with-profile 'doom' "$@")"
    return 0
}
