#!/usr/bin/env bash

# NOTE Currently has build issues on Ubuntu 20 with Rust 1.61.

main() {
    # """
    # OpenSSL 3 is not currently supported.
    # Refer to 'https://docs.rs/openssl/latest/openssl/' for details.
    # """
    local dict
    koopa_activate_app 'openssl1'
    declare -A dict=(
        ['openssl']="$(koopa_app_prefix 'openssl1')"
    )
    export OPENSSL_DIR="${dict['openssl']}"
    koopa_add_rpath_to_ldflags "${dict['openssl']}/lib"
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='dog' \
        "$@"
}
