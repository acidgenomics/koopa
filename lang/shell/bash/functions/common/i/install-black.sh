#!/usr/bin/env bash

koopa_install_black() {
    koopa_install_app \
        --link-in-bin='black' \
        --name='black' \
        "$@"
}
