#!/usr/bin/env bash

main() {
    koopa_activate_app 'texinfo'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='groff'
}
