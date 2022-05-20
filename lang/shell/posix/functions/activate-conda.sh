#!/bin/sh

koopa_activate_conda() {
    # """
    # Activate conda using 'activate' script.
    # @note Updated 2022-02-02.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba/issues/984
    # """
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(koopa_conda_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_is_alias 'mamba' && unalias 'mamba'
    nounset="$(koopa_boolean_nounset)"
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
    # Suppress mamba ASCII banner.
    [ -z "${MAMBA_NO_BANNER:-}" ] && export MAMBA_NO_BANNER=1
    return 0
}
