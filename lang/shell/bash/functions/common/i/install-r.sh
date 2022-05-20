#!/usr/bin/env bash

koopa_install_r() {
    # """
    # Assuming usage of R CRAN binary Homebrew cask on macOS.
    # Also don't link in the case of Debian R CRAN binary.
    # """
    local install_args
    install_args=(
        '--name-fancy=R'
        '--name=r'
    )
    if ! koopa_is_macos && [[ ! -x '/usr/bin/R' ]]
    then
        install_args+=(
            '--link-in-bin=bin/R'
            '--link-in-bin=bin/Rscript'
        )
    fi
    koopa_install_app \
        "${install_args[@]}" \
        "$@"
}
