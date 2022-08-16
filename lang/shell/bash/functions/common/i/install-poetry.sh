#!/usr/bin/env bash

koopa_install_poetry() {
    koopa_install_app \
        --link-in-bin='poetry' \
        --name='poetry' \
        "$@"
}
