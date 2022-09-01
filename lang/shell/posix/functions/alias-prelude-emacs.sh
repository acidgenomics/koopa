#!/bin/sh

koopa_alias_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2022-08-31.
    # """
    local prefix
    prefix="$(koopa_prelude_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    "$(koopa_alias_emacs --with-profile 'prelude' "$@")"
    return 0
}
