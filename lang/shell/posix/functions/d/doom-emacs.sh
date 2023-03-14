#!/bin/sh

_koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-03-11.
    # """
    [ -d "$(_koopa_doom_emacs_prefix)" ] || return 1
    _koopa_emacs --with-profile 'doom' "$@"
    return 0
}
