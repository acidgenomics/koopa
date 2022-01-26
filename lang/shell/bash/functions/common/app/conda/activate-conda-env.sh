#!/usr/bin/env bash

koopa::activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2022-01-17.
    #
    # Designed to work inside calling scripts and/or subshells.
    #
    # Currently, the conda activation script returns a 'conda()' function in
    # the current shell that doesn't propagate to subshells. This function
    # attempts to rectify the current situation.
    #
    # Don't use absolute path to conda binary here. Needs to use the conda
    # function sourced in shell session, otherwise you will hit an
    # initialization error.
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
    local dict
    koopa::assert_has_args_eq "$#" 1
    declare -A dict=(
        [env_name]="${1:?}"
        [nounset]="$(koopa::boolean_nounset)"
    )
    dict[env_prefix]="$(koopa::conda_env_prefix "${dict[env_name]}")"
    koopa::assert_is_dir "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set +u
    koopa::is_conda_env_active && koopa::deactivate_conda
    koopa::activate_conda
    koopa::assert_is_function 'conda'
    conda activate "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -u
    return 0
}
