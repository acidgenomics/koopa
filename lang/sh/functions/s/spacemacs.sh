#!/bin/sh

_koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-05-09.
    # """
    if [ ! -d "$(_koopa_spacemacs_prefix)" ]
    then
        _koopa_print 'Spacemacs is not installed.'
        return 1
    fi
    _koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}
