#!/usr/bin/env bash

koopa_debian_uninstall_system_llvm() {
    koopa_uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}
