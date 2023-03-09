#!/bin/sh

_koopa_pyenv_prefix() {
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}
