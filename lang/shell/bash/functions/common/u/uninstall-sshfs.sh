#!/usr/bin/env bash

koopa_uninstall_sshfs() {
    koopa_uninstall_app \
        --name='sshfs' \
        "$@"
}
