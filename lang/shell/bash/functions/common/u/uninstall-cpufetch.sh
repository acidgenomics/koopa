#!/usr/bin/env bash

koopa_uninstall_cpufetch() {
    koopa_uninstall_app \
        --name='cpufetch' \
        --unlink-in-bin='cpufetch' \
        "$@"
}
