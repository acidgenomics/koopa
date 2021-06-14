#!/bin/sh

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
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${CONDA_DEFAULT_ENV:-}"
    return 0
}

_koopa_deactivate_conda() { # {{{1
    # """
    # Deactivate Conda environment.
    # @note Updated 2020-06-30.
    # """
    local nounset
    [ "$#" -eq 0 ] || return 1
    [ -n "${CONDA_DEFAULT_ENV:-}" ] || return 0
    # Avoid exit on unbound PS1 in conda script.
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    conda deactivate
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_deactivate_envs() { # {{{1
    # """
    # Deactivate Conda and Python environments.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_deactivate_venv
    _koopa_deactivate_conda
    return 0
}

_koopa_deactivate_python_venv() { # {{{1
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2021-06-14.
    # """
    [ "$#" -eq 0 ] || return 1
    [ -n "${VIRTUAL_ENV:-}" ] || return 0
    _koopa_remove_from_path "${VIRTUAL_ENV}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

_koopa_venv_name() { # {{{1
    # """
    # Python virtual environment name.
    # @note Updated 2020-06-30.
    # """
    local env
    [ "$#" -eq 0 ] || return 1
    env="${VIRTUAL_ENV:-}"
    [ -n "$env" ] || return 1
    # Strip out the path and just leave the env name.
    env="${env##*/}"
    _koopa_print "$env"
    return 0
}
