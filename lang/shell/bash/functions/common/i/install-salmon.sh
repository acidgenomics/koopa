#!/usr/bin/env bash

koopa_install_salmon() {
    koopa_install_app \
        --link-in-bin='salmon' \
        --name='salmon' \
        "$@"
}
