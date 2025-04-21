#!/bin/sh

_koopa_alias_venv() {
    # """
    # Python virtual environment activation alias.
    # @note Updated 2025-04-17.
    # """
    if [ -f '.venv/bin/activate' ]
    then
        # shellcheck source=/dev/null
        source '.venv/bin/activate'
    elif [ -f "venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "venv/bin/activate"
    elif [ -f "${HOME}/.venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "${HOME}/.venv/bin/activate"
    elif [ -f "${HOME}/venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "${HOME}/venv/bin/activate"
    else
        _koopa_print 'Failed to locate Python virtual environment.'
        return 1
    fi
    return 0
}
