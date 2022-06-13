#!/usr/bin/env bash

koopa_install_zellij() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/zellij' \
        --name='zellij' \
        "$@"
}
