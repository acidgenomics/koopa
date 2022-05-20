#!/bin/sh

koopa_is_conda_env_active() {
    # """
    # Is a Conda environment (other than base) active?
    # @note Updated 2021-08-17.
    # """
    [ "${CONDA_SHLVL:-1}" -gt 1 ] && return 0
    [ "${CONDA_DEFAULT_ENV:-base}" != 'base' ] && return 0
    return 1
}
