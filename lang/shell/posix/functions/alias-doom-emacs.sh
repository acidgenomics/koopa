#!/bin/sh

koopa_alias_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'doom' "$@"
}
