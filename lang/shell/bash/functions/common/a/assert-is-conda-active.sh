#!/usr/bin/env bash

koopa_assert_is_conda_active() {
    # """
    # Assert that a Conda environment is active.
    # @note Updated 2020-07-03.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_conda_active
    then
        koopa_stop 'No active Conda environment detected.'
    fi
    return 0
}
