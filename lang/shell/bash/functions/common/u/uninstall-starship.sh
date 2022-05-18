#!/usr/bin/env bash

koopa_uninstall_starship() {
    koopa_uninstall_app \
        --unlink-in-bin='starship' \
        --name='starship' \
        "$@"
}
