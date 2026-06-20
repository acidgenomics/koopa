#!/usr/bin/env bash

_koopa_activate_pyright() {
    [[ -x "${KOOPA_PREFIX:?}/bin/pyright" ]] || return 0
    export PYRIGHT_PYTHON_FORCE_VERSION='latest'
    return 0
}
