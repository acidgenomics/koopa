#!/usr/bin/env bash

koopa_macos_uninstall_system_python() {
    koopa_uninstall_app \
        --name='python3.13' \
        --platform='macos' \
        --system \
        --uninstaller='python' \
        "$@"
}
