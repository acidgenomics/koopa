#!/usr/bin/env bash

koopa_macos_uninstall_python_binary() {
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        --uninstaller='python-binary' \
        --unlink-in-bin='python3' \
        "$@"
}
