#!/bin/sh

koopa_emacs_prefix() {
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    koopa_print "${HOME:?}/.emacs.d"
    return 0
}
