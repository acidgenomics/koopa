#!/usr/bin/env bash

koopa_install_htop() {
    koopa_install_app \
        --link-in-bin='htop' \
        --name='htop' \
        "$@"
}
