#!/usr/bin/env bash

# FIXME Split out the installer code.

main() {
    koopa_install_app_subshell \
        --installer='gnupg-gcrypt' \
        --name='gnupg'
}
