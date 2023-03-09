#!/bin/sh

# FIXME Move this to Bash.

_koopa_monorepo_prefix() {
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    _koopa_print "${HOME:?}/monorepo"
    return 0
}
