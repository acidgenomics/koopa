#!/usr/bin/env bash

koopa_install_emacs() {
    # """
    # Assume we're using Emacs cask by default on macOS.
    # """
    local install_args
    install_args=('--name=emacs')
    if ! koopa_is_macos
    then
        install_args+=(
            '--no-link-in-bin'
            '--no-link-in-man1'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
