#!/usr/bin/env bash

koopa_python_update_venv() {
    # """
    # Update packages in a Python virtual environment.
    # @note Updated 2025-04-16.
    #
    # @seealso
    # - https://www.activestate.com/resources/quick-reads/
    #   how-to-update-all-python-packages/
    # """
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['venv_prefix']="${1:?}"
    koopa_assert_is_dir "${dict['venv_prefix']}"
    dict['requirements']="$(koopa_mktemp)"
    koopa_python_activate_venv "${dict['venv_prefix']}"
    pip freeze > "$dict['requirements']}"
    pip install -r "${dict['requirements']}" --upgrade
    koopa_python_deactivate_venv
    koopa_rm "${dict['requirements']}"
    return 0
}
