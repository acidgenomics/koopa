#!/usr/bin/env bash

koopa_install_units() {
    koopa_install_app \
        --link-in-bin='units' \
        --name='units' \
        "$@"
}
