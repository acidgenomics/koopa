#!/usr/bin/env bash

koopa_uninstall_perl() {
    koopa_uninstall_app \
        --name='perl' \
        --unlink-in-bin='perl' \
        "$@"
}
