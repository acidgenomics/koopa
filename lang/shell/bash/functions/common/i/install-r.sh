#!/usr/bin/env bash

# FIXME Ensure we link koopa R and Rscript on macOS.

koopa_install_r() {
    # ""
    # Assume we're linking R CRAN binary on macOS instead.
    # """
    local install_args
    install_args=('--name=r')
    if koopa_is_linux && [[ ! -x '/usr/bin/R' ]]
    then
        install_args+=(
            '--link-in-bin=R'
            '--link-in-bin=Rscript'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
