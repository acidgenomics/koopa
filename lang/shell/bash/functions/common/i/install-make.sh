#!/usr/bin/env bash

koopa_install_make() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='make' \
        --name='make' \
        "$@"
}
