#!/usr/bin/env bash

_koopa_python_deactivate_venv() {
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    dict['prefix']="${VIRTUAL_ENV:-}"
    if [[ -z "${dict['prefix']}" ]]
    then
        _koopa_stop 'Python virtual environment is not active.'
    fi
    _koopa_remove_from_path_string "${dict['prefix']}/bin"
    unset -v VIRTUAL_ENV
    return 0
}
