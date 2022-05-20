#!/usr/bin/env bash

koopa_uninstall_r() {
    local uninstall_args
    uninstall_args=(
        '--name-fancy=R'
        '--name=r'
    )
    if ! koopa_is_macos && [[ ! -x '/usr/bin/R' ]]
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
