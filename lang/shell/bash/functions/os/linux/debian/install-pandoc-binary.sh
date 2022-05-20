#!/usr/bin/env bash

koopa_debian_install_pandoc_binary() {
    koopa_install_app \
        --installer='pandoc-binary' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}
