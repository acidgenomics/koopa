#!/bin/sh

koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2022-09-16.
    # """
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    koopa_emacs --with-profile 'doom' "$@"
    return 0
}
