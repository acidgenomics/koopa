#!/usr/bin/env bash

main() {
    koopa_activate_app --build-only 'texinfo'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='bc' \
        "$@"
}
