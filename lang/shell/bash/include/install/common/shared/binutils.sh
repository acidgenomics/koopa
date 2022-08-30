#!/usr/bin/env bash

main() {
    koopa_activate_build_opt_prefix 'bison'
    koopa_activate_opt_prefix 'zlib' 'texinfo'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}
