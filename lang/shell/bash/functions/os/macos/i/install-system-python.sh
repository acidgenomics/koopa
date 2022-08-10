#!/usr/bin/env bash

koopa_macos_install_system_python() {
    koopa_install_app \
        --name='python' \
        --no-prefix-check \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}
