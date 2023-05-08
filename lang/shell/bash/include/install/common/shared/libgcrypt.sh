#!/usr/bin/env bash

# FIXME This is now failing to build on macOS.
# Need to apply patch documented here:
# https://dev.gnupg.org/T6442
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgcrypt.rb

main() {
    koopa_install_app_subshell \
        --installer='gnupg-gcrypt' \
        --name='libgcrypt'
}
