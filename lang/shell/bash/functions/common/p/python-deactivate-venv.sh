#!/usr/bin/env bash

koopa_python_deactivate_venv() {
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2022-02-16.
    # """
    local dict
    declare -A dict=(
        [prefix]="${VIRTUAL_ENV:-}"
    )
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_stop 'Python virtual environment is not active.'
    fi
    koopa_remove_from_path "${dict[prefix]}/bin"
    unset -v VIRTUAL_ENV
    return 0
}
