#!/bin/sh

_koopa_activate_conda() {
    # """
    # Activate conda using 'activate' script.
    # @note Updated 2022-12-07.
    # """
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_conda_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_is_alias 'mamba' && unalias 'mamba'
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$script"
    # Ensure the base environment is deactivated by default.
    if [ "${CONDA_DEFAULT_ENV:-}" = 'base' ] && \
        [ "${CONDA_SHLVL:-0}" -eq 1 ]
    then
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
