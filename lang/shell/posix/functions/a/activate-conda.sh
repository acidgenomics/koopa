#!/bin/sh

_koopa_activate_conda() {
    # """
    # Activate conda using 'activate' script.
    # @note Updated 2023-03-20.
    # """
    __kvar_deactivate=0
    __kvar_prefix="${1:-}"
    if [ -z "$__kvar_prefix" ]
    then
        __kvar_deactivate=1
        __kvar_prefix="$(_koopa_conda_prefix)"
    fi
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v \
            __kvar_deactivate \
            __kvar_prefix
        return 0
    fi
    __kvar_script="${__kvar_prefix}/bin/activate"
    if [ ! -r "$__kvar_script" ]
    then
        unset -v \
            __kvar_deactivate \
            __kvar_prefix \
            __kvar_script
        return 0
    fi
    _koopa_is_alias 'conda' && unalias 'conda'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$__kvar_script"
    if [ "$__kvar_deactivate" -eq 1 ] && \
        [ "${CONDA_DEFAULT_ENV:-}" = 'base' ] && \
        [ "${CONDA_SHLVL:-0}" -eq 1 ]
    then
        conda deactivate
    fi
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_deactivate \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_script
    return 0
}
