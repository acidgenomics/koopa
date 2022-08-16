#!/usr/bin/env bash

koopa_install_sed() {
    koopa_install_app \
        --link-in-bin='sed' \
        --name='sed' \
        "$@"
}
