#!/usr/bin/env bash

koopa_has_no_environments() {
    # """
    # Detect activation of virtual environments.
    # @note Updated 2021-06-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_is_conda_active && return 1
    koopa_is_python_venv_active && return 1
    return 0
}
