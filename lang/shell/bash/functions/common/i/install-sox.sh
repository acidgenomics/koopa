#!/usr/bin/env bash

koopa_install_sox() {
    koopa_install_app \
        --link-in-bin='bin/sox' \
        --name-fancy='SoX' \
        --name='sox' \
        "$@"
}
