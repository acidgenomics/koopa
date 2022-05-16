#!/usr/bin/env bash

koopa_assert_has_no_envs() {
    # """
    # Assert that conda and Python virtual environments aren't active.
    # @note Updated 2020-07-01.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_has_no_environments
    then
        koopa_stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in PATH."
    fi
    return 0
}
