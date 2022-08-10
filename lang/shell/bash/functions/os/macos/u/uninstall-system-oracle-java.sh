#!/usr/bin/env bash

koopa_macos_uninstall_system_oracle_java() {
    koopa_uninstall_app \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}
