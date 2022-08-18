#!/usr/bin/env bash

koopa_install_pylint() {
    koopa_install_app \
        --link-in-bin='pylint' \
        --name='pylint' \
        "$@"
}
