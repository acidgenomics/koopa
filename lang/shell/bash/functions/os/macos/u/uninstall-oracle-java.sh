#!/usr/bin/env bash

koopa_macos_uninstall_oracle_java() {
    koopa_uninstall_app \
        --name-fancy='Oracle Java' \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}
