#!/usr/bin/env bash

# FIXME Need to apply patches for this.
# https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/mpfr.rb

main() {
    koopa_activate_app 'gmp'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='mpfr' \
        -D '--disable-static'
}
