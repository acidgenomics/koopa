#!/bin/sh

# FIXME Move this into Bash.
_koopa_python_virtualenvs_prefix() {
    # """
    # Python virtual environment prefix.
    # @note Updated 2023-03-09.
    # """
    _koopa_print "${HOME}/.virtualenvs"
    return 0
}
