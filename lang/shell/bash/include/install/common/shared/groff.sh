#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'texinfo'
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='groff' \
        "$@"
}
