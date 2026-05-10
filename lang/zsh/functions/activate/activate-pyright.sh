#!/usr/bin/env zsh

_koopa_activate_pyright() {
    [[ -x "$(_koopa_bin_prefix)/pyright" ]] || return 0
    export PYRIGHT_PYTHON_FORCE_VERSION='latest'
    return 0
}
