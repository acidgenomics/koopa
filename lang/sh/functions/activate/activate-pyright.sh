#!/bin/sh

_koopa_activate_pyright() {
    # """
    # Disable pyright version check spam.
    # @note Updated 2026-09-04.
    # """
    [ -x "${KOOPA_PREFIX:?}/bin/pyright" ] || return 0
    export PYRIGHT_PYTHON_IGNORE_WARNINGS='1'
    return 0
}
