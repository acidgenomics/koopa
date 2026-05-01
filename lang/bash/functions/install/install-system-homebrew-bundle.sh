#!/usr/bin/env bash

_koopa_install_system_homebrew_bundle() {
    _koopa_install_app \
        --name='homebrew-bundle' \
        --system \
        "$@"
}
