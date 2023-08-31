#!/usr/bin/env bash

koopa_macos_install_system_python() {
    koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}
