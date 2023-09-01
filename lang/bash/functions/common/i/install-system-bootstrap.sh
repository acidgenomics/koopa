#!/usr/bin/env bash

koopa_install_system_bootstrap() {
    koopa_install_app \
        --name='bootstrap' \
        --system \
        "$@"
}
