#!/usr/bin/env bash

koopa_conda_deactivate() {
    # """
    # Deactivate Conda environment.
    # @note Updated 2023-03-09.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['env_name']="${CONDA_DEFAULT_ENV:-}"
        ['nounset']="$(koopa_boolean_nounset)"
    )
    if [[ -z "${dict['env_name']}" ]]
    then
        koopa_stop 'conda is not active.'
    fi
    koopa_assert_is_function 'conda'
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    conda deactivate
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}
