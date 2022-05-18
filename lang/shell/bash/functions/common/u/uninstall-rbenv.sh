#!/usr/bin/env bash

koopa_uninstall_rbenv() {
    koopa_uninstall_app \
        --name='rbenv' \
        --unlink-in-bin='rbenv' \
        "$@"
}
