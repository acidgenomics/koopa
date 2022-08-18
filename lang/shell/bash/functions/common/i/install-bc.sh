#!/usr/bin/env bash

koopa_install_bc() {
    koopa_install_app \
        --link-in-bin='bc' \
        --name='bc' \
        "$@"
}
