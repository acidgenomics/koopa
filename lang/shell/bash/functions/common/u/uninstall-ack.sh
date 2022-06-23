#!/usr/bin/env bash

koopa_uninstall_ack() {
    koopa_uninstall_app \
        --name='ack' \
        --unlink-in-bin='ack' \
        "$@"
}
