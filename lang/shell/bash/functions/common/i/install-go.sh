#!/usr/bin/env bash

koopa_install_go() {
    koopa_install_app \
        --link-in-bin='go' \
        --name='go' \
        "$@"
}
