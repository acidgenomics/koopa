#!/bin/sh

_koopa_alias_emacs() {
    # """
    # Emacs alias.
    # @note Updated 2023-03-22.
    # """
    _koopa_is_alias 'emacs' && unalias 'emacs'
    _koopa_emacs "$@"
}
