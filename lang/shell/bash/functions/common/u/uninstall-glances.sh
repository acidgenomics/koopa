#!/usr/bin/env bash

koopa_uninstall_glances() {
    koopa_uninstall_app \
        --name='glances' \
        --unlink-in-bin='glances' \
        "$@"
}
