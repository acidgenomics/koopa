#!/usr/bin/env bash

koopa_debian_uninstall_system_pandoc() {
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        --uninstaller='pandoc-binary' \
        "$@"
}
