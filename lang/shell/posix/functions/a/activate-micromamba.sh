#!/bin/sh

koopa_activate_micromamba() {
    # """
    # Activate mamba (micromamba).
    # @note Update 2022-12-07.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba/issues/984
    # - https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html
    # - https://mamba.readthedocs.io/en/latest/user_guide/configuration.html
    # """
    if [ -z "${MAMBA_ROOT_PREFIX:-}" ]
    then
        export MAMBA_ROOT_PREFIX="${HOME:?}/.mamba"
    fi
    return 0
}
