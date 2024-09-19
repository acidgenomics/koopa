#!/usr/bin/env bash

koopa_assert_can_install_from_source() {
    # """
    # Assert that current environment supports building from source.
    # @note Updated 2024-09-19.
    # """
    # FIXME Check for conda.
    # FIXME Check that specific programs are installed -- python3, cc, ld, etc.
    # FIXME Check that compiler version is current.
    # FIXME Consider adding koopa_is_cc_supported check.
    koopa_assert_has_no_args "$#"
    koopa_assert_conda_env_is_not_active
    # Some HPCs run with Python venv loaded, so disabling.
    # > koopa_assert_python_venv_is_not_active
    koopa_assert_is_installed 'python3'
    return 0
}
