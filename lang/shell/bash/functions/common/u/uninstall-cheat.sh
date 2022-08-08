#!/usr/bin/env bash

koopa_uninstall_cheat() {
    koopa_uninstall_app \
        --name='cheat' \
        --unlink-in-bin='cheat' \
        "$@"
}
