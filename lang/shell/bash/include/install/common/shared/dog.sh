#!/usr/bin/env bash

main() {
    local dict
    local -A dict
    koopa_activate_app 'openssl1'
    dict['openssl']="$(koopa_app_prefix 'openssl1')"
    export OPENSSL_DIR="${dict['openssl']}"
    koopa_add_rpath_to_ldflags "${dict['openssl']}/lib"
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='dog' \
        "$@"
}
