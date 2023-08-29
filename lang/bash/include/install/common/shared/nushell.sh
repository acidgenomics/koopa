#!/usr/bin/env bash

# NOTE Consider adding libx11, libxcb.

main() {
    # """
    # Install nushell.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://www.nushell.sh/book/installation.html#build-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nushell.rb
    # - https://crates.io/crates/nu
    # """
    local -A dict
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib'
    dict['features']='extra'
    dict['name']='nu'
    koopa_install_rust_package \
        --features="${dict['features']}" \
        --name="${dict['name']}" \
        --with-openssl
    return 0
}
