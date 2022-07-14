#!/usr/bin/env bash

koopa_install_system_homebrew_bundle() {
    koopa_install_app \
        --name-fancy='Homebrew bundle' \
        --name='homebrew-bundle' \
        --system \
        "$@"
}
