#!/bin/sh

_koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-05-09.
    # """
    if [ ! -d "$(_koopa_doom_emacs_prefix)" ]
    then
        _koopa_print 'Doom Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --with-profile 'doom' "$@"
    return 0
}
