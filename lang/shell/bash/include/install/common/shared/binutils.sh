#!/usr/bin/env bash

main() {
    # """
    # Consider including zlib.
    # """
    koopa_activate_opt_prefix 'texinfo'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}
