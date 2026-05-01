#!/usr/bin/env zsh

_koopa_xdg_local_home() {
    _koopa_print "${HOME:?}/.local"
    return 0
}
