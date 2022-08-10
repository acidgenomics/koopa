#!/usr/bin/env bash

# FIXME This didn't create symlink correctly on macOS...what's up?

koopa_install_r() {
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
