#!/usr/bin/env bash

koopa_uninstall_mcfly() {
    koopa_uninstall_app \
        --name='mcfly' \
        --unlink-in-bin='mcfly' \
        "$@"
}
