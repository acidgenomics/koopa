#!/usr/bin/env bash

# NOTE This requires 'ed' to be installed on Ubuntu 20.

main() {
    koopa_activate_app --build-only 'texinfo'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='bc' \
        "$@"
}
