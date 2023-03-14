#!/bin/sh

_koopa_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2023-03-11.
    # """
    [ -d "$(_koopa_prelude_emacs_prefix)" ] || return 1
    _koopa_emacs --with-profile 'prelude' "$@"
    return 0
}
