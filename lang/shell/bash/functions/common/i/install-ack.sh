#!/usr/bin/env bash

koopa_install_ack() {
    koopa_install_app \
        --link-in-bin='ack' \
        --name='ack' \
        "$@"
}
