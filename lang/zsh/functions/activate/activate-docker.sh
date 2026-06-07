#!/usr/bin/env zsh

_koopa_activate_docker() {
    _koopa_add_to_path_start "${HOME:?}/.docker/bin"
    return 0
}
