#!/usr/bin/env bash

_koopa_assert_conda_env_is_not_active() {
    # """
    # Assert that a Conda environment is not active.
    # @note Updated 2024-09-18.
    # """
    _koopa_assert_has_no_args "$#"
    if _koopa_is_conda_env_active
    then
        _koopa_stop \
            'Active Conda environment detected.' \
            "Run 'conda deactivate' command before proceeding."
    fi
    return 0
}
