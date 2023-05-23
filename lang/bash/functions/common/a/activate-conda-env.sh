#!/usr/bin/env bash

koopa_activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2023-05-23.
    #
    # Designed to work inside calling scripts and/or subshells.
    #
    # Currently, the conda activation script returns a 'conda()' function in
    # the current shell that doesn't propagate to subshells. This function
    # attempts to rectify the current situation.
    #
    # Note that the conda activation script currently has unbound variables
    # (e.g. PS1), that will cause this step to fail unless we temporarily
    # disable unbound variable checks.
    #
    # Alternate approach:
    # > eval "$(conda shell.bash hook)"
    #
    # See also:
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    local -A bool dict
    koopa_assert_has_args_eq "$#" 1
    if koopa_is_conda_env_active
    then
        koopa_stop 'Conda environment is already active.'
    fi
    bool['nounset']="$(koopa_boolean_nounset)"
    dict['env']="${1:?}"
    [[ "${bool['nounset']}" -eq 1 ]] && set +u
    koopa_activate_conda
    conda activate "${dict['env']}"
    [[ "${bool['nounset']}" -eq 1 ]] && set -u
    return 0
}
