#!/bin/sh

_koopa_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2023-05-09.
    # """
    if [ ! -d "$(_koopa_prelude_emacs_prefix)" ]
    then
        _koopa_print 'Prelude Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --with-profile 'prelude' "$@"
    return 0
}
