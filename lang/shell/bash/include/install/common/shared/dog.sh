#!/usr/bin/env bash

# FIXME Consider consolidating openssl code for dog and mdcat in rust-package.

main() {
    local dict
    koopa_activate_app 'openssl3'
    declare -A dict
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    export OPENSSL_DIR="${dict['openssl']}"
    koopa_add_rpath_to_ldflags "${dict['openssl']}/lib"
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='dog' \
        "$@"
}
