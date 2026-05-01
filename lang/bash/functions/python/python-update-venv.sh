#!/usr/bin/env bash

_koopa_python_update_venv() {
    # """
    # Update packages in a Python virtual environment.
    # @note Updated 2025-04-16.
    #
    # @seealso
    # - https://www.activestate.com/resources/quick-reads/
    #   how-to-update-all-python-packages/
    # """
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['venv_prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['venv_prefix']}"
    dict['requirements']="$(_koopa_mktemp)"
    _koopa_python_activate_venv "${dict['venv_prefix']}"
    pip freeze > "$dict['requirements']}"
    pip install -r "${dict['requirements']}" --upgrade
    _koopa_python_deactivate_venv
    _koopa_rm "${dict['requirements']}"
    return 0
}
