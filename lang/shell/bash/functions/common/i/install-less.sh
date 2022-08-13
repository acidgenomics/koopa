#!/usr/bin/env bash

koopa_install_less() {
    koopa_install_app \
        --link-in-bin='less' \
        --name='less' \
        "$@"
}
