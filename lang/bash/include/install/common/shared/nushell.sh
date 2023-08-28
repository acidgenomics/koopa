#!/usr/bin/env bash

# NOTE Consider adding libx11, libxcb.

main() {
    # """
    # Install nushell.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://www.nushell.sh/book/installation.html#build-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nushell.rb
    # - https://crates.io/crates/nu
    # """
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib' 'openssl3'
    OPENSSL_DIR="$(koopa_app_prefix 'openssl3')"
    export OPENSSL_DIR
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='nushell' \
        -D '--cargo-name=nu' \
        -D '--features=extra'
}
