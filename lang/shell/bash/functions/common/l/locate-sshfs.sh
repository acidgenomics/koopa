#!/usr/bin/env bash

# FIXME Need to add install support for this.

koopa_locate_sshfs() {
    koopa_locate_app \
        --app-name='sshfs' \
        --bin-name='sshfs' \
        "$@"
}
