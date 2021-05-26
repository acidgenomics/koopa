#!/bin/sh

_koopa_alias_conda() { # {{{1
    # """
    # Conda alias.
    # @note Updated 2021-05-26.
    # """
    if _koopa_is_alias conda
    then
        unalias conda
        _koopa_activate_conda
    fi
    conda "$@"
}

_koopa_alias_br() { # {{{1
    if _koopa_is_alias br
    then
        unalias br
        _koopa_activate_broot
    fi
    br "$@"
}
