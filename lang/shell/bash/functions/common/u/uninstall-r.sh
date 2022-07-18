#!/usr/bin/env bash

koopa_uninstall_r() {
    local uninstall_args
    uninstall_args=(
        '--name=r'
    )
    if ! koopa_is_macos
    then
        install_args+=(
            '--unlink-in-bin=R'
            '--unlink-in-bin=Rscript'
        )
    fi
    koopa_uninstall_app \
        "${uninstall_args[@]}" \
        "$@"
}
