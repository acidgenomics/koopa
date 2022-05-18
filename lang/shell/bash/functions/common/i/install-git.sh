#!/usr/bin/env bash

koopa_install_git() {
    local install_args
    install_args=(
        '--link-in-bin=bin/git'
        '--name-fancy=Git'
        '--name=git'
    )
    if koopa_is_macos
    then
        install_args+=(
            '--link-in-bin=bin/git-credential-osxkeychain'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
