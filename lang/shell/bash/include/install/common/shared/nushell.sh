#!/usr/bin/env bash

# NOTE Consider adding libx11, libxcb.

main() {
    # """
    # @seealso
    # - https://www.nushell.sh/book/installation.html#build-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nushell.rb
    # - https://crates.io/crates/nu
    # """
    koopa_activate_opt_prefix 'zlib' 'openssl3'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='nushell' \
        "$@"
}
