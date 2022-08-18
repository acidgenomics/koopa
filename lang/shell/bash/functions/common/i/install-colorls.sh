#!/usr/bin/env bash

koopa_install_colorls() {
    koopa_install_app \
        --link-in-bin='colorls' \
        --name='colorls' \
        "$@"
}
