#!/usr/bin/env bash

koopa_macos_uninstall_system_python() {
    koopa_uninstall_app \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}
