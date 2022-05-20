#!/usr/bin/env bash

koopa_uninstall_python() {
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Python'
        '--name=python'
    )
    if ! koopa_is_macos
    then
        uninstall_args+=('--unlink-in-bin=python3')
    fi
    koopa_uninstall_app \
        "${uninstall_args[@]}" \
        "$@"
}
