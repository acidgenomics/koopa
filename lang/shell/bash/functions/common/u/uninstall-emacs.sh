#!/usr/bin/env bash

# FIXME Need to enable '--no-link-in-bin' and '--no-link-in-man1'

koopa_uninstall_emacs() {
    local uninstall_args
    uninstall_args=(
        '--name=emacs'
    )
    # Assume we're using Emacs cask by default on macOS.
    if ! koopa_is_macos
    then
        uninstall_args+=('--unlink-in-bin=emacs')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}
