#!/bin/sh

# FIXME Move this to Bash.

_koopa_python_venv_name() {
    # """
    # Python virtual environment name.
    # @note Updated 2021-08-17.
    # """
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    # Strip out the path and just leave the env name.
    x="${x##*/}"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
