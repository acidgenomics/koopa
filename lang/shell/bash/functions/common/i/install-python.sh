#!/usr/bin/env bash

koopa_install_python() {
    # """
    # Assuming usage of Python binary on macOS.
    # """
    local install_args
    install_args=(
        '--name-fancy=Python'
        '--name=python'
    )
    if ! koopa_is_macos
    then
        install_args+=('--link-in-bin=bin/python3')
    fi
    koopa_install_app \
        "${install_args[@]}" \
        "$@"
}
