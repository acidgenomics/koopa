#!/usr/bin/env bash

koopa_has_no_active_envs() {
    # """
    # Detect activation of Conda, Lmod, and Python virtual environments.
    # @note Updated 2024-09-18.
    # """
    koopa_assert_has_no_args "$#"
    koopa_is_conda_env_active && return 1
    koopa_is_lmod_active && return 1
    koopa_is_python_venv_active && return 1
    return 0
}
