#!/usr/bin/env bash

koopa_install_homebrew() {
    koopa_install_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --no-prefix-check \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}
