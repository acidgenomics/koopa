#!/usr/bin/env bash

main() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='pinentry' \
        "$@"
}
