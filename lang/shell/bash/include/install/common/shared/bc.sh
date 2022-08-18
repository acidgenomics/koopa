#!/usr/bin/env bash

main() {
    koopa_activate_build_opt_prefix 'texinfo'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='bc' \
        "$@"
}
