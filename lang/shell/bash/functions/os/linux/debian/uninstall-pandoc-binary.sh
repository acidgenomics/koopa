#!/usr/bin/env bash

koopa_debian_uninstall_pandoc_binary() {
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        --uninstaller='pandoc-binary' \
        "$@"
}
