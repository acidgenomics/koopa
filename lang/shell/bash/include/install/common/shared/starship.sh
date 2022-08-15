#!/usr/bin/env bash

main() {
    koopa_activate_build_opt_prefix 'cmake'
    koopa_install_app_internal \
        --installer='rust-package' \
        --name='starship' \
        "$@"
}
