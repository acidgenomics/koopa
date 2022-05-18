#!/usr/bin/env bash

koopa_install_htop() {
    koopa_install_app \
        --link-in-bin='bin/htop' \
        --name='htop' \
        "$@"
}
