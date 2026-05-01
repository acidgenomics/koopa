#!/usr/bin/env bash

_koopa_install_system_homebrew() {
    _koopa_install_app \
        --name='homebrew' \
        --prefix="$(_koopa_homebrew_prefix)" \
        --system \
        "$@"
}
