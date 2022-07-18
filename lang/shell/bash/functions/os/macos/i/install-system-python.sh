#!/usr/bin/env bash

koopa_macos_install_system_python_binary() {
    koopa_install_app \
        --installer='python-binary' \
        --link-in-bin='python3' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}
