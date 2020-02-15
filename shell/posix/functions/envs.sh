#!/bin/sh
# shellcheck disable=SC2039

_koopa_activate_conda_env() {  # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2020-01-21.
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
    _koopa_assert_is_installed conda
    local name
    name="${1:?}"
    local prefix
    prefix="$(_koopa_conda_prefix)"
    _koopa_h2 "Activating '${name}' conda environment at '${prefix}'."
    # Note that this function should only be called inside executable scripts,
    # so safe to adjust unbound variable settings here.
    set +u
    if ! type conda | grep -q conda.sh
    then
        # shellcheck source=/dev/null
        . "${prefix}/etc/profile.d/conda.sh"
    fi
    conda activate "$name"
    set -u
    return 0
}

_koopa_conda_default_envs_prefix() {  # {{{1
    # """
    # Locate the directory where conda environments are installed by default.
    # @note Updated 2019-10-26.
    # """
    _koopa_assert_is_installed conda
    conda info \
        | grep "envs directories" \
        | cut -d ':' -f 2 \
        | tr -d ' '
}

_koopa_conda_env() {  # {{{1
    # """
    # Conda environment name.
    # @note Updated 2020-01-12.
    #
    # Alternate approach:
    # > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
    # > export CONDA_PROMPT_MODIFIER
    # > conda="$CONDA_PROMPT_MODIFIER"
    #
    # See also:
    # - https://stackoverflow.com/questions/42481726
    # """
    echo "${CONDA_DEFAULT_ENV:-}"
}

_koopa_conda_env_list() {  # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2019-06-27.
    # """
    _koopa_is_installed conda || return 1
    conda env list --json
}

_koopa_conda_env_prefix() {  # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2020-01-16.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: _koopa_conda_env_prefix "deeptools"
    # """
    _koopa_is_installed conda || return 1
    local env_name
    env_name="${1:?}"
    [ -n "$env_name" ] || return 1
    local env_list
    env_list="${2:-$(_koopa_conda_env_list)}"
    env_list="$(echo "$env_list" | grep "$env_name")"
    if [ -z "$env_list" ]
    then
        _koopa_stop "Failed to detect prefix for '${env_name}'."
    fi
    local env_dir
    env_dir="$( \
        echo "$env_list" \
        | grep "/envs/${env_name}" \
        | head -n 1 \
    )"
    echo "$env_dir" | sed -E 's/^.*"(.+)".*$/\1/'
}

_koopa_deactivate_conda() {  # {{{1
    # """
    # Deactivate Conda environment.
    # @note Updated 2019-10-25.
    # """
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]
    then
        conda deactivate
    fi
    return 0
}

_koopa_deactivate_envs() {  # {{{1
    # """
    # Deactivate Conda and Python environments.
    # @note Updated 2019-10-25.
    # """
    _koopa_deactivate_venv
    _koopa_deactivate_conda
}

_koopa_deactivate_venv() {  # {{{1
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2019-10-25.
    #
    # The standard approach currently messes up autojump path:
    # # shellcheck disable=SC1090
    # > source "${VIRTUAL_ENV}/bin/activate"
    # > deactivate
    # """
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        _koopa_remove_from_path "${VIRTUAL_ENV}/bin"
        unset -v VIRTUAL_ENV
    fi
    return 0
}

_koopa_venv() {  # {{{1
    # """
    # Python virtual environment name.
    # @note Updated 2020-01-12.
    # """
    local env
    env="${VIRTUAL_ENV:-}"
    if [ -n "$env" ]
    then
        # Strip out the path and just leave the env name.
        env="${env##*/}"
    fi
    echo "$env"
}
