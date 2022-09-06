#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix \
        'gettext' \
        'mpfr' \
        'readline'
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='gawk' \
        "$@"
}
