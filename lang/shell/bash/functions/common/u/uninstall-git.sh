#!/usr/bin/env bash

koopa_uninstall_git() {
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Git'
        '--name=git'
        '--unlink-in-bin=git'
    )
    if koopa_is_macos
    then
        uninstall_args+=(
            '--unlink-in-bin=git-credential-osxkeychain'
        )
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}
