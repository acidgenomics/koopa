#!/usr/bin/env bash

koopa_uninstall_gnupg() {
    koopa_uninstall_app \
        --name-fancy='gnupg suite' \
        --name='gnupg' \
        "$@"
}
