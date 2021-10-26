#!/bin/sh

_koopa_conda_env_name() { # {{{1
    # """
    # Conda environment name.
    # @note Updated 2020-08-17.
    #
    # Alternate approach:
    # > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
    # > export CONDA_PROMPT_MODIFIER
    # > conda="$CONDA_PROMPT_MODIFIER"
    #
    # See also:
    # - https://stackoverflow.com/questions/42481726
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${CONDA_DEFAULT_ENV:-}"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_deactivate_anaconda() { # {{{1
    # """
    # Deactivate Anaconda environment.
    # @note Updated 2021-10-26.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_deactivate_conda
    return 0
}

_koopa_deactivate_conda() { # {{{1
    # """
    # Deactivate Conda environment.
    # @note Updated 2021-08-17.
    # """
    local env_name nounset
    [ "$#" -eq 0 ] || return 1
    env_name="$(_koopa_conda_env_name)"
    if [ -z "$env_name" ]
    then
        _koopa_warn 'conda is not active.'
        return 1
    fi
    # Avoid exit on unbound PS1 in conda script.
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    conda deactivate
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_deactivate_python_venv() { # {{{1
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2021-08-17.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="${VIRTUAL_ENV:-}"
    if [ -z "$prefix" ]
    then
        _koopa_warn 'Python virtual environment is not active.'
        return 1
    fi
    _koopa_remove_from_path "${prefix}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

_koopa_python_venv_name() { # {{{1
    # """
    # Python virtual environment name.
    # @note Updated 2021-08-17.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    # Strip out the path and just leave the env name.
    x="${x##*/}"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
