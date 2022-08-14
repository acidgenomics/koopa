#!/usr/bin/env bash

koopa_install_conda() {
    koopa_install_app \
        --link-in-bin='conda' \
        --name='conda' \
        "$@"
}
