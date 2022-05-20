#!/usr/bin/env bash

koopa_conda_activate_env() {
    # """
    # Activate a conda environment.
    # @note Updated 2022-03-16.
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
    # @seealso
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [env_name]="${1:?}"
        [nounset]="$(koopa_boolean_nounset)"
    )
    dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_alert_info "Attempting to install missing conda \
environment '${dict[env_name]}'."
        koopa_conda_create_env "${dict[env_name]}"
        dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    fi
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_stop "'${dict[env_name]}' conda environment is not installed."
    fi
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    koopa_is_conda_env_active && koopa_conda_deactivate
    koopa_activate_conda
    koopa_assert_is_function 'conda'
    conda activate "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}
