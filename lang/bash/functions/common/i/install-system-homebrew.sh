#!/usr/bin/env bash

koopa_install_system_homebrew() {
    koopa_install_app \
        --name='homebrew' \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}
