#!/usr/bin/env bash

koopa_install_pipx() {
    koopa_install_app \
        --link-in-bin='pipx' \
        --name='pipx' \
        "$@"
}
