#!/usr/bin/env bash

koopa_install_bat() {
    koopa_install_app \
        --link-in-bin='bat' \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}
