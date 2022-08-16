#!/usr/bin/env bash

koopa_install_zellij() {
    koopa_install_app \
        --link-in-bin='zellij' \
        --name='zellij' \
        "$@"
}
