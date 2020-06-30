#!/bin/sh
# shellcheck disable=SC2039

_koopa_conda_env() { # {{{1
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
    _koopa_print "${CONDA_DEFAULT_ENV:-}"
}

_koopa_conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2019-06-27.
    # """
    _koopa_is_installed conda || return 1
    conda env list --json
}

_koopa_conda_env_prefix() { # {{{1
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
    env_list="$(_koopa_print "$env_list" | grep "$env_name")"
    if [ -z "$env_list" ]
    then
        _koopa_stop "Failed to detect prefix for '${env_name}'."
    fi
    local env_dir
    env_dir="$( \
        _koopa_print "$env_list" \
        | grep "/envs/${env_name}" \
        | head -n 1 \
    )"
    _koopa_print "$env_dir" | sed -E 's/^.*"(.+)".*$/\1/'
}

_koopa_deactivate_conda() { # {{{1
    # """
    # Deactivate Conda environment.
    # @note Updated 2020-04-30.
    # """
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]
    then
        # Avoid exit on unbound PS1 in conda script.
        local nounset
        nounset="$(_koopa_boolean_nounset)"
        [ "$nounset" -eq 1 ] && set +u
        conda deactivate
        [ "$nounset" -eq 1 ] && set -u
    fi
    return 0
}

_koopa_deactivate_envs() { # {{{1
    # """
    # Deactivate Conda and Python environments.
    # @note Updated 2019-10-25.
    # """
    _koopa_deactivate_venv
    _koopa_deactivate_conda
}

_koopa_deactivate_venv() { # {{{1
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

_koopa_venv() { # {{{1
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
    _koopa_print "$env"
}
