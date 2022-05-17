#!/usr/bin/env bash

koopa_uninstall_bc() {
    koopa_uninstall_app \
        --name='bc' \
        --unlink-in-bin='bc' \
        "$@"
}
