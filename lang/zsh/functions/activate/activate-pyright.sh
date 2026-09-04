#!/usr/bin/env zsh

_koopa_activate_pyright() {
    [[ -x "${KOOPA_PREFIX:?}/bin/pyright" ]] || return 0
    export PYRIGHT_PYTHON_IGNORE_WARNINGS='1'
    return 0
}
