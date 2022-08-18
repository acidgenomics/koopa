#!/usr/bin/env bash

koopa_install_dog() {
    koopa_install_app \
        --link-in-bin='dog' \
        --name='dog' \
        "$@"
}
