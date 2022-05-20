#!/usr/bin/env bash

koopa_uninstall_gawk() {
    koopa_uninstall_app \
        --name='gawk' \
        --unlink-in-bin='awk' \
        "$@"
}
