#!/usr/bin/env bash

# FIXME Split out the install script.

main() {
    koopa_install_app_subshell \
        --installer='gnupg-gcrypt' \
        --name='npth'
}
