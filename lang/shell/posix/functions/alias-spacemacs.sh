#!/bin/sh

# FIXME Now seeing this in terminal:
# koopa_alias_spacemacs:4: permission denied:

koopa_alias_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2022-08-31.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    "$(koopa_alias_emacs --with-profile 'spacemacs' "$@")"
    return 0
}
