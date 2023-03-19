#!/bin/sh

_koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-03-11.
    # """
    [ -d "$(_koopa_spacemacs_prefix)" ] || return 1
    _koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}
