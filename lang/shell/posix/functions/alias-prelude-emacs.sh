#!/bin/sh

koopa_alias_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_prelude_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'prelude' "$@"
}
