#!/usr/bin/env bash

koopa_uninstall_neofetch() {
    koopa_uninstall_app \
        --name='neofetch' \
        --unlink-in-bin='neofetch' \
        "$@"
}
