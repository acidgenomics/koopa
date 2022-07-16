#!/usr/bin/env bash

koopa_install_perl() {
    koopa_install_app \
        --link-in-bin='perl' \
        --name='perl' \
        "$@"
}
