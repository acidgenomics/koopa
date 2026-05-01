#!/usr/bin/env bash

_koopa_macos_uninstall_system_oracle_java() {
    _koopa_uninstall_app \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}
