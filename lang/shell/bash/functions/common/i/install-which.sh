#!/usr/bin/env bash

koopa_install_which() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='which' \
        --name='which' \
        "$@"
}
