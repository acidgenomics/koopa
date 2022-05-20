#!/usr/bin/env bash

koopa_debian_install_llvm() {
    koopa_install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}
