#!/usr/bin/env bash

koopa_install_isort() {
    koopa_install_app \
        --link-in-bin='isort' \
        --name='isort' \
        "$@"
}
