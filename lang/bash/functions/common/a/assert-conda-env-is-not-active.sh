#!/usr/bin/env bash

koopa_assert_conda_env_is_not_active() {
    # """
    # Assert that a Conda environment is not active.
    # @note Updated 2024-09-18.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_conda_env_active
    then
        koopa_stop \
            'Active Conda environment detected.' \
            "Run 'conda deactivate' command before proceeding."
    fi
    return 0
}
