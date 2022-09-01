#!/bin/sh

# FIXME Now seeing this warning/error when using macOS Emacs absolute path
# to binary, rather than symlinking into koopa bin:
#
# koopa_alias_doom_emacs:4: permission denied:
#
# > /Applications/Emacs.app/Contents/MacOS/Emacs --with-profile='doom'

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
