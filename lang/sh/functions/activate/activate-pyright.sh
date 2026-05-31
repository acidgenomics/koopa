#!/bin/sh

_koopa_activate_pyright() {
    # """
    # Disable pyright version check spam.
    # @note Updated 2025-05-06.
    # """
    [ -x "${KOOPA_PREFIX:?}/bin/pyright" ] || return 0
    export PYRIGHT_PYTHON_FORCE_VERSION='latest'
    return 0
}
