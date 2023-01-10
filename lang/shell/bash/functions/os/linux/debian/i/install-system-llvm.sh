#!/usr/bin/env bash

koopa_debian_install_system_llvm() {
    koopa_install_app \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}
