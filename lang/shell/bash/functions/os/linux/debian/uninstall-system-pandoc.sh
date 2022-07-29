#!/usr/bin/env bash

koopa_debian_uninstall_system_pandoc() {
    koopa_uninstall_app \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}
